import os
import sys
import pickle as pkl
import numpy as np
import logging
import galsim
from scipy import interpolate
import matplotlib.pyplot as plt
from astropy.io import fits
from astropy.table import Table, vstack
from astropy.stats import SigmaClip, sigma_clip

from lsst.daf.butler import Butler
from lsst.obs.lsst import LsstCam
from lsst.afw.cameraGeom.utils import findAmp
from lsst.geom import Point2I

from photutils.background import Background2D, MedianBackground

sys.path.append('/home/a/abrought/bin/PSFHOME/psfhome')
from moments import *


sigma_clip = SigmaClip(sigma=6.)
bkg_estimator = MedianBackground()

# Lookup tables
SLACAMPS = {'C10': 'AMP01', 'C11': 'AMP02', 'C12': 'AMP03', 'C13': 'AMP04',
            'C14': 'AMP05', 'C15': 'AMP06', 'C16': 'AMP07', 'C17': 'AMP08',
            'C07': 'AMP09', 'C06': 'AMP10', 'C05': 'AMP11', 'C04': 'AMP12',
            'C03': 'AMP13', 'C02': 'AMP14', 'C01': 'AMP15', 'C00': 'AMP16'}

CHANNELTOAMP = {'C10': 1, 'C11': 2, 'C12': 3, 'C13': 4, 'C14': 5,
                'C15': 6, 'C16': 7, 'C17': 8, 'C07': 9, 'C06': 10,
                'C05': 11, 'C04': 12, 'C03': 13, 'C02': 14,
                'C01': 15, 'C00': 16}


def nsigfig(num, sig=3):
    """Convert a number to n significant figures.

    Args:
        num (float): number to convert.
        sig (int, optional): number of significant figures. Defaults to 3.

    Returns:
        str: string representation of converted number.
    """
    return np.format_float_positional(num, precision=sig, unique=False, fractional=False, trim='k')


def format_number(num, sig=3):
    """Convert a number to scientific notation with n significant figures.

    Args:
        num (float): number to convert.
        sig (int, optional): number of significant figures. Defaults to 3.

    Returns:
        str: string representation of converted number.
    """
    return np.format_float_scientific(num, precision=sig, unique=False, trim='k')


def get_outlier_mask(d, m=3):
    """_summary_

    Args:
        d (numpy.ndarray, float): Data vector.
        m (int, optional): sigma clipping threshold. Defaults to 3.

    Returns:
        _type_: mask with valid points within threshold are True.
    """
    return (np.abs(d - np.mean(d)) <= m * np.std(d))


def get_unique_indices(records_array):
    """Get unique indices within an array

    Args:
        records_array (numpy.ndarray, str): array of strings..

    Returns:
        numpy.ndarray: list of indexes corresponding to unique elements.
    """
    vals, indxs = np.unique(records_array, return_index=True)
    return indxs


def remove_bad_exps(expstoremove, data, verbose=False):
    """Remove the first few exposures everytime the projector position moves.

    Args:
        expstoremove (int): number of exposures to clip everytime the projector moved.
        data (astropy.Table): table of exposures.
        verbose (bool, optional): print out the sequence numbers that have been removed. Defaults to False.

    Returns:
        astropy.Table: row-truncated table
    """
    if expstoremove == 0:
        return data
    if verbose:
        print("Removing SEQNUMs:", end="\n\n")
    unique_pos = np.unique(np.asarray(np.round(data['BOTX'], 0)) / np.asarray(np.round(data['BOTY'], 0)))
    if expstoremove > 0:
        for pos in unique_pos:
            cond = (np.asarray(np.round(data['BOTX'], 0)) / np.asarray(np.round(data['BOTY'], 0)) == pos)
            temp = data[cond]

            for n in range(expstoremove):
                exp = np.argwhere((data['MJD'] == np.sort(temp['MJD'])[n]))[0][0]
                if verbose:
                    print(data[exp]["SEQNUM"], end=" ")
                data.remove_row(exp)

    return data


def read_data(filename1, filename2=None, expstoremove=0, verbose=False):
    """Read in data from a generated table. Optionally, trim off bad exposures.

    Args:
        filename1 (str): file corresponding to pickled data table.
        filename2 (str, optional): file corresponding to pickled data. If not None, 
                                   then it is appended to the end of file 1's data 
                                   table. Defaults to None.
        expstoremove (int, optional): number of exposures to clip everytime the projector 
                                      moved. Defaults to 0.
        verbose (bool, optional): print out the sequence numbers that have been removed. 
                                  Defaults to False.

    Returns:
       tuple (list): PTC turnoffs , sCTI turnoffs, pCTI turnoffs, maximum observed signals, gains
    """

    if filename2 is None:
        data = Table(pkl.load(open(filename1, "rb")))
        data = remove_bad_exps(expstoremove, data, verbose=verbose).group_by('exptime')

        if verbose:
            print("File 1")
            for t in np.unique(data['exptime']):
                print(str(t) + 's,', len(np.argwhere(data['exptime'] == t)), "images")

    else:
        data1 = Table(pkl.load(open(filename1, "rb")))
        data2 = Table(pkl.load(open(filename2, "rb")))

        data1 = remove_bad_exps(expstoremove, data1, verbose=verbose)
        data2 = remove_bad_exps(expstoremove, data2, verbose=verbose)

        data = vstack([data1, data2], join_type='exact',
                      metadata_conflicts='warn').group_by('exptime')
        if verbose:
            print("File 1")
            for t in np.unique(data1['exptime']):
                print(str(t) + 's,', len(np.argwhere(data1['exptime'] == t)), "images")

            print("\n\nFile 2")
            for t in np.unique(data2['exptime']):
                print(str(t) + 's,', len(np.argwhere(data2['exptime'] == t)), "images")

            print("\n\nCombined")
            for t in np.unique(data['exptime']):
                print(str(t) + 's,', len(np.argwhere(data['exptime'] == t)), "images")
    if verbose:
        print("\n\n", len(data))

    return data


def get_sensor_metadata(sensor, detector, repo="/repo/main"):
    """Return the sensor full well metrics along with the metadata for a single detector.

    Args:
        sensor (str): sensor name e.g. ("R22_S11")
        detector (int): detector number (e.g. 94)
        repo (str, optional): butler repository. Defaults to "/repo/main".

    Returns:
        _type_: _description_
    """
    butler = Butler(repo)
    camera = LsstCam().getCamera()

    # Get PTCs for gains
    if detector == 9:  # u/abrought/BF/2023.04.28/ptc.2023.04.28.R02-S00.trunc_to_pcti
        ptc = butler.get('ptc', detector=detector, instrument='LSSTCam',
                         collections='u/abrought/BF/2023.07.19/ptc.R02-S00.trunc_to_pcti.fullnoisematrix')
    elif detector == 83:
        ptc = butler.get('ptc', detector=detector, instrument='LSSTCam',
                         collections='u/abrought/BF/2023.07.19/ptc.R21-S02.trunc_to_pcti.fullnoisematrix')
    elif detector == 23:
        ptc = butler.get('ptc', detector=detector, instrument='LSSTCam',
                         collections='u/abrought/BF/2023.07.19/ptc.R03-S12.trunc_to_pcti.fullnoisematrix')
    else:
        ptc = butler.get('ptc', detector=detector, instrument='LSSTCam',
                         collections='u/abrought/BF/2023.07.19/ptc.R24-S11.trunc_to_pcti.fullnoisematrix')

    # Get gains, ptc turnoffs from ptc
    gains = dict()
    ptc_turnoffs = dict()
    for i, amp in enumerate(camera[0].getAmplifiers()):
        gains.update({amp.getName(): ptc.gain[amp.getName()]})

    # Get PTCs for PTC turnoffs.
    if detector == 9:  # u/abrought/BF/2023.04.28/ptc.2023.04.28.R02-S00.trunc_to_pcti
        ptc = butler.get('ptc', detector=detector, instrument='LSSTCam',
                         collections='u/abrought/BF/2023.07.19/ptc.R02-S00.fullnoisematrix')
    elif detector == 83:
        ptc = butler.get('ptc', detector=detector, instrument='LSSTCam',
                         collections='u/abrought/BF/2023.07.19/ptc.R21-S02.fullnoisematrix')
    elif detector == 23:
        ptc = butler.get('ptc', detector=detector, instrument='LSSTCam',
                         collections='u/abrought/BF/2023.07.19/ptc.R03-S12.fullnoisematrix')
    else:
        ptc = butler.get('ptc', detector=detector, instrument='LSSTCam',
                         collections='u/abrought/BF/2023.07.19/ptc.R24-S11.fullnoisematrix')

    for i, amp in enumerate(camera[0].getAmplifiers()):
        ptc_turnoffs.update({amp.getName(): ptc.ptcTurnoff[amp.getName()] * ptc.gain[amp.getName()]})

    ptc_turnoffs_list = np.array(list(ptc_turnoffs.items()))
    ptc_turnoffs_list = np.float64(ptc_turnoffs_list[:, 1])

    # Get sCTI turnoffs
    sensorparams = pkl.load(open("/home/a/abrought/run5/BF/data/cti_turnoffs_run_13339_e-.pkl", "rb"))
    scti_turnoffs = sensorparams[(sensorparams["BAY_SLOT"] == sensor)]["CTI_TURNOFF"].to_numpy()

    # Get maximum observed signal
    eotest_results_path = "/home/a/abrought/bin/13339/run-13339/raft_results_summary_BOT/v0/108433/"
    h = fits.open(eotest_results_path + sensor + "_13339_eotest_results.fits")
    mos = h[1].data["MAX_OBSERVED_SIGNAL"]
    amps = h[1].data["AMP"]
    h.close()
    moss = np.zeros(mos.shape)

    for i, amp in enumerate(camera[0].getAmplifiers()):
        ampnum = int(SLACAMPS[amp.getName()][-2:])
        moss[np.argwhere(amps == ampnum)] = mos[np.argwhere(amps == ampnum)] * gains[amp.getName()]

    # Get pcti turnoffs
    # Derived from run5/CTI.ipynb analysis
    if sensor == "R03_S12":
        pcti_turnoffs = [97201.75, 108223.88]
    elif sensor == "R24_S11":
        pcti_turnoffs = [83000.445, 97289.7]
    elif sensor == "R02_S00":
        pcti_turnoffs = [80099.695, 94984.21]
    elif sensor == "R21_S02":
        pcti_turnoffs = [73349.6, 86367.68]

    return ptc_turnoffs_list, scti_turnoffs, pcti_turnoffs, moss, gains


def interpolate_background(bkgArr):
    """Interpolate 2D

    Args:
        imArr (numpy.ndarray): 2D array matching image array of derived background.

    Returns:
        numpy.ndarray: 2D array matching image array of derived background with masked portions interpolated.
    """
    bkgArr[bkgArr == 0] = np.nan
    x = np.arange(0, bkgArr.shape[1])
    y = np.arange(0, bkgArr.shape[0])

    # mask invalid values
    np.ma.masked_invalid(bkgArr)
    xx, yy = np.meshgrid(x, y)

    # get only the valid values
    x1 = xx[~bkgArr.mask]
    y1 = yy[~bkgArr.mask]
    newArr = bkgArr[~bkgArr.mask]

    interpolated_image = interpolate.griddata((x1, y1), newArr.ravel(),
                                              (xx, yy), method='nearest')

    return interpolated_image


def get_background(self, image, exptime):
    """Determine the background from an image, with the spots masked.

    Args:
        image (np.ndarray): 2D array of the image data
        exptime (float): exposure time.

    Returns:
       numpy.ndarray: background of image.
    """

    # First pass to get rough background estimate
    sigmaclip = SigmaClip(sigma=5.)
    bkg_estimator = MedianBackground()
    bkg = Background2D(image, (65, 65), filter_size=(5, 5),
                       sigma_clip=sigmaclip,
                       bkg_estimator=bkg_estimator)

    # Second pass ignoring spots pixels
    diff = image - bkg.background

    coverage_mask = sigma_clip(diff, sigma=5, grow=2.0, maxiters=5, masked=True).mask
    del diff
    bkg = Background2D(image, (65, 65), filter_size=(5, 5),
                       sigma_clip=None,
                       bkg_estimator=bkg_estimator,
                       coverage_mask=coverage_mask)

    # Interpolate over spot regions (coverage mask area)
    new_bkg = self.interpolate_background(bkg.background)

    return new_bkg


def azimuthal_average(image, center=None, returnradii=False, return_nr=False,
                     binsize=0.5, weights=None, steps=False, interpnan=False, left=None, right=None,
                     mask=None):
    """
    Calculate the azimuthally averaged radial profile.
    image - The 2D image
    center - The [x,y] pixel coordinates used as the center. The default is
             None, which then uses the center of the image (including
             fractional pixels).
    stddev - if specified, return the azimuthal standard deviation instead of the average
    returnradii - if specified, return (radii_array,radial_profile)
    return_nr   - if specified, return number of pixels per radius *and* radius
    binsize - size of the averaging bin.  Can lead to strange results if
        non-binsize factors are used to specify the center and the binsize is
        too large
    weights - can do a weighted average instead of a simple average if this keyword parameter
        is set.  weights.shape must = image.shape.  weighted stddev is undefined, so don't
        set weights and stddev.
    steps - if specified, will return a double-length bin array and radial
        profile so you can plot a step-form radial profile (which more accurately
        represents what's going on)
    interpnan - Interpolate over NAN values, i.e. bins where there is no data?
        left,right - passed to interpnan; they set the extrapolated values
    mask - can supply a mask (boolean array same size as image with True for OK and False for not)
        to average over only select data.
    If a bin contains NO DATA, it will have a NAN value because of the
    divide-by-sum-of-weights component.  I think this is a useful way to denote
    lack of data, but users let me know if an alternative is prefered...

    """
    # Calculate the indices from the image
    y, x = np.indices(image.shape)

    if center is None:
        center = np.array([(x.max() - x.min()) / 2.0, (y.max() - y.min()) / 2.0])

    r = np.hypot(x - center[0], y - center[1])

    if weights is None:
        weights = np.ones(image.shape)
    elif stddev:
        raise ValueError("Weighted standard deviation is not defined.")

    if mask is None:
        mask = np.ones(image.shape, dtype='bool')

    # The 'bins' as initially defined are lower/upper bounds for each bin
    # so that values will be in [lower,upper)
    nbins = int(np.round(r.max() / binsize) + 1)
    maxbin = nbins * binsize
    bins = np.linspace(0, maxbin, nbins + 1)
    # But we're probably more interested in the bin centers than their left or right sides...
    bin_centers = (bins[1:] + bins[:-1]) / 2.0

    # How many per bin (i.e., histogram)?
    # There are never any in bin 0, because the lowest index returned by digitize is 1
    # nr = np.bincount(whichbin)[1:]
    nr = np.histogram(r, bins, weights=mask.astype('int'))[0]

    # Recall that bins are from 1 to nbins (which is expressed in array terms by 
    # arange(nbins)+1 or range(1,nbins+1) )
    # radial_prof.shape = bin_centers.shape
    # Find out which radial bin each point in the map belongs to
    whichbin = np.digitize(r.flat, bins)
    # This method is still very slow; is there a trick to do this with histograms?
    stddev = np.array([image.flat[mask.flat * (whichbin == b)].std() for b in range(1, nbins + 1)])
    radial_prof = np.histogram(r, bins, weights=(image * weights * mask)
                               )[0] / np.histogram(r, bins, weights=(mask * weights))[0]

    if interpnan:
        radial_prof = np.interp(bin_centers, bin_centers[radial_prof == radial_prof],
                                radial_prof[radial_prof == radial_prof], left=left, right=right)
        stddev = np.interp(bin_centers, bin_centers[stddev == stddev],
                           stddev[stddev == stddev], left=left, right=right)

    return nr, bin_centers, radial_prof, stddev


def calc_2nd_mom(results):
    # Calculate quadratic moment elements from HSM result
    e1 = results.observed_shape.e1
    e2 = results.observed_shape.e2
    sigma = results.moments_sigma
    sigma_ave = sigma / (1 - e1**2 - e2**2)**(0.25)
    Ixx = (1 + e1) * sigma_ave**2
    Iyy = (1 - e1) * sigma_ave**2
    Ixy = e2 * (sigma_ave**2)

    return Ixx, Iyy, Ixy


def plot_time_series(data, y1key='Ixx', y2key='Iyy', xlim=(0, 0), ylim=(0, 0), sensor="", runs="", fontsize=12):
    """ Plot time series of all data.
    """
    xx = np.zeros(len(data))
    np.zeros(len(data))
    mjd = np.zeros(len(data))
    np.zeros(len(data))
    botx = np.zeros(len(data))
    boty = np.zeros(len(data))
    np.zeros(len(data))
    excluded = np.zeros(len(data), dtype='bool')

    for i, t in enumerate(data):
        if len(np.argwhere(t['spot_indices'] == 1541).ravel()) == 0:
            xx[i] = np.nan
        else:
            xx[i] = t[y1key][np.argwhere(t['spot_indices'] == 1541)]

        excluded[i] = t['exptime'] < 15.

        mjd[i] = t['MJD']
        botx[i] = t['BOTX']
        boty[i] = t['BOTY']

    empty = np.isnan(xx)
    empty & excluded

    plt.figure(figsize=(12, 4), facecolor='white')
    if not runs == "":
        plt.title(sensor[0:3] + "-" + sensor[4:] + " (Runs " + runs + ")", fontsize=fontsize)
    else:
        plt.title(sensor[0:3] + "-" + sensor[4:], fontsize=fontsize)

    plt.scatter(mjd[~empty], xx[~empty], c=np.array(botx)[~empty] / np.array(boty)[~empty], s=5)
    #sca = plt.scatter(mjd, yy, c=np.array(botx)/np.array(boty), s=5)
    plt.scatter(mjd[excluded], xx[excluded], marker="x", c='red', s=10)
    # + '$\;&\;$' + y2key
    plt.ylabel(y1key, rotation=90, fontsize=fontsize, loc='center')
    plt.xlabel("MJD", fontsize=fontsize)

    if xlim[0] != 0 and xlim[1] != 0:
        plt.xlim(xlim[0], xlim[1])
    if ylim[0] != 0 and ylim[1] != 0:
        plt.ylim(ylim[0], ylim[1])


def plot_subplot(ax, data, t0, xkey, ykey, fitrange, fontsize, xlabel, ylabel, xlim, ylim, sensor, detector):
    """ Plot a subplot on a single axis.
    """

    matplotlib.rcParams.update({'font.size': fontsize})

    # Find shape zeropoint

    # Find unique spot across all exposures that
    # correspond to a single hole in the spot projector
    ref_data = data[data['exptime'] == t0]
    ref_spots = []
    for exp in ref_data:
        ref_spots.extend(['%04d' % n for n in exp['spot_indices']])
    ref_spots = np.unique(ref_spots)

    # Get the shape of each spot in each exposure,
    # and organize it in a dictionary keyed by spot
    # number.
    ref_spots_dict = dict()
    ref_spots_dict_err = dict()
    for spot in ref_spots:
        ref_spots_dict[spot] = []
        for exp in ref_data:
            if spot in ['%04d' % n for n in exp['spot_indices']]:
                this_spot = np.asarray(['%04d' % n for n in exp['spot_indices']]) == spot
                ref_spots_dict[spot].append(exp[ykey][this_spot][0])

    # Get the mean spot shape and error on
    # expected spot shape.
    for spot in ref_spots_dict.keys():
        mean = np.mean(ref_spots_dict[spot])
        std = np.std(ref_spots_dict[spot])
        ref_spots_dict_err[spot] = std / np.sqrt(len(ref_spots_dict[spot]))
        ref_spots_dict[spot] = mean

    # Get data for all spots
    ys = []
    xs = []
    es = []
    for exp in data:
        spots_in_this_exp = np.asarray(['%04d' % n for n in exp['spot_indices']])
        these_spots = np.intersect1d(ref_spots, spots_in_this_exp)

        for spot in these_spots:
            this_spot = (spots_in_this_exp == spot)
            if exp['channels'][this_spot] == 'C07':
                continue

            xs.append(exp[xkey][this_spot])
            ys.append(exp[ykey][this_spot] - ref_spots_dict[spot])
            es.append(exp['exptime'])

    xs = np.asarray(xs)
    ys = np.asarray(ys)
    es = np.asarray(es)

    # Plotting

    exptimes = np.unique(data['exptime'])
    normalize = matplotlib.colors.Normalize(vmin=np.min(exptimes), vmax=np.max(exptimes))

    fitx = []
    fity = []
    for i, e in enumerate(exptimes):
        select = (es == e)
        good = get_outlier_mask(xs[select], m=3)[:, 0] * get_outlier_mask(ys[select], m=3)[:, 0]

        len(es[select][good])

        xerr = np.std(xs[select][good])
        yerr = np.std(ys[select][good])

        if e >= fitrange[0] and e <= fitrange[1]:
            fitx.append(np.mean(xs[select][good]))
            fity.append(np.mean(ys[select][good]))

        ax.scatter(
            xs[select][good],
            ys[select][good],
            c="#4c8bf5",
            cmap='turbo',
            norm=normalize,
            s=.5,
            alpha=0.1)
        ax.errorbar(np.mean(xs[select][good]), np.mean(ys[select][good]),
                    xerr=xerr, yerr=yerr,
                    fmt="o", mfc="k", color="k", mec="k", ecolor="k", alpha=1,
                    ms=5., mew=0., capsize=3.5, capthick=0.5, elinewidth=0.5)

    # Fit only the linear section to a 1D polynomial
    fitx = np.asarray(fitx)
    fity = np.asarray(fity)
    if np.any(np.isnan(fitx)) or np.any(np.isnan(fity)):
        if np.all(np.isnan(fitx)) or np.all(np.isnan(fity)):
            print("CANNOT FIT DATA")
            return
        else:
            these = np.logical_not(np.logical_or(np.isnan(fitx), np.isnan(fity)))
            these = np.array(these)
            fitx = fitx[these]
            fity = fity[these]

    (slope, b), V = np.polyfit(fitx, fity, 1, cov=True)
    slope_err = np.sqrt(V[0][0])

    print("$", format_number(slope), "$ & $", format_number(slope_err), "$")

    label = "{}".format(str(nsigfig(slope))) + r" $\mathrm{px}^2 / \mathrm{el}$"
    if ykey == 'Ixx' or ykey == 'Iyy':
        label = "{}".format(str(nsigfig(slope * 1e6))) + r"$\times 10^{-6} \mathrm{px}^2 / \mathrm{el}$"
    elif ykey == 'Ixy':
        label = "{}".format(str(nsigfig(slope * 1e8))) + r"$\times 10^{-8} \mathrm{px}^2 / \mathrm{el}$"

    ax.plot(
        np.linspace(
            np.min(fitx),
            np.max(fitx),
            1000),
        slope *
        np.linspace(
            np.min(fitx),
            np.max(fitx),
            1000) +
        b,
        color="black",
        linewidth=1,
        linestyle="--",
        label=label)

    ax.ticklabel_format(axis="x", style="sci", scilimits=(0, 0), useMathText=True)
    ax.set_xlim(xlim)
    ax.set_ylim(ylim)
    ax.set_xlabel(xlabel)
    ax.set_ylabel(ylabel)
    ax.legend(loc=2, frameon=False)

    return slope, slope_err


def plot(
        data,
        data2,
        t0,
        xkey,
        ykey,
        fitrange,
        figsize,
        fontsize,
        xlabel,
        ylabel,
        ylabel2,
        xlim,
        ylim,
        sensor,
        detector,
        saveto):

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=figsize, facecolor="white")

    ax1.axhline(0.0, linestyle="--", color="k", linewidth=1, alpha=0.25)
    ax2.axhline(0.0, linestyle="--", color="k", linewidth=1, alpha=0.25)

    ptc_turnoffs, scti_turnoffs, pcti_turnoffs, moss, gains = get_sensor_metadata(
        sensor=sensor, detector=detector)
    ax1.axvspan(
        np.min(pcti_turnoffs),
        np.max(pcti_turnoffs),
        alpha=0.25,
        hatch='XX',
        color='gray',
        edgecolor="None",
        label="pCTI TURNOFF")
    ax1.axvspan(
        np.min(ptc_turnoffs),
        np.max(ptc_turnoffs),
        alpha=0.25,
        hatch='O',
        color='gray',
        edgecolor="None",
        label="PTC TURNOFF")
    ax1.axvspan(
        np.min(scti_turnoffs),
        np.max(scti_turnoffs),
        alpha=0.25,
        hatch='.',
        color='gray',
        edgecolor="None",
        label="sCTI TURNOFF")
    ax1.axvspan(
        np.min(moss),
        np.max(moss),
        alpha=0.25,
        color='gray',
        hatch='*',
        edgecolor="None",
        label="MAX OBSERVED SIGNAL")
    ax2.axvspan(
        np.min(pcti_turnoffs),
        np.max(pcti_turnoffs),
        alpha=0.25,
        hatch='XX',
        edgecolor="None",
        color='gray')
    ax2.axvspan(
        np.min(ptc_turnoffs),
        np.max(ptc_turnoffs),
        alpha=0.25,
        hatch='O',
        edgecolor="None",
        color='gray')
    ax2.axvspan(
        np.min(scti_turnoffs),
        np.max(scti_turnoffs),
        alpha=0.25,
        hatch='.',
        edgecolor="None",
        color='gray')
    ax2.axvspan(np.min(moss), np.max(moss), alpha=0.25, hatch='*', edgecolor="None", color='gray')

    if ykey == "Iyy":
        ax1.fill_between([0, 2.0e5], y1=[-0.01045, -0.01045], y2=[0.01045, 0.01045], color='#4c8bf5',
                         edgecolor="None", alpha=0.25, label=r'$|\delta I_{yy}|\;/\;\bar{I}_{yy, 15s} < 10^{-3}$')
        ax2.fill_between([0, 2.0e5], y1=[-0.01045, -0.01045], y2=[0.01045, 0.01045],
                         color='#4c8bf5', edgecolor="None", alpha=0.25)
    elif ykey == "Ixx":
        ax1.fill_between([0, 2.0e5], y1=[-0.00945, -0.00945], y2=[0.00945, 0.00945], color='#4c8bf5',
                         edgecolor="None", alpha=0.25, label=r'|$\delta I_{xx}|\;/\;\bar{I}_{xx, 15s} < 10^{-3}$')
        ax2.fill_between([0, 2.0e5], y1=[-0.00945, -0.00945], y2=[0.00945, 0.00945],
                         color='#4c8bf5', edgecolor="None", alpha=0.25)
    elif ykey == "Ixy":
        ax1.fill_between([0, 2.0e5], y1=[-0.00056, -0.00056], y2=[0.00056, 0.00056], color='#4c8bf5',
                         edgecolor="None", alpha=0.25, label=r'$|\delta I_{xy}|\;/\;\bar{I}_{xy, 15s} < 10^{-3}$')
        ax2.fill_between([0, 2.0e5], y1=[-0.00056, -0.00056], y2=[0.00056, 0.00056],
                         color='#4c8bf5', edgecolor="None", alpha=0.25)

    uncorrected_slope, uncorrected_slope_err = plot_subplot(
        ax1, data, t0, xkey, ykey, fitrange, fontsize, xlabel, ylabel, xlim, ylim, sensor, detector)
    corrected_slope, corrected_slope_err = plot_subplot(
        ax2, data, t0, xkey, ykey, fitrange, fontsize, xlabel, ylabel2, xlim, ylim, sensor, detector)

    correction = (1. - (corrected_slope / uncorrected_slope)) * 100
    print(ykey, correction)

    if ykey == 'Ixy':
        ax1.set_yticks([-0.1, 0, 0.1, 0.2])
        ax2.set_yticks([-0.1, 0, 0.1, 0.2])

    plt.savefig(saveto, bbox_inches="tight")

    return correction


class SpotAnalyzer:
    """
       A class with methods for reading and anlyzing spot data from
       catalogs generated by MixCOATL.
    """

    def __init__(self, repo, collection, singleImgPerExp=False, maxExpTime=-1,
                 fluxCutThreshold=0.0, onlyConvergedGridFits=False,
                 ellipticityRangeCut=(0.0, 1.0), centerCutRadius=-1,
                 subtractSkyBkg=False, calcHOMs=False):
        # Details
        self.raftbay = 'unkown'
        self.ccdslot = 'unkown'
        self.runnum = 'unknown'

        # Create butler object
        self.repo = repo
        self.collection = collection
        self.butler = Butler(self.repo)
        self.registry = self.butler.registry

        # Configuration
        self.singleImgPerExp = singleImgPerExp
        self.maxExpTime = maxExpTime
        self.fluxCutThreshold = fluxCutThreshold
        self.onlyConvergedGridFits = onlyConvergedGridFits
        self.ellipticityRangeCut = ellipticityRangeCut
        self.centerCutRadius = centerCutRadius
        self.subtractSkyBkg = subtractSkyBkg
        self.calcHOMs = calcHOMs

        # Initialize data table
        self.data = Table()

    def getData(self):
        """ Pulls out data from run and returns BF table."""

        # Get the BF-corrected butler
        subbutler = Butler(self.repo, collections=self.collection)
        subregistry = subbutler.registry

        datasetRefs = list(subregistry.queryDatasets(datasetType="gridSpotSrc", collections=self.collection))

        # Make sure there are image tables to analyze
        assert len(datasetRefs) > 0

        exptimes = [0]
        tab = []
        for i, aref in enumerate(datasetRefs):

            # Get raw image
            raw = subbutler.get("raw", dataId=aref.dataId)
            md = raw.getMetadata()
            sensor = md["RAFTBAY"] + "_" + md["CCDSLOT"]
            seqnum = md["SEQNUM"]
            tseqnum = md["TSEQNUM"]
            exptime = md["EXPTIME"]
            time = md["MJD"]
            botx = md["BOTX"]
            boty = md["BOTY"]

            self.raftbay = md["RAFTBAY"]
            self.ccdslot = md["CCDSLOT"]
            self.runnum = md["RUNNUM"]

            # Get camera/sensor information
            camera = LsstCam().getCamera()
            detector = camera.get(sensor)

            # Get PTC calibration for each sensor.
            if detector.getId() == 9:
                ptcs = self.butler.get(
                    'ptc',
                    detector=detector.getId(),
                    instrument='LSSTCam',
                    collections='u/abrought/BF/2023.04.28/ptc.2023.04.28.R02-S00.trunc_to_pcti')
            elif detector.getId() == 83:
                ptcs = self.butler.get(
                    'ptc',
                    detector=detector.getId(),
                    instrument='LSSTCam',
                    collections='u/abrought/BF/2023.04.28/ptc.2023.04.28.R21-S02.trunc_to_pcti')
            elif detector.getId() == 23:
                ptcs = self.butler.get(
                    'ptc',
                    detector=detector.getId(),
                    instrument='LSSTCam',
                    collections='u/abrought/BF/2023.04.28/ptc.2023.04.28.R03-S12.trunc_to_pcti')
            else:
                ptcs = self.butler.get(
                    'ptc',
                    detector=detector.getId(),
                    instrument='LSSTCam',
                    collections='u/abrought/BF/2023.04.28/ptc.2023.04.28.R24-S11.trunc_to_pcti')

            # Get gains
            gains = dict()
            for i, amp in enumerate(camera[0].getAmplifiers()):
                gains.update({amp.getName(): ptcs.gain[amp.getName()]})

            # Use only a single image at each exposure
            if self.singleImgPerExp:
                if np.any(np.isin(exptimes, [exptime])):
                    continue
                else:
                    exptimes.append(exptime)

            # Use only exposures less than maxExpTime
            if self.maxExpTime > 0.:
                if exptime > self.maxExpTime:
                    continue

            # Get source catalog
            src = subbutler.get("gridSpotSrc", dataId=aref.dataId)
            mdsrc = src.getMetadata()
            x0 = mdsrc['GRID_X0']
            y0 = mdsrc['GRID_Y0']

            # Flux cuts
            np.nanmax(src['base_SdssShape_instFlux'])
            thresh = np.percentile(src['base_SdssShape_instFlux'], self.fluxCutThreshold * 100)
            #select = src['base_SdssShape_instFlux'] >= self.fluxCutThreshold*maxFlux
            select = src['base_SdssShape_instFlux'] >= thresh
            src = src.subset(select)
            print("NUMPOINTS LEFT: ", len(src), "\n")

            # Initialize mask with NaN cuts
            mask = (src['spotgrid_index'] >= 0)

            # Get only points with a converged grid fit:
            if self.onlyConvergedGridFits:
                ymask = (np.abs(src['base_SdssCentroid_y'] - src['spotgrid_y']) < 2)
                xmask = (np.abs(src['base_SdssCentroid_x'] - src['spotgrid_x']) < 2)
                mask = mask & xmask & ymask

            # Get only the circular spots (removes elliptical spots as well as spots w/ trail bleeding)
            g1 = src['base_SdssShape_xx'] - src['base_SdssShape_yy']
            g2 = 2 * src['base_SdssShape_xy']
            ellipticities = np.sqrt(g1**2 + g2**2)
            mask = mask & (ellipticities > self.ellipticityRangeCut[0]) & \
                (ellipticities < self.ellipticityRangeCut[1])

            # Radial cuts from grid center
            if self.centerCutRadius > 0:
                maxradius = self.centerCutRadius * np.mean([mdsrc["GRID_XSTEP"], mdsrc["GRID_YSTEP"]])
                distances = np.sqrt((src["spotgrid_x"] - x0)**2 + (src["spotgrid_y"] - y0)**2)
                mask = mask & (distances <= maxradius)

            # Apply mask
            src = src[mask]

            # Check if any spots are left after cuts
            if not len(src) > 0:
                print("No spots left in exposure ", seqnum)
                continue

            # Get the peak spot values, channel, and amplifier names
            postisr = subbutler.get("postISRCCD", dataId=aref.dataId)
            image = postisr.getImage().getArray()

            # Calculate HSM mom with illumination background subtracted
            if self.subtractSkyBkg:
                bkg = get_background(image, exptime)
                maxbkg = np.max(bkg)
                #maxbkg = 1.57 * exptime
                #image -= maxbkg
            else:
                maxbkg = 0.

            peakSignal = np.zeros(len(src))
            Ixx = np.zeros(len(src))
            Iyy = np.zeros(len(src))
            Ixy = np.zeros(len(src))

            s = int(65 / 2.)  # Originally 20

            HOMs = np.full((len(src), 25,), np.nan)
            amps = []
            channels = []

            radial_profiles = np.full((len(src["spotgrid_index"]), 64), np.nan)
            radial_bin_centers = np.full((len(src["spotgrid_index"]), 64), np.nan)
            nrs = np.full((len(src["spotgrid_index"]), 64), np.nan)
            stddevs = np.full((len(src["spotgrid_index"]), 64), np.nan)
            serial_slice = np.full((len(src["spotgrid_index"]), (2 * s) + 1), np.nan)
            parallel_slice = np.full((len(src["spotgrid_index"]), (2 * s) + 1), np.nan)
            corresponding_gains = np.full(len(src["spotgrid_index"]), np.nan)
            stamp_sums = np.full(len(src["spotgrid_index"]), np.nan)
            for i, pt in enumerate(src["spotgrid_index"]):
                x = int(src['base_SdssCentroid_y'][i])  # The coordinate systems are flipped
                y = int(src['base_SdssCentroid_x'][i])

                xmin = max(0, x - s)
                xmax = min(image.shape[0] - 1, x + s + 1)
                ymin = max(0, y - s)
                ymax = min(image.shape[1] - 1, y + s + 1)
                stamp_center = [src['base_SdssCentroid_x'][i] - ymin, src['base_SdssCentroid_y'][i] - xmin]

                # Get the corresponding channel/amp
                amp = findAmp(detector, Point2I(y, x))
                channels.append(amp.getName())
                amps.append(SLACAMPS[amp.getName()])

                peakSignal[i] = np.max(image[xmin:xmax, ymin:ymax]) * gains[amp.getName()]
                PSFImage = galsim.Image(image[xmin:xmax, ymin:ymax])  # * gains[amp.getName()]
                corresponding_gains[i] = gains[amp.getName()]
                stamp_sums[i] = np.sum(PSFImage.array)

                # Calculate moments
                result = PSFImage.FindAdaptiveMom(strict=False)
                if result.error_message != "":
                    Ixx[i] = -np.nan
                    Iyy[i] = -np.nan
                    Ixy[i] = -np.nan
                else:
                    Ixx_, Iyy_, Ixy_ = calc_2nd_mom(result)
                    Ixx[i] = Ixx_
                    Iyy[i] = Iyy_
                    Ixy[i] = Ixy_

                # Calculate higher order image moments
                if self.calcHOMs:
                    psf_base = galsim.Gaussian(sigma=1.0)
                    sxm = shapeletXmoment(psf_base, 6)
                    pqlist = sxm.get_pq_full(6)
                    moments = sxm.get_all_moments(PSFImage, pqlist)
                    HOMs[i] = moments

                # Calculate radial profile
                nr, bin_centers, radial_prof, stddev = azimuthalAverage(PSFImage.array * gains[amp.getName()],
                                                                        center=stamp_center, returnradii=True,
                                                                        binsize=0.5, interpnan=True, steps=False)
                bin_mask = (bin_centers <= s)
                #print("Length of profile:", len(nr[bin_mask]))
                nrs[i] = nr[bin_mask]
                stddevs[i] = stddev[bin_mask]
                radial_bin_centers[i] = bin_centers[bin_mask]
                radial_profiles[i] = radial_prof[bin_mask]

                try:
                    serial_slice[i] = PSFImage.array[s, :]
                    parallel_slice[i] = PSFImage.array[:, s]
                except BaseException:
                    continue

            # print(serial_slice[0])
            # Calculate major and minor axes and theta of each spot
            Mxx = src['base_SdssShape_xx']
            Myy = src['base_SdssShape_yy']
            Mxy = src['base_SdssShape_xy']
            Muu_p_Mvv = Mxx + Myy
            Muu_m_Mvv = np.sqrt((Mxx - Myy)**2 + 4 * Mxy**2)
            Muu = 0.5 * (Muu_p_Mvv + Muu_m_Mvv)
            Mvv = 0.5 * (Muu_p_Mvv - Muu_m_Mvv)
            theta = 0.5 * np.arctan2(2 * Mxy, Mxx - Myy) * (180. / np.pi)
            a = np.sqrt(Muu)
            b = np.sqrt(Mvv)

            # Sort spots by spot index so that all variables align
            indxs = np.argsort(src['id'])

            # Create table
            tab.append(
                {
                    "index": i,
                    "exptime": exptime,
                    "SEQNUM": seqnum,
                    "TSEQNUM": tseqnum,
                    "MJD": time,
                    "BOTX": botx,
                    "BOTY": boty,
                    "GRIDX": x0,
                    "GRIDY": y0,
                    "numspots": len(src),
                    "spot_indices": src['spotgrid_index'][indxs],
                    "amps": np.asarray(amps)[indxs],
                    "corresponding_gains": corresponding_gains[indxs],
                    "channels": np.asarray(channels)[indxs],
                    "spotgrid_x": src['spotgrid_x'][indxs],
                    "spotgrid_y": src['spotgrid_y'][indxs],
                    "stamp_sums": stamp_sums,
                    "peakSignal": peakSignal[indxs],
                    "max_bkg": maxbkg,
                    "radial_bin_centers": radial_bin_centers[indxs],
                    "radial_profiles": radial_profiles[indxs],
                    "nrs": nrs[indxs],
                    "radial_profile_stddevs": stddevs[indxs],
                    "serial_slice": serial_slice[indxs],
                    "parallel_slice": parallel_slice[indxs],
                    "a": a,
                    "b": b,
                    "theta": theta,
                    "base_SdssCentroid_x": src['base_SdssCentroid_x'][indxs],
                    "base_SdssCentroid_y": src['base_SdssCentroid_y'][indxs],
                    "base_SdssShape_x": src['base_SdssShape_x'][indxs],
                    "base_SdssShape_y": src['base_SdssShape_y'][indxs],
                    "base_SdssShape_xx": src['base_SdssShape_xx'][indxs],
                    "base_SdssShape_yy": src['base_SdssShape_yy'][indxs],
                    "base_SdssShape_xy": src['base_SdssShape_xy'][indxs],
                    "base_SdssShape_xxErr": src['base_SdssShape_xxErr'][indxs],
                    "base_SdssShape_yyErr": src['base_SdssShape_yyErr'][indxs],
                    "base_SdssShape_xyErr": src['base_SdssShape_xyErr'][indxs],
                    "base_PsfFlux_instFlux": src["base_PsfFlux_instFlux"][indxs],
                    "base_CircularApertureFlux_35_0_instFlux": src["base_CircularApertureFlux_35_0_instFlux"][indxs],
                    "base_CircularApertureFlux_25_0_instFlux": src["base_CircularApertureFlux_25_0_instFlux"][indxs],
                    "base_CircularApertureFlux_25_0_instFluxErr": src["base_CircularApertureFlux_25_0_instFluxErr"][indxs],
                    "base_CircularApertureFlux_70_0_instFlux": src["base_CircularApertureFlux_70_0_instFlux"][indxs],
                    "base_CircularApertureFlux_70_0_instFluxErr": src["base_CircularApertureFlux_70_0_instFluxErr"][indxs],
                    "ext_shapeHSM_HsmShapeBj_e1": src["ext_shapeHSM_HsmShapeBj_e1"][indxs],
                    "ext_shapeHSM_HsmShapeBj_e2": src["ext_shapeHSM_HsmShapeBj_e2"][indxs],
                    "ext_shapeHSM_HsmShapeBj_sigma": src["ext_shapeHSM_HsmShapeBj_sigma"][indxs],
                    "ext_shapeHSM_HsmPsfMoments_xx": src["ext_shapeHSM_HsmPsfMoments_xx"][indxs],
                    "ext_shapeHSM_HsmPsfMoments_yy": src["ext_shapeHSM_HsmPsfMoments_yy"][indxs],
                    "ext_shapeHSM_HsmPsfMoments_xy": src["ext_shapeHSM_HsmPsfMoments_xy"][indxs],
                    "ext_shapeHSM_HsmShapeLinear_e1": src["ext_shapeHSM_HsmShapeLinear_e1"][indxs],
                    "ext_shapeHSM_HsmShapeLinear_e2": src["ext_shapeHSM_HsmShapeLinear_e2"][indxs],
                    "ext_shapeHSM_HsmShapeLinear_sigma": src["ext_shapeHSM_HsmShapeLinear_sigma"][indxs],
                    "ext_shapeHSM_HsmShapeRegauss_e1": src["ext_shapeHSM_HsmShapeRegauss_e1"][indxs],
                    "ext_shapeHSM_HsmShapeRegauss_e2": src["ext_shapeHSM_HsmShapeRegauss_e2"][indxs],
                    "ext_shapeHSM_HsmShapeRegauss_sigma": src["ext_shapeHSM_HsmShapeRegauss_sigma"][indxs],
                    "ext_shapeHSM_HsmSourceMoments_xx": src["ext_shapeHSM_HsmSourceMoments_xx"][indxs],
                    "ext_shapeHSM_HsmSourceMoments_yy": src["ext_shapeHSM_HsmSourceMoments_yy"][indxs],
                    "ext_shapeHSM_HsmSourceMoments_xy": src["ext_shapeHSM_HsmSourceMoments_xy"][indxs],
                    "Ixx": Ixx[indxs],
                    "Iyy": Iyy[indxs],
                    "Ixy": Ixy[indxs],
                    "e1": Ixx[indxs] - Iyy[indxs],
                    "e2": np.sqrt((Ixx[indxs] - Iyy[indxs])**2 + 4 * Ixy[indxs])
                    "HOMs": HOMs[indxs]
                }
            )

        # Sort the table by exposure time
        t = Table(tab)
        t_sorted = t[np.argsort(t['exptime'])]
        self.data = t_sorted

        return t_sorted

    def save_data(self, outdir="/home/a/abrought/run5/BF/data/", suffix="", filename=""):
        # Pickle the data

        import datetime
        now = datetime.datetime.now().isoformat(timespec='seconds')

        if not len(filename) == 0:
            filename = outdir + filename
        else:
            filename = outdir + "_".join(("data", self.runnum, self.raftbay,
                                          self.ccdslot, now))
            filename += suffix

        filename += ".pkl"

        if(os.path.isfile(filename)):
            print("Removing existing data pickle...")
            os.remove(filename)

        with open(filename, 'wb') as f:
            print("Jarring a new data pickle...", filename)
            names = self.data.colnames
            pkl.dump([dict(zip(names, row)) for row in self.data], f)
            print("Done.")

        return filename


#     def get_background(self, image, exptime):
#         # Remove background from a spot image

#         #from astropy.stats import SigmaClip
#         #from photutils.background import MedianBackground

#         # First pass to get Background estimate
#         sigma_clip = SigmaClip(sigma=5.)
#         bkg_estimator = MedianBackground()
#         bkg = Background2D(image, (65, 65), filter_size=(5, 5),
#                            sigma_clip=sigma_clip,
#                            bkg_estimator=bkg_estimator)
#         return bkg.background

#         # Second pass ignoring spots pixels
#         #diff = image - bkg.background
#         #coverage_mask = (diff > 250.+2.*exptime)
#         #del diff
#         #bkg = Background2D(image, (65, 65), filter_size=(3, 3),
#         #                   sigma_clip=None,
#         #                   bkg_estimator=bkg_estimator,
#         #                   coverage_mask=coverage_mask)

#         # Interpolate over spot regions (coverage mask area)
#         #new_bkg = self.interpolate_background(bkg.background)

#         #return new_bkg

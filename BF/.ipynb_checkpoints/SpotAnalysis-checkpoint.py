import os
import numpy as np
import glob
from astropy.io import fits
import pandas as pd
import pickle as pkl
import matplotlib.pyplot as plt
from lsst.daf.butler import Butler
import lsst.afw.display as afwDisplay
import lsst.afw.image as afwImage
from lsst.obs.lsst import LsstCam
from lsst.afw.cameraGeom.utils import findAmp
from lsst.geom import Point2I
from astropy.table import Table, vstack, join
from scipy import stats
from scipy.optimize import curve_fit
import logging
logging.basicConfig()
logger = logging.getLogger()
logger.setLevel(logging.CRITICAL)

slacAmps = {'C10':'AMP01','C11':'AMP02','C12':'AMP03','C13':'AMP04',\
                'C14':'AMP05','C15':'AMP06','C16':'AMP07','C17':'AMP08',\
                'C07':'AMP09','C06':'AMP10','C05':'AMP11','C04':'AMP12',\
                'C03':'AMP13','C02':'AMP14','C01':'AMP15','C00':'AMP16'}
channelToAmp = { 'C10' : 1, 'C11' : 2, 'C12' : 3, 'C13' : 4, 'C14' : 5, 'C15' : 6, 'C16' : 7, 'C17' : 8,
                 'C07' : 9, 'C06' : 10, 'C05' : 11, 'C04' : 12, 'C03' : 13, 'C02' : 14, 'C01' : 15, 'C00' : 16 }


                   

class Analyzer:
    """
       A class with methods for reading and anlyzing spot data from catalogs generated by MixCOATL.
       Created by Alex Broughton 3/7/2022
       
    """
    

    def __init__(self, repo, collection, singleImgPerExp = False, maxExpTime = -1, fluxCutThreshold = 0.0,
                 onlyConvergedGridFits = False, ellipticityRangeCut = (0.0,1.0), centerCutRadius = -1):   
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
        
        # Initialize data table
        self.data = Table()

        
    def getData(self):
        """ Pulls out data from run and returns BF table."""

        # Get the BF-corrected butler
        subbutler = Butler(self.repo, collections=self.collection)
        subregistry = subbutler.registry

        datasetRefs = list(subregistry.queryDatasets(datasetType="gridSpotSrc", collections=self.collection))

        stamp = []
        exptimes = [0]
        tab = []
        for i, aref in enumerate(datasetRefs):

            # Get raw image
            raw = subbutler.get("raw",dataId=aref.dataId)
            md = raw.getMetadata()
            sensor = md["RAFTBAY"] + "_" + md["CCDSLOT"]
            seqnum = md["SEQNUM"]
            tseqnum = md["TSEQNUM"]
            exptime = md["EXPTIME"]
            time = md["MJD"]
            botx,boty = md["BOTX"], md["BOTY"]
            
            self.raftbay = md["RAFTBAY"]
            self.ccdslot = md["CCDSLOT"]
            self.runnum = md["RUNNUM"]
            
            # Get camera/sensor information
            camera = LsstCam().getCamera()
            detector = camera.get(sensor)

            # Use only a single image at each exposure
            if self.singleImgPerExp :
                if np.any(np.isin(exptimes, [exptime])):
                    continue
                else:
                    exptimes.append(exptime)

            # Use only exposures less than maxExpTime
            if self.maxExpTime > 0.:
                if exptime > self.maxExpTime: 
                    continue


            src = subbutler.get("gridSpotSrc",dataId=aref.dataId)
            mdsrc = src.getMetadata()
            x0 = mdsrc['GRID_X0']
            y0 = mdsrc['GRID_Y0']

            # Flux cuts
            maxFlux = np.nanmax(src['base_SdssShape_instFlux'])
            select = src['base_SdssShape_instFlux'] >= self.fluxCutThreshold*maxFlux
            src  = src.subset(select)

            # Initialize mask with NaN cuts
            mask = (src['spotgrid_index'] >= 0)
            
            # Get only points with a converged grid fit:
            if self.onlyConvergedGridFits:
                ymask = (np.abs(src['base_SdssCentroid_y'] - src['spotgrid_y'])<2)
                xmask = (np.abs(src['base_SdssCentroid_x'] - src['spotgrid_x'])<2)
                mask = mask & xmask & ymask

            # Get only the circular spots (removes elliptical spots as well as spots w/ trail bleeding)
            #g1 = src['base_SdssShape_xx']-src['base_SdssShape_yy']
            #g2 = 2*src['base_SdssShape_xy']
            #ellipticities = np.sqrt(g1**2 + g2**2)
            #mask = mask & (ellipticities > self.ellipticityRangeCut[0]) &  (ellipticities < self.ellipticityRangeCut[1])

            # Center cuts
            if self.centerCutRadius > 0:
                maxradius = self.centerCutRadius * np.mean([mdsrc["GRID_XSTEP"], mdsrc["GRID_YSTEP"]])
                distances = np.sqrt((src["spotgrid_x"] - x0)**2 + (src["spotgrid_y"] - y0)**2)
                mask = mask & (distances <= maxradius)


            # Apply mask
            src = src[mask]
            
            # Check if any spots are left after cuts
            if not len(src) > 0:
                continue


            # Get the peak spot values, channel, and amplifier names
            postisr = subbutler.get("postISRCCD",dataId=aref.dataId)
            image = postisr.getImage().getArray()

            peakSignal = np.zeros(len(src))
            amps = []
            channels = []
            s = 15
            for i,pt in enumerate(src["spotgrid_index"]):
                x = int(src['base_SdssCentroid_y'][i]) # The coordinate systems are flipped
                y = int(src['base_SdssCentroid_x'][i])

                xmin = max(0,x-s)
                xmax = min(image.shape[0]-1, x+s)
                ymin = max(0,y-s)
                ymax = min(image.shape[1]-1, y+s)
                peakSignal[i] = np.max(image[xmin:xmax,ymin:ymax])
                
                # Get the corresponding channel/amp
                amp = findAmp(detector, Point2I(y,x))
                channels.append(amp.getName())
                
                amps.append(slacAmps[amp.getName()])

            # Calculate major and minor axes and theta of each spot       
            Mxx = src['base_SdssShape_xx']
            Myy = src['base_SdssShape_yy']
            Mxy = src['base_SdssShape_xy']
            Muu_p_Mvv = Mxx + Myy
            Muu_m_Mvv = np.sqrt((Mxx - Myy)**2 + 4*Mxy**2)
            Muu = 0.5*(Muu_p_Mvv + Muu_m_Mvv)
            Mvv = 0.5*(Muu_p_Mvv - Muu_m_Mvv)
            theta = 0.5*np.arctan2(2*Mxy, Mxx - Myy)*180/np.pi
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
                    "numspots" : len(src),
                    "spot_indices": src['spotgrid_index'][indxs],
                    "amps": np.asarray(amps)[indxs],
                    "channels": np.asarray(channels)[indxs],
                    "spotgrid_x": src['spotgrid_x'][indxs],
                    "spotgrid_y": src['spotgrid_y'][indxs],
                    "peakSignal": peakSignal[indxs],
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
                    "base_CircularApertureFlux_3_0_instFlux": src["base_CircularApertureFlux_3_0_instFlux"][indxs],
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
                    "ext_shapeHSM_HsmSourceMoments_xy": src["ext_shapeHSM_HsmSourceMoments_xy"][indxs]
                }
            )

        # Sort the table by exposure time
        t = Table(tab)
        t_sorted = t[np.argsort(t['exptime'])]
        self.data = t_sorted
        
        return t_sorted
    
    def saveData(self, outdir="/sdf/home/a/abrought/run5/BF/data/", suffix="", filename=""):
        # Pickle the data
        
        import datetime
        now=datetime.datetime.now().isoformat(timespec='seconds')
        
        if not len(filename) == 0:
            filename = outdir + filename
        else:
            filename =  outdir + "_".join(("data",self.runnum, self.raftbay, self.ccdslot, now))
            filename += suffix
        
        filename += ".pkl"
        
        if(os.path.isfile(filename)):
            #print("Removing existing data pickle...")
            os.remove(filename)

        with open(filename, 'wb') as f:
            #print("Jarring a new data pickle...", filename)
            names = self.data.colnames
            pkl.dump([dict(zip(names, row)) for row in self.data], f)
            #print("Done.")
            
        return filename

    
def removeBadExps(expstoremove, data):
    if expstoremove == 0:
        return data

    unique_pos = np.unique(np.asarray(np.round(data['BOTX'],0)) / np.asarray(np.round(data['BOTY'],0)))
    if expstoremove > 0 :
        for pos in unique_pos:
            cond = (np.asarray(np.round(data['BOTX'],0)) / np.asarray(np.round(data['BOTY'],0)) == pos)
            temp = data[cond]

            for n in range(expstoremove):
                exp = np.argwhere((data['MJD'] == np.sort(temp['MJD'])[n]))[0][0]
                data.remove_row(exp)
    return data
    

def readData(filename1, filename2="", expstoremove=0):

    if filename2=="":
        data = Table(pkl.load( open(filename1, "rb") ))
        data = removeBadExps(expstoremove, data).group_by('exptime')

        print("File 1")
        for t in np.unique(data['exptime']):
            print(str(t)+'s,', len(np.argwhere(data['exptime']==t)), "images")
            
    else:
        data1 = Table(pkl.load( open(filename1, "rb") ))
        data2 = Table(pkl.load( open(filename2, "rb") ))
        
        data1 = removeBadExps(expstoremove, data1)
        data2 = removeBadExps(expstoremove, data2)

        data = vstack([data1, data2], join_type='exact').group_by('exptime')

        print("File 1")
        for t in np.unique(data1['exptime']):
            print(str(t)+'s,', len(np.argwhere(data1['exptime']==t)), "images")

        print("\n\nFile 2")
        for t in np.unique(data2['exptime']):
            print(str(t)+'s,', len(np.argwhere(data2['exptime']==t)), "images")

        print("\n\nCombined")
        for t in np.unique(data['exptime']):
            print(str(t)+'s,', len(np.argwhere(data['exptime']==t)), "images")
    
    return data

def getSensorData(sensor, detector, repo = "/sdf/group/lsst/camera/IandT/repo_gen3/BOT_data/butler.yaml"):
    butler = Butler(repo)
    registry = butler.registry
    camera = LsstCam().getCamera()
    
    #Get the PTC collections
    ptcs            = butler.get('ptc', detector=detector, instrument='LSSTCam', collections='u/abrought/BF/run_13144/ptcs')
    ptcs_linearized = butler.get('ptc', detector=detector, instrument='LSSTCam', collections='u/abrought/BF/run_13144/ptcs_linearized')
    
    # Get gains
    gains = dict()
    for i, amp in enumerate(camera[0].getAmplifiers()):
        gains.update({amp.getName(): ptcs.gain[amp.getName()]})
        
    gains_linearized = dict()
    for i, amp in enumerate(camera[0].getAmplifiers()):
        gains_linearized.update({amp.getName(): ptcs_linearized.gain[amp.getName()]})
        
    
    # get PTC & CTI turnoffs
    sensorparams = pkl.load( open("/sdf/home/a/abrought/run5/BF/data/dfmerge_13144.pkl", "rb") )

    ptc_turnoffs = sensorparams[(sensorparams["BAY_SLOT"] == sensor)]["PTC_TURNOFF"].to_numpy() * sensorparams[(sensorparams["BAY_SLOT"] == sensor)]["PTC_GAIN"]
    cti_turnoffs = sensorparams[(sensorparams["BAY_SLOT"] == sensor)]["CTI_TURNOFF"].to_numpy() * sensorparams[(sensorparams["BAY_SLOT"] == sensor)]["PTC_GAIN"]

    # get maximum observed signal
    eotest_results_path = "/sdf/group/lsst/camera/IandT/jobHarness/jh_archive/LCA-10134_Cryostat/LCA-10134_Cryostat-0001/13162/raft_results_summary_BOT/v0/107240/"
    h=fits.open(eotest_results_path + sensor + "_13162_eotest_results.fits")
    mos =h[1].data["MAX_OBSERVED_SIGNAL"] * sensorparams[(sensorparams["BAY_SLOT"] == sensor)]["PTC_GAIN"]
    h.close()

    #channels = sensorparams[(sensorparams["BAY_SLOT"] == sensor)]['SEGMENT'].to_numpy()

    #for i in range(len(ptc_turnoffs)):
    #    if len(str(channels[i])) == 1:
    #        ch = 'C0' + str(channels[i])
    #    else:
    #        ch = 'C' + str(channels[i])
    #    ptc_turnoffs[i] = ptc_turnoffs[i] * gains[ch]

    #for i in range(len(cti_turnoffs)):
    #    if len(str(channels[i])) == 1:
    #        ch = 'C0' + str(channels[i])
    #    else:
    #        ch = 'C' + str(channels[i])
    #    cti_turnoffs[i] = cti_turnoffs[i] * gains[ch]
        
    return ptc_turnoffs, cti_turnoffs, mos, gains, gains_linearized, sensorparams[(sensorparams["BAY_SLOT"] == sensor)]["PTC_GAIN"]

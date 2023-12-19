import os
import numpy as np
import glob
from astropy.io import fits
import pickle as pkl
import matplotlib.pyplot as plt
from lsst.daf.butler import Butler
import lsst.afw.display as afwDisplay
import lsst.afw.image as afwImage
from astropy.table import Table, vstack, join
from scipy import stats
from scipy.optimize import curve_fit
from lsst.obs.lsst import LsstCam
camera = LsstCam().getCamera()




#repo_path = "/sdf/group/lsst/camera/IandT/repo_gen3/BOT_data/butler.yaml"
repo_path = "/sdf/group/rubin/repo/main/"
butler = Butler(repo_path)
registry = butler.registry

# Pick a sensor
# Interesting sensors: 9 (C15/C16), 31 (C10) 
sensor = "R24_S11"
# (9, 23, 31, 83, 112, 136)
det = 112



#bfk = butler.get('bfk', detector=23, instrument='LSSTCam', collections='u/abrought/BF/2023.01.26/bfks.2023.01.26.max100kE.noQuadFit.corrModelr_3')
ptc = butler.get('ptc', detector=23, instrument='LSSTCam', collections='u/abrought/BF/2023.01.26/ptc.2023.01.26.max100kE')


def avg_matrix(d, exclude_channels=[]):
    if type(d["C00"]) == list:
        for key in d:
            d[key] = np.asarray(d[key])
    t = np.zeros(d["C00"].shape)
    for k,channel in zip(d.values(), d.keys()):
        if channel in exclude_channels:
            continue
        t += k
    return t / len(d.values())

A = avg_matrix(ptc.aMatrix)


from scipy.signal import convolve2d
def bf_correction(image, A):
    # From Antilogus
    
    #shape = image.shape
    
    # Get charge contribution
    #def delta_ij(i, j, A, image):
    #    sum_kl = 0.0
    #    for k in range(8):
    #        for l in range(8):
    #            sum_kl += A[k,l] * image[i-k][j-l]

    #    return 0.5 * sum_kl

    dQ = 0.5 * convolve2d(image, A)[0:image.shape[0],0:image.shape[1]]
    #dQ = np.zeros(image.shape)
    #for i in range(image.shape[0]):
    #    for j in range(image.shape[1]):
    #        dQ[i,j] = delta_ij(i,j,a,Q)
    
    return image + dQ

datasetRefs = butler.registry.queryDatasets('cpPtcProc',collections='u/abrought/BF/2023.01.26/ptc.2023.01.26', 
                                            detector=112,
                                            instrument='LSSTCam',
                                            where=f"instrument='LSSTCam' AND exposure.observation_type='flat' ")


# Plot the corrected PTC
camera = LsstCam().getCamera()
    
mu = {'C10':[],'C11':[],'C12':[],'C13':[],\
      'C14':[],'C15':[],'C16':[],'C17':[],\
      'C07':[],'C06':[],'C05':[],'C04':[],\
      'C03':[],'C02':[],'C01':[],'C00':[]}

var = {'C10':[],'C11':[],'C12':[],'C13':[],\
      'C14':[],'C15':[],'C16':[],'C17':[],\
      'C07':[],'C06':[],'C05':[],'C04':[],\
      'C03':[],'C02':[],'C01':[],'C00':[]}

#for i, ref in enumerate(datasetRefs):
    # Get the extracted image
#    ptcProc = butler.get('cpPtcProc',dataId=ref.dataId, collections='u/abrought/BF/2023.01.26/ptc.2023.01.26')
    
    # Loop through the amplifiers
#    for j, amp in enumerate(camera[0].getAmplifiers()):
#        amp_image = ptcProc.getImage().subset(amp.getBBox())
#        amp_image = bf_correction(amp_image.getArray(), A)
        
#        mu[amp.getName()].append(np.mean(amp_image))
#        var[amp.getName()].append(np.var(amp_image))
        #print(i, amp.getName(), np.mean(amp_image), np.var(amp_image), end ="\r")

    #display(ptcProc)

#Save
#with open('mu_corrected.pickle', 'wb') as handle:
#    pkl.dump(mu, handle)
#with open('var_corrected.pickle', 'wb') as handle:
#    pkl.dump(var, handle)
    

# Plot the uncorrected PTC
mu = {'C10':[],'C11':[],'C12':[],'C13':[],\
      'C14':[],'C15':[],'C16':[],'C17':[],\
      'C07':[],'C06':[],'C05':[],'C04':[],\
      'C03':[],'C02':[],'C01':[],'C00':[]}

var = {'C10':[],'C11':[],'C12':[],'C13':[],\
      'C14':[],'C15':[],'C16':[],'C17':[],\
      'C07':[],'C06':[],'C05':[],'C04':[],\
      'C03':[],'C02':[],'C01':[],'C00':[]}

for i, ref in enumerate(datasetRefs):
    # Get the extracted image
    ptcProc = butler.get('cpPtcProc',dataId=ref.dataId, collections='u/abrought/BF/2023.01.26/ptc.2023.01.26')
    
    # Loop through the amplifiers
    for j, amp in enumerate(camera[0].getAmplifiers()):
        amp_image = ptcProc.getImage().subset(amp.getBBox())
        #amp_image = bf_correction(amp_image.getArray(), A)
        
        mu[amp.getName()].append(np.mean(amp_image.getArray()))
        var[amp.getName()].append(np.var(amp_image.getArray()))
        #print(i, amp.getName(), np.mean(amp_image), np.var(amp_image), end ="\r")

    #display(ptcProc)

#Save
with open('mu.pickle', 'wb') as handle:
    pkl.dump(mu, handle)
with open('var.pickle', 'wb') as handle:
    pkl.dump(var, handle)

#with open('filename.pickle', 'rb') as handle:
#    b = pkl.load(handle)

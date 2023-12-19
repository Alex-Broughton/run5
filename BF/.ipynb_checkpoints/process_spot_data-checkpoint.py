import os
import numpy as np
import glob
from astropy.io import fits
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


import sys
sys.path.append('/sdf/home/a/abrought/bin')
from SpotAnalysis import Analyzer


run_sensor_dict = { '13230' : 'R02-S00',
                    '13231' : 'R02-S00',
                    '13232' : 'R03-S12',
                    '13234' : 'R03-S12',
                    '13236' : 'R21-S02',
                    '13238' : 'R21-S02',
                    '13239' : 'R24-S11',
                    '13240' : 'R24-S11',
                    '13249' : 'R03-S12',
                    '13250' : 'R24-S11',
                    '13247' : 'R03-S12',
                    '13252' : 'R24-S11',
                    '13248' : 'R03-S12',
                    '13251' : 'R24-S11'}

runnum = sys.argv[1]
suffix = sys.argv[2]
datatype = sys.argv[3]

sensor = run_sensor_dict[runnum]
col = "u/abrought/BF/2023.10.09/run_" + runnum + "/" + sensor + "/" + datatype

print("Started " + runnum + "/" + sensor + "/" + datatype + "...", end='')

analyzer = Analyzer(repo='/repo/main', collection=col)

#analyzer.fluxCutThreshold = 0.95
#analyzer.onlyConvergedGridFits = True
#analyzer.subtractSkyBkg = True
#analyzer.calcRadialProfile= True
#analyzer.calcHOMs = False
##analyzer.ellipticityRangeCut = (-1.0, 1.0)

analyzer.fluxCutThreshold = 0.95
analyzer.onlyConvergedGridFits = True
#analyzer.centerCutRadius = 5
analyzer.subtractSkyBkg = True
analyzer.calcRadialProfile= True
analyzer.calcHOMs = False

table = analyzer.getData()
end = "_" + suffix + "_" + datatype
filename = analyzer.saveData(outdir="/sdf/home/a/abrought/run5/BF/data/2023-10-09/", suffix=end)

print("Finished! :)")
#!/bin/bash

##SBATCH --partition=rubin
#SBATCH --job-name=calib
#SBATCH --output=/sdf/home/a/abrought/run5/BF/output/calibout.txt
#SBATCH --error=/sdf/home/a/abrought/run5/BF/output/caliberr.txt
#SBATCH --ntasks=6
#SBATCH --cpus-per-task=5
#SBATCH --mem-per-cpu=16G
#SBATCH --time=5:00:00
 
# Setup tools needed for analysis (optionally use you own local copy of cp_pipe)
source /cvmfs/sw.lsst.eu/linux-x86_64/lsst_distrib/w_2022_44/loadLSST-ext.bash
setup lsst_distrib
export PYTHONPATH="/sdf/home/a/abrought/bin/mixcoatl/python:${PYTHONPATH}" # Needed for using gridFit
 
# Set up repositories for collections
export REPO=/repo/ir2
export CONFIG=/sdf/home/a/abrought/run5/BF/config
export sbias=u/abrought/BF/run_7067D/sbias
export defects=u/abrought/BF/run_7016D_new/defects
export sdark=u/abrought/BF/run_7066D_new/sdark
export sflat=u/abrought/BF/run_13141/sflat

 
# Other PTC datasets 13147/13148 

# Detectors 9, 23, 31, 83, 112, 136 

# Generate SBIAS
#pipetask run \
#    -j 25 \
#    -d "instrument='LSSTCam' AND exposure.science_program IN ('7067D') AND detector in (94) AND exposure.observation_type = 'bias' AND exposure.observation_reason = 'bias' " \
#    -b ${REPO} \
#    -i LSSTCam/raw/all,LSSTCam/calib \
#    -o ${sbias} \
#    -p ${CONFIG}/cpBias.yaml \
#    --register-dataset-types

# Find DEFECTS
#pipetask run \
#    -j 25 \
#    -d "instrument='LSSTCam' AND exposure.science_program IN ('7016D') AND detector in (94) AND exposure.observation_type = 'flat' AND exposure.observation_reason='sflat' " \
#    -b ${REPO} \
#    -i LSSTCam/raw/all,LSSTCam/calib,${sbias} \
#    -o ${defects} \
#    -p ${CONFIG}/findDefects.yaml \
#    --register-dataset-types

# Generate SDARK
#pipetask run \
#    -j 25 \
#    -d "instrument='LSSTCam' AND exposure.observation_type='dark' AND exposure.observation_reason='dark' AND detector in (94) AND exposure.science_program IN ('7066D')" \
#    -b ${REPO} \
#    -i LSSTCam/raw/all,LSSTCam/calib,${sbias},${defects} \
#    -o ${sdark} \
#    -p ${CONFIG}/cpDark.yaml \
#    --register-dataset-types
 
 
# Generate SFLAT
#pipetask run \
#    -d "instrument='LSSTCam' AND exposure.science_program IN ('13141') AND detector in (9, 23, 31, 83, 112, 136) AND exposure.observation_type = 'flat' AND exposure.observation_reason='sflat' " \
#    -b ${REPO} \
#    -i LSSTCam/raw/all,LSSTCam/calib,${sbias},${defects},${sdark} \
#    -o ${sflat} \
#    -p ${CONFIG}/cpFlat.yaml \
#    --register-dataset-types
 


 
# Generate PTC
#pipetask run  \
#    -j 25 \
#    -d "instrument='LSSTCam' AND detector IN (9, 23, 31, 83, 112, 136) AND exposure.science_program IN ('13144')  AND exposure.observation_type = 'flat' AND exposure.observation_reason='flat' AND exposure.exposure_time<81.0" \
#    -b ${REPO}/butler.yaml \
#    -i LSSTCam/raw/all,LSSTCam/calib,${sbias},${sdark} \
#    -o ${ptcs_expapproximation_expcutoff} \
#    -p ${config}/cpPtc.yaml \
#    --register-dataset-types
     
#cp ${config}/cpPtc.yaml ${REPO}/${ptcs_expapproximation_expcutoff}
 
# Generate LINEARIZER
# You must use a single dummy exposure in the -d option. I just picked the first in the sequence.
 
#pipetask run \
#      -j 25 \
#      -d "instrument='LSSTCam' AND exposure IN (3021120600576) AND detector in (9, 23, 31, 83, 112, 136) AND exposure.science_program IN ('13144') AND exposure.exposure_time<81.0" \
#      -b ${REPO}/butler.yaml \
#      -i LSSTCam/raw/all,LSSTCam/calib,${sbias},${sflat},${defects},${ptcs_expapproximation_expcutoff} \
#      -p ${config}/cpLinearityCorrected.yaml \
#      -o ${linearity_expapproximation_expcutoff} \
#      --register-dataset-types
 
#cp ${config}/cpLinearityCorrected.yaml ${REPO}/${linearity_expapproximation_expcutoff}
 
# Regenerate PTC w/ LINEARIZER
# Add doLinearize = True to measurePhotonTransferCurve.yaml and re-run the task.
#pipetask run  \
#    -j 25 \
#    -d "instrument='LSSTCam' AND detector IN (9, 23, 31, 83, 112, 136) AND exposure.science_program IN ('13144')  AND exposure.observation_type = 'flat' AND exposure.observation_reason='flat' AND exposure.exposure_time<81.0 " \
#    -b ${REPO}/butler.yaml \
#    -i LSSTCam/raw/all,LSSTCam/calib,${sbias},${sdark},${linearity_expapproximation_expcutoff} \
#    -o ${ptcs_linearized_expapproximation_expcutoff} \
#    -p ${config}/cpPtc.yaml \
#    --register-dataset-types
     
#cp ${config}/cpPtc.yaml ${REPO}/${ptcs_linearized_expapproximation_expcutoff}
 
 
 
#END

#!/bin/bash

##SBATCH --partition=rubin
#SBATCH --job-name=calib
#SBATCH --output=/sdf/home/a/abrought/run5/BF/output/calibout2.txt
#SBATCH --error=/sdf/home/a/abrought/run5/BF/output/caliberr2.txt
#SBATCH --ntasks=6
#SBATCH --cpus-per-task=5
#SBATCH --mem-per-cpu=16G
#SBATCH --time=5:00:00
 
# Setup tools needed for analysis (optionally use you own local copy of cp_pipe)
# source /cvmfs/sw.lsst.eu/linux-x86_64/lsst_distrib/w_2022_40/loadLSST-ext.bash
# setup lsst_distrib
# setup -j -r /sdf/home/a/abrought/cp_pipe
source /cvmfs/sw.lsst.eu/linux-x86_64/lsst_distrib/w_2022_32/loadLSST-ext.bash
setup lsst_distrib
#setup -j -r /sdf/home/a/abrought/cp_pipe
export PYTHONPATH="/sdf/home/a/abrought/bin/mixcoatl/python:${PYTHONPATH}" # Needed for using gridFit
 
# Set up repositories for collections
export REPO=/sdf/group/rubin/repo/ir2
export config=/sdf/home/a/abrought/run5/BF/config
export sbias=u/abrought/BF/run_13141/sbias
export sflat=u/abrought/BF/run_13141/sflat
export defects=u/abrought/BF/run_13141/defects
export sdark=u/abrought/BF/run_13162/sdark
export linearizer=u/cslage/linearizer_28jan22/20220128T174703Z # Craig's curated version
export linearity=u/abrought/BF/run_13144/linearity
export linearity_expapproximation_expcutoff=u/abrought/BF/run_13144/linearity_expapproximation_expcutoff
export linearity_fullcovariance=u/abrought/BF/run_13144/linearity_fullcovariance
export linearity_fullcovariance_test=u/abrought/BF/run_13144/linearity_fullcovariance_test4
export linearity_fullcovariance_expcutoff=u/abrought/BF/run_13144/linearity_fullcovariance_expcutoff
export linearity_fullcovariance_expcutoff_expanded=u/abrought/BF/run_13144/linearity_fullcovariance_expcutoff_expanded
export ptcs=u/abrought/BF/run_13144/ptcs
export ptcs_expapproximation_expcutoff=u/abrought/BF/run_13144/ptcs_expapproximation_expcutoff
export ptcs_fullcovariance=u/abrought/BF/run_13144/ptcs_fullcovariance
export ptcs_fullcovariance_expcutoff=u/abrought/BF/run_13144/ptcs_fullcovariance_expcutoff
export ptcs_fullcovariance_expcutoff_expanded=u/abrought/BF/run_13144/ptcs_fullcovariance_expcutoff_expanded
export ptcs_linearized=u/abrought/BF/run_13144/ptcs_linearized
export ptcs_linearized_expapproximation_expcutoff=u/abrought/BF/run_13144/ptcs_linearized_expapproximation_expcutoff
export ptcs_linearized_fullcovariance=u/abrought/BF/run_13144/ptcs_linearized_fullcovariance
export ptcs_linearized_fullcovariance_12_14_22=u/abrought/BF/run_13144/ptcs_linearized_fullcovariance_12_14_22
export ptcs_linearized_expapproximation_12_14_22=u/abrought/BF/run_13144/ptcs_linearized_expapproximation_12_14_22
export ptcs_linearized_expapproximation_expcutoff_12_14_22=u/abrought/BF/run_13144/ptcs_linearized_expapproximation_expcutoff_12_14_22
export ptcs_linearized_fullcovariance_expcutoff=u/abrought/BF/run_13144/ptcs_linearized_fullcovariance_expcutoff
export ptcs_linearized_fullcovariance_expcutoff_expanded=u/abrought/BF/run_13144/ptcs_linearized_fullcovariance_expcutoff_expanded
export bfks=u/abrought/BF/run_13144/bfks2
export bfks_linearized=u/abrought/BF/run_13144/bfks_linearized
export bfks_linearized_fullcovariance_12_14_22=u/abrought/BF/run_13144/bfks_linearized_fullcovariance_12_14_22
export bfks_linearized_expapproximation_12_14_22=u/abrought/BF/run_13144/bfks_linearized_expapproximation_12_14_22
export bfks_linearized_expapproximation_expcutoff_12_14_22=u/abrought/BF/run_13144/bfks_linearized_expapproximation_expcutoff_12_14_22
 
# Other PTC datasets 13147/13148 

# Detectors 9, 23, 31, 83, 112, 136 

# Generate SBIAS
#pipetask run \
#    -j 25 \
#    -d "instrument='LSSTCam' AND exposure.science_program IN ('13141') AND detector in (9, 23, 31, 83, 112, 136) AND exposure.observation_type = 'bias' " \
#    -b ${REPO} \
#    -i LSSTCam/raw/all,LSSTCam/calib \
#    -o ${sbias} \
#    -p ${CONFIG}/cpBias.yaml \
#    --register-dataset-types

# Find DEFECTS
#pipetask run \
#    -j 25 \
#    -d "instrument='LSSTCam' AND exposure.science_program IN ('13141') AND detector in (9, 23, 31, 83, 112, 136) AND exposure.observation_type = 'flat' AND exposure.observation_reason='sflat' " \
#    -b ${REPO} \
#    -i LSSTCam/raw/all,LSSTCam/calib,${sbias} \
#    -o ${defects} \
#    -p ${CONFIG}/findDefects.yaml \
#    --register-dataset-types

# Generate SDARK
#pipetask run \
#    -j 25 \
#    -d "instrument='LSSTCam' AND exposure.observation_type='dark' AND exposure.observation_reason='dark' AND detector in (9, 23, 31, 83, 112, 136) AND exposure.science_program IN ('13162')" \
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
#      -d "instrument='LSSTCam' AND exposure IN (3021120600576) AND detector in (9, 23, 31, 83, 112, 136) AND exposure.science_program IN ('13144')" \
#      -b ${REPO}/butler.yaml \
#      -i LSSTCam/raw/all,LSSTCam/calib,LSSTCam/photodiode,${sbias},${sflat},${defects},${ptcs_fullcovariance} \
#      -p ${config}/cpLinearityCorrected.yaml \
#      -o ${linearity_fullcovariance_test} \
#      --register-dataset-types
 
#cp ${config}/cpLinearityCorrected.yaml ${REPO}/${linearity_expapproximation_expcutoff}
 
# Regenerate PTC w/ LINEARIZER
# Add doLinearize = True to measurePhotonTransferCurve.yaml and re-run the task.
#pipetask run  \
#    -j 25 \
#    -d "instrument='LSSTCam' AND detector IN (23, 112) AND exposure.science_program IN ('13144')  AND exposure.observation_type = 'flat' AND exposure.observation_reason='flat' AND exposure.exposure_time<55.0 " \
#    -b ${REPO}/butler.yaml \
#    -i LSSTCam/raw/all,LSSTCam/calib,${sbias},${sdark},${linearizer} \
#    -o ${ptcs_linearized_expapproximation_expcutoff_12_14_22} \
#    -p ${config}/cpPtc.yaml \
#    --register-dataset-types


pipetask run \
       -j 25 \
       -d "instrument='LSSTCam' AND exposure IN (3021120600576) AND detector IN (23, 112) " \
       -b ${REPO}/butler.yaml \
       -i LSSTCam/raw/all,LSSTCam/calib,${sbias},${sdark},${sflat},${defects},${ptcs_linearized_expapproximation_expcutoff_12_14_22}  \
       -o ${bfks_linearized_expapproximation_expcutoff_12_14_22} \
       -p ${config}/cpBfkSolve.yaml \
       --register-dataset-types

pipetask run \
       -j 25 \
       -d "instrument='LSSTCam' AND exposure IN (3021120600576) AND detector IN (23, 112) " \
       -b ${REPO}/butler.yaml \
       -i LSSTCam/raw/all,LSSTCam/calib,${sbias},${sdark},${sflat},${defects},${ptcs_linearized_expapproximation_12_14_22}  \
       -o ${bfks_linearized_expapproximation_12_14_22} \
       -p ${config}/cpBfkSolve.yaml \
       --register-dataset-types
 
 
#END

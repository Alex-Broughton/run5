#!/bin/bash

##SBATCH --partition=rubin
#SBATCH --job-name=calib
#SBATCH --output=/sdf/home/a/abrought/run5/BF/output/out3.txt
#SBATCH --error=/sdf/home/a/abrought/run5/BF/output/err3.txt
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=5
#SBATCH --mem-per-cpu=16G
##SBATCH --time=5:00:00
 
# used to be 

#source /cvmfs/sw.lsst.eu/linux-x86_64/lsst_distrib/w_2023_09/loadLSST-ext.bash
#setup lsst_distrib
#setup -j -r /sdf/home/a/abrought/alternate_branches/cp_pipe
#setup -j -r /sdf/home/a/abrought/alternate_branches/ip_isr

source /sdf/group/rubin/sw/tag/w_2023_29/loadLSST.bash
setup lsst_distrib -t w_2023_29
setup -t w_2023_19 -j -r /sdf/home/a/abrought/alternate_branches/dm_stack/cp_pipe
setup -t w_2023_19 -j -r /sdf/home/a/abrought/alternate_branches/dm_stack/ip_isr

export PYTHONPATH="/sdf/home/a/abrought/bin/mixcoatl/python:${PYTHONPATH}" # Needed for using gridFit
 
# Set up repositories for collections
export REPO=/repo/main
export CONFIG=/sdf/home/a/abrought/run5/BF/config
export SBIAS=u/cslage/calib/13144/bias_20211229
export SDARK=u/cslage/calib/13144/dark_20211229
export DEFECTS=u/cslage/calib/13144/defects_20211229
export LINEARITY=u/cslage/linearizer_28jan22/20220128T174703Z
#export CTI=u/cslage/sdf/BOT/cti_test_20230106
export CTI=u/abrought/BF/2023.04.14/cti.2023.04.14

 
# Other PTC datasets 13147/13148 

# Detectors 9, 23, 31, 83, 112, 136 used for Run 5 spot testing

pipetask run  \
    -j 30 \
    -d "instrument='LSSTCam' AND detector IN (112) AND exposure.science_program IN ('13144')  AND exposure.observation_type = 'flat' AND exposure.observation_reason='flat' " \
    -b ${REPO} \
    -i u/abrought/BF/2023.07.19/ptc.R24-S11.trunc_to_pcti.fullnoisematrix,u/abrought/BF/2023.07.19/bfk.R24-S11.10000adu,${SBIAS},${SDARK},${DEFECTS},${CTI},${LINEARITY},LSSTCam/raw/all \
    -o u/abrought/BF/2023.07.19/ptc.R24-S11.bfcorrected.10000adu \
    -p ${CONFIG}/cpPtc.yaml \
        --config isr:connections.newBFKernel='bfk' \
    --register-dataset-types


pipetask run  \
    -j 30 \
    -d "instrument='LSSTCam' AND detector IN (112) AND exposure.science_program IN ('13144')  AND exposure.observation_type = 'flat' AND exposure.observation_reason='flat' " \
    -b ${REPO} \
    -i u/abrought/BF/2023.07.19/ptc.R24-S11.trunc_to_pcti.fullnoisematrix,u/abrought/BF/2023.07.19/bfk.R24-S11.20000adu,${SBIAS},${SDARK},${DEFECTS},${CTI},${LINEARITY},LSSTCam/raw/all \
    -o u/abrought/BF/2023.07.19/ptc.R24-S11.bfcorrected.20000adu \
    -p ${CONFIG}/cpPtc.yaml \
        --config isr:connections.newBFKernel='bfk' \
    --register-dataset-types
    
pipetask run  \
    -j 30 \
    -d "instrument='LSSTCam' AND detector IN (112) AND exposure.science_program IN ('13144')  AND exposure.observation_type = 'flat' AND exposure.observation_reason='flat' " \
    -b ${REPO} \
    -i u/abrought/BF/2023.07.19/ptc.R24-S11.trunc_to_pcti.fullnoisematrix,u/abrought/BF/2023.07.19/bfk.R24-S11.30000adu,${SBIAS},${SDARK},${DEFECTS},${CTI},${LINEARITY},LSSTCam/raw/all \
    -o u/abrought/BF/2023.07.19/ptc.R24-S11.bfcorrected.30000adu \
    -p ${CONFIG}/cpPtc.yaml \
        --config isr:connections.newBFKernel='bfk' \
    --register-dataset-types

pipetask run  \
    -j 30 \
    -d "instrument='LSSTCam' AND detector IN (112) AND exposure.science_program IN ('13144')  AND exposure.observation_type = 'flat' AND exposure.observation_reason='flat' " \
    -b ${REPO} \
    -i u/abrought/BF/2023.07.19/ptc.R24-S11.trunc_to_pcti.fullnoisematrix,u/abrought/BF/2023.07.19/bfk.R24-S11.40000adu,${SBIAS},${SDARK},${DEFECTS},${CTI},${LINEARITY},LSSTCam/raw/all \
    -o u/abrought/BF/2023.07.19/ptc.R24-S11.bfcorrected.40000adu \
    -p ${CONFIG}/cpPtc.yaml \
        --config isr:connections.newBFKernel='bfk' \
    --register-dataset-types


pipetask run  \
    -j 30 \
    -d "instrument='LSSTCam' AND detector IN (112) AND exposure.science_program IN ('13144')  AND exposure.observation_type = 'flat' AND exposure.observation_reason='flat' " \
    -b ${REPO} \
    -i u/abrought/BF/2023.07.19/ptc.R24-S11.trunc_to_pcti.fullnoisematrix,u/abrought/BF/2023.07.19/bfk.R24-S11.50000adu,${SBIAS},${SDARK},${DEFECTS},${CTI},${LINEARITY},LSSTCam/raw/all \
    -o u/abrought/BF/2023.07.19/ptc.R24-S11.bfcorrected.50000adu \
    -p ${CONFIG}/cpPtc.yaml \
        --config isr:connections.newBFKernel='bfk' \
    --register-dataset-types
    
pipetask run  \
    -j 30 \
    -d "instrument='LSSTCam' AND detector IN (112) AND exposure.science_program IN ('13144')  AND exposure.observation_type = 'flat' AND exposure.observation_reason='flat' " \
    -b ${REPO} \
    -i u/abrought/BF/2023.07.19/ptc.R24-S11.trunc_to_pcti.fullnoisematrix,u/abrought/BF/2023.07.19/bfk.R24-S11.60000adu,${SBIAS},${SDARK},${DEFECTS},${CTI},${LINEARITY},LSSTCam/raw/all \
    -o u/abrought/BF/2023.07.19/ptc.R24-S11.bfcorrected.60000adu \
    -p ${CONFIG}/cpPtc.yaml \
        --config isr:connections.newBFKernel='bfk' \
    --register-dataset-types
    
pipetask run  \
    -j 30 \
    -d "instrument='LSSTCam' AND detector IN (112) AND exposure.science_program IN ('13144')  AND exposure.observation_type = 'flat' AND exposure.observation_reason='flat' " \
    -b ${REPO} \
    -i u/abrought/BF/2023.07.19/ptc.R24-S11.trunc_to_pcti.fullnoisematrix,u/abrought/BF/2023.07.19/bfk.R24-S11.70000adu,${SBIAS},${SDARK},${DEFECTS},${CTI},${LINEARITY},LSSTCam/raw/all \
    -o u/abrought/BF/2023.07.19/ptc.R24-S11.bfcorrected.70000adu \
    -p ${CONFIG}/cpPtc.yaml \
        --config isr:connections.newBFKernel='bfk' \
    --register-dataset-types
    
pipetask run  \
    -j 30 \
    -d "instrument='LSSTCam' AND detector IN (112) AND exposure.science_program IN ('13144')  AND exposure.observation_type = 'flat' AND exposure.observation_reason='flat' " \
    -b ${REPO} \
    -i u/abrought/BF/2023.07.19/ptc.R24-S11.trunc_to_pcti.fullnoisematrix,u/abrought/BF/2023.07.19/bfk.R24-S11.80000adu,${SBIAS},${SDARK},${DEFECTS},${CTI},${LINEARITY},LSSTCam/raw/all \
    -o u/abrought/BF/2023.07.19/ptc.R24-S11.bfcorrected.80000adu \
    -p ${CONFIG}/cpPtc.yaml \
        --config isr:connections.newBFKernel='bfk' \
    --register-dataset-types
    
# pipetask run  \
#     -j 30 \
#     -d "instrument='LSSTCam' AND detector IN (112) AND exposure.science_program IN ('13144')  AND exposure.observation_type = 'flat' AND exposure.observation_reason='flat' " \
#     -b ${REPO} \
#     -i u/abrought/BF/2023.07.19/ptc.R24-S11.trunc_to_pcti.fullnoisematrix,u/abrought/BF/2023.07.19/bfk.R24-S11.90000adu,${SBIAS},${SDARK},${DEFECTS},${CTI},${LINEARITY},LSSTCam/raw/all \
#     -o u/abrought/BF/2023.07.19/ptc.R24-S11.bfcorrected.90000adu \
#     -p ${CONFIG}/cpPtc.yaml \
#         --config isr:connections.newBFKernel='bfk' \
#     --register-dataset-types
    
# pipetask run  \
#     -j 30 \
#     -d "instrument='LSSTCam' AND detector IN (112) AND exposure.science_program IN ('13144')  AND exposure.observation_type = 'flat' AND exposure.observation_reason='flat' " \
#     -b ${REPO} \
#     -i u/abrought/BF/2023.07.19/ptc.R24-S11.trunc_to_pcti.fullnoisematrix,u/abrought/BF/2023.07.19/bfk.R24-S11.100000adu,${SBIAS},${SDARK},${DEFECTS},${CTI},${LINEARITY},LSSTCam/raw/all \
#     -o u/abrought/BF/2023.07.19/ptc.R24-S11.bfcorrected.100000adu \
#     -p ${CONFIG}/cpPtc.yaml \
#         --config isr:connections.newBFKernel='bfk' \
#     --register-dataset-types
    


# END
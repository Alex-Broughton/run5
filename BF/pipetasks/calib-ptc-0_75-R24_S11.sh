#!/bin/bash

##SBATCH --partition=rubin
#SBATCH --job-name=calib
#SBATCH --output=/sdf/home/a/abrought/run5/BF/output/out025.txt
#SBATCH --error=/sdf/home/a/abrought/run5/BF/output/err025.txt
#SBATCH --ntasks=6
#SBATCH --cpus-per-task=5
#SBATCH --mem-per-cpu=16G
##SBATCH --time=5:00:00
 
# used to be 

#source /cvmfs/sw.lsst.eu/linux-x86_64/lsst_distrib/w_2023_09/loadLSST-ext.bash
#setup lsst_distrib
#setup -j -r /sdf/home/a/abrought/alternate_branches/cp_pipe
#setup -j -r /sdf/home/a/abrought/alternate_branches/ip_isr


source /cvmfs/sw.lsst.eu/linux-x86_64/lsst_distrib/w_2023_19/loadLSST-ext.bash
setup lsst_distrib
setup -j -r /sdf/home/a/abrought/alternate_branches/chrisfixes/cp_pipe
setup -j -r /sdf/home/a/abrought/alternate_branches/chrisfixes/ip_isr

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
export PTC=u/abrought/BF/2023.01.26/ptc.2023.01.26
export PTC_max100kE=u/abrought/BF/2023.01.26/ptc.2023.01.26.max100kE
export BFK=u/abrought/BF/2023.01.26/bfks.2023.01.26.max100kE.noQuadFit.corrModelr_3

 
# Other PTC datasets 13147/13148 

# Detectors 9, 23, 31, 83, 112, 136 used for Run 5 spot testing


pipetask run  \
    -j 10 \
    -d "instrument='LSSTCam' AND detector IN (112) AND exposure.science_program IN ('13144')  AND exposure.observation_type = 'flat' AND exposure.observation_reason='flat' " \
    -b ${REPO} \
    -i u/abrought/BF/2023.04.28/ptc.2023.04.28.R24-S11.trunc_to_pcti,u/abrought/BF/2023.05.15/bfk.2023.05.15.R24-S11.fudgefactor_0.75,${SBIAS},${SDARK},${DEFECTS},${CTI},${LINEARITY},LSSTCam/raw/all \
    -o u/abrought/BF/2023.06.06/ptc.2023.06.06.R24-S11.bfcorrected.fudgefactor_0.75 \
    -p ${CONFIG}/cpPtc.yaml \
        --config isr:connections.newBFKernel='bfk' \
    --register-dataset-types

#pipetask run  \
#    -j 10 \
#    -d "instrument='LSSTCam' AND detector IN (23) AND exposure.science_program IN ('13144')  AND exposure.observation_type = 'flat' AND exposure.observation_reason='flat' " \
#    -b ${REPO} \
#    -i u/abrought/BF/2023.04.28/ptc.2023.04.28.R03-S12.trunc_to_pcti,u/abrought/BF/2023.05.15/bfk.2023.05.15.R03-S12.fudgefactor_0.75,${SBIAS},${SDARK},${DEFECTS},${CTI},${LINEARITY},LSSTCam/raw/all \
#    -o u/abrought/BF/2023.06.06/ptc.2023.06.06.R03-S12.bfcorrected.fudgefactor_0.75 \
#    -p ${CONFIG}/cpPtc.yaml \
#        --config isr:connections.newBFKernel='bfk' \
#    --register-dataset-types
#
#pipetask run  \
#    -j 10 \
#    -d "instrument='LSSTCam' AND detector IN (9) AND exposure.science_program IN ('13144')  AND exposure.observation_type = 'flat' AND exposure.observation_reason='flat' " \
#    -b ${REPO} \
#    -i u/abrought/BF/2023.04.28/ptc.2023.04.28.R02-S00.trunc_to_pcti,u/abrought/BF/2023.05.15/bfk.2023.05.15.R02-S00.fudgefactor_0.75,${SBIAS},${SDARK},${DEFECTS},${CTI},${LINEARITY},LSSTCam/raw/all \
#    -o u/abrought/BF/2023.06.06/ptc.2023.06.06.R02-S00.bfcorrected.fudgefactor_0.75 \
#    -p ${CONFIG}/cpPtc.yaml \
#        --config isr:connections.newBFKernel='bfk' \
#    --register-dataset-types
#
#pipetask run  \
#    -j 10 \
#    -d "instrument='LSSTCam' AND detector IN (83) AND exposure.science_program IN ('13144')  AND exposure.observation_type = 'flat' AND exposure.observation_reason='flat' " \
#    -b ${REPO} \
#    -i u/abrought/BF/2023.04.28/ptc.2023.04.28.R21-S02.trunc_to_pcti,u/abrought/BF/2023.05.15/bfk.2023.05.15.R21-S02.fudgefactor_0.75,${SBIAS},${SDARK},${DEFECTS},${CTI},${LINEARITY},LSSTCam/raw/all \
#    -o u/abrought/BF/2023.06.06/ptc.2023.06.06.R21-S02.bfcorrected.fudgefactor_0.75 \
#    -p ${CONFIG}/cpPtc.yaml \
#        --config isr:connections.newBFKernel='bfk' \
#    --register-dataset-types

# END

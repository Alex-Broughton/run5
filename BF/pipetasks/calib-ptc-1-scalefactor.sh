#!/bin/bash

##SBATCH --partition=rubin
#SBATCH --job-name=calib
#SBATCH --output=/sdf/home/a/abrought/run5/BF/output/out2.txt
#SBATCH --error=/sdf/home/a/abrought/run5/BF/output/err2.txt
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=5
#SBATCH --mem-per-cpu=16G
##SBATCH --time=5:00:00
 
# used to be 

#source /cvmfs/sw.lsst.eu/linux-x86_64/lsst_distrib/w_2023_09/loadLSST-ext.bash
#setup lsst_distrib
#setup -j -r /sdf/home/a/abrought/alternate_branches/cp_pipe
#setup -j -r /sdf/home/a/abrought/alternate_branches/ip_isr

source /sdf/group/rubin/sw/tag/w_2023_19/loadLSST.bash
setup lsst_distrib -t w_2023_19
setup -t w_2023_19 -j -r /sdf/home/a/abrought/alternate_branches/chrisfixes_old/cp_pipe
setup -t w_2023_19 -j -r /sdf/home/a/abrought/alternate_branches/chrisfixes_old/ip_isr

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
    -d "instrument='LSSTCam' AND detector IN (23) AND exposure.science_program IN ('13144')  AND exposure.observation_type = 'flat' AND exposure.observation_reason='flat' " \
    -b ${REPO} \
    -i u/abrought/BF/2023.04.28/ptc.2023.04.28.R03-S12.trunc_to_pcti,u/abrought/BF/2023.06.16/bfk.R03-S12.scalefactor-0_6,${SBIAS},${SDARK},${DEFECTS},${CTI},${LINEARITY},LSSTCam/raw/all \
    -o u/abrought/BF/2023.06.16/ptc.R03-S12.bfcorrected.scalefactor-0_6 \
    -p ${CONFIG}/cpPtc.yaml \
        --config isr:connections.newBFKernel='bfk' \
    --register-dataset-types

#pipetask run  \
#    -j 30 \
#    -d "instrument='LSSTCam' AND detector IN (23) AND exposure.science_program IN ('13144')  AND exposure.observation_type = 'flat' AND exposure.observation_reason='flat' " \
#    -b ${REPO} \
#    -i u/abrought/BF/2023.04.28/ptc.2023.04.28.R03-S12.trunc_to_pcti,u/abrought/BF/2023.06.16/bfk.R03-S12.scalefactor-0_65,${SBIAS},${SDARK},${DEFECTS},${CTI},${LINEARITY},LSSTCam/raw/all \
#    -o u/abrought/BF/2023.06.16/ptc.R03-S12.bfcorrected.scalefactor-0_65 \
#    -p ${CONFIG}/cpPtc.yaml \
#        --config isr:connections.newBFKernel='bfk' \
#    --register-dataset-types


#pipetask run  \
#    -j 30 \
#    -d "instrument='LSSTCam' AND detector IN (23) AND exposure.science_program IN ('13144')  AND exposure.observation_type = 'flat' AND exposure.observation_reason='flat' " \
#    -b ${REPO} \
#    -i u/abrought/BF/2023.04.28/ptc.2023.04.28.R03-S12.trunc_to_pcti,u/abrought/BF/2023.06.16/bfk.R03-S12.scalefactor-0_675,${SBIAS},${SDARK},${DEFECTS},${CTI},${LINEARITY},LSSTCam/raw/all \
#    -o u/abrought/BF/2023.06.16/ptc.R03-S12.bfcorrected.scalefactor-0_675 \
#    -p ${CONFIG}/cpPtc.yaml \
#        --config isr:connections.newBFKernel='bfk' \
#    --register-dataset-types
    
pipetask run  \
    -j 30 \
    -d "instrument='LSSTCam' AND detector IN (23) AND exposure.science_program IN ('13144')  AND exposure.observation_type = 'flat' AND exposure.observation_reason='flat' " \
    -b ${REPO} \
    -i u/abrought/BF/2023.04.28/ptc.2023.04.28.R03-S12.trunc_to_pcti,u/abrought/BF/2023.06.16/bfk.R03-S12.scalefactor-0_7,${SBIAS},${SDARK},${DEFECTS},${CTI},${LINEARITY},LSSTCam/raw/all \
    -o u/abrought/BF/2023.06.16/ptc.R03-S12.bfcorrected.scalefactor-0_7 \
    -p ${CONFIG}/cpPtc.yaml \
        --config isr:connections.newBFKernel='bfk' \
    --register-dataset-types
    
#pipetask run  \
#    -j 30 \
#    -d "instrument='LSSTCam' AND detector IN (23) AND exposure.science_program IN ('13144')  AND exposure.observation_type = 'flat' AND exposure.observation_reason='flat' " \
#    -b ${REPO} \
#    -i u/abrought/BF/2023.04.28/ptc.2023.04.28.R03-S12.trunc_to_pcti,u/abrought/BF/2023.06.16/bfk.R03-S12.scalefactor-0_725,${SBIAS},${SDARK},${DEFECTS},${CTI},${LINEARITY},LSSTCam/raw/all \
#    -o u/abrought/BF/2023.06.16/ptc.R03-S12.bfcorrected.scalefactor-0_725 \
#    -p ${CONFIG}/cpPtc.yaml \
#        --config isr:connections.newBFKernel='bfk' \
#    --register-dataset-types
    
#pipetask run  \
#    -j 30 \
#    -d "instrument='LSSTCam' AND detector IN (23) AND exposure.science_program IN ('13144')  AND exposure.observation_type = 'flat' AND exposure.observation_reason='flat' " \
#    -b ${REPO} \
#    -i u/abrought/BF/2023.04.28/ptc.2023.04.28.R03-S12.trunc_to_pcti,u/abrought/BF/2023.06.16/bfk.R03-S12.scalefactor-0_75,${SBIAS},${SDARK},${DEFECTS},${CTI},${LINEARITY},LSSTCam/raw/all \
#    -o u/abrought/BF/2023.06.16/ptc.R03-S12.bfcorrected.scalefactor-0_75 \
#    -p ${CONFIG}/cpPtc.yaml \
#        --config isr:connections.newBFKernel='bfk' \
#    --register-dataset-types
    
#pipetask run  \
#    -j 30 \
#    -d "instrument='LSSTCam' AND detector IN (23) AND exposure.science_program IN ('13144')  AND exposure.observation_type = 'flat' AND exposure.observation_reason='flat' " \
#    -b ${REPO} \
#    -i u/abrought/BF/2023.04.28/ptc.2023.04.28.R03-S12.trunc_to_pcti,u/abrought/BF/2023.06.16/bfk.R03-S12.scalefactor-0_775,${SBIAS},${SDARK},${DEFECTS},${CTI},${LINEARITY},LSSTCam/raw/all \
#    -o u/abrought/BF/2023.06.16/ptc.R03-S12.bfcorrected.scalefactor-0_775 \
#    -p ${CONFIG}/cpPtc.yaml \
#        --config isr:connections.newBFKernel='bfk' \
#    --register-dataset-types
    
pipetask run  \
    -j 30 \
    -d "instrument='LSSTCam' AND detector IN (23) AND exposure.science_program IN ('13144')  AND exposure.observation_type = 'flat' AND exposure.observation_reason='flat' " \
    -b ${REPO} \
    -i u/abrought/BF/2023.04.28/ptc.2023.04.28.R03-S12.trunc_to_pcti,u/abrought/BF/2023.06.16/bfk.R03-S12.scalefactor-0_8,${SBIAS},${SDARK},${DEFECTS},${CTI},${LINEARITY},LSSTCam/raw/all \
    -o u/abrought/BF/2023.06.16/ptc.R03-S12.bfcorrected.scalefactor-0_8 \
    -p ${CONFIG}/cpPtc.yaml \
        --config isr:connections.newBFKernel='bfk' \
    --register-dataset-types

#pipetask run  \
#    -j 30 \
#    -d "instrument='LSSTCam' AND detector IN (23) AND exposure.science_program IN ('13144')  AND exposure.observation_type = 'flat' AND exposure.observation_reason='flat' " \
#    -b ${REPO} \
#    -i u/abrought/BF/2023.04.28/ptc.2023.04.28.R03-S12.trunc_to_pcti,u/abrought/BF/2023.06.16/bfk.R03-S12.scalefactor-0_825,${SBIAS},${SDARK},${DEFECTS},${CTI},${LINEARITY},LSSTCam/raw/all \
#    -o u/abrought/BF/2023.06.16/ptc.R03-S12.bfcorrected.scalefactor-0_825 \
#    -p ${CONFIG}/cpPtc.yaml \
#        --config isr:connections.newBFKernel='bfk' \
#    --register-dataset-types

#pipetask run  \
#    -j 30 \
#    -d "instrument='LSSTCam' AND detector IN (23) AND exposure.science_program IN ('13144')  AND exposure.observation_type = 'flat' AND exposure.observation_reason='flat' " \
#    -b ${REPO} \
#    -i u/abrought/BF/2023.04.28/ptc.2023.04.28.R03-S12.trunc_to_pcti,u/abrought/BF/2023.06.16/bfk.R03-S12.scalefactor-0_85,${SBIAS},${SDARK},${DEFECTS},${CTI},${LINEARITY},LSSTCam/raw/all \
#    -o u/abrought/BF/2023.06.16/ptc.R03-S12.bfcorrected.scalefactor-0_85 \
#    -p ${CONFIG}/cpPtc.yaml \
#        --config isr:connections.newBFKernel='bfk' \
#    --register-dataset-types

#pipetask run  \
#    -j 30 \
#    -d "instrument='LSSTCam' AND detector IN (23) AND exposure.science_program IN ('13144')  AND exposure.observation_type = 'flat' AND exposure.observation_reason='flat' " \
#    -b ${REPO} \
#    -i u/abrought/BF/2023.04.28/ptc.2023.04.28.R03-S12.trunc_to_pcti,u/abrought/BF/2023.06.16/bfk.R03-S12.scalefactor-0_875,${SBIAS},${SDARK},${DEFECTS},${CTI},${LINEARITY},LSSTCam/raw/all \
#    -o u/abrought/BF/2023.06.16/ptc.R03-S12.bfcorrected.scalefactor-0_875 \
#    -p ${CONFIG}/cpPtc.yaml \
#        --config isr:connections.newBFKernel='bfk' \
#    --register-dataset-types

pipetask run  \
    -j 30 \
    -d "instrument='LSSTCam' AND detector IN (23) AND exposure.science_program IN ('13144')  AND exposure.observation_type = 'flat' AND exposure.observation_reason='flat' " \
    -b ${REPO} \
    -i u/abrought/BF/2023.04.28/ptc.2023.04.28.R03-S12.trunc_to_pcti,u/abrought/BF/2023.06.16/bfk.R03-S12.scalefactor-0_9,${SBIAS},${SDARK},${DEFECTS},${CTI},${LINEARITY},LSSTCam/raw/all \
    -o u/abrought/BF/2023.06.16/ptc.R03-S12.bfcorrected.scalefactor-0_9 \
    -p ${CONFIG}/cpPtc.yaml \
        --config isr:connections.newBFKernel='bfk' \
    --register-dataset-types

#pipetask run  \
#    -j 30 \
#    -d "instrument='LSSTCam' AND detector IN (23) AND exposure.science_program IN ('13144')  AND exposure.observation_type = 'flat' AND exposure.observation_reason='flat' " \
#    -b ${REPO} \
#    -i u/abrought/BF/2023.04.28/ptc.2023.04.28.R03-S12.trunc_to_pcti,u/abrought/BF/2023.06.16/bfk.R03-S12.scalefactor-0_925,${SBIAS},${SDARK},${DEFECTS},${CTI},${LINEARITY},LSSTCam/raw/all \
#    -o u/abrought/BF/2023.06.16/ptc.R03-S12.bfcorrected.scalefactor-0_925 \
#    -p ${CONFIG}/cpPtc.yaml \
#        --config isr:connections.newBFKernel='bfk' \
#    --register-dataset-types

#pipetask run  \
#    -j 30 \
#    -d "instrument='LSSTCam' AND detector IN (23) AND exposure.science_program IN ('13144')  AND exposure.observation_type = 'flat' AND exposure.observation_reason='flat' " \
#    -b ${REPO} \
#    -i u/abrought/BF/2023.04.28/ptc.2023.04.28.R03-S12.trunc_to_pcti,u/abrought/BF/2023.06.16/bfk.R03-S12.scalefactor-0_95,${SBIAS},${SDARK},${DEFECTS},${CTI},${LINEARITY},LSSTCam/raw/all \
#    -o u/abrought/BF/2023.06.16/ptc.R03-S12.bfcorrected.scalefactor-0_95 \
#    -p ${CONFIG}/cpPtc.yaml \
#        --config isr:connections.newBFKernel='bfk' \
#    --register-dataset-types




# END
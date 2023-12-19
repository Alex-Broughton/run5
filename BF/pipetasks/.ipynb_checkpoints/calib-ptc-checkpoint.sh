#!/bin/bash

##SBATCH --partition=rubin
#SBATCH --job-name=calib
#SBATCH --output=/sdf/home/a/abrought/run5/BF/output/out100001.txt
#SBATCH --error=/sdf/home/a/abrought/run5/BF/output/err100001.txt
#SBATCH --ntasks=5
#SBATCH --cpus-per-task=10
#SBATCH --mem-per-cpu=16G
##SBATCH --time=5:00:00
 
# used to be 

#source /cvmfs/sw.lsst.eu/linux-x86_64/lsst_distrib/w_2023_09/loadLSST-ext.bash
#setup lsst_distrib
#setup -j -r /sdf/home/a/abrought/alternate_branches/cp_pipe
#setup -j -r /sdf/home/a/abrought/alternate_branches/ip_isr

source /sdf/group/rubin/sw/tag/w_2023_29/loadLSST.bash
setup lsst_distrib -t w_2023_29
setup -t w_2023_29 -j -r /sdf/home/a/abrought/alternate_branches/dm_stack/cp_pipe
setup -t w_2023_29 -j -r /sdf/home/a/abrought/alternate_branches/dm_stack/ip_isr

export PYTHONPATH="/sdf/home/a/abrought/bin/mixcoatl/python:${PYTHONPATH}" # Needed for using gridFit
 
# Set up repositories for collections
export REPO=/repo/main
export CONFIG=/sdf/home/a/abrought/run5/BF/config2
export SBIAS=u/cslage/calib/13144/bias_20211229
export SDARK=u/cslage/calib/13144/dark_20211229
export DEFECTS=u/cslage/calib/13144/defects_20211229
export LINEARITY=u/cslage/linearizer_28jan22/20220128T174703Z
#export CTI=u/cslage/sdf/BOT/cti_test_20230106
export CTI=u/abrought/BF/2023.04.14/cti.2023.04.14


pipetask run  \
    -j 50 \
    -d "instrument='LSSTCam' AND detector IN (23) AND exposure.science_program IN ('13144')  AND exposure.observation_type = 'flat' AND exposure.observation_reason='flat' " \
    -b ${REPO} \
    -i u/abrought/BF/2023.10.09/ptc.R03-S12.trunc_to_pcti,u/abrought/BF/2023.10.09/bfk.R03-S12.final,${SBIAS},${SDARK},${DEFECTS},${CTI},${LINEARITY},LSSTCam/raw/all \
    -o u/abrought/BF/2023.10.09/ptc.R03-S12.bfcorrected.final.nonFluxConserving \
    -p ${CONFIG}/cpPtc2.yaml \
        --config isr:connections.newBFKernel='bfk' \
    --register-dataset-types
    
pipetask run  \
    -j 50 \
    -d "instrument='LSSTCam' AND detector IN (9) AND exposure.science_program IN ('13144')  AND exposure.observation_type = 'flat' AND exposure.observation_reason='flat' " \
    -b ${REPO} \
    -i u/abrought/BF/2023.07.19/ptc.R02-S00.trunc_to_pcti.fullnoisematrix,u/abrought/BF/2023.10.09/bfk.R02-S00.final,${SBIAS},${SDARK},${DEFECTS},${CTI},${LINEARITY},LSSTCam/raw/all \
    -o u/abrought/BF/2023.10.09/ptc.R02-S00.bfcorrected.final.nonFluxConserving \
    -p ${CONFIG}/cpPtc2.yaml \
        --config isr:connections.newBFKernel='bfk' \
    --register-dataset-types


# pipetask run  \
#     -j 30 \
#     -d "instrument='LSSTCam' AND detector IN (112) AND exposure.science_program IN ('13144')  AND exposure.observation_type = 'flat' AND exposure.observation_reason='flat' " \
#     -b ${REPO} \
#     -i u/abrought/BF/2023.09.15/ptc.R24-S11.trunc_to_newpcti,u/abrought/BF/2023.09.15/bfk.R24-S11.final,${SBIAS},${SDARK},${DEFECTS},${CTI},${LINEARITY},LSSTCam/raw/all \
#     -o u/abrought/BF/2023.09.15/ptc.R24-S11.bfcorrected.final.nonFluxConserving \
#     -p ${CONFIG}/cpPtc2.yaml \
#         --config isr:connections.newBFKernel='bfk' \
#     --register-dataset-types

# pipetask run  \
#     -j 30 \
#     -d "instrument='LSSTCam' AND detector IN (9) AND exposure.science_program IN ('13144')  AND exposure.observation_type = 'flat' AND exposure.observation_reason='flat' " \
#     -b ${REPO} \
#     -i u/abrought/BF/2023.07.19/ptc.R02-S00.trunc_to_pcti.fullnoisematrix,u/abrought/BF/2023.09.15/bfk.R02-S00.final,${SBIAS},${SDARK},${DEFECTS},${CTI},${LINEARITY},LSSTCam/raw/all \
#     -o u/abrought/BF/2023.09.15/ptc.R02-S00.bfcorrected.final.nonFluxConserving \
#     -p ${CONFIG}/cpPtc2.yaml \
#         --config isr:connections.newBFKernel='bfk' \
#     --register-dataset-types

# pipetask run  \
#     -j 30 \
#     -d "instrument='LSSTCam' AND detector IN (83) AND exposure.science_program IN ('13144')  AND exposure.observation_type = 'flat' AND exposure.observation_reason='flat' " \
#     -b ${REPO} \
#     -i u/abrought/BF/2023.07.19/ptc.R21-S02.trunc_to_pcti.fullnoisematrix,u/abrought/BF/2023.09.15/bfk.R21-S02.final,${SBIAS},${SDARK},${DEFECTS},${CTI},${LINEARITY},LSSTCam/raw/all \
#     -o u/abrought/BF/2023.09.15/ptc.R21-S02.bfcorrected.final.nonFluxConserving \
#     -p ${CONFIG}/cpPtc2.yaml \
#         --config isr:connections.newBFKernel='bfk' \
#     --register-dataset-types




# pipetask run  \
#     -j 30 \
#     -d "instrument='LSSTCam' AND detector IN (23) AND exposure.science_program IN ('13144')  AND exposure.observation_type = 'flat' AND exposure.observation_reason='flat' " \
#     -b ${REPO} \
#     -i u/abrought/BF/2023.09.15/ptc.R03-S12.trunc_to_newpcti,u/abrought/BF/2023.09.15/bfk.R03-S12.final,${SBIAS},${SDARK},${DEFECTS},${CTI},${LINEARITY},LSSTCam/raw/all \
#     -o u/abrought/BF/2023.09.15/ptc.R03-S12.bfcorrected.final.fluxConserving \
#     -p ${CONFIG}/cpPtc.yaml \
#         --config isr:connections.newBFKernel='bfk' \
#     --register-dataset-types

# pipetask run  \
#     -j 30 \
#     -d "instrument='LSSTCam' AND detector IN (112) AND exposure.science_program IN ('13144')  AND exposure.observation_type = 'flat' AND exposure.observation_reason='flat' " \
#     -b ${REPO} \
#     -i u/abrought/BF/2023.09.15/ptc.R24-S11.trunc_to_newpcti,u/abrought/BF/2023.09.15/bfk.R24-S11.final,${SBIAS},${SDARK},${DEFECTS},${CTI},${LINEARITY},LSSTCam/raw/all \
#     -o u/abrought/BF/2023.09.15/ptc.R24-S11.bfcorrected.final.fluxConserving \
#     -p ${CONFIG}/cpPtc.yaml \
#         --config isr:connections.newBFKernel='bfk' \
#     --register-dataset-types

# pipetask run  \
#     -j 30 \
#     -d "instrument='LSSTCam' AND detector IN (9) AND exposure.science_program IN ('13144')  AND exposure.observation_type = 'flat' AND exposure.observation_reason='flat' " \
#     -b ${REPO} \
#     -i u/abrought/BF/2023.07.19/ptc.R02-S00.trunc_to_pcti.fullnoisematrix,u/abrought/BF/2023.09.15/bfk.R02-S00.final,${SBIAS},${SDARK},${DEFECTS},${CTI},${LINEARITY},LSSTCam/raw/all \
#     -o u/abrought/BF/2023.09.15/ptc.R02-S00.bfcorrected.final.fluxConserving \
#     -p ${CONFIG}/cpPtc.yaml \
#         --config isr:connections.newBFKernel='bfk' \
#     --register-dataset-types

# pipetask run  \
#     -j 30 \
#     -d "instrument='LSSTCam' AND detector IN (83) AND exposure.science_program IN ('13144')  AND exposure.observation_type = 'flat' AND exposure.observation_reason='flat' " \
#     -b ${REPO} \
#     -i u/abrought/BF/2023.07.19/ptc.R21-S02.trunc_to_pcti.fullnoisematrix,u/abrought/BF/2023.09.15/bfk.R21-S02.final,${SBIAS},${SDARK},${DEFECTS},${CTI},${LINEARITY},LSSTCam/raw/all \
#     -o u/abrought/BF/2023.09.15/ptc.R21-S02.bfcorrected.final.fluxConserving \
#     -p ${CONFIG}/cpPtc.yaml \
#         --config isr:connections.newBFKernel='bfk' \
#     --register-dataset-types
#!/bin/bash

##SBATCH --partition=rubin
#SBATCH --job-name=calib
#SBATCH --output=/sdf/home/a/abrought/run5/BF/output/out-single.txt
#SBATCH --error=/sdf/home/a/abrought/run5/BF/output/err-single.txt
#SBATCH --ntasks=6
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
setup -t w_2023_19 -j -r /sdf/home/a/abrought/alternate_branches/chrisfixes_old_bfloadfix/cp_pipe
setup -t w_2023_19 -j -r /sdf/home/a/abrought/alternate_branches/chrisfixes_old_bfloadfix/ip_isr

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


    
pipetask run  \
    -j 30 \
    -d "instrument='LSSTCam' AND detector IN (23) AND exposure.science_program IN ('13144')  AND exposure.observation_type = 'flat' AND exposure.observation_reason='flat' " \
    -b ${REPO} \
    -i u/abrought/BF/2023.07.19/ptc.R03-S12.trunc_to_pcti.fullnoisematrix,u/abrought/BF/2023.07.19/bfk.R03-S12.final,${SBIAS},${SDARK},${DEFECTS},${CTI},${LINEARITY},LSSTCam/raw/all \
    -o u/abrought/BF/2023.06.16/ptc.R03-S12.bfcorrected.final.testerwithctigain \
    -p ${CONFIG}/cpPtc.yaml \
        --config isr:connections.newBFKernel='bfk' \
    --register-dataset-types \
    --save-qgraph /sdf/data/rubin/repo/main_20210215/u/abrought/BF/qgraph_bfloadfix.qgraph



# pipetask run  \
#     -j 30 \
#     -d "instrument='LSSTCam' AND detector IN (9) AND exposure.science_program IN ('13144')  AND exposure.observation_type = 'flat' AND exposure.observation_reason='flat' " \
#     -b ${REPO} \
#     -i u/abrought/BF/2023.04.28/ptc.2023.04.28.R02-S00.trunc_to_pcti,u/abrought/BF/2023.06.16/bfk.R02-S00.40000adu,${SBIAS},${SDARK},${DEFECTS},${CTI},${LINEARITY},LSSTCam/raw/all \
#     -o u/abrought/BF/2023.06.16/ptc.R02-S00.bfcorrected.40000adu \
#     -p ${CONFIG}/cpPtc.yaml \
#         --config isr:connections.newBFKernel='bfk' \
#     --register-dataset-types


# pipetask run  \
#     -j 30 \
#     -d "instrument='LSSTCam' AND detector IN (9) AND exposure.science_program IN ('13144')  AND exposure.observation_type = 'flat' AND exposure.observation_reason='flat' " \
#     -b ${REPO} \
#     -i u/abrought/BF/2023.04.28/ptc.2023.04.28.R02-S00.trunc_to_pcti,u/abrought/BF/2023.06.16/bfk.R02-S00.50000adu,${SBIAS},${SDARK},${DEFECTS},${CTI},${LINEARITY},LSSTCam/raw/all \
#     -o u/abrought/BF/2023.06.16/ptc.R02-S00.bfcorrected.50000adu \
#     -p ${CONFIG}/cpPtc.yaml \
#         --config isr:connections.newBFKernel='bfk' \
#     --register-dataset-types
    
# pipetask run  \
#     -j 30 \
#     -d "instrument='LSSTCam' AND detector IN (9) AND exposure.science_program IN ('13144')  AND exposure.observation_type = 'flat' AND exposure.observation_reason='flat' " \
#     -b ${REPO} \
#     -i u/abrought/BF/2023.04.28/ptc.2023.04.28.R02-S00.trunc_to_pcti,u/abrought/BF/2023.06.16/bfk.R02-S00.60000adu,${SBIAS},${SDARK},${DEFECTS},${CTI},${LINEARITY},LSSTCam/raw/all \
#     -o u/abrought/BF/2023.06.16/ptc.R02-S00.bfcorrected.60000adu \
#     -p ${CONFIG}/cpPtc.yaml \
#         --config isr:connections.newBFKernel='bfk' \
#     --register-dataset-types
    
# pipetask run  \
#     -j 30 \
#     -d "instrument='LSSTCam' AND detector IN (9) AND exposure.science_program IN ('13144')  AND exposure.observation_type = 'flat' AND exposure.observation_reason='flat' " \
#     -b ${REPO} \
#     -i u/abrought/BF/2023.04.28/ptc.2023.04.28.R02-S00.trunc_to_pcti,u/abrought/BF/2023.06.16/bfk.R02-S00.70000adu,${SBIAS},${SDARK},${DEFECTS},${CTI},${LINEARITY},LSSTCam/raw/all \
#     -o u/abrought/BF/2023.06.16/ptc.R02-S00.bfcorrected.70000adu \
#     -p ${CONFIG}/cpPtc.yaml \
#         --config isr:connections.newBFKernel='bfk' \
#     --register-dataset-types
    
# pipetask run  \
#     -j 30 \
#     -d "instrument='LSSTCam' AND detector IN (9) AND exposure.science_program IN ('13144')  AND exposure.observation_type = 'flat' AND exposure.observation_reason='flat' " \
#     -b ${REPO} \
#     -i u/abrought/BF/2023.04.28/ptc.2023.04.28.R02-S00.trunc_to_pcti,u/abrought/BF/2023.06.16/bfk.R02-S00.80000adu,${SBIAS},${SDARK},${DEFECTS},${CTI},${LINEARITY},LSSTCam/raw/all \
#     -o u/abrought/BF/2023.06.16/ptc.R02-S00.bfcorrected.80000adu \
#     -p ${CONFIG}/cpPtc.yaml \
#         --config isr:connections.newBFKernel='bfk' \
#     --register-dataset-types
    
# pipetask run  \
#     -j 30 \
#     -d "instrument='LSSTCam' AND detector IN (9) AND exposure.science_program IN ('13144')  AND exposure.observation_type = 'flat' AND exposure.observation_reason='flat' " \
#     -b ${REPO} \
#     -i u/abrought/BF/2023.04.28/ptc.2023.04.28.R02-S00.trunc_to_pcti,u/abrought/BF/2023.06.16/bfk.R02-S00.90000adu,${SBIAS},${SDARK},${DEFECTS},${CTI},${LINEARITY},LSSTCam/raw/all \
#     -o u/abrought/BF/2023.06.16/ptc.R02-S00.bfcorrected.90000adu \
#     -p ${CONFIG}/cpPtc.yaml \
#         --config isr:connections.newBFKernel='bfk' \
#     --register-dataset-types
    
# pipetask run  \
#     -j 30 \
#     -d "instrument='LSSTCam' AND detector IN (9) AND exposure.science_program IN ('13144')  AND exposure.observation_type = 'flat' AND exposure.observation_reason='flat' " \
#     -b ${REPO} \
#     -i u/abrought/BF/2023.04.28/ptc.2023.04.28.R02-S00.trunc_to_pcti,u/abrought/BF/2023.06.16/bfk.R02-S00.100000adu,${SBIAS},${SDARK},${DEFECTS},${CTI},${LINEARITY},LSSTCam/raw/all \
#     -o u/abrought/BF/2023.06.16/ptc.R02-S00.bfcorrected.100000adu \
#     -p ${CONFIG}/cpPtc.yaml \
#         --config isr:connections.newBFKernel='bfk' \
#     --register-dataset-types
    


# END

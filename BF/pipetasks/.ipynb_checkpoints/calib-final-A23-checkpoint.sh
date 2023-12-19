#!/bin/bash

##SBATCH --partition=rubin
#SBATCH --job-name=a23
#SBATCH --output=/sdf/home/a/abrought/run5/BF/output/out1000.txt
#SBATCH --error=/sdf/home/a/abrought/run5/BF/output/err1000.txt
#SBATCH --ntasks=6
#SBATCH --cpus-per-task=5
#SBATCH --mem-per-cpu=16G
##SBATCH --time=5:00:00
 
# used to be 

#source /cvmfs/sw.lsst.eu/linux-x86_64/lsst_distrib/w_2023_09/loadLSST-ext.bash
#setup lsst_distrib
#setup -j -r /sdf/home/a/abrought/alternate_branches/cp_pipe
#setup -j -r /sdf/home/a/abrought/alternate_branches/ip_isr


source /cvmfs/sw.lsst.eu/linux-x86_64/lsst_distrib/w_2023_22/loadLSST-ext.bash
setup lsst_distrib
setup -j -r /sdf/home/a/abrought/alternate_branches/andresfixes/cp_pipe
setup -j -r /sdf/home/a/abrought/alternate_branches/andresfixes/ip_isr

pip install pyfftw

export PYTHONPATH="/sdf/home/a/abrought/alternate_branches/mixcoatl/python:${PYTHONPATH}" # Needed for using gridFit
 
# Set up repositories for collections
export REPO=/repo/main
export CONFIG=/sdf/home/a/abrought/run5/BF/config
export SBIAS=u/cslage/calib/13144/bias_20211229
export SDARK=u/cslage/calib/13144/dark_20211229
export DEFECTS=u/cslage/calib/13144/defects_20211229
export LINEARITY=u/cslage/linearizer_28jan22/20220128T174703Z
#export CTI=u/cslage/sdf/BOT/cti_test_20230106
export CTI=u/abrought/BF/2023.04.14/cti.2023.04.14


pipetask run \
        -j 30 \
        -d "instrument='LSSTCam' AND detector in ( 23 ) AND exposure.observation_type='spot' AND exposure.science_program IN ('13248')" \
        -b ${REPO} \
        -i u/abrought/BF/2023.04.28/ptc.2023.04.28.R03-S12.trunc_to_pcti,u/abrought/BF/2023.05.15/bfk.2023.05.15.R03-S12.final,${SBIAS},${SDARK},${DEFECTS},${CTI},${LINEARITY},LSSTCam/raw/all \
        -o u/abrought/BF/2023.06.16/run_13248/R03-S12/corrected.A23 \
        -p ${CONFIG}/gridFit_corrected-new-a23.yaml \
            --config isr:connections.newBFKernel='bfk' \
        --register-dataset-types

pipetask run \
        -j 30 \
        -d "instrument='LSSTCam' AND detector in ( 23 ) AND exposure.observation_type='spot' AND exposure.science_program IN ('13247')" \
        -b ${REPO} \
        -i u/abrought/BF/2023.04.28/ptc.2023.04.28.R03-S12.trunc_to_pcti,u/abrought/BF/2023.05.15/bfk.2023.05.15.R03-S12.final,${SBIAS},${SDARK},${DEFECTS},${CTI},${LINEARITY},LSSTCam/raw/all \
        -o u/abrought/BF/2023.06.16/run_13247/R03-S12/corrected.A23 \
        -p ${CONFIG}/gridFit_corrected-new-a23.yaml \
            --config isr:connections.newBFKernel='bfk' \
        --register-dataset-types
        
pipetask run \
        -j 30 \
        -d "instrument='LSSTCam' AND detector in ( 112 ) AND exposure.observation_type='spot' AND exposure.science_program IN ('13251')" \
        -b ${REPO} \
        -i u/abrought/BF/2023.04.28/ptc.2023.04.28.R03-S12.trunc_to_pcti,u/abrought/BF/2023.05.15/bfk.2023.05.15.R03-S12.final,${SBIAS},${SDARK},${DEFECTS},${CTI},${LINEARITY},LSSTCam/raw/all \
        -o u/abrought/BF/2023.06.16/run_13251/R03-S12/corrected.A23 \
        -p ${CONFIG}/gridFit_corrected-new-a23.yaml \
            --config isr:connections.newBFKernel='bfk' \
        --register-dataset-types

pipetask run \
        -j 30 \
        -d "instrument='LSSTCam' AND detector in ( 112 ) AND exposure.observation_type='spot' AND exposure.science_program IN ('13252')" \
        -b ${REPO} \
        -i u/abrought/BF/2023.04.28/ptc.2023.04.28.R24-S11.trunc_to_pcti,u/abrought/BF/2023.05.15/bfk.2023.05.15.R24-S11.final,${SBIAS},${SDARK},${DEFECTS},${CTI},${LINEARITY},LSSTCam/raw/all \
        -o u/abrought/BF/2023.06.16/run_13252/R24-S11/corrected.A23 \
        -p ${CONFIG}/gridFit_corrected-new-a23.yaml \
            --config isr:connections.newBFKernel='bfk' \
        --register-dataset-types

#pipetask run  \
#    -j 30 \
#    -d "instrument='LSSTCam' AND detector IN (23) AND exposure.science_program IN ('13144')  AND exposure.observation_type = 'flat' AND exposure.observation_reason='flat' " \
#    -b ${REPO} \
#    -i u/abrought/BF/2023.04.28/ptc.2023.04.28.R03-S12.trunc_to_pcti,u/abrought/BF/2023.05.15/bfk.2023.05.15.R03-S12.final,${SBIAS},${SDARK},${DEFECTS},${CTI},${LINEARITY},LSSTCam/raw/all \
#    -o u/abrought/BF/2023.05.15/ptc.2023.05.15.R03-S12.bfcorrected.A23.v4 \
#    -p ${CONFIG}/cpPtc-A23.yaml \
#        --config isr:connections.newBFKernel='bfk' \
#    --register-dataset-types

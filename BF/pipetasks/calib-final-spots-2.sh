#!/bin/bash

##SBATCH --partition=rubin
#SBATCH --job-name=calib1
#SBATCH --output=/sdf/home/a/abrought/run5/BF/output/out2.txt
#SBATCH --error=/sdf/home/a/abrought/run5/BF/output/err2.txt
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


 
## Detectors 9, 23, 83, 112 


#pipetask run \
#        -j 30 \
#        -d "instrument='LSSTCam' AND detector in ( 112 ) AND exposure.observation_type='spot' AND exposure.science_program IN ('13251')" \
#        -b ${REPO} \
#        -i u/abrought/BF/2023.04.28/ptc.2023.04.28.R24-S11.trunc_to_pcti,u/abrought/BF/2023.05.15/bfk.2023.05.15.R24-S11.final.fixed,${SBIAS},${SDARK},${DEFECTS},${CTI},${LINEARITY},LSSTCam/raw/all \
#        -o u/abrought/BF/2023.06.06/run_13251/R24-S11/uncorrected \
#        -p ${CONFIG}/gridFit_uncorrected-new.yaml \
#            --config isr:connections.newBFKernel='bfk' \
#        --register-dataset-types

pipetask run \
        -j 30 \
        -d "instrument='LSSTCam' AND detector in ( 112 ) AND exposure.observation_type='spot' AND exposure.science_program IN ('13251')" \
        -b ${REPO} \
        -i u/abrought/BF/2023.04.28/ptc.2023.04.28.R24-S11.trunc_to_pcti,u/abrought/BF/2023.05.15/bfk.2023.05.15.R24-S11.final.fixed,${SBIAS},${SDARK},${DEFECTS},${CTI},${LINEARITY},LSSTCam/raw/all \
        -o u/abrought/BF/2023.06.06/run_13251/R24-S11/corrected.optimized_scale_factor \
        -p ${CONFIG}/gridFit_corrected-new.yaml \
            --config isr:connections.newBFKernel='bfk' \
        --register-dataset-types

pipetask run \
        -j 30 \
        -d "instrument='LSSTCam' AND detector in ( 112 ) AND exposure.observation_type='spot' AND exposure.science_program IN ('13252')" \
        -b ${REPO} \
        -i u/abrought/BF/2023.04.28/ptc.2023.04.28.R24-S11.trunc_to_pcti,u/abrought/BF/2023.05.15/bfk.2023.05.15.R24-S11.final.fixed,${SBIAS},${SDARK},${DEFECTS},${CTI},${LINEARITY},LSSTCam/raw/all \
        -o u/abrought/BF/2023.06.06/run_13252/R24-S11/corrected.optimized_scale_factor \
        -p ${CONFIG}/gridFit_corrected-new.yaml \
            --config isr:connections.newBFKernel='bfk' \
        --register-dataset-types

#pipetask run \
#        -j 30 \
#        -d "instrument='LSSTCam' AND detector in ( 112 ) AND exposure.observation_type='spot' AND exposure.science_program IN ('13251')" \
#        -b ${REPO} \
#        -i u/abrought/BF/2023.04.28/ptc.2023.04.28.R24-S11.trunc_to_pcti,u/abrought/BF/2023.05.15/bfk.2023.05.15.R24-S11.cov_model_pcti,${SBIAS},${SDARK},${DEFECTS},${CTI},${LINEARITY},LSSTCam/raw/all \
#        -o u/abrought/BF/2023.05.15/run_13251/R24-S11/corrected.cov_model_pcti \
#        -p ${CONFIG}/gridFit_corrected-new.yaml \
#            --config isr:connections.newBFKernel='bfk' \
#        --register-dataset-types
        
#pipetask run \
#        -j 30 \
#        -d "instrument='LSSTCam' AND detector in ( 112 ) AND exposure.observation_type='spot' AND exposure.science_program IN ('13251')" \
#        -b ${REPO} \
#        -i u/abrought/BF/2023.04.28/ptc.2023.04.28.R24-S11.trunc_to_ptc,u/abrought/BF/2023.05.15/bfk.2023.05.15.R24-S11.cov_model_ptc,${SBIAS},${SDARK},${DEFECTS},${CTI},${LINEARITY},LSSTCam/raw/all \
#        -o u/abrought/BF/2023.05.15/run_13251/R24-S11/corrected.cov_model_ptc \
#        -p ${CONFIG}/gridFit_corrected-new.yaml \
#            --config isr:connections.newBFKernel='bfk' \
#        --register-dataset-types

#pipetask run \
#        -j 30 \
#        -d "instrument='LSSTCam' AND detector in ( 112 ) AND exposure.observation_type='spot' AND exposure.science_program IN ('13252')" \
#        -b ${REPO} \
#        -i u/abrought/BF/2023.04.28/ptc.2023.04.28.R24-S11.trunc_to_pcti,u/abrought/BF/2023.05.15/bfk.2023.05.15.R24-S11.final.fixed,${SBIAS},${SDARK},${DEFECTS},${CTI},${LINEARITY},LSSTCam/raw/all \
#        -o u/abrought/BF/2023.06.06/run_13252/R24-S11/uncorrected \
#        -p ${CONFIG}/gridFit_uncorrected-new.yaml \
#            --config isr:connections.newBFKernel='bfk' \
#        --register-dataset-types

#pipetask run \
#        -j 30 \
#        -d "instrument='LSSTCam' AND detector in ( 112 ) AND exposure.observation_type='spot' AND exposure.science_program IN ('13252')" \
#        -b ${REPO} \
#        -i u/abrought/BF/2023.04.28/ptc.2023.04.28.R24-S11.trunc_to_pcti,u/abrought/BF/2023.05.15/bfk.2023.05.15.R24-S11.final,${SBIAS},${SDARK},${DEFECTS},${CTI},${LINEARITY},LSSTCam/raw/all \
#        -o u/abrought/BF/2023.05.15/run_13252/R24-S11/corrected.optimized_scale_factor \
#        -p ${CONFIG}/gridFit_corrected-new.yaml \
#            --config isr:connections.newBFKernel='bfk' \
#        --register-dataset-types

#pipetask run \
#        -j 30 \
#        -d "instrument='LSSTCam' AND detector in ( 112 ) AND exposure.observation_type='spot' AND exposure.science_program IN ('13252')" \
#        -b ${REPO} \
#        -i u/abrought/BF/2023.04.28/ptc.2023.04.28.R24-S11.trunc_to_pcti,u/abrought/BF/2023.05.15/bfk.2023.05.15.R24-S11.cov_model_pcti,${SBIAS},${SDARK},${DEFECTS},${CTI},${LINEARITY},LSSTCam/raw/all \
#        -o u/abrought/BF/2023.05.15/run_13252/R24-S11/corrected.cov_model_pcti \
#        -p ${CONFIG}/gridFit_corrected-new.yaml \
#            --config isr:connections.newBFKernel='bfk' \
#        --register-dataset-types

#pipetask run \
#        -j 30 \
#        -d "instrument='LSSTCam' AND detector in ( 112 ) AND exposure.observation_type='spot' AND exposure.science_program IN ('13252')" \
#        -b ${REPO} \
#        -i u/abrought/BF/2023.04.28/ptc.2023.04.28.R24-S11.trunc_to_ptc,u/abrought/BF/2023.05.15/bfk.2023.05.15.R24-S11.cov_model_ptc,${SBIAS},${SDARK},${DEFECTS},${CTI},${LINEARITY},LSSTCam/raw/all \
#        -o u/abrought/BF/2023.05.15/run_13252/R24-S11/corrected.cov_model_ptc \
#        -p ${CONFIG}/gridFit_corrected-new.yaml \
#            --config isr:connections.newBFKernel='bfk' \
#        --register-dataset-types
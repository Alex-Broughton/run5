#!/bin/bash

##SBATCH --partition=rubin
#SBATCH --job-name=calib
#SBATCH --output=/sdf/home/a/abrought/run5/BF/output/out326.txt
#SBATCH --error=/sdf/home/a/abrought/run5/BF/output/err326.txt
#SBATCH --ntasks=6
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

## Generate BFK Kernels


# R24-S11

pipetask run \
       -j 25 \
       -d "instrument='LSSTCam' AND exposure IN (3021120600576) AND detector IN (112)" \
       -b ${REPO} \
       -i u/abrought/BF/2023.07.19/ptc.R24-S11.trunc_to_pcti.fullnoisematrix,${SBIAS},${SDARK},${DEFECTS},${LINEARITY},${CTI} \
       -o u/abrought/BF/2023.07.19/bfk.R24-S11.10000adu.zersumoff \
       -p ${CONFIG}/cpBfkSolve-10000-R24-S11.yaml \
       --register-dataset-types

pipetask run \
       -j 25 \
       -d "instrument='LSSTCam' AND exposure IN (3021120600576) AND detector IN (112)" \
       -b ${REPO} \
       -i u/abrought/BF/2023.07.19/ptc.R24-S11.trunc_to_pcti.fullnoisematrix,${SBIAS},${SDARK},${DEFECTS},${LINEARITY},${CTI} \
       -o u/abrought/BF/2023.07.19/bfk.R24-S11.20000adu.zersumoff \
       -p ${CONFIG}/cpBfkSolve-20000-R24-S11.yaml \
       --register-dataset-types

pipetask run \
       -j 25 \
       -d "instrument='LSSTCam' AND exposure IN (3021120600576) AND detector IN (112)" \
       -b ${REPO} \
       -i u/abrought/BF/2023.07.19/ptc.R24-S11.trunc_to_pcti.fullnoisematrix,${SBIAS},${SDARK},${DEFECTS},${LINEARITY},${CTI} \
       -o u/abrought/BF/2023.07.19/bfk.R24-S11.30000adu.zersumoff \
       -p ${CONFIG}/cpBfkSolve-30000-R24-S11.yaml \
       --register-dataset-types

pipetask run \
       -j 25 \
       -d "instrument='LSSTCam' AND exposure IN (3021120600576) AND detector IN (112)" \
       -b ${REPO} \
       -i u/abrought/BF/2023.07.19/ptc.R24-S11.trunc_to_pcti.fullnoisematrix,${SBIAS},${SDARK},${DEFECTS},${LINEARITY},${CTI} \
       -o u/abrought/BF/2023.07.19/bfk.R24-S11.40000adu.zersumoff \
       -p ${CONFIG}/cpBfkSolve-40000-R24-S11.yaml \
       --register-dataset-types

pipetask run \
       -j 25 \
       -d "instrument='LSSTCam' AND exposure IN (3021120600576) AND detector IN (112)" \
       -b ${REPO} \
       -i u/abrought/BF/2023.07.19/ptc.R24-S11.trunc_to_pcti.fullnoisematrix,${SBIAS},${SDARK},${DEFECTS},${LINEARITY},${CTI} \
       -o u/abrought/BF/2023.07.19/bfk.R24-S11.50000adu.zersumoff \
       -p ${CONFIG}/cpBfkSolve-50000-R24-S11.yaml \
       --register-dataset-types
       
pipetask run \
       -j 25 \
       -d "instrument='LSSTCam' AND exposure IN (3021120600576) AND detector IN (112)" \
       -b ${REPO} \
       -i u/abrought/BF/2023.07.19/ptc.R24-S11.trunc_to_pcti.fullnoisematrix,${SBIAS},${SDARK},${DEFECTS},${LINEARITY},${CTI} \
       -o u/abrought/BF/2023.07.19/bfk.R24-S11.60000adu.zersumoff \
       -p ${CONFIG}/cpBfkSolve-60000-R24-S11.yaml \
       --register-dataset-types
       
pipetask run \
       -j 25 \
       -d "instrument='LSSTCam' AND exposure IN (3021120600576) AND detector IN (112)" \
       -b ${REPO} \
       -i u/abrought/BF/2023.07.19/ptc.R24-S11.trunc_to_pcti.fullnoisematrix,${SBIAS},${SDARK},${DEFECTS},${LINEARITY},${CTI} \
       -o u/abrought/BF/2023.07.19/bfk.R24-S11.70000adu.zersumoff \
       -p ${CONFIG}/cpBfkSolve-70000-R24-S11.yaml \
       --register-dataset-types
       
pipetask run \
       -j 25 \
       -d "instrument='LSSTCam' AND exposure IN (3021120600576) AND detector IN (112)" \
       -b ${REPO} \
       -i u/abrought/BF/2023.07.19/ptc.R24-S11.trunc_to_pcti.fullnoisematrix,${SBIAS},${SDARK},${DEFECTS},${LINEARITY},${CTI} \
       -o u/abrought/BF/2023.07.19/bfk.R24-S11.80000adu.zersumoff \
       -p ${CONFIG}/cpBfkSolve-80000-R24-S11.yaml \
       --register-dataset-types
       
# pipetask run \
#        -j 25 \
#        -d "instrument='LSSTCam' AND exposure IN (3021120600576) AND detector IN (112)" \
#        -b ${REPO} \
#        -i u/abrought/BF/2023.07.19/ptc.R24-S11.trunc_to_pcti.fullnoisematrix,${SBIAS},${SDARK},${DEFECTS},${LINEARITY},${CTI} \
#        -o u/abrought/BF/2023.07.19/bfk.R24-S11.90000adu \
#        -p ${CONFIG}/cpBfkSolve-90000-R24-S11.yaml \
#        --register-dataset-types
       
# pipetask run \
#        -j 25 \
#        -d "instrument='LSSTCam' AND exposure IN (3021120600576) AND detector IN (112)" \
#        -b ${REPO} \
#        -i u/abrought/BF/2023.07.19/ptc.R24-S11.trunc_to_pcti.fullnoisematrix,${SBIAS},${SDARK},${DEFECTS},${LINEARITY},${CTI} \
#        -o u/abrought/BF/2023.07.19/bfk.R24-S11.100000adu \
#        -p ${CONFIG}/cpBfkSolve-100000-R24-S11.yaml \
#        --register-dataset-types
       


# END

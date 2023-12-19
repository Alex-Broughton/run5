#!/bin/bash

##SBATCH --partition=rubin
#SBATCH --job-name=calib
#SBATCH --output=/sdf/home/a/abrought/run5/BF/output/out8327.txt
#SBATCH --error=/sdf/home/a/abrought/run5/BF/output/err8327.txt
#SBATCH --ntasks=5
#SBATCH --cpus-per-task=1
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
export CONFIG=/sdf/home/a/abrought/run5/BF/config2
export SBIAS=u/cslage/calib/13144/bias_20211229
export SDARK=u/cslage/calib/13144/dark_20211229
export DEFECTS=u/cslage/calib/13144/defects_20211229
export LINEARITY=u/cslage/linearizer_28jan22/20220128T174703Z
#export CTI=u/cslage/sdf/BOT/cti_test_20230106
export CTI=u/abrought/BF/2023.04.14/cti.2023.04.14

## Generate BFK Kernels


# R03-S12
pipetask run \
       -j 25 \
       -d "instrument='LSSTCam' AND exposure IN (3021120600576) AND detector IN (23)" \
       -b ${REPO} \
       -i u/abrought/BF/2023.04.28/ptc.2023.04.28.R03-S12.trunc_to_pcti,${SBIAS},${SDARK},${DEFECTS},${LINEARITY},${CTI} \
       -o u/abrought/BF/2023.06.16/bfk.R03-S12.scalefactor-0_6 \
       -p ${CONFIG}/cpBfkSolve-R03-S12-0_6.yaml \
       --register-dataset-types

# pipetask run \
#        -j 25 \
#        -d "instrument='LSSTCam' AND exposure IN (3021120600576) AND detector IN (23)" \
#        -b ${REPO} \
#        -i u/abrought/BF/2023.04.28/ptc.2023.04.28.R03-S12.trunc_to_pcti,${SBIAS},${SDARK},${DEFECTS},${LINEARITY},${CTI} \
#        -o u/abrought/BF/2023.06.16/bfk.R03-S12.scalefactor-0_65 \
#        -p ${CONFIG}/cpBfkSolve-R03-S12-0_65.yaml \
#        --register-dataset-types

# pipetask run \
#        -j 25 \
#        -d "instrument='LSSTCam' AND exposure IN (3021120600576) AND detector IN (23)" \
#        -b ${REPO} \
#        -i u/abrought/BF/2023.04.28/ptc.2023.04.28.R03-S12.trunc_to_pcti,${SBIAS},${SDARK},${DEFECTS},${LINEARITY},${CTI} \
#        -o u/abrought/BF/2023.06.16/bfk.R03-S12.scalefactor-0_675 \
#        -p ${CONFIG}/cpBfkSolve-R03-S12-0_675.yaml \
#        --register-dataset-types
       
pipetask run \
        -j 25 \
        -d "instrument='LSSTCam' AND exposure IN (3021120600576) AND detector IN (23)" \
        -b ${REPO} \
        -i u/abrought/BF/2023.04.28/ptc.2023.04.28.R03-S12.trunc_to_pcti,${SBIAS},${SDARK},${DEFECTS},${LINEARITY},${CTI} \
        -o u/abrought/BF/2023.06.16/bfk.R03-S12.scalefactor-0_7 \
        -p ${CONFIG}/cpBfkSolve-R03-S12-0_7.yaml \
        --register-dataset-types
       
# pipetask run \
#        -j 25 \
#        -d "instrument='LSSTCam' AND exposure IN (3021120600576) AND detector IN (23)" \
#        -b ${REPO} \
#        -i u/abrought/BF/2023.04.28/ptc.2023.04.28.R03-S12.trunc_to_pcti,${SBIAS},${SDARK},${DEFECTS},${LINEARITY},${CTI} \
#        -o u/abrought/BF/2023.06.16/bfk.R03-S12.scalefactor-0_725 \
#        -p ${CONFIG}/cpBfkSolve-R03-S12-0_725.yaml \
#        --register-dataset-types
       
# pipetask run \
#        -j 25 \
#        -d "instrument='LSSTCam' AND exposure IN (3021120600576) AND detector IN (23)" \
#        -b ${REPO} \
#        -i u/abrought/BF/2023.04.28/ptc.2023.04.28.R03-S12.trunc_to_pcti,${SBIAS},${SDARK},${DEFECTS},${LINEARITY},${CTI} \
#        -o u/abrought/BF/2023.06.16/bfk.R03-S12.scalefactor-0_75 \
#        -p ${CONFIG}/cpBfkSolve-R03-S12-0_75.yaml \
#        --register-dataset-types
       
# pipetask run \
#        -j 25 \
#        -d "instrument='LSSTCam' AND exposure IN (3021120600576) AND detector IN (23)" \
#        -b ${REPO} \
#        -i u/abrought/BF/2023.04.28/ptc.2023.04.28.R03-S12.trunc_to_pcti,${SBIAS},${SDARK},${DEFECTS},${LINEARITY},${CTI} \
#        -o u/abrought/BF/2023.06.16/bfk.R03-S12.scalefactor-0_775 \
#        -p ${CONFIG}/cpBfkSolve-R03-S12-0_775.yaml \
#        --register-dataset-types
       
pipetask run \
       -j 25 \
       -d "instrument='LSSTCam' AND exposure IN (3021120600576) AND detector IN (23)" \
       -b ${REPO} \
       -i u/abrought/BF/2023.04.28/ptc.2023.04.28.R03-S12.trunc_to_pcti,${SBIAS},${SDARK},${DEFECTS},${LINEARITY},${CTI} \
       -o u/abrought/BF/2023.06.16/bfk.R03-S12.scalefactor-0_8 \
       -p ${CONFIG}/cpBfkSolve-R03-S12-0_8.yaml \
       --register-dataset-types

# pipetask run \
#        -j 25 \
#        -d "instrument='LSSTCam' AND exposure IN (3021120600576) AND detector IN (23)" \
#        -b ${REPO} \
#        -i u/abrought/BF/2023.04.28/ptc.2023.04.28.R03-S12.trunc_to_pcti,${SBIAS},${SDARK},${DEFECTS},${LINEARITY},${CTI} \
#        -o u/abrought/BF/2023.06.16/bfk.R03-S12.scalefactor-0_825 \
#        -p ${CONFIG}/cpBfkSolve-R03-S12-0_825.yaml \
#        --register-dataset-types

# pipetask run \
#        -j 25 \
#        -d "instrument='LSSTCam' AND exposure IN (3021120600576) AND detector IN (23)" \
#        -b ${REPO} \
#        -i u/abrought/BF/2023.04.28/ptc.2023.04.28.R03-S12.trunc_to_pcti,${SBIAS},${SDARK},${DEFECTS},${LINEARITY},${CTI} \
#        -o u/abrought/BF/2023.06.16/bfk.R03-S12.scalefactor-0_85 \
#        -p ${CONFIG}/cpBfkSolve-R03-S12-0_85.yaml \
#        --register-dataset-types

# pipetask run \
#        -j 25 \
#        -d "instrument='LSSTCam' AND exposure IN (3021120600576) AND detector IN (23)" \
#        -b ${REPO} \
#        -i u/abrought/BF/2023.04.28/ptc.2023.04.28.R03-S12.trunc_to_pcti,${SBIAS},${SDARK},${DEFECTS},${LINEARITY},${CTI} \
#        -o u/abrought/BF/2023.06.16/bfk.R03-S12.scalefactor-0_875 \
#        -p ${CONFIG}/cpBfkSolve-R03-S12-0_875.yaml \
#        --register-dataset-types

pipetask run \
       -j 25 \
       -d "instrument='LSSTCam' AND exposure IN (3021120600576) AND detector IN (23)" \
       -b ${REPO} \
       -i u/abrought/BF/2023.04.28/ptc.2023.04.28.R03-S12.trunc_to_pcti,${SBIAS},${SDARK},${DEFECTS},${LINEARITY},${CTI} \
       -o u/abrought/BF/2023.06.16/bfk.R03-S12.scalefactor-0_9 \
       -p ${CONFIG}/cpBfkSolve-R03-S12-0_9.yaml \
       --register-dataset-types

# pipetask run \
#        -j 25 \
#        -d "instrument='LSSTCam' AND exposure IN (3021120600576) AND detector IN (23)" \
#        -b ${REPO} \
#        -i u/abrought/BF/2023.04.28/ptc.2023.04.28.R03-S12.trunc_to_pcti,${SBIAS},${SDARK},${DEFECTS},${LINEARITY},${CTI} \
#        -o u/abrought/BF/2023.06.16/bfk.R03-S12.scalefactor-0_925 \
#        -p ${CONFIG}/cpBfkSolve-R03-S12-0_925.yaml \
#        --register-dataset-types
       
# pipetask run \
#        -j 25 \
#        -d "instrument='LSSTCam' AND exposure IN (3021120600576) AND detector IN (23)" \
#        -b ${REPO} \
#        -i u/abrought/BF/2023.04.28/ptc.2023.04.28.R03-S12.trunc_to_pcti,${SBIAS},${SDARK},${DEFECTS},${LINEARITY},${CTI} \
#        -o u/abrought/BF/2023.06.16/bfk.R03-S12.scalefactor-0_95 \
#        -p ${CONFIG}/cpBfkSolve-R03-S12-0_95.yaml \
#        --register-dataset-types
# END

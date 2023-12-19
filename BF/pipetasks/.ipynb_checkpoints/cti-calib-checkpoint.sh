#!/bin/bash

##SBATCH --partition=rubin
#SBATCH --job-name=calib
#SBATCH --output=/sdf/home/a/abrought/run5/BF/output/out.txt
#SBATCH --error=/sdf/home/a/abrought/run5/BF/output/err.txt
#SBATCH --ntasks=6
#SBATCH --cpus-per-task=5
#SBATCH --mem-per-cpu=16G
##SBATCH --time=5:00:00
 
# used to be 

#source /cvmfs/sw.lsst.eu/linux-x86_64/lsst_distrib/w_2023_09/loadLSST-ext.bash
#setup lsst_distrib
#setup -j -r /sdf/home/a/abrought/alternate_branches/cp_pipe
#setup -j -r /sdf/home/a/abrought/alternate_branches/ip_isr


##source /cvmfs/sw.lsst.eu/linux-x86_64/lsst_distrib/w_2023_19/loadLSST-ext.bash
##setup lsst_distrib
##setup -j -r /sdf/home/a/abrought/alternate_branches/chrisfixes/cp_pipe
##setup -j -r /sdf/home/a/abrought/alternate_branches/chrisfixes/ip_isr

source /sdf/group/rubin/sw/tag/w_2023_19/loadLSST.bash
setup lsst_distrib -t w_2023_19
setup -t w_2023_19 -j -r /sdf/home/a/abrought/alternate_branches/chrisfixes/cp_pipe
setup -t w_2023_19 -j -r /sdf/home/a/abrought/alternate_branches/chrisfixes/ip_isr

#source /cvmfs/sw.lsst.eu/linux-x86_64/lsst_distrib/w_2023_19/loadLSST-ext.bash
#setup lsst_distrib
#setup -j -r /sdf/home/a/abrought/alternate_branches/chrisfixes/cp_pipe
#setup -j -r /sdf/home/a/abrought/alternate_branches/chrisfixes/ip_isr

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

 

pipetask run \
     -j 32 \
     -d "detector IN (9,23,83,112) AND instrument='LSSTCam' AND exposure IN (3021120600575..3021120700825) AND exposure.observation_type='flat'" \
     -b /sdf/group/rubin/repo/main \
     -i LSSTCam/raw/all,LSSTCam/calib,u/cslage/calib/13144/calib.20220107 \
     -o u/abrought/BF/2023.04.14/cti.2023.04.14 \
     -p ${CONFIG}/cpDeferredCharge.yaml \
     -c isr:doApplyGains=False \
     --register-dataset-types
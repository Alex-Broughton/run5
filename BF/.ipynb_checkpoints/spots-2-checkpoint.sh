#!/bin/bash
 
#SBATCH --partition=rubin
#
#SBATCH --job-name=spot2
#SBATCH --output=/sdf/home/a/abrought/run5/BF/output/spotout2.txt
#SBATCH --error=/sdf/home/a/abrought/run5/BF/output/spoterr2.txt
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=20
#SBATCH --mem-per-cpu=16G
#SBATCH --time=24:00:00
 
export REPO=/sdf/group/lsst/camera/IandT/repo_gen3/BOT_data/

source /cvmfs/sw.lsst.eu/linux-x86_64/lsst_distrib/w_2021_52/loadLSST.bash
setup lsst_distrib
setup -r /sdf/home/j/jchiang/dev/daf_butler -j
setup -j -r /sdf/home/a/abrought/cp_pipe
export superbias=u/abrought/BF/run_13141/sbias
export PYTHONPATH="/sdf/home/a/abrought/bin/mixcoatl/python:${PYTHONPATH}"


#pipetask run \
#    -j 15 \
#    -d "instrument='LSSTCam' AND exposure.science_program IN ('13141') AND detector in (9, 23, 31, 112, 136) AND exposure.observation_type = 'bias' " \
#    -b /sdf/group/lsst/camera/IandT/repo_gen3/BOT_data/butler.yaml \
#    -i LSSTCam/raw/all,LSSTCam/calib \
#    -o u/abrought/BF/run_13141/sbias \
#    -p /sdf/home/a/abrought/yaml/cpBias.yaml \
#    --register-dataset-types

#butler certify-calibrations /sdf/group/lsst/camera/IandT/repo_gen3/BOT_data/ u/abrought/run_13141/sbias u/abrought/run_13141/calib bias

#pipetask run \
#    -j 15 \
#    -d "instrument='LSSTCam' AND exposure.science_program IN ('13141') AND detector in (9, 23, 31, 112, 136) AND exposure.observation_type = 'flat' AND exposure.observation_reason='sflat' " \
#    -b /sdf/group/lsst/camera/IandT/repo_gen3/BOT_data/butler.yaml \
#    -i LSSTCam/raw/all,LSSTCam/calib,${superbias} \
#    -o u/abrought/BF/run_13141/sflat \
#    -p /sdf/home/a/abrought/yaml/cpFlat.yaml \
#    --register-dataset-types

#butler certify-calibrations /sdf/group/lsst/camera/IandT/repo_gen3/BOT_data/ u/abrought/run_13141/sflat u/abrought/run_13141/calib flat

pipetask run \
    -j 20 \
    -d "instrument='LSSTCam' AND exposure.science_program IN ('13141') AND detector in (9, 23, 31, 112, 136) AND exposure.observation_type = 'flat' AND exposure.observation_reason='sflat' " \
    -b /sdf/group/lsst/camera/IandT/repo_gen3/BOT_data/butler.yaml \
    -i LSSTCam/raw/all,LSSTCam/calib,${superbias} \
    -o u/abrought/BF/run_13141/defects \
    -p /sdf/home/a/abrought/yaml/findDefects.yaml \
    --register-dataset-types

#butler certify-calibrations /sdf/group/lsst/camera/IandT/repo_gen3/BOT_data/ u/abrought/run_13141/defects u/abrought/run_13141/calib defects

#! pipetask run \
#    -b /sdf/group/lsst/camera/IandT/repo_gen3/BOT_data/butler.yaml \
#    -i LSSTCam/raw/all,LSSTCam/calib,u/abrought/run_13141/calib \
#    -d "instrument='LSSTCam' AND exposure.observation_type='dark' and  exposure.science_program IN ('13162')" \
#    -o u/abrought/run_13162/sdark \
#    -p /sdf/home/a/abrought/yaml/cpDark.yaml \
#    --register-dataset-types \
#    -j 10

# butler certify-calibrations /sdf/group/lsst/camera/IandT/repo_gen3/BOT_data/ u/abrought/run_13162/sdark u/abrought/run_13162/calib dark

#pipetask run  \
#    -j 10 \
#    -d "instrument='LSSTCam' AND detector IN (9) AND exposure.science_program IN ('13144')  AND exposure.observation_type = 'flat' AND exposure.observation_reason='flat' " \
#    -b /sdf/group/lsst/camera/IandT/repo_gen3/BOT_data/butler.yaml \
#    -i LSSTCam/raw/all,LSSTCam/calib,u/abrought/run_13141/calib \
#    -o u/abrought/Run_13144/ptcs \
#    -p /sdf/home/a/abrought/yaml/measurePhotonTransferCurve.yaml \
#         -c ptcSolve:ptcFitType=EXPAPPROXIMATION \
#    --register-dataset-types

#butler certify-calibrations /sdf/group/lsst/camera/IandT/repo_gen3/BOT_data/ u/abrought/RUN_13137/ptcs u/abrought/RUN_13137/calib ptc

# Generate BF Kernels
# You must only specify one exposure at a time, I selected the first in the sequence. This generated the kernel for the given detectors.
#pipetask run \
#       -j 10 \
#       -d "instrument='LSSTCam' AND exposure IN (3021120600576) AND detector in (9) " \
#       -b /sdf/group/lsst/camera/IandT/repo_gen3/BOT_data/butler.yaml \
#       -i LSSTCam/raw/all,LSSTCam/calib,u/abrought/run_13141/calib,u/abrought/Run_13144/ptcs,u/abrought/run_13162/calib  \
#       -o u/abrought/run_13144_updated/bfks \
#       -p /sdf/home/a/abrought/yaml/cpBfkSolve.yaml \
#       --register-dataset-types

#butler certify-calibrations /sdf/group/lsst/camera/IandT/repo_gen3/BOT_data/ u/abrought/run_craig_13144/bfkss u/abrought/run_craig_13144/calib bfk

#Run the IsrTask + mixcoatl tasks
#pipetask run \
#        -j 10 \
#        -d "instrument='LSSTCam' AND detector in ( 9 ) AND exposure.observation_type='spot' AND exposure.science_program IN ( '13230')" \
#        -b /sdf/group/lsst/camera/IandT/repo_gen3/BOT_data/butler.yaml \
#        -i LSSTCam/raw/all,LSSTCam/calib,u/abrought/RUN_13141/sbias,u/abrought/run_13144_updated/bfks,u/abrought/Run_13144/ptcs \
#        -o u/abrought/run_13230/R02_S00/corrected6 \
#        -p /sdf/home/a/abrought/yaml/gridFit.yaml \
#        --register-dataset-types


#
#
#END

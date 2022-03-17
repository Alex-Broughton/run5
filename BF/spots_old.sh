#!/bin/bash
 
#SBATCH --partition=rubin
#
#SBATCH --job-name=spot
#SBATCH --output=/sdf/home/a/abrought/run5/BF/output/spotout.txt
#SBATCH --error=/sdf/home/a/abrought/run5/BF/output/spoterr.txt
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=25
#SBATCH --mem-per-cpu=16G
#SBATCH --time=24:00:00

source /cvmfs/sw.lsst.eu/linux-x86_64/lsst_distrib/w_2022_11/loadLSST.bash
setup lsst_distrib
#setup -r /sdf/home/j/jchiang/dev/daf_butler -j
setup -j -r /sdf/home/a/abrought/cp_pipe

export REPO=/sdf/group/lsst/camera/IandT/repo_gen3/BOT_data
export superbias=u/abrought/BF/run_13141/sbias
export superflat=u/abrought/BF/run_13141/sflat
export defects=u/abrought/BF/run_13141/defects
export superdark=u/abrought/BF/run_13162/sdark
export linearity=u/abrought/BF/run_13144/linearity
export ptcs=u/abrought/BF/run_13144/ptcs
export ptcs_linearized=u/abrought/BF/run_13144/ptcs_linearized
export bfks=u/abrought/BF/run_13144/bfks2
export bfks_linearized=u/abrought/BF/run_13144/bfks_linearized
export PYTHONPATH="/sdf/home/a/abrought/bin/mixcoatl/python:${PYTHONPATH}"


#pipetask run \
#    -j 15 \
#    -d "instrument='LSSTCam' AND exposure.science_program IN ('13141') AND detector in (9, 23, 31, 112, 136) AND exposure.observation_type = 'bias' " \
#    -b /sdf/group/lsst/camera/IandT/repo_gen3/BOT_data/butler.yaml \
#    -i LSSTCam/raw/all,LSSTCam/calib \
#    -o u/abrought/BF/run_13141/sbias \
#    -p /sdf/home/a/abrought/yaml/cpBias.yaml \
#    --register-dataset-types

#butler certify-calibrations /sdf/group/lsst/camera/IandT/repo_gen3/BOT_data/ u/abrought/BF/run_13141/sbias u/abrought/BF/run_13141/calib bias

#pipetask run \
#    -j 15 \
#    -d "instrument='LSSTCam' AND exposure.science_program IN ('13141') AND detector in (9, 23, 31, 112, 136) AND exposure.observation_type = 'flat' AND exposure.observation_reason='sflat' " \
#    -b /sdf/group/lsst/camera/IandT/repo_gen3/BOT_data/butler.yaml \
#    -i LSSTCam/raw/all,LSSTCam/calib,${superbias} \
#    -o u/abrought/BF/run_13141/sflat \
#    -p /sdf/home/a/abrought/yaml/cpFlat.yaml \
#    --register-dataset-types

#butler certify-calibrations /sdf/group/lsst/camera/IandT/repo_gen3/BOT_data/ u/abrought/BF/run_13141/sflat u/abrought/BF/run_13141/calib flat

#pipetask run \
#    -j 20 \
#    -d "instrument='LSSTCam' AND exposure.science_program IN ('13141') AND detector in (9, 23, 31, 112, 136) AND exposure.observation_type = 'flat' AND exposure.observation_reason='sflat' " \
#    -b /sdf/group/lsst/camera/IandT/repo_gen3/BOT_data/butler.yaml \
#    -i LSSTCam/raw/all,LSSTCam/calib,${superbias} \
#    -o u/abrought/BF/run_13141/defects \
#    -p /sdf/home/a/abrought/yaml/findDefects.yaml \
#    --register-dataset-types

#butler certify-calibrations /sdf/group/lsst/camera/IandT/repo_gen3/BOT_data/ u/abrought/BF/run_13141/defects u/abrought/BF/run_13141/calib defects

#pipetask run \
#    -j 10 \
#    -d "instrument='LSSTCam' AND exposure.observation_type='dark' AND detector in (9, 23, 31, 112, 136) AND exposure.science_program IN ('13162')" \
#    -b /sdf/group/lsst/camera/IandT/repo_gen3/BOT_data/butler.yaml \
#    -i LSSTCam/raw/all,LSSTCam/calib,${superbias},${defects} \
#    -o u/abrought/BF/run_13162/sdark \
#    -p /sdf/home/a/abrought/yaml/cpDark.yaml \
#    --register-dataset-types

#    --replace-run \
#    --prune-replaced purge \

# butler certify-calibrations /sdf/group/lsst/camera/IandT/repo_gen3/BOT_data/ u/abrought/BF/run_13162/sdark u/abrought/BF/run_13162/calib dark

#pipetask run  \
#    -j 25 \
#    -d "instrument='LSSTCam' AND detector IN (9, 23, 31, 112, 136) AND exposure.science_program IN ('13144')  AND exposure.observation_type = 'flat' AND exposure.observation_reason='flat' " \
#    -b /sdf/group/lsst/camera/IandT/repo_gen3/BOT_data/butler.yaml \
#    -i LSSTCam/raw/all,LSSTCam/calib,${superbias},${superdark},${linearity} \
#    -o u/abrought/BF/run_13144/ptcs_linearized \
#    -p /sdf/home/a/abrought/yaml/measurePhotonTransferCurve.yaml \
#         -c ptcSolve:ptcFitType=EXPAPPROXIMATION \
#    --register-dataset-types
    
#cp /sdf/home/a/abrought/yaml/measurePhotonTransferCurve.yaml ${REPO}/u/abrought/BF/run_13144/ptcs_linearized
#butler certify-calibrations /sdf/group/lsst/camera/IandT/repo_gen3/BOT_data/ u/abrought/RUN_13137/ptcs u/abrought/RUN_13137/calib ptc

#pipetask run  \
#      -j 10 \
#      -d "instrument='LSSTCam' AND exposure IN (3021120600576) AND detector in (9, 23, 31, 112, 136) AND exposure.science_program IN ('13144')" \
#      -b /sdf/group/lsst/camera/IandT/repo_gen3/BOT_data/butler.yaml \
#      -i LSSTCam/raw/all,LSSTCam/calib,${superbias},${superflat},${defects},${ptcs} \
#      -o u/abrought/BF/run_13144/linearity \
#      -p /sdf/home/a/abrought/yaml/cpLinearityCorrected.yaml \
#      --register-dataset-types

#cp /sdf/home/a/abrought/yaml/cpLinearityCorrected.yaml ${REPO}/u/abrought/BF/run_13144/linearity
# Run PTC task again after linearizer

# Generate BF Kernels
# You must only specify one exposure at a time, I selected the first in the sequence. This generated the kernel for the given detectors.
#pipetask run \
#       -j 10 \
#       -d "instrument='LSSTCam' AND exposure IN (3021120600576) AND detector in (23) " \
#       -b /sdf/group/lsst/camera/IandT/repo_gen3/BOT_data/butler.yaml \
#       -i LSSTCam/raw/all,LSSTCam/calib,${superbias},${superdark},${superflat},${defects},${ptcs_linearized}  \
#       -o u/abrought/BF/run_13144/bfks_linearized \
#       -p /sdf/home/a/abrought/yaml/cpBfkSolve.yaml \
#       --register-dataset-types
       
#cp /sdf/home/a/abrought/yaml/cpBfkSolve.yaml ${REPO}/u/abrought/BF/run_13144/bfks_linearized
#butler certify-calibrations /sdf/group/lsst/camera/IandT/repo_gen3/BOT_data/ u/abrought/run_craig_13144/bfkss u/abrought/run_craig_13144/calib bfk

#Run the IsrTask + mixcoatl tasks
pipetask run \
        -j 25 \
        -d "instrument='LSSTCam' AND detector in ( 23 ) AND exposure.observation_type='spot' AND exposure.science_program IN ( '13232')" \
        -b /sdf/group/lsst/camera/IandT/repo_gen3/BOT_data/butler.yaml \
        -i LSSTCam/raw/all,LSSTCam/calib,${superbias},${superdark},${superflat},${defects},${linearities},${ptcs_linearized},${bfks_linearized} \
        -o u/abrought/BF/run_13232/R03_S12/corrected_linearized \
        -p /sdf/home/a/abrought/yaml/gridFit.yaml \
        --register-dataset-types

cp /sdf/home/a/abrought/yaml/gridFit.yaml ${REPO}/u/abrought/BF/run_13232/R03_S12/corrected_linearized
#
#
#END

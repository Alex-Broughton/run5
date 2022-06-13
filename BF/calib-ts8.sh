#!/bin/bash

#SBATCH --partition=rubin
#SBATCH --job-name=spot_calib
#SBATCH --output=/sdf/home/a/abrought/run5/BF/output/spotcalibout.txt
#SBATCH --error=/sdf/home/a/abrought/run5/BF/output/spotcaliberr.txt
#SBATCH --ntasks=6
#SBATCH --cpus-per-task=5
#SBATCH --mem-per-cpu=16G
#SBATCH --time=5:00:00
 
# Setup tools needed for analysis (optionally use you own local copy of cp_pipe)
source /cvmfs/sw.lsst.eu/linux-x86_64/lsst_distrib/w_2022_11/loadLSST.bash
setup lsst_distrib
setup -j -r /sdf/home/a/abrought/cp_pipe
export PYTHONPATH="/sdf/home/a/abrought/bin/mixcoatl/python:${PYTHONPATH}" # Needed for using gridFit
 
# Set up repositories for collections
export REPO=/sdf/group/lsst/camera/IandT/repo_gen3/BOT_data
export YAML=/sdf/home/a/abrought/yaml
export sbias=u/abrought/BF/run_13141/sbias2
export sflat=u/abrought/BF/run_13141/sflat2
export defects=u/abrought/BF/run_13141/defects2
export sdark=u/abrought/BF/run_13162/sdark2
export ptcs_iband=u/abrought/BF/run_13144/ptcs_iband
export ptcs_gband=u/abrought/BF/run_13144/ptcs_gband
export ptcs_rband=u/abrought/BF/run_13144/ptcs_rband



# Generate SBIAS
#pipetask run \
#    -j 25 \
#    -d "instrument='LSSTCam' AND exposure.science_program IN ('13141') AND detector in (94) AND exposure.observation_type = 'bias' " \
#    -b ${REPO}/butler.yaml \
#    -i LSSTCam/raw/all,LSSTCam/calib \
#    -o ${sbias} \
#    -p ${YAML}/cpBias.yaml \
#    --register-dataset-types
 
#cp ${YAML}/cpBias.yaml ${REPO}/${sbias}
 
# Generate SFLAT

#pipetask run \
#    -d "instrument='LSSTCam' AND exposure.science_program IN ('13141') AND detector in (94) AND exposure.observation_type = 'flat' AND exposure.observation_reason='sflat' AND exposure IN (3021120600480..3021120600495)" \
#    -b ${REPO}/butler.yaml \
#    -i LSSTCam/raw/all,LSSTCam/calib,${sbias} \
#    -o ${sflat} \
#    -p ${YAML}/cpFlat.yaml \
#    --register-dataset-types
 
#cp ${YAML}/cpFlat.yaml ${REPO}/${sflat}
 
# Find DEFECTS 9, 23, 31, 83, 112, 136
#pipetask run \
#    -j 25 \
#    -d "instrument='LSSTCam' AND exposure.science_program IN ('13141') AND detector in (94) AND exposure.observation_type = 'flat' AND exposure.observation_reason='sflat' " \
#    -b ${REPO}/butler.yaml \
#    -i LSSTCam/raw/all,LSSTCam/calib,${sbias} \
#    -o ${defects} \
#    -p ${YAML}/findDefects.yaml \
#    --register-dataset-types
 
#cp ${YAML}/findDefects.yaml ${REPO}/${defects}
 
# Generate SDARK
# pipetask run \
#    -j 25 \
#    -d "instrument='LSSTCam' AND exposure.observation_type='dark' AND exposure.observation_reason='dark' AND detector in (94) AND exposure.science_program IN ('13162')" \
#    -b ${REPO}/butler.yaml \
#    -i LSSTCam/raw/all,LSSTCam/calib,${sbias},${defects} \
#    -o ${sdark} \
#    -p ${YAML}/cpDark.yaml \
#    --register-dataset-types
 
#cp ${YAML}/cpDark.yaml ${REPO}/${sdark}
 
# Generate PTC
pipetask run  \
    -j 25 \
    -d "instrument='LSSTCam' AND detector IN (94) AND exposure.science_program IN ('7069D')  AND exposure.observation_type = 'flat' AND exposure.observation_reason='flat' " \
    -b ${REPO}/butler.yaml \
    -i LSSTCam/raw/all,LSSTCam/calib,${sbias},${sdark} \
    -o ${ptcs_iband} \
    -p ${YAML}/measurePhotonTransferCurve.yaml \
         -c ptcSolve:ptcFitType=EXPAPPROXIMATION \
    --register-dataset-types
     
cp ${YAML}/measurePhotonTransferCurve.yaml ${REPO}/${ptcs_iband}


pipetask run  \
    -j 25 \
    -d "instrument='LSSTCam' AND detector IN (94) AND exposure.science_program IN ('7068D')  AND exposure.observation_type = 'flat' AND exposure.observation_reason='flat' " \
    -b ${REPO}/butler.yaml \
    -i LSSTCam/raw/all,LSSTCam/calib,${sbias},${sdark} \
    -o ${ptcs_rband} \
    -p ${YAML}/measurePhotonTransferCurve.yaml \
         -c ptcSolve:ptcFitType=EXPAPPROXIMATION \
    --register-dataset-types
     
cp ${YAML}/measurePhotonTransferCurve.yaml ${REPO}/${ptcs_rband}
 

pipetask run  \
    -j 25 \
    -d "instrument='LSSTCam' AND detector IN (94) AND exposure.science_program IN ('7067D')  AND exposure.observation_type = 'flat' AND exposure.observation_reason='flat' " \
    -b ${REPO}/butler.yaml \
    -i LSSTCam/raw/all,LSSTCam/calib,${sbias},${sdark} \
    -o ${ptcs_gband} \
    -p ${YAML}/measurePhotonTransferCurve.yaml \
         -c ptcSolve:ptcFitType=EXPAPPROXIMATION \
    --register-dataset-types
     
cp ${YAML}/measurePhotonTransferCurve.yaml ${REPO}/${ptcs_gband}



#END

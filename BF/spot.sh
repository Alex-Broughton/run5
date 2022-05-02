#!/bin/bash
  
#SBATCH --partition=rubin
#SBATCH --job-name=spot
#SBATCH --output=/sdf/home/a/abrought/run5/BF/output/spotout.txt
#SBATCH --error=/sdf/home/a/abrought/run5/BF/output/spoterr.txt
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=25
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
export sbias=u/abrought/BF/run_13141/sbias
export sflat=u/abrought/BF/run_13141/sflat
export defects=u/abrought/BF/run_13141/defects
export sdark=u/abrought/BF/run_13162/sdark
export linearity=u/abrought/BF/run_13144/linearity
export ptcs=u/abrought/BF/run_13144/ptcs
export ptcs_linearized=u/abrought/BF/run_13144/ptcs_linearized
export bfks=u/abrought/BF/run_13144/bfks
export bfks_raw=u/abrought/BF/run_13144/bfks_raw
export bfks_linearized=u/abrought/BF/run_13144/bfks_linearized
export bfks_experimental=u/abrought/BF/run_13144/bfks_experimental_nozerosum

  
# Generate BF Kernels
# You must only a single dummy exposure in the -d option. I selected the first in the sequence. This generated the kernel for the given detector.
# It is recommended to generate kernels individually per sensor because some amplifiers misbehave and should be removed from the composite kernel by
# specifying e.g. "tasks: bfkSolve: config: ignoreAmpsForAveraging: ['C10', 'C11']"
# I will often generate the BFKs once initially, and then check the kernels and rerun with misbehaving amps ignored.
 
# If you don't want to linearize the results, replace all the ${*_linearized} collection with the regular ones and set doLinearize=False in all
# yaml files (cpBfkSolve.yaml & gridFit.yaml)
 
# pipetask run \
#       -j 25 \
#       -d "instrument='LSSTCam' AND exposure IN (3021120600576) AND detector IN (9, 23, 31, 83, 112, 136) " \
#       -b ${REPO}/butler.yaml \
#       -i LSSTCam/raw/all,LSSTCam/calib,${sbias},${sdark},${sflat},${defects},${ptcs_linearized}  \
#       -o ${bfks_linearized} \
#       -p ${YAML}/cpBfkSolve.yaml \
#       --register-dataset-types
        
# cp ${YAML}/cpBfkSolve.yaml ${REPO}/${bfks_linearized}
 
# Run the IsrTask + MIXCOATL tasks
pipetask run \
        -j 25 \
        -d "instrument='LSSTCam' AND detector in ( 112 ) AND exposure.observation_type='spot' AND exposure.science_program IN ('13250')" \
        -b ${REPO}/butler.yaml \
        -i LSSTCam/raw/all,LSSTCam/calib,${sbias},${sdark},${sflat},${defects},${ptcs},${bfks} \
        -o u/abrought/BF/run_13250/R24_S11/corrected \
        -p ${YAML}/gridFit.yaml \
        --register-dataset-types
 
cp ${YAML}/gridFit.yaml ${REPO}/u/abrought/BF/run_13250/R24_S11/corrected


pipetask run \
        -j 25 \
        -d "instrument='LSSTCam' AND detector in ( 112 ) AND exposure.observation_type='spot' AND exposure.science_program IN ('13250')" \
        -b ${REPO}/butler.yaml \
        -i LSSTCam/raw/all,LSSTCam/calib,${sbias},${sdark},${sflat},${defects},${ptcs},${bfks} \
        -o u/abrought/BF/run_13250/R24_S11/uncorrected \
        -p ${YAML}/gridFit2.yaml \
        --register-dataset-types
 
cp ${YAML}/gridFit2.yaml ${REPO}/u/abrought/BF/run_13250/R24_S11/uncorrected


# END

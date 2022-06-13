#!/bin/bash
  
#SBATCH --partition=rubin
#SBATCH --job-name=bfk
#SBATCH --output=/sdf/home/a/abrought/run5/BF/output/bfkout.txt
#SBATCH --error=/sdf/home/a/abrought/run5/BF/output/bfkerr.txt
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
export sbias=u/abrought/BF/run_13141/sbias2
export sflat=u/abrought/BF/run_13141/sflat2
export defects=u/abrought/BF/run_13141/defects2
export sdark=u/abrought/BF/run_13162/sdark2
export ptcs_iband=u/abrought/BF/run_13144/ptcs_iband
export ptcs_gband=u/abrought/BF/run_13144/ptcs_gband
export ptcs_rband=u/abrought/BF/run_13144/ptcs_rband
export ptcs_linearized=u/abrought/BF/run_13144/ptcs_linearized
export bfks=u/abrought/BF/run_13144/bfks
export bfks_raw_iband=u/abrought/BF/run_7069D/bfks_raw_iband
export bfks_raw_rband=u/abrought/BF/run_7068D/bfks_raw_rband
export bfks_raw_gband=u/abrought/BF/run_7067D/bfks_raw_gband
export bfks_linearized=u/abrought/BF/run_13144/bfks_linearized
export bfks_iband=u/abrought/BF/run_7069D/bfks_iband
export bfks_rband=u/abrought/BF/run_7068D/bfks_rband
export bfks_gband=u/abrought/BF/run_7067D/bfks_gband

export bfks_experimental=u/abrought/BF/run_13144/bfks_experimental_nozerosum

  
# Generate BF Kernels
# You must only a single dummy exposure in the -d option. I selected the first in the sequence. This generated the kernel for the given detector.
# It is recommended to generate kernels individually per sensor because some amplifiers misbehave and should be removed from the composite kernel by
# specifying e.g. "tasks: bfkSolve: config: ignoreAmpsForAveraging: ['C10', 'C11']"
# I will often generate the BFKs once initially, and then check the kernels and rerun with misbehaving amps ignored.
 
# If you don't want to linearize the results, replace all the ${*_linearized} collection with the regular ones and set doLinearize=False in all
# yaml files (cpBfkSolve.yaml & gridFit.yaml)
 
pipetask run \
       -j 25 \
       -d "instrument='LSSTCam' AND exposure IN (3022052300171) AND detector IN (94) " \
       -b ${REPO}/butler.yaml \
       -i LSSTCam/raw/all,LSSTCam/calib,${sbias},${sdark},${sflat},${defects},${ptcs_iband}  \
       -o ${bfks_raw_iband} \
       -p ${YAML}/cpBfkSolve.yaml \
       --register-dataset-types
        
cp ${YAML}/cpBfkSolve.yaml ${REPO}/${bfks_raw_iband}

# END

## i-band (13144):  3021120600576
## i-band (7069D):  3022052300171
## r-band (7068D):  3022052200188
## g-band (7067D):  3022052001188
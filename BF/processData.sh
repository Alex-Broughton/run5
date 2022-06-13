#!/bin/bash
  
#SBATCH --partition=rubin
#SBATCH --job-name=data_pickle
#SBATCH --output=/sdf/home/a/abrought/run5/BF/output/dataout.txt
#SBATCH --error=/sdf/home/a/abrought/run5/BF/output/dataerr.txt
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=16G
#SBATCH --time=16:00:00
 
# Setup tools needed for analysis (optionally use you own local copy of cp_pipe)
source /cvmfs/sw.lsst.eu/linux-x86_64/lsst_distrib/w_2022_14/loadLSST.bash
setup lsst_distrib

cd /sdf/home/a/abrought/run5/BF
 
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

echo "13230..."
python processData.py 13230 450nm uncorrected
## python processData.py 13230 uncorrected_linearized
python processData.py 13230 450nm corrected
## python processData.py 13230 corrected_linearized
echo "13231..."
python processData.py 13231 450nm uncorrected
## python processData.py 13231 uncorrected_linearized
python processData.py 13231 450nm corrected
## python processData.py 13231 corrected_linearized
echo "13232..."
python processData.py 13232 450nm uncorrected
## python processData.py 13232 uncorrected_linearized
python processData.py 13232 450nm corrected
## python processData.py 13232 corrected_linearized
echo "13234..."
python processData.py 13234 450nm uncorrected
## python processData.py 13234 uncorrected_linearized
python processData.py 13234 450nm corrected
## python processData.py 13234 corrected_linearized
echo "13236..."
python processData.py 13236 450nm uncorrected
## python processData.py 13236 uncorrected_linearized
python processData.py 13236 450nm corrected
## python processData.py 13236 corrected_linearized
echo "13238..."
python processData.py 13238 450nm uncorrected
## python processData.py 13238 uncorrected_linearized
python processData.py 13238 450nm corrected
## python processData.py 13238 corrected_linearized




echo "FINISHED :D"

# END

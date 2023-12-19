#!/bin/bash
  
##SBATCH --partition=rubin
#SBATCH --job-name=flats
#SBATCH --output=/sdf/home/a/abrought/run5/BF/output/AntilogusCorrection-out.txt
#SBATCH --error=/sdf/home/a/abrought/run5/BF/output/AntilogusCorrection-err.txt
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=16G
#SBATCH --time=24:00:00
 
# Setup tools needed for analysis (optionally use you own local copy of cp_pipe)
#source /cvmfs/sw.lsst.eu/linux-x86_64/lsst_distrib/w_2022_32/loadLSST.bash
#setup lsst_distrib

source /sdf/group/rubin/sw/tag/w_2022_45/loadLSST.bash
setup lsst_distrib

cd /sdf/home/a/abrought/run5/BF/notebooks/

echo "Starting..."

python AntilogusCorrection.py

echo "FINISHED :D"

# END

#!/bin/bash
  
##SBATCH --partition=rubin
#SBATCH --job-name=R03S12
#SBATCH --output=/sdf/home/a/abrought/run5/BF/output/spotdataout1.txt
#SBATCH --error=/sdf/home/a/abrought/run5/BF/output/spotdataerr1.txt
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=16G
#SBATCH --time=24:00:00
 
# Setup tools needed for analysis (optionally use you own local copy of cp_pipe)
source /sdf/group/rubin/sw/tag/w_2023_29/loadLSST.bash
setup lsst_distrib -t w_2023_29
setup -t w_2023_29 -j -r /sdf/home/a/abrought/alternate_branches/dm_stack/cp_pipe
setup -t w_2023_29 -j -r /sdf/home/a/abrought/alternate_branches/dm_stack/ip_isr

cd /sdf/home/a/abrought/run5/BF

echo "Starting..."

python processData.py 13248 680nm corrected
python processData.py 13247 680nm corrected






echo "FINISHED :D"

# END

#!/bin/bash
  
#SBATCH --partition=rubin
#SBATCH --job-name=data_pickle2
#SBATCH --output=/sdf/home/a/abrought/run5/BF/output/data2out.txt
#SBATCH --error=/sdf/home/a/abrought/run5/BF/output/data2err.txt
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

echo "13239..."
python processData.py 13239 450nm uncorrected
## python processData.py 13239 uncorrected_linearized
python processData.py 13239 450nm corrected
## python processData.py 13239 corrected_linearized
echo "13240..."
python processData.py 13240 450nm uncorrected
## python processData.py 13240 uncorrected_linearized
python processData.py 13240 450nm corrected
## python processData.py 13240 corrected_linearized
echo "13249..." 
python processData.py 13249 ellipse_680nm uncorrected
python processData.py 13249 ellipse_680nm corrected
echo "13250..."
python processData.py 13250 ellipse_680nm uncorrected
python processData.py 13250 ellipse_680nm corrected
echo "13247..."
python processData.py 13247 680nm uncorrected
python processData.py 13247 680nm corrected
echo "13252..."
python processData.py 13252 680nm uncorrected
python processData.py 13252 680nm corrected
echo "13248..."
python processData.py 13248 680nm uncorrected
python processData.py 13248 680nm corrected
echo "13251..."
python processData.py 13251 680nm uncorrected
python processData.py 13251 680nm corrected


echo "FINISHED :D"

# END

#!/bin/bash

##SBATCH --partition=rubin
#SBATCH --job-name=calib1
#SBATCH --output=/sdf/home/a/abrought/run5/BF/output/out4.txt
#SBATCH --error=/sdf/home/a/abrought/run5/BF/output/err4.txt
#SBATCH --ntasks=6
#SBATCH --cpus-per-task=3
#SBATCH --mem-per-cpu=16G
##SBATCH --time=5:00:00


source /sdf/group/rubin/sw/tag/w_2023_29/loadLSST.bash
setup lsst_distrib -t w_2023_29
setup -t w_2023_29 -j -r /sdf/home/a/abrought/alternate_branches/dm_stack/cp_pipe
setup -t w_2023_29 -j -r /sdf/home/a/abrought/alternate_branches/dm_stack/ip_isr

export PYTHONPATH="/sdf/home/a/abrought/alternate_branches/mixcoatl/python:${PYTHONPATH}" # Needed for using gridFit
 
# Set up repositories for collections
export REPO=/repo/main
export CONFIG=/sdf/home/a/abrought/run5/BF/config2
export SBIAS=u/cslage/calib/13144/bias_20211229
export SDARK=u/cslage/calib/13144/dark_20211229
export DEFECTS=u/cslage/calib/13144/defects_20211229
export LINEARITY=u/cslage/linearizer_28jan22/20220128T174703Z
#export CTI=u/cslage/sdf/BOT/cti_test_20230106
export CTI=u/abrought/BF/2023.04.14/cti.2023.04.14


 
## Detectors 9, 23, 83, 112 

#!/bin/bash

##SBATCH --partition=rubin
#SBATCH --job-name=calib1
#SBATCH --output=/sdf/home/a/abrought/run5/BF/output/out3.txt
#SBATCH --error=/sdf/home/a/abrought/run5/BF/output/err3.txt
#SBATCH --ntasks=6
#SBATCH --cpus-per-task=3
#SBATCH --mem-per-cpu=16G
##SBATCH --time=5:00:00


source /sdf/group/rubin/sw/tag/w_2023_29/loadLSST.bash
setup lsst_distrib -t w_2023_29
setup -t w_2023_29 -j -r /sdf/home/a/abrought/alternate_branches/dm_stack/cp_pipe
setup -t w_2023_29 -j -r /sdf/home/a/abrought/alternate_branches/dm_stack/ip_isr

export PYTHONPATH="/sdf/home/a/abrought/alternate_branches/mixcoatl/python:${PYTHONPATH}" # Needed for using gridFit
 
# Set up repositories for collections
export REPO=/repo/main
export CONFIG=/sdf/home/a/abrought/run5/BF/config2
export SBIAS=u/cslage/calib/13144/bias_20211229
export SDARK=u/cslage/calib/13144/dark_20211229
export DEFECTS=u/cslage/calib/13144/defects_20211229
export LINEARITY=u/cslage/linearizer_28jan22/20220128T174703Z
#export CTI=u/cslage/sdf/BOT/cti_test_20230106
export CTI=u/abrought/BF/2023.04.14/cti.2023.04.14


 
## Detectors 9, 23, 83, 112 

pipetask run \
        -j 30 \
        -d "instrument='LSSTCam' AND detector in ( 83 ) AND exposure.observation_type='spot' AND exposure.science_program IN ('13236')" \
        -b ${REPO} \
        -i u/abrought/BF/2023.07.19/ptc.R21-S02.trunc_to_newpcti.fullnoisematrix,u/abrought/BF/2023.09.15/bfk.R21-S02.final,${SBIAS},${SDARK},${DEFECTS},${CTI},${LINEARITY},LSSTCam/raw/all \
        -o u/abrought/BF/2023.09.15/run_13236/R21-S02/uncorrected \
        -p ${CONFIG}/cpSpots_uncorrected.yaml \
            --config isr:connections.newBFKernel='bfk' \
        --register-dataset-types

pipetask run \
        -j 30 \
        -d "instrument='LSSTCam' AND detector in ( 83 ) AND exposure.observation_type='spot' AND exposure.science_program IN ('13236')" \
        -b ${REPO} \
        -i u/abrought/BF/2023.07.19/ptc.R21-S02.trunc_to_newpcti.fullnoisematrix,u/abrought/BF/2023.09.15/bfk.R21-S02.final,${SBIAS},${SDARK},${DEFECTS},${CTI},${LINEARITY},LSSTCam/raw/all \
        -o u/abrought/BF/2023.09.15/run_13236/R21-S02/corrected.nonFluxConserving \
        -p ${CONFIG}/cpSpots_corrected_nonFluxConserving.yaml \
            --config isr:connections.newBFKernel='bfk' \
        --register-dataset-types

pipetask run \
        -j 30 \
        -d "instrument='LSSTCam' AND detector in ( 83 ) AND exposure.observation_type='spot' AND exposure.science_program IN ('13236')" \
        -b ${REPO} \
        -i u/abrought/BF/2023.07.19/ptc.R21-S02.trunc_to_newpcti.fullnoisematrix,u/abrought/BF/2023.09.15/bfk.R21-S02.final,${SBIAS},${SDARK},${DEFECTS},${CTI},${LINEARITY},LSSTCam/raw/all \
        -o u/abrought/BF/2023.09.15/run_13236/R21-S02/corrected.fluxConserving \
        -p ${CONFIG}/cpSpots_corrected_fluxConserving.yaml \
            --config isr:connections.newBFKernel='bfk' \
        --register-dataset-types

pipetask run \
        -j 30 \
        -d "instrument='LSSTCam' AND detector in ( 83 ) AND exposure.observation_type='spot' AND exposure.science_program IN ('13238')" \
        -b ${REPO} \
        -i u/abrought/BF/2023.07.19/ptc.R21-S02.trunc_to_newpcti.fullnoisematrix,u/abrought/BF/2023.09.15/bfk.R21-S02.final,${SBIAS},${SDARK},${DEFECTS},${CTI},${LINEARITY},LSSTCam/raw/all \
        -o u/abrought/BF/2023.09.15/run_13238/R21-S02/uncorrected \
        -p ${CONFIG}/cpSpots_uncorrected.yaml \
            --config isr:connections.newBFKernel='bfk' \
        --register-dataset-types

pipetask run \
        -j 30 \
        -d "instrument='LSSTCam' AND detector in ( 83 ) AND exposure.observation_type='spot' AND exposure.science_program IN ('13238')" \
        -b ${REPO} \
        -i u/abrought/BF/2023.07.19/ptc.R21-S02.trunc_to_newpcti.fullnoisematrix,u/abrought/BF/2023.09.15/bfk.R21-S02.final,${SBIAS},${SDARK},${DEFECTS},${CTI},${LINEARITY},LSSTCam/raw/all \
        -o u/abrought/BF/2023.09.15/run_13238/R21-S02/corrected.nonFluxConserving \
        -p ${CONFIG}/cpSpots_corrected_nonFluxConserving.yaml \
            --config isr:connections.newBFKernel='bfk' \
        --register-dataset-types
        
pipetask run \
        -j 30 \
        -d "instrument='LSSTCam' AND detector in ( 83 ) AND exposure.observation_type='spot' AND exposure.science_program IN ('13238')" \
        -b ${REPO} \
        -i u/abrought/BF/2023.07.19/ptc.R21-S02.trunc_to_newpcti.fullnoisematrix,u/abrought/BF/2023.09.15/bfk.R21-S02.final,${SBIAS},${SDARK},${DEFECTS},${CTI},${LINEARITY},LSSTCam/raw/all \
        -o u/abrought/BF/2023.09.15/run_13238/R21-S02/corrected.fluxConserving \
        -p ${CONFIG}/cpSpots_corrected_fluxConserving.yaml \
            --config isr:connections.newBFKernel='bfk' \
        --register-dataset-types
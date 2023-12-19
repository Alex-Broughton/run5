#!/bin/bash

##SBATCH --partition=rubin
#SBATCH --job-name=calib
#SBATCH --output=/sdf/home/a/abrought/run5/BF/output/out2.txt
#SBATCH --error=/sdf/home/a/abrought/run5/BF/output/err2.txt
#SBATCH --ntasks=6
#SBATCH --cpus-per-task=5
#SBATCH --mem-per-cpu=16G
##SBATCH --time=5:00:00
 
# used to be 

#source /cvmfs/sw.lsst.eu/linux-x86_64/lsst_distrib/w_2023_09/loadLSST-ext.bash
#setup lsst_distrib
#setup -j -r /sdf/home/a/abrought/alternate_branches/cp_pipe
#setup -j -r /sdf/home/a/abrought/alternate_branches/ip_isr


##source /cvmfs/sw.lsst.eu/linux-x86_64/lsst_distrib/w_2023_19/loadLSST-ext.bash
##setup lsst_distrib
##setup -j -r /sdf/home/a/abrought/alternate_branches/chrisfixes/cp_pipe
##setup -j -r /sdf/home/a/abrought/alternate_branches/chrisfixes/ip_isr

source /sdf/group/rubin/sw/tag/w_2023_29/loadLSST.bash
setup lsst_distrib -t w_2023_29
setup -t w_2023_29 -j -r /sdf/home/a/abrought/alternate_branches/dm_stack/cp_pipe
setup -t w_2023_29 -j -r /sdf/home/a/abrought/alternate_branches/dm_stack/ip_isr

#source /cvmfs/sw.lsst.eu/linux-x86_64/lsst_distrib/w_2023_19/loadLSST-ext.bash
#setup lsst_distrib
#setup -j -r /sdf/home/a/abrought/alternate_branches/chrisfixes/cp_pipe
#setup -j -r /sdf/home/a/abrought/alternate_branches/chrisfixes/ip_isr

export PYTHONPATH="/sdf/home/a/abrought/bin/mixcoatl/python:${PYTHONPATH}" # Needed for using gridFit
 
# Set up repositories for collections
export REPO=/repo/main
export CONFIG=/sdf/home/a/abrought/run5/BF/config2 #originally config
export SBIAS=u/cslage/calib/13144/bias_20211229
export SDARK=u/cslage/calib/13144/dark_20211229
export DEFECTS=u/cslage/calib/13144/defects_20211229
export LINEARITY=u/cslage/linearizer_28jan22/20220128T174703Z
#export CTI=u/cslage/sdf/BOT/cti_test_20230106
export CTI=u/abrought/BF/2023.04.14/cti.2023.04.14

 
# Other PTC datasets 13147/13148 

# Detectors 9, 23, 31, 83, 112, 136 used for Run 5 spot testing

 

#pipetask run \
#     -j 32 \
#     -d "detector IN (9,23,83,112) AND instrument='LSSTCam' AND exposure IN (3021120600575..3021120700825) AND exposure.observation_type='flat'" \
#     -b /sdf/group/rubin/repo/main \
#     -i LSSTCam/raw/all,LSSTCam/calib,u/cslage/calib/13144/calib.20220107 \
#     -o u/abrought/BF/2023.04.14/cti.2023.04.14 \
#     -p ${CONFIG}/cpDeferredCharge.yaml \
#     -c isr:doApplyGains=False \
#     --register-dataset-types

## PTC up to PTC turnoff
#pipetask run  \
#    -j 25 \
#    -d "instrument='LSSTCam' AND detector IN (112) AND exposure.science_program IN ('13144')  AND exposure.observation_type = 'flat' AND exposure.observation_reason='flat' " \
#    -b ${REPO} \
#    -i ${SBIAS},${SDARK},${DEFECTS},${LINEARITY},${CTI},LSSTCam/raw/all \
#    -o u/abrought/BF/2023.05.15/ptc.2023.05.15.R24-S11.trunc_to_ptc \
#    -p ${CONFIG}/cpPtc-R24-S11.yaml \
#    --register-dataset-types
    
#pipetask run  \
#   -j 25 \
#   -d "instrument='LSSTCam' AND detector IN (23) AND exposure.science_program IN ('13144')  AND exposure.observation_type = 'flat' AND exposure.observation_reason='flat' " \ 
#   -b ${REPO} \
#    -i ${SBIAS},${SDARK},${DEFECTS},${LINEARITY},${CTI},LSSTCam/raw/all \
#    -o u/abrought/BF/2023.05.15/ptc.2023.05.15.R03-S12.trunc_to_ptc \
#    -p ${CONFIG}/cpPtc-R03-S12.yaml \
#    --register-dataset-types

#pipetask run  \
#    -j 30 \
#    -d "instrument='LSSTCam' AND detector IN (23) AND exposure.science_program IN ('13144')  AND exposure.observation_type = 'flat' AND exposure.observation_reason='flat' " \
#    -b ${REPO} \
#    -i u/abrought/BF/2023.04.28/ptc.2023.04.28.R03-S12.trunc_to_pcti,u/abrought/BF/2023.05.15/bfk.2023.05.15.R03-S12.final,${SBIAS},${SDARK},${DEFECTS},${CTI},${LINEARITY},LSSTCam/raw/all \
#    -o u/abrought/BF/2023.05.15/ptc.2023.05.15.R03-S12.bfcorrected.final \
#    -p ${CONFIG}/cpPtc.yaml \
#        --config isr:connections.newBFKernel='bfk' \
#    --register-dataset-types

#pipetask run  \
#    -j 30 \
#    -d "instrument='LSSTCam' AND detector IN (112) AND exposure.science_program IN ('13144')  AND exposure.observation_type = 'flat' AND exposure.observation_reason='flat' " \
#    -b ${REPO} \
#    -i u/abrought/BF/2023.04.28/ptc.2023.04.28.R24-S11.trunc_to_pcti,u/abrought/BF/2023.05.15/bfk.2023.05.15.R24-S11.final,${SBIAS},${SDARK},${DEFECTS},${CTI},${LINEARITY},LSSTCam/raw/all \
#    -o u/abrought/BF/2023.05.15/ptc.2023.05.15.R24-S11.bfcorrected.final \
#    -p ${CONFIG}/cpPtc.yaml \
#        --config isr:connections.newBFKernel='bfk' \
#    --register-dataset-types

#pipetask run  \
#    -j 30 \
#    -d "instrument='LSSTCam' AND detector IN (9) AND exposure.science_program IN ('13144')  AND exposure.observation_type = 'flat' AND exposure.observation_reason='flat' " \
#    -b ${REPO} \
#    -i u/abrought/BF/2023.04.28/ptc.2023.04.28.R02-S00.trunc_to_pcti,u/abrought/BF/2023.05.15/bfk.2023.05.15.R02-S00.final,${SBIAS},${SDARK},${DEFECTS},${CTI},${LINEARITY},LSSTCam/raw/all \
#    -o u/abrought/BF/2023.05.15/ptc.2023.05.15.R02-S00.bfcorrected.final \
#    -p ${CONFIG}/cpPtc.yaml \
#        --config isr:connections.newBFKernel='bfk' \
#    --register-dataset-types

#pipetask run  \
#    -j 30 \
#    -d "instrument='LSSTCam' AND detector IN (83) AND exposure.science_program IN ('13144')  AND exposure.observation_type = 'flat' AND exposure.observation_reason='flat' " \
#    -b ${REPO} \
#    -i u/abrought/BF/2023.04.28/ptc.2023.04.28.R22-S02.trunc_to_pcti,u/abrought/BF/2023.05.15/bfk.2023.05.15.R22-S02.final,${SBIAS},${SDARK},${DEFECTS},${CTI},${LINEARITY},LSSTCam/raw/all \
#    -o u/abrought/BF/2023.05.15/ptc.2023.05.15.R22-S02.bfcorrected.final \
#    -p ${CONFIG}/cpPtc.yaml \
#        --config isr:connections.newBFKernel='bfk' \
#    --register-dataset-types

#pipetask run  \
#    -j 25 \
#    -d "instrument='LSSTCam' AND detector IN (9) AND exposure.science_program IN ('13144')  AND exposure.observation_type = 'flat' AND exposure.observation_reason='flat' " \
#    -b ${REPO} \
#    -i ${SBIAS},${SDARK},${DEFECTS},${LINEARITY},${CTI},LSSTCam/raw/all \
#    -o u/abrought/BF/2023.05.15/ptc.2023.05.15.R02-S00.trunc_to_ptc \
#    -p ${CONFIG}/cpPtc-R02-S00.yaml \
#    --register-dataset-types

#pipetask run  \
#    -j 25 \
#    -d "instrument='LSSTCam' AND detector IN (83) AND exposure.science_program IN ('13144')  AND exposure.observation_type = 'flat' AND exposure.observation_reason='flat' " \
#    -b ${REPO} \
#    -i ${SBIAS},${SDARK},${DEFECTS},${LINEARITY},${CTI},LSSTCam/raw/all \
#    -o u/abrought/BF/2023.05.15/ptc.2023.05.15.R21-S02.trunc_to_ptc \
#    -p ${CONFIG}/cpPtc-R21-S02.yaml \
#    --register-dataset-types

## PTC up to pCTI turnoff
pipetask run  \
    -j 30 \
    -d "instrument='LSSTCam' AND detector IN (112) AND exposure.science_program IN ('13144')  AND exposure.observation_type = 'flat' AND exposure.observation_reason='flat' " \
    -b ${REPO} \
    -i ${SBIAS},${SDARK},${DEFECTS},${LINEARITY},${CTI},LSSTCam/raw/all \
    -o u/abrought/BF/2023.10.09/ptc.R24-S11.trunc_to_pcti \
    -p ${CONFIG}/cpPtc-R24-S11-pCTI.yaml \
    --register-dataset-types
    

    
# pipetask run  \
#     -j 30 \
#     -d "instrument='LSSTCam' AND detector IN (9) AND exposure.science_program IN ('13144')  AND exposure.observation_type = 'flat' AND exposure.observation_reason='flat' " \
#     -b ${REPO} \
#     -i ${SBIAS},${SDARK},${DEFECTS},${LINEARITY},${CTI},LSSTCam/raw/all \
#     -o u/abrought/BF/2023.07.19/ptc.R02-S00.fullnoisematrix \
#     -p ${CONFIG}/cpPtc-full.yaml \
#     --register-dataset-types




#pipetask run  \
#    -j 25 \
#    -d "instrument='LSSTCam' AND detector IN (112) AND exposure.science_program IN ('13144')  AND exposure.observation_type = 'flat' AND exposure.observation_reason='flat' " \
#    -b ${REPO} \
#    -i ${SBIAS},${SDARK},${DEFECTS},${LINEARITY},${CTI},LSSTCam/raw/all \
#    -o u/abrought/BF/2023.07.19/ptc.R24-S11.trunc_to_ptc.fullnoisematrix \
#    -p ${CONFIG}/cpPtc-R24-S11-PTC.yaml \
#    --register-dataset-types
    
#pipetask run  \
#    -j 25 \
#    -d "instrument='LSSTCam' AND detector IN (23) AND exposure.science_program IN ('13144')  AND exposure.observation_type = 'flat' AND exposure.observation_reason='flat' " \
#    -b ${REPO} \
#    -i ${SBIAS},${SDARK},${DEFECTS},${LINEARITY},${CTI},LSSTCam/raw/all \
#    -o u/abrought/BF/2023.07.19/ptc.R03-S12.trunc_to_ptc.fullnoisematrix \
#    -p ${CONFIG}/cpPtc-R03-S12-PTC.yaml \
#    --register-dataset-types

# Generate BFK Kernels
#pipetask run \
#       -j 25 \
#       -d "instrument='LSSTCam' AND exposure IN (3021120600576) AND detector IN (23)" \
#       -b ${REPO} \
#       -i u/abrought/BF/2023.04.28/ptc.2023.04.28.R03-S12.trunc_to_pcti,${SBIAS},${SDARK},${DEFECTS},${LINEARITY},${CTI} \
#       -o u/abrought/BF/2023.04.28/bfk.2023.04.28.R03-S12.trunc_to_pcti.improved_corr_model.forceZeroSum.chrisfixes.fudgefactor \
#       -p ${CONFIG}/cpBfkSolve.yaml \
#           -c bfkSolve:fudgeFactor=0 \
#       --register-dataset-types
       
#pipetask run \
#       -j 25 \
#       -d "instrument='LSSTCam' AND exposure IN (3021120600576) AND detector IN (112)" \
#       -b ${REPO} \
#       -i u/abrought/BF/2023.04.28/ptc.2023.04.28.R24-S11.trunc_noise_to_pcti,${SBIAS},${SDARK},${DEFECTS},${LINEARITY},${CTI} \
#       -o u/abrought/BF/2023.04.28/bfk.2023.04.28.R24-S11.trunc_to_pcti.improved_corr_model.forceZeroSum.chrisfixes.fudgefactor \
#       -p ${CONFIG}/cpBfkSolve.yaml \
#           -c bfkSolve:useAmatrix=True \
#           -c bfkSolve:correlationQuadraticFit=False \
#           #-c bfkSolve:correlationModelRadius=3 \
#           -c bfkSolve:level='AMP' \
#           -c bfkSolve:forceZeroSum=True \
#       --register-dataset-types

#pipetask run \
#       -j 25 \
#       -d "instrument='LSSTCam' AND exposure IN (3021120600576) AND detector IN (112)" \
#       -b ${REPO} \
#       -i u/abrought/BF/2023.04.28/ptc.2023.04.28.R24-S11.trunc_to_pcti,${SBIAS},${SDARK},${DEFECTS},${LINEARITY},${CTI} \
#       -o u/abrought/BF/2023.04.28/bfk.2023.04.28.R24-S11.trunc_to_pcti.amatrix.improved_corr_model.noForceZeroSum.chrisfixes \
#       -p ${CONFIG}/cpBfkSolve.yaml \
#           -c bfkSolve:useAmatrix=True \
#           -c bfkSolve:correlationQuadraticFit=False \
#           -c bfkSolve:correlationModelRadius=100 \
#           -c bfkSolve:level='AMP' \
#           -c bfkSolve:forceZeroSum='False' \
#       --register-dataset-types

#pipetask run \
#       -j 25 \
#       -d "instrument='LSSTCam' AND exposure IN (3021120600576) AND detector IN (112)" \
#       -b ${REPO} \
#       -i u/abrought/BF/2023.04.28/ptc.2023.04.28.R24-S11.trunc_to_ptc,${SBIAS},${SDARK},${DEFECTS},${LINEARITY},${CTI} \
#       -o u/abrought/BF/2023.04.28/bfk.2023.04.28.R24-S11.trunc_to_ptc.amatrix.noCorrModel \
#       -p ${CONFIG}/cpBfkSolve.yaml \
#           -c bfkSolve:useAmatrix=True \
#           -c bfkSolve:correlationQuadraticFit=False \
#           #-c bfkSolve:correlationModelRadius=3 \
#           -c bfkSolve:level='AMP' \
#       --register-dataset-types



#pipetask run \
#       -j 25 \
#       -d "instrument='LSSTCam' AND exposure IN (3021120600576) AND detector IN (9)" \
#       -b ${REPO} \
#       -i u/abrought/BF/2023.04.28/ptc.2023.04.28.R02-S00.trunc_to_ptc,${SBIAS},${SDARK},${DEFECTS},${LINEARITY},${CTI} \
#       -o u/abrought/BF/2023.04.28/bfk.2023.04.28.R02-S00.trunc_to_ptc.amatrix \
#       -p ${CONFIG}/cpBfkSolve-9.yaml \
#           -c bfkSolve:useAmatrix=True \
#           -c bfkSolve:correlationQuadraticFit=False \
#           -c bfkSolve:correlationModelRadius=3 \
#           -c bfkSolve:level='DETECTOR' \
#       --register-dataset-types

#pipetask run \
#       -j 25 \
#       -d "instrument='LSSTCam' AND exposure IN (3021120600576) AND detector IN (83)" \
#       -b ${REPO} \
#       -i u/abrought/BF/2023.04.28/ptc.2023.04.28.R21-S02.trunc_to_ptc,${SBIAS},${SDARK},${DEFECTS},${LINEARITY},${CTI} \
#       -o u/abrought/BF/2023.04.28/bfk.2023.04.28.R21-S02.trunc_to_ptc.amatrix \
#       -p ${CONFIG}/cpBfkSolve-83.yaml \
#           -c bfkSolve:useAmatrix=True \
#           -c bfkSolve:correlationQuadraticFit=False \
#           -c bfkSolve:correlationModelRadius=3 \
#           -c bfkSolve:level='DETECTOR' \
#       --register-dataset-types

#pipetask run \
#       -j 25 \
#       -d "instrument='LSSTCam' AND exposure IN (3021120600576) AND detector IN (23)" \
#       -b ${REPO} \
#       -i u/abrought/BF/2023.04.28/ptc.2023.04.28.R03-S12.trunc_to_pcti,${SBIAS},${SDARK},${DEFECTS},${LINEARITY},${CTI} \
#       -o u/abrought/BF/2023.04.28/bfk.2023.04.28.R03-S12.trunc_to_pcti.amatrix.noCorrModel \
#       -p ${CONFIG}/cpBfkSolve.yaml \
#           -c bfkSolve:useAmatrix=True \
#           -c bfkSolve:correlationQuadraticFit=False \
#           #-c bfkSolve:correlationModelRadius=3 \
#           -c bfkSolve:level='AMP' \
#       --register-dataset-types


#pipetask run \
#       -j 25 \
#       -d "instrument='LSSTCam' AND exposure IN (3021120600576) AND detector IN (112)" \
#       -b ${REPO} \
#       -i u/abrought/BF/2023.04.28/ptc.2023.04.28.R24-S11.trunc_to_pcti,${SBIAS},${SDARK},${DEFECTS},${LINEARITY},${CTI} \
#       -o u/abrought/BF/2023.04.28/bfk.2023.04.28.R24-S11.trunc_to_pcti.amatrix.noCorrModel \
#       -p ${CONFIG}/cpBfkSolve.yaml \
#           -c bfkSolve:useAmatrix=True \
#           -c bfkSolve:correlationQuadraticFit=False \
#           #-c bfkSolve:correlationModelRadius=3 \
#           -c bfkSolve:level='AMP' \
#       --register-dataset-types

#pipetask run \
#       -j 25 \
#       -d "instrument='LSSTCam' AND exposure IN (3021120600576) AND detector IN (9)" \
#       -b ${REPO} \
#       -i u/abrought/BF/2023.04.28/ptc.2023.04.28.R02-S00.trunc_to_pcti,${SBIAS},${SDARK},${DEFECTS},${LINEARITY},${CTI} \
#       -o u/abrought/BF/2023.04.28/bfk.2023.04.28.R02-S00.trunc_to_pcti.amatrix \
#       -p ${CONFIG}/cpBfkSolve-9.yaml \
#           -c bfkSolve:useAmatrix=True \
#           -c bfkSolve:correlationQuadraticFit=False \
#           -c bfkSolve:correlationModelRadius=3 \
#           -c bfkSolve:level='DETECTOR' \
#       --register-dataset-types

#pipetask run \
#       -j 25 \
#       -d "instrument='LSSTCam' AND exposure IN (3021120600576) AND detector IN (83)" \
#       -b ${REPO} \
#       -i u/abrought/BF/2023.04.28/ptc.2023.04.28.R21-S02.trunc_to_pcti,${SBIAS},${SDARK},${DEFECTS},${LINEARITY},${CTI} \
#       -o u/abrought/BF/2023.04.28/bfk.2023.04.28.R21-S02.trunc_to_pcti.amatrix \
#       -p ${CONFIG}/cpBfkSolve-83.yaml \
#           -c bfkSolve:useAmatrix=True \
#           -c bfkSolve:correlationQuadraticFit=False \
#           -c bfkSolve:correlationModelRadius=3 \
#           -c bfkSolve:level='DETECTOR' \
#       --register-dataset-types

# Generate Spots
#pipetask run \
#        -j 25 \
#        -d "instrument='LSSTCam' AND detector in ( 23 ) AND exposure.observation_type='spot' AND exposure.science_program IN ('13247')" \
#        -b ${REPO} \
#        -i LSSTCam/raw/all,LSSTCam/calib,${SBIAS},${SDARK},${DEFECTS},${CTI},${PTC_max100kE},${LINEARITY} \
#        -o u/abrought/BF/2023.01.26/run_13247/R03_S12/uncorrected_max100kE \
#        -p ${CONFIG}/gridFit_uncorrected.yaml \
#        --register-dataset-types

#pipetask run \
#        -j 25 \
#        -d "instrument='LSSTCam' AND detector in ( 23 ) AND exposure.observation_type='spot' AND exposure.science_program IN ('13248')" \
#        -b ${REPO} \
#        -i ${SBIAS},${SDARK},${DEFECTS},${CTI},${PTC_max100kE},${LINEARITY},${BFK},LSSTCam/raw/all \
#        -o u/abrought/BF/2023.01.26/run_13248/R03_S12/corrected_max100kE_transposedKernel \
#        -p ${CONFIG}/gridFit_corrected.yaml \
#        --register-dataset-types

#pipetask run \
#        -j 25 \
#        -d "instrument='LSSTCam' AND detector in ( 112 ) AND exposure.observation_type='spot' AND exposure.science_program IN ('13251')" \
#        -b ${REPO} \
#        -i ${SBIAS},${SDARK},${DEFECTS},${CTI},${PTC_max100kE},${LINEARITY},${BFK},LSSTCam/raw/all \
#        -o u/abrought/BF/2023.01.26/run_13251/R24_S11/corrected_max100kE_transposedKernel \
#        -p ${CONFIG}/gridFit_corrected.yaml \
#        --register-dataset-types

#pipetask run \
#        -j 25 \
#        -d "instrument='LSSTCam' AND detector in ( 23 ) AND exposure.observation_type='spot' AND exposure.science_program IN ('13247')" \
#        -b ${REPO} \
#        -i LSSTCam/raw/all,LSSTCam/calib,${SBIAS},${SDARK},${DEFECTS},${CTI},${PTC_max100kE},${LINEARITY},${BFK} \
#        -o u/abrought/BF/2023.01.26/run_13247/R03_S12/corrected_max100kE_noQuadFit_corrModelr_3 \
#        -p ${CONFIG}/gridFit_corrected.yaml \
#            --config isr:connections.newBFKernel='bfk'
#        --register-dataset-types

#pipetask run \
#        -j 25 \
#        -d "instrument='LSSTCam' AND detector in ( 23 ) AND exposure.observation_type='spot' AND exposure.science_program IN ('13248')" \
#        -b ${REPO} \
#        -i LSSTCam/raw/all,LSSTCam/calib,${SBIAS},${SDARK},${DEFECTS},${CTI},${PTC_max100kE},${LINEARITY},${BFK} \
#        -o u/abrought/BF/2023.01.26/run_13248/R03_S12/corrected_max100kE_noQuadFit_corrModelr_3 \
#        -p ${CONFIG}/gridFit_corrected.yaml \
#            --config isr:connections.newBFKernel='bfk' \
#        --register-dataset-types

#pipetask run \
#        -j 25 \
#        -d "instrument='LSSTCam' AND detector in ( 23 ) AND exposure.observation_type='spot' AND exposure.science_program IN ('13249')" \
#        -b ${REPO} \
#        -i LSSTCam/raw/all,LSSTCam/calib,${SBIAS},${SDARK},${DEFECTS},${CTI},${PTC_max100kE},${LINEARITY} \
#        -o u/abrought/BF/2023.01.26/run_13249/R03_S12/uncorrected_max100kE \
#        -p ${CONFIG}/gridFit_uncorrected.yaml \
#            --config isr:connections.newBFKernel='bfk' \
#        --register-dataset-types

#pipetask run \
#        -j 30 \
#        -d "instrument='LSSTCam' AND detector in ( 23 ) AND exposure.observation_type='spot' AND exposure.science_program IN ('13248')" \
#        -b ${REPO} \
#        -i u/abrought/BF/2023.04.24/ptc.2023.04.24.R03-S12.ptc_cutoff,u/abrought/BF/2023.04.24/bfks.2023.04.24.R03-S12,${SBIAS},${SDARK},${DEFECTS},${CTI},${LINEARITY},LSSTCam/raw/all \
#        -o u/abrought/BF/2023.04.24/run_13248/R03_S12/corrected_default_kernel \
#        -p ${CONFIG}/gridFit_corrected.yaml \
#            --config isr:connections.newBFKernel='bfk' \
#        --register-dataset-types

#pipetask run \
#        -j 30 \
#        -d "instrument='LSSTCam' AND detector in ( 112 ) AND exposure.observation_type='spot' AND exposure.science_program IN ('13251')" \
#        -b ${REPO} \
#        -i u/abrought/BF/2023.04.24/ptc.2023.04.24.R24-S11.ptc_cutoff,u/abrought/BF/2023.04.24/bfks.2023.04.24.R24-S11,${SBIAS},${SDARK},${DEFECTS},${CTI},${LINEARITY},LSSTCam/raw/all \
#        -o u/abrought/BF/2023.04.24/run_13251/R24_S11/corrected_default_kernel \
#        -p ${CONFIG}/gridFit_corrected.yaml \
#            --config isr:connections.newBFKernel='bfk' \
#        --register-dataset-types



#pipetask run \
#        -j 25 \
#        -d "instrument='LSSTCam' AND detector in ( 9 ) AND exposure.observation_type='spot' AND exposure.science_program IN ('13231')" \
#        -b ${REPO} \
#        -i u/abrought/BF/2023.04.24/ptc.2023.04.24.R02-S00.ptc_cutoff,u/abrought/BF/2023.04.24/bfks.2023.04.24.R02-S00.ptc_cutoff_ver3,${SBIAS},${SDARK},${DEFECTS},${CTI},${LINEARITY},LSSTCam/raw/all \
#        -o u/abrought/BF/2023.04.24/run_13231/R02_S00/uncorrected \
#        -p ${CONFIG}/gridFit_uncorrected.yaml \
#            --config isr:connections.newBFKernel='bfk' \
#        --register-dataset-types


# END
#!/bin/bash

butler remove-collections /sdf/group/lsst/camera/IandT/repo_gen3/BOT_data u/abrought/BF/run_$1/*
butler remove-runs /sdf/group/lsst/camera/IandT/repo_gen3/BOT_data u/abrought/BF/run_$1/*

echo "Finishing up..."
cd /sdf/group/lsst/camera/IandT/repo_gen3/BOT_data/u/abrought/BF/
rm -r run_$1
echo "Done! :)"

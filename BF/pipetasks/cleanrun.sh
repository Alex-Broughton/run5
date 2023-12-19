#!/bin/bash

butler remove-collections /sdf/group/rubin/repo/ir2 u/abrought/BF/run_$1/*
butler remove-runs /sdf/group/rubin/repo/ir2 u/abrought/BF/run_$1/*

echo "Finishing up..."
cd /sdf/group/rubin/repo/main/u/abrought/BF/
rm -r run_$1
echo "Done! :)"

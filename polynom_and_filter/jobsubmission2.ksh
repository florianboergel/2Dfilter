#!/bin/ksh

#Job Submission to cca
#PBS -S /usr/bin/ksh
#PBS -N 3filter_application
#PBS -q ns
#PBS -o /perm/ms/spde/de5j/tools/analysis-tools/2dfilter/polynom_and_filter/job.o 
#PBS -e /perm/ms/spde/de5j/tools/analysis-tools/2dfilter/polynom_and_filter/job.e
#PBS -l walltime=06:00:00
#PBS -l EC_nodes=1
#PBS -l EC_total_tasks=1
#PBS -l EC_tasks_per_node=1
#PBS -l EC_hyperthreads=1
#PBS -l EC_memory_per_task=10GB

echo "Starting 03_application.sh"
cd /perm/ms/spde/de5j/tools/analysis-tools/2dfilter/polynom_and_filter
#./03_application.sh
./03_application_var_commands.sh "RELHUM" "50" "MODIS2000_HFD2_3D_sn_v01l"
./03_application_var_commands.sh "RELHUM" "50" "MODIS2000_HFD2_3D_sn_v02l"
./03_application_var_commands.sh "RELHUM" "50" "MODIS2000_HFD2_3D_sn_v03l"
./03_application_var_commands.sh "RELHUM" "50" "MODIS2000_HFD2_3D_nn_v01l"
./03_application_var_commands.sh "RELHUM" "50" "MODIS2000_HFD2_3D_nn_v02l"
./03_application_var_commands.sh "RELHUM" "50" "MODIS2000_HFD2_3D_nn_v03l"

exit 0



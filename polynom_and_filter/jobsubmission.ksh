#!/bin/ksh

#Job Submission to cca
#PBS -S /usr/bin/ksh
#PBS -N filter_ANOVA
#PBS -q ns
#PBS -o /perm/ms/spde/de5j/tools/analysis-tools/2dfilter/polynom_and_filter/job.o 
#PBS -e /perm/ms/spde/de5j/tools/analysis-tools/2dfilter/polynom_and_filter/job.e
#PBS -l walltime=24:00:00
#PBS -l EC_nodes=1
#PBS -l EC_total_tasks=1
#PBS -l EC_tasks_per_node=1
#PBS -l EC_hyperthreads=1
#PBS -l EC_memory_per_task=20GB

echo "Starting 03_application.sh"
cd /perm/ms/spde/de5j/tools/analysis-tools/2dfilter/polynom_and_filter
./03_application_var.sh
#./03_application.sh
#./03_application_var_commands.sh "RELHUM" "50" "MODIS2000_HFD1_FD_nn_v01l"
#./03_application_var_commands.sh "RELHUM" "50" "MODIS2000_HFD1_FD_nn_v02l"
#./03_application_var_commands.sh "RELHUM" "50" "MODIS2000_HFD1_FD_nn_v03l"

echo "Starting ANOVA"
cd /perm/ms/spde/de5j/tools/analysis-tools/r-programs/anova
# Level 50
echo "Starting calculate_1way-anova_season_bpfiltered2_daymean_nn.r"
Rscript calculate_1way-anova_season_bpfiltered2_daymean_commandargs_nn.r  'T' 50

# Loop over levels
for ilev in 49 48 47 46 45 44 43 42 41 40 39 38;
do

	echo "Starting calculate_1way-anova_season_unfiltered_daymean_nn.r"
	Rscript calculate_1way-anova_season_unfiltered_daymean_commandargs_nn.r  'T' $ilev
	echo "Starting calculate_1way-anova_season_unfiltered_daymean_nn.r"
	Rscript calculate_1way-anova_season_unfiltered_daymean_commandargs_nn.r  'T' $ilev
	echo "Starting calculate_1way-anova_season_bpfiltered_daymean_nn.r"
	Rscript calculate_1way-anova_season_bpfiltered_daymean_commandargs_nn.r  'T' $ilev
	echo "Starting calculate_1way-anova_season_bpfiltered2_daymean_nn.r"
	Rscript calculate_1way-anova_season_bpfiltered2_daymean_commandargs_nn.r  'T' $ilev

done

exit 0



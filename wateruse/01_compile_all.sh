#!/bin/bash

# This script compiles all necessary scripts to apply the polynomial fit and filter scripts. 
# Compilation and application on ecgate only (ECMWF) in Dec 2016 
# JKe
# 14-08-2017


# load modules 
 # on ecgate: > 
 cd /hpc/perm/ms/spde/de5j/tools/analysis-tools/2dfilter/wateruse

 prgenvswitchto gnu/4.4.7
	# note: does not work with 5.3.0 !
 #module unload netcdf
 module load netcdf/3.6.3
 module load cdo
 module load nco

#*****************************************
## STEP 1
#*****************************************
#echo "Step 1: Filter creation compilation"
#echo "Using $NETCDF_DIR"
#        # this one is working on ecgate
#        # -->  
#               f95 -o create_filter f90/create_filter.f90 $NETCDF_INCLUDE $NETCDF_LIB

echo "Step 1: Filter application compilation"
echo "Using $NETCDF_DIR"
        # working on ecgate
        # --> 
               f95 -o filter_data f90/filter_data.f90 $NETCDF_INCLUDE $NETCDF_LIB

#*****************************************
## STEP 2
#*****************************************
#echo "Step 2: Polyfit compilation"
#echo ""
#		# working on ecgate
#		# --> 
#		 	   f95 -o polyfit f90/polyfit.f90 $NETCDF_INCLUDE $NETCDF_LIB


echo "Compilations finished. "

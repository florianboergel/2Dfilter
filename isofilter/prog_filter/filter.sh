#!/bin/bash

# This script applies a filter to data
# Filter created in: /perm/ms/spde/de5j/tools/analysis-tools/2dfilter/isofilter
# JKe
# 14-12-2016 


# load modules 
 prgenvswitchto gnu
 module unload netcdf
 module load netcdf/3.6.3
 module load cdo
 module load nco
 
#*****************************************
# STEP 3: 
#*****************************************
# FILTER THE DATA
	echo "Filtering data..." 

	# % Usage: filter_data.sh <indir> <infile> <outdir> <gridpts in x> <gridpts in y> <variable> <filter indir> <filterfile> <filtertype>
		# % 'indir - input directory'
		# % 'infile - input file name'
		# % 'outdir - output directory'
		# % 'gridpts in x - number of gridpoints in x direction (spongezone included) -> see infile'
		# % 'gridpts in y - number of gridpoints in y direction (spongezone included) -> see infile'
		# % 'variable - name variable in input file to be filtered'
		# % 'filter indir - filter input directory'
		# % 'filterfile - filter file name'
		# % 'filter type - press l for lowpass, b for bandpass and h for highpass'

 # Choose a filter 
	filter_indir="$SCRATCH/bfilter_158x158_N8_maxinc/filters/"
	filterfile="bf_316x316_8_158x158_019x153.nc"
	filtertype="b"
 ## Set parameters
        gx=316
        gy=316
	yyyy="2003"
	mm="06"

## Set directory
for runnum in 1 2 3  
do
 for runname in 3D_sn 3D_nn FD_sn FD_nn
 do 
	#expid="MODIS2000_HFD1_3D_sn_v01l"
	expid="MODIS2000_HFD1_${runname}_v0${runnum}l"
	indir="$SCRATCH/terrsysmp_run/cordex_1.2.0MCT_clm-cos-pfl_${expid}/output/pp/focusdomain/cosmo_out/hourly/"
	var="T"
	infile="tsmp_out_cosmo_${var}_${yyyy}-${mm}_focusdomain_316x316.nc"
	outdir="${SCRATCH}/bfilter_158x158_N8_maxinc/output/${var}/${expid}"
	if [ ! -d $outdir ];
	then
		mkdir -p $outdir
	fi

   # Multi-level data 
    levstring=`ncdump -h $indir/$infile | grep "lev"`	# string is empty if levels do not exist
    ## Pre-process data if dimension has multiple levels 
	if  [[ ! -z "${levstring// }" ]];
	then
		nlev=`ncdump -h $indir/$infile | grep "lev" | grep "lev = " | awk '{print $3}'`
		echo "Looping until ...${nlev}"
		for i in $(seq 49 $nlev)
		do
			# repeat for all levels...
			rfile="tsmp_out_cosmo_${var}_${yyyy}-${mm}_focusdomain_316x316.nc"
			cdo -sellevel,$i $indir/$rfile "${indir}/tsmp_out_cosmo_${var}_${yyyy}-${mm}_focusdomain_316x316_sellev_${i}.nc"
			infile="tsmp_out_cosmo_${var}_${yyyy}-${mm}_focusdomain_316x316_sellev_${i}.nc"
			# delete level dimension
			infile_new="tsmp_out_cosmo_${var}_${yyyy}-${mm}_focusdomain_316x316_sellev_${i}d.nc"
			ncwa -v $var -y avg -a lev $indir/$infile $indir/$infile_new
			rm -f $indir/$infile
			# Filter the data !
			echo "./filter_data.sh $indir $infile_new $outdir $gx $gy $var $filter_indir $filterfile $filtertype "
			./filter_data.sh $indir $infile_new $outdir $gx $gy $var $filter_indir $filterfile $filtertype 
			rm -f $indir/$infile_new
		done
    # Single-level data
	else
			# Filter the data !
			echo "./filter_data.sh $indir $infile $outdir $gx $gy $var $filter_indir $filterfile $filtertype "
			./filter_data.sh $indir $infile $outdir $gx $gy $var $filter_indir $filterfile $filtertype 
	fi
	
 done	# runnum
done	# runname

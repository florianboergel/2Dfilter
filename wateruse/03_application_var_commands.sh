#!/bin/bash

# 
# ./03_application_var_commands.sh var lev expid
# ./03_application_var_commands.sh "RELHUM" "50" MODIS2000_HFD1_3D_nn_v01l"

#
# This script applies the filters

# Settings
    # Define parameters
    spzone=8
    gx=316
    gy=316
    wx=158
    wy=158

    # Lowpass filter
    indir_l="$SCRATCH/lowpassfilter_${gx}x${gy}_${wx}x${wy}_N${spzone}/filters/"
    lfilter="lf_${gx}x${gy}_${spzone}_${wx}x${wy}_006x043.nc"
	# LOWPASSFILTER: 006x043 -- low pass filter with k~19, i.e. only scales larger than 207 km 
    # Bandpass filter
    indir_b="$SCRATCH/bandpassfilter_${gx}x${gy}_${wx}x${wy}_N${spzone}_maxinc/filters/"
    bfilter1="bf_${gx}x${gy}_${spzone}_${wx}x${wy}_039x150.nc"
    bfilter2="bf_${gx}x${gy}_${spzone}_${wx}x${wy}_020x150.nc"
	# BANDPASSFILTER1: 039x150 -- band pass filter with 39<k<150 and 101km>k*>26km
	# BANDPASSFILTER2: 020x150 -- band pass filter with 20<k<150 and 197km>k*>26km
	# BANDPASSFILTER3: 020x150 -- subtract low-pass-filtered field (removes spatial trend, and better resolves small scales)
	# BANDPASSFILTER4: 039x150 -- subtract low-pass-filtered field (removes spatial trend, and better resolves small scales)

    # Dates
    yyyy="2003"
    for mm in 01 02 03 04 05 06 07 08 09 10 11 12
    do


    # Variable and level
    var=$1
    nlev=$2
    minlev=$2
       # nlev=`ncdump -h $indir/$infile | grep "lev" | grep "lev = " | awk '{print $3}'`

    # Input data 
    expid=$3

		    indir="$SCRATCH/terrsysmp_run/cordex_1.2.0MCT_clm-cos-pfl_${expid}/output/pp/focusdomain/cosmo_out/hourly/"
		    infile="tsmp_out_cosmo_${var}_${yyyy}-${mm}_focusdomain_316x316.nc"
		    # Output directories
		    outdir="$SCRATCH/filtered_data_${gx}x${gy}_${wx}x${wy}_N${spzone}/${expid}/${var}"
		    if [ ! -d "$outdir" ]; then mkdir -p $outdir; fi
		    bfoutdir1="$outdir/bf_${gx}x${gy}_${spzone}_${wx}x${wy}_039x150_sublowpass"
		    if [ ! -d "$bfoutdir1" ]; then mkdir -p $bfoutdir1; fi
		    bfoutdir2="$outdir/bf_${gx}x${gy}_${spzone}_${wx}x${wy}_020x150_sublowpass"
		    if [ ! -d "$bfoutdir2" ]; then mkdir -p $bfoutdir2; fi
		    lfoutdir="$outdir/lf_${gx}x${gy}_${spzone}_${wx}x${wy}_006x043"
		    if [ ! -d "$lfoutdir" ]; then mkdir -p $lfoutdir; fi
		
		
		# 
		  echo "Looping from $minlev until ${nlev}"
		  # repeat for all levels...
		  for ((i=minlev; i<=nlev; i++))
		  do
		  echo "Processing level ${i}"
			
			## 0. PREPARE INPUT DATA 
			# 	- select level and delete level dimension 
		          	linfile="tsmp_out_cosmo_${var}_${yyyy}-${mm}_focusdomain_316x316_sellev_${i}.nc"
			  	if [ -e "${linfile}" ]; then rm $linfile; fi
		          	cdo -O -sellevel,$i $indir/$infile "${indir}/${linfile}"
		          	# delete level dimension
		          	linfile_new="tsmp_out_cosmo_${var}_${yyyy}-${mm}_focusdomain_316x316_sellev_${i}d.nc"
			  	if [ -e "${linfile_new}" ]; then rm ${linfile_new}; fi
		          	ncwa -O -v $var -y avg -a lev $indir/$linfile $indir/${linfile_new}
		          	# delete temporary file
		          	rm $indir/${linfile}
		
			## 2. FILTER DATA
			# 	./filter_data.sh indir infile outputdir gx gy var filter_indir filterfile filtertype
		
				# A. LOW PASS FILTER
				# for raw variable (no trend subtracted)
				echo "**************"
				echo "Applying low-pass filter ..."
				echo "./filter_data.sh $indir ${linfile_new} $lfoutdir $gx $gy $var ${indir_l} $lfilter l"
				./filter_data.sh $indir ${linfile_new} $lfoutdir $gx $gy $var ${indir_l} $lfilter "l"
	
				# B. RAW FIELD - LOW-PASS-FILTERED FIELD
				echo "**************"
				diffile="tsmp_out_cosmo_d${var}_${yyyy}-${mm}_focusdomain_316x316_sellev_${i}d.nc"
				if [ -e "${diffile}" ]; then rm $diffile; fi
				cdo -O -expr,d${var}l=${var}-${var}l $lfoutdir/${linfile_new} $lfoutdir/$diffile
				echo "Successfully created: $lfoutdir/$diffile"
		
				# C BAND PASS FILTER (3) on diff field from (B)
				echo "**************"
				echo "Applying band-pass filter (1)..."
				echo "./filter_data.sh $lfoutdir $diffile $bfoutdir2 $gx $gy d${var}l ${indir_b} $bfilter2 b"
				./filter_data.sh $lfoutdir $diffile $bfoutdir2 $gx $gy "d${var}l" ${indir_b} $bfilter2 "b"
				echo "Successfully created: $bfoutdir2/..."

				# D. BAND PASS FILTER (4) on diff field from (B)
				echo "**************"
				echo "Applying band-pass filter (2)..."
				echo "./filter_data.sh $lfoutdir $diffile $bfoutdir1 $gx $gy d${var}l ${indir_b} $bfilter1 b"
				./filter_data.sh $lfoutdir $diffile $bfoutdir1 $gx $gy "d${var}l" ${indir_b} $bfilter1 "b"
				echo "Successfully created: $bfoutdir1/..."
		
		  done

done # mm

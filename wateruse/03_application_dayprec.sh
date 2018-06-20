#!/bin/bash

# This script applies the filters
# (a) chosen bandpass filter 
# (b) chosen lowpass filter 

cd /perm/ms/spde/de5j/tools/analysis-tools/2dfilter/wateruse


# Settings
    # Define parameters
    spzone=8
    gx=316
    gy=316
    wx=158
    wy=158
    polyorder="1"

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
    #mm="06"
    #for mm in 06 07 08
    for mm in 01 02 03 04 05 09 10 11 12
    do

    # Variable 
    #varname="TPREC"
    varname="PREChour"
    var="TOT_PREC"

    # Input data 
    for expid in "MODIS2000_HFD2_3D_sn_v04l_ref2" "MODIS2000_HFD2_3D_sn_v04l_wateruseW_day" "MODIS2000_HFD2_3D_sn_v04l_wateruseW_night" "MODIS2000_HFD2_3D_sn_v04l_wateruseS_day" "MODIS2000_HFD2_3D_sn_v04l_wateruseS_night"
    do

		    indir="$SCRATCH/terrsysmp_run/cordex_1.2.0MCT_clm-cos-pfl_${expid}/output/pp/focusdomain/cosmo_out/daily/"
		    infile="tsmp_out_cosmo_${varname}_${yyyy}-${mm}_focusdomain_316x316_daysum.nc"
		    # Output directories
		    outdir="$SCRATCH/filtered_data_${gx}x${gy}_${wx}x${wy}_N${spzone}/${expid}/${var}"
		    if [ ! -d "$outdir" ]; then mkdir -p $outdir; fi
		    bfoutdir1="$outdir/bf_${gx}x${gy}_${spzone}_${wx}x${wy}_039x150_sublowpass"
		    if [ ! -d "$bfoutdir1" ]; then mkdir -p $bfoutdir1; fi
		    bfoutdir2="$outdir/bf_${gx}x${gy}_${spzone}_${wx}x${wy}_020x150_sublowpass"
		    if [ ! -d "$bfoutdir2" ]; then mkdir -p $bfoutdir2; fi
		    lfoutdir="$outdir/lf_${gx}x${gy}_${spzone}_${wx}x${wy}_006x043"
		    if [ ! -d "$lfoutdir" ]; then mkdir -p $lfoutdir; fi
		
		
			## 1. FILTER DATA
			# 	./filter_data.sh indir infile outputdir gx gy var filter_indir filterfile filtertype
		
				# A. LOW PASS FILTER
				# for raw variable (no trend subtracted)
				echo "**************"
				echo "Applying low-pass filter ..."
				echo "./filter_data.sh $indir ${infile} $lfoutdir $gx $gy $var ${indir_l} $lfilter l"
				./filter_data.sh $indir ${infile} $lfoutdir $gx $gy $var ${indir_l} $lfilter "l"
	
				# B. RAW FIELD - LOW-PASS-FILTERED FIELD
				echo "**************"
				diffile="tsmp_out_cosmo_d${varname}_${yyyy}-${mm}_focusdomain_316x316.nc"
				if [ -e "${diffile}" ]; then rm $diffile; fi
				cdo -O -expr,d${var}l=${var}-${var}l $lfoutdir/${infile} $lfoutdir/$diffile
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
		

done # expid
done # mm

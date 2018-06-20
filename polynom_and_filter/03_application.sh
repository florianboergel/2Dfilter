#!/bin/bash

# This script applies the filters
# (a) chosen bandpass filter 
# (b) chosen lowpass filter 

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

    # Dates
    yyyy="2003"
    #mm="06"
    for mm in 06 07 08
    do


    # Variable and level
    var="T"
    nlev=50
    minlev=50
       # nlev=`ncdump -h $indir/$infile | grep "lev" | grep "lev = " | awk '{print $3}'`

    # Input data 
    #for expid in MODIS2000_HFD1_3D_sn_v01l MODIS2000_HFD1_3D_sn_v02l MODIS2000_HFD1_3D_sn_v03l
    #for expid in MODIS2000_HFD1_3D_sn_v01l
    #for expid in MODIS2000_HFD1_3D_sn_v02l MODIS2000_HFD1_3D_sn_v01l MODIS2000_HFD1_FD_sn_v03l MODIS2000_HFD1_FD_sn_v02l MODIS2000_HFD1_FD_sn_v01l MODIS2000_HFD2_3D_sn_v03l MODIS2000_HFD2_3D_sn_v02l MODIS2000_HFD2_3D_sn_v01l MODIS2000_HFD2_FD_sn_v03l MODIS2000_HFD2_FD_sn_v02l MODIS2000_HFD2_FD_sn_v01l
    for expid in MODIS2000_HFD1_3D_nn_v01l MODIS2000_HFD1_3D_nn_v02l MODIS2000_HFD1_3D_nn_v03l MODIS2000_HFD1_FD_nn_v03l MODIS2000_HFD1_FD_nn_v02l MODIS2000_HFD1_FD_nn_v01l MODIS2000_HFD2_3D_nn_v03l MODIS2000_HFD2_3D_nn_v02l MODIS2000_HFD2_3D_nn_v01l MODIS2000_HFD2_FD_nn_v03l MODIS2000_HFD2_FD_nn_v02l MODIS2000_HFD2_FD_nn_v01l
    do

		    indir="$SCRATCH/terrsysmp_run/cordex_1.2.0MCT_clm-cos-pfl_${expid}/output/pp/focusdomain/cosmo_out/hourly/"
		    infile="tsmp_out_cosmo_${var}_${yyyy}-${mm}_focusdomain_316x316.nc"
		    # Output directories
		    outdir="$SCRATCH/filtered_data_${gx}x${gy}_${wx}x${wy}_N${spzone}/${expid}/${var}"
		    if [ ! -d "$outdir" ]; then mkdir -p $outdir; fi
		    polyoutdir="$outdir/polynome/"
		    if [ ! -d "$polyoutdir" ]; then mkdir -p $polyoutdir; fi
		    bfoutdir1="$outdir/bf_${gx}x${gy}_${spzone}_${wx}x${wy}_039x150"
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
		          	cdo -sellevel,$i $indir/$infile "${indir}/${linfile}"
		          	# delete level dimension
		          	linfile_new="tsmp_out_cosmo_${var}_${yyyy}-${mm}_focusdomain_316x316_sellev_${i}d.nc"
			  	if [ -e "${linfile_new}" ]; then rm ${linfile_new}; fi
		          	ncwa -v $var -y avg -a lev $indir/$linfile $indir/${linfile_new}
		          	# delete temporary file
		          	rm $indir/${linfile}
		
		        ## 1. SUBTRACT POLYNOMIAL FIT OF FIRST ORDER
		        # 	./prepare_polyfit inputdir inputfile outputdir gx gy var polyorder
			  	#pinfile="K${polyorder}_tsmp_out_cosmo_${var}_${yyyy}-${mm}_focusdomain_316x316_sellev_${i}d.nc"
			  	#if [ -e "${pinfile}" ]; then rm $pinfile ; fi
		          	#./prepare_polyfit.sh $indir ${linfile_new} $polyoutdir $gx $gy "$var" $polyorder
		          	# delete temporary file 
		          	#rm $indir/${linfile_new}
		
			## 2. FILTER DATA
			# 	./filter_data.sh indir infile outputdir gx gy var filter_indir filterfile filtertype
		
				polyvar="K${polyorder}_${var}"
		
				# A. LOW PASS FILTER
				# for raw variable (no trend subtracted)
				echo "./filter_data.sh $indir ${linfile_new} $lfoutdir $gx $gy $var ${indir_l} $lfilter l"
				./filter_data.sh $indir ${linfile_new} $lfoutdir $gx $gy $var ${indir_l} $lfilter "l"
				#echo "./filter_data.sh $polyoutdir $pinfile $lfoutdir $gx $gy $var ${indir_l} $lfilter l"
				#./filter_data.sh $polyoutdir $pinfile $lfoutdir $gx $gy $var ${indir_l} $lfilter "l"
				# for de-trended variables (polynomial subtracted)
				#echo "./filter_data.sh $polyoutdir $pinfile $lfoutdir $gx $gy $polyvar ${indir_l} $lfilter l"
				#./filter_data.sh $polyoutdir $pinfile $lfoutdir $gx $gy $polyvar ${indir_l} $lfilter "l"
		
		
				# B. BAND PASS FILTER (1) 
				# for raw variable (no trend subtracted)
				#echo "./filter_data.sh $polyoutdir $pinfile $bfoutdir1 $gx $gy $var ${indir_b} $bfilter1 b"
				#./filter_data.sh $polyoutdir $pinfile $bfoutdir1 $gx $gy $var ${indir_b} $bfilter1 "b"
				# for de-trended variables (polynomial subtracted)
				#echo "./filter_data.sh $polyoutdir $pinfile $bfoutdir1 $gx $gy $polyvar ${indir_b} $bfilter1 b"
				#./filter_data.sh $polyoutdir $pinfile $bfoutdir1 $gx $gy $polyvar ${indir_b} $bfilter1 "b"
		
		
				# C. BAND PASS FILTER (2) 
				# for raw variable (no trend subtracted)
				#echo "./filter_data.sh $polyoutdir $pinfile $bfoutdir2 $gx $gy $var ${indir_b} $bfilter2 b"
				#./filter_data.sh $polyoutdir $pinfile $bfoutdir2 $gx $gy $var ${indir_b} $bfilter2 "b"
				# for de-trended variables (polynomial subtracted)
				#echo "./filter_data.sh $polyoutdir $pinfile $bfoutdir2 $gx $gy $polyvar ${indir_b} $bfilter2 b"
				#./filter_data.sh $polyoutdir $pinfile $bfoutdir2 $gx $gy $polyvar ${indir_b} $bfilter2 "b"

				# D. BAND PASS FILTER (2) - LOW-PASS-FILTER
				# for raw variable (no trend subtracted)
				diffile="tsmp_out_cosmo_d${var}_${yyyy}-${mm}_focusdomain_316x316_sellev_${i}d.nc"
				#cdo -expr,dRELHUMl=RELHUM-RELHUMl $lfoutdir/${linfile_new} $lfoutdir/$diffile
				cdo -expr,dTl=T-Tl $lfoutdir/${linfile_new} $lfoutdir/$diffile
				echo "./filter_data.sh $lfoutdir $diffile $bfoutdir2 $gx $gy $var ${indir_b} $bfilter2 b"
				#./filter_data.sh $lfoutdir $diffile $bfoutdir2 $gx $gy "dRELHUMl" ${indir_b} $bfilter2 "b"
				./filter_data.sh $lfoutdir $diffile $bfoutdir2 $gx $gy "dTl" ${indir_b} $bfilter2 "b"
				#diffile="dK${polyorder}_tsmp_out_cosmo_${var}_${yyyy}-${mm}_focusdomain_316x316_sellev_${i}d.nc"
				#cdo -expr,dTl=T-Tl $lfoutdir/$pinfile $lfoutdir/$diffile
				#echo "./filter_data.sh $lfoutdir $diffile $bfoutdir2 $gx $gy $var ${indir_b} $bfilter2 b"
				#./filter_data.sh $lfoutdir $diffile $bfoutdir2 $gx $gy "dTl" ${indir_b} $bfilter2 "b"
				# for de-trended variables (polynomial subtracted)
				#kdiffile="dKK${polyorder}_tsmp_out_cosmo_${var}_${yyyy}-${mm}_focusdomain_316x316_sellev_${i}d.nc"
				#cdo -expr,dK1_Tl=K1_T-K1_Tl $lfoutdir/$pinfile $lfoutdir/$kdiffile
				#echo "./filter_data.sh $lfoutdir $kdiffile $bfoutdir2 $gx $gy "dK1_Tl" ${indir_b} $bfilter2 b"
				#./filter_data.sh $lfoutdir $kdiffile $bfoutdir2 $gx $gy dK1_Tl ${indir_b} $bfilter2 "b"
		
		  done


done # expid
done # mm

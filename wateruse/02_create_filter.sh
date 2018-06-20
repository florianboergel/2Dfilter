#!/bin/bash

# This scripts creates the filters using "generate.sh"
# (a) lowpass filter
# (b) bandpass filter

# JKe 20-01-2017

module load cdo

# Settings 
    # Define parameters
    spzone=8
    gx=316
    gy=316
    wx=158
    wy=158
	# Output directory
    outdir_l=$SCRATCH/lowpassfilter_${gx}x${gy}_${wx}x${wy}_N${spzone}
    outdir_b=$SCRATCH/bandpassfilter_${gx}x${gy}_${wx}x${wy}_N${spzone}_maxinc


## FILTER SCRIPT APPLICATIONS:
    # % *  generate.sh
    # % Usage: generate.sh <spzone> <gridpts in x> <gridpts in y> <wn in x> <wn in y> <filter type (l-low/b-band/h-high)> <outdir>
        # % * spzone - number of gridpoints used for spongezone
        # % * gridpts in x - number of gridpoints in x direction (spongezone included) -> see infile
        # % * gridpts in y - number of gridpoints in y direction (spongezone included) -> see infile
        # % * wn in x - wavenumbers in x direction (usually half of gridpoints in x)
        # % * wn in y - wavenumbers in y direction (usually half of gridpoints in y)
        # % * filter type - press l for lowpass, b for bandpass and h for highpass
        # % * outdir - output directory

    if [ ! -d ${outdir_l} ]; then
        mkdir ${outdir_l}
    fi
    if [ ! -d ${outdir_b} ]; then
        mkdir ${outdir_b}
    fi

	# Execute generate.sh
    echo "Generating filters..."
    #echo "high-pass filter"
    #./generate.sh $spzone $gx $gy $wx $wy "h" $outdir
    echo "band-pass filter"
    ./generate_maxinc.sh $spzone $gx $gy $wx $wy "b" ${outdir_b}
    echo "low-pass filter"
    ./generate.sh $spzone $gx $gy $wx $wy "l" ${outdir_l}

    echo "Concat response functions..."
    	# % Choose an appropriate response function to find correct values for filtering.
    	# % To make it easier use:
    	# % 'ncecat -h <outdir>/respfunct/l*.nc l.nc'  --> for all response functions for low pass filtering
    	# % 'ncecat -h <outdir>/respfunct/b*.nc b.nc'  --> for all response functions for band pass filtering
    	# % 'ncecat -h <outdir>/respfunct/h*.nc h.nc'  --> for all response functions for high pass filtering

    ncecat -h ${outdir_l}/respfunct/l*.nc lowpassfilter_${wx}x${wy}_${spzone}.nc
    ncecat -h ${outdir_b}/respfunct/b*.nc bandpassfilter_${wx}x${wy}_${spzone}.nc

echo "Created filters. Done." 

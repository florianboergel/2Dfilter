#!/bin/bash

    outdir=$SCRATCH/bandpassfilter_158x158_N8_maxinc/polynome
    if [ ! -d $outdir ]; then
        mkdir $outdir
    fi

    # Define parameters
    spzone=4
    gx=316
    gy=316
    wx=158
    wy=158



    #echo 'indir - input directory'
    #echo 'infile - input file name' 
    #echo 'outdir - output directory'   
    #echo 'gridpts in x - number of gridpoints in x direction (spongezone included) -> see infile'
    #echo 'gridpts in y - number of gridpoints in y direction (spongezone included) -> see infile'
    #echo 'variable - name variable in input file to be filtered'
    #echo 'polyorder- order of apllied polynom'

    yyyy="2003"
    mm="06"
    ## Set directory 
    expid="MODIS2000_HFD1_3D_sn_v03l"
    indir="$SCRATCH/terrsysmp_run/cordex_1.2.0MCT_clm-cos-pfl_${expid}/output/pp/focusdomain/cosmo_out/hourly/"
    var="T"
    infile="tsmp_out_cosmo_${var}_${yyyy}-${mm}_focusdomain_316x316.nc"

               nlev=`ncdump -h $indir/$infile | grep "lev" | grep "lev = " | awk '{print $3}'`
               echo "Looping until ...${nlev}"
               #for i in $(seq 40 $nlev)
               for ((i=50; i<=nlev; i++))
               do
                       # repeat for all levels...
                       rfile="tsmp_out_cosmo_${var}_${yyyy}-${mm}_focusdomain_316x316.nc"
                       cdo -sellevel,$i $indir/$rfile "${indir}/tsmp_out_cosmo_${var}_${yyyy}-${mm}_focusdomain_316x316_sellev_${i}.nc"
                       infile="tsmp_out_cosmo_${var}_${yyyy}-${mm}_focusdomain_316x316_sellev_${i}.nc"
                       # delete level dimension
                       infile_new="tsmp_out_cosmo_${var}_${yyyy}-${mm}_focusdomain_316x316_sellev_${i}d.nc"
                       ncwa -v $var -y avg -a lev $indir/$infile $indir/$infile_new
                       rm -f $indir/$infile
                       # Subtract polyfit
			./prepare_polyfit.sh $indir ${infile_new} $outdir $gx $gy "T" "1"
               done


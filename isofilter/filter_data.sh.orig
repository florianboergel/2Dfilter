#!/bin/ksh
#

if [ $# -ne 9 ]
then
  echo
  echo 'wrong number of arguments'

  echo
  echo 'usage: filter_data.sh <indir> <infile> <outdir> <gridpts in x> <gridpts in y> <variable> <filter indir> <filterfile> <filtertype>'
  echo

    echo 'indir - input directory'
    echo 'infile - input file name' 
    echo 'outdir - output directory'   
    echo 'gridpts in x - number of gridpoints in x direction (spongezone included) -> see infile'
    echo 'gridpts in y - number of gridpoints in y direction (spongezone included) -> see infile'
    echo 'variable - name variable in input file to be filtered'
    echo 'filter indir - filter input directory'
    echo 'filterfile - filter file name'    
    echo 'filter type - press l for lowpass, b for bandpass and h for highpass'
    echo
  exit
fi


INDIR=$1
INFILE=$2
OUTDIR=$3
ix=$4
iy=$5
ncvar=${6}
FINDIR=${7}
FIFILE=${8}
ftype=${9}



#*****************************************
#* data preparation
#*****************************************

if [ ! -f ${OUTDIR}/${INFILE} ]
  then
  cp ${INDIR}/${INFILE} ${OUTDIR}/${INFILE}
  else 
  echo WARNING: ${OUTDIR}/${INFILE} exists.
fi

echo $ncvar$ftype will be attached to  ${OUTDIR}/${INFILE}.
ncks -h -O -v $ncvar ${OUTDIR}/${INFILE} ${OUTDIR}/tmpout.nc
ncrename -O -h -v  ${ncvar},${ncvar}${ftype} ${OUTDIR}/tmpout.nc
ncks -h -A -v ${ncvar}${ftype} ${OUTDIR}/tmpout.nc  ${OUTDIR}/${INFILE}  


#*****************************************
#* filter data
#*****************************************
   echo 'filter data'
   filter_data  ${INDIR} ${INFILE} $ix $iy $ncvar $FINDIR $FIFILE $ftype ${OUTDIR}



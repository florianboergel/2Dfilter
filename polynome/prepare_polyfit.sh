#!/bin/ksh
#

if [ $# -ne 7 ]
then
  echo
  echo 'Wrong number of arguments!'

  echo
  echo 'Usage: prepare_polyfit.sh <indir> <infile> <outdir> <gridpts in x> <gridpts in y> <variable> <polyorder>'
  echo

    echo 'indir - input directory'
    echo 'infile - input file name' 
    echo 'outdir - output directory'   
    echo 'gridpts in x - number of gridpoints in x direction (spongezone included) -> see infile'
    echo 'gridpts in y - number of gridpoints in y direction (spongezone included) -> see infile'
    echo 'variable - name variable in input file to be filtered'
    echo 'polyorder- order of apllied polynom'
    echo
  exit
fi


INDIR=$1
INFILE=$2
OUTDIR=$3
ix=$4
iy=$5
ncvar=${6}
kpm=${7}



#*****************************************
#* data preparation
#*****************************************

if [ ! -f ${OUTDIR}/K${kpm}_${INFILE} ]
  then
  cp ${INDIR}/${INFILE} ${OUTDIR}/K${kpm}_${INFILE}
  else 
  echo WARNING: ${OUTDIR}/K${kpm}_${INFILE} exists.
fi

echo K${kpm}_$ncvar will be attached to  ${OUTDIR}/${INFILE} and contains input field reduced by polynom of ${kpm}. order.
echo

ncks -h -O -v $ncvar ${OUTDIR}/K${kpm}_${INFILE} ${OUTDIR}/tmpout.nc
ncrename -O -h -v  ${ncvar},K${kpm}_${ncvar} ${OUTDIR}/tmpout.nc
ncks -h -A -v K${kpm}_${ncvar} ${OUTDIR}/tmpout.nc  ${OUTDIR}/K${kpm}_${INFILE}  
ncrename -O -h -v  K${kpm}_${ncvar},K${kpm}_POLYNOM_${ncvar} ${OUTDIR}/tmpout.nc
ncks -h -A -v K${kpm}_POLYNOM_${ncvar} ${OUTDIR}/tmpout.nc ${OUTDIR}/K${kpm}_${INFILE}  

#*****************************************
#* filter data
#*****************************************
   echo 'run "polyfit"'
   polyfit  ${INDIR} ${INFILE} $ix $iy $ncvar $kpm ${OUTDIR}



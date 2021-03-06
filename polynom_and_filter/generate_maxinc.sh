#!/bin/ksh
#

if [ $# -ne 7 ]
then
  echo
  echo 'wrong number of arguments'

  echo
  echo 'usage: generate.sh <spzone> <gridpts in x> <gridpts in y> <wn in x> <wn in y> <filter type (l-low/b-band/h-high)> <outdir>'

    echo
    echo 'spzone - number of gridpoints used for spongezone'
    echo 'gridpts in x - number of gridpoints in x direction (spongezone included) -> see infile'
    echo 'gridpts in y - number of gridpoints in y direction (spongezone included) -> see infile'
    echo 'wn in x - wavenumbers in x direction (usually half of gridpoints in x)'
    echo 'wn in y - wavenumbers in y direction (usually half of gridpoints in y)' 
    echo 'filter type - press l for lowpass, b for bandpass and h for highpass'
    echo 'outdir - output directory'
    echo
exit
fi


#***************************************
#* define your area and wavenumbers
#***************************************

N=$1
ix=$2
iy=$3
k=$4
l=$5
ftype=$6
OUTDIR=$7

mkdir ${OUTDIR}/respfunct
mkdir ${OUTDIR}/filters

RESPDIR=${OUTDIR}/output/respfunct

typeset -Z3 iip
typeset -Z3 iio

#*****************************************
#* generate filter and response functions
#*****************************************
iip=1
count=1
if [ -e "frame_${ftype}passfilter_${N}_${ix}x${iy}_${k}x${l}.txt" ]; then rm frame_${ftype}passfilter_${N}_${ix}x${iy}_${k}x${l}.txt; fi
touch frame_${ftype}passfilter_${N}_${ix}x${iy}_${k}x${l}.txt

while [ ${iip} -le $k ]
do 
  iio=1
  while [ ${iio} -le $l ]
  do 
     iiochar=`expr ${iio}`
     iipchar=`expr ${iip}`

  if [ ${iip} -ge  ${iio} ]
  then
  echo iio=${iip} and iio=${iio}
  echo Value of upper wave number is smaller than or equal to value of lower wave number. No response function created.  
  else
  ./create_filter $OUTDIR $N $ix $iy $k $l $iipchar $iiochar $ftype 

  echo working at iip=${iip} and iio=${iio}
  echo 
  cp ${OUTDIR}/respfunct/respfunct.nc ${OUTDIR}/respfunct/${ftype}r_${ix}x${iy}_${N}_${k}x${l}_${iip}x${iio}.nc
  cp ${OUTDIR}/filters/filter.nc  ${OUTDIR}/filters/${ftype}f_${ix}x${iy}_${N}_${k}x${l}_${iip}x${iio}.nc

  cdo info ${OUTDIR}/respfunct/${ftype}r_${ix}x${iy}_${N}_${k}x${l}_${iip}x${iio}.nc > t1
  #MAX=`tail -1 t1 | awk '{print $12}'`
  MAX=`sed '2q;d' t1 | awk '{print $11}'`
  #MIN=`tail -1 t1 | awk '{print $10}'`
  MIN=`sed '2q;d' t1 | awk '{print $9}'`
  echo Minimum value of response function = ${MIN}  
  echo Maximum value of response function = ${MAX}  
  echo

  #if [[ ! -z "${MAX// }" ]];
  #then
  #	echo "string not empty."
  #if [ ${MAX} -lt 1.0000 -o ${MAX} -gt 1.1000 -o ${MIN} -lt -0.5000 -o ${MIN} -gt 0.1000 ]
  #if [ "${MAX}" -lt "1.0000" -o "${MAX}" -gt "1.1000" -o "${MIN}" -lt "-0.5000" -o "${MIN}" -gt "0.1000" ]
  cond1=$(($(echo "${MAX} <= 1.0000" | bc)))
  cond2=$(($(echo "${MAX} > 2.1000" | bc)))
  #cond2=$(($(echo "${MAX} > 1.1000" | bc)))
  cond3=$(($(echo "${MIN} < -0.5000" | bc)))
  cond4=$(($(echo "${MIN} > 0.1000" | bc)))
  echo $cond1 $cond2 $cond3 $cond4
  	if [[ ${cond1} == 1 || ${cond2} == 1 || ${cond3} == 1 || ${cond4} == 1 ]]
  	then
  	  rm  ${OUTDIR}/respfunct/${ftype}r_${ix}x${iy}_${N}_${k}x${l}_${iip}x${iio}.nc
  	  rm  ${OUTDIR}/filters/${ftype}f_${ix}x${iy}_${N}_${k}x${l}_${iip}x${iio}.nc
  	  echo Minimum or maximum value of response function for iip=${iip} and iio=${iio} out of range. files deleted.
  	else 
  	  echo $count $iip $iio >> frame_${ftype}passfilter_${N}_${ix}x${iy}_${k}x${l}.txt
  	  count=$((count+1))
  	fi  
  fi

  echo
  iio=`expr ${iio} + 1`
  done
 iip=`expr ${iip} + 1`
done



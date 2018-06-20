-------------------------------------------------------------------------------
Polyfit subtraction of polynomials README:
------------------------------------------

(C) Hans von Storch, Frauke Feser and Ivonne Anders, GKSS Research Center, 
Geesthacht, Germany,  2006

The polynomials subtraction package polyfit.tar contains the following 
scripts and programs:

prepare_polyfit.sh - script to subtract the polynomials
polyfit.f90        - Fortran 90 program to calculate the polynomials
README.txt         - Documentation

-------------------------------------------------------------------------------

SYSTEM REQUIREMENTS - Following libraries and tools should be installed:
------------------------------------------------------------------------
Korn-Shell
NetCDF-Libraries (http://www.unidata.ucar.edu/software/netcdf/)
NCO (http://nco.sourceforge.net/)
ncview and ncdump (e.g. http://www.opendap.org/download/nc_clients.html or 
http://meteora.ucsd.edu/%7Epierce/ncview_home_page.html)
CDO (http://www.mpimet.mpg.de/fileadmin/software/cdo/).


FILE REQUIREMENTS:
------------------
NetCDF-file. Variable to be reduced by polynomial should only depend on 
longitude, latitude and time, in exactly this order (!). 
Use 'ncdump -h <file>' to check. See example below to compare. 
Attention: If the variable depends on a level, e.g. float T_2M(time, 
height_2m,rlat, rlon) ; 
use 'ncwa -v T_2M -y avg -a height_2m <infile> <outfile>'. 
The values of the variable will not be changed.   

Example:

dimensions:
        rlon = 105 ;
        rlat = 115 ;
        time = UNLIMITED ; // (1460 currently)
variables:
        float rlon(rlon) ;
                rlon:long_name = "rotated longitude" ;
                rlon:units = "degrees" ;
                rlon:standard_name = "longitude" ;
        float rlat(rlat) ;
                rlat:long_name = "rotated latitude" ;
                rlat:units = "degrees" ;
                rlat:standard_name = "latitude" ;
        double time(time) ;
                time:units = "seconds since 1995-01-01 00:00" ;
        float T_2M(time, rlat, rlon) ;
                T_2M:long_name = "2m temperature" ;
                T_2M:standard_name = "air_temperature" ;
                T_2M:units = "K" ;

-------------------------------------------------------------------------------

STEP 1:
-------

POLYNOMIAL CALCULATION PROGRAM COMPILATION (polyfit.f90):
---------------------------------------------------------
f90 -o polyfit polyfit.f90 < netCDF-libraries >
For < netCDF-libraries > you have to include your specific netCDF-libraries 
paths, e.g. they should look like
.../netcdf/netcdf-3.5.1 .../include .../lib/libnccf.a .../lib/libnetcdf.a


STEP 2:
-------

POLYNOMIAL SCRIPT APPLICATION:
------------------------------

The directory contains the shell-script: 'prepare_polyfit.sh' using the 
Fortran90-Program 'polyfit.f90'.

****************************
*  prepare_polyfit.sh
****************************

--> type 'prepare_polyfit.sh' and press 'Enter' to see instructions.

This shell-script calculates the requested polynomials and subtracts them 
from the input data. 

Usage: prepare_polyfit.sh <indir> <infile> <outdir> <gridpts in x> 
<gridpts in y> <variable> <polyorder>

indir - input directory
infile - input file name
outdir - output directory
gridpts in x - number of gridpoints in x direction (spongezone included) 
-> see infile
gridpts in y - number of gridpoints in y direction (spongezone included) 
-> see infile
variable - name variable in input file to be reduced by polynomial
polyorder - order of applied polynom (a value of 2 (quadratic polynomial)
            may give good results)

After finishing the script, you will find the output file in the output 
directory. Names start with K, followed by the number for the chosen 
polynomial. Normally a value of 2 will give good results. 

e.g. K2_<filename>.nc

Use e.g. 'ncview K2_<filename>.nc' to view the polynomial 
(name is K<number of chosen polynomial>_POLYNOM_<variable name>) 
and the input field after subtraction of the polynomial
(name is K<number of chosen polynomial>_<variable name>). 

STEP 3:
-------

Now the reduced field can be filtered (see isofilternew.tar).


-------------------------------------------------------------------------------

Literature:
-----------
                           
     A spatial two-dimensional discrete filter for limited area model 
     evaluation purposes                                              
     Frauke Feser and Hans von Storch                                 
     Monthly Weather Review, 133(6), 1774-1786, 2005.   

     Enhanced detectability of added value in limited area model results 
     separated into different spatial scales
     Frauke Feser
     Monthly Weather Review, 134(8), 2180-2190, 2006.             

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
Isotropic digital filter README:
--------------------------------

(C) Frauke Feser and Ivonne Anders, GKSS Research Center, Geesthacht, 
Germany,  2006

The filter package isofilter.tar contains the following scripts and programs:

generate.sh       - script to calculate all possible response functions
filter_data.sh    - script to filter the data
create_filter.f90 - Fortran 90 program of the isotropic digital filter
filter_data.f90   - Fortran 90 program to filter the data
README.txt        - Documentation

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
NetCDF-file. Variable to filter should only depend on longitude, latitude 
and time, in exactly this order (!). Use 'ncdump -h <file>' to check. See 
example bellow to compare. 
Attention: If the variable depends on a level, e.g.  float T_2M(time, 
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

FILTER CREATION PROGRAM COMPILATION (create_filter.f90):
--------------------------------------------------------
f90 -o create_filter create_filter.f90 < netCDF-libraries >
For < netCDF-libraries > you have to include your specific netCDF-libraries 
paths, e.g. they should look like
.../netcdf/netcdf-3.5.1 .../include .../lib/libnccf.a .../lib/libnetcdf.a

FILTER APPLICATION PROGRAM COMPILATION (filter_data.f90):
---------------------------------------------------------
f90 -o filter_data filter_data.f90 < netCDF-libraries >
For < netCDF-libraries > you have to include your specific netCDF-libraries 
paths, e.g. they should look like
.../netcdf/netcdf-3.5.1 .../include .../lib/libnccf.a .../lib/libnetcdf.a


STEP 2:
-------

FILTER SCRIPT APPLICATIONS:
---------------------------

The directory contains two shell-scripts: 'generate.sh' using the 
Fortran90-Program 'create_filter' and 'filter_data.sh' using the 
Fortran90-Program 'filter_data'.

****************************
*  generate.sh
****************************

--> type 'generate.sh' and press 'Enter' to see instructions.

This shell-script calculates all possible response functions. 
You need to define the number of grid points used for the sponge zone 
(this is equivalent to half the resulting filter size), number of grid 
points of the field you want to filter, maximum wave numbers for your 
area (usually it is half the number of grid points), filter type 
(press 'l' for lowpass, 'b' for bandpass and 'h' for highpass) and an 
output directory.

* usage: generate.sh <spzone> <gridpts in x> <gridpts in y> <wn in x> 
<wn in y> <filter type (l-low/b-band/h-high)> <outdir>
* 
* spzone - number of gridpoints used for spongezone
* gridpts in x - number of gridpoints in x direction (spongezone included) 
-> see infile
* gridpts in y - number of gridpoints in y direction (spongezone included) 
-> see infile
* wn in x - wavenumbers in x direction (usually half of gridpoints in x)
* wn in y - wavenumbers in y direction (usually half of gridpoints in y)
* filter type - press l for lowpass, b for bandpass and h for highpass
* outdir - output directory

Even if you have not a square model area, please use for the filter creation
(just here, for the filter application please use the real grid point numbers)
the same number for gridpts in x and gridpts in y as well as for wn in x 
and wn in y (e.g. for a model area of gridpts in x = 150 and gridpts in y= 200
use gridpts in x = 150 and gridpts in y = 150 and use wn in x = 75 and 
wn in y = 75).

The script creates two directories within your output directory: 'respfunct' 
and 'filters'.
After finishing the script, you will find all response functions and filters 
there. Names start with the letter of used filter type, followed by 'r' for 
'response function' or 'f' for 'filter'. After that you see the number of 
grid points in x- and y-direction, sponge zone, maximum wave numbers. You 
will need the last two values to filter the variable.

e.g. hr_105x115_10_50x50_01x06.nc

Choose an appropriate response function to find correct values for filtering. 
To make it easier use:  
'ncecat -h <outdir>/respfunct/l*.nc l.nc'  --> for all response functions for 
low pass filtering  
'ncecat -h <outdir>/respfunct/b*.nc b.nc'  --> for all response functions for 
band pass filtering  
'ncecat -h <outdir>/respfunct/h*.nc h.nc'  --> for all response functions for 
high pass filtering  

Use e.g. 'ncview l.nc' to view all low pass response functions and choose 
that one which fits your requirements. Remember the values for 'iio' and 
'iip' (you have to choose the ones according to the selected response 
function, e.g. if you choose the response function with record number 10, 
take iio and iip for record number 10 as well) for the filter application 
in step 3. These values will be different for the different filter types!

To estimate the spatial scales of wave numbers to be filtered (gridpts in x 
=gridpts in y as used in generate.sh):
spatial scales in x(=y) [km] = (gridpts in x(=y) * dx(=dy)[km])/wave number 
in x(=y)

STEP 3:
-------

Now use 'filter_data.sh' to filter your data.
****************************
*  filter_data.sh
****************************

Before filtering your data the script will make a copy of your input file 
to the output directory. A new variable will be attached to your output file, 
by copying and renaming the original field; e.g. the outfile contains one 
additional variable in comparison with the original input file. The new 
variable name is the name of the one you want to filter plus one letter for 
the used filter type e.g. T_2M --> T_2Mh 
For all of these actions NCO needs to be installed (see System Requirements 
above).

Similar to 'generate.sh' you need to define different parameters:
input directory, name of input file, output directory, gridpoints in x- 
and y- direction, variable to filter, filter input directory, and filter 
type. 

* usage: filter_data.sh <indir> <infile> <outdir> <gridpts in x> 
<gridpts in y> <variable> <filter indir> <filterfile> <filtertype>
* 
* 'indir - input directory'
* 'infile - input file name' 
* 'outdir - output directory'   
* 'gridpts in x - number of gridpoints in x direction (spongezone included) 
-> see infile'
* 'gridpts in y - number of gridpoints in y direction (spongezone included) 
-> see infile'
* 'variable - name variable in input file to be filtered'
* 'filter indir - filter input directory'
* 'filterfile - filter file name'    
* 'filter type - press l for lowpass, b for bandpass and h for highpass'


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

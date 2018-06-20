# Script to plot examples of filtered fields
# 
# 1) Plot filtered field examples
#
# JKe 01-02-2017

rm(list=ls())

library(fields)
library(ncdf)
source("/perm/ms/spde/de5j/tools/analysis-tools/r-programs/r_colors.r")
setwd("/perm/ms/spde/de5j/tools/analysis-tools/r-programs")

# Settings 
  expid		= "MODIS2000_HFD1_3D_sn_v03l"
  yyyy		= "2003"
  mm		= "06"
  level		= "50"
  var 		= "T"

  # low-pass filtered data 
  lfindir	= sprintf("/scratch/ms/spde/de5j/filtered_data_316x316_158x158_N8/%s/%s/lf_316x316_8_158x158_006x043",expid,var)
  lfinfile 	= sprintf("%s/tsmp_out_cosmo_%s_%s-%s_focusdomain_316x316_sellev_%sd.nc",lfindir,var,yyyy,mm,level)
  # band-pass filtered data  
  bfindir	= sprintf("/scratch/ms/spde/de5j/filtered_data_316x316_158x158_N8/%s/%s/bf_316x316_8_158x158_020x150_sublowpass",expid,var)
  bfinfile 	= sprintf("%s/tsmp_out_cosmo_d%s_%s-%s_focusdomain_316x316_sellev_%sd.nc",bfindir,var,yyyy,mm,level)

# Read data from netcdf
  # unfiltered field
  ifile		= lfinfile
  ncfile	= open.ncdf(ifile)
  t_unf		= get.var.ncdf(ncfile,"T")
  # low pass filtered field
  ifile		= lfinfile
  ncfile	= open.ncdf(ifile)
  t_lf		= get.var.ncdf(ncfile,"Tl")
  t_lf[1:9,,]=NA
  t_lf[,1:9,]=NA
  t_lf[308:316,,]=NA
  t_lf[,308:316,]=NA
  # band pass filtered field 
  ifile		= bfinfile
  ncfile	= open.ncdf(ifile)
  t_dlf		= get.var.ncdf(ncfile,"dTl")
  t_dlf[1:9,,]=NA
  t_dlf[,1:9,]=NA
  t_dlf[308:316,,]=NA
  t_dlf[,308:316,]=NA
  t_dlbf	= get.var.ncdf(ncfile,"dTlb")
  t_dlbf[1:16,,]=NA
  t_dlbf[,1:16,]=NA
  t_dlbf[300:316,,]=NA
  t_dlbf[,300:316,]=NA



##***************
## 1. Sample plots

# Unfiltered
ofile="Filtered_temperature_fields_examples_HFD1_3D_sn_v03l_2003-06-01_16UTC_unfiltered.pdf"
pdf(sprintf("plots/%s",ofile),width=7.5,height=6.0,onefile = TRUE, family = "sans", fonts = NULL, version = "1.1", pointsize=14,title="Example of an unfiltered temperature field")
par(mfrow=c(1,1),mar=c(0.25,0.25,0.50,2.5),oma=c(0,0,0,0),mgp=c(1.05,0.75,0))
  image.plot(t_unf[,,16],col=corcol,xlab="",ylab="",xaxt="n",yaxt="n",zlim=c(260,310))  
dev.off()

# Low-pass
ofile="Filtered_temperature_fields_examples_HFD1_3D_sn_v03l_2003-06-01_16UTC_low-pass-filtered.pdf"
pdf(sprintf("plots/%s",ofile),width=7.5,height=6.0,onefile = TRUE, family = "sans", fonts = NULL, version = "1.1", pointsize=14,title="Example of an unfiltered temperature field")
par(mfrow=c(1,1),mar=c(0.25,0.25,0.50,2.5),oma=c(0,0,0,0),mgp=c(1.05,0.75,0))
  image.plot(t_lf[,,16],col=corcol,xlab="",ylab="",xaxt="n",yaxt="n",zlim=c(260,310))  
  #image.plot(t_dlf[,,16],col=corcol,xlab="",ylab="",xaxt="n",yaxt="n")  
  #image.plot(t_dlbf[,,16],col=twocol,xlab="",ylab="",xaxt="n",yaxt="n",zlim=c(-10,10))  
dev.off()

# Diff to low-pass
ofile="Filtered_temperature_fields_examples_HFD1_3D_sn_v03l_2003-06-01_16UTC_low-pass-difference.pdf"
pdf(sprintf("plots/%s",ofile),width=7.5,height=6.0,onefile = TRUE, family = "sans", fonts = NULL, version = "1.1", pointsize=14,title="Example of an unfiltered temperature field")
par(mfrow=c(1,1),mar=c(0.25,0.25,0.50,2.5),oma=c(0,0,0,0),mgp=c(1.05,0.75,0))
  image.plot(t_dlf[,,16],col=corcol,xlab="",ylab="",xaxt="n",yaxt="n")  
  #image.plot(t_dlbf[,,16],col=twocol,xlab="",ylab="",xaxt="n",yaxt="n",zlim=c(-10,10))  
dev.off()

# band-pass 
ofile="Filtered_temperature_fields_examples_HFD1_3D_sn_v03l_2003-06-01_16UTC_band-pass-filtered-difference.pdf"
pdf(sprintf("plots/%s",ofile),width=7.5,height=6.0,onefile = TRUE, family = "sans", fonts = NULL, version = "1.1", pointsize=14,title="Example of an unfiltered temperature field")
par(mfrow=c(1,1),mar=c(0.25,0.25,0.50,2.5),oma=c(0,0,0,0),mgp=c(1.05,0.75,0))
  #image.plot(t_dlbf[,,16],col=twocol,xlab="",ylab="",xaxt="n",yaxt="n",zlim=c(-10,10))  
  image.plot(t_dlbf[,,16],col=corcol,xlab="",ylab="",xaxt="n",yaxt="n",zlim=c(-10,10))  
dev.off()


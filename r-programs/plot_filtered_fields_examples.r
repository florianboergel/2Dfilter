# Script to plot examples of filtered fields
# 
# 1) Plot filtered field examples
# 2) Calculate correlations as land-atmosphere-coupling indicators
#    for a set of unfiltered and filteres fields. 
#    - Correlation between T(level50) and LE(unfiltered, because masked from CLM)
#
# JKe 27-01-2017

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
  lfinfile 	= sprintf("%s/K1_tsmp_out_cosmo_%s_%s-%s_focusdomain_316x316_sellev_%sd.nc",lfindir,var,yyyy,mm,level)
  # band-pass filtered data (1) 
  bfindir1	= sprintf("/scratch/ms/spde/de5j/filtered_data_316x316_158x158_N8/%s/%s/bf_316x316_8_158x158_039x150",expid,var)
  bfinfile1 	= sprintf("%s/K1_tsmp_out_cosmo_%s_%s-%s_focusdomain_316x316_sellev_%sd.nc",bfindir1,var,yyyy,mm,level)
  # band-pass filtered data (2) 
  bfindir2	= sprintf("/scratch/ms/spde/de5j/filtered_data_316x316_158x158_N8/%s/%s/bf_316x316_8_158x158_020x150",expid,var)
  bfinfile2 	= sprintf("%s/K1_tsmp_out_cosmo_%s_%s-%s_focusdomain_316x316_sellev_%sd.nc",bfindir2,var,yyyy,mm,level)
  # band-pass-filtered data (3) (-low pass filtered field, with spatial trend)
  bindir3 	= bfindir2 
  bfinfile3 	= sprintf("%s/dK1_tsmp_out_cosmo_%s_%s-%s_focusdomain_316x316_sellev_%sd.nc",bfindir2,var,yyyy,mm,level)
  # band-pass-filtered data (4) (-low pass filtered field, without spatial trend (-P on))
  bindir4 	= bfindir2
  bfinfile4 	= sprintf("%s/dKK1_tsmp_out_cosmo_%s_%s-%s_focusdomain_316x316_sellev_%sd.nc",bfindir2,var,yyyy,mm,level)

# Read data from netcdf
  # unfiltered field
  ifile		= lfinfile
  ncfile	= open.ncdf(ifile)
  t_unf		= get.var.ncdf(ncfile,"T")[9:307,9:307,]
  # polynom
  tpoly1 	= get.var.ncdf(ncfile,"K1_POLYNOM_T")[9:307,9:307,]
  # low pass filtered field
  ifile		= lfinfile
  ncfile	= open.ncdf(ifile)
  t_lf		= get.var.ncdf(ncfile,"Tl")[9:307,9:307,]
  t_klf		= get.var.ncdf(ncfile,"K1_Tl")[9:307,9:307,]
  # band pass filtered field (1) 
  ifile		= bfinfile1
  ncfile	= open.ncdf(ifile)
  t_bf1		= get.var.ncdf(ncfile,"Tb")[9:307,9:307,]
  t_kbf1	= get.var.ncdf(ncfile,"K1_Tb")[9:307,9:307,]
  # band pass filtered field (2) 
  ifile		= bfinfile2
  ncfile	= open.ncdf(ifile)
  t_bf2		= get.var.ncdf(ncfile,"Tb")[9:307,9:307,]
  t_kbf2	= get.var.ncdf(ncfile,"K1_Tb")[9:307,9:307,]
  # band pass filtered field (3) 
  ifile		= bfinfile3
  ncfile	= open.ncdf(ifile)
  t_blf3	= get.var.ncdf(ncfile,"dTlb")[19:(316-19),19:(316-19),]
  # band pass filtered field (4) 
  ifile         = bfinfile4
  ncfile        = open.ncdf(ifile)
  t_kblf4	= get.var.ncdf(ncfile,"dK1_Tlb")[19:(316-19),19:(316-19),]



##***************
## 1. Sample plots

# Plot sample images 
ofile="Filtered_temperature_fields_examples_HFD1_3D_sn_v03l_2003-06-01_16UTC.pdf"
pdf(sprintf("plots/%s",ofile),width=14.5,height=6.0,onefile = TRUE, family = "sans", fonts = NULL, version = "1.1", pointsize=14,title="Filtered temperature fields")
par(mfrow=c(2,4),mar=c(0.25,0.25,0.50,3.5),oma=c(0,0,0,1.0),mgp=c(1.05,0.75,0))
  image.plot(t_unf[,,16],col=corcol,xlab="",ylab="",xaxt="n",yaxt="n")  
   mtext("a. unfiltered",side=3,padj=0,adj=0,cex=0.75,line=-1.0)
  image.plot(t_lf[,,16],col=corcol,xlab="",ylab="",xaxt="n",yaxt="n")  
   mtext("b. low-pass-filtered",side=3,padj=0,adj=0,cex=0.75,line=-1.0)
  image.plot(t_bf1[,,16],col=corcol,xlab="",ylab="",xaxt="n",yaxt="n")  
   mtext("c. band-pass-filtered (26-100km)",side=3,padj=0,adj=0,cex=0.75,line=-1.0)
  image.plot(t_bf2[,,16],col=corcol,xlab="",ylab="",xaxt="n",yaxt="n")  
   mtext("d. band-pass-filtered (26-200km)",side=3,padj=0,adj=0,cex=0.75,line=-1.0)
  image.plot(tpoly1[,,16],col=corcol,xlab="",ylab="",xaxt="n",yaxt="n")  
   mtext("e. 1st order polynomial",side=3,padj=0,adj=0,cex=0.75,line=-1.0)
  image.plot(t_klf[,,16],col=corcol,xlab="",ylab="",xaxt="n",yaxt="n")  
   mtext("f. low-pass-filtered (-P)",side=3,padj=0,adj=0,cex=0.75,line=-1.0)
  image.plot(t_kbf1[,,16],col=corcol,xlab="",ylab="",xaxt="n",yaxt="n")  
   mtext("g. band-pass-filtered (26-100km)(-P)",side=3,padj=0,adj=0,cex=0.75,line=-1.0)
  image.plot(t_kbf2[,,16],col=corcol,xlab="",ylab="",xaxt="n",yaxt="n")  
   mtext("h. band-pass-filtered (26-200km)(-P)",side=3,padj=0,adj=0,cex=0.75,line=-1.0)
dev.off()

# Plot sample images all 
ofile="Filtered_temperature_fields_examples_HFD1_3D_sn_v03l_2003-06-01_16UTC_expanded.pdf"
pdf(sprintf("plots/%s",ofile),width=18,height=6.0,onefile = TRUE, family = "sans", fonts = NULL, version = "1.1", pointsize=14,title="Filtered temperature fields")
par(mfrow=c(2,5),mar=c(0.25,0.25,0.50,3.5),oma=c(0,0,0,1.0),mgp=c(1.05,0.75,0))
  image.plot(t_unf[,,16],col=corcol,xlab="",ylab="",xaxt="n",yaxt="n")  
   mtext("a. unfiltered",side=3,padj=0,adj=0,cex=0.75,line=-1.0)
  image.plot(t_lf[,,16],col=corcol,xlab="",ylab="",xaxt="n",yaxt="n")  
   mtext("b. low-pass-filtered",side=3,padj=0,adj=0,cex=0.75,line=-1.0)
  image.plot(t_bf1[,,16],col=corcol,xlab="",ylab="",xaxt="n",yaxt="n")  
   mtext("c. band-pass-filtered (26-100km)",side=3,padj=0,adj=0,cex=0.75,line=-1.0)
  image.plot(t_bf2[,,16],col=corcol,xlab="",ylab="",xaxt="n",yaxt="n")  
   mtext("d. band-pass-filtered (26-200km)",side=3,padj=0,adj=0,cex=0.75,line=-1.0)
  image.plot(t_blf3[,,16],col=corcol,xlab="",ylab="",xaxt="n",yaxt="n")  
   mtext("e. band-pass-filtered (26-200km)(-lp)",side=3,padj=0,adj=0,cex=0.75,line=-1.0)
  image.plot(tpoly1[,,16],col=corcol,xlab="",ylab="",xaxt="n",yaxt="n")  
   mtext("f. 1st order polynomial",side=3,padj=0,adj=0,cex=0.75,line=-1.0)
  image.plot(t_klf[,,16],col=corcol,xlab="",ylab="",xaxt="n",yaxt="n")  
   mtext("g. low-pass-filtered (-P)",side=3,padj=0,adj=0,cex=0.75,line=-1.0)
  image.plot(t_kbf1[,,16],col=corcol,xlab="",ylab="",xaxt="n",yaxt="n")  
   mtext("h. band-pass-filtered (26-100km)(-P)",side=3,padj=0,adj=0,cex=0.75,line=-1.0)
  image.plot(t_kbf2[,,16],col=corcol,xlab="",ylab="",xaxt="n",yaxt="n")  
   mtext("i. band-pass-filtered (26-200km)(-P)",side=3,padj=0,adj=0,cex=0.75,line=-1.0)
  image.plot(t_kblf4[,,16],col=corcol,xlab="",ylab="",xaxt="n",yaxt="n")  
   mtext("j. band-pass-filtered (26-200km)(-Plp))",side=3,padj=0,adj=0,cex=0.75,line=-1.0)
dev.off()



##***************
## 2. Correlations

# # Calculate hourly correlations
# sigcors = function(x,y,alpha=0.95){
#    # this function checks for significant correlations between x and y 
#    # x,y: 3-d arrays of dim(nlon,nlat,time)
#    # result: array of dim(nlon,nlat) with significant correlations only
#    # according to http://janda.org/c10/Lectures/topic06/L24-significanceR.htm
#      res       = array(NA,c(dim(x)[1],dim(x)[2]))
#      for (i in 1:(dim(x))[1]){
#        for (j in 1:(dim(x))[2]){
#          if(all(is.na(x[i,j,]))|all(is.na(y[i,j,]))){res[i,j]=NA}else{
#            mycor = cor.test(x[i,j,],y[i,j,],use="pairwise.complete.obs")
#            if(!is.na(mycor$estimate)&(mycor$p.value<0.05)){res[i,j]= mycor$estimate}else{res[i,j]=NA}
#          }
#      }}
# return(res)}
# 
# # Read latent heat flux
#  ifile 	= sprintf("/scratch/ms/spde/de5j/terrsysmp_run/cordex_1.2.0MCT_clm-cos-pfl_MODIS2000_HFD1_3D_sn_v03l/output/pp/focusdomain/clm_out/hourly/tsmp_out_clm_FLE_2003-06_focusdomain_316x316.nc")
#  ncfile 	= open.ncdf(ifile)
#  fle_unf	= get.var.ncdf(ncfile,"FLE")[9:307,9:307,]
#
# # Correlations
# cor_unf	= sigcors(t_unf ,fle_unf)
# cor_lf 	= sigcors(t_lf  ,fle_unf)
# cor_bf1 	= sigcors(t_bf1 ,fle_unf)
# cor_bf2 	= sigcors(t_bf2 ,fle_unf)
# cor_klf 	= sigcors(t_klf ,fle_unf)
# cor_kbf1 	= sigcors(t_kbf1,fle_unf)
# cor_kbf2 	= sigcors(t_kbf2,fle_unf)
#
## Plot correlations
#ofile="Correlation_filtered_temperature_fields_to_FLE_examples_HFD1_3D_sn_v03l_2003-06.pdf"
#pdf(sprintf("plots/%s",ofile),width=14.5,height=5.0,onefile = TRUE, family = "sans", fonts = NULL, version = "1.1", pointsize=14,title="Correlation T-FLE for filtered data")
#par(mfrow=c(2,4),mar=c(0.25,0.25,0.50,3.5),oma=c(0,0,0,1.0),mgp=c(1.05,0.75,0))
#  image.plot(cor_unf[,],col=twocol,xlab="",ylab="",xaxt="n",yaxt="n",zlim=c(-1,1))  
#   mtext("a. unfiltered",side=3,padj=0,adj=0,cex=0.75,line=-1)
#  image.plot(cor_lf[,],col=twocol,xlab="",ylab="",xaxt="n",yaxt="n",zlim=c(-1,1))  
#   mtext("b. low-pass-filtered",side=3,padj=0,adj=0,cex=0.75,line=-1)
#  image.plot(cor_bf1[,],col=twocol,xlab="",ylab="",xaxt="n",yaxt="n",zlim=c(-1,1))  
#   mtext("c. band-pass-filtered (26-100km)",side=3,padj=0,adj=0,cex=0.75,line=-1.0)
#  image.plot(cor_bf2[,],col=twocol,xlab="",ylab="",xaxt="n",yaxt="n",zlim=c(-1,1))  
#   mtext("d. band-pass-filtered (26-200km)",side=3,padj=0,adj=0,cex=0.75,line=-1.0)
#  frame()
#  #image.plot(tpoly1[,,16],col=twocol,xlab="",ylab="",xaxt="n",yaxt="n",zlim=c(-1,1))  
#   #mtext("e. 1st order polynomial",side=3,padj=0,adj=0,cex=0.75,line=-1)
#  image.plot(cor_klf[,],col=twocol,xlab="",ylab="",xaxt="n",yaxt="n",zlim=c(-1,1))  
#   mtext("f. low-pass-filtered (-P)",side=3,padj=0,adj=0,cex=0.75,line=-1)
#  image.plot(cor_kbf1[,],col=twocol,xlab="",ylab="",xaxt="n",yaxt="n",zlim=c(-1,1))  
#   mtext("g. band-pass-filtered (26-100km)(-P)",side=3,padj=0,adj=0,cex=0.75,line=-1)
#  image.plot(cor_kbf2[,],col=twocol,xlab="",ylab="",xaxt="n",yaxt="n",zlim=c(-1,1))  
#   mtext("h. band-pass-filtered (26-200km)(-P)",side=3,padj=0,adj=0,cex=0.75,line=-1)
#dev.off()



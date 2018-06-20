PROGRAM filter_data


USE netcdf
IMPLICIT NONE

   INTEGER :: ix,iy,ia,ib,ic,id,ie,ii,n

   INTEGER :: ncid,ncidf,varID,varIDf,fivarID,timeID,lonID,status

   INTEGER :: iargc,timeLEN,lonLEN

   CHARACTER (len=200) :: d,filein,fileout,ncvar,ncvarf,filename,indir,outdir,filterdir,filtername, &
                          filterin,tmpout

   CHARACTER (len=10)  :: ftype

   REAL    :: PI

   REAL, ALLOCATABLE   :: feldin(:,:,:), ffilt(:,:,:), afg(:,:)

   REAL*8, ALLOCATABLE :: A(:,:), B(:,:), C(:,:)



   IF (iargc() < 9) THEN
    PRINT *, 'Error: too few arguments'
!    WRITE (*,*) 'Usage: filter_data <indir>'
    WRITE (*,*) 'Usage: filter_data <indir> <infile> <gridpts in x> <gridpts in y> <variable>' 
    PRINT *, ' <filter indir> <filterfile> <filtertype> <outdir>'
    PRINT *, '--------------------------------------' 
    PRINT *, 'indir - input directory'
    PRINT *, 'infile - input file name'    
    PRINT *, 'gridpts in x - number of gridpoints in x direction (spongezone incl) -> see infile'
    PRINT *, 'gridpts in y - number of gridpoints in y direction (spongezone incl) -> see infile'
    PRINT *, 'variable - name variable in input file to be filtered'
    PRINT *, 'filter indir - filter input directory'
    PRINT *, 'filterfile - filter file name'    
    PRINT *, 'filter type - press l for lowpass, b for bandpass and h for highpass'
    PRINT *, 'outdir - output directory'
    STOP
   ENDIF


      CALL getarg(1,indir)
      CALL getarg(2,d)
      READ(d,*) filename 
      CALL getarg(3,d)
      READ(d,*) ix
      CALL getarg(4,d) 
      READ(d,*) iy
      CALL getarg(5,d)
      READ(d,*) ncvar
      CALL getarg(6,filterdir)
      CALL getarg(7,d)
      READ(d,*) filtername 
      CALL getarg(8,d)
      READ(d,*) ftype
      CALL getarg(9,outdir)



      ncvarf=TRIM(ncvar)//ftype
      ncvar=TRIM(ncvar)
      filein = TRIM(indir)//'/'//TRIM(filename)
      tmpout= TRIM(outdir)//'/tmpout.nc'
      fileout= TRIM(outdir) //'/'//TRIM(filename)
      filterin= TRIM(filterdir)//'/'//TRIM(filtername)

      ALLOCATE(A(1:ix,1:iy),B(1:ix,1:iy),C(1:ix,1:iy))



      WRITE(*,*) 'opening filter file'
      status=nf90_open(filterin,nf90_nowrite,ncid)
      if(status /= nf90_noerr) call handle_err(status)
      status=nf90_inq_varid(ncid,"filter",fivarID)
      if(status /= nf90_noerr) call handle_err(status)       
      ! What is the dimension of the Filter?
         WRITE(*,*) '1.'
          status=nf90_inq_dimid(ncid,"x",lonID)
          !status=nf90_inq_dimid(ncid,"lon",lonID)
          if(status /= nf90_noerr) call handle_err(status) 
          status=nf90_inquire_dimension(ncid,lonID,len = lonLEN)
          if(status /= nf90_noerr) call handle_err(status)
          
          n=((lonLEN-1)/2)
          ALLOCATE(afg(-n:n,-n:n))

         WRITE(*,*) '2.'
      status=nf90_get_var(ncid,fivarID,afg)
      if(status /= nf90_noerr) call handle_err(status)
      status = nf90_close(ncid)
      if (status /= nf90_noerr) call handle_err(status)





      WRITE(*,*) 'opening data file'

       status=nf90_open(filein,nf90_nowrite,ncidf)
       if(status /= nf90_noerr) call handle_err(status)
       status=nf90_inq_varid(ncidf,TRIM(ncvar),varID)
       if(status /= nf90_noerr) call handle_err(status)
       status=nf90_inq_dimid(ncidf,"time",timeID)
       if(status /= nf90_noerr) call handle_err(status)
       status=nf90_inquire_dimension(ncidf,timeID,len = timeLEN)
       if(status /= nf90_noerr) call handle_err(status)

        ALLOCATE(feldin(ix,iy,timeLEN), ffilt(ix,iy,timeLEN))

       status=nf90_get_var(ncidf,varID,feldin)
       if(status /= nf90_noerr) call handle_err(status)
       status = nf90_close(ncidf)
       if (status /= nf90_noerr) call handle_err(status)



      WRITE(*,*) 'filtering data '
!      Initialisation:

       PI = 4.*ATAN(1.)
       DO ii=1,timeLEN

        DO ia=1,ix
          DO ib=1,iy
!            feldin(ia,ib,ii)=0.0
            ffilt(ia,ib,ii)=0.0
            A(ia,ib)=0.0
            B(ia,ib)=0.0
            C(ia,ib)=0.0
          END DO
        END DO

!     Calculate Filtered Function 
!     (Equation (4) in (Feser and von Storch, 2005)):

        DO ia=(n+1),ix-n
          DO ib=(n+1),iy-n
            DO ic=1,n
              A(ia,ib)= A(ia,ib)+afg(ic,0)* &
                  (feldin(ia,ib+ic,ii)+ &
                   feldin(ia,ib-ic,ii)+ &
                   feldin(ia+ic,ib,ii)+ &
                   feldin(ia-ic,ib,ii)) 
              B(ia,ib)= B(ia,ib)+afg(ic,ic)* &
                  (feldin(ia+ic,ib+ic,ii)+ &
                   feldin(ia+ic,ib-ic,ii)+ &
                   feldin(ia-ic,ib+ic,ii)+ &
                   feldin(ia-ic,ib-ic,ii))
            END DO
            DO id=2,n
              DO ie=1,id-1
                C(ia,ib)= C(ia,ib)+afg(id,ie)* &
                    (feldin(ia+id,ib+ie,ii)+ &
                     feldin(ia+id,ib-ie,ii)+ &
                     feldin(ia-id,ib+ie,ii)+ &
                     feldin(ia-id,ib-ie,ii)+ &
                     feldin(ia+ie,ib+id,ii)+ &
                     feldin(ia+ie,ib-id,ii)+ &
                     feldin(ia-ie,ib+id,ii)+ &
                     feldin(ia-ie,ib-id,ii))
              END DO
            END DO
          END DO
        END DO   

        DO ia=(n+1),ix-n
          DO ib=(n+1),iy-n
            ffilt(ia,ib,ii)=afg(0,0)*feldin(ia,ib,ii)+A(ia,ib)+B(ia,ib)+ &
                C(ia,ib)
            IF(feldin(ia,ib,ii).eq.9.E10)then
               ffilt(ia,ib,ii)=9.E10
            ENDIF
          END DO
        END DO


      END DO

!     Write Filtered Output Field:

       WRITE(*,*) 'writing data '

       status=nf90_open(fileout,nf90_write,ncidf)
       if(status /= nf90_noerr) call handle_err1(status)
       status=nf90_inq_varid(ncidf,ncvarf,varIDf)
       if(status /= nf90_noerr) call handle_err(status)
       status = nf90_put_var(ncidf,varIDf,ffilt)
       if(status /= nf90_NoErr) call handle_err(status)
       status = nf90_close(ncidf)
       if (status /= nf90_noerr) call handle_err(status)



      CONTAINS

!     HANDLE-ERR

      SUBROUTINE HANDLE_ERR(status)
      INTEGER, INTENT(IN) :: status
      IF (status /= nf90_noerr) THEN 
         PRINT *, 'error' !trim(nf90_strerror(status))
         STOP
      ENDIF
      END SUBROUTINE HANDLE_ERR

      SUBROUTINE HANDLE_ERR1(status)
      INTEGER, INTENT(IN) :: status
      IF (status /= nf90_noerr) THEN 
         PRINT *, trim(nf90_strerror(status))
         STOP
      ENDIF
      END SUBROUTINE HANDLE_ERR1

END PROGRAM filter_data
! (C) Copr. 1986-92 numerical Recipes Software "W#(1&.

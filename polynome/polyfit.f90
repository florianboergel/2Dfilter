PROGRAM polyfit

USE netcdf
IMPLICIT NONE

   INTEGER ::             & 
      nx,ny,              & ! field dimension
      n,                  & ! number of gridpoints 
      kpm,kpqm,           & ! maximum polynom order, number of maximum coefficients
      kp,                 & ! actual polynom order (used as loop var)  
      kpq,                & ! actual number of coefficients 
      ii,k,ks,i,j,ix,iy,  & ! loop variables
      t,iv,iw,            & ! loop variables
      iargc               ! number of arguments

   INTEGER ::             &
      ncid,ncido ,        & ! file IDs
      varID,varIDo,polIDo,& ! variable IDs
      timeID,             & ! variable ID for "time"
      status,             & ! status of NETCDF error messages
      timeLEN               ! number of timesteps 
   
   INTEGER, ALLOCATABLE :: &
      ni(:), nj(:)

   CHARACTER (len=200) :: &
      d,c,Knr,            & ! help variable for reading data 
      indir,outdir,       & ! directories of input and output 
      filename,           & ! file name (same for in and out file)
      filein,             & ! input data file  (indir+filename)
      actout,             & ! name of actual outfile 
      ncvar,              & ! name variable in input file to be reduced by polynom
      actoutvar,          & ! name of variable of actual reduced datafield in outfile
      actoutpol             ! name of variable of actual polynom in outfile


   REAL  ::  &
      varf,expf,varr,expr,var 
   
   REAL, ALLOCATABLE   :: &
        datax(:,:,:),     & ! input field of data 
        datar(:,:,:),     & ! input field of data reduced by polynom
        datap(:,:,:),     & ! Polynom
        am(:,:)             ! Matrix

   REAL, ALLOCATABLE :: &
         rh(:,:)

   IF (iargc() < 7) THEN
    PRINT *, 'Error: too few arguments'
    WRITE (*,*) 'Usage: polyfit <indir> <infile> <gridpts in x> <gridpts in y> <variable>' 
    PRINT *, ' <polyorder> <outdir>'
    PRINT *, '--------------------------------------' 
    PRINT *, 'indir - input directory'
    PRINT *, 'infile - input file name'    
    PRINT *, 'gridpts in x - number of gridpoints in x direction (spongezone incl) -> see infile'
    PRINT *, 'gridpts in y - number of gridpoints in y direction (spongezone incl) -> see infile'
    PRINT *, 'variable - name variable in input file to be reduced by polynom'
    PRINT *, 'polyorder - order of apllied polynom'
    PRINT *, 'outdir - output directory'
    STOP
   ENDIF


      CALL getarg(1,indir)
      CALL getarg(2,d)
      READ(d,*) filename 
      CALL getarg(3,d)
      READ(d,*) nx
      CALL getarg(4,d) 
      READ(d,*) ny
      CALL getarg(5,d)
      READ(d,*) ncvar
      CALL getarg(6,d)
      READ(d,*) kpm
      CALL getarg(7,outdir)



!      ncvarf=TRIM(ncvar)//ftype
      ncvar=TRIM(ncvar)
      filein = TRIM(indir)//'/'//TRIM(filename)

      kpqm=(kpm+1)*(kpm+2)/2 
      n=nx*ny

      ALLOCATE(ni(1:kpqm),nj(1:kpqm),rh(1:kpqm,1:1),am(1:kpqm,1:kpqm))
      
  
    WRITE(*,*) 'starting process'    
!    DO kp=1,kpm    ! start loop over number of maximum order of polynom
       
    	  kp=kpm
             WRITE(c,'(i1)') kp
             actout=TRIM(outdir)//'/K'//TRIM(c)//'_'//TRIM(filename)
             actoutvar='K'//TRIM(c)//'_'//TRIM(ncvar)
             actoutpol='K'//TRIM(c)//'_POLYNOM_'//TRIM(ncvar)

	   WRITE(*,*) 'opening data file', nx, ny

           status=nf90_open(filein,nf90_nowrite,ncid)
           if(status /= nf90_noerr) call handle_err1(status)
           status=nf90_inq_varid(ncid,TRIM(ncvar),varID)
           if(status /= nf90_noerr) call handle_err(status)
           status=nf90_inq_dimid(ncid,"time",timeID)
           if(status /= nf90_noerr) call handle_err(status)
           status=nf90_inquire_dimension(ncid,timeID,len = timeLEN)
           if(status /= nf90_noerr) call handle_err(status)

           ALLOCATE(datax(nx,ny,timeLEN), datap(nx,ny,timeLEN), datar(nx,ny,timeLEN))
!      Initializing output fields        
           iv=0
           iw=0
           t=0
           DO t=1,timeLEN
           DO iv=1,ix
           DO iw=1,iy
             datax(ix,iy,timeLEN)=0
             datap(ix,iy,timeLEN)=0
             datar(ix,iy,timeLEN)=0
           ENDDO
           ENDDO
           ENDDO
              
!           WRITE(*,*) timeLEN
!           WRITE(*,*) datax(5,5,2), datap(5,5,2), datar(5,5,2)            


           status=nf90_get_var(ncid,varID,datax)
           if(status /= nf90_noerr) call handle_err(status)

           ! close output file       
           WRITE(*,*) 'close input file'
           status = nf90_close(ncid)
           if (status /= nf90_noerr) call handle_err(status)
 
           ! open output file 
           WRITE(*,*) 'open ouput file ', actout
           status=nf90_open(actout,nf90_write,ncido) 
           if(status /= nf90_noerr) call handle_err(status)




         kpq = (kp+1)*(kp+2)/2
         WRITE(*,*) 'order of actual 2d-polynomial:', kp
         WRITE(*,*) 'number of coeffs:', kpq 

	 ! mapping of 2d index field on 1d index field    
         ii = 0
	 DO k=0,kp
	    DO ks=0,kp-k
	    ii=ii+1
	    ni(ii)=k
	    nj(ii)=ks
!            WRITE(*,*) 'kp,k,ii,ni(ii),nj(ii) ', kp,k,ii,ni(ii),nj(ii)
	    ENDDO
	 ENDDO    

          
    

       DO t=1,timeLEN  ! loop over timesteps

         ! preparation of matrices and right hand sides 
         ii = 0	 
	 DO ii=1,kpq
	    rh(ii,1)=0
	    DO i=1,nx
	       DO j=1,ny
	       rh(ii,1)=rh(ii,1)+datax(i,j,t)*(i**ni(ii))*(j**nj(ii))
!               WRITE(*,*) 'kpq,ii,nx,ny,i,j,ni(ii),nj(ii),rh(ii,1) ', kpq,ii,nx,ny,i,j,ni(ii),nj(ii),rh(ii,1)
	       ENDDO
	    ENDDO
	 ENDDO  
	 
         iv=0
         iw=0
	 DO iv=1,kpq
	 DO iw=1,kpq
	    am(iv,iw)=0
            i=0
            j=0
	    DO i=1,nx
	    DO j=1,ny
	       am(iv,iw)=am(iv,iw)+(i**(ni(iv)+ni(iw)))*(j**(nj(iv)+nj(iw))) 
	    ENDDO
	    ENDDO
!            WRITE(*,*) 'kpq,ix,iy,i,j,ni(ix),ni(iy),nj(ix),nj(iy),am(ix,iy) ', kpq,ix,iy,i,j,&
!               ni(ix),ni(iy),nj(ix),nj(iy),am(ix,iy)
	 ENDDO
	 ENDDO
	 
	 ! Matrix inversion
         call gaussj(am,kpq,kpqm,rh,1,1)
	 
	 
	!  DETERMINING REDUCTION OF VARIANCE BY SUBSTRACTION OF POLYNOMIAL
!        varf = 0.
!        expf = 0.
!        varr = 0.
!        expr = 0 


      !	calculating polynom

        iv = 0
        iw = 0
	DO iv=1,nx
	DO iw=1,ny
!	   varf = varf+datax(iv,iw,t)*datax(iv,iw,t)
!           expf = expf+datax(iv,iw,t)
           datap(iv,iw,t) = 0.
           ii = 0
	   DO ii=1,kpq
	      datap(iv,iw,t) = datap(iv,iw,t)+rh(ii,1)*(iv**ni(ii))*(iw**nj(ii))
	   ENDDO
!	   expr = expr + datap(iv,iw,t)-datax(iv,iw,t)
!           varr=varr+(datap(iv,iw,t)-datax(iv,iw,t))*(datap(iv,iw,t)-datax(iv,iw,t))
           datar(iv,iw,t)=datax(iv,iw,t)-datap(iv,iw,t)
	ENDDO
	ENDDO
	
!	expr = expr/n
!        expf = expf/n	
!        varf = sqrt(varf/n - expf**2)
!        varr = sqrt(varr/n - expr**2)  	
!        var  = (varr/varf)*100.+0.5
 
!        WRITE(*,*) 'ratio std dev',var,'%'
        WRITE(*,*) datax(5,5,t), datap(5,5,t), datar(5,5,t)
        WRITE(*,*) 'timestep: ', t
	ENDDO          ! end of loop over timesteps
   


     ! writing data to output file       
       WRITE(*,*) 'writing data '
       WRITE(*,*) 'write reduced data field'
       status=nf90_inq_varid(ncido,actoutvar,varIDo)
       if(status /= nf90_noerr) call handle_err(status)
       status = nf90_put_var(ncido,varIDo,datar)
       if(status /= nf90_NoErr) call handle_err(status)
     ! write polynom       
       WRITE(*,*) 'write polynom '
       status=nf90_inq_varid(ncido,actoutpol,polIDo)
       if(status /= nf90_noerr) call handle_err1(status)
       status = nf90_put_var(ncido,polIDo,datap)
       if(status /= nf90_NoErr) call handle_err(status)

      ! close output file       
       WRITE(*,*) 'close output file'
       status = nf90_close(ncido)
       if (status /= nf90_noerr) call handle_err(status)    
	          
!    ENDDO      ! end loop over number of maximum order of polynom



      CONTAINS

!     Matrix-Inversion:

      SUBROUTINE gaussj(a,n,np,b,m,mp)
      INTEGER :: m,mp,n,np
      REAL :: a(np,np),b(np,mp)
      INTEGER, PARAMETER :: nmax=5000
      INTEGER :: i,icol,irow,j,k,l,ll,indxc(nmax),indxr(nmax),ipiv(nmax)
      REAL :: big,dum,pivinv
      
      DO j=1,n
        ipiv(j)=0
      END DO
      
      DO i=1,n
        big=0.
	
        DO j=1,n
          IF(ipiv(j).ne.1)then
            DO k=1,n
              IF (ipiv(k).eq.0) then
                IF (abs(a(j,k)).ge.big)then
                  big=abs(a(j,k))
                  irow=j
                  icol=k
                ENDIF
              ELSEIF (ipiv(k).gt.1) then
!               pause 'singular matrix in gaussj'
             ENDIF
           END DO
          ENDIF
        END DO
	
        ipiv(icol)=ipiv(icol)+1
	
        IF (irow.ne.icol) then
          DO l=1,n
            dum=a(irow,l)
            a(irow,l)=a(icol,l)
            a(icol,l)=dum
          END DO
          DO l=1,m
            dum=b(irow,l)
            b(irow,l)=b(icol,l)
            b(icol,l)=dum
          END DO
        ENDIF
	
        indxr(i)=irow
        indxc(i)=icol
        IF (a(icol,icol).eq.0.) pause 'singular matrix in gaussj'
        pivinv=1./a(icol,icol)
        a(icol,icol)=1.
	
        DO l=1,n
          a(icol,l)=a(icol,l)*pivinv
        END DO
	
        DO l=1,m
          b(icol,l)=b(icol,l)*pivinv
        END DO
        
	DO ll=1,n
          IF(ll.ne.icol)then
            dum=a(ll,icol)
            a(ll,icol)=0.
            DO l=1,n
              a(ll,l)=a(ll,l)-a(icol,l)*dum
            END DO
            DO l=1,m
              b(ll,l)=b(ll,l)-b(icol,l)*dum
            END DO
          ENDIF
	END DO
	
      END DO
      
      DO l=n,1,-1
        IF(indxr(l).ne.indxc(l))then
          DO k=1,n
            dum=a(k,indxr(l))
            a(k,indxr(l))=a(k,indxc(l))
            a(k,indxc(l))=dum
          END DO
        ENDIF
      END DO
      
      RETURN
      END SUBROUTINE gaussj

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

     END PROGRAM polyfit
! (C) Copr. 1986-92 numerical Recipes Software "W#(1&.

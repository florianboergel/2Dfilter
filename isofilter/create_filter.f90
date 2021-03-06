PROGRAM isofilter
!#######################################################################
!                                                                      #
!     Isotropic digital filter; test of the response-function.         #
!     (C) Frauke Feser, GKSS Research Center, 2004/2005.               #
!     Compile: f90 -o isotrfilter isotrfilter.f90 netCDF-libraries     #
!                                                                      #
!     Paper on isotropic spatial filter:                               #
!     A spatial two-dimensional discrete filter for limited area model #
!     evaluation purposes                                              #
!     Frauke Feser and Hans von Storch                                 #
!     Monthly Weather Review, 133(6), 1774-1786, 2005.                 #
!                                                                      #
!     For 40 x 40 wave numbers k x l, 81 x 91 grid points ix x iy :    #
!     wave number k < or = l; otherwise swap k und l in the definition #
!     of NFMAX                                                         #
!     iip=lower wave number,iio=upper wave number,iir=blurring area    #
!                                                                      #
!     Configuration for low-pass filter:  N=8,iip=7 ,iio=10,iir=1      #
!     In   'Define Wave Number Areas' :                                #
!     First palpi(NF,1)=1., third palpi(NF,1)=0., second palpi:comment #
!     out                                                              #
!                                                                      #
!     Configuration for med-pass filter:  N=8,iip=7 ,iio=17,iir=1      #
!     In   'Define Wave Number Areas' :                                #
!     First palpi(NF,1)=0., third palpi(NF,1)=0., second palpi(NF,1)=1.#
!                                                                      #
!     Configuration for high-pass filter: N=8,iip=22,iio=25,iir=1      #
!     In   'Define Wave Number Areas' :                                #
!     First palpi(NF,1)=0., third palpi(NF,1)=1., second palpi:comment #
!     out                                                              #
!                                                                      #
!     Input field: fieldin, ieee-service Format                        #
!     Output field: fieldout, ieee-service Format                      #
!     Response-Function: respfunct.srv, ieee-service Format            #
!     Filter Weights: filterg.srv, ieee-service Format                 #
!                                                                      #
!#######################################################################

USE netcdf
IMPLICIT NONE

      INTEGER, PARAMETER :: iir=1

      INTEGER :: ix,iy,n,k,l,ihead(1:8,1:1),nn,ia,ib,ic,id,ne,ie,iip,iio,nf, &
           nfmax,i,j,ii,ij,in,im,jl,ierror,fsizex,fsizey,rsizex,rsizey

      INTEGER :: ncid,ncidr,ncidf,status,xFSizeID,yFSizeID,xRSizeID,yRSizeID,rlonID, &
           rlatID,filterID,responseID,varID,varIDf,timeID,iiID,iipID,iioID

      INTEGER :: timeLEN,nDIMs,nATTs

      INTEGER, ALLOCATABLE :: il(:),ik(:),kk(:),ll(:),fx(:),fy(:) 

      CHARACTER (len=200) :: d,filein,respfunct,filter,outdir,indir,filename, &
           tmpout,fileout,ncvar,ncvarf 

      CHARACTER (len=10) :: ftype, apply,ff !ncvar,ncvarf
     
      CHARACTER (len=5) :: iipchar, iiochar, nchar, kchar, lchar, ixchar, iychar 
 
      LOGICAL :: fexist

      INTEGER :: iargc

      REAL :: gb,ndach,mdach,tumme1,tumme2,RAD,PI

      REAL, ALLOCATABLE :: feldin(:,:,:), ffilt(:,:,:),ffresp(:,:), &
          tumme3(:,:),tumme4(:,:), &
          afg(:,:),pmatri(:,:),pmatrc(:,:), &
          pmatrb(:,:),pmatrt(:,:),pmatrm(:,:), &
          palpi(:,:),palpin(:,:)

      REAL *8, ALLOCATABLE :: A(:,:),B(:,:),C(:,:)

     IF (iargc() < 9) THEN
    PRINT *, 'Error: too few arguments'
    WRITE (*,*) 'Usage: create_filter <outdir> <spzone> <gridpts in x> <gridpts in y> <wn in x> <wn in y>'
    PRINT *, ' <from wn> <to wn> <filter type (l-low/b-band/h-high)> <variable>' 
    PRINT *, '--------------------------------------'  
    PRINT *, 'outdir - output directory'
    PRINT *, 'spzone - number of gridpoints used for spongezone'
    PRINT *, 'gridpts in x - number of gridpoints in x direction (spongezone included) -> see infile'
    PRINT *, 'gridpts in y - number of gridpoints in y direction (spongezone included) -> see infile'
    PRINT *, 'wn in x - wavenumbers in x direction (usually half of gridpoints in x)'
    PRINT *, 'wn in x - wavenumbers in y direction (usually half of gridpoints in y)' 
    PRINT *, 'from wn - to filter from wavenumber (lower bound)'
    PRINT *, 'from wn - to filter from wavenumber (upper bound)'
    PRINT *, 'filter type - press l for lowpass, b for bandpass and h for highpass'
    STOP
    ENDIF



      CALL getarg(1,outdir)
      CALL getarg(2,d)
      READ(d,*) n
      CALL getarg(3,d)
      READ(d,*) ix
      CALL getarg(4,d) 
      READ(d,*) iy
      CALL getarg(5,d)
      READ(d,*) k
      CALL getarg(6,d)
      READ(d,*) l
      CALL getarg(7,d)
      READ(d,*) iip
      CALL getarg(8,d)
      READ(d,*) iio
      CALL getarg(9,ftype)



      ne=((n+1)*(n+2)/2)
      IF(k.le.l) THEN
      nfmax=(int(k*(2*l-k+1)/2))
      ELSE
      nfmax=(int(l*(2*k-l+1)/2))
      ENDIF
      fsizex=2*n+1
      fsizey=2*n+1
      ncvarf=TRIM(ncvar)//ftype
      ncvar=TRIM(ncvar)
      filein = TRIM(indir)//'/'//TRIM(filename)
      tmpout= TRIM(outdir)//'/tmpout.nc'
      fileout= TRIM(outdir) //'/'//TRIM(filename)
      respfunct= TRIM(outdir) //'/respfunct/respfunct.nc'
      filter= TRIM(outdir) //'/filters/filter.nc'


      ALLOCATE(ik(1:nfmax),il(1:nfmax),fx(1:fsizex),fy(1:fsizey),kk(0:k),ll(0:l))

      ALLOCATE(ffresp(0:k,0:l), &
          tumme3(0:k,0:l),tumme4(0:k,0:l), &
          afg(-n:n,-n:n),pmatri(1:nfmax,1:ne),pmatrc(1:ne,1:nfmax), &
          pmatrb(1:ne,1:ne),pmatrt(1:ne,1:ne),pmatrm(1:ne,1:nfmax), &
          palpi(1:nfmax,1:1),palpin(1:ne,1:1))

      ALLOCATE(A(1:ix,1:iy),B(1:ix,1:iy),C(1:ix,1:iy))


!     Initialisation:

      PI = 4.*ATAN(1.)
      RAD=2.*PI/ix
      tumme1=0.0
      tumme2=0.0
      gb=0.0
      ndach=2.*PI/ix
      mdach=2.*PI/iy
      nf=0

      DO ia=1,nfmax
        DO ib=1,ne
          pmatri(ia,ib)=0.0
          pmatrc(ib,ia)=0.0
          pmatrm(ib,ia)=0.0
          palpin(ib,1)=0.0
        END DO
        palpi(ia,1)=0.0      
        ik(ia)=0
        il(ia)=0    
      END DO

      DO ia=0,k
        DO ib=0,l
          ffresp(ia,ib)=0.0
        END DO
      END DO

      DO ia=-n,n
        DO ib=-n,n
          afg(ia,ib)=0.0
        END DO
      END DO

!     Define Wave Number Areas:

!     low-pass
      IF(ftype.eq."l") THEN
        DO ia=1,k
          DO ib=1,ia
          IF((SQRT(ia**2.+ib**2.)).le.(iip-iir))THEN
             nf=nf+1
             palpi(nf,1)=1.
             ik(nf)=ia
             il(nf)=ib
          ELSEIF((SQRT(ia**2.+ib**2.)).ge.(iio+iir))THEN
             nf=nf+1
             palpi(nf,1)=0.
             ik(nf)=ia
             il(nf)=ib
          ENDIF
          END DO
        END DO   
      ENDIF

!     med-pass
      IF(ftype.eq."b") THEN
        DO ia=1,k
          DO ib=1,ia
          IF((SQRT(ia**2.+ib**2.)).le.(iip-iir))THEN
             nf=nf+1
             palpi(nf,1)=0.
             ik(nf)=ia
             il(nf)=ib
          ELSEIF((SQRT(ia**2.+ib**2.)).ge.(iip+iir).and.& 
                (SQRT(ia**2.+ ib**2.)).le.(iio-iir))THEN
             nf=nf+1
             palpi(nf,1)=1.
             ik(nf)=ia
             il(nf)=ib   
          ELSEIF((SQRT(ia**2.+ib**2.)).ge.(iio+iir))THEN
             nf=nf+1
             palpi(nf,1)=0.
             ik(nf)=ia
             il(nf)=ib
          ENDIF
          END DO
        END DO
      ENDIF


!     high-pass
      IF(ftype.eq."h") THEN
        DO ia=1,k
          DO ib=1,ia
          IF((SQRT(ia**2.+ib**2.)).le.(iip-iir))THEN
             nf=nf+1
             palpi(nf,1)=0.
             ik(nf)=ia
             il(nf)=ib
          ELSEIF((SQRT(ia**2.+ib**2.)).ge.(iio+iir))THEN
             nf=nf+1
             palpi(nf,1)=1.
             ik(nf)=ia
             il(nf)=ib
          ENDIF
          END DO
        END DO
      ENDIF

!     Calculate Filter Weights:
!       Inverse matrix is determined for calculating Alpha:
!	Alpha=inverse matrix * kappa
!	pmatri(1:NE,1:NE)=Input matrix,
!       palpi(1:NE,1:1)=Vector on right hand side. 
!       In subroutine gaussj pmatri is replaced with the inverse matrix, 
!       palpi is replaced with the solution vectors.
!       Call gaussj(a,n,np,b,m,mp) with a(1:n,1:n)=input matrix with
!       dimension np x np, b(1:n,1:m)=vector with dimension np x mp.

!     Calculate matrix pmatri:
!     (Equation (11) in (Feser and von Storch, 2005)):

      DO ij=1,nf
        pmatri(ij,1)=1.
        DO in=1,n
          pmatri(ij,in*(in+1)/2+1)=2.*(cos(ik(ij)*ndach*in)+cos(il(ij) &
              *ndach*in))
        END DO
        DO in=2,n
          DO im=1,in-1
            pmatri(ij,in*(in+1)/2+1+im)=4.*(cos(ik(ij)*ndach*in) &
                *cos(il(ij)*mdach*im)+cos(il(ij)*ndach*in)*cos(ik(ij) &
                *mdach*im))
          END DO
        END DO
        DO in=1,n
          pmatri(ij,in*(in+1)/2+1+in)=4.*cos(ik(ij)*ndach*in)*cos(il(ij) &
              *ndach*in)
        END DO
      END DO 

!     Calculate solution vector palpin:
!     Calculate transposed matrix MT:

      DO ia=1,nf
        DO ib=1,ne
          pmatrm(ib,ia)=pmatri(ia,ib)
        END DO
      END DO

!     Multiplication MT x Matrix M:

      DO ia=1,ne
        DO ib=1,ne
          pmatrt(ia,ib)=0.
          DO ic=1,nf
            pmatrt(ia,ib)=pmatrt(ia,ib)+pmatrm(ia,ic)*pmatri(ic,ib)
          END DO
        END DO
      END DO

!     Set up identity matrix for caculating the inverse matrix:

        DO i=1,ne
          DO j=1,ne
            pmatrb(i,j)=0.
          END DO
          pmatrb(i,i)=1.
        END DO

!     Calculate inverse matrix (with identity matrix):

	call gaussj(pmatrt,ne,ne,pmatrb,ne,ne)

!     Multiplication inverse solution MTxM with Matrix MT:

        DO ia=1,ne
          DO ib=1,nf
            DO ic=1,ne
              pmatrc(ia,ib)=pmatrc(ia,ib)+pmatrt(ia,ic)*pmatrm(ic,ib)
            END DO
          END DO
        END DO

!     Multiplication result with vector kappa:
!     (Equation (14) in (Feser and von Storch, 2005)):

        DO ia=1,ne
          DO ib=1,nf
            palpin(ia,1)=palpin(ia,1)+pmatrc(ia,ib)*palpi(ib,1)
          END DO
        END DO

!     Allocation Filter Weights afg:
!     (using the symmetry conditions of Equation (2) in (Feser and
!     von Storch, 2005)):

        DO ia=0,n
          nn=(ia*(ia+1))/2+1
          DO ib=0,ia
            afg(ia,ib)=palpin(nn+ib,1)
          END DO
        END DO

        DO ia=0,n
          DO ib=ia+1,n
            afg(ia,ib)=afg(ib,ia)
          END DO
        END DO

      DO ia=0,n
        DO ib=0,n
          afg(-ib,ia)=afg(ia,ib)
          afg(ib,-ia)=afg(ia,ib) 
          afg(-ib,-ia)=afg(ia,ib)
        END DO
      END DO

!     Write Filter Weights:
     
      WRITE(*,*) 'writing filter weights '

      fsizex=2*n+1
      fsizey=2*n+1
      DO ia=0,fsizex
      fx(ia)=ia
      END DO
      DO ia=0,fsizey
      fy(ia)=ia
      END DO
             

      status = nf90_create (filter, nf90_clobber, ncid)
      if (status /= nf90_noerr) call handle_err(status)
      status = nf90_def_dim(ncid, "lon",fsizex, xFSizeID)
      if (status /= nf90_noerr) call handle_err(status)
      status = nf90_def_dim(ncid, "lat",fsizey, yFSizeID)
      if (status /= nf90_noerr) call handle_err(status) 
      status = nf90_def_dim(ncid, "iidim",1, iiID)
      if (status /= nf90_noerr) call handle_err(status)
      status = nf90_def_var(ncid, "filter", nf90_double, &
                            (/ xFSizeID, yFSizeID /), filterID)
      if(status /= nf90_noerr) call handle_err(status)
      status = nf90_def_var(ncid, "lon", nf90_float, &
                            (/ xFSizeID /), rlonID)
      if(status /= nf90_noerr) call handle_err(status)
      status = nf90_def_var(ncid, "lat", nf90_float, &
                            (/ yFSizeID /), rlatID)
      if(status /= nf90_noerr) call handle_err(status)
      status = nf90_def_var(ncid, "iip", nf90_int, &
                            (/ iiID /), iipID)
      if(status /= nf90_noerr) call handle_err(status)
      status = nf90_def_var(ncid, "iio", nf90_int, &
                            (/ iiID /), iioID)
      if(status /= nf90_noerr) call handle_err(status)
      status = nf90_put_att(ncid, rlonID,"axis","X")
      if(status /= nf90_noerr) call handle_err(status)
      status = nf90_put_att(ncid, rlatID,"axis","Y")
      if(status /= nf90_noerr) call handle_err(status)
      status = nf90_enddef(ncid)
      if (status /= nf90_noerr) call handle_err(status)
      status = nf90_put_var(ncid, filterID,afg)
      if(status /= nf90_NoErr) call handle_err(status)
      status = nf90_put_var(ncid, rlonID,fx)
      if(status /= nf90_NoErr) call handle_err(status)
      status = nf90_put_var(ncid, rlatID,fy)
      if(status /= nf90_NoErr) call handle_err(status)
      status = nf90_put_var(ncid, iipID,iip)
      if(status /= nf90_NoErr) call handle_err(status)
      status = nf90_put_var(ncid, iioID,iio)
      if(status /= nf90_NoErr) call handle_err(status)
      status = nf90_close(ncid)
      if (status /= nf90_noerr) call handle_err(status)

!     Calculate Response Function:
!     (Equation (8) in (Feser and von Storch, 2005)):

      DO ia=0,k
        DO ib=0,l
          tumme3(ia,ib)=0.0
          tumme4(ia,ib)=0.0
          DO ic=1,n
            tumme3(ia,ib)=tumme3(ia,ib)+2. &
                *afg(ic,0)*(cos(ndach*ia*ic)+cos(ndach*ib*ic))+ &
                4*afg(ic,ic)*cos(ndach*ia*ic)*cos(ndach*ib*ic)
          END DO
          DO ic=2,n
            DO id=1,ic-1
              tumme4(ia,ib)=tumme4(ia,ib)+afg(ic,id)* &
                  (cos(ndach*ia*ic)*cos(mdach*ib*id)+ &
                  cos(ndach*ib*ic)*cos(mdach*ia*id))
            END DO
          END DO
        END DO
      END DO

      DO ia=0,k
        DO ib=0,l
          ffresp(ia,ib)=afg(0,0)+tumme3(ia,ib)+4.*tumme4(ia,ib)
        END DO
      END DO

!     Write Response Function:

      WRITE(*,*) 'writing response function '

      rsizex=k+1
      rsizey=l+1
      DO ia=0,k
      kk(ia)=ia
      END DO
      DO ia=0,l
      ll(ia)=ia
      END DO

      status = nf90_create (respfunct, nf90_clobber, ncidr)
      if (status /= nf90_noerr) call handle_err(status)
      status = nf90_def_dim(ncidr, "lon",rsizex, xRSizeID)
      if (status /= nf90_noerr) call handle_err(status)
      status = nf90_def_dim(ncidr, "lat",rsizey, yRSizeID)
      if (status /= nf90_noerr) call handle_err(status)
      status = nf90_def_dim(ncidr, "iidim",1, iiID)
      if (status /= nf90_noerr) call handle_err(status)
      status = nf90_def_var(ncidr, "response", nf90_double, &
                            (/ xRSizeID, yRSizeID /), responseID)
      if (status /= nf90_noerr) call handle_err(status)
      status = nf90_def_var(ncidr, "lon", nf90_float, &
                            (/ xRSizeID /), rlonID)
      if(status /= nf90_noerr) call handle_err(status)
      status = nf90_def_var(ncidr, "lat", nf90_float, &
                            (/ yRSizeID /), rlatID)
      if(status /= nf90_noerr) call handle_err(status)
      status = nf90_def_var(ncidr, "iip", nf90_int, &
                            (/ iiID /), iipID)
      if(status /= nf90_noerr) call handle_err(status)
      status = nf90_def_var(ncidr, "iio", nf90_int, &
                            (/ iiID /), iioID)
      if(status /= nf90_noerr) call handle_err(status)
      status = nf90_put_att(ncidr, rlonID,"axis","X")
      if(status /= nf90_noerr) call handle_err(status)
      status = nf90_put_att(ncidr, rlatID,"axis","Y")
      if(status /= nf90_noerr) call handle_err(status)
      status = nf90_enddef(ncidr)
      if (status /= nf90_noerr) call handle_err(status)
      status = nf90_put_var(ncidr, responseID, ffresp)
      if(status /= nf90_NoErr) call handle_err(status)
      status = nf90_put_var(ncidr, rlonID,kk)
      if(status /= nf90_NoErr) call handle_err(status)
      status = nf90_put_var(ncidr, rlatID,ll)
      if(status /= nf90_NoErr) call handle_err(status)
      status = nf90_put_var(ncidr, iipID,iip)
      if(status /= nf90_NoErr) call handle_err(status)
      status = nf90_put_var(ncidr, iioID,iio)
      if(status /= nf90_NoErr) call handle_err(status)
      status = nf90_close(ncidr)
      if (status /= nf90_noerr) call handle_err(status)


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
        IF (a(icol,icol).eq.0.) then
                 PRINT *,'JKe: singular matrix in gaussj'
!                'singular matrix in gaussj'
        ENDIF
        !IF (a(icol,icol).eq.0.) pause 'singular matrix in gaussj'
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

     END PROGRAM isofilter
! (C) Copr. 1986-92 numerical Recipes Software "W#(1&.

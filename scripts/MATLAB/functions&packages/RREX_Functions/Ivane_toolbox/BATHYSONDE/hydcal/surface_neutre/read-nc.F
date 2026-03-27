	subroutine read_nc(along,alat,s0,t0,p0,gamma0,a0,n0,
     &						along0,alat0,iocean0)
ccc
ccc
ccc
ccc	DESCRIPTION :	Read variables from the netcdf labelled data file 
ccc
ccc	PRECISION:	Double precision
ccc
ccc	INPUT :		along		longitude of record
ccc			alat		latitude of record
ccc
ccc	OUTPUT :	s0(nz,2,2)	array of cast salinities
ccc			t0(nz,2,2)	array of cast in situ temperatures
ccc			p0(nz)		array of cast pressures
ccc			gamma0(nz,2,2)	array of cast gamma values
ccc			a0(nz,2,2)	array of cast a values
ccc			n0(2,2)		length of casts
ccc			along0(2)	array of cast longitudes
ccc			alat0(2)	array of cast latitudes
ccc			iocean0(2,2)	array of cast oceans
ccc
ccc	UNITS :		salinity	psu (IPSS-78)
ccc			temperature	degrees C (IPTS-68)
ccc			pressure	db
ccc			gamma		kg m-3
ccc
ccc
ccc	AUTHOR :	David Jackett
ccc
ccc	CREATED :	July 1993
ccc
ccc	REVISION :	1.3		15/11/94
ccc
ccc
ccc
	parameter(nx=90,ny=45,nz=33,ndx=4,ndy=4)

	implicit double precision (a-h,o-z)

	integer*4 id_gnc,id_lon,id_lat,id_p,id_n
	integer*4 id_ocean,id_s,id_t,id_gamma,id_a
	integer*4 start(3),count(3),ierr,n0(2,2),n0_t(2)

	integer*4 iocean(nx,ny),iocean0(2,2)

	real*4 along_s(nx),alat_s(ny)
	real*4 s0_s(nz,2,2),t0_s(nz,2,2),p0_s(nz),gamma0_s(nz,2,2),a0_s(nz,2,2)
	real*4 s0_t(nz,2),t0_t(nz,2),gamma0_t(nz,2),a0_t(nz,2)

	dimension along_d(nx),alat_d(ny),along0(2),alat0(2)
	dimension s0(nz,2,2),t0(nz,2,2),p0(nz),gamma0(nz,2,2),a0(nz,2,2)

	character*100 filename

	save along_d,alat_d,i0,j0,iocean,p0_s

	data start/1,1,1/, count/nz,nx,ny/, nw/0/, i0/1/, j0/1/


	ilong(alng) = int(alng/ndx + 1)
	jlat(alt) = int((88+alt)/ndy + 1)



ccc
ccc		only read when you have to
ccc

	dx = along-along_d(i0)
	dy = alat-alat_d(j0)

	if(dx.lt.0.0.or.dx.ge.4.0.or.dy.lt.0.0.or.dy.ge.4.0.or.
     &					    (i0.eq.1.and.j0.eq.1)) then

ccc
ccc		open the netcdf file and get the variable id's
ccc

	  filename = '/home/archaden/logiciels/bathysonde/hydcal/surface_neutre/gamma.nc'
	  id_gnc = ncopn(filename,nw,ierr)

	  if(i0.eq.1.and.j0.eq.1) then

	    start(2) = 1
	    count(2) = nx
	    start(3) = 1
	    count(3) = ny

	    id_lon =  ncvid(id_gnc,'lon',ierr)
	    call ncvgt(id_gnc,id_lon,start(2),count(2),along_s,ierr)
	    do i = 1,nx
	      along_d(i) = along_s(i)
	    end do

	    id_lat =  ncvid(id_gnc,'lat',ierr)
	    call ncvgt(id_gnc,id_lat,start(3),count(3),alat_s,ierr)
	    do j = 1,ny
	      alat_d(j) = alat_s(j)
	    end do

	    id_p =  ncvid(id_gnc,'pressure',ierr)
	    call ncvgt(id_gnc,id_p,start(1),count(1),p0_s,ierr)

	    id_ocean =  ncvid(id_gnc,'iocean',ierr)
	    call ncvgt(id_gnc,id_ocean,start(2),count(2),iocean,ierr)

	  end if

	  do k = 1,nz
	    p0(k) = p0_s(k)
	  end do

	  id_n =  ncvid(id_gnc,'n',ierr)
	  id_s =  ncvid(id_gnc,'s',ierr)
	  id_t =  ncvid(id_gnc,'t',ierr)
	  id_gamma =  ncvid(id_gnc,'gamma',ierr)
	  id_a =  ncvid(id_gnc,'a',ierr)
	
ccc
ccc		read the appropriate records
ccc

	  i0 = ilong(along)
	  j0 = jlat(alat)

	  along0(1) = along_d(i0)
	  alat0(1) = alat_d(j0)
	  alat0(2) = alat0(1)+ndy

	  if(i0.eq.nx+1) i0 = 1

	  if(i0.lt.nx) then

	    along0(2) = along0(1)+ndx

	    start(2) = i0
	    count(2) = 2
	    start(3) = j0
	    count(3) = 2

	    call ncvgt(id_gnc,id_n,start(2),count(2),n0,ierr)
	    call ncvgt(id_gnc,id_s,start,count,s0_s,ierr)
	    call ncvgt(id_gnc,id_t,start,count,t0_s,ierr)
	    call ncvgt(id_gnc,id_gamma,start,count,gamma0_s,ierr)
	    call ncvgt(id_gnc,id_a,start,count,a0_s,ierr)

	  elseif(i0.eq.nx) then

	    start(2) = i0
	    count(2) = 1
	    start(3) = j0
	    count(3) = 2

	    call ncvgt(id_gnc,id_n,start(2),count(2),n0_t,ierr)
	    call ncvgt(id_gnc,id_s,start,count,s0_t,ierr)
	    call ncvgt(id_gnc,id_t,start,count,t0_t,ierr)
	    call ncvgt(id_gnc,id_gamma,start,count,gamma0_t,ierr)
	    call ncvgt(id_gnc,id_a,start,count,a0_t,ierr)

	    do j = 1,2
	      n0(1,j) = n0_t(j)
	      do k = 1,nz
	        s0_s(k,1,j) = s0_t(k,j)
	        t0_s(k,1,j) = t0_t(k,j)
	        gamma0_s(k,1,j) = gamma0_t(k,j)
	        a0_s(k,1,j) = a0_t(k,j)
	      end do
	    end do

	    along0(2) = 0.0

	    start(2) = 1
	    count(2) = 1
	    start(3) = j0
	    count(3) = 2

	    call ncvgt(id_gnc,id_n,start(2),count(2),n0_t,ierr)
	    call ncvgt(id_gnc,id_s,start,count,s0_t,ierr)
	    call ncvgt(id_gnc,id_t,start,count,t0_t,ierr)
	    call ncvgt(id_gnc,id_gamma,start,count,gamma0_t,ierr)
	    call ncvgt(id_gnc,id_a,start,count,a0_t,ierr)

	    do j = 1,2
	      n0(2,j) = n0_t(j)
	      do k = 1,nz
	        s0_s(k,2,j) = s0_t(k,j)
	        t0_s(k,2,j) = t0_t(k,j)
	        gamma0_s(k,2,j) = gamma0_t(k,j)
	        a0_s(k,2,j) = a0_t(k,j)
	      end do
	    end do

	  end if

	  call ncclos(id_gnc,ierr)


ccc
ccc		get the ocean information
ccc

	  do j = 1,2
	  do i = 1,2
	    iocean0(i,j) = iocean(ilong(along0(i)),jlat(alat0(j)))
	  end do
	  end do


ccc
ccc		the data
ccc

	  do j = 1,2
	  do i = 1,2
	  do k = 1,n0(i,j)
	    s0(k,i,j) = s0_s(k,i,j)
	    t0(k,i,j) = t0_s(k,i,j)
	    gamma0(k,i,j) = gamma0_s(k,i,j)
	    a0(k,i,j) = a0_s(k,i,j)
	  end do
	  end do
	  end do



	end if




	return
	end

        parameter(nz=80,nlevels=3)

	implicit double precision (a-h,o-z)

        dimension s(nz),t(nz),p(nz),gamma(nz),dgl(nz),dgh(nz)
	dimension glevels(nlevels),sns(nlevels),tns(nlevels),pns(nlevels)
	dimension dsns(nlevels),dtns(nlevels),dpns(nlevels)

	data glevels/26.8,27.9,28.1/


ccc
ccc             an example of labelling data
ccc


        open(10,file='example.dat',status='old')

        read(10,*) along,alat,n
        do k = 1,n
          read(10,*) s(k),t(k),p(k)
        end do

ccc
ccc		label
ccc

        call gamma_n(s,t,p,n,along,alat,gamma,dgl,dgh)

        print *, '\nlocation'
	print *
        write(6,'(2f12.4,i8)') along,alat

        print *, '\nlabels'
	print *
        do k = 1,n
          write(6,'(f8.2,3f12.6)') p(k),gamma(k),dgl(k),dgh(k)
        end do


ccc
ccc		fit some surfaces
ccc

	call neutral_surfaces(s,t,p,gamma,n,glevels,nlevels,
     &					sns,tns,pns,dsns,dtns,dpns)

	print *, '\nsurfaces'
        print *

	do k = 1,nlevels
	  print '(f8.2,2f12.6,f14.6,f6.1)', 
     &				glevels(k),sns(k),tns(k),pns(k),dpns(k)
	end do

	print *




        end

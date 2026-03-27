c     *** dqtgs ******* version 1, modification level 0 *** dko20521 ***
c     *                                                                *
c     *   compute the value of the integral over a monotonically       *
c     *   tabulated function by the trapezoidal rule                   *
c     *                                                                *
c     *   5736-xm7 copyright ibm corp. 1971                            *
c     *   refer to instructions on copyright notice form no. 120-2083  *
c     *   fe service no. 200281                                        *
c     *                                                                *
c     under the lease agreement this program may be run only at mit ipc
c
      subroutine dqtgs(x,y,idim,s,ier)
      dimension x(1),y(1)
      double precision x,y,s,xa,xb,xc

      isw  =ier
      ier  =0
      jmp  =1
      if (idim) 1,1,2
    1 ier  =1000
      goto 9
    2 last =1+(idim-1)*jmp
      s    =0.d0
      xa   =x(1)
      xb   =xa
      i    =1
    3 if (i-last+jmp) 4,4,8
    4 ijmp =i+jmp
      xc   =x(ijmp)
      if (i-1) 7,7,5
    5 if ((xc-xb)*(xb-xa)) 6,6,7
    6 ier  =1
    7 s    =s+(xc-xa)*y(i)
      xa   =xb
      xb   =xc
      i    =ijmp
      goto 3
    8 s    =(s+(xb-xa)*y(last))*0.5d0
      if (ier) 9,11,9
    9 if (isw+12345) 10,11,10
   10 call wier(ier,20521)
   11 return
      end

      subroutine wier(ier,no)
      write (6,1) no,ier
    1 format (//' ***** dko',i5,' raised error indicator to ',i4,
     1     ' *****'///)
      return
      end

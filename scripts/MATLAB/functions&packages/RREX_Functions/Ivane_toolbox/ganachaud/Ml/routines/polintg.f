      subroutine mexFunction(nlhs, plhs, nrhs, prhs)
C     TO COMPILE:
C     mex alinterpg.f alinterp1.f alinterp.f al_index.f
      integer plhs(*), prhs(*)
      integer nlhs, nrhs
C
C      integer mxGetM, mxGetN, mxGetPr, mxCreateFull
      integer m1,m2,m3
      integer n1,n2,n3
      integer xa,ya,x,nd,ni
      integer y,dy
  
C     Check number of arguments
      if (nrhs.ne.3) then
         call mexErrMsgTxt('3 input arguments required')
      elseif (nlhs.ne.2) then
         call mexErrMsgTxt('2 output arguments required')
      endif
C
C     Check input arguments dimensions
      m1 = mxGetM(prhs(1))      
      n1 = mxGetN(prhs(1))
      m2 = mxGetM(prhs(2))      
      n2 = mxGetN(prhs(2))
      m3 = mxGetM(prhs(3))      
      n3 = mxGetN(prhs(3))
C

      xa=   mxGetpr(prhs(1))
      ya=   mxGetpr(prhs(2))
      x =  mxGetpr(prhs(3))

      nd=m1*n1
      ni=m3*n3

      if( ((m1*n1).ne.(m2*n2)).or.((m3.ne.1).and.(n3.ne.1))) then
         call mexErrMsgTxt('bad input arguments dimensions')
      endif
C
C     Create matrices for return arguments
      plhs(1)=mxCreateFull(ni,1,0)
      y=mxGetpr(plhs(1))
      plhs(2)=mxCreateFull(ni,1,0)
      dy=mxGetpr(plhs(2))
 
C     Call routine
      call polint1(%VAL(xa),%VAL(ya),nd,%VAL(x),ni,%VAL(y),%VAL(dy))

      return
      end


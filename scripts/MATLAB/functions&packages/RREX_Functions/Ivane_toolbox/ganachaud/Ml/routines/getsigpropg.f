      subroutine mexFunction(nlhs, plhs, nrhs, prhs)
      integer plhs(*), prhs(*)
      integer nlhs, nrhs
C Compilation: mex -v getsigpropg.f getsigprop.f
C      integer mxGetM, mxGetN, mxGetPr, mxCreateFull
      integer m1,m2,m3,m4,m5
      integer n1,n2,n3,n4,n5
      integer nd,np,nl
      integer dep,prop,botdep,sigdep,sigprop
C
C     Check number of arguments
      if (nrhs.ne.5) then
         call mexErrMsgTxt('5 input arguments required')
      elseif (nlhs.ne.1) then
         call mexErrMsgTxt('1 output arguments required')
      endif
C
C     Check input arguments dimensions
      m1 = mxGetM(prhs(1))      
      n1 = mxGetN(prhs(1))
      m2 = mxGetM(prhs(2))      
      n2 = mxGetN(prhs(2))
      m3 = mxGetM(prhs(3))      
      n3 = mxGetN(prhs(3))
      m4 = mxGetM(prhs(4))      
      n4 = mxGetN(prhs(4))
      m5 = mxGetM(prhs(5))      
      n5 = mxGetN(prhs(5))
C

      dep=     mxGetpr(prhs(1))
      prop=    mxGetpr(prhs(2))
      botdep=  mxGetpr(prhs(3))
      sigdep=  mxGetpr(prhs(4))
      sigprop= mxGetpr(prhs(5))

      nd=m1*n1
      np=n2
      nl=n4

      if( (m2.ne.nd).or.((m3*n3).ne.np).or.(m4.ne.np).or.
     &     (m5.ne.np).or.(n5.ne.nl) ) then
         call mexErrMsgTxt('bad input arguments dimensions')
      endif
C
C     Create matrices for return arguments
      sigprop=mxGetpr(prhs(5))
      plhs(1)=prhs(5)
C
C     Call routine
      call getsigprop(nd,np,%VAL(dep),%VAL(prop),%VAL(botdep),nl,
     &     %VAL(sigdep),%VAL(sigprop))
         
      return
      end


      subroutine mexFunction(nlhs, plhs, nrhs, prhs)
      integer plhs(*), prhs(*)
      integer nlhs, nrhs
C
C    Compilation
C     mex integlayg.f integlay.f dqtgs.f
C
C      integer mxGetM, mxGetN, mxGetPr, mxCreateFull
C      integer mxCreateDoubleMatrix
      integer m1,m2,m3,m4,m5,m6
      integer n1,n2,n3,n4,n5,n6
      integer nd,np,nl
      integer lidep,lipropint,dep,ppropint,sdist,botdep,lprop
C
C     Check number of arguments
      if (nrhs.ne.6) then
         call mexErrMsgTxt('6 input arguments required')
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
      m6 = mxGetM(prhs(6))      
      n6 = mxGetN(prhs(6))
C

      np=m1
      nl=n1
      nd=m3
      lidep    = mxGetpr(prhs(1))
      lipropint= mxGetpr(prhs(2))
      dep      = mxGetpr(prhs(3))
      ppropint = mxGetpr(prhs(4))
      sdist    = mxGetpr(prhs(5))
      botdep   = mxGetpr(prhs(6))

      if( (m2.ne.np).or.(n2.ne.nl).or.(n3.ne.np).or.
     &     (m4.ne.nd).or.(n4.ne.np).or.((m5*n5).ne.np).or.
     &     ((m6*n6).ne.(np+1)) ) then
         call mexErrMsgTxt('bad input arguments dimensions')
      endif
C
C     Create matrices for return arguments
      plhs(1)=mxCreateFull(np,nl,0)
      lprop=mxGetpr(plhs(1))
C
C     Call routine
      call integlay(np,nl,nd,%VAL(lidep),%VAL(lipropint),%VAL(dep),
     &     %VAL(ppropint),%VAL(sdist),%VAL(botdep),%VAL(lprop))
         
      return
      end


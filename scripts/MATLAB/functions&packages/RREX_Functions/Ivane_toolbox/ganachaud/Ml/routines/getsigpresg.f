      subroutine mexFunction(nlhs, plhs, nrhs, prhs)
      integer plhs(*), prhs(*)
      integer nlhs, nrhs
C Compilation mex -v getsigpresg.f getsigpres.f
C      integer mxGetM, mxGetN, mxGetPr, mxCreateFull
C      integer mxCreateDoubleMatrix
      integer m1,m2,m3,m4,m5,m6,m7,m8
      integer n1,n2,n3,n4,n5,n6,n7,n8
      integer nnd,nnp,nns,imaxdi(10000)
      integer nd,np,ns,pres,botdep,imaxd,sigs,sigint,psig
      real*8  xnnd,xnnp,xnns,xmaxd(10000)
C
C     Check number of arguments
      if (nrhs.ne.8) then
         call mexErrMsgTxt('8 input arguments required')
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
      m7 = mxGetM(prhs(7))      
      n7 = mxGetN(prhs(7))
      m8 = mxGetM(prhs(8))      
      n8 = mxGetN(prhs(8))
C
      if ((m1*n1*m2*n2*m3*n3).ne.1) then
         call mexErrMsgTxt('1,2,3th input arguments misplaced')
      endif

      nd=    mxGetpr(prhs(1))
      np=    mxGetpr(prhs(2))
      ns=    mxGetpr(prhs(3))
      pres=  mxGetpr(prhs(4))
      botdep=mxGetpr(prhs(5))
      imaxd= mxGetpr(prhs(6))
      sigs=  mxGetpr(prhs(7))
      sigint=mxGetpr(prhs(8))

      call mxCopyPtrToReal8(nd,xnnd,1)
      nnd=int(xnnd)
      call mxCopyPtrToReal8(np,xnnp,1)
      nnp=int(xnnp)
      call mxCopyPtrToReal8(ns,xnns,1)
      nns=int(xnns)
      call mxCopyPtrToReal8(imaxd,xmaxd,nnp)
      do ii=1,nnp
         imaxdi(ii)=int(xmaxd(ii))
      enddo

      if( ((n4*m4).ne.nnd).or.((m5*n5).ne.nnp).or.((m6*n6).ne.nnp).or.
     &     (m7.ne.nnd).or.(n7.ne.nnp).or.((m8*n8).ne.nns) ) then
         call mexErrMsgTxt('bad input arguments dimensions')
      endif
C
C     Create matrices for return arguments
C      plhs(1)=mxCreateDoubleMatrix(nnp,nns,0)
      plhs(1)=mxCreateFull(nnp,nns,0)
      psig=mxGetpr(plhs(1))
C
C     Call routine
      call getsigpres(nnd,nnp,nns,%VAL(pres),
     &     %VAL(botdep),imaxdi(1),%VAL(sigs),%VAL(sigint),%VAL(psig))
         
      return
      end


      subroutine mexFunction(nlhs, plhs, nrhs, prhs)
      integer plhs(*), prhs(*)
      integer nlhs, nrhs
C
      integer mxGetM, mxGetN, mxGetPr
C      integer mxCreateDoubleMatrix
      integer m1, m2, n2
      integer n1
      integer nnd
      integer nd,nx, nnx
      real*8 x
C
C
C     Check input arguments dimensions
      m1 = mxGetM(prhs(1))      
      n1 = mxGetN(prhs(1))
      m2 = mxGetM(prhs(1))      
      n2 = mxGetN(prhs(1))

      nd=    mxGetpr(prhs(1))
      nx=    mxGetpr(prhs(2))
      call mxCopyPtrToInteger4(nd,nnd,1)
      call mxCopyPtrToReal8(nx,x,1)
      nnx=int(x)
      print*,nd
      print*,nnd,m1,n1,x,nnx


    
      return
      end

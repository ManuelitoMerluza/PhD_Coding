      SUBROUTINE ZMEXFUN(NLHS,PL,NRHS,PR)
*
*     MAIN GATEWAY (VAX/VMS)
*
      INTEGER          C
      PARAMETER       (C=255)
      CHARACTER * (C)  Q
      INTEGER          NL    , NR   
*
      INTEGER          NLHS  , NRHS 
      INTEGER          PL(*) , PR(*)
*
      INTEGER          ZALREAL
      INTEGER          ZGETSCA
*
*     BUFFER POINTER AND SIZE
*
      INTEGER          B,BSIZE
      COMMON  /BUFFER/ B
      SAVE    /BUFFER/
*
*     UTILITY FUNCTIONS
*
      INTEGER          ZIDSET
*
      EXTERNAL         ZALREAL,ZGETSCA,ZGETSIZ,ZIDSET
*
      CHARACTER *(C*C) Q1
*
*     POINTERS TO ARRAYS
*
      INTEGER          A1,A3,A4,A5,A6,A7,A8
*
*     INTEGERS USED TO DIMENSION ARRAYS
*
      INTEGER          I2
*
      PARAMETER       (Q = 'rd_std_hdr_m' , NL =6 , NR =2)
*
      PARAMETER (M=2048)
      CHARACTER*(M) NAMES
      CHARACTER*(30) PROCNM
      COMMON /ARGLST/ PROCNM,NAMES
      SAVE /ARGLST/
      EXTERNAL ZTEST
*
      NAMES='hdrname,ncasts_in_file'
      PROCNM='=rd_std_hdr_m'
*
      CALL ZTEST(Q,NLHS,NRHS,NL,NR)
*
*     GET VALUES OF ALL INTEGER DIMENSIONS
*
      I2     = ZGETSCA (PR(2))
*
*     ALLOCATE SPACE FOR ALL ARRAY ARGUMENTS
*
*
      CALL ZGETSIZ(PR(1),M1,N1)
*
      A1     = (M1)*(N1)
      A3     = ZALREAL (I2)
      A4     = ZALREAL (I2)
      A5     = ZALREAL (I2)
      A6     = ZALREAL (I2)
      A7     = ZALREAL (I2)
      A8     = ZALREAL (I2)
*
*     ALLOCATE SPACE FOR BUFFER
*
      BSIZE  = MAX0   (1,(I2),(I2),(I2),(I2),(I2),(I2))
      B      = ZALREAL (BSIZE)
*
      CALL FCNRD_STD_HDR_M(NLHS,PL,NRHS,PR,Q1(:A1),%VAL(A3),%VAL(A4),
     +                 %VAL(A5),%VAL(A6),%VAL(A7),%VAL(A8))
*
      RETURN
      END
 
      SUBROUTINE FCNRD_STD_HDR_M(NLHS,PL,NRHS,PR,A1,A3,A4,A5,A6,A7,A8)
*
      INTEGER          P, C
      PARAMETER       (P = 0, C = 255)
*
*     NUMBER OF LHS AND RHS ARGUMENTS ( NL AND NR )
*
      INTEGER          NL , NR
      CHARACTER *(C)   Q
*
      PARAMETER       (Q = 'rd_std_hdr_m' , NL =6 , NR =2)
*
*     INPUT / OUTPUT INTERFACE POINTERS
*
      INTEGER          NLHS  , NRHS
      INTEGER          PL(*) , PR(*)
*
*     UTILITY PROCEDURES
*
      EXTERNAL ZOUTI,ZOUTC,ZOUTZ,ZARG1,ZIND,ZINS,
     +         ZOUTR,ZOUTL,ZOUTX,ZINI,ZINC,ZINX,
     +         ZOUTD,ZOUTS,ZARG0,ZINR,ZINL,ZINZ,
     +         ZCHECK,RD_STD_HDR_M
*
*     REAL AND  IMAGINARY  POINTERS TO LHS ARGUMENTS
*
      INTEGER          RL(NL),IL(NL)
      DATA             RL,IL /NL*0,NL*0/
*     REAL AND  IMAGINARY  POINTERS TO RHS ARGUMENTS
*
      INTEGER          RR(NR),IR(NR)
*
*     LHS DATA TYPE
*
      INTEGER          FLAG(NL)
*
*     DIMENSIONS      (X,Y)  AND D = X*Y
*
      INTEGER          DL(NL),XL(NL),YL(NL)
      INTEGER          DR(NR),XR(NR),YR(NR),X(NR),Y(NR)
*
*     VARIABLES USED IN DATA TYPE CONVERSION
*
      INTEGER         B
      COMMON /BUFFER/ B
*
      COMMON  /M_RDH_DTS_DR/ A2
*
*     LOCAL FORTRAN VARIABLES
*
      INTEGER          A2     
      CHARACTER * (*)  A1     
      INTEGER          A3     (*)
      INTEGER          A7     (*)
      INTEGER          A8     (*)
      REAL             A4     (*)
      REAL             A5     (*)
      REAL             A6     (*)
*
*     DATA TYPE FOR LHS ARGUMENTS ( RE= 0 ,  IM = 1 )
*
      SAVE FLAG
      DATA FLAG       /0,0,0,0,0,0/
*
*     GET ARGUMENT DIMENSIONS AND POINTERS (RHS)
*
      CALL ZARG0(Q,P,PR,RR,IR,X,Y,DR,NR)
*
*     COPY MATLAB RHS (DIMENSION) INTEGERS TO FORTRAN
*                 ===
*
      CALL ZOUTI ( Q, P, 2    , A2   , DR, RR, IR, %VAL(B) )
*
*     GET SPECIFIED DIMENSION OF RHS ARGUMENTS
*
      CALL RD_STD_HDR_MR(XR,YR,DR,NR)
*
*     CHECK DIMENSION OF RHS ARGUMENTS
*
      CALL ZCHECK(Q,P,X,Y,XR,YR,DR,RR,NR)
*
*     COPY MATLAB RHS (NON-DIMENSION) ARGUMENTS TO FORTRAN
*                 ===
*
      CALL ZOUTS ( Q, P, 1    , A1   , PR)
*
*     GET DIMENSION OF LHS ARGUMENTS
*
      CALL RD_STD_HDR_ML(XL,YL,DL,X,Y,NL)
*
*     ALLOCATE SPACE AND GET POINTERS FOR LHS ARGUMENTS
*
      CALL ZARG1(PL,RL,IL,XL,YL,FLAG,NL)
*
*     CALL EXTERNAL FORTRAN PROCEDURE
*
      CALL   RD_STD_HDR_M(A1,A2,A3,A4,A5,A6,A7,A8)
*
*     COPY FORTRAN OUTPUT ARRAYS TO MATLAB ARRAYS
*                  ======
      CALL ZINI ( A3    , 1   , DL, RL, %VAL(B) )
      CALL ZINR ( A4    , 2   , DL, RL, %VAL(B) )
      CALL ZINR ( A5    , 3   , DL, RL, %VAL(B) )
      CALL ZINR ( A6    , 4   , DL, RL, %VAL(B) )
      CALL ZINI ( A7    , 5   , DL, RL, %VAL(B) )
      CALL ZINI ( A8    , 6   , DL, RL, %VAL(B) )
*
      RETURN
      END
 
      SUBROUTINE RD_STD_HDR_ML(X,Y,Z,U,V,W)
*
*     THIS SUBROUTINE RETURNS THE DIMENSIONS OF THE
*     LHS VARIABLES USING THE INTEGER SCALARS WHICH
*     ARE PASSED THROUGH THE COMMON BLOCK
*
      INTEGER          Q,W,X(*),Y(*),Z(*),U(*),V(*)
*
      INTEGER I2
      COMMON  /M_RDH_DTS_DR/ I2
*
      INTEGER  ZIDSET
      EXTERNAL ZIDSET
*
*
      X(1)     = I2
      Y(1)     = 1
*
      X(2)     = I2
      Y(2)     = 1
*
      X(3)     = I2
      Y(3)     = 1
*
      X(4)     = I2
      Y(4)     = 1
*
      X(5)     = I2
      Y(5)     = 1
*
      X(6)     = I2
      Y(6)     = 1
*
      DO 10 Q = 1 , W
         Z(Q) = X(Q) * Y(Q)
   10 CONTINUE
 
      RETURN
      END
 
      SUBROUTINE RD_STD_HDR_MR(X,Y,Z,W)
*
*     THIS SUBROUTINE RETURNS THE DIMENSIONS OF THE
*     RHS VARIABLES USING THE INTEGER SCALARS WHICH
*     ARE PASSED THROUGH THE COMMON BLOCK
*
*
      INTEGER          Q,W,X(*),Y(*),Z(*)
*
      INTEGER I2
      COMMON  /M_RDH_DTS_DR/ I2
*
      X(1)     = 1
      Y(1)     = 0
*
      X(2)     = 1
      Y(2)     = 1
*
      DO 10 Q = 1 , W
         Z(Q) = X(Q) * Y(Q)
   10 CONTINUE
*
      RETURN
      END
 

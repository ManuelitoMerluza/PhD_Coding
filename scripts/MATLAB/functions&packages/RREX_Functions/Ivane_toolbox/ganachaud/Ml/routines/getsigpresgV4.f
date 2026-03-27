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
*     POINTERS TO ARRAYS
*
      INTEGER          A4,A5,A6,A7,A8,A9
*
*     INTEGERS USED TO DIMENSION ARRAYS
*
      INTEGER          I1,I2,I3
*
      PARAMETER       (Q = 'getsigpres' , NL =1 , NR =8)
*
      PARAMETER (M=2048)
      CHARACTER*(M) NAMES
      CHARACTER*(30) PROCNM
      COMMON /ARGLST/ PROCNM,NAMES
      SAVE /ARGLST/
      EXTERNAL ZTEST
*
      NAMES='nd,np,ns,pres,botdep,imaxd,sigs,sigint'
      PROCNM=';getsigpres'
*
      CALL ZTEST(Q,NLHS,NRHS,NL,NR)
*
*     GET VALUES OF ALL INTEGER DIMENSIONS
*
      I1     = ZGETSCA (PR(1))
      I2     = ZGETSCA (PR(2))
      I3     = ZGETSCA (PR(3))
*
*     ALLOCATE SPACE FOR ALL ARRAY ARGUMENTS
*
      A4     = ZALREAL (I1)
      A5     = ZALREAL (I2)
      A6     = ZALREAL (I2)
      A7     = ZALREAL ((I1)*(I2))
      A8     = ZALREAL (I3)
      A9     = ZALREAL ((I2)*(I3))
*
*     ALLOCATE SPACE FOR BUFFER
*
      BSIZE  = MAX0   (1,(I1),(I2),(I2),(I1)*(I2),(I3),(I2)*(I3))
      B      = ZALREAL (BSIZE)
*
      CALL FCNGETSIGPRES(NLHS,PL,NRHS,PR,%VAL(A4),%VAL(A5),%VAL(A6),
     +                 %VAL(A7),%VAL(A8),%VAL(A9))
*
      RETURN
      END
 
      SUBROUTINE FCNGETSIGPRES(NLHS,PL,NRHS,PR,A4,A5,A6,A7,A8,A9)
*
      INTEGER          P, C
      PARAMETER       (P = 0, C = 255)
*
*     NUMBER OF LHS AND RHS ARGUMENTS ( NL AND NR )
*
      INTEGER          NL , NR
      CHARACTER *(C)   Q
*
      PARAMETER       (Q = 'getsigpres' , NL =1 , NR =8)
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
     +         ZCHECK,GETSIGPRES
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
      COMMON  /SERPGISTEG/ A1,A2,A3
*
*     LOCAL FORTRAN VARIABLES
*
      INTEGER          A1     
      INTEGER          A2     
      INTEGER          A3     
      INTEGER          A6     (*)
      DOUBLE PRECISION A4     (*)
      DOUBLE PRECISION A5     (*)
      DOUBLE PRECISION A7     (*)
      DOUBLE PRECISION A8     (*)
      DOUBLE PRECISION A9     (*)
*
*     DATA TYPE FOR LHS ARGUMENTS ( RE= 0 ,  IM = 1 )
*
      SAVE FLAG
      DATA FLAG       /0/
*
*     GET ARGUMENT DIMENSIONS AND POINTERS (RHS)
*
      CALL ZARG0(Q,P,PR,RR,IR,X,Y,DR,NR)
*
*     COPY MATLAB RHS (DIMENSION) INTEGERS TO FORTRAN
*                 ===
*
      CALL ZOUTI ( Q, P, 1    , A1   , DR, RR, IR, %VAL(B) )
      CALL ZOUTI ( Q, P, 2    , A2   , DR, RR, IR, %VAL(B) )
      CALL ZOUTI ( Q, P, 3    , A3   , DR, RR, IR, %VAL(B) )
*
*     GET SPECIFIED DIMENSION OF RHS ARGUMENTS
*
      CALL GETSIGPRESR(XR,YR,DR,NR)
*
*     CHECK DIMENSION OF RHS ARGUMENTS
*
      CALL ZCHECK(Q,P,X,Y,XR,YR,DR,RR,NR)
*
*     COPY MATLAB RHS (NON-DIMENSION) ARGUMENTS TO FORTRAN
*                 ===
*
      CALL ZOUTD ( Q, P, 4    , A4   , DR, RR, IR)
      CALL ZOUTD ( Q, P, 5    , A5   , DR, RR, IR)
      CALL ZOUTI ( Q, P, 6    , A6   , DR, RR, IR, %VAL(B) )
      CALL ZOUTD ( Q, P, 7    , A7   , DR, RR, IR)
      CALL ZOUTD ( Q, P, 8    , A8   , DR, RR, IR)
*
*     GET DIMENSION OF LHS ARGUMENTS
*
      CALL GETSIGPRESL(XL,YL,DL,X,Y,NL)
*
*     ALLOCATE SPACE AND GET POINTERS FOR LHS ARGUMENTS
*
      CALL ZARG1(PL,RL,IL,XL,YL,FLAG,NL)
*
*     CALL EXTERNAL FORTRAN PROCEDURE
*
      CALL   GETSIGPRES(A1,A2,A3,A4,A5,A6,A7,A8,A9)
*
*     COPY FORTRAN OUTPUT ARRAYS TO MATLAB ARRAYS
*                  ======
      CALL ZIND ( A9    , 1   , DL, RL)
*
      RETURN
      END
 
      SUBROUTINE GETSIGPRESL(X,Y,Z,U,V,W)
*
*     THIS SUBROUTINE RETURNS THE DIMENSIONS OF THE
*     LHS VARIABLES USING THE INTEGER SCALARS WHICH
*     ARE PASSED THROUGH THE COMMON BLOCK
*
      INTEGER          Q,W,X(*),Y(*),Z(*),U(*),V(*)
*
      INTEGER I1,I2,I3
      COMMON  /SERPGISTEG/ I1,I2,I3
*
      INTEGER  ZIDSET
      EXTERNAL ZIDSET
*
*
      X(1)     = I2
      Y(1)     = I3
*
      DO 10 Q = 1 , W
         Z(Q) = X(Q) * Y(Q)
   10 CONTINUE
 
      RETURN
      END
 
      SUBROUTINE GETSIGPRESR(X,Y,Z,W)
*
*     THIS SUBROUTINE RETURNS THE DIMENSIONS OF THE
*     RHS VARIABLES USING THE INTEGER SCALARS WHICH
*     ARE PASSED THROUGH THE COMMON BLOCK
*
*
      INTEGER          Q,W,X(*),Y(*),Z(*)
*
      INTEGER I1,I2,I3
      COMMON  /SERPGISTEG/ I1,I2,I3
*
      X(1)     = 1
      Y(1)     = 1
*
      X(2)     = 1
      Y(2)     = 1
*
      X(3)     = 1
      Y(3)     = 1
*
      X(4)     = I1
      Y(4)     = 1
*
      X(5)     = I2
      Y(5)     = 1
*
      X(6)     = I2
      Y(6)     = 1
*
      X(7)     = I1
      Y(7)     = I2
*
      X(8)     = I3
      Y(8)     = 1
*
      DO 10 Q = 1 , W
         Z(Q) = X(Q) * Y(Q)
   10 CONTINUE
*
      RETURN
      END
 

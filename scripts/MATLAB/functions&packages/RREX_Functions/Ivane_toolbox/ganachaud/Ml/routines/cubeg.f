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
      INTEGER          A1,A2
*
*     INTEGERS USED TO DIMENSION ARRAYS
*
      INTEGER          I3
*
      PARAMETER       (Q = 'cube' , NL =1 , NR =2)
*
      PARAMETER (M=2048)
      CHARACTER*(M) NAMES
      CHARACTER*(30) PROCNM
      COMMON /ARGLST/ PROCNM,NAMES
      SAVE /ARGLST/
      EXTERNAL ZTEST
*
      NAMES='x,idim'
      PROCNM='5cube'
*
      CALL ZTEST(Q,NLHS,NRHS,NL,NR)
*
*     GET VALUES OF ALL INTEGER DIMENSIONS
*
      I3     = ZGETSCA (PR(2))
*
*     ALLOCATE SPACE FOR ALL ARRAY ARGUMENTS
*
      A1     = ZALREAL (I3)
      A2     = ZALREAL (I3)
*
*     ALLOCATE SPACE FOR BUFFER
*
      BSIZE  = MAX0   (1,(I3),(I3))
      B      = ZALREAL (BSIZE)
*
      CALL FCNCUBE(NLHS,PL,NRHS,PR,%VAL(A1),%VAL(A2))
*
      RETURN
      END
 
      SUBROUTINE FCNCUBE(NLHS,PL,NRHS,PR,A1,A2)
*
      INTEGER          P, C
      PARAMETER       (P = 0, C = 255)
*
*     NUMBER OF LHS AND RHS ARGUMENTS ( NL AND NR )
*
      INTEGER          NL , NR
      CHARACTER *(C)   Q
*
      PARAMETER       (Q = 'cube' , NL =1 , NR =2)
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
     +         ZCHECK,CUBE
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
      COMMON  /EBUC/ A3
*
*     LOCAL FORTRAN VARIABLES
*
      INTEGER          A3     
      REAL             A1     (*)
      REAL             A2     (*)
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
      CALL ZOUTI ( Q, P, 2    , A3   , DR, RR, IR, %VAL(B) )
*
*     GET SPECIFIED DIMENSION OF RHS ARGUMENTS
*
      CALL CUBER(XR,YR,DR,NR)
*
*     CHECK DIMENSION OF RHS ARGUMENTS
*
      CALL ZCHECK(Q,P,X,Y,XR,YR,DR,RR,NR)
*
*     COPY MATLAB RHS (NON-DIMENSION) ARGUMENTS TO FORTRAN
*                 ===
*
      CALL ZOUTR ( Q, P, 1    , A1   , DR, RR, IR, %VAL(B) )
*
*     GET DIMENSION OF LHS ARGUMENTS
*
      CALL CUBEL(XL,YL,DL,X,Y,NL)
*
*     ALLOCATE SPACE AND GET POINTERS FOR LHS ARGUMENTS
*
      CALL ZARG1(PL,RL,IL,XL,YL,FLAG,NL)
*
*     CALL EXTERNAL FORTRAN PROCEDURE
*
      CALL   CUBE(A1,A2,A3)
*
*     COPY FORTRAN OUTPUT ARRAYS TO MATLAB ARRAYS
*                  ======
      CALL ZINR ( A2    , 1   , DL, RL, %VAL(B) )
*
      RETURN
      END
 
      SUBROUTINE CUBEL(X,Y,Z,U,V,W)
*
*     THIS SUBROUTINE RETURNS THE DIMENSIONS OF THE
*     LHS VARIABLES USING THE INTEGER SCALARS WHICH
*     ARE PASSED THROUGH THE COMMON BLOCK
*
      INTEGER          Q,W,X(*),Y(*),Z(*),U(*),V(*)
*
      INTEGER I3
      COMMON  /EBUC/ I3
*
      INTEGER  ZIDSET
      EXTERNAL ZIDSET
*
*
      X(1)     = I3
      Y(1)     = 1
*
      DO 10 Q = 1 , W
         Z(Q) = X(Q) * Y(Q)
   10 CONTINUE
 
      RETURN
      END
 
      SUBROUTINE CUBER(X,Y,Z,W)
*
*     THIS SUBROUTINE RETURNS THE DIMENSIONS OF THE
*     RHS VARIABLES USING THE INTEGER SCALARS WHICH
*     ARE PASSED THROUGH THE COMMON BLOCK
*
*
      INTEGER          Q,W,X(*),Y(*),Z(*)
*
      INTEGER I3
      COMMON  /EBUC/ I3
*
      X(1)     = I3
      Y(1)     = 1
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
 

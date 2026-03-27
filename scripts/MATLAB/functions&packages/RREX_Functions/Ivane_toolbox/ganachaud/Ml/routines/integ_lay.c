static char mc_version[] = "MATLAB Compiler 1.0 infun";
/*
 *  MATLAB Compiler: 1.0
 *  Date: Oct 20, 1995
 *  Arguments: integ_lay 
 */
#include <math.h>
#include "mex.h"
#include "mcc.h"


void
mexFunction(
    int nlhs_,
    Matrix *plhs_[],
    int nrhs_,
    Matrix *prhs_[]
)
{
   int ci_, i_, j_;
   unsigned flags_;
   Matrix *Mplhs_[32], *Mprhs_[32];
   for (ci_=i_=0; i_<nrhs_; ++i_)
   {
      if (prhs_[i_]->pi)
      {
         ci_ = 1;
         break;
      }
      if (prhs_[i_]->pr)
      {
         break;
      }
   }
   if (ci_)
   {
/***************** Compiler Assumptions ****************
 *
 *       Botdep      	complex vector/matrix
 *       C0_         	complex scalar temporary
 *       CM0_        	complex vector/matrix temporary
 *       Dep         	complex vector/matrix
 *       I0_         	integer scalar temporary
 *       NaN         	<function>
 *       R0_         	real scalar temporary
 *       R1_         	real scalar temporary
 *       RM0_        	real vector/matrix temporary
 *       deep        	complex vector/matrix
 *       dratio      	complex vector/matrix
 *       find        	<function>
 *       gid         	real vector/matrix
 *       id          	integer scalar
 *       idep        	integer scalar
 *       iid         	integer scalar
 *       il          	integer scalar
 *       integ_lay   	<function being defined>
 *       ip          	integer scalar
 *       laydepth    	complex scalar
 *       lbot        	integer scalar
 *       ldist       	complex scalar
 *       ldist       	complex vector/matrix  => ldist_1
 *       length      	<function>
 *       lidep       	complex vector/matrix
 *       linteg      	complex vector/matrix
 *       lipropint   	complex vector/matrix
 *       lprop       	complex vector/matrix
 *       ltop        	integer scalar
 *       max         	<function>
 *       min         	<function>
 *       nd          	integer scalar
 *       nl          	integer scalar
 *       np          	integer scalar
 *       ppropint    	complex vector/matrix
 *       sdist       	complex vector/matrix
 *       shallow     	complex vector/matrix
 *       size        	<function>
 *       trapz       	<function>
 *       zinteg      	real vector/matrix
 *******************************************************/
      Matrix lprop;
      Matrix lidep;
      Matrix lipropint;
      Matrix Dep;
      Matrix ppropint;
      Matrix sdist;
      Matrix Botdep;
      int np;
      int nl;
      int nd;
      int il;
      int ltop;
      int lbot;
      int ip;
      double laydepth_r, laydepth_i;
      Matrix deep;
      Matrix shallow;
      Matrix dratio;
      int idep;
      Matrix linteg;
      Matrix zinteg;
      double ldist_r, ldist_i;
      Matrix gid;
      int iid;
      int id;
      Matrix ldist_1;
      Matrix CM0_;
      Matrix RM0_;
      double R0_;
      double C0__r, C0__i;
      double R1_;
      int I0_;
      
      mccComplexInit(lidep);
      mccImport(&lidep, ((nrhs_>0) ? prhs_[0] : 0), 0, 0);
      mccComplexInit(lipropint);
      mccImport(&lipropint, ((nrhs_>1) ? prhs_[1] : 0), 0, 0);
      mccComplexInit(Dep);
      mccImport(&Dep, ((nrhs_>2) ? prhs_[2] : 0), 0, 0);
      mccComplexInit(ppropint);
      mccImport(&ppropint, ((nrhs_>3) ? prhs_[3] : 0), 0, 0);
      mccComplexInit(sdist);
      mccImport(&sdist, ((nrhs_>4) ? prhs_[4] : 0), 0, 0);
      mccComplexInit(Botdep);
      mccImport(&Botdep, ((nrhs_>5) ? prhs_[5] : 0), 0, 0);
      mccComplexInit(lprop);
      mccComplexInit(deep);
      mccComplexInit(shallow);
      mccComplexInit(dratio);
      mccComplexInit(linteg);
      mccRealInit(zinteg);
      mccRealInit(gid);
      mccComplexInit(ldist_1);
      mccComplexInit(CM0_);
      mccRealInit(RM0_);
      
      /* % KEY:   integrate the property in each layer */
      /* % USAGE : */
      
      
      /* % DESCRIPTION :  */
      /* % integrate the property between layer interfaces, last */
      /* % is the top to bottom one */
      
      /* % Trapezoidal integration, takes the bottom triangle into account */
      
      /* % INPUT: */
      /* % ip = pair indice */
      /* % il = layer indice */
      /* % id = std. depth indice */
      /* % is = station indice */
      
      /* % lidep(ip,il)     (m)  depth at layer interface */
      /* % lipropint(ip,il)      property to integrate at layer interface */
      /* % Dep(id,ip)       (m)  std. depth */
      /* % ppropint(id,ip)       property to integrate, at std. depth */
      /* % sdist(ip)        (km) distance between stations */
      /* % Botdep(is)       (m)  bottom depth */
      
      /* % OUTPUT: */
      
      /* % lprop(ip.il)     (m^2)*property : integrated property in layer  */
      
      
      /* % AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , April 97 */
      
      /* % SIDE EFFECTS : */
      
      /* % SEE ALSO : */
      
      /* % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% */
      /* % CALLER: */
      /* % CALLEE: */
      /* [np,nl]=size(lidep); */
      if( lidep.flags & mccNOTSET )
      {
         mexErrMsgTxt( "variable lidep undefined, line 39" );
      }
      mccGetMatrixSize(&np,&nl, &lidep);
      /* nd=length(Dep); */
      if( Dep.flags & mccNOTSET )
      {
         mexErrMsgTxt( "variable Dep undefined, line 40" );
      }
      nd = mccGetLength(&Dep);
      
      /* % LOOP OVER LAYERS */
      /* for il=1:nl */
      for (il = 1; il <= nl; il = il + 1)
      {
         /* %DEFINE INDICES FOR TOP/BOTTOM INTERFACE */
         /* if il<nl */
         if ((il < nl))
         {
            /* ltop=il; */
            ltop = il;
            /* lbot=il+1; */
            lbot = (il + 1);
            /* else %last is top to bottom */
         }
         else
         {
            /* ltop=1; */
            ltop = 1;
            /* lbot=nl; */
            lbot = nl;
            /* end */
         }
         
         /* %LOOP OVER PAIRS */
         /* for ip=1:np */
         for (ip = 1; ip <= np; ip = ip + 1)
         {
            /* laydepth=lidep(ip,lbot)-lidep(ip,ltop); */
            laydepth_r = ((mccGetRealMatrixElement(&lidep, (int)ip, (int)lbot)) - (mccGetRealMatrixElement(&lidep, (int)ip, (int)ltop)));
            laydepth_i = (mccGetImagMatrixElement(&lidep, (int)ip, (int)lbot) - mccGetImagMatrixElement(&lidep, (int)ip, (int)ltop));
            /* if laydepth<1e-6 */
            if ((laydepth_r < 1e-6))
            {
               /* lprop(ip,il)=0; */
               mccSetMatrixElement(&lprop, ip, il, 0, 0.);
               lprop.dmode = mxNUMBER;
               /* else */
            }
            else
            {
               /* deep=max([Botdep(ip),Botdep(ip+1)]); */
               mccCatenateColumns(&CM0_, mccTempVectorElement(&Botdep, ip), mccTempVectorElement(&Botdep, (ip + 1)));
               Mprhs_[0] = &CM0_;
               Mplhs_[0] = &deep;
               mccCallMATLAB(1, Mplhs_, 1, Mprhs_, "max", 59);
               /* shallow=min([Botdep(ip),Botdep(ip+1)]); */
               mccCatenateColumns(&CM0_, mccTempVectorElement(&Botdep, ip), mccTempVectorElement(&Botdep, (ip + 1)));
               Mprhs_[0] = &CM0_;
               Mplhs_[0] = &shallow;
               mccCallMATLAB(1, Mplhs_, 1, Mprhs_, "min", 60);
               /* if deep==shallow */
               RM0_.dmode = mxNUMBER;
               {
                  int m_=1, n_=1, cx_ = 0;
                  double t_;
                  double *p_RM0_;
                  int I_RM0_=1;
                  double *p_deep;
                  int I_deep=1;
                  double *q_deep;
                  double *p_shallow;
                  int I_shallow=1;
                  double *q_shallow;
                  m_ = mcmCalcResultSize(m_, &n_, deep.m, deep.n);
                  m_ = mcmCalcResultSize(m_, &n_, shallow.m, shallow.n);
                  mccAllocateMatrix(&RM0_, m_, n_);
                  I_RM0_ = (RM0_.m != 1 || RM0_.n != 1);
                  p_RM0_ = RM0_.pr;
                  I_deep = (deep.m != 1 || deep.n != 1);
                  p_deep = deep.pr;
                  q_deep = deep.pi;
                  I_shallow = (shallow.m != 1 || shallow.n != 1);
                  p_shallow = shallow.pr;
                  q_shallow = shallow.pi;
                  for (j_=0; j_<n_; ++j_)
                  {
                     for (i_=0; i_<m_; ++i_, p_RM0_+=I_RM0_, p_deep+=I_deep, q_deep+=I_deep, p_shallow+=I_shallow, q_shallow+=I_shallow)
                     {
                        *p_RM0_ = ((*p_deep == *p_shallow) && (*q_deep == *q_shallow));
                        ;
                     }
                  }
               }
               RM0_.dmode = mxNUMBER;
               if (mccIfCondition(&RM0_))
               {
                  /* dratio=NaN */
                  R0_ = mexGetNaN();
                  {
                     double tr_ = R0_;
                     mccAllocateMatrix(&dratio, 1, 1);
                     *dratio.pr = tr_;
                  }
                  *dratio.pi = 0.;
                  dratio.dmode = mxNUMBER;
                  mccPrint (&dratio, "dratio");
                  /* else */
               }
               else
               {
                  /* dratio=1e3*sdist(ip)/(deep-shallow); */
                  C0__r = (1e3 * (mccGetRealVectorElement(&sdist, (int)ip)));
                  C0__i = (1e3 * mccGetImagVectorElement(&sdist, (int)ip));
                  CM0_.dmode = mxNUMBER;
                  {
                     int m_=1, n_=1, cx_ = 0;
                     double t_;
                     double *p_CM0_;
                     int I_CM0_=1;
                     double *q_CM0_;
                     double *p_deep;
                     int I_deep=1;
                     double *q_deep;
                     double *p_shallow;
                     int I_shallow=1;
                     double *q_shallow;
                     m_ = mcmCalcResultSize(m_, &n_, deep.m, deep.n);
                     m_ = mcmCalcResultSize(m_, &n_, shallow.m, shallow.n);
                     mccAllocateMatrix(&CM0_, m_, n_);
                     I_CM0_ = (CM0_.m != 1 || CM0_.n != 1);
                     p_CM0_ = CM0_.pr;
                     q_CM0_ = CM0_.pi;
                     I_deep = (deep.m != 1 || deep.n != 1);
                     p_deep = deep.pr;
                     q_deep = deep.pi;
                     I_shallow = (shallow.m != 1 || shallow.n != 1);
                     p_shallow = shallow.pr;
                     q_shallow = shallow.pi;
                     for (j_=0; j_<n_; ++j_)
                     {
                        for (i_=0; i_<m_; ++i_, p_CM0_+=I_CM0_, q_CM0_+=I_CM0_, p_deep+=I_deep, q_deep+=I_deep, p_shallow+=I_shallow, q_shallow+=I_shallow)
                        {
                           *p_CM0_ = (*p_deep - *p_shallow);
                           *q_CM0_ = (*q_deep - *q_shallow);
                           ;
                        }
                     }
                  }
                  CM0_.dmode = mxNUMBER;
                  mccRightDivide(&dratio, mccTempMatrix(C0__r, C0__i, mxNUMBER|mccCOMPLEX), &CM0_);
                  /* end */
               }
               
               /* %IDEP WILL BE THE NUMBER OF DEPTH OVER WHICH THE INTEGRATION */
               /* %IS MADE = 1 (top interface)+ 1(bot.int.) + number of std. */
               /* %depths between top and bot interfaces  */
               /* idep=1; */
               idep = 1;
               /* linteg=[]; */
               mccCreateEmpty(&linteg);
               /* zinteg=[]; */
               mccCreateEmpty(&zinteg);
               
               /* %SET INTEGRAND AT TOP OF LAYER */
               /* if lidep(ip,ltop)>shallow */
               R0_ = (mccGetRealMatrixElement(&lidep, ip, ltop));
               RM0_.dmode = mxNUMBER;
               {
                  int m_=1, n_=1, cx_ = 0;
                  double t_;
                  double *p_RM0_;
                  int I_RM0_=1;
                  double *p_shallow;
                  int I_shallow=1;
                  double *q_shallow;
                  m_ = mcmCalcResultSize(m_, &n_, shallow.m, shallow.n);
                  mccAllocateMatrix(&RM0_, m_, n_);
                  I_RM0_ = (RM0_.m != 1 || RM0_.n != 1);
                  p_RM0_ = RM0_.pr;
                  I_shallow = (shallow.m != 1 || shallow.n != 1);
                  p_shallow = shallow.pr;
                  q_shallow = shallow.pi;
                  for (j_=0; j_<n_; ++j_)
                  {
                     for (i_=0; i_<m_; ++i_, p_RM0_+=I_RM0_, p_shallow+=I_shallow, q_shallow+=I_shallow)
                     {
                        *p_RM0_ = (R0_ > *p_shallow);
                        ;
                     }
                  }
               }
               RM0_.dmode = mxNUMBER;
               if (mccIfCondition(&RM0_))
               {
                  /* ldist=dratio*(deep-lidep(ip,ltop)); */
                  R0_ = (mccGetRealMatrixElement(&lidep, ip, ltop));
                  CM0_.dmode = mxNUMBER;
                  {
                     int m_=1, n_=1, cx_ = 0;
                     double t_;
                     double *p_CM0_;
                     int I_CM0_=1;
                     double *q_CM0_;
                     double *p_deep;
                     int I_deep=1;
                     double *q_deep;
                     m_ = mcmCalcResultSize(m_, &n_, deep.m, deep.n);
                     mccAllocateMatrix(&CM0_, m_, n_);
                     I_CM0_ = (CM0_.m != 1 || CM0_.n != 1);
                     p_CM0_ = CM0_.pr;
                     q_CM0_ = CM0_.pi;
                     I_deep = (deep.m != 1 || deep.n != 1);
                     p_deep = deep.pr;
                     q_deep = deep.pi;
                     for (j_=0; j_<n_; ++j_)
                     {
                        for (i_=0; i_<m_; ++i_, p_CM0_+=I_CM0_, q_CM0_+=I_CM0_, p_deep+=I_deep, q_deep+=I_deep)
                        {
                           *p_CM0_ = (*p_deep - R0_);
                           *q_CM0_ = (*q_deep - 0.);
                           ;
                        }
                     }
                  }
                  CM0_.dmode = mxNUMBER;
                  mccInnerProduct(&ldist_r, &ldist_i, &dratio, &CM0_);
                  /* else */
               }
               else
               {
                  /* ldist=1e3*sdist(ip); */
                  ldist_r = (1e3 * (mccGetRealVectorElement(&sdist, (int)ip)));
                  ldist_i = (1e3 * mccGetImagVectorElement(&sdist, (int)ip));
                  /* end */
               }
               /* %INTEGRAND */
               /* linteg(idep)=ldist*lipropint(ip,ltop);  */
               mccSetVectorElement(&linteg, idep, (ldist_r * (mccGetRealMatrixElement(&lipropint, (int)ip, (int)ltop)) - ldist_i * mccGetImagMatrixElement(&lipropint, (int)ip, (int)ltop)), (ldist_r * mccGetImagMatrixElement(&lipropint, (int)ip, (int)ltop) + ldist_i * (mccGetRealMatrixElement(&lipropint, (int)ip, (int)ltop))));
               linteg.dmode = mxNUMBER;
               /* zinteg(idep)=lidep(ip,ltop); */
               mccSetRealVectorElement(&zinteg, idep, (mccGetRealMatrixElement(&lidep, ip, ltop)));
               zinteg.dmode = mxNUMBER;
               
               /* %SET INTEGRAND IN THE INTERMEDIATE STANDART DEPTHS */
               /* gid=find( (Dep(:,ip)>lidep(ip,ltop)) & ... */
               R0_ = (mccGetRealMatrixElement(&lidep, ip, ltop));
               R1_ = (mccGetRealMatrixElement(&lidep, ip, lbot));
               RM0_.dmode = mxNUMBER;
               {
                  int m_=1, n_=1, cx_ = 0;
                  double t_;
                  double *p_RM0_;
                  int I_RM0_=1;
                  double *p_Dep;
                  int I_Dep=1, J_Dep;
                  double *p_1Dep;
                  int I_1Dep=1, J_1Dep;
                  m_ = mcmCalcResultSize(m_, &n_, Dep.m, 1);
                  m_ = mcmCalcResultSize(m_, &n_, Dep.m, 1);
                  mccAllocateMatrix(&RM0_, m_, n_);
                  mccCheckMatrixSize(&Dep, m_, ip);
                  mccCheckMatrixSize(&Dep, m_, ip);
                  I_RM0_ = (RM0_.m != 1 || RM0_.n != 1);
                  p_RM0_ = RM0_.pr;
                  if (Dep.m == 1 && Dep.n == 1) { I_Dep = J_Dep = 0; }
                  else { I_Dep=1; J_Dep=Dep.m-m_; }
                  p_Dep = Dep.pr + 0 + Dep.m * (ip-1);
                  if (Dep.m == 1 && Dep.n == 1) { I_1Dep = J_1Dep = 0; }
                  else { I_1Dep=1; J_1Dep=Dep.m-m_; }
                  p_1Dep = Dep.pr + 0 + Dep.m * (ip-1);
                  for (j_=0; j_<n_; ++j_, p_Dep += J_Dep, p_1Dep += J_1Dep)
                  {
                     for (i_=0; i_<m_; ++i_, p_RM0_+=I_RM0_, p_Dep+=I_Dep, p_1Dep+=I_1Dep)
                     {
                        *p_RM0_ = (!!(*p_Dep > R0_) && !!(*p_1Dep < R1_));
                        ;
                     }
                  }
               }
               RM0_.dmode = mxNUMBER;
               mccFind(&gid, &RM0_);
               /* for iid=1:length(gid) */
               I0_ = mccGetLength(&gid);
               for (iid = 1; iid <= I0_; iid = iid + 1)
               {
                  /* id=gid(iid); */
                  id = ((int)mccGetRealVectorElement(&gid, iid));
                  /* idep=idep+1; */
                  idep = (idep + 1);
                  /* if Dep(id,ip)>shallow */
                  R1_ = (mccGetRealMatrixElement(&Dep, id, ip));
                  RM0_.dmode = mxNUMBER;
                  {
                     int m_=1, n_=1, cx_ = 0;
                     double t_;
                     double *p_RM0_;
                     int I_RM0_=1;
                     double *p_shallow;
                     int I_shallow=1;
                     double *q_shallow;
                     m_ = mcmCalcResultSize(m_, &n_, shallow.m, shallow.n);
                     mccAllocateMatrix(&RM0_, m_, n_);
                     I_RM0_ = (RM0_.m != 1 || RM0_.n != 1);
                     p_RM0_ = RM0_.pr;
                     I_shallow = (shallow.m != 1 || shallow.n != 1);
                     p_shallow = shallow.pr;
                     q_shallow = shallow.pi;
                     for (j_=0; j_<n_; ++j_)
                     {
                        for (i_=0; i_<m_; ++i_, p_RM0_+=I_RM0_, p_shallow+=I_shallow, q_shallow+=I_shallow)
                        {
                           *p_RM0_ = (R1_ > *p_shallow);
                           ;
                        }
                     }
                  }
                  RM0_.dmode = mxNUMBER;
                  if (mccIfCondition(&RM0_))
                  {
                     /* ldist=dratio*(deep-Dep(id,ip)); */
                     R1_ = (mccGetRealMatrixElement(&Dep, id, ip));
                     CM0_.dmode = mxNUMBER;
                     {
                        int m_=1, n_=1, cx_ = 0;
                        double t_;
                        double *p_CM0_;
                        int I_CM0_=1;
                        double *q_CM0_;
                        double *p_deep;
                        int I_deep=1;
                        double *q_deep;
                        m_ = mcmCalcResultSize(m_, &n_, deep.m, deep.n);
                        mccAllocateMatrix(&CM0_, m_, n_);
                        I_CM0_ = (CM0_.m != 1 || CM0_.n != 1);
                        p_CM0_ = CM0_.pr;
                        q_CM0_ = CM0_.pi;
                        I_deep = (deep.m != 1 || deep.n != 1);
                        p_deep = deep.pr;
                        q_deep = deep.pi;
                        for (j_=0; j_<n_; ++j_)
                        {
                           for (i_=0; i_<m_; ++i_, p_CM0_+=I_CM0_, q_CM0_+=I_CM0_, p_deep+=I_deep, q_deep+=I_deep)
                           {
                              *p_CM0_ = (*p_deep - R1_);
                              *q_CM0_ = (*q_deep - 0.);
                              ;
                           }
                        }
                     }
                     CM0_.dmode = mxNUMBER;
                     mccMultiply(&ldist_1, &dratio, &CM0_);
                     /* else */
                  }
                  else
                  {
                     /* ldist=1e3*sdist(ip); */
                     {
                        double tr_ = (1e3 * (mccGetRealVectorElement(&sdist, (int)ip)));
                        double ti_ = (1e3 * mccGetImagVectorElement(&sdist, (int)ip));
                        mccAllocateMatrix(&ldist_1, 1, 1);
                        *ldist_1.pr = tr_;
                        *ldist_1.pi = ti_;
                     }
                     ldist_1.dmode = mxNUMBER;
                     /* end */
                  }
                  /* linteg(idep)=ldist*ppropint(id,ip); */
                  C0__r = (mccGetRealMatrixElement(&ppropint, (int)id, (int)ip));
                  C0__i = mccGetImagMatrixElement(&ppropint, (int)id, (int)ip);
                  CM0_.dmode = mxNUMBER;
                  {
                     int m_=1, n_=1, cx_ = 0;
                     double t_;
                     double *p_CM0_;
                     int I_CM0_=1;
                     double *q_CM0_;
                     double *p_ldist_1;
                     int I_ldist_1=1;
                     double *q_ldist_1;
                     m_ = mcmCalcResultSize(m_, &n_, ldist_1.m, ldist_1.n);
                     mccAllocateMatrix(&CM0_, m_, n_);
                     I_CM0_ = (CM0_.m != 1 || CM0_.n != 1);
                     p_CM0_ = CM0_.pr;
                     q_CM0_ = CM0_.pi;
                     I_ldist_1 = (ldist_1.m != 1 || ldist_1.n != 1);
                     p_ldist_1 = ldist_1.pr;
                     q_ldist_1 = ldist_1.pi;
                     for (j_=0; j_<n_; ++j_)
                     {
                        for (i_=0; i_<m_; ++i_, p_CM0_+=I_CM0_, q_CM0_+=I_CM0_, p_ldist_1+=I_ldist_1, q_ldist_1+=I_ldist_1)
                        {
                           {
                              double t_ = (*p_ldist_1 * C0__r - *q_ldist_1 * C0__i);
                              *q_CM0_ = (*p_ldist_1 * C0__i + *q_ldist_1 * C0__r);
                              *p_CM0_ = t_;
                           }
                           ;
                        }
                     }
                  }
                  CM0_.dmode = mxNUMBER;
                  mccSetVectorElement(&linteg, idep, (mccGetRealVectorElement(&CM0_, (int)1)), mccGetImagVectorElement(&CM0_, (int)1));
                  linteg.dmode = mxNUMBER;
                  /* zinteg(idep)=Dep(id,ip); */
                  mccSetRealVectorElement(&zinteg, idep, (mccGetRealMatrixElement(&Dep, id, ip)));
                  zinteg.dmode = mxNUMBER;
                  /* end %on id */
               }
               
               /* %SET INTEGRAND AT BOTTOM OF LAYER */
               /* idep=idep+1; */
               idep = (idep + 1);
               /* if lidep(ip,lbot)>shallow */
               R1_ = (mccGetRealMatrixElement(&lidep, ip, lbot));
               RM0_.dmode = mxNUMBER;
               {
                  int m_=1, n_=1, cx_ = 0;
                  double t_;
                  double *p_RM0_;
                  int I_RM0_=1;
                  double *p_shallow;
                  int I_shallow=1;
                  double *q_shallow;
                  m_ = mcmCalcResultSize(m_, &n_, shallow.m, shallow.n);
                  mccAllocateMatrix(&RM0_, m_, n_);
                  I_RM0_ = (RM0_.m != 1 || RM0_.n != 1);
                  p_RM0_ = RM0_.pr;
                  I_shallow = (shallow.m != 1 || shallow.n != 1);
                  p_shallow = shallow.pr;
                  q_shallow = shallow.pi;
                  for (j_=0; j_<n_; ++j_)
                  {
                     for (i_=0; i_<m_; ++i_, p_RM0_+=I_RM0_, p_shallow+=I_shallow, q_shallow+=I_shallow)
                     {
                        *p_RM0_ = (R1_ > *p_shallow);
                        ;
                     }
                  }
               }
               RM0_.dmode = mxNUMBER;
               if (mccIfCondition(&RM0_))
               {
                  /* ldist=dratio*(deep-lidep(ip,lbot)); */
                  R1_ = (mccGetRealMatrixElement(&lidep, ip, lbot));
                  CM0_.dmode = mxNUMBER;
                  {
                     int m_=1, n_=1, cx_ = 0;
                     double t_;
                     double *p_CM0_;
                     int I_CM0_=1;
                     double *q_CM0_;
                     double *p_deep;
                     int I_deep=1;
                     double *q_deep;
                     m_ = mcmCalcResultSize(m_, &n_, deep.m, deep.n);
                     mccAllocateMatrix(&CM0_, m_, n_);
                     I_CM0_ = (CM0_.m != 1 || CM0_.n != 1);
                     p_CM0_ = CM0_.pr;
                     q_CM0_ = CM0_.pi;
                     I_deep = (deep.m != 1 || deep.n != 1);
                     p_deep = deep.pr;
                     q_deep = deep.pi;
                     for (j_=0; j_<n_; ++j_)
                     {
                        for (i_=0; i_<m_; ++i_, p_CM0_+=I_CM0_, q_CM0_+=I_CM0_, p_deep+=I_deep, q_deep+=I_deep)
                        {
                           *p_CM0_ = (*p_deep - R1_);
                           *q_CM0_ = (*q_deep - 0.);
                           ;
                        }
                     }
                  }
                  CM0_.dmode = mxNUMBER;
                  mccMultiply(&ldist_1, &dratio, &CM0_);
                  /* else */
               }
               else
               {
                  /* ldist=1e3*sdist(ip); */
                  {
                     double tr_ = (1e3 * (mccGetRealVectorElement(&sdist, (int)ip)));
                     double ti_ = (1e3 * mccGetImagVectorElement(&sdist, (int)ip));
                     mccAllocateMatrix(&ldist_1, 1, 1);
                     *ldist_1.pr = tr_;
                     *ldist_1.pi = ti_;
                  }
                  ldist_1.dmode = mxNUMBER;
                  /* end */
               }
               /* linteg(idep)=ldist*lipropint(ip,lbot); */
               C0__r = (mccGetRealMatrixElement(&lipropint, (int)ip, (int)lbot));
               C0__i = mccGetImagMatrixElement(&lipropint, (int)ip, (int)lbot);
               CM0_.dmode = mxNUMBER;
               {
                  int m_=1, n_=1, cx_ = 0;
                  double t_;
                  double *p_CM0_;
                  int I_CM0_=1;
                  double *q_CM0_;
                  double *p_ldist_1;
                  int I_ldist_1=1;
                  double *q_ldist_1;
                  m_ = mcmCalcResultSize(m_, &n_, ldist_1.m, ldist_1.n);
                  mccAllocateMatrix(&CM0_, m_, n_);
                  I_CM0_ = (CM0_.m != 1 || CM0_.n != 1);
                  p_CM0_ = CM0_.pr;
                  q_CM0_ = CM0_.pi;
                  I_ldist_1 = (ldist_1.m != 1 || ldist_1.n != 1);
                  p_ldist_1 = ldist_1.pr;
                  q_ldist_1 = ldist_1.pi;
                  for (j_=0; j_<n_; ++j_)
                  {
                     for (i_=0; i_<m_; ++i_, p_CM0_+=I_CM0_, q_CM0_+=I_CM0_, p_ldist_1+=I_ldist_1, q_ldist_1+=I_ldist_1)
                     {
                        {
                           double t_ = (*p_ldist_1 * C0__r - *q_ldist_1 * C0__i);
                           *q_CM0_ = (*p_ldist_1 * C0__i + *q_ldist_1 * C0__r);
                           *p_CM0_ = t_;
                        }
                        ;
                     }
                  }
               }
               CM0_.dmode = mxNUMBER;
               mccSetVectorElement(&linteg, idep, (mccGetRealVectorElement(&CM0_, (int)1)), mccGetImagVectorElement(&CM0_, (int)1));
               linteg.dmode = mxNUMBER;
               /* zinteg(idep)=lidep(ip,lbot); */
               mccSetRealVectorElement(&zinteg, idep, (mccGetRealMatrixElement(&lidep, ip, lbot)));
               zinteg.dmode = mxNUMBER;
               
               /* %DO THE INTEGRATION FOR THIS LAYER, THIS PAIR */
               /* lprop(ip,il)=trapz(zinteg,linteg); */
               Mprhs_[0] = &zinteg;
               Mprhs_[1] = &linteg;
               Mplhs_[0] = &CM0_;
               mccCallMATLAB(1, Mplhs_, 2, Mprhs_, "trapz", 110);
               mccSetMatrixElement(&lprop, ip, il, (mccGetRealVectorElement(&CM0_, (int)1)), mccGetImagVectorElement(&CM0_, (int)1));
               lprop.dmode = mxNUMBER;
               
               /* end %if laydepth<1e-6 */
            }
            /* end %loop on ip */
         }
         
         /* end %loop on nl */
      }
      mccReturnFirstValue(&plhs_[0], &lprop);
   }
   else
   {
/***************** Compiler Assumptions ****************
 *
 *       Botdep      	real vector/matrix
 *       Dep         	real vector/matrix
 *       I0_         	integer scalar temporary
 *       NaN         	<function>
 *       R0_         	real scalar temporary
 *       R1_         	real scalar temporary
 *       RM0_        	real vector/matrix temporary
 *       deep        	real vector/matrix
 *       dratio      	real vector/matrix
 *       find        	<function>
 *       gid         	real vector/matrix
 *       id          	integer scalar
 *       idep        	integer scalar
 *       iid         	integer scalar
 *       il          	integer scalar
 *       integ_lay   	<function being defined>
 *       ip          	integer scalar
 *       laydepth    	real scalar
 *       lbot        	integer scalar
 *       ldist       	real scalar
 *       ldist       	real vector/matrix  => ldist_1
 *       length      	<function>
 *       lidep       	real vector/matrix
 *       linteg      	real vector/matrix
 *       lipropint   	real vector/matrix
 *       lprop       	real vector/matrix
 *       ltop        	integer scalar
 *       max         	<function>
 *       min         	<function>
 *       nd          	integer scalar
 *       nl          	integer scalar
 *       np          	integer scalar
 *       ppropint    	real vector/matrix
 *       sdist       	real vector/matrix
 *       shallow     	real vector/matrix
 *       size        	<function>
 *       trapz       	<function>
 *       zinteg      	real vector/matrix
 *******************************************************/
      Matrix lprop;
      Matrix lidep;
      Matrix lipropint;
      Matrix Dep;
      Matrix ppropint;
      Matrix sdist;
      Matrix Botdep;
      int np;
      int nl;
      int nd;
      int il;
      int ltop;
      int lbot;
      int ip;
      double laydepth;
      Matrix deep;
      Matrix shallow;
      Matrix dratio;
      int idep;
      Matrix linteg;
      Matrix zinteg;
      double ldist;
      Matrix gid;
      int iid;
      int id;
      Matrix ldist_1;
      Matrix RM0_;
      double R0_;
      double R1_;
      int I0_;
      
      mccRealInit(lidep);
      mccImport(&lidep, ((nrhs_>0) ? prhs_[0] : 0), 0, 0);
      mccRealInit(lipropint);
      mccImport(&lipropint, ((nrhs_>1) ? prhs_[1] : 0), 0, 0);
      mccRealInit(Dep);
      mccImport(&Dep, ((nrhs_>2) ? prhs_[2] : 0), 0, 0);
      mccRealInit(ppropint);
      mccImport(&ppropint, ((nrhs_>3) ? prhs_[3] : 0), 0, 0);
      mccRealInit(sdist);
      mccImport(&sdist, ((nrhs_>4) ? prhs_[4] : 0), 0, 0);
      mccRealInit(Botdep);
      mccImport(&Botdep, ((nrhs_>5) ? prhs_[5] : 0), 0, 0);
      mccRealInit(lprop);
      mccRealInit(deep);
      mccRealInit(shallow);
      mccRealInit(dratio);
      mccRealInit(linteg);
      mccRealInit(zinteg);
      mccRealInit(gid);
      mccRealInit(ldist_1);
      mccRealInit(RM0_);
      
      /* % KEY:   integrate the property in each layer */
      /* % USAGE : */
      
      
      /* % DESCRIPTION :  */
      /* % integrate the property between layer interfaces, last */
      /* % is the top to bottom one */
      
      /* % Trapezoidal integration, takes the bottom triangle into account */
      
      /* % INPUT: */
      /* % ip = pair indice */
      /* % il = layer indice */
      /* % id = std. depth indice */
      /* % is = station indice */
      
      /* % lidep(ip,il)     (m)  depth at layer interface */
      /* % lipropint(ip,il)      property to integrate at layer interface */
      /* % Dep(id,ip)       (m)  std. depth */
      /* % ppropint(id,ip)       property to integrate, at std. depth */
      /* % sdist(ip)        (km) distance between stations */
      /* % Botdep(is)       (m)  bottom depth */
      
      /* % OUTPUT: */
      
      /* % lprop(ip.il)     (m^2)*property : integrated property in layer  */
      
      
      /* % AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , April 97 */
      
      /* % SIDE EFFECTS : */
      
      /* % SEE ALSO : */
      
      /* % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% */
      /* % CALLER: */
      /* % CALLEE: */
      /* [np,nl]=size(lidep); */
      if( lidep.flags & mccNOTSET )
      {
         mexErrMsgTxt( "variable lidep undefined, line 39" );
      }
      mccGetMatrixSize(&np,&nl, &lidep);
      /* nd=length(Dep); */
      if( Dep.flags & mccNOTSET )
      {
         mexErrMsgTxt( "variable Dep undefined, line 40" );
      }
      nd = mccGetLength(&Dep);
      
      /* % LOOP OVER LAYERS */
      /* for il=1:nl */
      for (il = 1; il <= nl; il = il + 1)
      {
         /* %DEFINE INDICES FOR TOP/BOTTOM INTERFACE */
         /* if il<nl */
         if ((il < nl))
         {
            /* ltop=il; */
            ltop = il;
            /* lbot=il+1; */
            lbot = (il + 1);
            /* else %last is top to bottom */
         }
         else
         {
            /* ltop=1; */
            ltop = 1;
            /* lbot=nl; */
            lbot = nl;
            /* end */
         }
         
         /* %LOOP OVER PAIRS */
         /* for ip=1:np */
         for (ip = 1; ip <= np; ip = ip + 1)
         {
            /* laydepth=lidep(ip,lbot)-lidep(ip,ltop); */
            laydepth = ((mccGetRealMatrixElement(&lidep, ip, lbot)) - (mccGetRealMatrixElement(&lidep, ip, ltop)));
            /* if laydepth<1e-6 */
            if ((laydepth < 1e-6))
            {
               /* lprop(ip,il)=0; */
               mccSetRealMatrixElement(&lprop, ip, il, (double)0);
               lprop.dmode = mxNUMBER;
               /* else */
            }
            else
            {
               /* deep=max([Botdep(ip),Botdep(ip+1)]); */
               mccCatenateColumns(&RM0_, mccTempVectorElement(&Botdep, ip), mccTempVectorElement(&Botdep, (ip + 1)));
               mccMax(&deep, &RM0_);
               /* shallow=min([Botdep(ip),Botdep(ip+1)]); */
               mccCatenateColumns(&RM0_, mccTempVectorElement(&Botdep, ip), mccTempVectorElement(&Botdep, (ip + 1)));
               mccMin(&shallow, &RM0_);
               /* if deep==shallow */
               RM0_.dmode = mxNUMBER;
               {
                  int m_=1, n_=1, cx_ = 0;
                  double t_;
                  double *p_RM0_;
                  int I_RM0_=1;
                  double *p_deep;
                  int I_deep=1;
                  double *p_shallow;
                  int I_shallow=1;
                  m_ = mcmCalcResultSize(m_, &n_, deep.m, deep.n);
                  m_ = mcmCalcResultSize(m_, &n_, shallow.m, shallow.n);
                  mccAllocateMatrix(&RM0_, m_, n_);
                  I_RM0_ = (RM0_.m != 1 || RM0_.n != 1);
                  p_RM0_ = RM0_.pr;
                  I_deep = (deep.m != 1 || deep.n != 1);
                  p_deep = deep.pr;
                  I_shallow = (shallow.m != 1 || shallow.n != 1);
                  p_shallow = shallow.pr;
                  for (j_=0; j_<n_; ++j_)
                  {
                     for (i_=0; i_<m_; ++i_, p_RM0_+=I_RM0_, p_deep+=I_deep, p_shallow+=I_shallow)
                     {
                        *p_RM0_ = (*p_deep == *p_shallow);
                        ;
                     }
                  }
               }
               RM0_.dmode = mxNUMBER;
               if (mccIfCondition(&RM0_))
               {
                  /* dratio=NaN */
                  R0_ = mexGetNaN();
                  {
                     double tr_ = R0_;
                     mccAllocateMatrix(&dratio, 1, 1);
                     *dratio.pr = tr_;
                  }
                  dratio.dmode = mxNUMBER;
                  mccPrint (&dratio, "dratio");
                  /* else */
               }
               else
               {
                  /* dratio=1e3*sdist(ip)/(deep-shallow); */
                  R0_ = (1e3 * (mccGetRealVectorElement(&sdist, ip)));
                  {
                     int m_=1, n_=1, cx_ = 0;
                     double t_;
                     double *p_dratio;
                     int I_dratio=1;
                     double *p_deep;
                     int I_deep=1;
                     double *p_shallow;
                     int I_shallow=1;
                     m_ = mcmCalcResultSize(m_, &n_, deep.m, deep.n);
                     m_ = mcmCalcResultSize(m_, &n_, shallow.m, shallow.n);
                     mccAllocateMatrix(&dratio, m_, n_);
                     I_dratio = (dratio.m != 1 || dratio.n != 1);
                     p_dratio = dratio.pr;
                     I_deep = (deep.m != 1 || deep.n != 1);
                     p_deep = deep.pr;
                     I_shallow = (shallow.m != 1 || shallow.n != 1);
                     p_shallow = shallow.pr;
                     for (j_=0; j_<n_; ++j_)
                     {
                        for (i_=0; i_<m_; ++i_, p_dratio+=I_dratio, p_deep+=I_deep, p_shallow+=I_shallow)
                        {
                           *p_dratio = (R0_ / (double) (*p_deep - *p_shallow));
                           ;
                        }
                     }
                  }
                  dratio.dmode = mxNUMBER;
                  /* end */
               }
               
               /* %IDEP WILL BE THE NUMBER OF DEPTH OVER WHICH THE INTEGRATION */
               /* %IS MADE = 1 (top interface)+ 1(bot.int.) + number of std. */
               /* %depths between top and bot interfaces  */
               /* idep=1; */
               idep = 1;
               /* linteg=[]; */
               mccCreateEmpty(&linteg);
               /* zinteg=[]; */
               mccCreateEmpty(&zinteg);
               
               /* %SET INTEGRAND AT TOP OF LAYER */
               /* if lidep(ip,ltop)>shallow */
               R0_ = (mccGetRealMatrixElement(&lidep, ip, ltop));
               RM0_.dmode = mxNUMBER;
               {
                  int m_=1, n_=1, cx_ = 0;
                  double t_;
                  double *p_RM0_;
                  int I_RM0_=1;
                  double *p_shallow;
                  int I_shallow=1;
                  m_ = mcmCalcResultSize(m_, &n_, shallow.m, shallow.n);
                  mccAllocateMatrix(&RM0_, m_, n_);
                  I_RM0_ = (RM0_.m != 1 || RM0_.n != 1);
                  p_RM0_ = RM0_.pr;
                  I_shallow = (shallow.m != 1 || shallow.n != 1);
                  p_shallow = shallow.pr;
                  for (j_=0; j_<n_; ++j_)
                  {
                     for (i_=0; i_<m_; ++i_, p_RM0_+=I_RM0_, p_shallow+=I_shallow)
                     {
                        *p_RM0_ = (R0_ > *p_shallow);
                        ;
                     }
                  }
               }
               RM0_.dmode = mxNUMBER;
               if (mccIfCondition(&RM0_))
               {
                  /* ldist=dratio*(deep-lidep(ip,ltop)); */
                  R0_ = (mccGetRealMatrixElement(&lidep, ip, ltop));
                  RM0_.dmode = mxNUMBER;
                  {
                     int m_=1, n_=1, cx_ = 0;
                     double t_;
                     double *p_RM0_;
                     int I_RM0_=1;
                     double *p_deep;
                     int I_deep=1;
                     m_ = mcmCalcResultSize(m_, &n_, deep.m, deep.n);
                     mccAllocateMatrix(&RM0_, m_, n_);
                     I_RM0_ = (RM0_.m != 1 || RM0_.n != 1);
                     p_RM0_ = RM0_.pr;
                     I_deep = (deep.m != 1 || deep.n != 1);
                     p_deep = deep.pr;
                     for (j_=0; j_<n_; ++j_)
                     {
                        for (i_=0; i_<m_; ++i_, p_RM0_+=I_RM0_, p_deep+=I_deep)
                        {
                           *p_RM0_ = (*p_deep - R0_);
                           ;
                        }
                     }
                  }
                  RM0_.dmode = mxNUMBER;
                  ldist = mccRealInnerProduct(&dratio, &RM0_);
                  /* else */
               }
               else
               {
                  /* ldist=1e3*sdist(ip); */
                  ldist = (1e3 * (mccGetRealVectorElement(&sdist, ip)));
                  /* end */
               }
               /* %INTEGRAND */
               /* linteg(idep)=ldist*lipropint(ip,ltop);  */
               mccSetRealVectorElement(&linteg, idep, (ldist * (mccGetRealMatrixElement(&lipropint, ip, ltop))));
               linteg.dmode = mxNUMBER;
               /* zinteg(idep)=lidep(ip,ltop); */
               mccSetRealVectorElement(&zinteg, idep, (mccGetRealMatrixElement(&lidep, ip, ltop)));
               zinteg.dmode = mxNUMBER;
               
               /* %SET INTEGRAND IN THE INTERMEDIATE STANDART DEPTHS */
               /* gid=find( (Dep(:,ip)>lidep(ip,ltop)) & ... */
               R0_ = (mccGetRealMatrixElement(&lidep, ip, ltop));
               R1_ = (mccGetRealMatrixElement(&lidep, ip, lbot));
               RM0_.dmode = mxNUMBER;
               {
                  int m_=1, n_=1, cx_ = 0;
                  double t_;
                  double *p_RM0_;
                  int I_RM0_=1;
                  double *p_Dep;
                  int I_Dep=1, J_Dep;
                  double *p_1Dep;
                  int I_1Dep=1, J_1Dep;
                  m_ = mcmCalcResultSize(m_, &n_, Dep.m, 1);
                  m_ = mcmCalcResultSize(m_, &n_, Dep.m, 1);
                  mccAllocateMatrix(&RM0_, m_, n_);
                  mccCheckMatrixSize(&Dep, m_, ip);
                  mccCheckMatrixSize(&Dep, m_, ip);
                  I_RM0_ = (RM0_.m != 1 || RM0_.n != 1);
                  p_RM0_ = RM0_.pr;
                  if (Dep.m == 1 && Dep.n == 1) { I_Dep = J_Dep = 0; }
                  else { I_Dep=1; J_Dep=Dep.m-m_; }
                  p_Dep = Dep.pr + 0 + Dep.m * (ip-1);
                  if (Dep.m == 1 && Dep.n == 1) { I_1Dep = J_1Dep = 0; }
                  else { I_1Dep=1; J_1Dep=Dep.m-m_; }
                  p_1Dep = Dep.pr + 0 + Dep.m * (ip-1);
                  for (j_=0; j_<n_; ++j_, p_Dep += J_Dep, p_1Dep += J_1Dep)
                  {
                     for (i_=0; i_<m_; ++i_, p_RM0_+=I_RM0_, p_Dep+=I_Dep, p_1Dep+=I_1Dep)
                     {
                        *p_RM0_ = (!!(*p_Dep > R0_) && !!(*p_1Dep < R1_));
                        ;
                     }
                  }
               }
               RM0_.dmode = mxNUMBER;
               mccFind(&gid, &RM0_);
               /* for iid=1:length(gid) */
               I0_ = mccGetLength(&gid);
               for (iid = 1; iid <= I0_; iid = iid + 1)
               {
                  /* id=gid(iid); */
                  id = ((int)mccGetRealVectorElement(&gid, iid));
                  /* idep=idep+1; */
                  idep = (idep + 1);
                  /* if Dep(id,ip)>shallow */
                  R1_ = (mccGetRealMatrixElement(&Dep, id, ip));
                  RM0_.dmode = mxNUMBER;
                  {
                     int m_=1, n_=1, cx_ = 0;
                     double t_;
                     double *p_RM0_;
                     int I_RM0_=1;
                     double *p_shallow;
                     int I_shallow=1;
                     m_ = mcmCalcResultSize(m_, &n_, shallow.m, shallow.n);
                     mccAllocateMatrix(&RM0_, m_, n_);
                     I_RM0_ = (RM0_.m != 1 || RM0_.n != 1);
                     p_RM0_ = RM0_.pr;
                     I_shallow = (shallow.m != 1 || shallow.n != 1);
                     p_shallow = shallow.pr;
                     for (j_=0; j_<n_; ++j_)
                     {
                        for (i_=0; i_<m_; ++i_, p_RM0_+=I_RM0_, p_shallow+=I_shallow)
                        {
                           *p_RM0_ = (R1_ > *p_shallow);
                           ;
                        }
                     }
                  }
                  RM0_.dmode = mxNUMBER;
                  if (mccIfCondition(&RM0_))
                  {
                     /* ldist=dratio*(deep-Dep(id,ip)); */
                     R1_ = (mccGetRealMatrixElement(&Dep, id, ip));
                     RM0_.dmode = mxNUMBER;
                     {
                        int m_=1, n_=1, cx_ = 0;
                        double t_;
                        double *p_RM0_;
                        int I_RM0_=1;
                        double *p_deep;
                        int I_deep=1;
                        m_ = mcmCalcResultSize(m_, &n_, deep.m, deep.n);
                        mccAllocateMatrix(&RM0_, m_, n_);
                        I_RM0_ = (RM0_.m != 1 || RM0_.n != 1);
                        p_RM0_ = RM0_.pr;
                        I_deep = (deep.m != 1 || deep.n != 1);
                        p_deep = deep.pr;
                        for (j_=0; j_<n_; ++j_)
                        {
                           for (i_=0; i_<m_; ++i_, p_RM0_+=I_RM0_, p_deep+=I_deep)
                           {
                              *p_RM0_ = (*p_deep - R1_);
                              ;
                           }
                        }
                     }
                     RM0_.dmode = mxNUMBER;
                     mccRealMatrixMultiply(&ldist_1, &dratio, &RM0_);
                     /* else */
                  }
                  else
                  {
                     /* ldist=1e3*sdist(ip); */
                     {
                        double tr_ = (1e3 * (mccGetRealVectorElement(&sdist, ip)));
                        mccAllocateMatrix(&ldist_1, 1, 1);
                        *ldist_1.pr = tr_;
                     }
                     ldist_1.dmode = mxNUMBER;
                     /* end */
                  }
                  /* linteg(idep)=ldist*ppropint(id,ip); */
                  R1_ = (mccGetRealMatrixElement(&ppropint, id, ip));
                  RM0_.dmode = mxNUMBER;
                  {
                     int m_=1, n_=1, cx_ = 0;
                     double t_;
                     double *p_RM0_;
                     int I_RM0_=1;
                     double *p_ldist_1;
                     int I_ldist_1=1;
                     m_ = mcmCalcResultSize(m_, &n_, ldist_1.m, ldist_1.n);
                     mccAllocateMatrix(&RM0_, m_, n_);
                     I_RM0_ = (RM0_.m != 1 || RM0_.n != 1);
                     p_RM0_ = RM0_.pr;
                     I_ldist_1 = (ldist_1.m != 1 || ldist_1.n != 1);
                     p_ldist_1 = ldist_1.pr;
                     for (j_=0; j_<n_; ++j_)
                     {
                        for (i_=0; i_<m_; ++i_, p_RM0_+=I_RM0_, p_ldist_1+=I_ldist_1)
                        {
                           *p_RM0_ = (*p_ldist_1 * R1_);
                           ;
                        }
                     }
                  }
                  RM0_.dmode = mxNUMBER;
                  mccSetRealVectorElement(&linteg, idep, (mccGetRealVectorElement(&RM0_, 1)));
                  linteg.dmode = mxNUMBER;
                  /* zinteg(idep)=Dep(id,ip); */
                  mccSetRealVectorElement(&zinteg, idep, (mccGetRealMatrixElement(&Dep, id, ip)));
                  zinteg.dmode = mxNUMBER;
                  /* end %on id */
               }
               
               /* %SET INTEGRAND AT BOTTOM OF LAYER */
               /* idep=idep+1; */
               idep = (idep + 1);
               /* if lidep(ip,lbot)>shallow */
               R1_ = (mccGetRealMatrixElement(&lidep, ip, lbot));
               RM0_.dmode = mxNUMBER;
               {
                  int m_=1, n_=1, cx_ = 0;
                  double t_;
                  double *p_RM0_;
                  int I_RM0_=1;
                  double *p_shallow;
                  int I_shallow=1;
                  m_ = mcmCalcResultSize(m_, &n_, shallow.m, shallow.n);
                  mccAllocateMatrix(&RM0_, m_, n_);
                  I_RM0_ = (RM0_.m != 1 || RM0_.n != 1);
                  p_RM0_ = RM0_.pr;
                  I_shallow = (shallow.m != 1 || shallow.n != 1);
                  p_shallow = shallow.pr;
                  for (j_=0; j_<n_; ++j_)
                  {
                     for (i_=0; i_<m_; ++i_, p_RM0_+=I_RM0_, p_shallow+=I_shallow)
                     {
                        *p_RM0_ = (R1_ > *p_shallow);
                        ;
                     }
                  }
               }
               RM0_.dmode = mxNUMBER;
               if (mccIfCondition(&RM0_))
               {
                  /* ldist=dratio*(deep-lidep(ip,lbot)); */
                  R1_ = (mccGetRealMatrixElement(&lidep, ip, lbot));
                  RM0_.dmode = mxNUMBER;
                  {
                     int m_=1, n_=1, cx_ = 0;
                     double t_;
                     double *p_RM0_;
                     int I_RM0_=1;
                     double *p_deep;
                     int I_deep=1;
                     m_ = mcmCalcResultSize(m_, &n_, deep.m, deep.n);
                     mccAllocateMatrix(&RM0_, m_, n_);
                     I_RM0_ = (RM0_.m != 1 || RM0_.n != 1);
                     p_RM0_ = RM0_.pr;
                     I_deep = (deep.m != 1 || deep.n != 1);
                     p_deep = deep.pr;
                     for (j_=0; j_<n_; ++j_)
                     {
                        for (i_=0; i_<m_; ++i_, p_RM0_+=I_RM0_, p_deep+=I_deep)
                        {
                           *p_RM0_ = (*p_deep - R1_);
                           ;
                        }
                     }
                  }
                  RM0_.dmode = mxNUMBER;
                  mccRealMatrixMultiply(&ldist_1, &dratio, &RM0_);
                  /* else */
               }
               else
               {
                  /* ldist=1e3*sdist(ip); */
                  {
                     double tr_ = (1e3 * (mccGetRealVectorElement(&sdist, ip)));
                     mccAllocateMatrix(&ldist_1, 1, 1);
                     *ldist_1.pr = tr_;
                  }
                  ldist_1.dmode = mxNUMBER;
                  /* end */
               }
               /* linteg(idep)=ldist*lipropint(ip,lbot); */
               R1_ = (mccGetRealMatrixElement(&lipropint, ip, lbot));
               RM0_.dmode = mxNUMBER;
               {
                  int m_=1, n_=1, cx_ = 0;
                  double t_;
                  double *p_RM0_;
                  int I_RM0_=1;
                  double *p_ldist_1;
                  int I_ldist_1=1;
                  m_ = mcmCalcResultSize(m_, &n_, ldist_1.m, ldist_1.n);
                  mccAllocateMatrix(&RM0_, m_, n_);
                  I_RM0_ = (RM0_.m != 1 || RM0_.n != 1);
                  p_RM0_ = RM0_.pr;
                  I_ldist_1 = (ldist_1.m != 1 || ldist_1.n != 1);
                  p_ldist_1 = ldist_1.pr;
                  for (j_=0; j_<n_; ++j_)
                  {
                     for (i_=0; i_<m_; ++i_, p_RM0_+=I_RM0_, p_ldist_1+=I_ldist_1)
                     {
                        *p_RM0_ = (*p_ldist_1 * R1_);
                        ;
                     }
                  }
               }
               RM0_.dmode = mxNUMBER;
               mccSetRealVectorElement(&linteg, idep, (mccGetRealVectorElement(&RM0_, 1)));
               linteg.dmode = mxNUMBER;
               /* zinteg(idep)=lidep(ip,lbot); */
               mccSetRealVectorElement(&zinteg, idep, (mccGetRealMatrixElement(&lidep, ip, lbot)));
               zinteg.dmode = mxNUMBER;
               
               /* %DO THE INTEGRATION FOR THIS LAYER, THIS PAIR */
               /* lprop(ip,il)=trapz(zinteg,linteg); */
               Mprhs_[0] = &zinteg;
               Mprhs_[1] = &linteg;
               Mplhs_[0] = &RM0_;
               mccCallMATLAB(1, Mplhs_, 2, Mprhs_, "trapz", 110);
               mccSetRealMatrixElement(&lprop, ip, il, (mccGetRealVectorElement(&RM0_, 1)));
               lprop.dmode = mxNUMBER;
               
               /* end %if laydepth<1e-6 */
            }
            /* end %loop on ip */
         }
         
         /* end %loop on nl */
      }
      mccReturnFirstValue(&plhs_[0], &lprop);
   }
   return;
}

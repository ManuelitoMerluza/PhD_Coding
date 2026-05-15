# -*- coding: utf-8 -*-
"""
Created on Mon Apr  2 18:08:12 2018

@author: bieito
"""
import os
import matplotlib as mpl
if os.environ.get('DISPLAY','') == '':
    print('no display found. Using non-interactive Agg backend')
    mpl.use('Agg')
import xlrd
#import xlwt
import xlsxwriter
import matplotlib.pyplot as plt
import matplotlib.cm as cm
from matplotlib.path import Path
import numpy as np
import seawater as gsw
import scipy.optimize as opt
import pickle
import scipy.io as sio

def main():

    DATA = pickle.load(open("../le_CTD/FluxesI_CTD_deep.pickle","r"))
    print DATA.keys()

    st = DATA["Station"]
    pres =  DATA["pres"]
    S = DATA["S"]
    PT = DATA["PT"]
    dens = DATA["sigmath"]
    O2 = DATA["O2_calP"]
    #pasa de umol/l a umol/kg
    
    C = pickle.load(open("fit_NO_Si.pickle","r"))

    CNO = C["NO"]
    varsNO = C["var_NO"]
    NO = CNO[0]*np.ones(PT.shape)
    for i in range(len(varsNO)):
        exec("NO += CNO[i+1]*"+varsNO[i])

    CSi = C["Si"]
    varsSi = C["var_Si"]
    SiO2 = CSi[0]*np.ones(PT.shape)
    for i in range(len(varsSi)):
        exec("SiO2 += CSi[i+1]*"+varsSi[i])
    

    #does omp
    X, WT = does_OMP(st,pres,PT,S,dens,O2,NO,SiO2,'WTYPES_MMW.xls')
    
    ##############
    #write output
    ###############
    
    #pickle
    out = {}
    out["Station"] = DATA["Station"]
    out["Cast"] = DATA["Cast"]
    out["Lat"] = DATA["Lat"]
    out["Lon"] = DATA["Lon"]
    out["WT"] = WT["WT"]
    out["X"] = X
    out["pres"] = pres
    out["depth"] = DATA["depth"]
    out["PT"] = PT
    out["T"] = DATA["T"]
    out["S"] = S
    out["sigmat"] = dens
    out["NO"] = NO
    out["SiO2"] = SiO2
    out["O2"] = O2
    out["PAR"] = DATA["PAR"]
    out["CDOM"] = DATA["CDOM"]
    out["BA"] = DATA["BA"]
    out["BT"] = DATA["BT"]
    out["Chl"] = DATA["Chl"]
    out["Flu"] = DATA["Flu"]
    out["Turb"] = DATA["Turb"]
    with open("FLUXESI_OMP_MMW_CTD_1dbar.p", "wb" ) as f:
        pickle.dump( out , f ) 
    sio.savemat("FLUXESI_OMP_MMW_CTD_1dbar",out)

    outVAR = ["Station","Cast","Lon","Lat","pres",\
    "depth","PT","S","sigmat","O2","NO","SiO2",\
    "PAR","CDOM","BA","BT","Chl","Flu","Turb"]
    nV = len(outVAR)

    """
    #excell
    book = xlwt.Workbook(encoding="utf-8")
    sh1 = book.add_sheet("OMP")
    
    NWM = len(WT["WT"])   
    nD = len(out["Station"])
    
    for cc in range(nV):
        var0 = outVAR[cc]
        sh1.write(0,cc,var0)
        for ff in range(nD):
            sh1.write(ff+1,cc,out[var0][ff])
    

    for i in range(NWM):
        sh1.write(0,i+nV+1,WT["WT"][i])
        for j in range(len(PT)):
            if np.isnan(X[j,i]) == False:
                sh1.write(j+1,i+nV+1,X[j,i])
    
            
            
    book.save("OMP_FluxesI_CTD_1dbar.xls")
    """
    
    wb = xlsxwriter.Workbook('OMP_FluxesI_CTD_1dbar.xlsx')
    sh1 = wb.add_worksheet()
    NWM = len(WT["WT"])
    nD = len(out["Station"])
    
    for cc in range(nV):
        var0 = outVAR[cc]
        sh1.write(0,cc,var0)
        for ff in range(nD):
            sh1.write(ff+1,cc,out[var0][ff])
    

    for i in range(NWM):
        sh1.write(0,i+nV+1,WT["WT"][i])
        for j in range(len(PT)):
            if np.isnan(X[j,i]) == False:
                sh1.write(j+1,i+nV+1,X[j,i])
    
    wb.close()


def does_OMP(st,pres,PT,S,dens,O2,NO,SiO2,WTfile):
    
    stU = np.unique(st)

    wbWT =  xlrd.open_workbook(WTfile)
    shWT = wbWT.sheet_by_index(0)
    WT = shWT.col_values(0)[1:]
    WT_S = np.array(shWT.col_values(1)[1:])
    WT_PT = np.array(shWT.col_values(2)[1:])
    WT_NO = np.array(shWT.col_values(3)[1:])
    WT_Si = np.array(shWT.col_values(4)[1:])
    WT_dens = gsw.dens(WT_S,WT_PT,0)-1000
    
    NP = len(PT)
    NWM = len(WT)

    iv2 = np.arange(NP)
    stU = np.unique(st) #estacions unicas
    
    TScoords =  []
    for i in range(len(PT)):
        TScoords.append( (S[i],PT[i]) )

    """
    denC = np.zeros(PT.shape)
    for stUU in stU:
        ist = np.where(st==stUU)[0]
        den00 = dens[ist]
        pres00 = pres[ist]
        denC0 = np.min(den00)+0.25
        for i in range(len(ist)):
            denC[ist[i]] = denC0
    print denC
    """    

  
    ###############
    #MIXING FIGURES
    ################
        
    corrT = np.array([0.3,-0.25,0,0.0,0,0,0,0,0,0,0])
    corrS = np.array([0.036,0.03,0,0.04,0,0,0,0,0,0,0])

    #upper Central Waters
    jUCW = [1,0,2]
    vUCW = [(WT_S[i],WT_PT[i]) for i in jUCW]
    vUCWc = [(WT_S[i]+corrS[i],WT_PT[i]+corrT[i]) for i in jUCW]
    pUCWc = Path(vUCWc)
    iUCW = np.where((pUCWc.contains_points(TScoords)) & (pres>=100.))[0]
    
    #Central Waters
    jCW = [1,2,4,3]
    vCW = [(WT_S[i],WT_PT[i]) for i in jCW]
    vCWc = [(WT_S[i]+corrS[i],WT_PT[i]+corrT[i]) for i in jCW]
    pCWc = Path(vCWc)
    iCW=np.where((pCWc.contains_points(TScoords)) & (pres>=100.) )[0]
    
    #intermediate + central waters (NACW12,SACW12,NACW8,AAIW)
    jICW = [3,4,6,5]
    vICW = [(WT_S[i],WT_PT[i]) for i in jICW]
    vICWc = [(WT_S[i]+corrS[i],WT_PT[i]+corrT[i]) for i in jICW]
    pICWc = Path(vICWc)
    iICW = np.where(pICWc.contains_points(TScoords))[0]
    
    
    #intermediate and deep waters (NACW8,AAIW,MW,LSW) (Non fan falta correccions)
    jIDW = [5,6,8,7]
    vIDW = [(WT_S[i],WT_PT[i]) for i in jIDW]
    pIDW = Path(vIDW)
    iIDW =  np.where(pIDW.contains_points(TScoords))[0]
    
    #deep waters (UNADW,LSW,MDW)
    jDW = [7,8,9]
    vDW = [(WT_S[i],WT_PT[i]) for i in jDW]
    pDW = Path(vDW)
    iDW =  np.where(pDW.contains_points(TScoords))[0]
    
    #bottom waters
    jBW = [9,10]
    iA= pDW.contains_points(TScoords)
    iB = PT<3
    iBW = np.where(~iA & iB)[0]
    

    
        
    #densidade TS
    ng = 25
    ti = np.linspace(0,25,ng)
    si = np.linspace(34.5,37.5,ng)
    deni = np.zeros((ng,ng))
    for i in range(ng):
        for j in range(ng):
            deni[i,j] = gsw.dens(si[j],ti[i],0)
    deni = deni - 1000.
    lvs = np.arange(deni.min(),deni.max(),0.5)

    """
    #by station
    
    
    for stUU in stU:
        print "Station %s"%stUU
    
        ist = np.where(st==stUU)[0]
        dd = dens[ist]
        isd = np.argsort(dd)

        istUCW = iUCW[np.where(st[iUCW] == stUU)[0]]
        istCW = iCW[np.where(st[iCW] == stUU)[0]]
        istICW = iICW[np.where(st[iICW] == stUU)[0]]
        istIDW = iIDW[np.where(st[iIDW] == stUU)[0]]
        istDW = iDW[np.where(st[iDW] == stUU)[0]]
        istBW = iDW[np.where(st[iDW] == stUU)[0]]
        
        f3,ax = plt.subplots(1,2,figsize = (12,7))
        CS=ax[0].contour(si,ti,deni,levels=lvs,colors='gray')
        polyUCW = plt.Polygon(vUCW,alpha=0.2,fc='blue',lw=0.5)
        ax[0].add_patch(polyUCW)
    
        polyCW = plt.Polygon(vCW,alpha=0.2,fc='dodgerblue',lw=0.5)
        ax[0].add_patch(polyCW)

        polyICW = plt.Polygon(vICW,alpha=0.2,fc='green',lw=0.5)
        ax[0].add_patch(polyICW)

        polyIDW = plt.Polygon(vIDW,alpha=0.2,fc='orange',lw=0.5)
        ax[0].add_patch(polyIDW)

        polyDW = plt.Polygon(vDW,alpha=0.2,fc='red',lw=0.5)
        ax[0].add_patch(polyDW)
    
        ax[0].clabel(CS, fontsize=10, inline=1, fmt='%1.1f')

        ax[0].scatter(S[ist],PT[ist],8,'gray',lw=0)
        ax[0].scatter(S[istUCW],PT[istUCW],8,'blue',lw=0)
        ax[0].scatter(S[istCW],PT[istCW],8,'skyblue',lw=0)
        ax[0].scatter(S[istICW],PT[istICW],8,'green',lw=0)
        ax[0].scatter(S[istIDW],PT[istIDW],8,'orange',lw=0)
        ax[0].scatter(S[istDW],PT[istDW],8,'red',lw=0)
        ax[0].scatter(S[istBW],PT[istBW],8,'k',lw=0)
        ax[0].scatter(WT_S,WT_PT,60,WT_dens)
        ax[0].set_xlim((34.5,37.5))
        ax[0].set_ylim((0,25))
        for i in range(len(WT)):
            ax[0].annotate(WT[i],xy=(WT_S[i]+0.05,WT_PT[i]),va='center',fontsize=10)#,bbox = dict(fc='w',ec='w'))
            ax[0].set_xlabel('S',fontsize = 16)
            ax[0].set_ylabel('$\\theta$ ($^{\circ}$C)',fontsize=16)

        ax[1].scatter(dd[isd],-pres[ist[isd]],10,dd[isd],vmin = 26, vmax = 28)
        ax[1].set_xlabel("$\\sigma_{\\theta}$")
        ax[1].set_ylabel("Pres (db)")
        ax[1].yaxis.tick_right()
        ax[1].yaxis.set_label_position('right')
        ax[0].set_title("Station "+"{:d}".format(stUU))
        f3.savefig("{:02d}".format(stUU)+"_TS.pdf")
        plt.close(f3)
    """

    
    #########
    ##OMPS##
    #######
    X = np.zeros((NP,NWM))
    #X[:] = np.nan
    #Preal = np.zeros((NP,1))
    #print Preal.shape
    print "Is doing OMP"
    
    #UCW
    print PT[iUCW].shape
    x=solve_OMP(PT,S,NO,SiO2,WT_PT,WT_S,WT_NO,WT_Si,iUCW,jUCW)
    print x.shape
    X = realocates_values(x,X,iUCW,jUCW)
    #Preal = realocates_values(pres[iUCW].reshape((len(iUCW),1)),Preal,iUCW,[0])
    del x
    
    #CW
    x=solve_OMP(PT,S,NO,SiO2,WT_PT,WT_S,WT_NO,WT_Si,iCW,jCW)
    X = realocates_values(x,X,iCW,jCW)
    del x
    
    #ICW
    x=solve_OMP(PT,S,NO,SiO2,WT_PT,WT_S,WT_NO,WT_Si,iICW,jICW)
    X = realocates_values(x,X,iICW,jICW)
    del x
    
    #IDW
    x=solve_OMP(PT,S,NO,SiO2,WT_PT,WT_S,WT_NO,WT_Si,iIDW,jIDW)
    X = realocates_values(x,X,iIDW,jIDW)
    del x
    
    #DW
    x=solve_OMP(PT,S,NO,SiO2,WT_PT,WT_S,WT_NO,WT_Si,iDW,jDW)
    X = realocates_values(x,X,iDW,jDW)
    del x
    #BW
    x=solve_OMP(PT,S,NO,SiO2,WT_PT,WT_S,WT_NO,WT_Si,iBW,jBW)
    X = realocates_values(x,X,iBW,jBW)
    del x
    
    #pon nans nos datos non resoltos
    ii = np.where(np.sum(X,axis=1)==0)[0]    
    X[ii,:] = np.nan
    #Preal[Preal==0] = np.nan
    
    print "OMP done!"
    
    WT = shWT.col_values(0)[1:]
    WT_S = np.array(shWT.col_values(1)[1:])
    WT_PT = np.array(shWT.col_values(2)[1:])
    WT_NO = np.array(shWT.col_values(3)[1:])
    WT_Si = np.array(shWT.col_values(4)[1:])
    WT_dens = gsw.dens(WT_S,WT_PT,0)-1000
    
    WTo = {}
    WTo["WT"] = WT
    WTo["S"] = WT_S
    WTo["PT"] = WT_PT
    WTo["NO"] = WT_NO
    WTo["Si"] = WT_Si
    WTo["dens"] = WT_dens
    
    
    
    ###
    #Figures
    ###
    

    
    f1, (ax1, ax2, ax3) = plt.subplots(1, 3,figsize = (8*3,6),sharey = True)

    #polygons
    polyUCW = plt.Polygon(vUCW,alpha=0.2,fc='blue',lw=0.5)
    ax1.add_patch(polyUCW)
    
    polyCW = plt.Polygon(vCW,alpha=0.2,fc='dodgerblue',lw=0.5)
    ax1.add_patch(polyCW)

    polyICW = plt.Polygon(vICW,alpha=0.2,fc='green',lw=0.5)
    ax1.add_patch(polyICW)

    polyIDW = plt.Polygon(vIDW,alpha=0.2,fc='orange',lw=0.5)
    ax1.add_patch(polyIDW)

    polyDW = plt.Polygon(vDW,alpha=0.2,fc='red',lw=0.5)
    ax1.add_patch(polyDW)    
    
    
    CS=ax1.contour(si,ti,deni,levels=lvs,colors='gray')
    ax1.clabel(CS, fontsize=10, inline=1, fmt='%1.1f')
    ax1.scatter(S,PT,8,'gray',lw=0)
    ax1.scatter(WT_S,WT_PT,60,WT_dens, edgecolor = 'k', lw = 1,  cmap = cm.jet, zorder = 3)
    
    ax1.scatter(S,PT,8,'gray',lw=0)
    ax1.scatter(S[iUCW],PT[iUCW],8,'blue',lw=0)
    ax1.scatter(S[iCW],PT[iCW],8,'dodgerblue',lw=0)
    ax1.scatter(S[iICW],PT[iICW],8,'green',lw=0)
    ax1.scatter(S[iIDW],PT[iIDW],8,'orange',lw=0)
    ax1.scatter(S[iDW],PT[iDW],8,'red',lw=0)
    ax1.scatter(S[iBW],PT[iBW],8,'k',lw=0)    
    
    ax1.set_xlim((34.5,37.5))
    ax1.set_ylim((0,25))
    for i in range(len(WT)):
        ax1.annotate(WT[i],xy=(WT_S[i]+0.05,WT_PT[i]),va='center',fontsize=10)#,bbox = dict(fc='w',ec='w'))
    ax1.set_xlabel('S',fontsize = 16)
    ax1.set_ylabel('$\\theta$ ($^{\circ}$C)',fontsize=16)

    #axis 2    
    ax2.scatter(NO,PT,8,'gray',lw=0)
    ax2.scatter(NO[iUCW],PT[iUCW],8,'blue',lw=0)
    ax2.scatter(NO[iCW],PT[iCW],8,'dodgerblue',lw=0)
    ax2.scatter(NO[iICW],PT[iICW],8,'green',lw=0)
    ax2.scatter(NO[iIDW],PT[iIDW],8,'orange',lw=0)
    ax2.scatter(NO[iDW],PT[iDW],8,'red',lw=0)
    ax2.scatter(NO[iBW],PT[iBW],8,'k',lw=0)    
    
    ax2.scatter(WT_NO,WT_PT,60,WT_dens,edgecolor = 'k', lw = 1,  cmap = cm.jet, zorder = 3)
    for i in range(len(WT)):
        ax2.annotate(WT[i],xy=(WT_NO[i]+4,WT_PT[i]),va='center',fontsize=10)#,bbox = dict(fc='w',ec='w'))
    ax2.set_xlabel('NO ($\mu$ mol kg$^{-1}$)',fontsize=16)
    
    #axis 3
    ax3.scatter(SiO2,PT,8,'gray',lw=0)
    ax3.scatter(SiO2[iUCW],PT[iUCW],8,'blue',lw=0)
    ax3.scatter(SiO2[iCW],PT[iCW],8,'dodgerblue',lw=0)
    ax3.scatter(SiO2[iICW],PT[iICW],8,'green',lw=0)
    ax3.scatter(SiO2[iIDW],PT[iIDW],8,'orange',lw=0)
    ax3.scatter(SiO2[iDW],PT[iDW],8,'red',lw=0)
    ax3.scatter(SiO2[iBW],PT[iBW],8,'k',lw=0)    
    
    ax3.scatter(WT_Si,WT_PT,60,WT_dens, edgecolor = 'k', lw = 1, cmap = cm.jet, zorder = 3)
    for i in range(len(WT)):
        ax3.annotate(WT[i],xy=(WT_Si[i]+1,WT_PT[i]),va='center',fontsize=10)#,bbox = dict(fc='w',ec='w'))
    ax3.set_xlabel('SiO$_2$H$_4$ ($\mu$ mol kg$^{-1}$)',fontsize=16)
    
    #1.savefig('TS_FLUXESI.pdf',bbox_inches = 'tight')
    f1.savefig('TS_FLUXESI_CTD.png',bbox_inches = 'tight')
    plt.close(f1)
        
        
    f2, ax1 = plt.subplots(1, 1,figsize = (6,6))
    #polygons
    polyUCW = plt.Polygon(vUCW,alpha=0.2,fc='blue',lw=0.5)
    ax1.add_patch(polyUCW)
    
    polyCW = plt.Polygon(vCW,alpha=0.2,fc='dodgerblue',lw=0.5)
    ax1.add_patch(polyCW)

    polyICW = plt.Polygon(vICW,alpha=0.2,fc='green',lw=0.5)
    ax1.add_patch(polyICW)

    polyIDW = plt.Polygon(vIDW,alpha=0.2,fc='orange',lw=0.5)
    ax1.add_patch(polyIDW)

    polyDW = plt.Polygon(vDW,alpha=0.2,fc='red',lw=0.5)
    ax1.add_patch(polyDW)    
    
    lvs = np.arange(deni.min(),deni.max(),0.5)
    CS=ax1.contour(si,ti,deni,levels=lvs,colors='gray')
    ax1.clabel(CS, fontsize=10, inline=1, fmt='%1.1f')
    ax1.scatter(S,PT,8,'gray',lw=0)
    ax1.scatter(WT_S,WT_PT,60,WT_dens, edgecolor = 'k', lw = 1, zorder =3, cmap = cm.jet)
    ax1.scatter(S,PT,8,'gray',lw=0)
    ax1.scatter(S[iUCW],PT[iUCW],8,'blue',lw=0)
    ax1.scatter(S[iCW],PT[iCW],8,'dodgerblue',lw=0)
    ax1.scatter(S[iICW],PT[iICW],8,'green',lw=0)
    ax1.scatter(S[iIDW],PT[iIDW],8,'orange',lw=0)
    ax1.scatter(S[iDW],PT[iDW],8,'red',lw=0)
    ax1.scatter(S[iBW],PT[iBW],8,'k',lw=0)    
    
    ax1.set_xlim((34.5,37.5))
    ax1.set_ylim((0,25))
    for i in range(len(WT)):
        ax1.annotate(WT[i],xy=(WT_S[i]+0.05,WT_PT[i]),va='center',fontsize=10)#,bbox = dict(fc='w',ec='w'))
    ax1.set_xlabel('S',fontsize = 16)
    ax1.set_ylabel('$\\theta$ ($^{\circ}$C)',fontsize=16)#polygons
    
    #2.savefig('TS_polygons_FLUXESI.pdf',bbox_inches = 'tight')
    f2.savefig('TS_polygons_FLUXESI_CTD.png',bbox_inches = 'tight')
    plt.close(f2)
    #plt.set_xticks(fontsize=14)
    #plt.set_yticks(fontsize=14)

    
    return X, WTo#, Preal
    
def solve_OMP(T,S,NO,Si,T0,S0,NO0,Si0,indS,indWM, ww = [100,10,10,2,1]):
    #ww = np.array(ww)**2
    N = len(indS)
    NWM = len(indWM)
    
    T = T[indS]
    S = S[indS]
    NO = NO[indS]
    Si = Si[indS]

    mT = np.mean(T)
    rT = Crange(T)
    mS = np.mean(S)
    rS = Crange(S)
    mNO = np.mean(NO)
    rNO = Crange(NO)    
    mSi = np.mean(Si)
    rSi = Crange(Si)  
    
    M = ww[0]*np.ones(T.shape)
    T = ww[1]*(T - mT)/rT   
    S = ww[2]*(S - mS)/rS
    NO = ww[3]*(NO - mNO)/rNO
    Si = ww[4]*(Si - mSi)/rSi

    
    T0 = T0[indWM]
    S0 = S0[indWM]
    NO0 = NO0[indWM]
    Si0 = Si0[indWM]

    M0 = ww[0]*np.ones(T0.shape)
    T0 = ww[1]*(T0 - mT)/rT   
    S0 = ww[2]*(S0 - mS)/rS
    NO0 = ww[3]*(NO0 - mNO)/rNO
    Si0 = ww[4]*(Si0 - mSi)/rSi

    B = np.vstack( (M0,T0,S0,NO0,Si0) )

    X = np.zeros((N,NWM))
    for i in range(N):
        y =  [M[i],T[i],S[i],NO[i],Si[i]]
        #X=np.linalg.lstsq(B,y) #
        x=opt.nnls(B,y)
        X[i,:] = x[0]

   
    return X

def Crange(x):
    R = np.max(x)-np.min(x)
    return R
    
def realocates_values(y,Y,I,J):
    i=0
    for ii in I:
        j=0
        for jj in J:        
            Y[ii,jj] = y[i,j]
            j+=1
        i+=1
    return Y
        
###################

main()

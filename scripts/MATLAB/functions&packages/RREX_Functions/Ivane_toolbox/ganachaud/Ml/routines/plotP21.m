%To plot all properties
%datadir='/home/cornoc/ganacho/I2/Geovel/';
%secid='A2hpolyfit';
%secid='I2polyfit';
%secid='I3polyfit';
p_xax='lon';
  secid='P21E';
  datadir=['/export/data1/ganacho/' 'P21' '/Stddata/'];
  getsdat
      thetactd=sw_ptmp(sali,temp,Presctd,0);
gi2p=1:Nstat;

    pres=Presctd;
  
iprop=2;  
  gi2ps=gi2p;
  figure(iprop);clf
  prop=rhydro([datadir Statfiles{iprop}],Precision{iprop},MPres(iprop), ...
    Nstat,Maxd(:,iprop));
  eval([Propnm{iprop} '=prop;']);
  maxy=500*ceil(mmax(Botp)/500);
  if (iprop==Ioxyg)&any(any(prop>100)) 
    pottemp=sw_ptmp(sali,temp,pres,0);
    rho=sw_dens(sali,pottemp,0);
    prop=prop.*rho/1000/44.6369;
    punits='ml/l';
  else
    punits=Propunits{iprop};
  end
  if Isctd(iprop)
    pres=Presctd;
  else
    pres=Pres;
  end
  if iprop==Itemp
    sali=rhydro([datadir Statfiles{Isali}],Precision{Isali},...
      MPres(Isali), ...
      Nstat,Maxd(:,Isali));
    prop=sw_ptmp(sali,temp,pres,0);
    pname='theta';
    sigtheta=sw_pden(sali,temp,Presctd,0)-1000;
   else
    pname=Propnm{iprop};
  end
  plt_prop(prop(:,gi2p),pname , punits, ...
    Cruise, pres, Maxd(gi2ps,iprop), Botp(gi2ps), Slat(gi2ps), ...
    Slon(gi2ps),maxy,1,gi2p,p_xax)
  land;setlargefig

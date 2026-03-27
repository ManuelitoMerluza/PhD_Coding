%To plot all properties
%datadir='/home/cornoc/ganacho/I2/Geovel/';
%secid='A2hpolyfit';
%secid='I2polyfit';
%secid='I3polyfit';
p_xax='lon';
if ~exist('Nstat')
  secs={'a36n';'a24n';'A5';'A6';'A7';'A8';'A9';'A10';'A11';...
  'P6';'P21W';'P21';'P4';'P3';'P1';'I2';'I3';'I5'};
else
  secs=NaN;
end
%for isec=1:length(secs)
isec=length(secs)
if ~exist('Nstat')
  secid=secs{isec};
  datadir=['/home/cornoc/ganacho/' secid '/Stddata/'];
  getsdat
      thetactd=sw_ptmp(sali,temp,Presctd,0);
else
  datadir=OPdir;
end

%p_xax='lon';
%To plot subsection
gi2p=1:Nstat;
 %gi2p=1:fix(Npair/2);
 %gi2p=fix(Npair/2):Npair;

  if Isctd(1)
    pres=Presctd;
  else
    pres=Pres;
  end
  
for iprop=1:2%:Npropplotallprops
  
  gi2ps=gi2p;
  figure(iprop)
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
  if 0
    plt_prop(sigtheta,'pden' , 'kg m^{-3}', ...
      Cruise, pres, Maxd(gi2ps,iprop), Botp(gi2ps), Slat(gi2ps), ...
      Slon(gi2ps),maxy,1,gi2p,p_xax)
    land;setlargefig
  end
end
clear Nstat
%end %for isec
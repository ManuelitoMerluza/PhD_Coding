%rof_statsel.m
%optional code of readobsfile for subselecting a group of stations

% gisel: group of stations
%gisel=[1:80,91:-1:82,81];
% Variables Gidselectedpres Gidselectedcast NOT switched !

  Slat=Slat(gisel);
  Slon=Slon(gisel);
  Stnnbr=Stnnbr(gisel);
  Time=Time(gisel);
  Botd=Botd(gisel);
  if exist('Nobs')
    Nobs=Nobs(gisel);
  end
  btlnbr=btlnbr(:,gisel);
  castno=castno(:,gisel);
  opres=opres(:,gisel);
  isobs=isobs(:,gisel);
  sampno=sampno(:,gisel);
  for iprop=1:nvar
    eval([propnm(iprop,:) '='propnm(iprop,:) '(:,gisel);'])
  end

  %clear useless variables that could become confusing...
  clear gis2see ssstnnbrs zzz
  plot(Slon,Slat,'+-');ppause
  plot(Slon,-Botd,'+-');ppause
  plot(Slon,Time);ppause
  
  
  
  
  
function [cstnnbr,cbotp,propnmctd,propunitsctd,...
  pctd,tctd,sctd,o2ctd]=...
ctd_readorstom(fname);
% Read Orstom ctd format
% nstat=224
%gisel=1:onstat

disp('  ctd_readorstom.m ...')
propnmctd   ={'otemp','osali','ooxyg','ophos','osili','onita'};
propunitsctd={'cels', 'g/kg ','umol/kg','umol/kg','umol/kg','umol/kg'};
Maxobs=100;

  fictd=fopen(fname,'r');
  lnn1=fgetl(fictd);
  cstnnbr=sscanf(lnn1,'%i',1);
  lnn2=fgetl(fictd);
  lnn3=fgetl(fictd);
  lnn4=fgetl(fictd);
  
  Time=1900+str2num(lnn4(5:6))+cal2dec(str2num(lnn4(3:4)),str2num(lnn4(1:2)),...
    str2num(lnn4(8:9)), str2num(lnn4(10:11)))/365.25;
  ns=lnn4(13);
  tla=sscanf(lnn4(15:23),'%g',2);
  if ns=='S'
    cslat= -(tla(1)+tla(2)/60);
  elseif ns=='N'
    cslat=  (tla(1)+tla(2)/60);
  else
    error([lnn4 ' ns not found'])
  end
  ew=lnn4(25);
  tlo=sscanf(lnn4(27:35),'%g',2);
  if ew=='E'
    cslon= (tlo(1)+tlo(2)/60);
  elseif ew=='W'
    cslon=-(tlo(1)+tlo(2)/60);
  else
    error([lnn4 ' ew not found'])
  end
  nppp=sscanf(lnn4(37:length(lnn4)),'%g',4);
  npar=nppp(1);
  nlines=nppp(2);
  cbotp=sw_pres(nppp(2),cslat);
  
  lnn5=fgetl(fictd);
  lnn6=fgetl(fictd);
  for iv=1:npar
    lnni=fgetl(fictd);
    switch iv
    case 1
    if lnni(1)~='P'
      error(['not the right variable ! ' lnni])
    end
    case 2
    if lnni(1)~='T'
      error(['not the right variable ! ' lnni])
    end
    case 3
    if lnni(1)~='S'
      error(['not the right variable ! ' lnni])
    end
    case 4
    if lnni(1)~='O'
      error(['not the right variable ! ' lnni])
    end
    case 5
    if lnni(1)~='O'
      error(['not the right variable ! ' lnni])
    end
    otherwise
    error(['Too many parameters !' lnni])
    end
  end
  
  %READ DATA
  if strcmp(fname,'/data35/ganacho/A6/Orstom/cit10075.ecp')
    %No oxygen in cit10075.ecp
    alldata=fscanf(fictd,...
      '%f %f %f ',[1,Inf]);
    ndat=3;
  elseif strcmp(fname,'/data35/ganacho/A6/Orstom/cit10069.ecp')
    %No oxygen sarting at 2428db in cit10075.ecp
    ndat=5;
    alldata=fscanf(fictd,...
      '%f %f %f %f %f',2425*ndat);
    cnobs=length(alldata)/ndat;
    alldata=reshape(alldata,ndat,cnobs)';
    pctd=alldata(:,1);
    tctd=alldata(:,2);
    sctd=alldata(:,3);
    o2ctd=alldata(:,5);
    %data without oxygen
    ndat=3;
    alldata=fscanf(fictd,...
      '%f %f %f',1072*ndat);
    cnobs=length(alldata)/ndat;
    alldata=reshape(alldata,ndat,cnobs)';
    pctd=[pctd;alldata(:,1)];
    tctd=[tctd;alldata(:,2)];
    sctd=[sctd;alldata(:,3)];
    o2ctd=[o2ctd;NaN*ones(cnobs,1)];
    
    %data with oxygen
    ndat=5;
    alldata=fscanf(fictd,...
      '%f %f %f %f %f',[1,Inf]);
    cnobs=length(alldata)/ndat;
    if (cnobs~=round(cnobs)) 
      error('problem in the data file')
    end
    alldata=reshape(alldata,ndat,cnobs)';
    pctd=[pctd;alldata(:,1)];
    tctd=[tctd;alldata(:,2)];
    sctd=[sctd;alldata(:,3)];
    o2ctd=[o2ctd;alldata(:,5)];
    return

  elseif strcmp(fname,'/data35/ganacho/A6/Orstom/cit10068.ecp')
    %No oxygen sarting at 2715db in cit10068.ecp
    ndat=5;
    alldata=fscanf(fictd,...
      '%f %f %f %f %f',2711*ndat);
    cnobs=length(alldata)/ndat;
    alldata=reshape(alldata,ndat,cnobs)';
    pctd=alldata(:,1);
    tctd=alldata(:,2);
    sctd=alldata(:,3);
    o2ctd=alldata(:,5);
    %data without oxygen
    ndat=3;
    alldata=fscanf(fictd,...
      '%f %f %f',Inf);
    cnobs=length(alldata)/ndat;
    if (cnobs~=round(cnobs)) 
      error('problem in the data file')
    end
    alldata=reshape(alldata,ndat,cnobs)';
    pctd=[pctd;alldata(:,1)];
    tctd=[tctd;alldata(:,2)];
    sctd=[sctd;alldata(:,3)];
    o2ctd=[o2ctd;NaN*ones(cnobs,1)];
    return
  else 
    alldata=fscanf(fictd,...
      '%f %f %f %f %f',[1,Inf]);
    ndat=5;
    cnobs=length(alldata)/ndat;
  end  
  fclose(fictd);
  cnobs=length(alldata)/ndat;
  if (cnobs~=round(cnobs)) | (cnobs~=nlines)
    error('problem in the data file')
  end
  alldata=reshape(alldata,ndat,cnobs)';
  pctd=alldata(:,1);
  tctd=alldata(:,2);
  sctd=alldata(:,3);
  if ndat==5
    o2ctd=alldata(:,5); %TAKE THE umol/kg one
  else
    o2ctd=NaN*ones(cnobs,1);
  end
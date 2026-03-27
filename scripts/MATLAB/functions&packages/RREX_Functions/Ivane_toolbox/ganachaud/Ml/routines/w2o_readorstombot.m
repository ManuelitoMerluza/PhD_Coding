function [oslat,oslon,ostnnbr,Time,obotp,onobs,opropnm,opropunits,nvar,...
  opres,otemp,osali,ooxyg,ophos,osili,onita,castno]=...
w2o_readorstombot(gisel,orstomdir);
% Read Orstom bottle format
% nstat=224
%gisel=1:onstat

disp('  readorstombot.m ...')

opropnm   ={'otemp','osali','ooxyg','ophos','osili','onita'};
opropunits={'cels', 'g/kg ','umol/kg','umol/kg','umol/kg','umol/kg'};
Maxobs=100;
opres=NaN*ones(Maxobs,length(gisel));
otemp=NaN*ones(Maxobs,length(gisel));
osali=NaN*ones(Maxobs,length(gisel));
ooxyg=NaN*ones(Maxobs,length(gisel));
osili=NaN*ones(Maxobs,length(gisel));
onita=NaN*ones(Maxobs,length(gisel));
ophos=NaN*ones(Maxobs,length(gisel));

onstat=length(gisel);
for is=1:onstat
  fnut=sprintf('%s/cit1%04i.ecc',orstomdir,gisel(is));
  disp(['Reading ' fnut])
  finut=fopen(fnut,'r');
  lnn1=fgetl(finut);
  ostnnbr(is)=sscanf(lnn1,'%i',1);
  lnn2=fgetl(finut);
  lnn3=fgetl(finut);
  lnn4=fgetl(finut);
  
  Time(is)=1900+str2num(lnn4(5:6))+cal2dec(str2num(lnn4(3:4)),str2num(lnn4(1:2)),...
    str2num(lnn4(8:9)), str2num(lnn4(10:11)))/365.25;
  ns=lnn4(13);
  tla=sscanf(lnn4(15:23),'%g',2);
  if ns=='S'
    oslat(is)= -(tla(1)+tla(2)/60);
  elseif ns=='N'
    oslat(is)=  (tla(1)+tla(2)/60);
  else
    error([lnn4 ' ns not found'])
  end
  ew=lnn4(25);
  tlo=sscanf(lnn4(27:35),'%g',2);
  if ew=='E'
    oslon(is)= (tlo(1)+tlo(2)/60);
  elseif ew=='W'
    oslon(is)=-(tlo(1)+tlo(2)/60);
  else
    error([lnn4 ' ew not found'])
  end
  nppp=sscanf(lnn4(37:length(lnn4)),'%g',4);
  npar(is)=nppp(1);
  obotp(is)=sw_pres(nppp(3),oslat(is));
  
  lnn5=fgetl(finut);
  lnn6=fgetl(finut);
  for iv=1:npar(is)
    lnni=fgetl(finut);
    switch iv
    case 1
    if lnni(1)~='P'
      error(['not the right variable !' lnni])
    end
    case 2
    if lnni(1)~='T'
      error(['not the right variable !' lnni])
    end
    case 3
    if lnni(1)~='S'
      error(['not the right variable !' lnni])
    end
    case 4
    if lnni(1)~='O'
      error(['not the right variable !' lnni])
    end
    case 5
    if lnni(1)~='S'
      error(['not the right variable !' lnni])
    end
    case 6
    if lnni(1)~='N'
      error(['not the right variable !' lnni])
    end
    case 7
    if lnni(1)~='P'
      error(['not the right variable !' lnni])
    end
    otherwise
    error(['Too many parameters !' lnni])
    end
  end
  alldata=fscanf(finut,...
    '%f %s %f %s %f %s %f %s %f %s %f %s %f %s ',[1,Inf]);
  fclose(finut);
  onobs(is)=length(alldata)/14;
  if onobs(is)~=round(onobs(is))
    error('problem in the data file')
  end
  alldata=reshape(alldata,14,onobs(is))';
  opres(1:onobs(is),is)=alldata(:,1);
  gin1=find(alldata(:,2)~=98);
  opres(gin1,is)=NaN*ones(size(gin1));
  gin2=find(opres(1:onobs(is),is)==999999);
  opres(gin2,is)=NaN*ones(size(gin2));
  giobs=find(~isnan(opres(1:onobs(is),is)));
  onobs(is)=length(giobs);
  opres(1:onobs(is),is)=opres(giobs,is);
  
  otemp(1:onobs(is),is)=alldata(giobs,3);
  gin=find(alldata(giobs,4)~=98);
  otemp(gin,is)=NaN*ones(size(gin));
  osali(1:onobs(is),is)=alldata(giobs,5);
  gin=find(alldata(giobs,6)~=98);
  osali(gin,is)=NaN*ones(size(gin));
  ooxyg(1:onobs(is),is)=alldata(giobs,7);
  gin=find(alldata(giobs,8)~=98);
  ooxyg(gin,is)=NaN*ones(size(gin));
  osili(1:onobs(is),is)=alldata(giobs,9);
  gin=find(alldata(giobs,10)~=98);
  osili(gin,is)=NaN*ones(size(gin));
  onita(1:onobs(is),is)=alldata(giobs,11);
  gin=find(alldata(giobs,12)~=98);
  onita(gin,is)=NaN*ones(size(gin));
  ophos(1:onobs(is),is)=alldata(giobs,13);
  gin=find(alldata(giobs,14)~=98);
  ophos(gin,is)=NaN*ones(size(gin));
  castno(1:onobs(is),is)=-1;
  
  %gidrilled=find(opres(1:onobs(is),is)>obotp(is));
  %opres(gidrilled,is)=obotp(is)*ones(size(gidrilled));
  pmax=max(opres(1:onobs(is),is));
  if pmax>obotp(is)
    disp(sprintf('Station %i , changing botdepth from %f to %f\n',...
      is,obotp(is),pmax))
    obotp(is)=pmax;
    if (pmax-obotp(is))>200
      disp('LARGE UNDER-THE-BOTTOM MEASUREMENT !')
      pmax
      obotp
      ppause
    end
  end
end %is

nlev=max(onobs);
if nlev>Maxobs
  error('parameter Maxobs too small. Increase and rerun !')
end
opres=opres(1:nlev,:);
otemp=otemp(1:nlev,:);
osali=osali(1:nlev,:);
ooxyg=ooxyg(1:nlev,:);
osili=osili(1:nlev,:);
onita=onita(1:nlev,:);
ophos=ophos(1:nlev,:);
nvar=6;

oslat=oslat(:);
oslon=oslon(:);
ostnnbr=ostnnbr(:);
Time=Time(:);
obotp=obotp(:);
onobs= onobs(:);

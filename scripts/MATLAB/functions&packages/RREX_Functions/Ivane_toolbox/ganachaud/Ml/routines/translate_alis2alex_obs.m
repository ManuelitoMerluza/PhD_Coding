%To translate Alison's format to Alex format for observed data
%Additional parameters that will be saved:
    Itemp=1; Isali=2; Ioxyg=3;Iphos=4;Isili=5;Inita=6;Initi=7;
    %CRUISE INFO
    Secname='A9';
    Cruise='A9, METEOR cruise 15, leg 3, Siedler';
    Secdate='Feb 10, 1991 to March 3, 1991';
    Remarks=[];
    Treatment='Woce data treatment';
    OPdir='/data35/ganacho/A9/Obsdata/';

%ORIGINAL DATA OBSERVATION MASK
bottobsmaskfile='/data35/ganacho/A9/Obsdata/A9.observed_obsmask.mat';
  
%Data File
obsdir= '/data35/ganacho/A9/';
fobsdat='A9.observed';
obshdr= 'A9.stationh';
nstat=111;
nvar=12;
ndep=70;
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  eval(['load ' bottobsmaskfile])
  %CONTENT:
  %Botd                Slat                isobs               
  %Gidselectedcast     Slon                lstat               
  %Gidselectedpres     Stnnbr              nsec                
  %Maxd                Xdep                opres               
  %Nobs                botfile             propnm              
  %Nprop               sumfile             opropunits
  %Nstat               fstat               
  onstat=nstat;

  %READ HEADER FILE
  nbhdr=[obsdir obshdr];
  [oship,ostnnbr,oslat,oslon,obotp,okt,oxdep,onobs,omaxd]=...
    read_stathdr(nbhdr,nstat);
  if any(diff(okt)~=1)
    error('okt not consecutive. Program will not work')
  end
  if exist('gstatobs')
    ostnnbr=ostnnbr(gstatobs);
    obotp=obotp(gstatobs);
    oship=oship(gstatobs);
    oslat=oslat(gstatobs);
    oslon=oslon(gstatobs);
    okt=okt(gstatobs);
    oxdep=oxdep(gstatobs);
    onobs=onobs(gstatobs);
  else
    gstatobs=1:onstat;
  end
  %READ DATA
  [fid,message]=fopen([ obsdir fobsdat],'r');
  if fid==-1
    error(message)
  end
  reclen=ndep*(nvar+1);
  allprops=NaN*ones(ndep,nstat,nvar+1);
  for is=1:nstat
    [record,ct]=fread(fid,[reclen],'float32');
    if ct<reclen
      error('Not the right number of station/variables')
    end
    for iprop=1:nvar+1
      allprops(:,is,iprop)=record((iprop-1)*ndep+1:(iprop*ndep));
    end %iprop
  end %is
  [record,ct]=fread(fid,[reclen],'float32');
  if ct~=0
    error('Some more data information is to read')
  end
  fclose(fid);
  
  %Recover properties from info file
  %opres is the first property. normally it is already here from the 
  %bottobsmaskfile
  opres=squeeze(allprops(:,gstatobs,1));
  onprop=length(propnm);
  if ~iscell('propnm')
    for iprop=1:onprop
      opropnm{iprop}=killblank(propnm{iprop});
    end
  end
  for iprop=1:onprop
    eval([opropnm{iprop} '=squeeze(allprops(:,gstatobs,iprop+1));'])
    ostatfiles{iprop}=[Secname '_obs_' opropnm{iprop} '.fbin'];
    oprecision{iprop}='float32';
  end %iprop
  %clear allprops
  
  %re-save the bottle mask file with consistent variable names
  %eval(['save ' bottobsmaskfile ' Botd  Gidselectedcast Gidselectedpres '...
  %    'omaxd onobs oslat oslon ostnnbr oxdep botfile sumfile fstat '...
  %    'isobs lstat nsec opres opropnm'])

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % SAVE THE PROPERTIES INTO ALEX' FORMAT
  for iprop=1:onprop
    ovw=1;
    eval(['prop=' opropnm{iprop} ';'])
    whydro(prop,[OPdir ostatfiles{iprop}],oprecision{iprop},omaxd,ovw)
  end
  
  %SAVING HEADER FILE
  OPhdr=[Secname '_obs.hdr.mat'];
  obotp=sw_pres(Botd,oslat);
  
  eval(['save ' OPdir OPhdr ' Treatment Remarks Cruise Secname '...
      'Secdate onstat oslat oslon '...
      'obotp opres omaxd onprop  '...
      'Itemp Isali Ioxyg Iphos Isili Inita Initi '...
      'opropnm opropunits ostatfiles oprecision '...
      'oship ostnnbr oxdep okt onobs isobs '...
      'Gidselectedcast Gidselectedpres botfile sumfile ']);

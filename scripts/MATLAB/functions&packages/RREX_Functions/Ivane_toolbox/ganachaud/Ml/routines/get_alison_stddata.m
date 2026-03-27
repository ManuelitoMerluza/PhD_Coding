%Get Alison's standard depth data
%nvar: number of variables in the input file
%Nprop: size of Propnm: number of properties to pick (from temp ...)

  nbhdr=[bottdir botthdr];
  %READ HEADER FILE
  [ship,stnnbr,slat,slon,botp,kt,xdep,nobs,maxd]=...
    read_stathdr(nbhdr,nstat);
  if any(diff(kt)~=1)
    error('kt not consecutive. Program will not work')
  end
  if exist('gstatbott')
    stnnbr=stnnbr(gstatbott);
    botp=botp(gstatbott);
    Ship=ship(gstatbott);
    Slat=slat(gstatbott);
    Slon=slon(gstatbott);
    Kt=kt(gstatbott);
    Xdep=xdep(gstatbott);
    Nobs=nobs(gstatbott);
  end  
  %READ DATA
  [fid,message]=fopen([ bottdir botdat],'r');
  if fid==-1
    error(message)
  end
  Ndep=ndep;
  Nprop=length(Propnm);
  reclen=ndep*nvar;
  allprops=NaN*ones(Ndep,nstat,nvar);
  for is=1:nstat
    [record,ct]=fread(fid,[reclen],'float32');
    if ct<reclen
      error('Not the right number of station/variables')
    end
    for iprop=1:nvar
      allprops(:,is,iprop)=record((iprop-1)*ndep+1:(iprop*ndep));
    end %iprop
  end %is
  [record,ct]=fread(fid,[reclen],'float32');
  if ct~=0
    error('Some more data information is to read')
  end
  fclose(fid);
  for iprop=1:Nprop
    eval([Propnm{iprop} '=squeeze(allprops(:,gstatbott,iprop));'])
    Statfiles{iprop}=[Secname '_stat_' Propnm{iprop} '.fbin'];
    Precision{iprop}='float32';
  end %iprop
  %clear allprops
  Nstat=length(gstatbott);

% script readalisonbot
% KEY: read bottle data from Alison's format
% USAGE :
% 
%
%
%
% DESCRIPTION : 
%
%
% INPUT PARAMETERS
%  nhdr : name of header file
%  nifile: name of input bottle file
%  nlev: number of levels in the bottle file
%  nvar: number of variables     (not including pressure)
%  propnm: name of each property (not including pressure)
%  onstat:number of stations
%  e.g.: /data39/alison/phd/atldata/at109readobsfile_input.m
%
% OUTPUT:
%  Slat, Slon, ...
%  opres, otemp, ...
%
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , Oct 97
%
% SIDE EFFECTS :
%
% SEE ALSO :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER:
% CALLEE: Hydrosys routines
  if p_woce
    error('p_woce was set together with p_alison')
  end
  if ~exist('nhdr')
    disp('running default parameter file ...')
    readobsfile_input
    disp(['READING ' nifile])
    disp(nhdr)
  end
  
  %READ HEADER FILE
  fidh=fopen(nhdr,'r');
  Shipid=fread(fidh,[nstat,1],'int32');
  ostnnbr=fread(fidh,[nstat,1],'int32');
  oslat  =fread(fidh,[nstat,1],'float');
  oslon  =fread(fidh,[nstat,1],'float');
  obotd  =fread(fidh,[nstat,1],'float');
  Kt    =fread(fidh,[nstat,1],'int32'); 
  Xdep  =fread(fidh,[nstat,1],'float'); %deepest measurement
  onobs  =fread(fidh,[nstat,1],'int32');
  omaxd  =fread(fidh,[nstat,1],'int32');
  if ~isempty(fread(fidh))
    error('more info in header file')
  end
  fclose(fidh);
  
  %READ OBSERVATIONS
  reclen=4*(nvar+1)*nlev;
  
  fid=fopen(nifile,'r');
  for is=1:nstat
    rec=fread(fid,[nlev,nvar+1],'float');
    opres(:,is)=rec(:,1);
    for iprop=1:nvar
      oprop=rec(:,iprop+1);
      eval([opropnm{iprop} '(:,is)=oprop;'])
    end
  end
  fclose(fid);
  
  %MASK THE DATA BELOW LAST OBSERVATION, REMOVE -999 -> NaN
  issurfnull=find(opres(1,:)==0);
  opres(1,issurfnull)=ones(size(issurfnull));
  ggidry=find(opres==0);
  %for is=1:nstat
  %  if any(opres(omaxd(is)+1:nlev,is))
  %    error('pressure problem');
  %  else
  %    opres(omaxd(is)+1:nlev,is)=NaN*ones(nlev-omaxd(is),1);
  %  end
  %end
  opres(ggidry)=NaN;
  for is=1:nstat
    omx=max(find(~isnan(opres(:,is))));
    if omx~=omaxd(is)
      disp(sprintf(['Station %i omaxd corrected from '...
	  ' %i to %i'],is,omaxd(is),omx))
      omaxd(is)=omx;
    end
  end
  opres(1,issurfnull)=0;
  clear issurfnull
  
  disp('')
  disp('*******************************************************')
  for iprop=1:nvar
    eval(['prop=' opropnm{iprop} ';'])
    prop(ggidry)=NaN*ones(size(ggidry));
    ginan=find(prop==-999);
    prop(ginan)=NaN*ones(size(ginan));
    if iprop==3 & all(prop(~isnan(prop))<100)
      ptemp=sw_ptmp(osali,otemp,opres,0);
      rho = sw_dens(osali,ptemp,0);
      if ~strcmp(killblank(opropnm{iprop}),'ooxyg')
	error('problem with oxygen ')
      end
      disp('Converting oxygen from ml/l to umol/kg')
      prop = 44.6369*prop*1e3./rho;
    end
    if p_nut_moll2molkg &iprop>3
      disp(['Converting ' opropnm{iprop} '  from umol/l to umol/kg'])
      prop = nut_units(prop,osali);
    elseif iprop>3
      disp(['Not mol/l to mol/kg conversion for ' opropnm{iprop}  '?'])
      ppause
    end
    eval([opropnm{iprop} '=prop;'])
  end
 
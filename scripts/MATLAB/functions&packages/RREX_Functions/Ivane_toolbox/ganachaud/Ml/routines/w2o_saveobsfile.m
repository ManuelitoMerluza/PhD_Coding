% saveobsfile
% KEY:    save variables into a "observation" file readable by program
%         obs2std
% USAGE :
% 
%
%
%
% DESCRIPTION : 
%
%
% INPUT:
%
% OUTPUT:
%   <nofile>: binary direct access file containing the data
%   <nofile>_obsmask.mat: matlab file containing the observation
%   mask
% example of use of the mask:
onprop=nvar;
if 0
  for iprop=1:onprop
    figure(iprop);clf 
    omask=ones(size(isobs));
    gimask=find(~bitget(isobs,iprop));
    omask(gimask)=NaN;
    plot(1:onstat,-opres.*omask,'b.',1:onstat,-obotp) 
    title(['OBSERVED ' opropnm{iprop}])
    xlabel('Station indice');ylabel('Pressure')
    set(gca,'xlim',[1 onstat]);grid on
    land;setlargefig;
  end
end
%
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , Aug 97
%
% SIDE EFFECTS :
%
% SEE ALSO : readobsfile
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER:
% CALLEE:
disp('  w2o_saveobsfile.m ...')
onprop=nvar;

if ~(exist(OPdir)==7)
  disp('Creating output directory ...')
  disp(['mkdir ' OPdir]);
  unix(['mkdir ' OPdir]);
end

%UPDATE isobs
for iprop=1:nvar
  eval(['prop=' opropnm{iprop} ';'])
  ginan=find(isnan(prop));
  isobs(ginan)=bitset(isobs(ginan),iprop,0);
end 

%UNMASK THE DATA: PUTS ZEROS UNDER BELOW LAST OBSERVATION
%REPLACE OTHER NaN's WITH -999
if p_alison
  ggidry=find(opres==0);
elseif p_woce
  omaxd=sum((~isnan(opres))); %INDICE OF THE LAST BOTTLE DEPTH
  ggidry=find(isnan(opres));
  %opres(ggidry)=zeros(size(ggidry));
end
for iprop=1:nvar
  eval(['prop=' opropnm{iprop} ';'])
  prop(ggidry)=zeros(size(ggidry));
  ginan=find(isnan(prop));
  prop(ginan)=-999*ones(size(ginan));
  eval([opropnm{iprop} '=prop;'])
end
if exist('issurfnull')&~isempty(issurfnull)
  opres(1,issurfnull)=0;
end
% Create oxdep, Depth of last observation
okt=(1:onstat)';
if ~exist('oship')
  oship=zeros(onstat,1);
end
if ~exist('Gidselectedcast')
  Gidselectedcast=[];
end
%UPDATE BOTTOM DEPTH TO MATCH DEEPEST OBSERVATIONS
%(avoids producing ridiculous underground bottles on the plots)
for is=1:onstat
  xd=mmax(opres(:,is));
  if ~isempty(xd)
    oxdep(is)=xd; %LAST BOTTLE DEPTH
  else
    oxdep(is)=NaN;
  end
  dpres=obotp(is)-oxdep(is);
  if dpres<0
    disp(sprintf('updating bottom pressure station %i (%i)',...
      is,ostnnbr(is)))
    if ( abs(dpres)>200 )
      disp('last bottle below bottom by more than 200db ... Check everything !')
      disp([obotp(is) oxdep(is)])
      ppause
    end
    obotp(is)=oxdep(is)+1;
  end
end
  

if exist('Cast')
  disp('Renaming Cast to ostnnbr')
  ostnnbr=Cast;
end
if ~exist('Gidselectedpres')
  Gidselectedpres=NaN;
end
%SAVE
if exist('nofile')
  disp(['SAVING RESULTS IN ' nofile ])
  disp('OK ?')
  ppause
  disp('ALISON S FORMAT ...')
  if exist(nofile)==2
    str=input('FILE ALREADY EXIST. REMOVE ? (y/n)','s');
  else
    str='y';
  end
  if strcmp(lower(str(1)),'y')
    fid=fopen(nofile,'w');
    for is=1:onstat
      clear rec
      rec(:,1)=opres(:,is);
      for iprop=1:onprop
	eval(['oprop=' opropnm{iprop} '(:,is);'])
	rec(:,iprop+1)=oprop;
	if find(isnan(rec))|find(isinf(rec))
	  stop
	end
      end
      fwrite(fid,rec,'float');
    end
    fclose(fid);
    disp('DONE')
  else
    disp('FILE NOT SAVED')
  end
  %SAVE THE OBSERVATION MASK AND HEADER DATA
  nomf=[nofile '_obsmask.mat'];
  disp('SAVING HEADER INFO AND OBSERVATION MASK IN')
  disp(nomf)
  omaxd=omaxd(:);
  if p_alison
    eval(['save ' nomf ' oship ostnnbr oslat oslon obotd oxdep onobs omaxd'...
	' isobs opres nvar opropnm nsec fstat lstat'])
  elseif p_woce
    eval(['save ' nomf ' sumfile botfile ostnnbr onstat onprop '...
	' oslat oslon obotd oxdep onobs omaxd'...
	' Gidselectedcast Gidselectedpres ' ...
	' isobs opres opropnm opropunits nsec fstat lstat'])
    
    %CREATES HEADER FILE
    disp(['WRITING HEADER ' nhdr])
    fidh=fopen(nhdr,'w');
    fwrite(fidh,oship,'int32');
    fwrite(fidh,ostnnbr,'int32');
    fwrite(fidh,oslat,'float');
    fwrite(fidh,oslon,'float');
    fwrite(fidh,obotd,'float');
    fwrite(fidh,okt,  'int32');
    fwrite(fidh,oxdep,'float');
    fwrite(fidh,onobs,'int32');
    fwrite(fidh,omaxd,'int32');
    fclose(fidh);
    disp('DONE')
  end  
end %if exist('nofile')

if exist('OPdir')
  disp('Writing data with Alex format')
  onprop=length(opropnm);
  for iprop=1:onprop
    ostatfiles{iprop}=[Secname '_obs_' killblank(opropnm{iprop}) '.fbin'];
    oprecision{iprop}='float32';
  end %iprop
  for iprop=1:onprop
    ovw=1;
    eval(['prop=' opropnm{iprop} ';'])
    whydro(prop,[OPdir ostatfiles{iprop}],oprecision{iprop},omaxd,ovw)
  end
  
  %SAVING HEADER FILE
  OPhdr=[Secname '_obs.hdr.mat'];
  if ~exist('obotp')
    obotp=sw_pres(obotd,oslat);
  end
  disp(['Writting header ' OPdir OPhdr])
  eval(['save ' OPdir OPhdr ' Treatment Remarks Cruise Secname '...
      'Secdate onstat oslat oslon '...
      'obotp opres omaxd onprop  '...
      'opropnm opropunits ostatfiles oprecision '...
      'oship ostnnbr oxdep okt onobs isobs '...
      'Gidselectedcast Gidselectedpres ']);
 
end % 					exist('OPdir')

disp('')
disp('DATA SAVED')
disp('diary off')
disp('Program finished now')
diary off
disp('plotting observation location')
for iprop=1:onprop
  figure(iprop);clf 
  omask=ones(size(isobs));
  gimask=find(~bitget(isobs,iprop));
  omask(gimask)=NaN;
  plot(1:onstat,-opres.*omask,'b.',1:onstat,-obotp) 
  title([opropnm{iprop} ' observations'])
  xlabel('Station indice');ylabel('Pressure')
  set(gca,'xlim',[1 onstat]);grid on
  land;setlargefig;
  axes('position',[0 0 1 1])
  axis off
  text(.01,.03,Cruise)
end

s=input('Print all that ? (y/n) ','s');
if s=='y'
  for iprop=1:onprop  
    pg;close
  end
end

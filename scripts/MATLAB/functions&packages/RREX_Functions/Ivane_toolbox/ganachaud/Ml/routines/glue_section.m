%glue_section
% KEY: Put together two or more pieces of a cruise (2 legs)
% USAGE : Right after woce2obs
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
%
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , Dec 97
%
% SIDE EFFECTS :
%
% SEE ALSO :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER:
% CALLEE:
%ca
%IPdir='/data35/ganacho/P21/Obsdata/';
%OPdir=IPdir;
%hdrname =['P21E_leg2_obs.hdr.mat';'P21E_leg1_obs.hdr.mat'];
%gisel{1}=1:89;
%gisel{2}='a';
%newsectionname='P21';

for ipiece=1:size(hdrname,1)
  disp(' reading header file : ')
  disp([IPdir hdrname(ipiece,:)])
  eval(['load ' IPdir hdrname(ipiece,:) ])

  if gisel{ipiece}=='a'
    gis=(1:onstat)';
  else
    gis=gisel{ipiece}(:);
  end
  % 2 - DATA FILE:
  disp('READING DATA FILES ...')
  for iprop=1:onprop
    sf= ostatfiles{iprop};
    pr=oprecision{iprop};
    prp=opropnm{iprop};
    disp([IPdir sf])
    ompres=size(opres,1);
    prop = rhydro([IPdir sf], pr, ...
      ompres, onstat, omaxd);
    if ipiece==1
      eval([prp '=prop(:,gis);']);
    else
      eval([prp '=[' prp ', prop(:,gis)];'])
    end
  end
  
  %Gluing:
  if ipiece==1
    Cruise1=Cruise;
    Remarks1=Remarks;
    Secdate1=Secdate;
    Secname1=Secname;
    Treatment1=Treatment;
    isobs1=isobs(:,gis);
    obotp1=obotp(gis);
    okt1=okt(gis);
    omaxd1=omaxd(gis);
    onobs1=onobs(gis);
    onprop1=onprop;
    onstat1=length(gis);
    oprecision1=oprecision;
    opres1=opres(:,gis);
    opropnm1=opropnm;
    opropunits1=opropunits;
    oship1=oship(gis);
    oslat1=oslat(gis);
    oslon1=oslon(gis);
    ostatfiles1=ostatfiles;
    ostnnbr1=ostnnbr(gis);
    oxdep1=oxdep(gis);
  else
    Cruise1=[Cruise1 '-' Cruise];
    Remarks1=[Remarks1 ' - ' Remarks];
    Secdate1=[Secdate1 ' - ' Secdate];
    Secname1=[Secname1 ' - ' Secname];
    Treatment1=[Treatment1 ' - ' Treatment];
    isobs1=[isobs1,isobs(:,gis)];
    obotp1=[obotp1;obotp(gis)];
    okt1=[okt1;okt(gis)];
    omaxd1=[omaxd1,omaxd(gis)];
    onobs1=[onobs1,onobs(gis)];
    if onprop1~=onprop
      error('Not the same number of data !')
    end
    if ~all(strcmp(oprecision1,oprecision1))
      error('Not the same precision!')
    end
    if ~all(strcmp(opropnm1,opropnm))
      error('Not the same properties!')
    end
    if ~all(strcmp(opropunits1,opropunits))
      error('Not the same units!')
    end
    onstat1=onstat1+length(gis);
    opres1=[opres1,opres(:,gis)];
    oship1=[oship1;oship(gis)];
    oslat1=[oslat1;oslat(gis)];
    oslon1=[oslon1;oslon(gis)];
    ostnnbr1=[ostnnbr1;ostnnbr(gis)];
    oxdep1=[oxdep1,oxdep(gis)];    
  end
end

%RENAME AND SAVE THE NEW DATA SET
    Cruise=Cruise1;
    Remarks=Remarks1;
    Secdate=Secdate1;
    Treatment=Treatment1;
    isobs=isobs1;
    obotp=obotp1;
    okt=okt1;
    omaxd=omaxd1(:);
    onobs=onobs1(:);
    onprop=onprop1;
    onstat=onstat1;
    oprecision=oprecision1;
    opres=opres1;
    opropnm=opropnm1;
    opropunits=opropunits1;
    oship=oship1;
    oslat=oslat1;
    oslon=scan_longitude(oslon1);
    ostatfiles=ostatfiles1;
    ostnnbr=ostnnbr1;
    oxdep=oxdep1(:);

    Secname=newsectionname;
    for iprop=1:onprop
      ostatfiles{iprop}=[Secname '_obs_' killblank(opropnm{iprop}) '.fbin'];
      oprecision{iprop}='float32';
    end %iprop
    for iprop=1:onprop
      ovw=0;
      eval(['prop=' opropnm{iprop} ';'])
      whydro(prop,[OPdir ostatfiles{iprop}],oprecision{iprop},omaxd,ovw)
    end
  
    %SAVING HEADER FILE
    OPhdr=[Secname '_obs.hdr.mat'];
    if exist([OPdir OPhdr])==2
      s=input([ 'OVERWRITE ' OPdir OPhdr ' ? '],'s');
    else
      s='y';
    end
    if s=='y'
      disp(['Writting header ' OPdir OPhdr])
      eval(['save ' OPdir OPhdr ' Treatment Remarks Cruise Secname '...
	  'Secdate onstat oslat oslon '...
	  'obotp opres omaxd onprop  '...
	  'opropnm opropunits ostatfiles oprecision '...
	  'oship ostnnbr oxdep okt onobs isobs ']);
    else
      disp('!!!!!!!!!!!!!!!! Header file not wrote !')
    end
  end

  figure(1);clf
  plot(oslon,oslat,'+-');grid on;zoom on;xlabel('oslon');ylabel('oslat');title(Cruise)
  for ipt=1:10:length(oslon);
    htxt=text(oslon((ipt)),.02+oslat((ipt)),sprintf('%i',(ipt)),...
      'fontsize',12,'VerticalAlignment','bottom');
  end
  land;setlargefig;
  %Check for repeat stations
  for is=1:length(ostnnbr)
    giff=find(ostnnbr==ostnnbr(is));
    if length(giff)>1
      giff
      error('repeat station number ! Eliminate first')
    end
  end
  %check for azimuthal change
  [dis,phaseangle]=sw_dist(oslat,oslon,'km');
  giff=find(abs(diff(phaseangle))>90);
  if giff
    disp('LARGE AZIMUTHAL CHANGE... CHECK FOR STATION SWAP / REPEAT!')
    disp('Station(s):')
    disp(giff)
    ppause
  end
   figure(2);clf
  plot(sw_dist(oslat,oslon,'km'),'+-');grid on;zoom;xlabel('pair number');
  ylabel('distance between stations (km)');title(Cruise)
  zoom on
  land;setlargefig
  
  figure(3);clf
  plot(-obotp,'+-');grid on;zoom;xlabel('pair number');
  ylabel('bottom pressure');title(Cruise)
  zoom on
  land;setlargefig
  s10=input('print these figures ? ','s');
  if s10=='y'
    f1;land;setlargefig;print -Pgraphics;
    f2;land;setlargefig;print -Pgraphics;
    f3;land;setlargefig;print -Pgraphics;
  end

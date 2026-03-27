% SCRIPT readobsfile
% KEY: READ AN OBSERVATION FILE OUTPUT FROM EITHER
% WOCE2OBS (ALISON'S OBSERVATION FILE)
% OR ASCII WOCE FORMAT
% 
% MAKE PLOTS TO TRY TO DETECT OUTLIERS IN OBSERVATIONS
% 
% USAGE : 
% 
% STEP 0: SET RUN PARAMETERS AS DESCRIBED BELOW (BY RUNNING A 
%  woce2obs_input.m - type file
%
% STEP 1: RUN WOCE2OBS:
%   Data are read and outliers are eliminated
%   1) read sum file    (woce2obs)
%   2) read bottle data (w2o_readwocebot)
%     2a) check bottle number consistency and fill opres, otemp, osali, etc.
%         result is saved in rwbstep1.mat
%         script: rwb_selectprop
%
%     2c) (automatic) lookup for bottles within 10m from each other
%         eliminate and replace with one bottle with as many measurement
%         as possible from all other bottles
%         result is saved in rwbstep2.mat
%         script: rwb_step2
%
%     2d) (interactive) Makes the pressure monotically increasing
%     reorder or eliminate some points
%
%   3) Spot outliers visually
%      WRITE THEM DOWN (Station no/depth range and variable) 
%      TO ELIMINATE THEM LATER
%      script:w2o_spotoutliers
%
%   4) SET VARIABLE gis TO THE STATIONS THAT WANT TO BE CHECKED
%      VISUALIZE STATIONS
%      script: w2o_checkstat
%
%   5) MAKE MANUAL MODIFICATION, E.G. onita(23,12)=NaN TO REMOVE
%      OUTLIER OBSERVATION STATION 12, depth 23
%      KEEP A RECORD OF THESE MODIF IN pwd/woce2obs.log
%
% 
%   6) SAVE THE INTERPOLATED DATA
%      w2o_saveobsfile.m
%      ALSO SAVES A BINARY ARRAY CONTAINING PRESSURE
%      HEADER INFO AND LOGICAL ON OBSERVED DATA ('isobs')
%
%
% DESCRIPTION : 
%
% INPUT: Bottle data in the WOCE format
%        run parameters in memory: from woce2obs_input
%        e.g., /data35/ganacho/A9/woce2obs_input.m
%
% OUTPUT: modified data, same format
%
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , Sep 97
%   MODIF TO ACCEPT ORSTOM FORMAT (A6 and A7)
%
%
%
% SIDE EFFECTS :
%
% SEE ALSO : woce2obs_input.m w2o_checkstat, w2o_saveobsfile, plotobsdata.m
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER:
% CALLEE: readwocebot/readalisonbot rof_spotoutliers checkstat saveobsfile

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  OBSOLETE INFORMATION
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PARAMETERS NEEDED IN MEMORY (FROM A readobsfile_input.m FILE FOR EXAMPLE)
% INPUT: WOCE2OBS output = bottle data in the binary format
%
%  INPUT OBSERVATION HEADER AND DATA FILE
%    nhdr  ='/data39/alison/phd/atldata/at109.stationh_sun';
%    nifile='/data39/alison/phd/atldata/at109.observed_sun';
%  OUTPUT OBSERVATION MODIFIED FILE
%    nofile='/data39/alison/phd/atldata/at109.observedm_sun';
%  NUMBER OF VERTICAL LEVELS IN INPUT FILE
%    nlev=24;
%  NUMBER OF VARIABLES EXCLUDING PRESSURE
%    nvar=6;
%  NAME OF PROPERTIES
%    propnm=['otemp';'osali';'ooxyg';'ophos';'osili';'onita'];
%  NUMBER OF STATIONS
%    nstat=213;
%  SECTION SEPARATION (ONLY FOR PLOTTING CONVENIENCE)
%    nsec=3; %number of sections in the data
%    fstat=[1;  102;192]; %section first station
%    lstat=[101;191;213]; %section last  station
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
p_alison=0;
p_woce=~p_alison;
if p_woce
  %READ WOCE FORMAT
  %sumfile='/data35/ganacho/Woce/A9/06MT15-3.sum';
  %botfile='/data35/ganacho/Woce/A9/06MT15-3.hyd';
  %  
  %gisel=1:111; %STATIONS SUBSELECTED FROM THE SUM FILE
  %fstat=1;lstat=111;nsec=1;
  %
  %OUTPUT FILES
  %  OPTION 1: ALISON'S FORMAT
  %  nofile='/data35/ganacho/Woce/A9/A9.observed';
  %  nhdr  ='/data35/ganacho/Woce/A9/A9.stationh';
  % 
  %  OPTION 2: ALEX' FORMAT
  %  GIVE OPdir if Alex' format
  %  OPdir='/data35/ganacho/A9/Obsdata/';
  %  Itemp=1; Isali=2; Ioxyg=3;Iphos=4;Isili=5;Inita=6;Initi=7;
  %  CRUISE INFO
  %  Secname='A9';
  %  Cruise='A9, METEOR cruise 15, leg 3, Siedler';
  %  Secdate='Feb 10, 1991 to March 3, 1991';
  %  Remarks=[];
  %  Treatment='Woce data treatment';

  disp(['opening diary ' pwd '/woce2obs.dry'])
  if exist('woce2obs.dry')==2
    !rm woce2obs.dry
  end
  diary woce2obs.dry
  if exist('orstomdir')
    disp('Reading ORSTOM format')
    [oslat,oslon,ostnnbr,Time,obotp,onobs,opropnm,opropunits,nvar,...
	opres,otemp,osali,ooxyg,ophos,osili,onita,castno]=...
      w2o_readorstombot(gisel,orstomdir);
    onstat=length(obotp);
    nlev=size(opres,1);
    sampno=castno; %All dummy and eq. -1 here
    btlnbr=castno; %All dummy and eq. -1 here
  
  else %WOCE FORMAT
    disp(['reading ' sumfile '...'])
    [oslat,oslon,ostnnbr,Time,obotd]=whp_sum(sumfile);
    if ~exist('gisel')
      gisel=1:length(oslon);
    end
    disp('done')
    oslat=oslat(gisel);
    oslon=scan_longitude(oslon(gisel));
    ostnnbr=ostnnbr(gisel);
    Time=Time(gisel);
    obotd=obotd(gisel);
    obotp=sw_pres(obotd,oslat);
  end %if exist('orstomdir')
  if ~exist('nsec')
    fstat=1;
    lstat=length(oslon);
    nsec=1;  
  end
 
  figure(1);clf
  plot(oslon,oslat,'+-');grid on;zoom;xlabel('oslon');ylabel('oslat');title(Cruise)
  for ipt=1:10:length(oslon);
    htxt=text(oslon((ipt)),.02+oslat((ipt)),sprintf('%i',(ipt)),...
      'fontsize',12,'VerticalAlignment','bottom');
  end
  figure(2);clf
  plot(sw_dist(oslat,oslon,'km'),'+-');grid on;zoom;xlabel('pair number');
  ylabel('distance between stations (km)');title(Cruise)
  zoom
  land;setlargefig
  ppause
  
  if exist('orstomdir')
    %checks on pressures from the readwocebot procedure
    p_debug=0;
    rwb_step2
    rwb_step3
    save rwbstep3.mat
  else  
    w2o_readwocebot
  end
  %load rwbstep3.mat
end %p_woce

if p_alison
  %READ ALISON'S FORMAT, OUTPUT OF WOCE2OBS
  readalisonbot
end %if p_alison

%CREATE THE LOGICAL ARRAY isobs 1 is data, 0 if no
%bitget(isobs,iprop)=1 -> observed
isobs=zeros(nlev,onstat);
for iprop=1:nvar
  eval(['prop=' opropnm{iprop} ';'])
  giobs=find(~isnan(prop));
  isobs(giobs)=bitset(isobs(giobs),iprop);
end  

%PLOT THE BOTTLE SAMPLES FOR EACH SECTION AS IT MAY BE USEFUL AFTERWARD
f1;clf;f2;clf
for isec=1:nsec
  gisec=fstat(isec):lstat(isec);
  f1;
  subplot(nsec,1,isec)
  plot(-obotp(gisec))
  hold on;grid on
  plot(gisec,-opres(:,gisec),'.')
  axis([min(gisec),max(gisec),-max(obotp(gisec)),0])
  title(['bottles, ' Cruise ])
  xlabel('station indice')
  zoom
  set(gcf,'paperor','land')
  setlargefig
  f2;
  subplot(nsec,1,isec)
  plot(oslon(gisec),oslat,'.-')
  for ipt=1:10:length(gisec);
    htxt=text(oslon(gisec(ipt)),.02+oslat(gisec(ipt)),sprintf('%i',gisec(ipt)),...
      'fontsize',8,'VerticalAlignment','bottom');
  end
  grid on;zoom; 
  xlabel('oslon');ylabel('oslat')
  title(Cruise)
  set(gcf,'paperor','land')
  setlargefig
end

w2o_spotoutliers
error('MANUAL RUN FROM HERE. SEND THE FOLLOWING COMMANDS')
%VISUAL CHECK
gis=[56 83];
w2o_checkstat

%OPTIONAL STATION ORDERING CHANGE (NOT USABLE RIGHT NOW)
%   gisel=[1:80,91:-1:82,81];
%   w2o_statsel

%
%w2o_saveobsfile
diary off
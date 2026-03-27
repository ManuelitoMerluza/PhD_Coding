% Portion of woce2obs.m to be run
% after manually loading rwbstep3.mat

%load rwbstep3.mat

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
  s10=input('print ? ','s');if s10=='y',print -Pgraphics,end

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
gis=[7 ];
w2o_checkstat

%OPTIONAL STATION ORDERING CHANGE (NOT USABLE RIGHT NOW)
%   gisel=[1:80,91:-1:82,81];
%   w2o_statsel

%
w2o_saveobsfile
diary off
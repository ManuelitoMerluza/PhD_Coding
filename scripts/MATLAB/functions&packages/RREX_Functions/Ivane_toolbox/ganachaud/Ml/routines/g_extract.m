% script g_extract
%key: turn the original station data into as subset of those data
%synopsis : g_extract
% IN: Gis2do= indice of the stations defineing the subset
%     Subsecname= name of the subset
% 					
% I/O: the following data, that are turned into their subset
%
%Remarks            :-
%Nstat              :# of stations
%Slat Slon(Nstat)   :locations
%Botp(Nstat)        :bottom depths
%Maxd(Nstat,Nprop)  :index of deepest measurement
%Ship Cast 
%Xdep               :depths to the deepst measurement for each station
%Kt                 :record number (not usefull at the moment)
%Nobs               :# of observations
%
%description : 
%
%
%
%
%uses :
%
%side effects : 
%
%author : A.Ganachaud (ganacho@gulf.mit.edu) , Oct 95
%
%see also : geovel.m g_choose_stat.m
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Remarks=[Remarks,'; This is a subset of ' Secname];
Nstat=length(Gis2do);
Slat=Slat(Gis2do);
Slon=Slon(Gis2do);
Botp=Botp(Gis2do);
Maxd=Maxd(Gis2do,:);

na=NaN*ones(size(Gis2do));
if exist('Cast')
  Stnnbr=Cast(Gis2do);
else
  Stnnbr=Stnnbr(Gis2do);
end
if exist('Ship')
  Ship=Ship(Gis2do);
else
  Ship=na;
end
if exist('Xdep')&~isempty(Xdep)
  Xdep=Xdep(Gis2do);
else
  Xdep=na;
end
if exist('Kt')&~isempty(Kt)
  Kt=Kt(Gis2do);
else
  Kt=na;
end
if exist('Nobs')
  Nobs=Nobs(Gis2do);
else
  Nobs=na;
end
if exist('Eta')
  Eta=Eta(Gis2do);
else
  Eta=na;
end

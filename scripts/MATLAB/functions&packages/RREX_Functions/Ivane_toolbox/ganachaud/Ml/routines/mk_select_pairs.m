%function mk_select_pairs
%KEY: select a subset of pairs from the section
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
%
% OUTPUT:
%
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , Aug 98
%
% SIDE EFFECTS :
%
% SEE ALSO :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER:
% CALLEE:
if any(diff(gip2select)~=1)
  error('Selected pairs must be continuous')
end
Nstat=length(gip2select)+1;
gip2select=gip2select(:);
gis2select=[gip2select;max(gip2select)+1];
Nstat=length(gis2select);

Slat=Slat(gis2select);
Slon=Slon(gis2select);
Botp=Botp(gis2select);
Maxd=Maxd(gis2select,:);

na=NaN*ones(size(gis2select));
if exist('Cast')
  Stnnbr=Cast(gis2select);
else
  Stnnbr=Stnnbr(gis2select);
end
if exist('Ship')
  Ship=Ship(gis2select);
else
  Ship=na;
end
if exist('Xdep')&~isempty(Xdep)
  Xdep=Xdep(gis2select);
else
  Xdep=na;
end
if exist('Kt')&~isempty(Kt)
  Kt=Kt(gis2select);
else
  Kt=na;
end
if exist('Nobs')
  Nobs=Nobs(gis2select);
end

%Pair selection
Maxdp=Maxdp(gip2select,:);
Npair=Nstat-1;
Pbotp=Pbotp(gip2select);
Plat=Plat(gip2select);
Plon=Plon(gip2select);
Ptreat=Ptreat(gip2select);
svel=svel(gip2select);
gvel=gvel(:,gip2select);
for iprop=1:Nprop
  eval(['p' Propnm{iprop} '=p' Propnm{iprop} '(:,gip2select);'])
end

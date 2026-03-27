function laybound_test
% KEY: test for laybound program
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
%
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , Jul 97
%
% SIDE EFFECTS :
%
% SEE ALSO :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER:
% CALLEE:
secid='a36n'
datadir='/data1/ganacho/HDATA/';
getpdat

%LEVELS OF NEUTRAL DENSITY LAYER INTERFACES:
glevels = [22 26.44 26.85 27.162 27.38 27.62 27.82 27.922 27.975 28.008, ...
    28.044 28.072 28.0986 28.112 28.1295 28.141 28.154 48];

%NEUTRAL DENSITY COMPUTATION FOR ALL POINTS
disp('COMPUTING NEUTRAL DENSITY ...')
tic;[pgamn,dgl,dgh] = gamman(psali,ptemp,Pres,Plon,Plat);toc
disp('DONE')

%FIND DEPTHS OF THE INTERFACES
lipres = getsigpres(Pres,Pdep,Maxdp(:,Itemp),pgamn,glevels);
%lipres(ip,il) contains the interface il depth (dB), pair ip
Nlay=size(lipres,2);
lidep=sw_dpth(lipres,Plat*ones(1,Nlay));
Botdep=sw_dpth(Botd,Slat);
nd=length(Pres);
Dep    =sw_dpth(Pres(:,1)*ones(1,Npair),ones(nd,1)*(Plat'));

Sdist=sw_dist(Slat,Slon,'km');

%GET AREA IN EACH CELL
larea=integlay(lidep,ones(Npair,Nlay),Dep,ones(nd,Npair),...
  Sdist,Botdep);

%DENSITY
prhoi = sw_dens(psali,ptemp,Pres);
lirhoi=getsigprop(Pres,prhoi,Pdep,lipres);
lrhoi =integlay(lidep,lirhoi,Dep,prhoi,Sdist,Botdep);
lrhoi2=integlay(lidep,lirhoi.^2,Dep,prhoi.^2,Sdist,Botdep);

MASS=1;isec=1;
[laybs,lays]=laybound(Slat,Slon,lidep,larea,lirhoi,lrhoi,lrhoi2);

%SILICA
lisili=getsigprop(Pres,psili,Pdep,lipres);
lsili =integlay(lidep,lisili,Dep,psili,Sdist,Botdep);
lsili2=integlay(lidep,lisili.^2,Dep,psili.^2,Sdist,Botdep);
[laybs,lays]=laybound(Slat,Slon,lidep,larea,lisili,lsili,lsili2);

plt_prop(psili, 'sili','\mu mol.kg^{-1}' , ...
    Cruise, Pres, Maxd, Botd, Slat, Slon)
dpt =(0.5*Sdist(1) + [1; cumsum(0.5*...
     (Sdist(1:Nstat-2)+Sdist(2:Nstat-1)))]);
ch=get(gcf,'child');
axes(ch(2));
hold on
[c,h]=contour(dpt,-Pres,pgamn,glevels);
clabel(c,h)
for ih=1:length(h)
  set(h(ih),'LineWidth',1.5)
end
set(gcf,'papero','land');setlargefig

lays.lprop

laybs

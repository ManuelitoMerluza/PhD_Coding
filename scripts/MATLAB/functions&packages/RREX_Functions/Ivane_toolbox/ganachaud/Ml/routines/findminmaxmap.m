function [iminlon,imaxlon,iminlat,imaxlat,precis]=findminmaxmap(lon,lat);
% Find nice boundaries for a map
% Adapted from P. Grimigni TSG software
% A. Ganachaud Aug 2006
maxlon=max(max(lon));
minlon=min(min(lon));
maxlat=max(max(lat));
minlat=min(min(lat));



if (maxlon-minlon)>80 | (maxlat-minlat)>30
    precis=0;
else
    precis=1;
end

if (maxlon-minlon)>240
    imaxlat=60;
    iminlat=-50;
    imaxlon=360;
    iminlon=0;    
elseif  (maxlat-minlat) > (maxlon-minlon)/2.5     
    imaxlat=maxlat+(maxlat-minlat)/10;
    iminlat=minlat-(maxlat-minlat)/10;
    a=imaxlat-iminlat;
%    delta=(4*a - maxlon + minlon)/2;
% Modif A. Ganachaud pour Frontalis
    delta=(4*a - maxlon + minlon)/10;
    imaxlon=maxlon+delta;
    iminlon=minlon-delta;       
else
    delta=maxlon-minlon;
    if delta<0.05
        delta=8;
    end
    imaxlon=maxlon+delta/10;
    iminlon=minlon-delta/10;
    b=imaxlon-iminlon;
    delta=(b/4 - maxlat + minlat)/2;
    imaxlat=maxlat+delta;
    iminlat=minlat-delta;
end
    

function [dept]=sandepth(lat0,lon0);
% get the depths at a given location (nearest topographic grid point to the
% south-west
% author: Alexandre Ganachaud 
% October 2006
topofile='E:/Topography/smith_sandwell_topo_v8_2.nc';
if ~exist(topofile)
  topofile='/local/Topography/smith_sandwell_topo_v8_2.nc';
end  
%inqnc(topofile)
%.01667E -> 359.9833E
%72.0009S -> 72.0009N
lat=getnc(topofile,'latitude');
lon=getnc(topofile,'longitude');
%lon0=166.0005
%lat0=-23.00
ilon=min(find(lon>=lon0));
ilat=min(find(lat>=lat0));
corner=[ilat,ilon];
end_point=corner;
stride=1; %every point
order=-1;
change_miss=2; %convert to NaN if nothing
dept = getnc(topofile, 'ROSE', corner, end_point, stride,order,change_miss);
%  new_miss, squeeze_it, rescale_opts);

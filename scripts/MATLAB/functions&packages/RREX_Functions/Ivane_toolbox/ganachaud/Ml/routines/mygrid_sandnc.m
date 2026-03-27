% Function MYGRID_SANDNC	Read bathymetry data from Sandwell Database
%      [dept,vlat,vlon] = mygrid_sand(region,res)
%
% program to get bathymetry from smith_sandwell_topo_v8_2.nc  (Smith and Sandwell bathymetry)
%  (values are even numbered if interpolated, odd-numbered if from a ship sounding)
% WARNING: change filename to the correct one for your machine
%						Alexandre Ganachaud
%	input:
%		region =[south north west east];
%               %.01667E -> 359.9833E
%                 72.0009S -> 72.0009N
%       resolution: 1= maxi, 2=every 2 points, etc
%	output:
%		image_data  
%                (for iopt = 1) - matrix of sandwell bathymetry/topography
%		vlat - vector of latitudes associated with image_data
%      		vlon - vector of longitudes
% 
function  [dept,vlat,vlon] = mygrid_sandnc(region,res)

topofile='E:/Topography/smith_sandwell_topo_v8_2.nc';
if ~exist(topofile)
    topofile='/local/Topography/smith_sandwell_topo_v8_2.nc';
end
%inqnc(topofile)
lat=getnc(topofile,'latitude');
lon=getnc(topofile,'longitude');
lat0=region(1);lat1=region(2);
ilat0=min(find(lat>=lat0));
ilat1=max(find(lat<=lat1));
lon0=region(3);lon1=region(4);
ilon0=min(find(lon>=lon0));
ilon1=max(find(lon<=lon1));
corner=[ilat0,ilon0];
end_point=[ilat1,ilon1];
stride=res; %every res point
order=-1;
change_miss=2; %convert to NaN if nothing
dept = getnc(topofile, 'ROSE', corner, end_point, stride,order,change_miss);
%  new_miss, squeeze_it, rescale_opts);
vlat=lat(ilat0:ilat1);
vlon=lon(ilon0:ilon1);

function ssh = sshgeost(lon,lat,vel,sens)
%key: sea surface height ssh deduced from th surface geostrophic velocity
%synopsis : ssh = sshgeost(lon,lat,vel,sens)
% lon, lat in degree: location of the measurements
% vel: geostrophic velocity, in cm/sec => ssh in cm
% sens: +1 = integration from West shore, -1=from East shore
% ssh = sea surface heigth
%
%description : 
% ssh is obtained by integration trapez, beginning at 0
%
%uses :
% scan_longitude.m
% fcoriolis.m
% distance.m
%
%side effects :
%
%author : A.Ganachaud, Apr 95
%
%see also :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global G
lon=scan_longitude(lon);	%prevent longitude discontinuity

len=length(vel);
ssh=zeros(len,1);
for i=2:len
  ssh(i)=ssh(i-1)+ sens*distance(lat(i-1),lon(i-1),lat(i),lon(i))* ...
	fcoriolis( (lat(i-1)+lat(i))./2 )./G .* ...
   	(vel(i-1)+vel(i))./2;
end

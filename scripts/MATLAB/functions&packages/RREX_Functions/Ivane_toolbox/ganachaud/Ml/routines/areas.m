function [spharea]=areas(lats,lons);
%% function [spharea]=areas(lats,lons);
%% areas.m calculates the area on Earth in m^2 of a polygon specified by 
%% corners with the latitude, longitude coordinates contained in 
%% "lat" and "lon" and in either clockwise or counterclockwise order
%% (for example, a triangle [lat1,lat2,lat3],[lon1,lon2,lon3])
%% NOTE: Interior angles MUST be less than 180 degrees.
%% Chris Holloway, 8/10/99, based on Nathan's program in Fourtran, areas.f

num=length(lats);
if num~=length(lons)
  error('Lengths of lats and lons Must Be Equal!')
end
if num<3
  error('Must Have at Least Three Points!')
end
rlat=lats*pi/180;
rlon=lons*pi/180;
angles=ones(num,3);
sphang=ones(num,1);

angles(1,1)=acos(sin(rlat(num))*sin(rlat(2))+ ...
  cos(rlat(num))*cos(rlat(2))*cos(rlon(num)-rlon(2)));
angles(1,2)=acos(sin(rlat(1))*sin(rlat(2))+ ...
  cos(rlat(1))*cos(rlat(2))*cos(rlon(1)-rlon(2)));
angles(1,3)=acos(sin(rlat(num))*sin(rlat(1))+ ...
  cos(rlat(num))*cos(rlat(1))*cos(rlon(num)-rlon(1)));

angles(num,1)=acos(sin(rlat(num-1))*sin(rlat(1))+ ...
  cos(rlat(num-1))*cos(rlat(1))*cos(rlon(num-1)-rlon(1)));
angles(num,2)=acos(sin(rlat(num))*sin(rlat(1))+ ...
  cos(rlat(num))*cos(rlat(1))*cos(rlon(num)-rlon(1)));
angles(num,3)=acos(sin(rlat(num-1))*sin(rlat(num))+ ...
  cos(rlat(num-1))*cos(rlat(num))*cos(rlon(num-1)-rlon(num)));

for i=2:num-1
  angles(i,1)=acos(sin(rlat(i-1))*sin(rlat(i+1))+ ...
    cos(rlat(i-1))*cos(rlat(i+1))*cos(rlon(i-1)-rlon(i+1)));
  angles(i,2)=acos(sin(rlat(i))*sin(rlat(i+1))+ ...
    cos(rlat(i))*cos(rlat(i+1))*cos(rlon(i)-rlon(i+1)));
  angles(i,3)=acos(sin(rlat(i-1))*sin(rlat(i))+ ...
    cos(rlat(i-1))*cos(rlat(i))*cos(rlon(i-1)-rlon(i)));
end

for i=1:num
  ss=0.5*sum(angles(i,:));
  sina=sqrt(sin(ss-angles(i,2))*sin(ss-angles(i,3))/...
    (sin(angles(i,2))*sin(angles(i,3))));
  sphang(i)=2*asin(sina);
end

r=6.3710*10^6;  %% Radius of Earth in m (change this for other sph.)
sumang=sum(sphang);
spharea=(sumang-(num-2)*pi)*(r^2);
  




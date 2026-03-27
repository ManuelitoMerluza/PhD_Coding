function azi = azimuth( lon1, lat1, lon2, lat2 )
% computes the azimuth from point 1 to point 2 
%synopsis : azi = azimuth( lon1, lat1, lon2, lat2 );
 
 % lon1, lon2 : longitude of each point
 % lat1, lat2 : latitudes
 % must be column vectors

%description : 
 
%uses : sublong.m

% side effects : restricted to small distances, NaN if same point 1, 2

% author : A.Ganachaud, Feb 95

%see also :

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

c=lat2-lat1;
b=sublong(lon2, lon1);

%if any( c == 0 & b == 0 ) error(['same-point azimuth, i=',...
%	int2str(find(c == 0 & b == 0))]); end

% degree conversion : *360./2./pi=57.2958

azi = 57.2958.*atan2(b,c);

% when the two points are the same

fff=find(c == 0 & b == 0);
azi(fff)=NaN.*ones(length(fff),1);
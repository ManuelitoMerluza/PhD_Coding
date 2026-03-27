function vel = geost_vel_1d( ssh, lon , lat )
% normal geostrophic velocity from sea level, 1d
% ssh in m -> vel in m/s

% uses sublon, fcoriolis

g = 9.81;
onedegree = 111194.929 ;	% meters/degree

n = length( lon );
diflon=zeros(n,1);
diflat=zeros(n,1);
difssh=zeros(n,1);

difssh(2:n-1) = (ssh(3:n)-ssh(1:n-2)) ./2;
difssh(1) = ssh(2) - ssh(1);
difssh(n) = ssh(n) - ssh(n-1);

diflon(2:n-1) = sublong( lon(3:n), lon(1:n-2) ) ./ 2;
diflon(1) = sublong( lon(2), lon(1) );
diflon(n) = sublong( lon(n), lon(n-1) );

diflat(2:n-1) = (lat(3:n)-lat(1:n-2)) ./2;
diflat(1) = lat(2) - lat(1);
diflat(n) = lat(n) - lat(n-1);

dist = onedegree .* sqrt( diflat.^2 + (diflon .* cos( lat.* pi./180 )).^2);

vel = g ./ fcoriolis(lat) .* difssh ./ dist;


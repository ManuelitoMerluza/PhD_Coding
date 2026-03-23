% Read variables (adjust names if your file uses different ones)
lat = double(ncread('etopo2.nc','y'));   % vector, degrees north
lon = double(ncread('etopo2.nc','x'));   % vector, degrees east (might be 0..360)
z   = double(ncread('etopo2.nc','z'));     % matrix (lat x lon) or (lon x lat) — check orientation

% Define target box
latmin = 50; latmax = 65;
lonmin = -40; lonmax = -20;  % W longitudes (negative)

% Ensure lon vector uses -180..180
if any(lon > 180)
    lon = lon;
    % convert to -180..180 for selection
    lon180 = lon;
    lon180(lon > 180) = lon(lon > 180) - 360;
else
    lon180 = lon;
end

% Find index ranges (allow inclusive bounds)
ilat = find(lat >= latmin & lat <= latmax);
ilon = find(lon180 >= lonmin & lon180 <= lonmax);

% Handle empty result
if isempty(ilat) || isempty(ilon)
    error('No grid points found in requested box. Check coordinate vectors and bounds.');
end

% Subset z. Common orientations:
% If size(z) = [numLon, numLat], transpose or index accordingly.
sz = size(z);
if isequal(sz, [numel(lat), numel(lon)]) || isequal(sz, [numel(lat), numel(lon), 1])
    zsub = z(ilat, ilon);
elseif isequal(sz, [numel(lon), numel(lat)]) || isequal(sz, [numel(lon), numel(lat), 1])
    zsub = z(ilon, ilat)';  % transpose to lat x lon
else
    % If z is 2D but orientation unknown, try common transpose
    zsub = z(ilat, ilon);
end

latsub = lat(ilat);
lonsub = lon180(ilon);

save('REXXBathymetry.mat','lonsub','latsub','zsub')
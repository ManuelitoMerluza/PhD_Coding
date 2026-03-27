function [rr,gwc] = extract_rossby_radius(latitude,longitude,filename)
% [rr,ps] = extract_rossby_radius(latitude,longitude);
% rr = baroclinic Rossby radius of deformation (km)
% ps = baroclinic gravity wave phase speed (m/s)
% latitude = vector of latitudes mx1
% longitude = vector of longitudes mx1
% if a filename is precised, the program also writes
% a text file called this name, with lines as
%   latitude longitude    rr    ps
%
% ex.:
%     [rr,gwc] = extract_rossby_radius(latstamoy,lonstamoy,'rossbyrad.txt');

rr_file = which('rossby_radius.nc');
if isempty(rr_file)
  warning('inputfile:not_found','rossby_radius.nc was not found in the paths');
  rr = latitude*nan;
  gwc = latitude*nan;
  return
end
ncload(rr_file);
%X_AXIS(X_AXIS>180) = X_AXIS(X_AXIS>180)-360;
LR(LR==-1) = NaN;
%LR2 = LR;
LR2 = fill_gaps(LR,2,1); %LR2(isfinite(LR)) = LR(isfinite(LR));
C(C==-1) = NaN;
C2 = fill_gaps(C,2,1); %LR2(isfinite(LR)) = LR(isfinite(LR));

long2 = longitude;
long2(longitude<0) = long2(longitude<0)+360;
%figure;pcolor(X_AXIS,Y_AXIS,C2);shading flat;colorbar;hold on; plot(long2,latitude,'k+');

rr  = interp2(X_AXIS,Y_AXIS,LR2,long2,latitude,'*linear');
gwc = interp2(X_AXIS,Y_AXIS,C2,long2,latitude,'*linear');

if nargin>2,
    fid = fopen(filename,'w');
    fprintf(fid,'%%Latitude  Longitude   LR(km)  gwc(m/s)\n');
    fprintf(fid,'%9.5f  %9.5f  %6.2f  %5.2f\n',[latitude longitude rr gwc]');
    fclose(fid);
end


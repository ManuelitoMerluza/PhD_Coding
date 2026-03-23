function [T1i,T2i,dx, dz,bottomi] = RREXInterpolation(T1,x1,pres1,bottom1,T2,x2,pres2,bottom2,variable,latlon)

% This function is used for interpolating 1 variable of both RREX
% cruises using a common grid
% THE FUNCTION ONLY WORKS WHEN LAT OR LON STAY POSITIVE OR NEGATIVE

% INPUT
%        T1:        Variable for RREX2015 (Temperature, Salinity, Density, Oxygen) [M1 x N1] 
%        T2:        Variable for RREX2017 (must be the same variable as T1)  [M2 x N2]  
%        x1:        Spatial Coordinate (latitude or longitude) [N1] 
%        pres1:     Pressure [M1 x N1] 
%        bottom1:   Depth of the bottom [N1]
%        variable:  Can be 1,2,3,4 (Temperature, Salinity, Density, Oxygen)
%        latlon:    indicates if the variable is latitude or longitude (either 'lat' or 'lon')

% OUTPUT
%        T1i:      Interpolated Variable for RREX2015  [Z x X] 
%        T2i:      Interpolated Variable for RREX2017  [Z x X]  
%        dx:       New Horizontal Cordinate [X] 
%        dz:       New Pressure Cordinate [Z] 
%        bottomi:  Interpolated Depth of the Bottom [X]

%% Convert from E-W, N-S to positive degrees

if latlon(3)=='n'
    % i1=x1<0; x1(i1)=x1(i1)+360;
    xstr='Longitude';
elseif latlon(3)=='t'
    % i1=x1<0; x1(i1)=x1(i1)+180;
    xstr='Latitude';
end


%% Preparing the variables for interpolation

% Finds the x coordinate that starts and ends the new dx variable
aux1=min([min(x1),min(x2)]); aux2=max([max(x1),max(x2)]);

% Makes a latitudinal vector with a step of 0.1deg
dx=round(aux1,1):0.1:round(aux2,1);

% The same for the z axis (pressure)
aux3=max([max(max(pres1)),max(max(pres2))]);

% Makes a depth vector with a step of 1 dbar
dz=0:1:aux3;

% Merges both bottoms
x=[x1;x2]; bottom=[bottom1;bottom2];
[x,aux4]=unique(x); bottom=bottom(aux4);

% Interpolates the bottom
bottomi = interp1(x, bottom, dx, 'linear', 'extrap');

% Makes a 2D latitude for the interpolation
[M1,~]=size(T1); x1_2D=repmat(x1',M1,1);

[M2,~]=size(T2); x2_2D=repmat(x2',M2,1);

% Convert everything to vectors
x1_vec = x1_2D(:);
pres1_vec = pres1(:);
T1_vec = T1(:);

x2_vec = x2_2D(:);
pres2_vec = pres2(:);
T2_vec = T2(:);

% Remove any NaN if present
valid_idx = ~isnan(T1_vec) & ~isnan(x1_vec) & ~isnan(pres1_vec);
x1_vec = x1_vec(valid_idx);
pres1_vec = pres1_vec(valid_idx);
T1_vec = T1_vec(valid_idx);

valid_idx = ~isnan(T2_vec) & ~isnan(x2_vec) & ~isnan(pres2_vec);
x2_vec = x2_vec(valid_idx);
pres2_vec = pres2_vec(valid_idx);
T2_vec = T2_vec(valid_idx);

%% Interpolation

% Create interpolant
F1 = scatteredInterpolant(x1_vec, pres1_vec, T1_vec, 'linear', 'boundary');
F2 = scatteredInterpolant(x2_vec, pres2_vec, T2_vec, 'linear', 'boundary');

% Target grid
[dX, dZ] = meshgrid(dx,dz);

% Interpolate
T1i = F1(dX, dZ); T2i = F2(dX, dZ);

%% Bathymetry mask

% Create pressure grid (same size as Ti1=Ti2)
pres_grid = repmat(dz', 1, length(dx));

% Create mask
mask = pres_grid <= repmat(bottomi,length(dz),1); % True where above seafloor

% Apply mask
T1i(~mask) = NaN; T2i(~mask) = NaN;

%% Makes a Figure Depending on the Variable type (1-4)
% 
% figure('Position', [100, 100, 1600, 500]);
% 
% ax1=subplot(1,3,1);
% pcolor(dx, dz, T1i);
% shading flat;
% set(gca, 'YDir', 'reverse');
% clim([min(T1_vec), max(T1_vec)]);
% colorbar;
% xlabel(xstr); ylabel('Pressure');
% title('2015');
% hold on; area(dx,bottomi,5000,'facecolor',[0.6 0.6 0.6],'edgecolor','k'); hold off 
% 
% ax2=subplot(1,3,2);
% pcolor(dx, dz, T2i);
% shading flat;
% set(gca, 'YDir', 'reverse');
% clim([min(T1_vec), max(T1_vec)]);
% colorbar;
% xlabel(xstr); ylabel('Pressure');
% title('2017');
% hold on; area(dx,bottomi,5000,'facecolor',[0.6 0.6 0.6],'edgecolor','k'); hold off 
% 
% ax3=subplot(1,3,3);
% pcolor(dx, dz, T2i-T1i);
% shading flat;
% set(gca, 'YDir', 'reverse');
% clim([-3 3]);
% colorbar;
% xlabel(xstr); ylabel('Pressure');
% title('2017 - 2015');
% hold on; area(dx,bottomi,5000,'facecolor',[0.6 0.6 0.6],'edgecolor','k'); hold off 
% 
% if variable==1
%     colormap(ax1,slanCM('turbo'));
%     colormap(ax2,slanCM('turbo'));
%     colormap(ax3,slanCM('vik'));
%     sgtitle('RREX Interpolated \theta [°C]','FontSize',16, 'FontWeight', 'bold','FontName','LMRoman10')
%     clim(ax1,[2 10]); clim(ax2,[2 10]);clim(ax3,[-1.5 1.5]);
% elseif variable==2
%     colormap(ax1,slanCM('haline'));
%     colormap(ax2,slanCM('haline'));
%     colormap(ax3,slanCM('delta'));
%     sgtitle('RREX Interpolated Salinity [PSU]','FontSize',16, 'FontWeight', 'bold','FontName','LMRoman10')
%     clim(ax1,[34.6 35.2]); clim(ax2,[34.6 35.2]);clim(ax3,[-0.2 0.2]);
% elseif variable==3
%     colormap(ax1,slanCM('gnuplot2'));
%     colormap(ax2,slanCM('gnuplot2'));
%     colormap(ax3,slanCM('PuOr'));
%     sgtitle('RREX Interpolated \sigma_0 [kg/m^3]','FontSize',16, 'FontWeight', 'bold','FontName','LMRoman10')
%     clim(ax1,[27.4 28]); clim(ax2,[27.4 28]);clim(ax3,[-0.15 0.15]);
% elseif variable==4
%     colormap(ax1,slanCM('jet'));
%     colormap(ax2,slanCM('jet'));
%     colormap(ax3,slanCM('coolwarm'));
%     sgtitle('RREX Interpolated DO [\mumol/kg]','FontSize',16, 'FontWeight', 'bold','FontName','LMRoman10')
%     clim(ax1,[240 300]); clim(ax2,[240 300]); clim(ax3,[-25 25]);
% 
% end

end
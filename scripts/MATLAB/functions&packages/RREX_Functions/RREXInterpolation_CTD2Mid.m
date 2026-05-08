function [T1i pres_grid pres_bottom] = RREXInterpolation_CTD2Mid(T1,x1,pres1,x2,pres2,bottom2,latlon)

% This function is used for interpolating CTD variables into their
% middlepoint, AKA into their velocity coordiantes (using as reference)

% INPUT
%        T1:        Variable for RREX (Temperature, Salinity...) [M1 x N1] 
%        x1:        Spatial Coordinate (latitude or longitude) [N1] 
%        pres1:     Pressure [M1 x N1] 
%        x2,pres2:  Grid points for interpolation [X], [Z]
%        bottom2:   Bottom of the velocity profiles used for masking
%                   interpolated values
%        latlon:    indicates if the variable is latitude or longitude (either 'lat' or 'lon')

% OUTPUT
%        T1i:      Interpolated Variable for RREX  [Z x X] 


%% Convert from E-W, N-S to positive degrees

if latlon(3)=='n'
    % i1=x1<0; x1(i1)=x1(i1)+360;
    xstr='Longitude';
elseif latlon(3)=='t'
    % i1=x1<0; x1(i1)=x1(i1)+180;
    xstr='Latitude';
end


%% Preparing the variables for interpolation

dx=x2; dz=pres2;
bottomi = bottom2;

% Makes a 2D latitude for the interpolation
[M1,~]=size(T1); x1_2D=repmat(x1',M1,1);

% Convert everything to vectors
x1_vec = x1_2D(:);
pres1_vec = pres1(:);
T1_vec = T1(:);

% Remove any NaN if present
valid_idx = ~isnan(T1_vec) & ~isnan(x1_vec) & ~isnan(pres1_vec);
x1_vec = x1_vec(valid_idx);
pres1_vec = pres1_vec(valid_idx);
T1_vec = T1_vec(valid_idx);


%% Interpolation

% Create interpolant
F1 = scatteredInterpolant(x1_vec, pres1_vec, T1_vec, 'linear');

% Target grid
[dX, dZ] = meshgrid(dx,dz);

% Interpolate
T1i = F1(dX, dZ);

%% Bathymetry mask

% Create pressure grid (same size as Ti1=Ti2)
pres_grid = repmat(dz, 1, length(dx));
pres_bottom= repmat(bottomi,length(dz),1);

figure()
pcolor(dx,dz,T1i); shading interp
set(gca,'ydir','reverse')

% Create mask
mask = pres_grid <= pres_bottom; % True where above seafloor

% Apply mask
T1i(~mask) = NaN;

figure()
pcolor(dx,dz,T1i); shading interp
set(gca,'ydir','reverse')

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
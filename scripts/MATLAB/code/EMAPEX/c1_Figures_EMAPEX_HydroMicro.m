% This is the script for plotting both the hydrography and microstructure EMAPEX data

% We load paths and colorbars
addpath(genpath('C:/Users/mitg1n25/Desktop/PhD/Year 1 - 2026'))
%addpath(genpath('D:/Respaldo PC/iop/materia/Magister/Semestre 2/PRODIGY/m_map/'))
set(0, 'DefaultAxesFontSize', 12);
set(0, 'DefaultAxesTitleFontSizeMultiplier', 1.15)

b={'4969' '4971' '7802' '7806' '7807' '7808'};

map = load('colormap_RREX.mat'); % colormap(map.cmap);
load EMAPEXBathymetry.mat

%% Loads interpolated data

load('EMAPEX_Hydrography_Interpolated.mat')
load('EMAPEX_Microstructure_Interpolated.mat')

%% Calculates neutral density


% name.b1= sprintf('gamman_%s', b{1});
% name.b2= sprintf('gamman_%s', b{2});
% name.b3= sprintf('gamman_%s', b{3});
% name.b4= sprintf('gamman_%s', b{4});
% name.b5= sprintf('gamman_%s', b{5});
% name.b6= sprintf('gamman_%s', b{6});
% namecell=struct2cell(name);
% 
% for i=1:length(b)
%     T=dynamicvariable('T_in_',b{i});
%     S=dynamicvariable('S_in_',b{i});
%     P=dynamicvariable('P_in_',b{i});
%     lat=dynamicvariable('lat_hydro_',b{i});
%     lon=dynamicvariable('lon_hydro_',b{i});
%     lat2d=repmat(lat,length(depth),1);
%     lon2d=repmat(lon,length(depth),1);
%     gamman=eos80_legacy_gamma_n(S,T,P,lon2d,lat2d);
% 
%     EMAPEX_gamman.(namecell{i}) = gamman;
% end
% 
% save('EMAPEX_gamman.mat', '-struct' , 'EMAPEX_gamman')

%% Calculates Absolute Salinity and Potential Temperature

% name.b1= sprintf('SA_%s', b{1});
% name.b2= sprintf('SA_%s', b{2});
% name.b3= sprintf('SA_%s', b{3});
% name.b4= sprintf('SA_%s', b{4});
% name.b5= sprintf('SA_%s', b{5});
% name.b6= sprintf('SA_%s', b{6});
% namecellSA=struct2cell(name);
% 
% name.b1= sprintf('theta_%s', b{1});
% name.b2= sprintf('theta_%s', b{2});
% name.b3= sprintf('theta_%s', b{3});
% name.b4= sprintf('theta_%s', b{4});
% name.b5= sprintf('theta_%s', b{5});
% name.b6= sprintf('theta_%s', b{6});
% namecellPT=struct2cell(name);
% 
% for i=1:length(b)
%     T=dynamicvariable('T_in_',b{i});
%     S=dynamicvariable('S_in_',b{i});
%     P=dynamicvariable('P_in_',b{i});
%     lat=dynamicvariable('lat_hydro_',b{i});
%     lon=dynamicvariable('lon_hydro_',b{i});
%     lat2d=repmat(lat,length(depth),1);
%     lon2d=repmat(lon,length(depth),1);
%     SA = gsw_SA_from_SP(S,P,lon2d,lat2d);
%     theta = gsw_pt0_from_t(SA,T,P);
%     EMAPEX_Theta_SA.(namecellSA{i}) = SA;
%     EMAPEX_Theta_SA.(namecellPT{i}) = theta;
% end
% 
% save('EMAPEX_Theta_SA.mat', '-struct' , 'EMAPEX_Theta_SA')


%% Load neutral density, potential temperature and absolute salinity

load EMAPEX_gamman.mat
load EMAPEX_Theta_SA.mat

%% Plot figures for each float

% Define the variable name for my struct
name.b1= 'T'; name.b2= 'S'; name.b3= 'gamman';
name.b4= 'chi'; name.b5= 'u'; name.b6= 'v';
namecell=struct2cell(name);

% Make vectors and text with lenght six for each variable
tit = {'Temperature [C]'; 'Salinity [PSU]'; '\gamma_n [kg/m^3]'; '\chi_\theta [K^2/s]'; 'u [cm/s]'; 'v [cm/s]'};
lim=[2 15; 34.8 35.4; 27 28; 1e-10 1e-7; -15 15; -15 15];
colorpallet={'turbo','haline','gnuplot2','plasma','bwr','bwr'};

for i=4%:length(b) 

figure(i) % One figure for every float
set(gcf,'Position',[20, 20, 1500, 900])

    aux.T=dynamicvariable('T_in_',b{i}); % Store each variable in a struct
    aux.S=dynamicvariable('S_in_',b{i});
    aux.gamman=dynamicvariable('gamman_',b{i});
    aux.chi=dynamicvariable('chi_in_',b{i});
    aux.u=dynamicvariable('u_in_',b{i})*100;
    aux.v=dynamicvariable('v_in_',b{i})*100;
    time=dynamicvariable('time_hydro_',b{i});
    for j=1:6 
        ax=subplot(2,3,j); % One subplot for each variable
        pcolor(time,depth,aux.(namecell{j})); shading flat; 
        if j==4
            set(gca,'ColorScale','log'); % Consider the logscale for chi
        else
            set(gca,'ColorScale','linear'); % Normal for other variables
        end
        colorbar; clim(lim(j,:)); colormap(ax,slanCM(colorpallet{j}));
        ylim([-1200 0]); % set(gca,'YDir','reverse'); 
        title(tit{j});
    end
    sgtitle(['float',b{i}]);

    % saveas(gcf,['c1_float_',b{i},'TimeSeries.png']) % Save figure

end

%% Plot the position for each float


% % Plot scatter directly on same axes
% colors = {'red', 'green', 'blue', 'cyan', 'magenta', 'yellow'};
% sc = gobjects(length(b), 1);
% 
% for i = 1:length(b)
% 
%     figure(i); 
%     set(gcf, 'Position', [100, 100, 925, 575]);
% 
%     % Single axes
%     ax = axes('Position', [0.07, 0.12, 0.86, 0.78]);
% 
%     % Plot pcolor
%     pcolor(ax, lonsub, latsub, zsub); 
%     shading(ax, 'flat');
%     colormap(ax, map.cmap);
%     caxis(ax, [-4500, 500]);
%     xlim([-37 -7])
%     ylim([55 65])
%     hold(ax, 'on');
%     colorbar
%     title(['Float ',b{i}])
% 
% 
%     lat_vals = dynamicvariable('lat_micro_', b{i});
%     lon_vals = dynamicvariable('lon_micro_', b{i});
% 
%     sc(i) = scatter(ax, lon_vals, lat_vals, 80, ... 
%                    colors{i}, 'filled', 's', ...
%                    'MarkerEdgeColor', 'k', ...
%                    'LineWidth', 2, ...
%                    'MarkerFaceAlpha', 0.9);
% 
%      hold(ax, 'off');
%      xlabel(ax, 'Longitude'); 
%      ylabel(ax, 'Latitude');
% 
%      % Add grid for reference
%      grid(ax, 'on');
%      grid(ax, 'minor');
% 
%     % saveas(gcf,['c1_float_',b{i},'_Position.png']) % Save figure
% end

%% Create file for calculating diapycnal/total contribution using the jupyter notebook

OUTPUT.chi=chi_in_7806(:,1:206);
OUTPUT.salinity=S_in_7806(:,1:206);
OUTPUT.theta=theta_7806(:,1:206);
OUTPUT.temperature=T_in_7806(:,1:206);
OUTPUT.gamman=gamman_7806(:,1:206);
OUTPUT.latitude=lat_micro_7806(:,1:206);
OUTPUT.longitude=lon_micro_7806(:,1:206);
OUTPUT.pressure=P_in_7806(:,1:206);
OUTPUT.depth=depth;
OUTPUT.time=datevec(time_micro_7806(1:206));

save('EMAPEX_DataForNotebook_7806.mat', '-struct' , 'OUTPUT')

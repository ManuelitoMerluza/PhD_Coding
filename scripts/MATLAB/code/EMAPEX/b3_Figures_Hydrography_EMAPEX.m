% This is the script for plotting the hydrography EMAPEX data

% We load paths and colorbars
addpath(genpath('C:/Users/mitg1n25/Desktop/PhD/Year 1 - 2026'))
%addpath(genpath('D:/Respaldo PC/iop/materia/Magister/Semestre 2/PRODIGY/m_map/'))
set(0, 'DefaultAxesFontSize', 12);
set(0, 'DefaultAxesTitleFontSizeMultiplier', 1.15)

b={'4969' '4971' '7802' '7806' '7807' '7808'};

map = load('colormap_RREX.mat'); % colormap(map.cmap);
load EMAPEXBathymetry.mat

%% Load the float data

for i=1:length(b)
    load(['EMAPEX_float',b{i},'_Hydrography_filtered.mat'])
end

%% I plot the bathymetry near the RREX region and the floar positions

figure(); 
set(gcf, 'Position', [100, 100, 925, 575]);

% Single axes
ax = axes('Position', [0.07, 0.12, 0.86, 0.78]);

% Plot pcolor
pcolor(ax, lonsub, latsub, zsub); 
shading(ax, 'flat');
colormap(ax, map.cmap);
caxis(ax, [-4500, 500]);
xlim([-37 -7])
ylim([55 65])
hold(ax, 'on');
colorbar

% Plot scatter directly on same axes
colors = {'red', 'green', 'blue', 'cyan', 'magenta', 'yellow'};
sc = gobjects(length(b), 1);

for i = 1:length(b)
    lat_vals = dynamicvariable('lat_', b{i});
    lon_vals = dynamicvariable('lon_', b{i});
    
    sc(i) = scatter(ax, lon_vals, lat_vals, 80, ... 
                   colors{i}, 'filled', 's', ...
                   'MarkerEdgeColor', 'k', ...
                   'LineWidth', 2, ...
                   'MarkerFaceAlpha', 0.9);
end

hold(ax, 'off');
xlabel(ax, 'Longitude'); 
ylabel(ax, 'Latitude');

% Add grid for reference
grid(ax, 'on');
grid(ax, 'minor');

legend(sc, b, 'Location', 'west');

%% Calculate a horizontal average by float

u_m=NaN(500,length(b));
v_m=NaN(500,length(b));
z_m=NaN(500,length(b));

for i=1:length(b)
    u=dynamicvariable('u_',b{i});
    v=dynamicvariable('v_',b{i});
    z=dynamicvariable('z_',b{i});
    [n,~]=size(u);
    u_m(1:n,i)=nanmean(u,2);
    v_m(1:n,i)=nanmean(v,2);
    z_m(1:n,i)=nanmean(z,2);
end
% chi_mm=movmean(chi_m,80,1); % 50 m moving mean
% eps_mm=movmean(eps_m,80,1); % 50 m moving mean
% KT_mm=movmean(KT_m,80,1); % 50 m moving mean
% z_mm=movmean(z_m,80,1); % 50 m moving mean

%% Plotting horizontal average

colors = {'red', 'green', 'blue', 'cyan', 'magenta', 'yellow'};

figure('Position',[20, 20, 900, 700])
subplot(1,2,1)
hold on
for i=1:length(b)
    plot(u_m(:,i)*100,z_m(:,i),'-b','LineWidth',1.5,'Color',colors{i})
end
hold off
ylim([-1200 0])
ylabel('Depth [m]'); title('Zonal')
xlabel('u [cm/s]');
grid on

subplot(1,2,2)
hold on
for i=1:length(b)
    plot(v_m(:,i)*100,z_m(:,i),'-b','LineWidth',1.5,'Color',colors{i})
end
hold off
legend(b)
ylim([-1200 0])
ylabel('Depth [m]'); title('Meridional')
xlabel('v [cm/s]');
grid on

%% Plotting each float

tit='Temperature [C]';
lim=[2 15]; % Temperature
figure('Position',[20, 20, 1200, 900])
for i=1:length(b)
    T=dynamicvariable('T_',b{i});
    [aux,~]=size(T);
    time=dynamicvariable('time_',b{i});
    time2d=repmat(time,aux,1);
    z=dynamicvariable('z_',b{i});
    subplot(2,3,i)
    pcolor(time2d,z,T);shading flat;
    colorbar; clim(lim); colormap('jet');
    ylim([-1200 0]); % set(gca,'YDir','reverse'); 
    xlabel('time')
    title(['float',b{i}]);
    sgtitle(tit)
end

tit='Salinity [PSU]';
lim=[34.8 35.4]; % Salinity
figure('Position',[20, 20, 1200, 900])
for i=1:length(b)
    S=dynamicvariable('S_',b{i});
    [aux,~]=size(S);
    time=dynamicvariable('time_',b{i});
    time2d=repmat(time,aux,1);
    z=dynamicvariable('z_',b{i});
    subplot(2,3,i)
    pcolor(time2d,z,S);shading flat;
    colorbar; clim(lim); colormap('jet');
    ylim([-1200 0]); % set(gca,'YDir','reverse'); 
    xlabel('time')
    title(['float',b{i}]);
    sgtitle(tit)
end

tit='Zonal Velocity u [cm/s]';
lim=[-15 15]; % u
figure('Position',[20, 20, 1200, 900])
for i=1:length(b)
    u=dynamicvariable('u_',b{i})*100;
    [aux,~]=size(u);
    time=dynamicvariable('time_',b{i});
    time2d=repmat(time,aux,1);
    z=dynamicvariable('z_',b{i});
    subplot(2,3,i)
    pcolor(time2d,z,u);shading flat;
    colorbar; clim(lim); colormap(slanCM('bwr'));
    ylim([-1200 0]); % set(gca,'YDir','reverse'); 
    xlabel('time')
    title(['float',b{i}]);
    sgtitle(tit)
end

tit='Meridional Velocity v [cm/s]';
lim=[-15 15]; % v
figure('Position',[20, 20, 1200, 900])
for i=1:length(b)
    v=dynamicvariable('v_',b{i})*100;
    [aux,~]=size(v);
    time=dynamicvariable('time_',b{i});
    time2d=repmat(time,aux,1);
    z=dynamicvariable('z_',b{i});
    subplot(2,3,i)
    pcolor(time2d,z,v);shading flat;
    colorbar; clim(lim); colormap(slanCM('bwr'));
    ylim([-1200 0]); % set(gca,'YDir','reverse'); 
    xlabel('time')
    title(['float',b{i}]);
    sgtitle(tit)
end

%% Interpolating every 2 meters


% name.b1= sprintf('chi_in_%s', b{1});
% name.b2= sprintf('chi_in_%s', b{2});
% name.b3= sprintf('chi_in_%s', b{3});
% name.b4= sprintf('chi_in_%s', b{4});
% name.b5= sprintf('chi_in_%s', b{5});
% name.b6= sprintf('chi_in_%s', b{6});
% namecell=struct2cell(name);
% 
% % Create a struct with the variables
% 
% d=flip(-1000:2:0)';
% 
% for i=1:length(b)
%     chi=dynamicvariable('chi_',b{i}); % Load the variables I'll work with
%     chi(chi>10^-5)=NaN;
%     [aux,~]=size(chi);
%     time=dynamicvariable('time_',b{i});
%     z=dynamicvariable('z_',b{i});
%     chi_in=NaN(length(d),length(time));
%     for p = 1:length(time)
%         % Create 2D interpolant for this pressure level
%         [z_uni, uni]=unique(z(:,p),'stable');
%         chi_uni=chi(uni,p);
%         flag=~isnan(z_uni); 
%         z_flag=z_uni(flag); % Make a flag to omit NaN Values
%         chi_flag=chi_uni(flag);
%         chi_in(:,p) = interp1(z_flag, chi_flag,d, 'linear');
%     end
% 
%     EMAPEX_IN.(namecell{i}) = chi_in; % Saving in on a struct variable
% 
% end
% 
% %% Plot interpolated values
% 
% 
% lim=[1e-10 1e-7];
% 
% figure('Position',[20, 20, 1500, 900])
% 
% for i=1:length(b)
%     chi=EMAPEX_IN.(namecell{i});
%     time=dynamicvariable('time_',b{i});
%     subplot(2,3,i)
%     pcolor(time,d,chi);shading flat;
%     set(gca,'ColorScale','log');
%     colorbar; clim(lim); colormap(slanCM('plasma'));
%     ylim([-1200 0]); % set(gca,'YDir','reverse'); 
%     xlabel('time')
%     title(['\chi float',b{i}]);
% end
% sgtitle('2 meter Interpolation')

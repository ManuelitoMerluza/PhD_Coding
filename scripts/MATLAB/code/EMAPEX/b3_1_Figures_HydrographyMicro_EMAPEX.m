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
    load(['EMAPEX_float',b{i},'_Hydrography_filtered_micro.mat'])
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
    lat_vals = dynamicvariable('lat_micro_', b{i});
    lon_vals = dynamicvariable('lon_micro_', b{i});
    
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
    u=dynamicvariable('u_micro_',b{i});
    v=dynamicvariable('v_micro_',b{i});
    z=dynamicvariable('z_micro_',b{i});
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
    T=dynamicvariable('T_micro_',b{i});
    [aux,~]=size(T);
    time=dynamicvariable('time_micro_',b{i});
    time2d=repmat(time,aux,1);
    z=dynamicvariable('z_micro_',b{i});
    subplot(2,3,i)
    pcolor(time2d,z,T);shading flat;
    colorbar; clim(lim); colormap('jet');
    ylim([-1200 0]); % set(gca,'YDir','reverse'); 
    title(['float',b{i}]);
end
sgtitle(tit)

tit='Salinity [PSU]';
lim=[34.8 35.4]; % Salinity
figure('Position',[20, 20, 1200, 900])
for i=1:length(b)
    S=dynamicvariable('S_micro_',b{i});
    [aux,~]=size(S);
    time=dynamicvariable('time_micro_',b{i});
    time2d=repmat(time,aux,1);
    z=dynamicvariable('z_micro_',b{i});
    subplot(2,3,i)
    pcolor(time2d,z,S);shading flat;
    colorbar; clim(lim); colormap('jet');
    ylim([-1200 0]); % set(gca,'YDir','reverse'); 
    title(['float',b{i}]);
    sgtitle(tit)
end

tit='Zonal Velocity u [cm/s]';
lim=[-15 15]; % u
figure('Position',[20, 20, 1200, 900])
for i=1:length(b)
    u=dynamicvariable('u_micro_',b{i})*100;
    [aux,~]=size(u);
    time=dynamicvariable('time_micro_',b{i});
    time2d=repmat(time,aux,1);
    z=dynamicvariable('z_micro_',b{i});
    subplot(2,3,i)
    pcolor(time2d,z,u);shading flat;
    colorbar; clim(lim); colormap(slanCM('bwr'));
    ylim([-1200 0]); % set(gca,'YDir','reverse'); 
    title(['float',b{i}]);
    sgtitle(tit)
end

tit='Meridional Velocity v [cm/s]';
lim=[-15 15]; % v
figure('Position',[20, 20, 1200, 900])
for i=1:length(b)
    v=dynamicvariable('v_micro_',b{i})*100;
    [aux,~]=size(v);
    time=dynamicvariable('time_micro_',b{i});
    time2d=repmat(time,aux,1);
    z=dynamicvariable('z_micro_',b{i});
    subplot(2,3,i)
    pcolor(time2d,z,v);shading flat;
    colorbar; clim(lim); colormap(slanCM('bwr'));
    ylim([-1200 0]); % set(gca,'YDir','reverse'); 
    title(['float',b{i}]);
    sgtitle(tit)
end

%% Interpolating every 2 meters


name.b1= sprintf('T_in_%s', b{1});
name.b2= sprintf('T_in_%s', b{2});
name.b3= sprintf('T_in_%s', b{3});
name.b4= sprintf('T_in_%s', b{4});
name.b5= sprintf('T_in_%s', b{5});
name.b6= sprintf('T_in_%s', b{6});
namecellT=struct2cell(name);

name.b1= sprintf('P_in_%s', b{1});
name.b2= sprintf('P_in_%s', b{2});
name.b3= sprintf('P_in_%s', b{3});
name.b4= sprintf('P_in_%s', b{4});
name.b5= sprintf('P_in_%s', b{5});
name.b6= sprintf('P_in_%s', b{6});
namecellP=struct2cell(name);

name.b1= sprintf('S_in_%s', b{1});
name.b2= sprintf('S_in_%s', b{2});
name.b3= sprintf('S_in_%s', b{3});
name.b4= sprintf('S_in_%s', b{4});
name.b5= sprintf('S_in_%s', b{5});
name.b6= sprintf('S_in_%s', b{6});
namecellS=struct2cell(name);

name.b1= sprintf('u_in_%s', b{1});
name.b2= sprintf('u_in_%s', b{2});
name.b3= sprintf('u_in_%s', b{3});
name.b4= sprintf('u_in_%s', b{4});
name.b5= sprintf('u_in_%s', b{5});
name.b6= sprintf('u_in_%s', b{6});
namecellu=struct2cell(name);

name.b1= sprintf('v_in_%s', b{1});
name.b2= sprintf('v_in_%s', b{2});
name.b3= sprintf('v_in_%s', b{3});
name.b4= sprintf('v_in_%s', b{4});
name.b5= sprintf('v_in_%s', b{5});
name.b6= sprintf('v_in_%s', b{6});
namecellv=struct2cell(name);

name.b1= sprintf('lat_hydro_%s', b{1});
name.b2= sprintf('lat_hydro_%s', b{2});
name.b3= sprintf('lat_hydro_%s', b{3});
name.b4= sprintf('lat_hydro_%s', b{4});
name.b5= sprintf('lat_hydro_%s', b{5});
name.b6= sprintf('lat_hydro_%s', b{6});
namecelllat=struct2cell(name);

name.b1= sprintf('lon_hydro_%s', b{1});
name.b2= sprintf('lon_hydro_%s', b{2});
name.b3= sprintf('lon_hydro_%s', b{3});
name.b4= sprintf('lon_hydro_%s', b{4});
name.b5= sprintf('lon_hydro_%s', b{5});
name.b6= sprintf('lon_hydro_%s', b{6});
namecelllon=struct2cell(name);

name.b1= sprintf('time_hydro_%s', b{1});
name.b2= sprintf('time_hydro_%s', b{2});
name.b3= sprintf('time_hydro_%s', b{3});
name.b4= sprintf('time_hydro_%s', b{4});
name.b5= sprintf('time_hydro_%s', b{5});
name.b6= sprintf('time_hydro_%s', b{6});
namecelltime=struct2cell(name);


% Create a struct with the variables

d=flip(-1000:2:0)';

for i=1:length(b)
    T=dynamicvariable('T_micro_',b{i}); % Load the variables I'll work with
    S=dynamicvariable('S_micro_',b{i});
    P=dynamicvariable('P_micro_',b{i});
    u=dynamicvariable('u_micro_',b{i});
    v=dynamicvariable('v_micro_',b{i});
    [aux,~]=size(T);
    time=dynamicvariable('time_micro_',b{i});
    z=dynamicvariable('z_micro_',b{i});
    T_in=NaN(length(d),length(time));
    P_in=NaN(length(d),length(time));
    S_in=NaN(length(d),length(time));
    u_in=NaN(length(d),length(time));
    v_in=NaN(length(d),length(time));
    for p = 1:length(time)
        % Create 2D interpolant for this pressure level
        [z_uni, uni]=unique(z(:,p),'stable'); % So we don't have repeating values at z
        T_uni=T(uni,p); S_uni=S(uni,p); u_uni=u(uni,p); v_uni=v(uni,p); P_uni=P(uni,p);
        flag=~isnan(z_uni); 
        z_flag=z_uni(flag); % Make a flag to omit NaN Values
        T_flag=T_uni(flag); S_flag=S_uni(flag);
        u_flag=u_uni(flag); v_flag=v_uni(flag);
        P_flag=P_uni(flag);
        if sum(flag)<2
            T_in(:,p)= T_in(:,p); S_in(:,p)= S_in(:,p);
            u_in(:,p)= u_in(:,p); v_in(:,p)= v_in(:,p);
        else
            T_in(:,p) = interp1(z_flag, T_flag,d, 'linear');
            S_in(:,p) = interp1(z_flag, S_flag,d, 'linear');
            P_in(:,p) = interp1(z_flag, P_flag,d, 'linear');
            u_in(:,p) = interp1(z_flag, u_flag,d, 'linear');
            v_in(:,p) = interp1(z_flag, v_flag,d, 'linear');
        end
    end

    EMAPEX_Hydro_IN.(namecellT{i}) = T_in; % Saving in on a struct variable
    EMAPEX_Hydro_IN.(namecellS{i}) = S_in;
    EMAPEX_Hydro_IN.(namecellu{i}) = u_in;
    EMAPEX_Hydro_IN.(namecellv{i}) = v_in;
    EMAPEX_Hydro_IN.(namecellP{i}) = P_in;
    EMAPEX_Hydro_IN.(namecelllat{i}) = dynamicvariable('lat_micro_',b{i});
    EMAPEX_Hydro_IN.(namecelllon{i}) = dynamicvariable('lon_micro_',b{i});
    EMAPEX_Hydro_IN.(namecelltime{i}) = dynamicvariable('time_micro_',b{i});
    EMAPEX_Hydro_IN.depth = d;

end

save('EMAPEX_Hydrography_Interpolated.mat', '-struct' , 'EMAPEX_Hydro_IN')

%% Plot interpolated values

tit='Temperature [C]';
lim=[2 15];

figure('Position',[20, 20, 1500, 900])
for i=1:length(b)
    T=EMAPEX_Hydro_IN.(namecellT{i});
    time=dynamicvariable('time_micro_',b{i});
    subplot(2,3,i)
    pcolor(time,d,T);shading flat;
    colorbar; clim(lim); colormap('jet');
    ylim([-1200 0]); % set(gca,'YDir','reverse'); 
    title(['float',b{i}]);
end
sgtitle(tit)
saveas(gcf,'11_TemperatureProfile_Interp.png')

tit='Salinity [PSU]';
lim=[34.8 35.4]; % Salinity

figure('Position',[20, 20, 1500, 900])
for i=1:length(b)
    S=EMAPEX_Hydro_IN.(namecellS{i});
    time=dynamicvariable('time_micro_',b{i});
    subplot(2,3,i)
    pcolor(time,d,S);shading flat;
    colorbar; clim(lim); colormap('jet');
    ylim([-1200 0]); % set(gca,'YDir','reverse'); 
    title(['float',b{i}]);
end
sgtitle(tit)
saveas(gcf,'12_SalinityProfile_Interp.png')

tit='Zonal Velocity u [cm/s]';
lim=[-15 15]; % v

figure('Position',[20, 20, 1500, 900])
for i=1:length(b)
    u=EMAPEX_Hydro_IN.(namecellu{i})*100;
    time=dynamicvariable('time_micro_',b{i});
    subplot(2,3,i)
    pcolor(time,d,u);shading flat;
    colorbar; clim(lim); colormap(slanCM('bwr'));
    ylim([-1200 0]); % set(gca,'YDir','reverse'); 
    title(['float',b{i}]);
end
sgtitle(tit)
saveas(gcf,'13_uProfile_Interp.png')

tit='Meridional Velocity v [cm/s]';
lim=[-15 15]; % v

figure('Position',[20, 20, 1500, 900])
for i=1:length(b)
    v=EMAPEX_Hydro_IN.(namecellv{i})*100;
    time=dynamicvariable('time_micro_',b{i});
    subplot(2,3,i)
    pcolor(time,d,v);shading flat;
    colorbar; clim(lim); colormap(slanCM('bwr'));
    ylim([-1200 0]); % set(gca,'YDir','reverse'); 
    title(['float',b{i}]);
end
sgtitle(tit)
saveas(gcf,'14_vProfile_Interp.png')

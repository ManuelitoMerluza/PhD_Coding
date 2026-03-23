% This is the script I'll use to filter out bad data from the EMAPEX floats
% that extracted previuosly and plot some figures to evaluate the data

% I'll use the data report as a reference for teh periods where floats
% worked correctly

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
    load(['EMAPEX_float',b{i},'_filtered.mat'])
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

chi_m=NaN(2000,length(b));
eps_m=NaN(2000,length(b));
KT_m=NaN(2000,length(b));
z_m=NaN(2000,length(b));

for i=1:length(b)
    chi=dynamicvariable('chi_',b{i});
    chi(chi>10^-5)=NaN;
    eps=dynamicvariable('eps_',b{i});
    KT=dynamicvariable('KT_',b{i});
    z=dynamicvariable('z_',b{i});
    [n,~]=size(chi);
    chi_m(1:n,i)=nanmean(chi,2);
    eps_m(1:n,i)=nanmean(eps,2);
    KT_m(1:n,i)=nanmean(KT,2);
    z_m(1:n,i)=nanmean(z,2);
end
chi_mm=movmean(chi_m,80,1); % 50 m moving mean
eps_mm=movmean(eps_m,80,1); % 50 m moving mean
KT_mm=movmean(KT_m,80,1); % 50 m moving mean
z_mm=movmean(z_m,80,1); % 50 m moving mean

clear chi eps z KT
%% Calculate vertical average for all data points

chi_r=NaN(343,length(b));
eps_r=NaN(343,length(b));
KT_r=NaN(343,length(b));

for i=1:length(b)
    chi=dynamicvariable('chi_',b{i});
    chi(chi>10^-5)=NaN;
    eps=dynamicvariable('eps_',b{i});
    KT=dynamicvariable('KT_',b{i});
    [~,m]=size(chi); %
    chi_r(1:m,i)=nanmean(chi,1);
    eps_r(1:m,i)=nanmean(eps,1);
    KT_r(1:m,i)=nanmean(KT,1);
end


%% Plotting horizontal average

colors = {'red', 'green', 'blue', 'cyan', 'magenta', 'yellow'};
lim=[1e-11 1e-5];
n=7; %number of ticks

figure('Position',[20, 20, 900, 700])
subplot(1,2,1)
hold on
for i=1:length(b)
    plot(chi_m(:,i),z_m(:,i),'-b','LineWidth',1.5,'Color',colors{i})
    ax=gca; ax.XScale='log';
end
hold off
xlim(lim); ylim([-1200 0])
xticks(ax, logspace(log10(lim(1)), log10(lim(2)), n));
ylabel('Depth [m]'); title('Raw Data')
xlabel('\chi [K^2/s]');
grid on

subplot(1,2,2)
hold on
for i=1:length(b)
    plot(chi_mm(:,i),z_mm(:,i),'-b','LineWidth',1.5,'Color',colors{i})
    ax=gca; ax.XScale='log';
end
hold off
legend(b)
xlim(lim); ylim([-1200 0])
xticks(ax, logspace(log10(lim(1)), log10(lim(2)), n));
ylabel('Depth [m]'); title('50 m Moving Average')
xlabel('\chi [K^2/s]');
grid on

%% Plotting each float

lim=[1e-10 1e-7];

figure('Position',[20, 20, 1200, 900])
for i=1:length(b)
    chi=dynamicvariable('chi_',b{i});
    chi(chi>10^-5)=NaN;
    [aux,~]=size(chi);
    time=dynamicvariable('time_',b{i});
    time2d=repmat(time,aux,1);
    z=dynamicvariable('z_',b{i});
    subplot(2,3,i)
    pcolor(time2d,z,chi);shading flat;
    set(gca,'ColorScale','log');
    colorbar; clim(lim); colormap(slanCM('plasma'));
    ylim([-1200 0]); % set(gca,'YDir','reverse'); 
    xlabel('time')
    title(['\chi float',b{i}]);
end

%% Plotting vertical average in the region

lim2  = [1e-9 1e-7];     % scatter caxis

% First plot the region with the colorbar using in the picture

figure(); set(gcf, 'Position',  [100, 100, 925, 575])
ax1 = axes('Position',[0.07 0.12 0.86 0.78]); % adjust margins
pcolor(lonsub,latsub,zsub); shading flat
colormap(ax1,map.cmap);%cb1= colorbar(ax1,'eastoutside'); caxis(ax1,[-4500 500]);
%title(cb1,{'Depth [m]',''}); % Move up by inserting a blank line
%cb1 = gca; cb1.FontSize = 13; 

% Now lets add the scatter plot

% Top axes: transparent for scatter (same position)
ax2 = axes('Position', ax1.Position);
ax2.Color = 'none';                      % transparent
ax2.XLim = ax1.XLim; ax2.YLim = ax1.YLim;
ax2.FontSize = 13;
hold(ax2,'on')

% Plot scatter on ax2
hold on
for i=1:length(b)
    aux=~isnan(chi_r(:,i));
    lat_vals = dynamicvariable('lat_', b{i});
    lon_vals = dynamicvariable('lon_', b{i});
    scatter(ax2, lon_vals(aux), lat_vals(aux), 75,chi_r(aux,i) , 'filled' ...
        , 'MarkerEdgeColor','k');
end 
hold off
set(ax2,'ColorScale','log');
colormap(ax2, slanCM('plasma'));   
caxis(ax2,lim2);
ax2.XTick = []; ax2.YTick = [];           % hide duplicate ticks if desired
xlabel(ax1,'Longitude'); ylabel(ax1,'Latitude');
linkaxes([ax1 ax2]) 
xlim([-37 -7])
ylim([55 65])

% saveas(gcf,'8_RegionXiEMAPEX_Filtered.png')

%% Plotting the colorbar for Xi

% The same for Xi
cmap1 = map.cmap;          % bathymetry colormap
lim1  = [-4500 500];      % bathymetry caxis
cmap2 = slanCM('plasma'); % scatter colormap
lim2  = [1e-9 1e-7];     % scatter caxis

% New figure sized for two colorbars side-by-side
fh = figure('Position',[100, 100, 1125, 675])

% Left colorbar (for scatter)
axL = axes(fh,'Position',[0.05 0.15 0.25 0.7],'Visible','off'); % invisible axes
set(axL,'ColorScale','log'); colormap(axL,cmap2);
caxis(axL,lim2);
cbL = colorbar(axL,'westoutside');    % place on left
cbL.Label.String = 'Mean \chi [K^2/s]';
cbL.Label.FontSize = 12;
cbL.TicksMode = 'auto';

% Right colorbar (for bathymetry)
axR = axes(fh,'Position',[0.55 0.15 0.25 0.7],'Visible','off');
colormap(axR,cmap1);
caxis(axR,lim1);
cbR = colorbar(axR,'eastoutside');    % place on right
cbR.Label.String = 'Depth [m]';
cbR.Label.FontSize = 12;

% Optional: tidy figure before saving
set(fh,'Color','w');

% saveas(gcf,'9_colorbars_region_Filtered.png')

%% Interpolating every 2 meters


name.b1= sprintf('chi_in_%s', b{1});
name.b2= sprintf('chi_in_%s', b{2});
name.b3= sprintf('chi_in_%s', b{3});
name.b4= sprintf('chi_in_%s', b{4});
name.b5= sprintf('chi_in_%s', b{5});
name.b6= sprintf('chi_in_%s', b{6});
namecell=struct2cell(name);

name.b1= sprintf('lat_micro_%s', b{1});
name.b2= sprintf('lat_micro_%s', b{2});
name.b3= sprintf('lat_micro_%s', b{3});
name.b4= sprintf('lat_micro_%s', b{4});
name.b5= sprintf('lat_micro_%s', b{5});
name.b6= sprintf('lat_micro_%s', b{6});
namecelllat=struct2cell(name);

name.b1= sprintf('lon_micro_%s', b{1});
name.b2= sprintf('lon_micro_%s', b{2});
name.b3= sprintf('lon_micro_%s', b{3});
name.b4= sprintf('lon_micro_%s', b{4});
name.b5= sprintf('lon_micro_%s', b{5});
name.b6= sprintf('lon_micro_%s', b{6});
namecelllon=struct2cell(name);

name.b1= sprintf('time_micro_%s', b{1});
name.b2= sprintf('time_micro_%s', b{2});
name.b3= sprintf('time_micro_%s', b{3});
name.b4= sprintf('time_micro_%s', b{4});
name.b5= sprintf('time_micro_%s', b{5});
name.b6= sprintf('time_micro_%s', b{6});
namecelltime=struct2cell(name);

% Create a struct with the variables

d=flip(-1000:2:0)';

for i=1:length(b)
    chi=dynamicvariable('chi_',b{i}); % Load the variables I'll work with
    chi(chi>10^-5)=NaN;
    [aux,~]=size(chi);
    time=dynamicvariable('time_',b{i});
    z=dynamicvariable('z_',b{i});
    chi_in=NaN(length(d),length(time));
    for p = 1:length(time)
        % Create 2D interpolant for this pressure level
        [z_uni, uni]=unique(z(:,p),'stable');
        chi_uni=chi(uni,p);
        flag=~isnan(z_uni); 
        z_flag=z_uni(flag); % Make a flag to omit NaN Values
        chi_flag=chi_uni(flag);
        chi_in(:,p) = interp1(z_flag, chi_flag,d, 'linear');
    end

    EMAPEX_Micro_IN.(namecell{i}) = chi_in; % Saving in on a struct variable
    EMAPEX_Micro_IN.(namecelllat{i}) = dynamicvariable('lat_',b{i});
    EMAPEX_Micro_IN.(namecelllon{i}) = dynamicvariable('lon_',b{i});
    EMAPEX_Micro_IN.(namecelltime{i}) = dynamicvariable('time_',b{i});
    EMAPEX_Micro_IN.depth = d;
end

save('EMAPEX_Microstructure_Interpolated.mat', '-struct' , 'EMAPEX_Micro_IN')

%% Plot interpolated values


lim=[1e-10 1e-7];

figure('Position',[20, 20, 1500, 900])

for i=1:length(b)
    chi=EMAPEX_IN.(namecell{i});
    time=dynamicvariable('time_',b{i});
    subplot(2,3,i)
    pcolor(time,d,chi);shading flat;
    set(gca,'ColorScale','log');
    colorbar; clim(lim); colormap(slanCM('plasma'));
    ylim([-1200 0]); % set(gca,'YDir','reverse'); 
    xlabel('time')
    title(['\chi float',b{i}]);
end
sgtitle('2 meter Interpolation')

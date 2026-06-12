% We load paths and colorbars
addpath(genpath('C:/Users/mitg1n25/Desktop/PhD/PhD_coding'))
set(0, 'DefaultAxesFontSize', 12);
set(0, 'DefaultAxesTitleFontSizeMultiplier', 1.15)
set(0, 'DefaultAxesFontName', 'LMRoman17');
set(0, 'DefaultAxesFontWeight', 'bold');
map = load('colormap_RREX.mat'); % colormap(map.cmap);
load REXXBathymetry.mat


% This is the script I'll use to plot the hydrography data of both RREX cruises

%% First, we load the variables 

folder='C:/Users/mitg1n25/Desktop/PhD/PhD_Coding/data/RREX/Hydrography';
filenames = dir(fullfile(folder,'*CTDO.nc')); % Check the variable position

lat2015=ncread(filenames(1).name,'LATITUDE');
lon2015=ncread(filenames(1).name,'LONGITUDE');
bottom2015=ncread(filenames(1).name,'BOTTOM_DEPTH');
pres2015=ncread(filenames(1).name,'PRES'); % Pressure
temp2015=ncread(filenames(1).name,'TEMP'); % In situ temperature
sal2015=ncread(filenames(1).name,'PSAL'); % Practical Salinity
oxy2015=ncread(filenames(1).name,'OXYK'); % Oxygen concentration in umol/kg
dens2015=ncread(filenames(1).name,'SIG0'); % Density anomaly referred to p=0
n2015=length(lat2015);

lat2017=ncread(filenames(2).name,'LATITUDE',2,inf);
lon2017=ncread(filenames(2).name,'LONGITUDE',2,inf);
bottom2017=ncread(filenames(2).name,'BOTTOM_DEPTH',2,inf);
pres2017=ncread(filenames(2).name,'PRES',[1 2],[inf inf]); % Pressure
temp2017=ncread(filenames(2).name,'TEMP',[1 2],[inf inf]); % In situ temperature
sal2017=ncread(filenames(2).name,'PSAL',[1 2],[inf inf]); % Practical Salinity
oxy2017=ncread(filenames(2).name,'OXYK',[1 2],[inf inf]); % Oxygen concentration in umol/kg
dens2017=ncread(filenames(2).name,'SIG0',[1 2],[inf inf]); % Density anomaly referred to p=0
n2017=length(lat2017);

%% Calculates potential temperature and absolute salinity

SA2015=gsw_SA_from_SP(sal2015,pres2015,lon2015,lat2015);
SA2017=gsw_SA_from_SP(sal2017,pres2017,lon2017,lat2017);

CT2015 = gsw_CT_from_t(SA2015,temp2015,pres2015);
CT2017 = gsw_CT_from_t(SA2017,temp2017,pres2017);

lati2015=repmat(lat2015',4449,1); loni2015=repmat(lon2015',4449,1);
gamma2015 = eos80_legacy_gamma_n(sal2015,temp2015,pres2015,loni2015,lati2015);

lati2017=repmat(lat2017',4340,1); loni2017=repmat(lon2017',4340,1);
gamma2017 = eos80_legacy_gamma_n(sal2017,temp2017,pres2017,loni2017,lati2017);

temp2015 = gsw_pt_from_t(SA2015,temp2015,pres2015);
temp2017 = gsw_pt_from_t(SA2017,temp2017,pres2017);

%% Calculates N2, the thermal and haline components of stratification

% I used 3 different methods for calculating the thermal and haline
% components.
% 1) I used a modifed version of the gsw_Nsquared function
%    called N2T and N2S.
% 2) I computed the terms manually using:
%    a) Finite diference method for derivatives
%    b) Gradient function for derivatives
% There are no major diferences between the methods, so I finally decided
% to plot the values calculated using gsw's framework

% 2015
[N2_2015, pmid2015]=gsw_Nsquared(SA2015,CT2015,pres2015,repmat(lat2015',4449,1)); % N2
[N2T_2015, ~]=N2T(SA2015,CT2015,pres2015,repmat(lat2015',4449,1)); % N2 Thermal Component
[N2S_2015, ~]=N2S(SA2015,CT2015,pres2015,repmat(lat2015',4449,1)); % N2 Haline Component

% 2017
[N2_2017, pmid2017]=gsw_Nsquared(SA2017,CT2017,pres2017,repmat(lat2017',4340,1));
[N2T_2017, ~]=N2T(SA2017,CT2017,pres2017,repmat(lat2017',4340,1)); % N2 Thermal Component
[N2S_2017, ~]=N2S(SA2017,CT2017,pres2017,repmat(lat2017',4340,1)); % N2 Haline Component

alpha2015=gsw_alpha(SA2015,CT2015,pres2015); % Thermal expansion
alpha2017=gsw_alpha(SA2017,CT2017,pres2017);
alpha2015diff=0.5*(alpha2015(1:end-1,:)+alpha2015(2:end,:)); % Same size as N2
alpha2017diff=0.5*(alpha2017(1:end-1,:)+alpha2017(2:end,:));

beta2015=gsw_beta(SA2015,CT2015,pres2015); % Haline contraction
beta2017=gsw_beta(SA2017,CT2017,pres2017);
beta2015diff=0.5*(beta2015(1:end-1,:)+beta2015(2:end,:)); % Same size as N2
beta2017diff=0.5*(beta2017(1:end-1,:)+beta2017(2:end,:)); 

z2015=gsw_z_from_p(pres2015,lat2015);
z2017=gsw_z_from_p(pres2017,lat2017);


% Prepares the variables used for calculation
g = 9.7963; % g aceleration ussed in gsw_Nsquated function
% You can choose between the difference of gradient method for derivation
Tz2015diff=NaN(size(pres2015)-1); Sz2015diff=NaN(size(pres2015)-1);
Dz2015diff=NaN(size(pres2015)-1);
Tz2015=NaN(size(pres2015)); Sz2015=NaN(size(pres2015)); Dz2015=NaN(size(pres2015));
for i=1:length(lat2015)
    Tz2015diff(:,i)=diff(CT2015(:,i))./diff(z2015(:,i)); % Vertical Temperature Gradient
    Sz2015diff(:,i)=diff(SA2015(:,i))./diff(z2015(:,i)); % Vertical Salinity Gradient
    Dz2015diff(:,i)=diff(dens2015(:,i))./diff(z2015(:,i)); % Density Gradient
    Tz2015(:,i)=gradient(CT2015(:,i),z2015(:,i)); 
    Sz2015(:,i)=gradient(SA2015(:,i),z2015(:,i)); 
    Dz2015(:,i)=gradient(dens2015(:,i),z2015(:,i)); 
end

Tz2017diff=NaN(size(pres2017)-1); Sz2017diff=NaN(size(pres2017)-1);
Dz2017diff=NaN(size(pres2017)-1);
Tz2017=NaN(size(pres2017)); Sz2017=NaN(size(pres2017)); Dz2017=NaN(size(pres2017));
for i=1:length(lat2017)
    Tz2017diff(:,i)=diff(CT2017(:,i))./diff(z2017(:,i)); % Vertical Temperature Gradient
    Sz2017diff(:,i)=diff(SA2017(:,i))./diff(z2017(:,i)); % Vertical Salinity Gradient
    Dz2017diff(:,i)=diff(dens2017(:,i))./diff(z2017(:,i)); % Vertical Salinity Gradient
    Tz2017(:,i)=gradient(CT2017(:,i),z2017(:,i));
    Sz2017(:,i)=gradient(SA2017(:,i),z2017(:,i));
    Dz2017(:,i)=gradient(dens2017(:,i),z2017(:,i));
end


% Computes the T and S components of N2
% Difference
thermal2015diff=g*(alpha2015diff.*Tz2015diff); thermal2017diff=g*(alpha2017diff.*Tz2017diff);
haline2015diff=-g*(beta2015diff.*Sz2015diff); haline2017diff=-g*(beta2017diff.*Sz2017diff);
% N22015diff=(g/1025)*Dz2015diff; N22017diff=(g/1025)*Dz2017diff; 
N22015diff=thermal2015diff+haline2015diff; N22017diff=thermal2017diff+haline2017diff;
% Gradient
thermal2015=g*(alpha2015.*Tz2015); thermal2017=g*(alpha2017.*Tz2017);
haline2015=g*(beta2015.*Sz2015); haline2017=g*(beta2017.*Sz2017);
%N22015=(g/1025)*Dz2015; N22017=(g/1025)*Dz2017; 
N22015=thermal2015+haline2015; N22017=thermal2017+haline2017;

%% First, we take a look at the amount of data to see how we can separate it in transects
% 
% % 2017
% figure(); set(gcf, 'Position',  [100, 100, 925, 575])
% ax1 = axes('Position',[0.07 0.12 0.86 0.78]); % adjust margins
% pcolor(lonsub,latsub,zsub); shading flat
% colormap(ax1,map.cmap);%cb1= colorbar(ax1,'eastoutside'); caxis(ax1,[-4500 500]);
% 
% % Now lets add the scatter plot
% 
% % Top axes: transparent for scatter (same position)
% ax2 = axes('Position', ax1.Position);
% ax2.Color = 'none';                      % transparent
% ax2.XLim = ax1.XLim; ax2.YLim = ax1.YLim;
% ax2.FontSize = 13;
% hold(ax2,'on')
% 
% hold on
% for i=1:n2017
%     numtext=num2str(i);
% 
% % Plot scatter on ax2
% s = text(ax2, lon2017(i), lat2017(i), numtext, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
% set(ax2,'ColorScale','log'); 
% ax2.XTick = []; ax2.YTick = [];           % hide duplicate ticks if desired
% xlabel(ax1,'Longitude'); ylabel(ax1,'Latitude');
% linkaxes([ax1 ax2]) 
% 
% end
% hold off
% 
% % 2015
% figure(); set(gcf, 'Position',  [100, 100, 925, 575])
% ax1 = axes('Position',[0.07 0.12 0.86 0.78]); % adjust margins
% pcolor(lonsub,latsub,zsub); shading flat
% colormap(ax1,map.cmap);
% ax2 = axes('Position', ax1.Position);
% ax2.Color = 'none';                      % transparent
% ax2.XLim = ax1.XLim; ax2.YLim = ax1.YLim;
% ax2.FontSize = 13;
% hold(ax2,'on')
% hold on
% for i=1:n2015
%     numtext=num2str(i);
% % Plot scatter on ax2
% s = text(ax2, lon2015(i), lat2015(i), numtext, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
% set(ax2,'ColorScale','log'); 
% ax2.XTick = []; ax2.YTick = [];           % hide duplicate ticks if desired
% xlabel(ax1,'Longitude'); ylabel(ax1,'Latitude');
% linkaxes([ax1 ax2]) 
% end
% hold off

%% Plot of map and stations of both 2015 and 2017

% figure(); set(gcf, 'Position',  [100, 100, 950, 575])
% ax1 = axes('Position',[0.07 0.12 0.86 0.78]); % adjust margins
% pcolor(lonsub,latsub,zsub); shading flat
% cm=colormap(ax1,flipud(slanCM('blues'))); caxis(ax1,[-4500 0]);
% colorbar
% 
% % Now lets add the scatter plot
% 
% % Top axes: transparent for scatter (same position)
% ax2 = axes('Position', ax1.Position);
% ax2.Color = 'none';                      % transparent
% ax2.XLim = ax1.XLim; ax2.YLim = ax1.YLim;
% ax2.FontSize = 13;
% hold(ax2,'on')
% 
% 
% % Plot scatter on ax2
% s1 = scatter(ax2,lon2015, lat2015, 80, 'filled','MarkerFaceColor', 'black','MarkerEdgeColor','red','MarkerFaceAlpha',0.9);
% s2 = scatter(ax2,lon2017, lat2017, 80, 'filled','MarkerFaceColor', [0.5 0.5 0.5],'MarkerEdgeColor','green','MarkerFaceAlpha',0.5);
% ax2.XTick = []; ax2.YTick = [];           % hide duplicate ticks if desired
% xlabel(ax1,'Longitude'); ylabel(ax1,'Latitude');
% linkaxes([ax1 ax2]) 
% 
% legend([s1, s2], ...
%        {'2015','2017'}, ...
%        'Location', 'southeast', 'NumColumns', 2, ...
%        'FontSize', 14, 'FontWeight', 'bold');
% % Make an invisible colorbar
% cb = colorbar; set(cb, 'Visible', 'off');
% hold off
% 
% % saveas(gcf,'0.Hydrography_Locations.png')


%% Separation of transects

ride_2015=[68:84 89:102 110:133];
north_2015=46:67;
ovide_2015=26:45;
south_2015=[3:10 15 16 21:25];

ride_2017=[56:69 76:125];
south_2017=[1:8 11:17];
ovide_2017=[18:20 22:24 27:28 43:-1:41 38:-1:31];
north_2017=[44:55 57];

titles = {'Ridge', 'South', 'OVIDE', 'North'};
transects2015={ride_2015, south_2015, ovide_2015, north_2015};
transects2017={ride_2017, south_2017, ovide_2017, north_2017};

xlims=[48.5 63.5; -38.1 -31.3;-37.3 -27.3 ;-34.1 -20.9];
ylims=[100 4500; 100 3000; 100 3000; 100 3000];

figpath='C:\Users\mitg1n25\Desktop\PhD\PhD_Coding\docs\figures\Hydrography_RREX';
imgnametrans={'01.RREX_Transect_ridge.png','02.RREX_Transect_south.png','03.RREX_Transect_ovide.png','04.RREX_Transect_north.png'};

%% Ploting transects: ridge

q=1; 
a=transects2015{q}; b=transects2017{q};

figure(); set(gcf, 'Position',  [100, 100, 1700, 700])
t=tiledlayout(2,4,"TileSpacing","compact","Padding","compact");

ax1=nexttile;
pcolor(lat2015(a),pres2015(:,a),temp2015(:,a)); shading flat
c=colorbar; caxis([2 10]); colormap(ax1,slanCM('turbo'));
set(gca,'YDir','reverse'); ylim(ylims(q,:)); xlim(xlims(q,:));
ylabel('Pressure [dbar]'); title('\theta [°C]');
hold on; h=area(lat2015(a),bottom2015(a),5000,'facecolor',[0.6 0.6 0.6], ...
    'edgecolor','k');
hold off

ax2=nexttile;
pcolor(lat2015(a),pres2015(:,a),sal2015(:,a)); shading flat
c=colorbar; caxis([34.6 35.2]); colormap(ax2,slanCM('haline'));
set(gca,'YDir','reverse'); ylim(ylims(q,:)); xlim(xlims(q,:));
%c.Label.String = '[PSU]';
title('Salinity [PSU]');
hold on; h=area(lat2015(a),bottom2015(a),5000,'facecolor',[0.6 0.6 0.6],'edgecolor','k'); hold off

ax3=nexttile;
pcolor(lat2015(a),pres2015(:,a),dens2015(:,a)); shading flat
c=colorbar; caxis([27.4 28]); colormap(ax3,slanCM('gnuplot2'));
set(gca,'YDir','reverse'); ylim(ylims(q,:)); xlim(xlims(q,:));
%c.Label.String = '[kg/m^3]'; %xlabel('Latitude °N')
title('\sigma_0 [kg/m^3]');
hold on; area(lat2015(a),bottom2015(a),5000,'facecolor',[0.6 0.6 0.6],'edgecolor','k'); hold off

ax4=nexttile;
pcolor(lat2015(a),pres2015(:,a),oxy2015(:,a)); shading flat
c=colorbar; caxis([240 300]); colormap(ax4,slanCM('jet'));
set(gca,'YDir','reverse'); ylim(ylims(q,:)); xlim(xlims(q,:));
title('DO [\mumol/kg]');
hold on; area(lat2015(a),bottom2015(a),5000,'facecolor',[0.6 0.6 0.6],'edgecolor','k'); hold off

ax5=nexttile;
pcolor(lat2017(b),pres2017(:,b),temp2017(:,b)); shading flat
c=colorbar; caxis([2 10]); colormap(ax5,slanCM('turbo'));
set(gca,'YDir','reverse'); ylim(ylims(q,:)); xlim(xlims(q,:));
ylabel('Pressure [dbar]'); xlabel('Latitude °N')
hold on; area(lat2017(b),bottom2017(b),5000,'facecolor',[0.6 0.6 0.6],'edgecolor','k'); hold off

ax6=nexttile;
pcolor(lat2017(b),pres2017(:,b),sal2017(:,b)); shading flat
c=colorbar; caxis([34.6 35.2]); colormap(ax6,slanCM('haline'));
set(gca,'YDir','reverse'); ylim(ylims(q,:)); xlim(xlims(q,:));
xlabel('Latitude °N')
hold on; area(lat2017(b),bottom2017(b),5000,'facecolor',[0.6 0.6 0.6],'edgecolor','k'); hold off

ax7=nexttile;
pcolor(lat2017(b),pres2017(:,b),dens2017(:,b)); shading flat
c=colorbar; caxis([27.4 28]); colormap(ax7,slanCM('gnuplot2'));
set(gca,'YDir','reverse'); ylim(ylims(q,:)); xlim(xlims(q,:));
xlabel('Latitude °N')
hold on; area(lat2017(b),bottom2017(b),5000,'facecolor',[0.6 0.6 0.6],'edgecolor','k'); hold off 

ax8=nexttile;
pcolor(lat2017(b),pres2017(:,b),oxy2017(:,b)); shading flat
c=colorbar; caxis([240 300]); colormap(ax8,slanCM('jet'));
set(gca,'YDir','reverse'); ylim(ylims(q,:)); xlim(xlims(q,:));
xlabel('Latitude °N')
hold on; area(lat2017(b),bottom2017(b),5000,'facecolor',[0.6 0.6 0.6],'edgecolor','k'); hold off 

sgtitle('Along-Ridge Transect','FontSize',17, 'FontWeight', 'bold','FontName','LMRoman10')

imgname=imgnametrans{q}; % Name of the image being stored
figname=fullfile(figpath, imgname);
% Save the figure
set(gca, 'LooseInset', get(gca, 'TightInset'));
% print(gcf,figname, '-dpng', '-r0', '-loose')

%% PLotting N2 gsw

q=1; 
a=transects2015{q}; b=transects2017{q};

figure(); set(gcf, 'Position',  [100, 100, 1300, 700])
tiledlayout(2,3,"TileSpacing","compact","Padding","compact");

nexttile;
pcolor(lat2015(a),pmid2015(:,a),N2_2015(:,a)); shading interp
set(gca,'colorscale','log'); clim([1e-8 1e-4]);
set(gca,'YDir','reverse'); ylim([100 1000]); xlim(xlims(q,:));
ylabel('Pressure [dbar]'); title('N^2 [1/s^2]');
hold on; h=area(lat2015(a),bottom2015(a),5000,'facecolor',[0.6 0.6 0.6], ...
    'edgecolor','k');
hold off

nexttile;
pcolor(lat2015(a),pmid2015(:,a),N2T_2015(:,a)); shading interp
set(gca,'colorscale','log'); clim([1e-8 1e-4]);
set(gca,'YDir','reverse'); ylim([100 1000]); xlim(xlims(q,:));
title('N^2_T [1/s^2]');
hold on; h=area(lat2015(a),bottom2015(a),5000,'facecolor',[0.6 0.6 0.6], ...
    'edgecolor','k');
hold off

nexttile;
pcolor(lat2015(a),pmid2015(:,a),N2S_2015(:,a)); shading interp
colorbar; 
set(gca,'colorscale','log'); clim([1e-8 1e-4]);
set(gca,'YDir','reverse'); ylim([100 1000]); xlim(xlims(q,:));
title('N^2_S [1/s^2]');
hold on; h=area(lat2015(a),bottom2015(a),5000,'facecolor',[0.6 0.6 0.6], ...
    'edgecolor','k');
hold off


nexttile;
pcolor(lat2017(b),pmid2017(:,b),N2_2017(:,b)); shading interp
set(gca,'colorscale','log'); clim([1e-8 1e-4]);
set(gca,'YDir','reverse'); ylim([100 1000]); xlim(xlims(q,:));
ylabel('Pressure [dbar]'); xlabel('Longitude °W')
hold on; h=area(lat2015(a),bottom2015(a),5000,'facecolor',[0.6 0.6 0.6], ...
    'edgecolor','k');
hold off

nexttile;
pcolor(lat2017(b),pmid2017(:,b),N2T_2017(:,b)); shading interp
set(gca,'colorscale','log'); clim([1e-8 1e-4]);
set(gca,'YDir','reverse'); ylim([100 1000]); xlim(xlims(q,:));
xlabel('Longitude °W')
hold on; h=area(lat2015(a),bottom2015(a),5000,'facecolor',[0.6 0.6 0.6], ...
    'edgecolor','k');
hold off

nexttile;
pcolor(lat2017(b),pmid2017(:,b),N2S_2017(:,b)); shading interp
colormap(slanCM('viridis')); colorbar; 
set(gca,'colorscale','log'); clim([1e-8 1e-4]);
set(gca,'YDir','reverse'); ylim([100 1000]); xlim(xlims(q,:));
xlabel('Longitude °W')
hold on; h=area(lat2015(a),bottom2015(a),5000,'facecolor',[0.6 0.6 0.6], ...
    'edgecolor','k');
hold off

sgtitle('Along-Ridge Transect - GSW','FontSize',17, 'FontWeight', 'bold','FontName','LMRoman10')

imgname='0.N2_gsw_RidgeTransect.png'; % Name of the image being stored
figname=fullfile(figpath, imgname);
% Save the figure
set(gca, 'LooseInset', get(gca, 'TightInset'));
% print(gcf,figname, '-dpng', '-r0', '-loose')

%% PLotting N2 Diff

q=1; 
a=transects2015{q}; b=transects2017{q};

figure(); set(gcf, 'Position',  [100, 100, 1300, 700])
tiledlayout(2,3,"TileSpacing","compact","Padding","compact");

nexttile;
pcolor(lat2015(a),pmid2015(:,a),N22015diff(:,a)); shading interp
% pcolor(lat2015(a),pres2015(:,a),N22015(:,a)); shading interp
set(gca,'colorscale','log'); clim([1e-8 1e-4]);
set(gca,'YDir','reverse'); ylim([100 1000]); xlim(xlims(q,:));
ylabel('Pressure [dbar]'); title('N^2 [1/s^2]');
hold on; h=area(lat2015(a),bottom2015(a),5000,'facecolor',[0.6 0.6 0.6], ...
    'edgecolor','k');
hold off

nexttile;
pcolor(lat2015(a),pmid2015(:,a),thermal2015diff(:,a)); shading interp
% pcolor(lat2015(a),pres2015(:,a),thermal2015(:,a)); shading interp
set(gca,'colorscale','log'); clim([1e-8 1e-4]);
set(gca,'YDir','reverse'); ylim([100 1000]); xlim(xlims(q,:));
title('N^2_T [1/s^2]');
hold on; h=area(lat2015(a),bottom2015(a),5000,'facecolor',[0.6 0.6 0.6], ...
    'edgecolor','k');
hold off

nexttile;
pcolor(lat2015(a),pmid2015(:,a),haline2015diff(:,a)); shading interp
% pcolor(lat2015(a),pres2015(:,a),haline2015(:,a)); shading interp
colorbar; 
set(gca,'colorscale','log'); clim([1e-8 1e-4]);
set(gca,'YDir','reverse'); ylim([100 1000]); xlim(xlims(q,:));
title('N^2_S [1/s^2]');
hold on; h=area(lat2015(a),bottom2015(a),5000,'facecolor',[0.6 0.6 0.6], ...
    'edgecolor','k');
hold off

nexttile;
pcolor(lat2017(b),pmid2017(:,b),N22017diff(:,b)); shading interp
% pcolor(lat2017(b),pres2017(:,b),N22017(:,b)); shading interp
set(gca,'colorscale','log'); clim([1e-8 1e-4]);
set(gca,'YDir','reverse'); ylim([100 1000]); xlim(xlims(q,:));
ylabel('Pressure [dbar]'); xlabel('Longitude °W')
hold on; h=area(lat2015(a),bottom2015(a),5000,'facecolor',[0.6 0.6 0.6], ...
    'edgecolor','k');
hold off

nexttile;
pcolor(lat2017(b),pmid2017(:,b),thermal2017diff(:,b)); shading interp
% pcolor(lat2017(b),pres2017(:,b),thermal2017(:,b)); shading interp
set(gca,'colorscale','log'); clim([1e-8 1e-4]);
set(gca,'YDir','reverse'); ylim([100 1000]); xlim(xlims(q,:));
xlabel('Longitude °W')
hold on; h=area(lat2015(a),bottom2015(a),5000,'facecolor',[0.6 0.6 0.6], ...
    'edgecolor','k');
hold off

nexttile;
pcolor(lat2017(b),pmid2017(:,b),haline2017diff(:,b)); shading interp
% pcolor(lat2017(b),pres2017(:,b),haline2017(:,b)); shading interp
colormap(slanCM('viridis')); colorbar; 
set(gca,'colorscale','log'); clim([1e-8 1e-4]);
set(gca,'YDir','reverse'); ylim([100 1000]); xlim(xlims(q,:));
xlabel('Longitude °W')
hold on; h=area(lat2015(a),bottom2015(a),5000,'facecolor',[0.6 0.6 0.6], ...
    'edgecolor','k');
hold off


sgtitle('Along-Ridge Transect - Diff','FontSize',17, 'FontWeight', 'bold','FontName','LMRoman10')

imgname='0.N2_diff_RidgeTransect.png'; % Name of the image being stored
figname=fullfile(figpath, imgname);
% Save the figure
set(gca, 'LooseInset', get(gca, 'TightInset'));
print(gcf,figname, '-dpng', '-r0', '-loose')

%% Ploting transects: Transect 1 (south one)

q=2; 
a=transects2015{q}; b=transects2017{q};

figure(); set(gcf, 'Position',  [100, 100, 1700, 700])
t=tiledlayout(2,4,"TileSpacing","compact","Padding","compact");

ax1=nexttile;
pcolor(lon2015(a),pres2015(:,a),temp2015(:,a)); shading flat
c=colorbar; caxis([2 10]); colormap(ax1,slanCM('turbo'));
set(gca,'YDir','reverse'); ylim(ylims(q,:)); xlim(xlims(q,:));
ylabel('Pressure [dbar]'); title('\theta [°C]');
hold on; area(lon2015(a),bottom2015(a),5000,'facecolor',[0.6 0.6 0.6],'edgecolor','k'); hold off

ax2=nexttile;
pcolor(lon2015(a),pres2015(:,a),sal2015(:,a)); shading flat
c=colorbar; caxis([34.6 35.2]); colormap(ax2,slanCM('haline'));
set(gca,'YDir','reverse'); ylim(ylims(q,:)); xlim(xlims(q,:));
title('Salinity [PSU]');
hold on; area(lon2015(a),bottom2015(a),5000,'facecolor',[0.6 0.6 0.6],'edgecolor','k'); hold off

ax3=nexttile;
pcolor(lon2015(a),pres2015(:,a),dens2015(:,a)); shading flat
c=colorbar; caxis([27.4 28]); colormap(ax3,slanCM('gnuplot2'));
set(gca,'YDir','reverse'); ylim(ylims(q,:)); xlim(xlims(q,:));
title('\sigma_0 [kg/m^3]');
hold on; area(lon2015(a),bottom2015(a),5000,'facecolor',[0.6 0.6 0.6],'edgecolor','k'); hold off

ax4=nexttile;
pcolor(lon2015(a),pres2015(:,a),oxy2015(:,a)); shading flat
c=colorbar; caxis([240 300]); colormap(ax4,slanCM('jet'));
set(gca,'YDir','reverse'); ylim(ylims(q,:)); xlim(xlims(q,:));
title('DO [\mumol/kg]');
hold on; area(lon2015(a),bottom2015(a),5000,'facecolor',[0.6 0.6 0.6],'edgecolor','k'); hold off

ax5=nexttile;
pcolor(lon2017(b),pres2017(:,b),temp2017(:,b)); shading flat
c=colorbar; caxis([2 10]); colormap(ax5,slanCM('turbo'));
set(gca,'YDir','reverse'); ylim(ylims(q,:)); xlim(xlims(q,:));
ylabel('Pressure [dbar]'); xlabel('Longitude °W')
hold on; area(lon2017(b),bottom2017(b),5000,'facecolor',[0.6 0.6 0.6],'edgecolor','k'); hold off 

ax6=nexttile;
pcolor(lon2017(b),pres2017(:,b),sal2017(:,b)); shading flat
c=colorbar; caxis([34.6 35.2]); colormap(ax6,slanCM('haline'));
set(gca,'YDir','reverse'); ylim(ylims(q,:)); xlim(xlims(q,:));
xlabel('Longitude °W')
hold on; area(lon2017(b),bottom2017(b),5000,'facecolor',[0.6 0.6 0.6],'edgecolor','k'); hold off 

ax7=nexttile;
pcolor(lon2017(b),pres2017(:,b),dens2017(:,b)); shading flat
c=colorbar; caxis([27.4 28]); colormap(ax7,slanCM('gnuplot2'));
set(gca,'YDir','reverse'); ylim(ylims(q,:)); xlim(xlims(q,:));
xlabel('Longitude °W')
hold on; area(lon2017(b),bottom2017(b),5000,'facecolor',[0.6 0.6 0.6],'edgecolor','k'); hold off 

ax8=nexttile;
pcolor(lon2017(b),pres2017(:,b),oxy2017(:,b)); shading flat
c=colorbar; caxis([240 300]); colormap(ax8,slanCM('jet'));
set(gca,'YDir','reverse'); ylim(ylims(q,:)); xlim(xlims(q,:));
xlabel('Longitude °W')
hold on; area(lon2017(b),bottom2017(b),5000,'facecolor',[0.6 0.6 0.6],'edgecolor','k'); hold off 

sgtitle('Cross-Ridge Transect 1 (South)','FontSize',17, 'FontWeight', 'bold','FontName','LMRoman10')

imgname=imgnametrans{q}; % Name of the image being stored
figname=fullfile(figpath, imgname);
% Save the figure
set(gca, 'LooseInset', get(gca, 'TightInset'));
print(gcf,figname, '-dpng', '-r0', '-loose')

%% Ploting transects: Transect 2 (OVIDE)

q=3; 
a=transects2015{q}; b=transects2017{q};

figure(); set(gcf, 'Position',  [100, 100, 1700, 700])
t=tiledlayout(2,4,"TileSpacing","compact","Padding","compact");

ax1=nexttile;
pcolor(lon2015(a),pres2015(:,a),temp2015(:,a)); shading flat
c=colorbar; caxis([2 10]); colormap(ax1,slanCM('turbo'));
set(gca,'YDir','reverse'); ylim(ylims(q,:)); xlim(xlims(q,:));
ylabel('Pressure [dbar]'); title('\theta [°C]');
hold on; area(lon2015(a),bottom2015(a),5000,'facecolor',[0.6 0.6 0.6],'edgecolor','k'); hold off

ax2=nexttile;
pcolor(lon2015(a),pres2015(:,a),sal2015(:,a)); shading flat
c=colorbar; caxis([34.6 35.2]); colormap(ax2,slanCM('haline'));
set(gca,'YDir','reverse'); ylim(ylims(q,:)); xlim(xlims(q,:));
title('Salinity [PSU]');
hold on; area(lon2015(a),bottom2015(a),5000,'facecolor',[0.6 0.6 0.6],'edgecolor','k'); hold off

ax3=nexttile;
pcolor(lon2015(a),pres2015(:,a),dens2015(:,a)); shading flat
c=colorbar; caxis([27.4 28]); colormap(ax3,slanCM('gnuplot2'));
set(gca,'YDir','reverse'); ylim(ylims(q,:)); xlim(xlims(q,:));
title('\sigma_0 [kg/m^3]');
hold on; area(lon2015(a),bottom2015(a),5000,'facecolor',[0.6 0.6 0.6],'edgecolor','k'); hold off

ax4=nexttile;
pcolor(lon2015(a),pres2015(:,a),oxy2015(:,a)); shading flat
c=colorbar; caxis([240 300]); colormap(ax4,slanCM('jet'));
set(gca,'YDir','reverse'); ylim(ylims(q,:)); xlim(xlims(q,:));
title('DO [\mumol/kg]');
hold on; area(lon2015(a),bottom2015(a),5000,'facecolor',[0.6 0.6 0.6],'edgecolor','k'); hold off

ax5=nexttile;
pcolor(lon2017(b),pres2017(:,b),temp2017(:,b)); shading flat
c=colorbar; caxis([2 10]); colormap(ax5,slanCM('turbo'));
set(gca,'YDir','reverse'); ylim(ylims(q,:)); xlim(xlims(q,:));
ylabel('Pressure [dbar]'); xlabel('Longitude °W')
hold on; area(lon2017(b),bottom2017(b),5000,'facecolor',[0.6 0.6 0.6],'edgecolor','k'); hold off 

ax6=nexttile;
pcolor(lon2017(b),pres2017(:,b),sal2017(:,b)); shading flat
c=colorbar; caxis([34.6 35.2]); colormap(ax6,slanCM('haline'));
set(gca,'YDir','reverse'); ylim(ylims(q,:)); xlim(xlims(q,:));
xlabel('Longitude °W')
hold on; area(lon2017(b),bottom2017(b),5000,'facecolor',[0.6 0.6 0.6],'edgecolor','k'); hold off 

ax7=nexttile;
pcolor(lon2017(b),pres2017(:,b),dens2017(:,b)); shading flat
c=colorbar; caxis([27.4 28]); colormap(ax7,slanCM('gnuplot2'));
set(gca,'YDir','reverse'); ylim(ylims(q,:)); xlim(xlims(q,:));
xlabel('Longitude °W')
hold on; area(lon2017(b),bottom2017(b),5000,'facecolor',[0.6 0.6 0.6],'edgecolor','k'); hold off 

ax8=nexttile;
pcolor(lon2017(b),pres2017(:,b),oxy2017(:,b)); shading flat
c=colorbar; caxis([240 300]); colormap(ax8,slanCM('jet'));
set(gca,'YDir','reverse'); ylim(ylims(q,:)); xlim(xlims(q,:));
xlabel('Longitude °W')
hold on; area(lon2017(b),bottom2017(b),5000,'facecolor',[0.6 0.6 0.6],'edgecolor','k'); hold off 

sgtitle('Cross-Ridge Transect 2 (OVIDE)','FontSize',17, 'FontWeight', 'bold','FontName','LMRoman10')

imgname=imgnametrans{q}; % Name of the image being stored
figname=fullfile(figpath, imgname);
% Save the figure
set(gca, 'LooseInset', get(gca, 'TightInset'));
print(gcf,figname, '-dpng', '-r0', '-loose')

%% Ploting transects: Transect 4 (north-west of ridge)

q=4; 
a=transects2015{q}; b=transects2017{q};

figure(); set(gcf, 'Position',  [100, 100, 1700, 700])
t=tiledlayout(2,4,"TileSpacing","compact","Padding","compact");

ax1=nexttile;
pcolor(lon2015(a),pres2015(:,a),temp2015(:,a)); shading flat
c=colorbar; caxis([2 10]); colormap(ax1,slanCM('turbo'));
set(gca,'YDir','reverse'); ylim(ylims(q,:)); xlim(xlims(q,:));
ylabel('Pressure [dbar]'); title('\theta [°C]');
hold on; area(lon2015(a),bottom2015(a),5000,'facecolor',[0.6 0.6 0.6],'edgecolor','k'); hold off

ax2=nexttile;
pcolor(lon2015(a),pres2015(:,a),sal2015(:,a)); shading flat
c=colorbar; caxis([34.6 35.2]); colormap(ax2,slanCM('haline'));
set(gca,'YDir','reverse'); ylim(ylims(q,:)); xlim(xlims(q,:));
title('Salinity [PSU]');
hold on; area(lon2015(a),bottom2015(a),5000,'facecolor',[0.6 0.6 0.6],'edgecolor','k'); hold off

ax3=nexttile;
pcolor(lon2015(a),pres2015(:,a),dens2015(:,a)); shading flat
c=colorbar; caxis([27.4 28]); colormap(ax3,slanCM('gnuplot2'));
set(gca,'YDir','reverse'); ylim(ylims(q,:)); xlim(xlims(q,:));
title('\sigma_0 [kg/m^3]');
hold on; area(lon2015(a),bottom2015(a),5000,'facecolor',[0.6 0.6 0.6],'edgecolor','k'); hold off

ax4=nexttile;
pcolor(lon2015(a),pres2015(:,a),oxy2015(:,a)); shading flat
c=colorbar; caxis([240 300]); colormap(ax4,slanCM('jet'));
set(gca,'YDir','reverse'); ylim(ylims(q,:)); xlim(xlims(q,:));
title('DO [\mumol/kg]');
hold on; area(lon2015(a),bottom2015(a),5000,'facecolor',[0.6 0.6 0.6],'edgecolor','k'); hold off

ax5=nexttile;
pcolor(lon2017(b),pres2017(:,b),temp2017(:,b)); shading flat
c=colorbar; caxis([2 10]); colormap(ax5,slanCM('turbo'));
set(gca,'YDir','reverse'); ylim(ylims(q,:)); xlim(xlims(q,:));
ylabel('Pressure [dbar]'); xlabel('Longitude °W')
hold on; area(lon2017(b),bottom2017(b),5000,'facecolor',[0.6 0.6 0.6],'edgecolor','k'); hold off 

ax6=nexttile;
pcolor(lon2017(b),pres2017(:,b),sal2017(:,b)); shading flat
c=colorbar; caxis([34.6 35.2]); colormap(ax6,slanCM('haline'));
set(gca,'YDir','reverse'); ylim(ylims(q,:)); xlim(xlims(q,:));
xlabel('Longitude °W')
hold on; area(lon2017(b),bottom2017(b),5000,'facecolor',[0.6 0.6 0.6],'edgecolor','k'); hold off 

ax7=nexttile;
pcolor(lon2017(b),pres2017(:,b),dens2017(:,b)); shading flat
c=colorbar; caxis([27.4 28]); colormap(ax7,slanCM('gnuplot2'));
set(gca,'YDir','reverse'); ylim(ylims(q,:)); xlim(xlims(q,:));
xlabel('Longitude °W')
hold on; area(lon2017(b),bottom2017(b),5000,'facecolor',[0.6 0.6 0.6],'edgecolor','k'); hold off 

ax8=nexttile;
pcolor(lon2017(b),pres2017(:,b),oxy2017(:,b)); shading flat
c=colorbar; caxis([240 300]); colormap(ax8,slanCM('jet'));
set(gca,'YDir','reverse'); ylim(ylims(q,:)); xlim(xlims(q,:));
xlabel('Longitude °W')
hold on; area(lon2017(b),bottom2017(b),5000,'facecolor',[0.6 0.6 0.6],'edgecolor','k'); hold off 

sgtitle('Cross-Ridge Transect 3 (North)','FontSize',17, 'FontWeight', 'bold','FontName','LMRoman10')

imgname=imgnametrans{q}; % Name of the image being stored
figname=fullfile(figpath, imgname);
% Save the figure
set(gca, 'LooseInset', get(gca, 'TightInset'));
print(gcf,figname, '-dpng', '-r0', '-loose')

%% Ploting transects: Transect 5 (north-east of ridge)

a=eastridge_2015;

figure(); set(gcf, 'Position',  [100, 100, 1800, 350])
ax1=subplot(1,4,1);
pcolor(lon2015(a),pres2015(:,a),temp2015(:,a)); shading flat
c=colorbar; caxis([2 10]); colormap(ax1,slanCM('turbo'));
set(gca,'YDir','reverse'); ylim([100 3500])
ylabel('Pressure [dbar]'); title('\theta [°C]');
hold on; area(lon2015(a),bottom2015(a),5000,'facecolor',[0.6 0.6 0.6],'edgecolor','k'); hold off

ax2=subplot(1,4,2);
pcolor(lon2015(a),pres2015(:,a),sal2015(:,a)); shading flat
c=colorbar; caxis([34.6 35.2]); colormap(ax2,slanCM('haline'));
set(gca,'YDir','reverse'); ylim([100 3500])
title('Salinity [PSU]');
hold on; area(lon2015(a),bottom2015(a),5000,'facecolor',[0.6 0.6 0.6],'edgecolor','k'); hold off

ax3=subplot(1,4,3);
pcolor(lon2015(a),pres2015(:,a),dens2015(:,a)); shading flat
c=colorbar; caxis([27.4 28]); colormap(ax3,slanCM('gnuplot2'));
set(gca,'YDir','reverse'); ylim([100 3500])
title('\sigma_0 [kg/m^3]');
hold on; area(lon2015(a),bottom2015(a),5000,'facecolor',[0.6 0.6 0.6],'edgecolor','k'); hold off

ax4=subplot(1,4,4);
pcolor(lon2015(a),pres2015(:,a),oxy2015(:,a)); shading flat
c=colorbar; caxis([240 300]); colormap(ax4,slanCM('jet'));
set(gca,'YDir','reverse'); ylim([100 3500])
title('DO [\mumol/kg]');
hold on; area(lon2015(a),bottom2015(a),5000,'facecolor',[0.6 0.6 0.6],'edgecolor','k'); hold off

sgtitle('East-Ridge Transect','FontSize',17, 'FontWeight', 'bold','FontName','LMRoman10')

% saveas(gcf,'5.Hydrography_eastridge.png')

%% Ploting transects: South of Ridge (CGFZ)

a=southridge_2015; b=southridge_2017;

figure(); set(gcf, 'Position',  [100, 100, 1700, 700])
ax1=subplot(2,4,1);
pcolor(lat2015(a),pres2015(:,a),temp2015(:,a)); shading flat
c=colorbar; caxis([2 10]); colormap(ax1,slanCM('turbo'));
set(gca,'YDir','reverse'); ylim([100 5000])
ylabel('Pressure [dbar]'); title('\theta [°C]');
hold on; h=area(lat2015(a),bottom2015(a),7000,'facecolor',[0.6 0.6 0.6], ...
    'edgecolor','k');
hold off

ax2=subplot(2,4,2);
pcolor(lat2015(a),pres2015(:,a),sal2015(:,a)); shading flat
c=colorbar; caxis([34.6 35.2]); colormap(ax2,slanCM('haline'));
set(gca,'YDir','reverse'); ylim([100 5000])
%c.Label.String = '[PSU]';
title('Salinity [PSU]');
hold on; h=area(lat2015(a),bottom2015(a),7000,'facecolor',[0.6 0.6 0.6],'edgecolor','k'); hold off


ax3=subplot(2,4,3);
pcolor(lat2015(a),pres2015(:,a),dens2015(:,a)); shading flat
c=colorbar; caxis([27.4 28]); colormap(ax3,slanCM('gnuplot2'));
set(gca,'YDir','reverse'); ylim([100 5000])
%c.Label.String = '[kg/m^3]'; %xlabel('Latitude °N')
title('\sigma_0 [kg/m^3]');
hold on; area(lat2015(a),bottom2015(a),7000,'facecolor',[0.6 0.6 0.6],'edgecolor','k'); hold off

ax4=subplot(2,4,4);
pcolor(lat2015(a),pres2015(:,a),oxy2015(:,a)); shading flat
c=colorbar; caxis([240 300]); colormap(ax4,slanCM('jet'));
set(gca,'YDir','reverse'); ylim([100 5000])
title('DO [\mumol/kg]');
hold on; area(lat2015(a),bottom2015(a),7000,'facecolor',[0.6 0.6 0.6],'edgecolor','k'); hold off


ax5=subplot(2,4,5);
pcolor(lat2017(b),pres2017(:,b),temp2017(:,b)); shading flat
c=colorbar; caxis([2 10]); colormap(ax5,slanCM('turbo'));
set(gca,'YDir','reverse'); ylim([100 5000])
ylabel('Pressure [dbar]'); xlabel('Latitude °N')
hold on; area(lat2017(b),bottom2017(b),7000,'facecolor',[0.6 0.6 0.6],'edgecolor','k'); hold off

ax6=subplot(2,4,6);
pcolor(lat2017(b),pres2017(:,b),sal2017(:,b)); shading flat
c=colorbar; caxis([34.6 35.2]); colormap(ax6,slanCM('haline'));
set(gca,'YDir','reverse'); ylim([100 7000])
xlabel('Latitude °N')
hold on; area(lat2017(b),bottom2017(b),7000,'facecolor',[0.6 0.6 0.6],'edgecolor','k'); hold off

ax7=subplot(2,4,7);
pcolor(lat2017(b),pres2017(:,b),dens2017(:,b)); shading flat
c=colorbar; caxis([27.4 28]); colormap(ax7,slanCM('gnuplot2'));
set(gca,'YDir','reverse'); ylim([100 5000])
xlabel('Latitude °N')
hold on; area(lat2017(b),bottom2017(b),7000,'facecolor',[0.6 0.6 0.6],'edgecolor','k'); hold off 

ax8=subplot(2,4,8);
pcolor(lat2017(b),pres2017(:,b),oxy2017(:,b)); shading flat
c=colorbar; caxis([240 300]); colormap(ax8,slanCM('jet'));
set(gca,'YDir','reverse'); ylim([100 5000])
xlabel('Latitude °N')
hold on; area(lat2017(b),bottom2017(b),7000,'facecolor',[0.6 0.6 0.6],'edgecolor','k'); hold off 

sgtitle('South-Ridge Transect (CGFZ)','FontSize',17, 'FontWeight', 'bold','FontName','LMRoman10')

% saveas(gcf,'6.Hydrography_SouthRidge.png')

%% T-S Diagram of Both Cruises (all stations)

% Transform the matrices into a column vector
s2015=sal2015(:); s2017=sal2017(:);
t2015=temp2015(:); t2017=temp2017(:);
o2015=oxy2015(:); o2017=oxy2017(:);
d2015=dens2015(:); d2017=dens2017(:);
S2015=SA2015(:); S2017=SA2017(:);
T2015=CT2015(:); T2017=CT2017(:);

% This is for creating the density backround
xdim=2000 ; ydim=2000; % Size of temperature (x) and salinity (y) coordinates
sigma_sca=zeros(ydim,xdim); % Creating variable for density
thetai=linspace(min(t2015)-2,max(t2015)+2,xdim); % Temperature coordinates
si=linspace(min(S2015)-1,max(S2015)+1,ydim); % Salinity coordinates
for j=1:ydim
    for i=1:xdim
        sigma_sca(j,i)=eos80_legacy_sigma(si(i),thetai(j),0); % Creates density contours
    end
end
% Densities used in Figure 4 of Petit et al 2018
density_levels=[27, 27.52, 27.71, 27.8, 28];

%% Water mass identification

NACW2015=dens2015<27.52 & sal2015>34.94;
NACW2017=dens2017<27.52 & sal2017>34.94;

SAW2015=dens2015<27.52 & sal2015<34.94;
SAW2017=dens2017<27.52 & sal2017<34.94;

SAIW2015=dens2015>27.52 & dens2015<27.71 & sal2015<34.94;
SAIW2017=dens2017>27.52 & dens2017<27.71 & sal2017<34.94;

IW2015=dens2015>27.52 & dens2015<27.71 & sal2015>34.94 & oxy2015 < 272;
IW2017=dens2017>27.52 & dens2017<27.71 & sal2017>34.94 & oxy2017 < 272;

SPMW2015=dens2015>27.52 & dens2015<27.71 & sal2015>34.94 & oxy2015 > 272;
SPMW2017=dens2017>27.52 & dens2017<27.71 & sal2017>34.94 & oxy2017 > 272;

LSW2015=dens2015>27.71 & dens2015<27.8 & sal2015<34.94;
LSW2017=dens2017>27.71 & dens2017<27.8 & sal2017<34.94;

ISW2015=dens2015>27.71 & dens2015<27.8 & sal2015>34.94;
ISW2017=dens2017>27.71 & dens2017<27.8 & sal2017>34.94;

LDW2015=dens2015>27.8 & sal2015<34.94;
LDW2017=dens2017>27.8 & sal2017<34.94;

ISOW2015=dens2015>27.8 & sal2015>34.94;
ISOW2017=dens2017>27.8 & sal2017>34.94;

%% We calculate the averages in each water mass range in order to get the source water mass

SA2015=s2015; SA2017=s2017; CT2015=temp2015; CT2017=temp2017;

SA_NACW_2015=mean(SA2015(NACW2015),"all",'omitmissing'); SA_NACW_2017=mean(SA2017(NACW2017),"all",'omitmissing');
CT_NACW_2015=mean(CT2015(NACW2015),"all",'omitmissing'); CT_NACW_2017=mean(CT2017(NACW2017),"all",'omitmissing');
oxy_NACW_2015=mean(oxy2015(NACW2015),"all",'omitmissing'); oxy_NACW_2017=mean(oxy2017(NACW2017),"all",'omitmissing');
gamma_NACW_2015=mean(gamma2015(NACW2015),"all",'omitmissing'); gamma_NACW_2017=mean(gamma2017(NACW2017),"all",'omitmissing');

SA_SAW_2015=mean(SA2015(SAW2015),"all",'omitmissing'); SA_SAW_2017=mean(SA2017(SAW2017),"all",'omitmissing');
CT_SAW_2015=mean(CT2015(SAW2015),"all",'omitmissing'); CT_SAW_2017=mean(CT2017(SAW2017),"all",'omitmissing');
oxy_SAW_2015=mean(oxy2015(SAW2015),"all",'omitmissing'); oxy_SAW_2017=mean(oxy2017(SAW2017),"all",'omitmissing');
gamma_SAW_2015=mean(gamma2015(SAW2015),"all",'omitmissing'); gamma_SAW_2017=mean(gamma2017(SAW2017),"all",'omitmissing');

SA_SAIW_2015=mean(SA2015(SAIW2015),"all",'omitmissing'); SA_SAIW_2017=mean(SA2017(SAIW2017),"all",'omitmissing');
CT_SAIW_2015=mean(CT2015(SAIW2015),"all",'omitmissing'); CT_SAIW_2017=mean(CT2017(SAIW2017),"all",'omitmissing');
oxy_SAIW_2015=mean(oxy2015(SAIW2015),"all",'omitmissing'); oxy_SAIW_2017=mean(oxy2017(SAIW2017),"all",'omitmissing');
gamma_SAIW_2015=mean(gamma2015(SAIW2015),"all",'omitmissing'); gamma_SAIW_2017=mean(gamma2017(SAIW2017),"all",'omitmissing');

SA_IW_2015=mean(SA2015(IW2015),"all",'omitmissing'); SA_IW_2017=mean(SA2017(IW2017),"all",'omitmissing');
CT_IW_2015=mean(CT2015(IW2015),"all",'omitmissing'); CT_IW_2017=mean(CT2017(IW2017),"all",'omitmissing');
oxy_IW_2015=mean(oxy2015(IW2015),"all",'omitmissing'); oxy_IW_2017=mean(oxy2017(IW2017),"all",'omitmissing');
gamma_IW_2015=mean(gamma2015(IW2015),"all",'omitmissing'); gamma_IW_2017=mean(gamma2017(IW2017),"all",'omitmissing');

SA_SPMW_2015=mean(SA2015(SPMW2015),"all",'omitmissing'); SA_SPMW_2017=mean(SA2017(SPMW2017),"all",'omitmissing');
CT_SPMW_2015=mean(CT2015(SPMW2015),"all",'omitmissing'); CT_SPMW_2017=mean(CT2017(SPMW2017),"all",'omitmissing');
oxy_SPMW_2015=mean(oxy2015(SPMW2015),"all",'omitmissing'); oxy_SPMW_2017=mean(oxy2017(SPMW2017),"all",'omitmissing');
gamma_SPMW_2015=mean(gamma2015(SPMW2015),"all",'omitmissing'); gamma_SPMW_2017=mean(gamma2017(SPMW2017),"all",'omitmissing');

SA_LSW_2015=mean(SA2015(LSW2015),"all",'omitmissing'); SA_LSW_2017=mean(SA2017(LSW2017),"all",'omitmissing');
CT_LSW_2015=mean(CT2015(LSW2015),"all",'omitmissing'); CT_LSW_2017=mean(CT2017(LSW2017),"all",'omitmissing');
oxy_LSW_2015=mean(oxy2015(LSW2015),"all",'omitmissing'); oxy_LSW_2017=mean(oxy2017(LSW2017),"all",'omitmissing');
gamma_LSW_2015=mean(gamma2015(LSW2015),"all",'omitmissing'); gamma_LSW_2017=mean(gamma2017(LSW2017),"all",'omitmissing');

SA_ISW_2015=mean(SA2015(ISW2015),"all",'omitmissing'); SA_ISW_2017=mean(SA2017(ISW2017),"all",'omitmissing');
CT_ISW_2015=mean(CT2015(ISW2015),"all",'omitmissing'); CT_ISW_2017=mean(CT2017(ISW2017),"all",'omitmissing');
oxy_ISW_2015=mean(oxy2015(ISW2015),"all",'omitmissing'); oxy_ISW_2017=mean(oxy2017(ISW2017),"all",'omitmissing');
gamma_ISW_2015=mean(gamma2015(ISW2015),"all",'omitmissing'); gamma_ISW_2017=mean(gamma2017(ISW2017),"all",'omitmissing');

SA_LDW_2015=mean(SA2015(LDW2015),"all",'omitmissing'); SA_LDW_2017=mean(SA2017(LDW2017),"all",'omitmissing');
CT_LDW_2015=mean(CT2015(LDW2015),"all",'omitmissing'); CT_LDW_2017=mean(CT2017(LDW2017),"all",'omitmissing');
oxy_LDW_2015=mean(oxy2015(LDW2015),"all",'omitmissing'); oxy_LDW_2017=mean(oxy2017(LDW2017),"all",'omitmissing');
gamma_LDW_2015=mean(gamma2015(LDW2015),"all",'omitmissing'); gamma_LDW_2017=mean(gamma2017(LDW2017),"all",'omitmissing');

SA_ISOW_2015=mean(SA2015(ISOW2015),"all",'omitmissing'); SA_ISOW_2017=mean(SA2017(ISOW2017),"all",'omitmissing');
CT_ISOW_2015=mean(CT2015(ISOW2015),"all",'omitmissing'); CT_ISOW_2017=mean(CT2017(ISOW2017),"all",'omitmissing');
oxy_ISOW_2015=mean(oxy2015(ISOW2015),"all",'omitmissing'); oxy_ISOW_2017=mean(oxy2017(ISOW2017),"all",'omitmissing');
gamma_ISOW_2015=mean(gamma2015(ISOW2015),"all",'omitmissing'); gamma_ISOW_2017=mean(gamma2017(ISOW2017),"all",'omitmissing');


SWM2015=[SA_NACW_2015 CT_NACW_2015 oxy_NACW_2015 gamma_NACW_2015; 
         SA_SAW_2015 CT_SAW_2015 oxy_SAW_2015 gamma_SAW_2015;
         SA_SPMW_2015 CT_SPMW_2015 oxy_SPMW_2015 gamma_SPMW_2015;
         SA_IW_2015 CT_IW_2015 oxy_IW_2015 gamma_IW_2015;
         SA_SAIW_2015 CT_SAIW_2015 oxy_SAIW_2015 gamma_SAIW_2015;
         SA_ISW_2015 CT_ISW_2015 oxy_ISW_2015 gamma_ISW_2015;
         SA_LSW_2015 CT_LSW_2015 oxy_LSW_2015 gamma_LSW_2015;
         SA_ISOW_2015 CT_ISOW_2015 oxy_ISOW_2015 gamma_ISOW_2015;
         SA_LDW_2015 CT_LDW_2015 oxy_LDW_2015 gamma_LDW_2015];

SWM2017=[SA_NACW_2017 CT_NACW_2017 oxy_NACW_2017 gamma_NACW_2017; 
         SA_SAW_2017 CT_SAW_2017 oxy_SAW_2017 gamma_SAW_2017;
         SA_SPMW_2017 CT_SPMW_2017 oxy_SPMW_2017 gamma_SPMW_2017;
         SA_IW_2017 CT_IW_2017 oxy_IW_2017 gamma_IW_2017;
         SA_SAIW_2017 CT_SAIW_2017 oxy_SAIW_2017 gamma_SAIW_2017;
         SA_ISW_2017 CT_ISW_2017 oxy_ISW_2017 gamma_ISW_2017;
         SA_LSW_2017 CT_LSW_2017 oxy_LSW_2017 gamma_LSW_2017;
         SA_ISOW_2017 CT_ISOW_2017 oxy_ISOW_2017 gamma_ISOW_2017;
         SA_LDW_2017 CT_LDW_2017 oxy_LDW_2017 gamma_LDW_2017];


SWM=(SWM2015+SWM2017)*0.5;

%% Make the plot with oxygen as colors

figure(); set(gcf, 'Position',  [100, 100, 1700, 700])
subplot(1,2,1)
scatter(s2015,t2015,5,o2015,'filled')
colormap jet; caxis([240 300]);
xlim([34.5 35.3]); ylim([1 11])
hold on
[c,h]=contour(si,thetai,sigma_sca,density_levels,'--k');
clabel(c, h,'FontSize', 11, 'FontWeight', 'bold','LabelSpacing', 120, 'Color', 'k');
xlabel('Salinity','FontSize',13)
ylabel('Potential Temperature','FontSize',13)
title('2015','FontSize',16)
grid on
hold off

subplot(1,2,2)
scatter(s2017,t2017,5,o2017,'filled')
colormap jet; caxis([240 300])
xlim([34.5 35.3]); ylim([1 11])
hold on
[c,h]=contour(si,thetai,sigma_sca,density_levels,'--k');
clabel(c, h,'FontSize', 11, 'FontWeight', 'bold','LabelSpacing', 120, 'Color', 'k');
xlabel('Salinity','FontSize',13)
title('2017','FontSize',16)
grid on
hold off

% Add colorbar to the right
cb = colorbar('Position', [0.92 0.14 0.015 0.74]); %[position_x position_y width_x width_y]
cb.Label.String = 'Oxygen Concentration (μmol/kg)';
cb.FontSize = 12;
cb.FontWeight = 'bold';

sgtitle('RREX Cruise Comparison','FontSize',17, 'FontWeight', 'bold','FontName','LMRoman10')

% saveas(gcf,'7.TSDiagram_AllStations.png')

%% Make the water mass index a vector

NACW2015=NACW2015(:); NACW2017=NACW2017(:);
SAW2015=SAW2015(:); SAW2017=SAW2017(:);
SAIW2015=SAIW2015(:); SAIW2017=SAIW2017(:);
IW2015=IW2015(:); IW2017=IW2017(:);
SPMW2015=SPMW2015(:); SPMW2017=SPMW2017(:);
LSW2015=LSW2015(:); LSW2017=LSW2017(:);
ISW2015=ISW2015(:); ISW2017=ISW2017(:);
LDW2015=LDW2015(:); LDW2017=LDW2017(:);
ISOW2015=ISOW2015(:); ISOW2017=ISOW2017(:);

%% Make the plot with Water Masses as colors

figure(); set(gcf, 'Position',  [100, 100, 1700, 700])
subplot(1,2,1)
h1 = scatter(s2015(NACW2015), t2015(NACW2015), 5, 'blue', 'filled');
hold on;
h2 = scatter(s2015(SAW2015), t2015(SAW2015), 5, 'filled','MarkerFaceColor', [0.50196, 0, 0.12549]);
h3 = scatter(s2015(SAIW2015), t2015(SAIW2015), 5, 'cyan', 'filled');
h4 = scatter(s2015(IW2015), t2015(IW2015), 5, 'filled','MarkerFaceColor', [0.75 0.75 0.75]);
h5 = scatter(s2015(SPMW2015), t2015(SPMW2015), 5, 'green', 'filled');
h6 = scatter(s2015(LSW2015), t2015(LSW2015), 5, 'yellow', 'filled');
h7 = scatter(s2015(ISW2015), t2015(ISW2015), 5, 'filled', 'MarkerFaceColor', [1 0.5 0]);
h8 = scatter(s2015(LDW2015), t2015(LDW2015), 5, 'filled','MarkerFaceColor', [0.5 0 0.5]);
h9 = scatter(s2015(ISOW2015), t2015(ISOW2015), 5, 'red', 'filled');
xlim([34.5 35.3]); ylim([1 11])
[c,h]=contour(si,thetai,sigma_sca,density_levels,'--k');
clabel(c, h,'FontSize', 11, 'FontWeight', 'bold','LabelSpacing', 120, 'Color', 'k');
xlabel('Salinity','FontSize',13)
ylabel('Potential Temperature','FontSize',13)
title('2015','FontSize',16)
grid on
hold off
legend([h1, h2, h3, h4, h5, h6, h7, h8, h9], ...
       {'NACW', 'SAW', 'SAIW', 'IW', 'SPMW', 'LSW', 'ISW', 'LDW', 'ISOW'}, ...
       'Location', 'southeast', 'NumColumns', 2, ...
       'FontSize', 10, 'FontWeight', 'bold');

subplot(1,2,2)
h1=scatter(s2017(NACW2017),t2017(NACW2017),5,'blue','filled');
hold on
h2=scatter(s2017(SAW2017),t2017(SAW2017),5,'filled','MarkerFaceColor',[0.50196, 0, 0.12549]); % Burgundy 
h3=scatter(s2017(SAIW2017),t2017(SAIW2017),5,'cyan','filled');
h4=scatter(s2017(IW2017),t2017(IW2017),5,'filled','MarkerFaceColor',[.75 .75 .75]); % Light grey
h5=scatter(s2017(SPMW2017),t2017(SPMW2017),5,'green','filled');
h6=scatter(s2017(LSW2017),t2017(LSW2017),5,'yellow','filled');
h7=scatter(s2017(ISW2017),t2017(ISW2017),5,'filled','MarkerFaceColor',[1 0.5 0]); % Orange
h8=scatter(s2017(LDW2017),t2017(LDW2017),5,'filled','MarkerFaceColor',[0.5 0 0.5]); % Purple
h9=scatter(s2017(ISOW2017),t2017(ISOW2017),5,'red','filled');
xlim([34.5 35.3]); ylim([1 11])
[c,h]=contour(si,thetai,sigma_sca,density_levels,'--k');
clabel(c, h,'FontSize', 11, 'FontWeight', 'bold','LabelSpacing', 120, 'Color', 'k');
xlabel('Salinity','FontSize',13)
title('2017','FontSize',16)
grid on
hold off
legend([h1, h2, h3, h4, h5, h6, h7, h8, h9], ...
       {'NACW', 'SAW', 'SAIW', 'IW', 'SPMW', 'LSW', 'ISW', 'LDW', 'ISOW'}, ...
       'Location', 'southeast', 'NumColumns', 2, ...
       'FontSize', 10, 'FontWeight', 'bold');


sgtitle('RREX Cruise Comparison - Water Masses','FontSize',17, 'FontWeight', 'bold','FontName','LMRoman10')

% saveas(gcf,'7b.TSDiagram_AllStations.png')

%% The same but in temperature-oxygen space

figure(); set(gcf, 'Position',  [100, 100, 1700, 700])
subplot(1,2,1)
h1 = scatter(o2015(NACW2015), t2015(NACW2015), 5, 'blue', 'filled');
hold on;
h2 = scatter(o2015(SAW2015), t2015(SAW2015), 5, 'filled','MarkerFaceColor', [0.50196, 0, 0.12549]);
h3 = scatter(o2015(SAIW2015), t2015(SAIW2015), 5, 'cyan', 'filled');
h4 = scatter(o2015(IW2015), t2015(IW2015), 5, 'filled','MarkerFaceColor', [0.75 0.75 0.75]);
h5 = scatter(o2015(SPMW2015), t2015(SPMW2015), 5, 'green', 'filled');
h6 = scatter(o2015(LSW2015), t2015(LSW2015), 5, 'yellow', 'filled');
h7 = scatter(o2015(ISW2015), t2015(ISW2015), 5, 'filled', 'MarkerFaceColor', [1 0.5 0]);
h8 = scatter(o2015(LDW2015), t2015(LDW2015), 5, 'filled','MarkerFaceColor', [0.5 0 0.5]);
h9 = scatter(o2015(ISOW2015), t2015(ISOW2015), 5, 'red', 'filled');
xlim([220 320]); ylim([1 11])
% [c,h]=contour(si,thetai,sigma_sca,density_levels,'--k');
% clabel(c, h,'FontSize', 11, 'FontWeight', 'bold','LabelSpacing', 120, 'Color', 'k');
xlabel('Salinity','FontSize',13)
ylabel('Potential Temperature','FontSize',13)
title('2015','FontSize',16)
grid on
hold off
legend([h1, h2, h3, h4, h5, h6, h7, h8, h9], ...
       {'NACW', 'SAW', 'SAIW', 'IW', 'SPMW', 'LSW', 'ISW', 'LDW', 'ISOW'}, ...
       'Location', 'southeast', 'NumColumns', 2, ...
       'FontSize', 10, 'FontWeight', 'bold');

subplot(1,2,2)
h1=scatter(o2017(NACW2017),t2017(NACW2017),5,'blue','filled');
hold on
h2=scatter(o2017(SAW2017),t2017(SAW2017),5,'filled','MarkerFaceColor',[0.50196, 0, 0.12549]); % Burgundy 
h3=scatter(o2017(SAIW2017),t2017(SAIW2017),5,'cyan','filled');
h4=scatter(o2017(IW2017),t2017(IW2017),5,'filled','MarkerFaceColor',[.75 .75 .75]); % Light grey
h5=scatter(o2017(SPMW2017),t2017(SPMW2017),5,'green','filled');
h6=scatter(o2017(LSW2017),t2017(LSW2017),5,'yellow','filled');
h7=scatter(o2017(ISW2017),t2017(ISW2017),5,'filled','MarkerFaceColor',[1 0.5 0]); % Orange
h8=scatter(o2017(LDW2017),t2017(LDW2017),5,'filled','MarkerFaceColor',[0.5 0 0.5]); % Purple
h9=scatter(o2017(ISOW2017),t2017(ISOW2017),5,'red','filled');
xlim([220 320]); ylim([1 11])
% [c,h]=contour(si,thetai,sigma_sca,density_levels,'--k');
% clabel(c, h,'FontSize', 11, 'FontWeight', 'bold','LabelSpacing', 120, 'Color', 'k');
xlabel('Salinity','FontSize',13)
title('2017','FontSize',16)
grid on
hold off
legend([h1, h2, h3, h4, h5, h6, h7, h8, h9], ...
       {'NACW', 'SAW', 'SAIW', 'IW', 'SPMW', 'LSW', 'ISW', 'LDW', 'ISOW'}, ...
       'Location', 'southeast', 'NumColumns', 2, ...
       'FontSize', 10, 'FontWeight', 'bold');


sgtitle('RREX Cruise Comparison - Water Masses','FontSize',17, 'FontWeight', 'bold','FontName','LMRoman10')

%% T-S Diagram of the Ridge

a=ridge_2015; b=ridge_2017;
s2015=sal2015(:,a); s2017=sal2017(:,b); s2015=s2015(:); s2017=s2017(:);
t2015=temp2015(:,a); t2017=temp2017(:,b); t2015=t2015(:); t2017=t2017(:);
o2015=oxy2015(:,a); o2017=oxy2017(:,b); o2015=o2015(:); o2017=o2017(:);

figure(); set(gcf, 'Position',  [100, 100, 1600, 700])
subplot(1,2,1)
scatter(s2015,t2015,5,o2015,'filled')
colormap jet; caxis([240 300]);
xlim([34.5 35.3]); ylim([1 11])
hold on
[c,h]=contour(si,thetai,sigma_sca,density_levels,'--k');
clabel(c, h,'FontSize', 11, 'FontWeight', 'bold','LabelSpacing', 120, 'Color', 'k');
xlabel('Salinity','FontSize',13)
ylabel('Temperature','FontSize',13)
title('2015','FontSize',15)
grid on
hold off

subplot(1,2,2)
scatter(s2017,t2017,5,o2017,'filled')
colormap jet; caxis([240 300])
xlim([34.5 35.3]); ylim([1 11])
hold on
[c,h]=contour(si,thetai,sigma_sca,density_levels,'--k');
clabel(c, h,'FontSize', 11, 'FontWeight', 'bold','LabelSpacing', 120, 'Color', 'k');
xlabel('Salinity','FontSize',13)
title('2017','FontSize',15)
grid on
hold off

% Add colorbar to the right
cb = colorbar('Position', [0.92 0.14 0.015 0.74]); %[position_x position_y width_x width_y]
cb.Label.String = 'Oxygen Concentration (μmol/kg)';
cb.FontSize = 12;
cb.FontWeight = 'bold';

sgtitle('RREX Along Ridge Transect','FontSize',16, 'FontWeight', 'bold','FontName','LMRoman10')

% saveas(gcf,'8.TSDiagram_Ridge.png')

% T-S Diagram of the water masses

RREXWaterMasses(temp2015(:,a),sal2015(:,a),dens2015(:,a),oxy2015(:,a),'2015 Ridge')
% saveas(gcf,'8a.TSDiagram_Ridge.png')
RREXWaterMasses(temp2017(:,b),sal2017(:,b),dens2017(:,b),oxy2017(:,b),'2017 Ridge')
% saveas(gcf,'8b.TSDiagram_Ridge.png')

%% The same but in vertical format

% figure(); 
% set(gcf, 'Position', [100, 100, 500, 700]);
% 
% % Define fixed positions for subplots (leave room for colorbar)
% subplot(2,1,1, 'Position', [0.1 0.58 0.7 0.34]); % [left bottom width height]
% scatter(s2015, t2015, 5, o2015, 'filled');
% colormap jet; caxis([240 300]);
% xlim([34.7 35.3]); ylim([1 11]);
% hold on;
% [c, h] = contour(si, thetai, sigma_sca, density_levels, '--k');
% clabel(c, h, 'FontSize', 11, 'FontWeight', 'bold', 'LabelSpacing', 120, 'Color', 'k');
% ylabel('Temperature', 'FontSize', 13);
% title('2015', 'FontSize', 15);
% grid on;
% hold off;
% 
% subplot(2,1,2, 'Position', [0.1 0.11 0.7 0.34]);
% scatter(s2017, t2017, 5, o2017, 'filled');
% caxis([240 300]);
% xlim([34.7 35.3]); ylim([1 11]);
% hold on;
% [c, h] = contour(si, thetai, sigma_sca, density_levels, '--k');
% clabel(c, h, 'FontSize', 11, 'FontWeight', 'bold', 'LabelSpacing', 120, 'Color', 'k');
% ylabel('Temperature', 'FontSize', 13);
% xlabel('Salinity', 'FontSize', 13);
% title('2017', 'FontSize', 15);
% grid on;
% hold off;
% 
% % Add colorbar in the reserved space
% cb = colorbar('Position', [0.82 0.15 0.03 0.7]);
% cb.Label.String = 'Oxygen Concentration (\mu mol/kg)';
% cb.FontSize = 12;
% cb.FontWeight = 'bold';
% 
% saveas(gcf,'8b.TSDiagram_Ridge.png')

%% T-S Diagram of Cross-Ridge 1 (southern transect)

a=trans1_2015; b=trans1_2017;
s2015=sal2015(:,a); s2017=sal2017(:,b); s2015=s2015(:); s2017=s2017(:);
t2015=temp2015(:,a); t2017=temp2017(:,b); t2015=t2015(:); t2017=t2017(:);
o2015=oxy2015(:,a); o2017=oxy2017(:,b); o2015=o2015(:); o2017=o2017(:);

figure(); set(gcf, 'Position',  [100, 100, 1600, 700])
subplot(1,2,1)
scatter(s2015,t2015,5,o2015,'filled')
colormap jet; caxis([240 300]);
xlim([34.5 35.3]); ylim([1 11])
hold on
[c,h]=contour(si,thetai,sigma_sca,density_levels,'--k');
clabel(c, h,'FontSize', 11, 'FontWeight', 'bold','LabelSpacing', 120, 'Color', 'k');
xlabel('Salinity','FontSize',13)
ylabel('Temperature','FontSize',13)
title('2015','FontSize',15)
grid on
hold off

subplot(1,2,2)
scatter(s2017,t2017,5,o2017,'filled')
colormap jet; caxis([240 300])
xlim([34.5 35.3]); ylim([1 11])
hold on
[c,h]=contour(si,thetai,sigma_sca,density_levels,'--k');
clabel(c, h,'FontSize', 11, 'FontWeight', 'bold','LabelSpacing', 120, 'Color', 'k');
xlabel('Salinity','FontSize',13)
title('2017','FontSize',15)
grid on
hold off

% Add colorbar to the right
cb = colorbar('Position', [0.92 0.14 0.015 0.74]); %[position_x position_y width_x width_y]
cb.Label.String = 'Oxygen Concentration (μmol/kg)';
cb.FontSize = 12;
cb.FontWeight = 'bold';

sgtitle('RREX Cross-Ridge Transect 1','FontSize',16, 'FontWeight', 'bold','FontName','LMRoman10')

% saveas(gcf,'9.TSDiagram_XRidge1.png')

% T-S Diagram of the water masses
RREXWaterMasses(temp2015(:,a),sal2015(:,a),dens2015(:,a),oxy2015(:,a),'2015 Cross-Ridge 1')
% saveas(gcf,'9a.TSDiagram_XRidge1.png')

RREXWaterMasses(temp2017(:,b),sal2017(:,b),dens2017(:,b),oxy2017(:,b),'2017 Cross-Ridge 1')
% saveas(gcf,'9b.TSDiagram_XRidge1.png')

%% T-S Diagram of Cross-Ridge 2 (OVIDE)

a=trans2_2015; b=trans2_2017;
s2015=sal2015(:,a); s2017=sal2017(:,b); s2015=s2015(:); s2017=s2017(:);
t2015=temp2015(:,a); t2017=temp2017(:,b); t2015=t2015(:); t2017=t2017(:);
o2015=oxy2015(:,a); o2017=oxy2017(:,b); o2015=o2015(:); o2017=o2017(:);

figure(); set(gcf, 'Position',  [100, 100, 1600, 700])
subplot(1,2,1)
scatter(s2015,t2015,5,o2015,'filled')
colormap jet; caxis([240 300]);
xlim([34.5 35.3]); ylim([1 11])
hold on
[c,h]=contour(si,thetai,sigma_sca,density_levels,'--k');
clabel(c, h,'FontSize', 11, 'FontWeight', 'bold','LabelSpacing', 120, 'Color', 'k');
xlabel('Salinity','FontSize',13)
ylabel('Temperature','FontSize',13)
title('2015','FontSize',15)
grid on
hold off

subplot(1,2,2)
scatter(s2017,t2017,5,o2017,'filled')
colormap jet; caxis([240 300])
xlim([34.5 35.3]); ylim([1 11])
hold on
[c,h]=contour(si,thetai,sigma_sca,density_levels,'--k');
clabel(c, h,'FontSize', 11, 'FontWeight', 'bold','LabelSpacing', 120, 'Color', 'k');
xlabel('Salinity','FontSize',13)
title('2017','FontSize',15)
grid on
hold off

% Add colorbar to the right
cb = colorbar('Position', [0.92 0.14 0.015 0.74]); %[position_x position_y width_x width_y]
cb.Label.String = 'Oxygen Concentration (μmol/kg)';
cb.FontSize = 12;
cb.FontWeight = 'bold';

sgtitle('RREX Cross-Ridge Transect 2 (OVIDE)','FontSize',16, 'FontWeight', 'bold','FontName','LMRoman10')

% saveas(gcf,'10.TSDiagram_XRidge2.png')

% T-S Diagram of the water masses
RREXWaterMasses(temp2015(:,a),sal2015(:,a),dens2015(:,a),oxy2015(:,a),'2015 Cross-Ridge 2')
% saveas(gcf,'10a.TSDiagram_XRidge2.png')

RREXWaterMasses(temp2017(:,b),sal2017(:,b),dens2017(:,b),oxy2017(:,b),'2017 Cross-Ridge 2')
% saveas(gcf,'10b.TSDiagram_XRidge2.png')

%% T-S Diagram West of Ridge 

a=westridge_2015; b=westridge_2017;
s2015=sal2015(:,a); s2017=sal2017(:,b); s2015=s2015(:); s2017=s2017(:);
t2015=temp2015(:,a); t2017=temp2017(:,b); t2015=t2015(:); t2017=t2017(:);
o2015=oxy2015(:,a); o2017=oxy2017(:,b); o2015=o2015(:); o2017=o2017(:);

figure(); set(gcf, 'Position',  [100, 100, 1600, 700])
subplot(1,2,1)
scatter(s2015,t2015,5,o2015,'filled')
colormap jet; caxis([240 300]);
xlim([34.5 35.3]); ylim([1 11])
hold on
[c,h]=contour(si,thetai,sigma_sca,density_levels,'--k');
clabel(c, h,'FontSize', 11, 'FontWeight', 'bold','LabelSpacing', 120, 'Color', 'k');
xlabel('Salinity','FontSize',13)
ylabel('Temperature','FontSize',13)
title('2015','FontSize',15)
grid on
hold off

subplot(1,2,2)
scatter(s2017,t2017,5,o2017,'filled')
colormap jet; caxis([240 300])
xlim([34.5 35.3]); ylim([1 11])
hold on
[c,h]=contour(si,thetai,sigma_sca,density_levels,'--k');
clabel(c, h,'FontSize', 11, 'FontWeight', 'bold','LabelSpacing', 120, 'Color', 'k');
xlabel('Salinity','FontSize',13)
title('2017','FontSize',15)
grid on
hold off

% Add colorbar to the right
cb = colorbar('Position', [0.92 0.14 0.015 0.74]); %[position_x position_y width_x width_y]
cb.Label.String = 'Oxygen Concentration (μmol/kg)';
cb.FontSize = 12;
cb.FontWeight = 'bold';

sgtitle('RREX West of Ridge Transect','FontSize',16, 'FontWeight', 'bold','FontName','LMRoman10')

% saveas(gcf,'11.TSDiagram_WRidge.png')

% T-S Diagram of the water masses
RREXWaterMasses(temp2015(:,a),sal2015(:,a),dens2015(:,a),oxy2015(:,a),'2015 West-Ridge')
% saveas(gcf,'11a.TSDiagram_WRidge.png')

RREXWaterMasses(temp2017(:,b),sal2017(:,b),dens2017(:,b),oxy2017(:,b),'2017 West-Ridge')
% saveas(gcf,'11b.TSDiagram_WRidge.png')

%% T-S Diagram East of Ridge 

a=eastridge_2015;
s2015=sal2015(:,a);  s2015=s2015(:); 
t2015=temp2015(:,a); t2015=t2015(:); 
o2015=oxy2015(:,a);  o2015=o2015(:); 

figure(); set(gcf, 'Position',  [100, 100, 850, 700])
scatter(s2015,t2015,5,o2015,'filled')
colormap jet; caxis([240 300]); cb=colorbar;
cb.Label.String = 'Oxygen Concentration (μmol/kg)';
xlim([34.5 35.3]); ylim([1 11])
hold on
[c,h]=contour(si,thetai,sigma_sca,density_levels,'--k');
clabel(c, h,'FontSize', 11, 'FontWeight', 'bold','LabelSpacing', 120, 'Color', 'k');
xlabel('Salinity','FontSize',13)
ylabel('Temperature','FontSize',13)
grid on
hold off

sgtitle('RREX 2015 East of Ridge Transect','FontSize',16, 'FontWeight', 'bold','FontName','LMRoman10')

% saveas(gcf,'12.TSDiagram_ERidge.png')

% T-S Diagram of the water masses
RREXWaterMasses(temp2015(:,a),sal2015(:,a),dens2015(:,a),oxy2015(:,a),'2015 East-Ridge')
% saveas(gcf,'12a.TSDiagram_ERidge.png')

%% T-S Diagram South of Ridge 

a=southridge_2015; b=southridge_2017;
s2015=sal2015(:,a); s2017=sal2017(:,b); s2015=s2015(:); s2017=s2017(:);
t2015=temp2015(:,a); t2017=temp2017(:,b); t2015=t2015(:); t2017=t2017(:);
o2015=oxy2015(:,a); o2017=oxy2017(:,b); o2015=o2015(:); o2017=o2017(:);

figure(); set(gcf, 'Position',  [100, 100, 1600, 700])
subplot(1,2,1)
scatter(s2015,t2015,5,o2015,'filled')
colormap jet; caxis([240 300]);
xlim([34.5 35.3]); ylim([1 11])
hold on
[c,h]=contour(si,thetai,sigma_sca,density_levels,'--k');
clabel(c, h,'FontSize', 11, 'FontWeight', 'bold','LabelSpacing', 120, 'Color', 'k');
xlabel('Salinity','FontSize',13)
ylabel('Temperature','FontSize',13)
title('2015','FontSize',15)
grid on
hold off

subplot(1,2,2)
scatter(s2017,t2017,5,o2017,'filled')
colormap jet; caxis([240 300])
xlim([34.5 35.3]); ylim([1 11])
hold on
[c,h]=contour(si,thetai,sigma_sca,density_levels,'--k');
clabel(c, h,'FontSize', 11, 'FontWeight', 'bold','LabelSpacing', 120, 'Color', 'k');
xlabel('Salinity','FontSize',13)
title('2017','FontSize',15)
grid on
hold off

% Add colorbar to the right
cb = colorbar('Position', [0.92 0.14 0.015 0.74]); %[position_x position_y width_x width_y]
cb.Label.String = 'Oxygen Concentration (μmol/kg)';
cb.FontSize = 12;
cb.FontWeight = 'bold';

sgtitle('RREX South of Ridge Transect','FontSize',16, 'FontWeight', 'bold','FontName','LMRoman10')

% saveas(gcf,'13.TSDiagram_SouthRidge.png')

% T-S Diagram of the water masses
RREXWaterMasses(temp2015(:,a),sal2015(:,a),dens2015(:,a),oxy2015(:,a),'2015 South of Ridge')
% saveas(gcf,'13a.TSDiagram_SouthRidge.png')

RREXWaterMasses(temp2017(:,b),sal2017(:,b),dens2017(:,b),oxy2017(:,b),'2017 South of Ridge')
% saveas(gcf,'13b.TSDiagram_SouthRidge.png')

%% ADCP Data

filenames = dir(fullfile(folder,'*khz.nc')); % Check the variable position

u=ncread(filenames(2).name,'UVEL_ADCP');
v=ncread(filenames(2).name,'VVEL_ADCP');
w=ncread(filenames(2).name,'WVEL_ADCP');
bindepth=ncread(filenames(2).name,'DEPH');
juldate=ncread(filenames(2).name,'JULD');
lat=ncread(filenames(2).name,'SecLat');
lon=ncread(filenames(2).name,'SecLon');
bathymetry=ncread(filenames(2).name,'BATHY');

ref=datetime('1950-01-01 00:00:00');
time=ref+days(juldate);

%% Plot the whole time series

figure(); set(gcf, 'Position',  [100, 100, 1600, 500])
ax1=subplot(1,3,1);
pcolor(time,-bindepth,u*100); shading flat
c=colorbar; caxis([-15 15]); colormap(ax1,slanCM('seismic'));
set(gca,'YDir','reverse'); ylim([100 2000])
ylabel('Depth [m]'); title('u [cm/s]');
hold on; area(time,-bathymetry,4000,'facecolor',[0.6 0.6 0.6],'edgecolor','k'); hold off

ax2=subplot(1,3,2);
pcolor(time,-bindepth,v*100); shading flat
c=colorbar; caxis([-15 15]); colormap(ax2,slanCM('seismic'));
set(gca,'YDir','reverse'); ylim([100 2000])
ylabel('Depth [m]'); title('v [cm/s]');
hold on; area(time,-bathymetry,4000,'facecolor',[0.6 0.6 0.6],'edgecolor','k'); hold off

ax3=subplot(1,3,3);
pcolor(time,-bindepth,w*100); shading flat
c=colorbar; caxis([-15 15]); colormap(ax3,slanCM('seismic'));
set(gca,'YDir','reverse'); ylim([100 2000])
ylabel('Depth [m]'); title('v [cm/s]');
hold on; area(time,-bathymetry,4000,'facecolor',[0.6 0.6 0.6],'edgecolor','k'); hold off

%% Plot map of positions

figure(); set(gcf, 'Position',  [100, 100, 950, 575])
ax1 = axes('Position',[0.07 0.12 0.86 0.78]); % adjust margins
pcolor(lonsub,latsub,zsub); shading flat
cm=colormap(ax1,flipud(slanCM('blues'))); caxis(ax1,[-4500 0]);
cb = colorbar; set(cb, 'Visible', 'off');
% Now lets add the scatter plot

% Top axes: transparent for scatter (same position)
ax2 = axes('Position', ax1.Position);
ax2.Color = 'none';                      % transparent
ax2.XLim = ax1.XLim; ax2.YLim = ax1.YLim;
ax2.FontSize = 13;
hold(ax2,'on')


% Plot scatter on ax2
s1 = scatter(ax2,lon, lat,[],datenum(time), 'filled');  
ax2.XTick = []; ax2.YTick = [];           % hide duplicate ticks if desired
xlabel(ax1,'Longitude'); ylabel(ax1,'Latitude');
linkaxes([ax1 ax2]) 

title('RREX 2015')
colorbar; cbdate; cm=colormap(ax2,slanCM('oranges'))
hold off

%% 2017

filename='AT_RREX_OS38_osite_m09_004_12_fhv21.nc';

u=ncread(filename,'UVEL_ADCP');
u=ncread(filename,'UVEL_ADCP');
v=ncread(filename,'VVEL_ADCP');
w=ncread(filename,'WVEL_ADCP');
bindepth=ncread(filename,'DEPH');
juldate=ncread(filename,'JULD');
lat=ncread(filename,'LATITUDE');
lon=ncread(filename,'LONGITUDE');
bathymetry=ncread(filename,'BATHY');

ref=datetime('1950-01-01 00:00:00');
time=ref+days(juldate);

%% Plot 

figure(); set(gcf, 'Position',  [100, 100, 950, 575])
ax1 = axes('Position',[0.07 0.12 0.86 0.78]); % adjust margins
pcolor(lonsub,latsub,zsub); shading flat
cm=colormap(ax1,flipud(slanCM('blues'))); caxis(ax1,[-4500 0]);
cb = colorbar; set(cb, 'Visible', 'off');
% Now lets add the scatter plot

% Top axes: transparent for scatter (same position)
ax2 = axes('Position', ax1.Position);
ax2.Color = 'none';                      % transparent
ax2.XLim = ax1.XLim; ax2.YLim = ax1.YLim;
ax2.FontSize = 13;
hold(ax2,'on')


% Plot scatter on ax2
s1 = scatter(ax2,lon, lat,[],datenum(time), 'filled');  
ax2.XTick = []; ax2.YTick = [];           % hide duplicate ticks if desired
xlabel(ax1,'Longitude'); ylabel(ax1,'Latitude');
linkaxes([ax1 ax2]) 

title('RREX 2017')
colorbar; cbdate; cm=colormap(ax2,slanCM('oranges'))
hold off

% This script is for interpolating and seeing the difference between the
% transects

% We load paths and colorbars
addpath(genpath('C:/Users/mitg1n25/Desktop/PhD/PhD_Coding'))
%addpath(genpath('D:/Respaldo PC/iop/materia/Magister/Semestre 2/PRODIGY/m_map/'))
set(0, 'DefaultAxesFontSize', 12);
set(0, 'DefaultAxesTitleFontSizeMultiplier', 1.15)
set(0, 'DefaultAxesFontName', 'LMRoman17');
set(0, 'DefaultAxesFontWeight', 'bold');


%% First, we load the variables 

% load("RREX2015_processed_VMP6000_ManuTest.mat")

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
N2015=ncread(filenames(1).name,'BRV2'); % Brunt Vaisala frequency squared
f2015=ncread(filenames(1).name,'VORP'); % Planetary Vorticity
n2015=length(lat2015);

lat2017=ncread(filenames(2).name,'LATITUDE');
lon2017=ncread(filenames(2).name,'LONGITUDE');
bottom2017=ncread(filenames(2).name,'BOTTOM_DEPTH');
pres2017=ncread(filenames(2).name,'PRES'); % Pressure
temp2017=ncread(filenames(2).name,'TEMP'); % In situ temperature
sal2017=ncread(filenames(2).name,'PSAL'); % Practical Salinity
oxy2017=ncread(filenames(2).name,'OXYK'); % Oxygen concentration in umol/kg
dens2017=ncread(filenames(2).name,'SIG0'); % Density anomaly referred to p=0
N2017=ncread(filenames(2).name,'BRV2'); % Brunt Vaisala frequency squared
f2017=ncread(filenames(2).name,'VORP'); % Planetary Vorticity
n2017=length(lat2017);

%% Calculates potential temperature and absolute salinity

SA2015=gsw_SA_from_SP(sal2015,pres2015,lon2015,lat2015);
SA2017=gsw_SA_from_SP(sal2017,pres2017,lon2017,lat2017);

CT2015 = gsw_CT_from_t(SA2015,temp2015,pres2015);
CT2017 = gsw_CT_from_t(SA2017,temp2017,pres2017);

temp2015 = gsw_pt_from_t(SA2015,temp2015,pres2015);
temp2017 = gsw_pt_from_t(SA2017,temp2017,pres2017);

%% Separation of transects

ridge_2015=[68:84 89:102 110:133];
southridge_2015=126:133;
eastridge_2015=46:55;
westridge_2015=56:67;
trans2_2015=26:45;
trans1_2015=[3:10 15 16 21:25];

ridge_2017=[57:70 77:86 92:126];
southridge_2017=115:126;
trans1_2017=[2:9 12:18];
trans2_2017=[19:29 31:39 41:44];
westridge_2017=45:56;

%% Calculates the Interpolated Variables (With Extrapolated Boundaries) 

transect={'ridge','trans1','trans2','westridge','southridge'};
direction={'lat','lon','lon','lon','lat'};

% Creates the names of the variables that will go inside the struct

namecellT2015 = arrayfun(@(i) sprintf('T2015in_%s', transect{i}), 1:5, 'UniformOutput', false);
namecellT2017 = arrayfun(@(i) sprintf('T2017in_%s', transect{i}), 1:5, 'UniformOutput', false);
namecellS2015 = arrayfun(@(i) sprintf('S2015in_%s', transect{i}), 1:5, 'UniformOutput', false);
namecellS2017 = arrayfun(@(i) sprintf('S2017in_%s', transect{i}), 1:5, 'UniformOutput', false);
namecellSigma2015 = arrayfun(@(i) sprintf('Sigma2015in_%s', transect{i}), 1:5, 'UniformOutput', false);
namecellSigma2017 = arrayfun(@(i) sprintf('Sigma2017in_%s', transect{i}), 1:5, 'UniformOutput', false);
namecellO2015 = arrayfun(@(i) sprintf('O2015in_%s', transect{i}), 1:5, 'UniformOutput', false);
namecellO2017 = arrayfun(@(i) sprintf('O2017in_%s', transect{i}), 1:5, 'UniformOutput', false);
namecelldX = arrayfun(@(i) sprintf('dX_%s', transect{i}), 1:5, 'UniformOutput', false);
namecelldZ = arrayfun(@(i) sprintf('dZ_%s', transect{i}), 1:5, 'UniformOutput', false);
namecellBottom = arrayfun(@(i) sprintf('Bottom_%s', transect{i}), 1:5, 'UniformOutput', false);

% Defines variables used for plotting
k=[1 5 9 13];
column_labels = {'\theta [°C]', 'Salinity [PSU]', '\sigma_0 [kg/m^3]', 'DO [\mumol/kg]'};

figure('Position', [74, -43, 1812, 1065]);
for i=1:length(transect)-1
    % Defines the transect variables
    a=dynamicvariable(transect{i},'_2015');
    b=dynamicvariable(transect{i},'_2017');
    
    % Creates the transects
    p1=pres2015(:,a); T1=temp2015(:,a); b1=bottom2015(a);
    p2=pres2017(:,b); T2=temp2017(:,b); b2=bottom2017(b);
    s1=sal2015(:,a); o1=oxy2015(:,a);d1=dens2015(:,a);
    s2=sal2017(:,b); o2=oxy2017(:,b);d2=dens2017(:,b);

    % Determines if it uses longitude or latitude
    latlon=direction{i};
    if latlon(3)=='n'
        x1=lon2015(a); x2=lon2017(b);
    elseif latlon(3)=='t'
        x1=lat2015(a); x2=lat2017(b);
    end

    % Interpolates
    [T1i,T2i,dx, dz,bottomi] = RREXInterpolation(T1,x1,p1,b1,T2,x2,p2,b2,1,latlon);
    [S1i,S2i] = RREXInterpolation(s1,x1,p1,b1,s2,x2,p2,b2,2,latlon);
    [O1i,O2i] = RREXInterpolation(o1,x1,p1,b1,o2,x2,p2,b2,4,latlon);

    dim=size(T1i);
    Sigma1i=eos80_legacy_sigma(S1i,T1i,0); Sigma1i=reshape(Sigma1i,dim);
    Sigma2i=eos80_legacy_sigma(S2i,T2i,0); Sigma2i=reshape(Sigma2i,dim);

    % Makes a Figure containing the difference in all transects

    ax1=subplot(4,4,k(i));
    pcolor(dx, dz, T2i-T1i); shading flat; set(gca, 'YDir', 'reverse');
    clim(ax1,[-1.5 1.5]); colormap(ax1,slanCM('vik'));
    hold on; area(dx,bottomi,5000,'facecolor',[0.6 0.6 0.6],'edgecolor','k'); hold off 

    ax2=subplot(4,4,k(i)+1);
    pcolor(dx, dz, S2i-S1i); shading flat; set(gca, 'YDir', 'reverse');
    clim(ax2,[-0.2 0.2]); colormap(ax2,slanCM('delta'));
    hold on; area(dx,bottomi,5000,'facecolor',[0.6 0.6 0.6],'edgecolor','k'); hold off 

    ax3=subplot(4,4,k(i)+2);
    pcolor(dx, dz, Sigma2i-Sigma1i); shading flat; set(gca, 'YDir', 'reverse');
    clim(ax3,[-0.15 0.15]); colormap(ax3,slanCM('PuOr'));
    hold on; area(dx,bottomi,5000,'facecolor',[0.6 0.6 0.6],'edgecolor','k'); hold off 

    ax4=subplot(4,4,k(i)+3);
    pcolor(dx, dz, O2i-O1i); shading flat; set(gca, 'YDir', 'reverse');
    clim(ax4,[-25 25]); colormap(ax4,slanCM('coolwarm'));
    hold on; area(dx,bottomi,5000,'facecolor',[0.6 0.6 0.6],'edgecolor','k'); hold off 

    fig_pos = get(gcf, 'Position'); % Gets figure dimensions
    if i == 1
        cb1 = colorbar(ax1,'Position', [0.13, 0.94, 0.155, 0.015]);
        cb1.Label.String = column_labels{1};
        cb1.Label.FontSize = 12;
        cb1.Label.Rotation = 0; % Set to 0 for horizontal text
        cb1.Label.Position = [0, 2, 0]; % Move label above colorbar
        cb1.TickLength = 0.02;
        cb1.Orientation = 'horizontal';
        %cb1.Box = 'on';

        cb2 = colorbar(ax2,'Position', [0.336, 0.94, 0.155, 0.015]);
        cb2.Label.String = column_labels{2};
        cb2.Label.FontSize = 12;
        cb2.Label.Position = [0, 2, 0]; % Move label above colorbar
        cb2.Label.Rotation = 0; % Set to 0 for horizontal text
        cb2.TickLength = 0.02;
        cb2.Orientation = 'horizontal';

        cb3 = colorbar(ax3,'Position', [0.542, 0.94, 0.155, 0.015]);
        cb3.Label.String = column_labels{3};
        cb3.Label.FontSize = 12;
        cb3.Label.Position = [0, 2, 0]; % Move label above colorbar
        cb3.Label.Rotation = 0; % Set to 0 for horizontal text
        cb3.TickLength = 0.02;
        cb3.Orientation = 'horizontal';

        cb4 = colorbar(ax4,'Position', [0.748, 0.94, 0.155, 0.015]);
        cb4.Label.String = column_labels{4};
        cb4.Label.FontSize = 12;
        cb4.Label.Position = [0, 2, 0]; % Move label above colorbar
        cb4.Label.Rotation = 0; % Set to 0 for horizontal text
        cb4.TickLength = 0.02;
        cb4.Orientation = 'horizontal';
    end


    % Makes a struct that will be saved as a .MAT file
    RREX_Transects_Interpolated.(namecellT2015{i})=T1i;
    RREX_Transects_Interpolated.(namecellT2017{i})=T2i;
    RREX_Transects_Interpolated.(namecellS2015{i})=S1i;
    RREX_Transects_Interpolated.(namecellS2017{i})=S2i;
    RREX_Transects_Interpolated.(namecellSigma2015{i})=Sigma1i;
    RREX_Transects_Interpolated.(namecellSigma2017{i})=Sigma2i;
    RREX_Transects_Interpolated.(namecellO2015{i})=O1i;
    RREX_Transects_Interpolated.(namecellO2017{i})=O2i;
    RREX_Transects_Interpolated.(namecelldX{i})=dx;
    RREX_Transects_Interpolated.(namecelldZ{i})=dz;
    RREX_Transects_Interpolated.(namecellBottom{i})=bottomi;

end

figpath=('C:/Users/mitg1n25/Desktop/PhD/PhD_Coding/docs/figures/Hydrography_RREX/');
imgname='14.AllTransectDifference.png';
figname=fullfile(figpath, imgname);

% Make the figure have minimal borders when saving
set(gca, 'LooseInset', get(gca, 'TightInset'));
% print(gcf,figname, '-dpng', '-r0', '-loose')

% save([folder 'RREX_Transects_Interpolated.mat'], '-struct' , 'RREX_Transects_Interpolated')


%% This is If I want to interpolate into a same common grid (Not ready)

% transect={'ride','south','ovide','north'};
% section=transect{1};
% 
% if strcmp(section,'ride') % Defines x axis depending on the transect
%     load([path2015 'transport_geo/transport_RREX15_' section '_use.mat'],'X','tr_z');
%     load([path2015 'vitesse_abs/OS38_section_' section '_use.mat'],'v_abs','z_abs'); 
%     v2015=v_abs; X2015=X; T2015=tr_z; p2015=gsw_p_from_z(repmat(-z_abs,[1 length(X)]),X);
%     for i=1:length(X2015)
%         lastIdx = find(~isnan(v2015(:,i)), 1, 'last');
%         b2015(i) = p2015(lastIdx,i); % Finds bottom
%     end
% 
%     load([path2017 'transport_geo/transport_RREX17_' section '_use.mat'],'X','tr_z');
%     load([path2017 'vitesse_abs/OS38_section_' section '_use.mat'],'v_abs','z_abs','dpair_abs');
%     v2017=v_abs; X2017=X; T2017=tr_z; p2017=gsw_p_from_z(repmat(-z_abs,[1 length(X)]),X);
%     latlon='lat';
%     for i=1:length(X2017)
%         lastIdx = find(~isnan(v2017(:,i)), 1, 'last');
%         b2017(i) = p2017(lastIdx,i); % Finds bottom
%     end
% 
% else
%     load([path2015 'transport_geo/transport_RREX15_' section '_pfit.mat'],'X','tr_z');
%     load([path2015 'vitesse_abs/OS38_section_' section '_pfit.mat'],'v_abs','z_abs','lat_abs');
%     v2015=v_abs; X2015=X; T2015=tr_z; z2015=z_abs; p2015=gsw_p_from_z(repmat(-z_abs,[1 length(lat_abs)]),lat_abs);
%     for i=1:length(X2015)
%         lastIdx = find(~isnan(v2015(:,i)), 1, 'last');
%         b2015(i) = p2015(lastIdx,i); % Finds bottom
%     end
% 
%     load([path2017 'transport_geo/transport_RREX17_' section '_pfit.mat'],'X','tr_z');
%     load([path2017 'vitesse_abs/OS38_section_' section '_pfit.mat'],'v_abs','z_abs','lat_abs','dpair_abs');
%     v2017=v_abs; X2017=X; T2017=tr_z; z2017=z_abs; p2017=gsw_p_from_z(repmat(-z_abs,[1 length(lat_abs)]),lat_abs);
%     latlon='lon';
%     for i=1:length(X2017)
%         lastIdx = find(~isnan(v2017(:,i)), 1, 'last');
%         b2017(i) = p2017(lastIdx,i); % Finds bottom
%     end
% end
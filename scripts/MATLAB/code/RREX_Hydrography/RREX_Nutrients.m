% We load paths and colorbars
addpath(genpath('C:/Users/mitg1n25/Desktop/PhD/PhD_Coding'))
%addpath(genpath('D:/Respaldo PC/iop/materia/Magister/Semestre 2/PRODIGY/m_map/'))
set(0, 'DefaultAxesFontSize', 12);
set(0, 'DefaultAxesTitleFontSizeMultiplier', 1.15)
set(0, 'DefaultAxesFontName', 'LMRoman17');
set(0, 'DefaultAxesFontWeight', 'bold');
map = load('colormap_RREX.mat'); % colormap(map.cmap);
load REXXBathymetry.mat

% This is the script I'll use to plot the Discrete nutrient data of both RREX cruises

% Columns of the csv file

% 1. Station
% 2. Sample number (from 3 - 30) of 28 niskin bottles
% 3, 4, 5. Year, month, day.
% 6. Latitude
% 7. Longitude
% 8. Pressure CTD (dbar)
% 10. Temperature CTD
% 12. Salinity CTD (PSU)
% 14. Salinity Autosal (PSU) 
% 16. Oxygem CTD (umol/kg)
% 18. Oxygen Winkler (umol/kg)
% 20. pH
% 22. Nitrate (umol/kg)
% 24. Phosphate (umol/kg)
% 26. Silicate (umol/kg)


%% First, we load the variables 

% load("RREX2015_processed_VMP6000_ManuTest.mat")

folder='C:/Users/mitg1n25/Desktop/PhD/PhD_Coding/data/RREX/2015_Nutrients';
filenames = dir(fullfile(folder,'*.csv')); % 
data=csvread(filenames.name);

%% Transform the matrix into a more comprehensible format

data(data==-999)=NaN; % Delete missing values (flagged as -999)

id=unique(data(:,1)); % Separate unique stations
lat=unique(data(:,6),"stable"); lon=unique(data(:,7),"stable");

%% THIS WORKS BUT IT I NEED TO SEPARATE EACH MATRIX DEPENDING ON THE VARIABLE

% Initialize storage for 3D matrix
% Let's determine the structure first
n_profiles = length(id); % 133
n_variables = size(data,2);        % Number of columns

% Find maximum number of rows per profile
max_rows = 0;
for i = 1:n_profiles
    rows_for_profile = sum(data(:,1) == id(i)); % This calculates how much data we have per station
    max_rows = max(max_rows, rows_for_profile);
end

% Initialize 3D matrix with NaNs for missing data
data3d = NaN(max_rows, n_variables, n_profiles);

% Fill the 3D matrix
for i = 1:n_profiles
    % Get current profile ID
    pid = id(i);
    
    % Extract rows for this profile
    profile_rows = data(data(:,1) == pid, :);
    
    % Number of rows in this profile
    n_rows = size(profile_rows, 1);
    
    % Place data into 3D matrix
    data3d(1:n_rows, :, i) = profile_rows;
end

% Separate the variables
pressure=squeeze(data3d(:,8,:)); temperature=squeeze(data3d(:,10,:)); salinity=squeeze(data3d(:,14,:));
oxygen=squeeze(data3d(:,18,:)); pH=squeeze(data3d(:,20,:)); nitrate=squeeze(data3d(:,22,:));
phosphate=squeeze(data3d(:,24,:)); silicate=squeeze(data3d(:,26,:));  

%% Separation of transects

ridge_2015=[68:84 89:102 110:133]; %this considers both the ridge and the abysal plane
eastridge_2015=46:55;
westridge_2015=56:67;
trans2_2015=26:45;
trans1_2015=[3:10 15 16 21:25];

% We load bottom depth
folder='C:/Users/mitg1n25/Desktop/PhD/PhD_Coding/data/RREX/Hydrography';
filenames = dir(fullfile(folder,'*CTDO.nc')); % Check the variable position
bottom=ncread(filenames(1).name,'BOTTOM_DEPTH');

% Defining variables for plotting
trans={'ridge_2015','trans1_2015','trans2_2015','westridge_2015','eastridge_2015'};

column_labels = {'\theta [°C]', 'Salinity [PSU]', 'DO [\mumol/kg]', 'pH','Nitrate [\mumol/kg]','Silicate [\mumol/kg]','Phosphate [\mumol/kg]'};

%%  Plotting all the transects

figure('Position', [74, -100, 2200, 1100]);
axhandles = {};
k=[1, 8, 15, 22, 29];
trans={'ridge_2015','trans1_2015','trans2_2015','westridge_2015','eastridge_2015'};
column_labels = {'\theta [°C]', 'Salinity [PSU]', 'DO [\mumol/kg]', 'pH','Nitrate [\mumol/kg]','Silicate [\mumol/kg]','Phosphate [\mumol/kg]'};


for i=1:length(trans)

    % Defines variables for each transect
    if i==1
        dx=lat(dynamicvariable(trans{i},''));
    else
        dx=lon(dynamicvariable(trans{i},''));
    end
    b=bottom(dynamicvariable(trans{i},''));
    P=pressure(:,dynamicvariable(trans{i},''));
    T=temperature(:,dynamicvariable(trans{i},''));
    S=salinity(:,dynamicvariable(trans{i},''));
    O=oxygen(:,dynamicvariable(trans{i},''));
    PH=pH(:,dynamicvariable(trans{i},''));
    Ni=nitrate(:,dynamicvariable(trans{i},''));
    Si=silicate(:,dynamicvariable(trans{i},''));
    Pho=phosphate(:,dynamicvariable(trans{i},''));

    % Make each subplot
    ax1=subplot(5,7,k(i));
    pcolor(dx,P,T); shading flat
    clim([2 10]); colormap(ax1,slanCM('turbo'));
    set(gca,'YDir','reverse');
    hold on; h=area(dx,b,5000,'facecolor',[0.6 0.6 0.6],'edgecolor','k'); hold off
    ylabel(ax1,'Pressure [dbar]');
    axhandles{end+1}=ax1;
    
    ax2=subplot(5,7,k(i)+1);
    pcolor(dx,P,S); shading flat
    clim([34.6 35.2]); colormap(ax2,slanCM('haline'));
    set(gca,'YDir','reverse');
    hold on; h=area(dx,b,5000,'facecolor',[0.6 0.6 0.6],'edgecolor','k'); hold off
    axhandles{end+1}=ax2;

    ax3=subplot(5,7,k(i)+2);
    pcolor(dx,P,O); shading flat
    clim([240 300]); colormap(ax3,slanCM('jet'));
    set(gca,'YDir','reverse');
    hold on; h=area(dx,b,5000,'facecolor',[0.6 0.6 0.6],'edgecolor','k'); hold off
    axhandles{end+1}=ax3;

    ax4=subplot(5,7,k(i)+3);
    pcolor(dx,P,PH); shading flat
    clim([7.7 7.8]); colormap(ax4,flipud(slanCM('parula')));
    set(gca,'YDir','reverse');
    hold on; h=area(dx,b,5000,'facecolor',[0.6 0.6 0.6],'edgecolor','k'); hold off
    axhandles{end+1}=ax4;

    ax5=subplot(5,7,k(i)+4);
    pcolor(dx,P,Ni); shading flat
    clim([2 20]); colormap(ax5,slanCM('neon'));
    set(gca,'YDir','reverse');
    hold on; h=area(dx,b,5000,'facecolor',[0.6 0.6 0.6],'edgecolor','k'); hold off
    axhandles{end+1}=ax5;

    ax6=subplot(5,7,k(i)+5);
    pcolor(dx,P,Si); shading flat
    clim([3 12]); colormap(ax6,slanCM('neon'));
    set(gca,'YDir','reverse');
    hold on; h=area(dx,b,5000,'facecolor',[0.6 0.6 0.6],'edgecolor','k'); hold off
    axhandles{end+1}=ax6;

    ax7=subplot(5,7,k(i)+6);
    pcolor(dx,P,Pho); shading flat
    clim([0.3 1.3]); colormap(ax7,slanCM('neon'));
    set(gca,'YDir','reverse');
    hold on; h=area(dx,b,5000,'facecolor',[0.6 0.6 0.6],'edgecolor','k'); hold off
    axhandles{end+1}=ax7;

    % set(ax2, 'YTick', []); set(ax3, 'YTick', []); set(ax4, 'YTick', []);
    % set(ax5, 'YTick', []); set(ax6, 'YTick', []); set(ax7, 'YTick', []);

    if i == 1 % For adding colorbars at the top of the plot
        cb1 = colorbar(ax1,'Position', [0.13, 0.885, 0.085, 0.012]);
        cb1.Label.String = column_labels{1};
        cb1.Label.FontSize = 12; cb1.Label.Rotation = 0; % Set to 0 for horizontal text
        cb1.TickLength = 0.02; cb1.Orientation = 'horizontal';

        cb2 = colorbar(ax2,'Position', [0.13+0.1149, 0.885, 0.085, 0.012]);
        cb2.Label.String = column_labels{2};
        cb2.Label.FontSize = 12; cb2.Label.Rotation = 0; % Set to 0 for horizontal text
        cb2.TickLength = 0.02; cb2.Orientation = 'horizontal';

        cb3 = colorbar(ax3,'Position', [0.13+(2*0.115), 0.885, 0.085, 0.012]);
        cb3.Label.String = column_labels{3};
        cb3.Label.FontSize = 12; cb3.Label.Rotation = 0; % Set to 0 for horizontal text
        cb3.TickLength = 0.02; cb3.Orientation = 'horizontal';

        cb4 = colorbar(ax4,'Position', [0.13+(3*0.115), 0.885, 0.085, 0.012]);
        cb4.Label.String = column_labels{4};
        cb4.Label.FontSize = 12; cb4.Label.Rotation = 0; % Set to 0 for horizontal text
        cb4.TickLength = 0.02; cb4.Orientation = 'horizontal';
        xlabel(ax4,'Latitude °N');

        cb5 = colorbar(ax5,'Position', [0.13+(4*0.115), 0.885, 0.085, 0.012]);
        cb5.Label.String = column_labels{5};
        cb5.Label.FontSize = 12; cb5.Label.Rotation = 0; % Set to 0 for horizontal text
        cb5.TickLength = 0.02; cb5.Orientation = 'horizontal';

        cb6 = colorbar(ax6,'Position', [0.13+(5*0.115), 0.885, 0.085, 0.012]);
        cb6.Label.String = column_labels{6};
        cb6.Label.FontSize = 12; cb6.Label.Rotation = 0; % Set to 0 for horizontal text
        cb6.TickLength = 0.02; cb6.Orientation = 'horizontal';

        cb7 = colorbar(ax7,'Position', [0.13+(6*0.115), 0.885, 0.085, 0.012]);
        cb7.Label.String = column_labels{7};
        cb7.Label.FontSize = 12; cb7.Label.Rotation = 0; % Set to 0 for horizontal text
        cb7.TickLength = 0.02; cb7.Orientation = 'horizontal';

    elseif i==5
        xlabel(ax4,'Longitude °W');
    end

end


% This is for shifting the plots down
shift_down1=0.05; shift_down2=0.04; % Amount to shift down (adjust as needed)
shift_down3=0.03; shift_down4=0.02;

j=1;
for h = axhandles
    pos = get(h{1}, 'Position');
    if j>28
        pos(2) = pos(2); % Leave the last row in the original place
    elseif j<29 && j>21
        pos(2) = pos(2) - shift_down4; % 4th row
    elseif j<22 && j>14
        pos(2) = pos(2) - shift_down3; % 3rd row
    elseif j<15 && j>7
        pos(2) = pos(2) - shift_down2; % 2nd row
    else
        pos(2) = pos(2) - shift_down1; % First row down
    end
    set(h{1}, 'Position', pos);
    j=j+1;
end

set(gca, 'LooseInset', get(gca, 'TightInset'));
figname=fullfile('C:\Users\mitg1n25\Desktop\PhD\PhD_Coding\docs\figures\Hydrography_RREX', '18.Nutrients2015.png');
exportgraphics(gcf,figname)
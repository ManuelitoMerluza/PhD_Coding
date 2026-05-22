function [T_sum2015, T_sum2017, X_sum2015, X_sum2017, T_mag2015, T_mag2017] = RREX_ComputesTransport_WaterMasses(transect,WM,method)

%  This function computes the cumulative transport for a specific water mass
%  You will need the .mat output file that is calculated using Bieito's OMP
%  python script.
%  You can choose any water mass from those that appears on the list

% Inputs
% 
% transect:      'ride' 'south' 'ovide' 'north'
% WM:            'NACW', 'SAW', 'SPMW', 'SAIW', 'ISW', 'LSW', 'LSW', 'ISOW', 'LDW'
%
% method:        'mean', any other string :p 
%                 This option is for the method used for
%                 making the product between the transport and the water
%                 mass percentage. If you choose 'mean' it will take the
%                 average water mass concentration at each station and then
%                 multiply it to the total transport in that location. The
%                 other option is making a product between each water mass
%                 percentage and transport, after which the result in
%                 summed verticale to end up with the total transport.

% Outputs
%
% T_sum:
% X_sum:
% T_mag

% Comment for the digital archeologist from the future:
% For some reason, Ivane's transport outputs for the 2017 cruise are already interpolated to
% the position of the original CTD location. This means to get the proper
% results for each layer, I need to calculate the sum of the transport
% inside the layer and then interpolated to the CTD. Just like I did for
% the 2015 cruises. This is relevant because there is no line of code
% dedicated to this interpolation inside Ivane's files and it adds another
% source of uncertainty to the calculation.


%% Loads paths that will load variables related to transport

addpath(genpath('C:/Users/mitg1n25/Desktop/PhD/PhD_coding'))

% Paths where Absolute Velocity Data is stored
path2015='C:/Users/mitg1n25/Desktop/PhD/PhD_Coding/data/RREX/Ivane_output_RREX15/transport_geo/';
path2017='C:/Users/mitg1n25/Desktop/PhD/PhD_Coding/data/RREX/Ivane_output_RREX17/transport_geo/';
%Ekpath2017='C:/Users/mitg1n25/Desktop/PhD/PhD_Coding/data/RREX/Ivane_output_RREX17/transport_Ekman/';
%Ekpath2015='C:/Users/mitg1n25/Desktop/PhD/PhD_Coding/data/RREX/Ivane_output_RREX15/transport_Ekman/';

%% Defines the stations for each transect (Original CTD locations)

ride_2015=[68:84 89:102 110:133];
north_2015=46:67;
ovide_2015=26:45;
south_2015=[3:10 15 16 21:25];

ride_2017=[56:69 76:125];
south_2017=[1:8 11:17];
ovide_2017=[18:20 22:24 27:28 43:-1:41 38:-1:31];
north_2017=[44:55 57];

%transects2015={ride_2015, south_2015, ovide_2015, north_2015};
%transects2017={ride_2017, south_2017, ovide_2017, north_2017};

transects2015=dynamicvariable(transect,'_2015');
transects2017=dynamicvariable(transect,'_2017');

%% Loads and Defines water mass

WMN = {'NACW', 'SAW', 'SPMW', 'SAIW', 'ISW', 'LSW', 'ISOW', 'LDW'};
match = strcmp(WM, WMN);
WMi = find(match); % This is the position of the water mass in matrix

% 2015
load('RREX2015_Water_Mass_fractions_6poly.mat','X2015')
X=permute(X2015,[2 1 3]); % Changes dimensions for consistency
X=X(:,transects2015,:); % Subsamples the transect
% This is for the case we take the average
X_mean=squeeze(mean(X,1,"omitmissing")); 
X_mean=(X_mean(1:end-1,:)+X_mean(2:end,:))*0.5;
WMP2015_mean=X_mean(:,WMi);
% This is for the other case
X(isnan(X))=0; % Removes NaN
WMP2015 = (X(:,1:end-1,:)+X(:,2:end,:))*0.5; % Averages so it has the same size as Vgeo
WMP2015=squeeze(WMP2015(:,:,WMi)); % Changes NaN for 0 and selects the water mass
%WMP2015(isnan(WMP2015))=0;

% 2017
load('RREX2017_Water_Mass_fractions_6poly.mat','X2017')
X=permute(X2017,[2 1 3]);
X=X(:,transects2017,:);
% This is for the case we take the average
X_mean=squeeze(mean(X,1,"omitmissing")); 
X_mean=(X_mean(1:end-1,:)+X_mean(2:end,:))*0.5;
WMP2017_mean=X_mean(:,WMi);
% This is for the other case
X(isnan(X))=0; % Removes NaN
WMP2017 = (X(:,1:end-1,:)+X(:,2:end,:))*0.5;
WMP2017=squeeze(WMP2017(:,:,WMi));
%WMP2017(isnan(WMP2017))=0;

%% Loads the transport variables and calculates the water mass transport

% 2015
if strcmp(transect,'ride')
   load([path2015 'transport_RREX15_' transect '_use.mat']);
else 
   load([path2015 'transport_RREX15_' transect '_pfit.mat']);
end
X_ctd2015=X_ctd; X2015=X;
T_tot1=T_tot;
% We make a product between the water mass percentages and the transport
tr_z2015=tr_z.*WMP2015; % This is the important part

% 2017
load([path2017 'transport_RREX17_' transect '_pfit.mat']);
% Only the north section uses constant slope as bottom triangles
if strcmp(transect,'south') || strcmp(transect,'ovide') || strcmp(transect,'ride')
    load([path2017 'tr_z_RREX17_' transect '_pfit.mat']);
elseif strcmp(transect,'north')
    load([path2017 'tr_z_RREX17_' transect '_cstslope.mat']);
end
X2017=X; X_ctd2017=X_ctd; 
T_tot2=T_tot;
tr_z2017=tr_z.*WMP2017; % This is the important part

if strcmp(method,'mean')
    % Makes a product between the station average water mass percentage and the total transport
    T_tot2015=T_tot1.*WMP2015_mean';
    T_tot2017=T_tot2.*WMP2017_mean';
else
    % Calculates the total water mass transport for each lat/lon position
    T_tot2015 = sum(tr_z2015,1);
    T_tot2017 = sum(tr_z2017,1);
end

%% Calculates the cumulative transport per transect


% Ridge
if strcmp(transect,'ride')
    % 2015
    X_sum=[X_ctd2015(1); X2015]; % Adds the CTD location where the sumation start
    T=zeros(1,length(T_tot2015)+1); T(2:end)=T_tot2015; % Creates the transport vector with a zero on the start
    T=interp1(X_sum,T,X_ctd2015,'pchip','extrap'); % Interpolates to have the same locations as the CTD
    T_sum=cumsum(T); % Computes the cumulative sum
    X_sum2015=X_sum; T_sum2015=T_sum; 
    % Defines the transport between sections
    T_ride_ovide=T_sum(17); T_ride_south=sum(T(18:31));
    T_ride_nac=sum(T(32:40)); T_ride_end=sum(T(41:end));
    % Extract the values into a vector
    T_mag2015=round([T_ride_end T_ride_nac T_ride_south T_ride_ovide],1);

    % 2017
    T=zeros(1,length(T_tot2017)+1); T(2:end)=T_tot2017;
    T_sum2017=cumsum(T'); X_sum2017=X_ctd2017;
    T_ride_ovide=T_sum2017(14); T_ride_south=sum(T(15:30));
    T_ride_nac=sum(T(31:49)); T_ride_end=sum(T(50:62));
    T_mag2017=round([T_ride_end T_ride_nac T_ride_south T_ride_ovide],1);

elseif strcmp(transect,'south')
    %2015
    % In this case we separate the section in two in order to get the
    % sumation from the ridge (where transport=0)
    % West part
    X_sum1=[X_ctd2015(9); X2015(9:14)];
    T_sum1=zeros(1,7); T_sum1(2:end)=T_tot2015(9:14);
    T_sum1=interp1(X_sum1,T_sum1,X_ctd2015(9:end),'linear','extrap');
    T_sum1=cumsum(T_sum1);
    % East part
    X_sum2=[X2015(1:8); X_ctd2015(9)]; T_sum2=zeros(1,9);
    T_sum2(1:8)=T_tot2015(1:8); T_sum2=interp1(X_sum2,T_sum2,X_ctd2015(1:9),'nearest','extrap');
    T_sum2=cumsum(T_sum2,'reverse');
    % Merge both
    X_sum2015=X_ctd2015; T_sum2015=[T_sum2(1:8); T_sum1];
    T_south_west=T_sum1(6) ; % South transect west of ridge
    T_south_east=T_sum2(1) ; % South transect east of ridge
    T_mag2015=round([T_south_west T_south_east],1);

    % 2017    
    X_sum1=[X_ctd2017(8); X2017(8:14)]; T_sum1=zeros(1,8); T_sum1(2:end)=T_tot2017(8:14);
    T_sum1=interp1(X_sum1,T_sum1,X_ctd2017(8:end),'linear','extrap');
    T_sum1=cumsum(T_sum1); 
    % West part
    X_sum2=[X2017(1:7); X_ctd2017(8)]; T_sum2=zeros(1,8); T_sum2(1:7)=T_tot2017(1:7);
    T_sum2=interp1(X_sum2,T_sum2,X_ctd2017(1:8),'next','extrap'); %next 7.7
    T_sum2=cumsum(T_sum2,'reverse');
    % Merges both
    X_sum2017=X_ctd2017; T_sum2017=[T_sum2; T_sum1(2:end)];
    T_south_west=T_sum2(2) ; % South transect west of ridge
    T_south_east=T_sum1(7) ; % South transect east of ridge
    T_mag2017=round([T_south_west T_south_east],1);

elseif strcmp(transect,'ovide')
    % 2015
    % West of ridge
    X_sum1=[X2015(1:9); X_ctd2015(10)];
    T_sum1=zeros(1,10); T_sum1(1:end-1)=T_tot2015(1:9);
    T_sum1=interp1(X_sum1,T_sum1,X_ctd2015(1:10),'next','extrap');
    T_sum1=cumsum(T_sum1,'reverse');
    % East of ridge
    X_sum2=[X_ctd2015(10); X2015(10:end)];
    T_sum2=zeros(1,11); T_sum2(2:end)=T_tot2015(10:end);
    T_sum2=interp1(X_sum2,T_sum2,X_ctd2015(10:end),'previous','extrap');
    T_sum2=cumsum(T_sum2);
    % Total cumulative transport (merge both)
    X_sum2015=X_ctd2015; T_sum2015=[T_sum1; T_sum2(2:end)];
    % Defines the transport between sections
    T_ovide_west=T_sum1(4) ; % OVIDE transect west of ridge
    T_ovide_east=T_sum2(6) ; % OVIDE transect east of ridge
    T_mag2015=round([T_ovide_west T_ovide_east],1);

    % 2017
    T=zeros(1,19); T(1:9)=T_tot2017(1:9); T(11:end)=T_tot2017(10:end);
    X_sum=[X2017(1:9); X_ctd2017(10); X2017(10:end)];
    [X_sum, s]=sort(X_sum); T=T(s); X_ctd2017=X_ctd2017(s);
    
    T_sum1=interp1(X_sum(1:10),T(1:10),X_ctd2017(1:10),"next","extrap");
    T_sum1=cumsum(T_sum1,'reverse');
    
    T_sum2=interp1(X_sum(10:end),T(10:end),X_ctd2017(10:end),"nearest","extrap");
    T_sum2=cumsum(T_sum2);
    
    X_sum2017=X_sum; T_sum2017=[T_sum1; T_sum2(2:end)];
    
    T_ovide_west=T_sum2017(6) ; % OVIDE transect west of ridge
    T_ovide_east=T_sum2017(16) ; % OVIDE transect east of ridge
    
    T_mag2017=round([T_ovide_west T_ovide_east],1);

elseif strcmp(transect,'north')
    % 2015
    % Sorts the variables in longitude
    [X2015, s]=sort(X2015); T_tot2015=T_tot2015(s); X_ctd2015=sort(X_ctd2015);
    % West side
    X_sum1=[X2015(1:11); X_ctd2015(12)];
    T_sum1=zeros(1,12); T_sum1(1:end-1)=T_tot2015(1:11);
    T_sum1=interp1(X_sum1,T_sum1,X_ctd2015(1:12),'next','extrap');
    T_sum1=cumsum(T_sum1,'reverse');
    % East side
    X_sum2=[X_ctd2015(12); X2015(12:end)];
    T_sum2=zeros(1,11); T_sum2(2:11)=T_tot2015(12:end);
    T_sum2=interp1(X_sum2,T_sum2,X_ctd2015(12:end),'linear','extrap');
    T_sum2=cumsum(T_sum2);
    X_sum2015=X_ctd2015; T_sum2015=[T_sum1; T_sum2(2:end)];

    T_north_west=T_sum1(5) ; % north transect west of ridge
    T_north_east=T_sum2(7) ; % north transect east of ridge
    T_mag2015=round([T_north_west T_north_east],1);

    % 2017
    X_sum1=[X2017; X_ctd2017(13)];
    T_sum1=zeros(1,13); T_sum1(1:end-1)=T_tot2017;
    T_sum1=interp1(X_sum1,T_sum1,X_ctd2017,'makima'); % Interpolates
    T_sum1=cumsum(T_sum1,'reverse');
    X_sum2017=X_ctd2017; T_sum2017=T_sum1;
   
    T_north_west=T_sum1(8) ; % north transect west of ridge
    T_mag2017=round(T_north_west,1);
end

% Saves the variables in the following directory:
% direct='C:/Users/mitg1n25/Desktop/PhD/PhD_Coding/data/RREX/Ivane_output_RREX15/transport_geo/';
% save([direct 'RREX_T_' WM '_' transect '.mat'],"T_mag2017","T_mag2015","T_sum2015","X_sum2015","T_sum2017","X_sum2017");


end






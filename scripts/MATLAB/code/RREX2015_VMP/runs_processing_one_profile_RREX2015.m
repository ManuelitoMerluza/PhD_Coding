clc
clear
addpath(genpath('../functions'))

%%%%%%%%%%%%%%%%%%%
%%%%% Parameters %
%%%%%%%%%%%%%%%%%%%%%%

info.minvel_detect = 0.5; % Minimum velocity detection for profile in m/s
info.pmin = 4; % Minimum depth
info.pmax = 4000; % Maximum depth
info.dp = 4; % Size of bins
info.dpD = 8; % Size of bins where dissipation is calculated
info.dpGr = 8; % Size of bins where the bakcround gradients are calculated
info.dpTr = 4; % Size of bins of tracers
info.prof_dir = 'down'; % Downcast of Upcast (options: up or down)
info.fmaxT = 30; % thermistors are noisy in this dataset from 35 Hz, needs cutting
info.k_HP_cut_T = 0.; % Makes a highpass filter for a particular frequency (CPM)
info.Tmethod = 'B'; % Only option
info.Tspec = 'K'; % B or K for the model of temperature spectra
info.system = 'Oce'; %Oce or lake name (does not apply)
info.Nfft = 512; %Length of the Fast Fourier Transform
info.Latitude = 60; % Latitude

%Rockland standard
info.time_res = nan;  %5.8;%Sebastiano % nan for rockland
info.time_res_speed = 'none';
info.pole = 'Double'; % Tiempo de respuesta del termistor, con Nan va a la formula por defecto que entrega rockland

%H factor
info.hfactor = 1/10.; % Tope de magnitud para consierar la varianza como real

PLOT = 0; % Options: 0 or 1

%%%%%%%%%%%%%%%%%
% FILES %%%%%%%%%%
%%%%%%%%%%%%%%%%%%

FILE_INDEX = 2; % Defines the file number that is going to be processed


folder_orig = 'C:/Users/mitg1n25/Desktop/PhD/Year 1 - 2026/Microstructure Data/RREX/2015_113061/'; % Defines the folder where the original data is
filenames = dir(fullfile(folder_orig,'*.p')); % Selects the files of the folder that have a .p extension (data)
filename = filenames(FILE_INDEX).name; % Isolates the file depending on the index

filename = filename(1:end-2); % Removes the .p from the name of the file

% folder = 'C:/Users/Manuelito/Desktop/PhD/Year 1 - 2026/Microstructure Data/OVIDE/VMP2008/patched/';
% eval(['!cp ',[folder_orig,filename],'.p ',[folder,filename],'.p'])
% patch_setupstr([folder,filename,'.p'],[folder_orig,'setup.cfg']);   

%ctd_file = 'C:/Users/Manuelito/Desktop/PhD/Year 1 - 2026/Microstructure Data/OVIDE/CTD/CTD2008_GOSHIP_35TH20080610_ctd.nc'


%loads the patched file
DAT=odas_p2mat([folder_orig,filename,'.p']);

%quick_look([folder_orig,filename,'.p'],info.pmin,info.pmax)

% if FILE_INDEX == 1
%     ctd_pres= ncread(ctd_file,'pressure',[1,3],[inf,1]);
%     ctd_tmp =  ncread(ctd_file,'ctd_temperature',[1,3],[inf,1]);
% 
%     iigood = isfinite(ctd_pres+ ctd_tmp);
%     ctd_temp_int = interp1(ctd_pres(iigood),ctd_tmp(iigood),DAT.P_slow);
% 
%     %iigood = DAT.sbc>20;
% 
%     x = DAT.T1_slow;
%     x= move_av(x,8);
%     %x(DAT.P_slow<info.pmin-info.dpTr) = nan;
%     ii_good = isfinite(x+ctd_temp_int);
%     p = polyfit(x(ii_good),ctd_temp_int(ii_good),1);
%     ctd_temp_c = polyval(p,x);
% 
%     DAT.sbt = ctd_temp_c;
% 
%     plot( ctd_temp_int,DAT.P_slow)
%     hold on
%     plot( ctd_temp_c,DAT.P_slow)
% end



% 
% if FILE_INDEX>=106 && FILE_INDEX<=115
%     fprintf('sticks to the original cfg')
%         %for station 049 keeps the original conf file. since the patched
%         %one was giving too large epsilon1
%         DAT =DAT0;
% else
%     fprintf('patched cfg')
%         DAT=odas_p2mat([folder_patched,filename,'.p']);
% end


tic
[BINNED0,SLOW0] = resolve_VMP_profile_shear_RREX2015(DAT,info,filename,PLOT);
toc

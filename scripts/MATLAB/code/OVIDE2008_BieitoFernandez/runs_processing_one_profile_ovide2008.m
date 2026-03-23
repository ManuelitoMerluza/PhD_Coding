clc
clear
addpath(genpath('functions'))

%%%%%%%%%%%%%%%%%%%
%%%%% Parameters %
%%%%%%%%%%%%%%%%%%%%%%

info.minvel_detect = 0.5; % Minimum velocity detection for profile in m/s
info.pmin = 4; % Minimum depth
info.pmax = 6000; % Maximum depth
info.dp = 4; % Size of bins
info.dpD = 8;
info.dpGr = 8;
info.dpTr = 4;
info.prof_dir = 'down'; % Downcast of Upcast (options: up or down)
info.fmaxT = 30; % thermistors are noisy in this dataset from 35 Hz, needs cutting
info.k_HP_cut_T = 0.;
info.Tmethod = 'B';
info.Tspec = 'K';
info.system = 'Oce';
info.Nfft = 512;
info.Latitude = 50; % Latitude

%Rockland standard
info.time_res = nan;  %5.8;%Sebastiano % nan for rockland
info.time_res_speed = 'none';
info.pole = 'Double';

%%%sebastiano paper
%info.time_res = 7.;%Sebastiano % nan for rockland
%%%info.time_res = 0.00001;

%Sommer [THIS IS CLEARLY TOO MUCH]
%info.time_res = 10.;%5.8;%Sebastiano % nan for rockland
%info.time_res_speed = 'none';
%info.pole = 'Double';

%H factor
info.hfactor = 1/10.;

PLOT = 0; % Options: 0 or 1

%%%%%%%%%%%%%%%%%
% FILES %%%%%%%%%%
%%%%%%%%%%%%%%%%%%

FILE_INDEX = 4; % Defines the file number that is going to be processed


folder_orig = 'C:/Users/Manuelito/Desktop/PhD/Year 1 - 2026/Microstructure Data/OVIDE/VMP2008/'; % Defines the folder where the original data is
filenames = dir(fullfile(folder_orig,'*.p')); % Selects the files of the folder that have a .p extension (data)
filename = filenames(FILE_INDEX).name; % Isolates the file depending on the index

filename = filename(1:end-2); % Removes the .p from the name of the file

folder = 'C:/Users/Manuelito/Desktop/PhD/Year 1 - 2026/Microstructure Data/OVIDE/VMP2008/patched/';
eval(['!cp ',[folder_orig,filename],'.p ',[folder,filename],'.p'])
patch_setupstr([folder,filename,'.p'],[folder_orig,'setup.cfg']);   

ctd_file = 'C:/Users/Manuelito/Desktop/PhD/Year 1 - 2026/Microstructure Data/OVIDE/CTD/CTD2008_GOSHIP_35TH20080610_ctd.nc'


%loads the patched file
DAT=odas_p2mat([folder,filename,'.p']);


if FILE_INDEX == 1
    ctd_pres= ncread(ctd_file,'pressure',[1,3],[inf,1]);
    ctd_tmp =  ncread(ctd_file,'ctd_temperature',[1,3],[inf,1]);

    iigood = isfinite(ctd_pres+ ctd_tmp);
    ctd_temp_int = interp1(ctd_pres(iigood),ctd_tmp(iigood),DAT.P_slow);

    %iigood = DAT.sbc>20;
    
    x = DAT.T1_slow;
    x= move_av(x,8);
    %x(DAT.P_slow<info.pmin-info.dpTr) = nan;
    ii_good = isfinite(x+ctd_temp_int);
    p = polyfit(x(ii_good),ctd_temp_int(ii_good),1);
    ctd_temp_c = polyval(p,x);

    DAT.sbt = ctd_temp_c;
    
    plot( ctd_temp_int,DAT.P_slow)
    hold on
    plot( ctd_temp_c,DAT.P_slow)
end



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
[BINNED0,SLOW0] = resolve_VMP_profile_shear_ovide2008(DAT,info,filename,PLOT);
toc

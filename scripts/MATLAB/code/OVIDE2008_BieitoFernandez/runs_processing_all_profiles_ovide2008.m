clc
clear
close all

addpath(genpath('functions'))
%set(0,'DefaultFigureVisible','off')
%%%%%%%%%%%%%%%%%%%
%%%%% Parameters %
%%%%%%%%%%%%%%%%%%%%%%

info.minvel_detect = 0.5;
%info.mindur_detect = 10;
info.pmin = 4;
info.pmax = 6500; %%%CHANGE: maximum depth
info.dp = 4;
info.dpD = 8;
info.dpGr = 8;
info.dpTr = 4;
info.prof_dir = 'down'; %%CHANGE: up or down
info.fmaxT = 30;
info.k_HP_cut_T = 0.;
info.Tmethod = 'B';
info.Tspec = 'K';
info.system = 'Oce';
info.Nfft = 512;
info.Latitude = 50;


%Rockland standard
info.time_res = nan;%5.8;%Sebastiano % nan for rockland
info.time_res_speed = 'none';
info.pole = 'Double';

%%%sebastiano paper
%info.time_res = 7.;%Sebastiano % nan for rockland

%Sommer [THIS IS CLEARLY TOO MUCH]
%info.time_res = 10.;%5.8;%Sebastiano % nan for rockland
%info.time_res_speed = 'none';
%info.pole = 'Double';

%H factor
info.hfactor = 1/10.;

PLOT = 0;

%%%%%%%%%%%%%%%%%
% FILES %%%%%%%%%%
%%%%%%%%%%%%%%%%%%



folder_orig = 'C:/Users/Manuelito/Desktop/PhD/Year 1 - 2026/Microstructure Data/OVIDE/VMP2008/'; % Defines the folder where the original data is
filenames = dir(fullfile(folder_orig,'*.p')); % Selects the files of the folder that have a .p extension (data)
folder = 'C:/Users/Manuelito/Desktop/PhD/Year 1 - 2026/Microstructure Data/OVIDE/VMP2008/patched/';
ctd_file = 'C:/Users/Manuelito/Desktop/PhD/Year 1 - 2026/Microstructure Data/OVIDE/CTD/CTD2008_GOSHIP_35TH20080610_ctd.nc'


Nf = length(filenames);
%declares general variables
OUTPUT.filename = {};
OUTPUT.pres = [];
OUTPUT.T = [];
OUTPUT.theta = [];
OUTPUT.S = [];
OUTPUT.theta_up = [];
OUTPUT.S_up = [];
OUTPUT.sigma0 = [];
OUTPUT.grT = [];
OUTPUT.grS = [];
OUTPUT.N2 = [];
OUTPUT.N2_s = [];
OUTPUT.LT = [];

%declares shear variables
OUTPUT.epsSH1 = [];
OUTPUT.MADsh1 = [];
OUTPUT.MADcsh1 = [];
OUTPUT.fit_flag_sh1 = [];

OUTPUT.epsSH2 = [];
OUTPUT.MADsh2 = [];
OUTPUT.MADcsh2 = [];
OUTPUT.fit_flag_sh2 = [];

%declares micro T variables
OUTPUT.Xic1 = [];
OUTPUT.Xiv1 = [];
OUTPUT.Xif1 = [];
OUTPUT.epsT1 = [];
OUTPUT.MAD1 = [];
OUTPUT.MADc1 = [];
OUTPUT.LKHratio1 = [];
OUTPUT.fit_flag_T1 = [];

OUTPUT.Xic2 = [];
OUTPUT.Xiv2 = [];
OUTPUT.Xif2 = [];
OUTPUT.epsT2 = [];
OUTPUT.MAD2 = [];
OUTPUT.MADc2 = [];
OUTPUT.LKHratio2 = [];
OUTPUT.fit_flag_T2 = [];

%declares derived variables
OUTPUT.KOsb1 = [];
OUTPUT.KOsbT1 = [];
OUTPUT.KTf1 = [];

OUTPUT.KOsb2 = [];
OUTPUT.KOsbT2 = [];
OUTPUT.KTf2 = [];

k = 1;
for i = 1:Nf
    %if i== 97
    %    continue
   

    filename = filenames(i).name;
    filename = filename(1:end-2);
    eval(['!cp ',[folder_orig,filename],'.p ',[folder,filename],'.p'])
    patch_setupstr([folder,filename,'.p'],[folder_orig,'setup.cfg']);   

    DAT=odas_p2mat([folder,filename,'.p']);

    if i == 1
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



    tic
    [BINNED0,SLOW0] = resolve_VMP_profile_shear_ovide2008(DAT,info,filename,PLOT);
    toc

    %gets general variables
    OUTPUT.filename{k} =  filename;
    OUTPUT.pres = BINNED0.pres;
    OUTPUT.T = [OUTPUT.T,BINNED0.T'];
    OUTPUT.theta = [OUTPUT.theta,BINNED0.theta'];
    OUTPUT.S = [OUTPUT.S,BINNED0.S'];
    OUTPUT.theta_up = [OUTPUT.theta_up,BINNED0.theta_up'];
    OUTPUT.S_up = [OUTPUT.S_up,BINNED0.S_up'];
    OUTPUT.sigma0 = [OUTPUT.sigma0,BINNED0.sigmat'];
    OUTPUT.grT = [OUTPUT.grT,BINNED0.grT'];
    OUTPUT.grS = [OUTPUT.grS,BINNED0.grS'];
    OUTPUT.N2 = [OUTPUT.N2,BINNED0.N2'];
    OUTPUT.N2_s = [OUTPUT.N2_s,BINNED0.N2_s'];
    OUTPUT.LT = [OUTPUT.LT,BINNED0.LT'];

    %shear variables
    OUTPUT.epsSH1 = [OUTPUT.epsSH1, BINNED0.epsSH1'];
    OUTPUT.MADsh1 = [OUTPUT.MADsh1,BINNED0.MADsh1'];
    OUTPUT.MADcsh1 = [OUTPUT.MADcsh1,BINNED0.MADcsh1'];
    OUTPUT.fit_flag_sh1 = [OUTPUT.fit_flag_sh1,BINNED0.fit_flag_sh1'];
    
    OUTPUT.epsSH2 = [OUTPUT.epsSH2, BINNED0.epsSH2'];
    OUTPUT.MADsh2 = [OUTPUT.MADsh2,BINNED0.MADsh2'];
    OUTPUT.MADcsh2 = [OUTPUT.MADcsh2,BINNED0.MADcsh2'];
    OUTPUT.fit_flag_sh2 = [OUTPUT.fit_flag_sh2,BINNED0.fit_flag_sh2'];

    %microT variables
    OUTPUT.Xic1 = [OUTPUT.Xic1, BINNED0.Xic1'];
    OUTPUT.Xiv1 = [OUTPUT.Xiv1, BINNED0.Xiv1'];
    OUTPUT.Xif1 = [OUTPUT.Xif1, BINNED0.Xif1'];
    OUTPUT.epsT1 = [OUTPUT.epsT1, BINNED0.epsT1'];
    OUTPUT.MAD1 = [OUTPUT.MAD1, BINNED0.MAD1'];
    OUTPUT.MADc1 = [OUTPUT.MADc1, BINNED0.MADc1'];
    OUTPUT.LKHratio1 = [OUTPUT.LKHratio1, BINNED0.LKHratio1'];
    OUTPUT.fit_flag_T1 = [OUTPUT.fit_flag_T1, BINNED0.fit_flag_T1'];

    OUTPUT.Xic2 = [OUTPUT.Xic2, BINNED0.Xic2'];
    OUTPUT.Xiv2 = [OUTPUT.Xiv2, BINNED0.Xiv2'];
    OUTPUT.Xif2 = [OUTPUT.Xif2, BINNED0.Xif2'];
    OUTPUT.epsT2 = [OUTPUT.epsT2, BINNED0.epsT2'];
    OUTPUT.MAD2 = [OUTPUT.MAD2, BINNED0.MAD2'];
    OUTPUT.MADc2 = [OUTPUT.MADc2, BINNED0.MADc2'];
    OUTPUT.LKHratio2 = [OUTPUT.LKHratio2, BINNED0.LKHratio2'];
    OUTPUT.fit_flag_T2 = [OUTPUT.fit_flag_T2, BINNED0.fit_flag_T2'];

    % derived variables
    OUTPUT.KOsb1 = [ OUTPUT.KOsb1, BINNED0.KOsb1'];
    OUTPUT.KOsbT1 = [OUTPUT.KOsbT1, BINNED0.KOsbT1'];
    OUTPUT.KTf1 = [OUTPUT.KTf1, BINNED0.KTf1'];

    OUTPUT.KOsb2 = [ OUTPUT.KOsb2, BINNED0.KOsb2'];
    OUTPUT.KOsbT2 = [OUTPUT.KOsbT2, BINNED0.KOsbT2'];
    OUTPUT.KTf2 = [OUTPUT.KTf2, BINNED0.KTf2'];
    k=k+1;
 
end

save('OVIDE2008_processed_VMP6000_rockland_time_response_H10.mat', '-struct' , 'OUTPUT')

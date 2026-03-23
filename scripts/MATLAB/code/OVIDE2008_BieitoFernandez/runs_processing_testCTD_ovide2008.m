clc
clear
addpath(genpath('../functions/'))

%%%%%%%%%%%%%%%%%%%
%%%%% Parameters %
%%%%%%%%%%%%%%%%%%%%%%

info.minvel_detect = 0.25;
info.pmin = 4;
info.pmax = 6500; %%%CHANGE: maximum depth
info.dp = 2;
info.dpD = 4;
info.dpGr = 4;
info.dpTr = 2;
info.prof_dir = 'down'; %%CHANGE: up or down
info.fmaxT = 35; %thermistors are noisy in this dataset from 35 Hz, needs cutting
info.k_HP_cut_T = 0.;
info.Tmethod = 'B';
info.Tspec = 'K';
info.system = 'Oce';
info.Nfft = 512;
info.Latitude = -60;

%Rockland standard
info.time_res = nan;%5.8;%Sebastiano % nan for rockland
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

PLOT = 0;

%%%%%%%%%%%%%%%%%
% FILES %%%%%%%%%%
%%%%%%%%%%%%%%%%%%

for FILE_INDEX = 1:30

folder_orig = '/media/bieito/Elements1/SCIENCE_DATA/VMP/OVIDE_bruno/VMP2008/';
filenames = dir([folder_orig,'*.p']);
filename = filenames(FILE_INDEX).name;

filename = filename(1:end-2);


folder = '/media/bieito/Elements1/SCIENCE_DATA/VMP/OVIDE_bruno/VMP2008/patched/';
eval(['!cp ',[folder_orig,filename],'.p ',[folder,filename],'.p'])
patch_setupstr([folder,filename,'.p'],[folder_orig,'setup.cfg']);   




%loads the patched file
DAT=odas_p2mat([folder,filename,'.p']);

figure(1)
clf
subplot(1,2,1)
plot(DAT.sbt, -DAT.P_slow)
xlim([-2,30])
subplot(1,2,2)
plot(DAT.sbc, -DAT.P_slow)
xlim([0,60])
title(filename)
saveas(gcf,['CTD_',filename,'_P','.png'])
%pause()
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



%tic
%[BINNED0,SLOW0] = resolve_VMP_profile_shear_ovide2008(DAT,info,filename,PLOT);
%toc

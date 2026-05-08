% We load paths and colorbars
addpath(genpath('C:/Users/mitg1n25/Desktop/PhD/PhD_coding'))
set(0, 'DefaultAxesFontSize', 12);
set(0, 'DefaultAxesTitleFontSizeMultiplier', 1.15)
set(0, 'DefaultAxesFontName', 'LMRoman17');
set(0, 'DefaultAxesFontWeight', 'bold');
map = load('colormap_RREX.mat'); % colormap(map.cmap);
load REXXBathymetry.mat


% This is the script I'll use to plot the hydrography data of both RREX cruises
%% Separation of transects

ridge_2015=[68:84 89:102 110:133];
north_2015=46:67;
ovide_2015=26:45;
south_2015=[3:10 15 16 21:25];

ridge_2017=[56:69 76:125];
south_2017=[1:8 11:17];
ovide_2017=[18:20 22:24 27:28 43:-1:41 38:-1:31];
north_2017=[44:55 57];

transect={'ridge','south','ovide','north'};
transects2015={ridge_2015, south_2015, ovide_2015, north_2015};
transects2017={ridge_2017, south_2017, ovide_2017, north_2017};
clear ridge_2015 ridge_2017 south_2015 south_2017 ovide_2015 ovide_2017 north_2015 north_2017

% We select the transect of interest (q=1 is ridge)
q=1; a=transects2015{q}; b=transects2017{q};


%% First, we load the variables 

folder='C:/Users/mitg1n25/Desktop/PhD/PhD_Coding/data/RREX/Hydrography';
filenames = dir(fullfile(folder,'*CTDO.nc')); % Check the variable position

lat2015=ncread(filenames(1).name,'LATITUDE'); lat2015=lat2015(a);
lon2015=ncread(filenames(1).name,'LONGITUDE'); lon2015=lon2015(a);
bottom2015=ncread(filenames(1).name,'BOTTOM_DEPTH'); bottom2015=bottom2015(a);
pres2015=ncread(filenames(1).name,'PRES'); pres2015=pres2015(:,a);
temp2015=ncread(filenames(1).name,'TEMP'); temp2015=temp2015(:,a);
sal2015=ncread(filenames(1).name,'PSAL'); sal2015=sal2015(:,a);
oxy2015=ncread(filenames(1).name,'OXYK'); oxy2015=oxy2015(:,a);
dens2015=ncread(filenames(1).name,'SIG0'); dens2015=dens2015(:,a);
n2015=length(lat2015);

lat2017=ncread(filenames(2).name,'LATITUDE'); lat2017=lat2017(b+1);
lon2017=ncread(filenames(2).name,'LONGITUDE'); lon2017=lon2017(b+1);
bottom2017=ncread(filenames(2).name,'BOTTOM_DEPTH'); bottom2017=bottom2017(b+1);
pres2017=ncread(filenames(2).name,'PRES'); pres2017=pres2017(:,b+1);
temp2017=ncread(filenames(2).name,'TEMP'); temp2017=temp2017(:,b+1);
sal2017=ncread(filenames(2).name,'PSAL'); sal2017=sal2017(:,b+1);
oxy2017=ncread(filenames(2).name,'OXYK'); oxy2017=oxy2017(:,b+1);
dens2017=ncread(filenames(2).name,'SIG0'); dens2017=dens2017(:,b+1);
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

%% We make a matrix for testing the pythons OMP
% It's a column vector version of all variables without NaNs

lat=lati2015(:); lon=loni2015(:); temp=CT2015(:); sal=SA2015(:); dens=gamma2015(:);
oxy=oxy2015(:); pres=pres2015(:);


valid_idx = ~isnan(temp) & ~isnan(sal) & ~isnan(dens) & ~isnan(oxy);
lat=lat(valid_idx); lon=lon(valid_idx); temp=temp(valid_idx); oxy=oxy(valid_idx);
sal=sal(valid_idx); dens=dens(valid_idx); pres=pres(valid_idx);

save(['RREX_Test_' transect{q} '.mat'],'lat','lon',"dens","sal","temp","oxy","pres");


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
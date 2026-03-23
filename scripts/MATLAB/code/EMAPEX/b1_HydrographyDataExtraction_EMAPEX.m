% This is the script I'll use to recover the hydrographic data from the
% EMAPEX buoys

% We load paths and colorbars
addpath(genpath('C:/Users/mitg1n25/Desktop/PhD/Year 1 - 2026'))
%addpath(genpath('D:/Respaldo PC/iop/materia/Magister/Semestre 2/PRODIGY/m_map/'))
set(0, 'DefaultAxesFontSize', 12);
set(0, 'DefaultAxesTitleFontSizeMultiplier', 1.15)

%% The structure of the -vel.mat files

% runid = 4967n1
% fltid = 4967
% hpid  = 1
% ofile = /home/emapex/proc/vel/4967n1/ema-4967n1-0001-vel.txt
% uxt_ref  = 1559165071.0  #  2019-05-29 21:24:31
% lat_gps  = 57.458638
% lon_gps  = -23.071458
% uxt_gps  = 1559172602  #  2019-05-29 23:30:02
% lat_irid = 63.642479
% lon_irid = -23.913018
% uxt_irid = 1558971358  #  2019-05-27 15:35:58
% fh       = 16483.0687756  # nT
% fz       = -48150.7665573  # nT
% magvar   = -11.2299036467  # degrees
% esep1   = 0.219  # m
% esep2   = 0.219  # m
% uvpc1   = 5.960e-04  # uV / LSB
% uvpc2   = 5.960e-04  # uV / LSB
% alpha1   = 0.379  # radians
% alpha2   = 1.95  # radians
% c1e1   = 0.5
% c1e2   = 0.5
% c2e1   = -0.2
% c2e2   = -0.2
% nvals = 74
% vars  = P,T,S,u1,v1,verr1,u2,v2,verr2,W,e1mean,e2mean,piston,uxt
% units = dbar,degC,PSU,m/s,m/s,m/s,m/s,m/s,m/s,m/s,uV,uV,counts,s

% I wil focus on extracting 
% P, T, S, u1, v1, u2, v2, W, lat_gps, lon_gps, uxt_gps

% datetime(uxt_gps, 'ConvertFrom', 'epochtime', 'epoch', datetime(1970, 1, 1))

%% First, we define the folder path

% We need to select the buoys using their serial number
% The buoy number that remained in the water for longer periods where:
% 4969 4971 7802 7806 7807 7808
b={'4969n1' '4971n1' '7802n1' '7806n1' '7807n3' '7808n3'}; %n1 and n3 are the names of the folders that contain longer records of data

for j=1:length(b)
    folder=['C:/Users/mitg1n25/Desktop/PhD/Year 1 - 2026/Microstructure Data/EMAPEX/emapex_raw/','ema-',b{j}];
    filenames = dir(fullfile(folder,'*-vel.mat')); % Selects all the files of the directory (they are all folders)
    
    for i=1:length(filenames)
        filename(i,:) = filenames(i).name;
    end

    S=NaN(500,length(filename)); T=NaN(500,length(filename));
    P=NaN(500,length(filename)); u1=NaN(500,length(filename));
    u2=NaN(500,length(filename)); v1=NaN(500,length(filename));
    v2=NaN(500,length(filename)); W=NaN(500,length(filename));
    lat=NaN(1,length(filename)); lon=NaN(1,length(filename));
    time=NaT(1,length(filename));

    for i=1:length(filename)
        file=open(filename(i,:));
        time_aux=datetime(file.uxt_ref, 'ConvertFrom', 'epochtime', 'epoch', datetime(1970, 1, 1));
        n=length(file.u1);
        S(1:n,i)=file.S;
        T(1:n,i)=file.T;
        P(1:n,i)=file.P;
        u1(1:n,i)=file.u1;
        u2(1:n,i)=file.u2;
        v1(1:n,i)=file.v1;
        v2(1:n,i)=file.v2;
        W(1:n,i)=file.W;
        lat(i)=file.lat;
        lon(i)=file.lon;
        time(i)=time_aux;
    end
    clear filename

% Create the struct that will be saved as a MAT file
    OUTPUT.P = P;
    OUTPUT.lat = lat;
    OUTPUT.lon = lon;
    OUTPUT.time = time;
    OUTPUT.T = T;
    OUTPUT.S = S;
    OUTPUT.u1 = u1;
    OUTPUT.u2 = u2;
    OUTPUT.v1 = v1;
    OUTPUT.v2 = v2;
    OUTPUT.W = W;

    text_aux=b{j}; text_aux=text_aux(1:4);
    save(['EMAPEX_float',text_aux,'_Hydrography.mat'], '-struct' , 'OUTPUT')

end

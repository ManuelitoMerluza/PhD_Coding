clc
clear
addpath gamman_mat/
load OVIDE2008_processed_VMP6000_rockland_time_response_H10.mat
load OVIDE2008_processed_VMP6000_final.mat longitude latitude
gamman = nan(size(T));
S(S<30) = nan;
for i =1:30
    i
    gamman(:,i) = gamma_n(S(:,i),T(:,i),pres',longitude(i),latitude(i));
end

clear longitude latitude i
save OVIDE2008_processed_VMP6000_rockland_time_response_H10_gamman.mat
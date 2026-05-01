%% This function is used for calculating and storing the total transport
% from the 2017 transects

% It uses the err_cal_RREX_ride.m, err_cal_RREX_zonale.m  functions
% for 2017 and 2015

addpath(genpath('C:/Users/mitg1n25/Desktop/PhD/PhD_Coding'))
transect={'ride','south','ovide','north'};

%% 2015

% Ridge
error_calc_RREX15_ride(transect{1},1:16,'none','none'); error1=round(ans,2);
error_calc_RREX15_ride(transect{1},17:30,'none','none'); error2=round(ans,2);
error_calc_RREX15_ride(transect{1},31:39,'none','none'); error3=round(ans,1);
error_calc_RREX15_ride(transect{1},40:54,'none','none'); error4=round(ans,1);
error_ride2015=[error4 error3 error2 error1];

% South
error_calc_RREX15_zonale(transect{2},9:14,'none','none'); error1=round(ans,1);
error_calc_RREX15_zonale(transect{2},1:8,'none','none'); error2=round(ans,1);
error_south2015=[error1 error2];

% OVIDE
error_calc_RREX15_zonale(transect{3},4:9,'none','none'); error1=round(ans,2);
error_calc_RREX15_zonale(transect{3},10:14,'none','none'); error2=round(ans,2);
error_ovide2015=[error1 error2];

% North
error_calc_RREX15_zonale(transect{4},5:11,'none','none'); error1=round(ans,1);
error_calc_RREX15_zonale(transect{4},12:17,'none','none'); error2=round(ans,1);
error_north2015=[error1 error2];

%% 2017

% Ridge

error_calc_RREX17_ride(transect{1},1:14,'none','none'); error1=round(ans,2);
error_calc_RREX17_ride(transect{1},15:30,'none','none'); error2=round(ans,2);
error_calc_RREX17_ride(transect{1},31:49,'none','none'); error3=round(ans,1);
error_calc_RREX17_ride(transect{1},50:62,'none','none'); error4=round(ans,1);

error_ride2017=[error4 error3 error2 error1];

% South

error_calc_RREX17_zonale(transect{2},8:13,'none','none'); error1=round(ans,2);
error_calc_RREX17_zonale(transect{2},2:7,'none','none'); error2=round(ans,2);

error_south2017=[error2 error1];

% OVIDE

error_calc_RREX17_zonale(transect{3},6:9,'none','none'); error1=round(ans,2);
error_calc_RREX17_zonale(transect{3},10:14,'none','none'); error2=round(ans,2);

error_ovide2017=[error1 error2];

% North

error_calc_RREX17_zonale(transect{4},8:12,'none','none'); error1=round(ans,1);

error_north2017=[error1];

%% Save all errors

save('C:/Users/mitg1n25/Desktop/PhD/PhD_Coding/data/RREX/Ivane_output_RREX15/transport_geo/RREX_T_tot_errors.mat', ...
    "error_ride2015","error_south2015","error_ovide2015","error_north2015", ...
    "error_ride2017","error_south2017","error_ovide2017","error_north2017");



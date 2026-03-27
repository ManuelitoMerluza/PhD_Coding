function fileop=ctd_to_cdf(OPdir,secname,nc_author,remarks_on_calibration,cruise_report,...
     statnbr,pctd,tctd,sctd,o2ctd,sinfo,qualt,botdep_m)
%  Creates a ctd data file in NetCDF format used by WHPO.  
%  INPUTS:
%      OPdir output directory
%      secname section name
%      nc_author 
%      remarks_on_calibration 
%      cruise_report 
%      statnbr (integer) station number
%      pctd (vector) pressure data
%      tctd (vector) temperature data (IT-90)
%      sctd (vector) salinity data (PSS-78)
%      o2ctd (vector) umol/kg
%      sinfo structure (example)
%sinfo = 
%       name: 'SECALIS 2'
%     strnbr: 19
%     castno: 1
%      norec: 2105
%       date: '15-Dec-2004'
%       time: '0:35:0'
%    datenum: 7.3230e+005
%        lat: -20.7563
%        lon: 167.5282
%      qualt structure with WOCE quality flags
% qualt=
%       t: (vector)
%       s: (vector)
%    o2ml: (vector)
%      o2: (vector)
%       p: (vector)
%
%      botdep_m
%
% Author: Alexandre Ganachaud IRD, ganachoNOSPAM@noumea.ird.nc
% Sept 2006
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nanval=-1e34;
%NaN value (Ferret default)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OPEN NETCDF FILE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%create an output file - clobber means that even if the file 
%exists it will be overwritten
fileop=sprintf('%s%s_%04d.nc',OPdir,secname,statnbr);
nc=netcdf(fileop,'clobber');

ctdwocedate=fix(24*60*(sinfo.datenum-datenum(1980,1,1)));
wocedate=sscanf([datestr(sinfo.datenum,'yyyy') datestr(sinfo.datenum,'mm') datestr(sinfo.datenum,'dd')],'%8d');
[hhmm]=sscanf(datestr(sinfo.datenum,'HH:MM'),'%2d:%2d');
wocetime=hhmm(1)*100+hhmm(2);

ncquiet
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DEFINE DIMENSIONS (using parentheses)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nc('time') = 1;
np=length(pctd);
nc('pressure') = np; %parenthesis defines dimension
nc('latitude') = 1;
nc('longitude') = 1;
nc('string_dimension')=40;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DEFINE VARIABLES (using parentheses)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%time   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nc{'time'}='time';
nc{'time'}.units='minutes since 1980-01-01 00:00:00';
nc{'time'}.long_name='time';                       
nc{'time'}.data_min=min(ctdwocedate);
nc{'time'}.data_max=max(ctdwocedate);  
nc{'time'}.C_format='%10d';                        

%%pressure%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nc{'pressure'}='pressure'; % dimension dependance
nc{'pressure'}.long_name= ncchar('pressure');
nc{'pressure'}.units = ncchar('dbar');
nc{'pressure'}.positive= ncchar('down');
nc{'pressure'}.data_min=min(pctd);
nc{'pressure'}.data_max=max(pctd);
nc{'pressure'}.C_format='%8.1f'
nc{'pressure'}.WHPO_Variable_Name='CTDPRS'
nc{'pressure'}.OBS_QC_VARIABLE='pressure_QC';

nc{'pressure_QC'}='pressure';
nc{'pressure_QC'}.long_name= ncchar('pressure_QC_flag');
nc{'pressure_QC'}.units = ncchar('woce_flags');
nc{'pressure_QC'}.C_format='%1d'

%%temperature%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nc{'temperature'}='pressure';
nc{'temperature'}.long_name= ncchar('temperature');
nc{'temperature'}.units = ncchar('it-90');
nc{'temperature'}.data_min=min(tctd);
nc{'temperature'}.data_max=max(tctd);
nc{'temperature'}.C_format='%8.4f'
nc{'temperature'}.WHPO_Variable_Name='CTDTMP'
nc{'temperature'}.OBS_QC_VARIABLE='temperature_QC';

nc{'temperature_QC'}='pressure';
nc{'temperature_QC'}.long_name= ncchar('temperature_QC_flag');
nc{'temperature_QC'}.units = ncchar('woce_flags');
nc{'temperature_QC'}.C_format='%1d'

%%salinity%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nc{'salinity'}='pressure';
nc{'salinity'}.long_name= ncchar('ctd salinity');
nc{'salinity'}.units = ncchar('pss-78');
nc{'salinity'}.data_min=min(sctd);
nc{'salinity'}.data_max=max(sctd);
nc{'salinity'}.C_format='%8.4f'
nc{'salinity'}.WHPO_Variable_Name='CTDSAL'
nc{'salinity'}.OBS_QC_VARIABLE='salinity_QC';

nc{'salinity_QC'}='pressure';
nc{'salinity_QC'}.long_name= ncchar('ctd salinity_QC_flag');
nc{'salinity_QC'}.units = ncchar('woce_flags');
nc{'salinity_QC'}.C_format='%1d'

%%oxygen%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nc{'oxygen'}='pressure';
nc{'oxygen'}.long_name= ncchar('ctd oxygen');
nc{'oxygen'}.units = ncchar('umol/kg');
nc{'oxygen'}.data_min=min(o2ctd);
nc{'oxygen'}.data_max=max(o2ctd);
nc{'oxygen'}.C_format='%8.1f'
nc{'oxygen'}.WHPO_Variable_Name='CTDOXY'
nc{'oxygen'}.OBS_QC_VARIABLE='oxygen_QC';

nc{'oxygen_QC'}='pressure';
nc{'oxygen_QC'}.long_name= ncchar('ctd oxygen_QC_flag');
nc{'oxygen_QC'}.units = ncchar('woce_flags');
nc{'oxygen_QC'}.C_format='%1d'

%%latitude%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nc{'latitude'}='latitude';
nc{'latitude'}.long_name= ncchar('latitude');
nc{'latitude'}.units = ncchar('degrees_N');
nc{'latitude'}.data_min=min(sinfo.lat);
nc{'latitude'}.data_max=max(sinfo.lat);
nc{'latitude'}.C_format='%9.4f'

%%longitude%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nc{'longitude'}='longitude';
nc{'longitude'}.long_name= ncchar('longitude');
nc{'longitude'}.units = ncchar('degrees_E');
nc{'longitude'}.data_min=min(sinfo.lon);
nc{'longitude'}.data_max=max(sinfo.lon);
nc{'longitude'}.C_format='%9.4f'

%%woce date%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nc{'woce_date'}='time';
nc{'woce_date'}.long_name= ncchar('WOCE date');
nc{'woce_date'}.units = ncchar('yyyymmdd UTC');
nc{'woce_date'}.data_min=min(wocedate);
nc{'woce_date'}.data_max=max(wocedate);
nc{'woce_date'}.C_format='%8d'

%%woce time%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nc{'woce_time'}='time';
nc{'woce_time'}.long_name= ncchar('WOCE time');
nc{'woce_time'}.units = ncchar('hhmm UTC');
nc{'woce_time'}.data_min=min(wocetime);
nc{'woce_time'}.data_max=max(wocetime);
nc{'woce_time'}.C_format='%4d'

%%station%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nc{'station'}=ncchar('string_dimension');
nc{'station'}.long_name= ncchar('STATION');
nc{'station'}.units = ncchar('unspecified');
nc{'station'}.C_format='%s'

%%cast%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nc{'cast'}=ncchar('string_dimension');
nc{'cast'}.long_name= ncchar('cast');
nc{'cast'}.units = ncchar('unspecified');
nc{'cast'}.C_format='%s'

%{'time', 'pressure', 'latitude', 'longitude'}

%exit define mode
endef(nc)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DEFINE GLOBAL ATTRIBUTES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nc.EXPOCODE=[sinfo.name ''];
nc.Conventions='COARDS/WOCE';
nc.CRUISE_ID=[sinfo.name ''];;
nc.DATA_TYPE='WOCE CTD';
nc.STATION_NUMBER=sprintf('%d',statnbr);
nc.CAST_NUMBER='1';
nc.BOTTOM_DEPTH_METERS=botdep_m;
nc.Creation_Time=sprintf('%s %s',nc_author,datestr(now));
nc.WOCE_CTD_FLAG_DESCRIPTION=['1=Not calibrated:2=Acceptable measurement:'...
    '3=Questionable measurement:4=Bad measurement:5=Not reported'...
    ':6=Interpolated over >2 dbar interval:7=Despiked'...
    ':8=Not assigned for CTD data:9=Not sampled::'];
nc.remarks_on_calibration=remarks_on_calibration;
nc.cruise_report=cruise_report;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% WRITE DATA TO VARIABLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tctd(isnan(tctd))=nanval;
sctd(isnan(sctd))=nanval;
o2ctd(isnan(o2ctd))=nanval;
pctd(isnan(pctd))=nanval;

nc{'time'}(1)=ctdwocedate;
nc{'pressure'}(:)=pctd;
nc{'pressure_QC'}(:)=qualt.p;
nc{'temperature'}(:)=tctd;
nc{'temperature_QC'}(:)=qualt.t(:);
nc{'salinity'}(:)=sctd;
nc{'salinity_QC'}(:)=qualt.s(:);
nc{'oxygen'}(:)=o2ctd;
nc{'oxygen_QC'}(:)=qualt.o2(:);
nc{'latitude'}(:)=sinfo.lat;
nc{'longitude'}(:)=sinfo.lon;
nc{'woce_date'}(:)=wocedate;
nc{'woce_time'}(:)=wocetime;
str=sprintf('%d',statnbr);
nc{'station'}(1:length(str))=str;
str=sprintf('%d',sinfo.castno);
nc{'cast'}(1:length(str))=str;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CLOSE NETCDF FILE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close(nc)
%ncdump(fileop)

if 0 %test lines
    %inqnc(fileop)
    plot(getnc(fileop,'temperature'),-getnc(fileop,'pressure'));pause
    %title([getnc(fileop,'woce_date'),getnc(fileop,'woce_time')]);pause
    plot(getnc(fileop,'salinity'),-getnc(fileop,'pressure'));pause
    plot(getnc(fileop,'oxygen'),-getnc(fileop,'pressure'));pause
end

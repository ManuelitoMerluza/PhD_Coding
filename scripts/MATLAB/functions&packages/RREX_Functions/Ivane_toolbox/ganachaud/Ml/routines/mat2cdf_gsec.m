function fileop=mat2cdf_gsec(datadir,secid,nc_author,remarks_on_calibration,...
    Cruise, Presctd,temp,sali,oxyg,lat,lon,Botp,gvelref)

%  Creates a ctd data file in NetCDF format used by WHPO.  
%  INPUTS:
%      OPdir output directory
%      secname section name
%      nc_author 
%      remarks_on_calibration 
%      cruise_report 
%      Presctd (p) pressure data
%      temp (p,x) temperature data (IT-90)
%      sali (p,x) salinity data (PSS-78)
%      oxyg (p,x) umol/kg
%      gvelref (p,x): referenced velocities
%
% Author: Alexandre Ganachaud IRD, ganachoNOSPAM@noumea.ird.nc
% Sept 2006
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if 0
    datadir='/local/SECINVERT/Secalis2/Geovel/'
    secid='Seca2LegNorthV';
    secid='Seca2LegNorthVH';
    getpdat
    %nf='/home/ganacho/ferrettests/dh2000or2bot.cdf';
    %inqnc(nf)
    OPdir=datadir;
    nc_author='A. Ganachaud';
    remarks='essai';
end

% LINES FROM BILLY FILE CREATION
%dimensions:
%        YSEC3 = 16 ;
%        bnds = 2 ;
%        ZAX1M = 2001 ;
%variables:
%        double YSEC3(YSEC3) ;
%                YSEC3:units = "degrees_north" ;
%                YSEC3:point_spacing = "uneven" ;
%                YSEC3:axis = "Y" ;
 %               YSEC3:bounds = "YSEC3_bnds" ;
%        double YSEC3_bnds(YSEC3, bnds) ;
%        double ZAX1M(ZAX1M) ;
%                ZAX1M:units = "METER" ;
%                ZAX1M:positive = "down" ;
%                ZAX1M:point_spacing = "even" ;
%                ZAX1M:axis = "Z" ;
%        float TCTD2(ZAX1M, YSEC3) ;
%                TCTD2:missing_value = -1.e+34f ;
%                TCTD2:_FillValue = -1.e+34f ;
%                TCTD2:long_name = "RESHAPE(TCTD1,YZSHAPE)" ;
%                TCTD2:history = "From Secalis3_ctd" ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OPEN NETCDF FILE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%create an output file - clobber means that even if the file 
%exists it will be overwritten
fileop=sprintf('%s%s.nc',datadir,secid);
nc=netcdf(fileop,'clobber');

%ctdwocedate=fix(24*60*(sinfo.datenum-datenum(1980,1,1)));
%wocedate=sscanf([datestr(sinfo.datenum,'yyyy') datestr(sinfo.datenum,'mm') datestr(sinfo.datenum,'dd')],'%8d');
%[hhmm]=sscanf(datestr(sinfo.datenum,'HH:MM'),'%2d:%2d');
%wocetime=hhmm(1)*100+hhmm(2);

ncquiet

% NEED TO DEFINE INDEX FOR STATIONS
Nstat=length(lon);
gisid=1:Nstat;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DEFINE DIMENSIONS (using parentheses)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nc('time') = 1;
np=length(Presctd);
nc('depth') = np; %parenthesis defines dimension
nc('statindex')= Nstat;
%nc('latitude') = Nstat;
%nc('longitude') = Nstat;
nc('string_dimension')=40;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DEFINE VARIABLES (using parentheses)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%time   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if 0
nc{'time'}='time';
nc{'time'}.units='minutes since 1980-01-01 00:00:00#';
nc{'time'}.long_name='time#';                       
end
%%depth%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nc{'depth'}='depth'; % dimension dependence
nc{'depth'}.long_name= ncchar('depth');
nc{'depth'}.units = ncchar('meters');
nc{'depth'}.positive= ncchar('down');
nc{'depth'}.axis=ncchar('Z');
nc{'depth'}.point_spacing='even';

%%station index%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nc{'statindex'}='statindex';
nc{'statindex'}.long_name= ncchar('station_index');
nc{'statindex'}.units = ncchar('station_index');
nc{'statindex'}.axis=ncchar('I');
nc{'statindex'}.point_spacing='even';

%%latitude%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nc{'latitude'}='statindex';
nc{'latitude'}.long_name= ncchar('latitude');
nc{'latitude'}.units = ncchar('degrees_N');
%%longitude%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nc{'longitude'}='statindex';
nc{'longitude'}.long_name= ncchar('longitude');
nc{'longitude'}.units = ncchar('degrees_E');

%%temperature%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nc{'temperature'}={'depth','statindex'};
nc{'temperature'}.long_name= ncchar('temperature');
nc{'temperature'}.units = ncchar('it-90');

%%salinity%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nc{'salinity'}={'depth';'statindex'}
nc{'salinity'}.long_name= ncchar('ctd salinity');
nc{'salinity'}.units = ncchar('pss-78');

%%velocity%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nc{'gvel'}={'depth';'statindex'}
nc{'gvel'}.long_name= ncchar('ref velocity');
nc{'gvel'}.units = ncchar('cm/s');

%%oxygen%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if exist('oxyg')
    nc{'oxygen'}='depth';
    nc{'oxygen'}.long_name= ncchar('ctd oxygen');
    nc{'oxygen'}.units = ncchar('umol/kg');
end

%exit define mode
endef(nc)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DEFINE GLOBAL ATTRIBUTES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nc.SectionName=[secid];
%nc.Conventions='COARDS/WOCE';
nc.CRUISE_ID=[Cruise ''];;
nc.STATION_NUMBER=sprintf('%d',Nstat);
%nc.CAST_NUMBER='1#';
%nc.BOTTOM_DEPTH_METERS=botdep_m;
nc.Creation_Time=sprintf('%s %s',nc_author,datestr(now));
nc.remarks=remarks_on_calibration;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% WRITE DATA TO VARIABLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%nc{'time'}(1)=ctdwocedate;
nc{'depth'}(:)=sw_dpth(Presctd,mean(lat));
nc{'statindex'}(:)=gisid;
nc{'latitude'}(:)=lat;
nc{'longitude'}(:)=lon;
temp(isnan(temp))=-1e34;
nc{'temperature'}(:)=temp;
sali(isnan(sali))=-1e34;
nc{'salinity'}(:)=sali;
gvelref(isnan(gvelref))=-1e34;
nc{'gvel'}(:)=gvelref;
%nc{'oxygen'}(:)=o2ctd;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CLOSE NETCDF FILE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close(nc)
%ncdump(fileop)

if 0 %test lines
    %inqnc(fileop)
    clf;
    plot(getnc(fileop,'temperature'),-getnc(fileop,'depth'));pause
    %title([getnc(fileop,'woce_date'),getnc(fileop,'woce_time')]);pause
    plot(getnc(fileop,'salinity'),-getnc(fileop,'depth'));pause
    plot(getnc(fileop,'oxygen'),-getnc(fileop,'depth'));pause
end

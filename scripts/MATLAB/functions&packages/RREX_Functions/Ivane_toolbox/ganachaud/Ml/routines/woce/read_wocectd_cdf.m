function [statlabel,sdate,slat,slon,pres,temp,sali,oxyg]=...
    read_wocectd_cdf(fname)
%READ WOCE FORMAT NETCDF CTD FILE
%ALEXANDRE GANACHAUD IRD SEPT 2006
%fname='e:/WOCEData/P21_CTD/p21e_00004_00001_ctd.nc';
%inqnc(fname)
%header stuff
if exist(fname)
    disp(['reading ' fname])
    statlabel=getnc(fname,'station');
    ttime=getnc(fname,'woce_time');
    thour=floor(ttime/100);
    tmin=ttime-100*thour;
    tdate=getnc(fname,'woce_date');
    tyear=floor(tdate/1e4);
    tmonth=floor((tdate-tyear*1e4)/1e2);
    tday=tdate-tyear*1e4-tmonth*1e2;
    sdate=datenum(tyear,tmonth,tday,thour,tmin,0);
    slat=getnc(fname,'latitude');
    slon=getnc(fname,'longitude');
    pres=getnc(fname,'pressure');
    temp=getnc(fname,'temperature');
    qtemp=getnc(fname,'temperature_QC');
    temp((qtemp==4)|(temp==-1e34))=NaN;
    sali=getnc(fname,'salinity');
    qsali=getnc(fname,'salinity_QC');
    sali((qsali==4)|(sali==-1e34))=NaN;
    oxyg=getnc(fname,'oxygen');
    qoxyg=getnc(fname,'oxygen_QC');
    oxyg((qoxyg==4)|(oxyg==-1e34))=NaN;
    subplot(1,2,1);plot(temp,-pres);subplot(1,2,2);plot(sali,-pres);
else
    disp([fname ' NOT FOUND ' ])
    statlabel=[];sdate=[];slat=[];slon=[];
    pres=[];temp=[];sali=[];oxyg=[];
end

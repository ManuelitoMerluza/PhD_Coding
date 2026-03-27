%-----------------------------------------------------------
%
% transformation des fichiers Netcdf CCHDO en Netcdf cli LPO
% (_ctd.nc en _cli.nc)
%
% Catherine Lagadec / Juillet 2014 durant le CDD de Mathieu Hamon

% programme special pour les fichiers AR07W 
% qui ne contiennent pas de flag et CTDTMP au lieu de temperature
% les campagnes AR07W ne contiennent pas de flag,
% il est imposé à 1 dans les cli et les clc avec DATA_MODE= 'not calibrated'
% (demande des chercheurs - cf CR réunion du 28/10/14)

% programme utilisé aussi pour A12_10 car pas de flag
% mais CTDOXY au lieu de oxygene ... on s'amuse !!!
%
% ---------------------------------------------------------------------------------

text_flagp =  '1: good; 2: probably good; 3: probably bad;  4: bad; 6: interpolated over >2 dbar interval; 7: despiked; 9: No data';
fillval = -9999;
tabphys_nc = ['PRES';'PSAL';'OXYK';'TEMP'];
nomphys_nc = ['Sea Pressure                  '; ...
              'Practical Salinity PSS78      '; ...
              'Dissolved oxygen concentration'; ...
              'In situ temperature ITS-90    '];
valmin_nc = [0;0;0;-2];
valmax_nc = [15000;60;600;40];

unit_nc   = ['decibar        '; ...
             'psu            '; ...
             'micromol/kg    '; ...
             'degree celsius '];

         
% informations concernant la campagne devant être lues
% dans le fichier xls des campagnes (créé par Mathieu Hamon)

% lecture du fichier CCHDO_NCF.csv transformé à partir
% du fichier CCHDO_NCF.xlsx cree par Mathieu Hamon
% ce fichier contient :
% code section, EXPOCODE, navire, 
% dates de la campagne, pi, pays, organisme pi,section hydro

ff=fopen('/home1/homedir5/perso/clagadec/PROG_MATLAB/refonte_hydro_2013/crecli_WOCE/CCHDO_NCF.csv');
CCHDO=textscan(ff,'%s%s%s%s%s%s%s%s','Delimiter',',');
fclose(ff);

          
sect_hyd    = input('Section Hydro ? ', 's');
rep=input('Expocode correspond-il au nom de fichier ? (O/N) ', 's');

stat1       = input('Station debut ? ');
statn       = input('Station fin ? ');
cast        = input('Numero de cast ? ');
ccast       = sprintf('%5.5i',cast);

messerr=lfcod_phys;

for i=1:length(CCHDO{1})
   if strcmp(CCHDO{8}(i), sect_hyd)
       section        = cell2mat(CCHDO{1}(i));
       if strcmp(rep,'N')
           identcamp   = input('Debut nom de fichier (ne pas taper dernier _)  ? ','s');
       else
           identcamp   = cell2mat(CCHDO{2}(i));
       end
       expocode       = cell2mat(CCHDO{2}(i));
       ship           = cell2mat(CCHDO{3}(i));
       cruise_dates   = cell2mat(CCHDO{4}(i));
       pi             = cell2mat(CCHDO{5}(i));
       org_resp       = cell2mat(CCHDO{7}(i));
       section_hydro  = cell2mat(CCHDO{8}(i));
   end
end



for i=stat1:statn
    
 clear tvalcli tvalb tvalbon 
 cstat = sprintf('%5.5i',i);
 fic_woce=[identcamp '_' cstat '_' ccast '_ctd.nc']

if exist(fic_woce,'file')

% codes pour les AR07W / pas de flag : pressure,salinity,oxygen,CTDTMP
% codes pour A12_10 / pas de flag : pressure,salinity,temperature,CTDOXY

param1=    'pressure';
param2=    'salinity';

if strcmp(sect_hyd,'A12_10')
    param4=    'temperature';
    param3=    'CTDOXY';
else
    param3=    'oxygen';
    param4=    'CTDTMP';
end
clear tvalcli
tvalcli(1,:)   = ncread(fic_woce,param1);
tvalcli(1,:)   = round(tvalcli(1,:));

tvalcli(2,:)   = ncread(fic_woce,param2);
tvalcli(3,:)   = ncread(fic_woce,param3);
tvalcli(4,:)   = ncread(fic_woce,param4);

% les fichiers de AR07W11 sont des fichiers montée !
if strcmp(section_hydro,'AR07W11')
      clear tvalt
      [tvalt(1,:),index]   = sort(tvalcli(1,:),'ascend');
      for jj =1:length(index)
         tvalt(2,jj)   = tvalcli(2,index(jj));
         tvalt(3,jj)   = tvalcli(3,index(jj));
         tvalt(4,jj)   = tvalcli(4,index(jj));
      end
      clear tvalcli
      tvalcli=tvalt;
end

ibon=find(isfinite(tvalcli(2,:)));

% pb dans ces 2 fichiers car derniere valeur de pression
% inferieure à precedente
if strcmp(fic_woce,'18HU99022_1_00073_00001_ctd.nc') || strcmp(fic_woce,'18HU20070510_00145_00001_ctd.nc')
    tvalb(2,:) = tvalcli(2,ibon(1):ibon(end-1));
    tvalb(1,:) = tvalcli(1,ibon(1):ibon(end-1));
else
    tvalb(2,:) = tvalcli(2,ibon(1):ibon(end));
    tvalb(1,:) = tvalcli(1,ibon(1):ibon(end));
end

if strcmp(fic_woce,'18HU99022_1_00073_00001_ctd.nc') || strcmp(fic_woce,'18HU20070510_00145_00001_ctd.nc')
    tvalb(3,:)   = tvalcli(3,ibon(1):ibon(end-1));
    tvalb(4,:)   = tvalcli(4,ibon(1):ibon(end-1));
else
    tvalb(3,:)   = tvalcli(3,ibon(1):ibon(end));
    tvalb(4,:)   = tvalcli(4,ibon(1):ibon(end));
end

ibon=find(isfinite(tvalb(4,:)));
tvalbon(1,:)   = tvalb(1,ibon(1):ibon(end));
tvalbon(2,:)   = tvalb(2,ibon(1):ibon(end));
if strcmp(fic_woce,'18HU99022_1_00038_00001_ctd.nc') || strcmp(fic_woce,'18HU99022_1_00029_00001_ctd.nc') ...
       || strcmp(fic_woce,'18HU99022_1_00050_00001_ctd.nc')
    tvalbon(2,1) = tvalbon(2,2);
end
tvalbon(3,:)   = tvalb(3,ibon(1):ibon(end));
tvalbon(4,:)   = tvalb(4,ibon(1):ibon(end));
[~,nlevels]  = size(tvalbon);

lat   = ncread(fic_woce,'latitude');
lon   = ncread(fic_woce,'longitude');

wdate = ncread(fic_woce,'woce_date');
cwdate=num2str(wdate);
wtime = ncread(fic_woce,'woce_time');
cwtime=sprintf('%4.4i',wtime);

data_type    = ncreadatt(fic_woce,'/','DATA_TYPE');
stat         = ncreadatt(fic_woce,'/','STATION_NUMBER');
cast         = ncreadatt(fic_woce,'/','CAST_NUMBER');
dist_probe   = ncreadatt(fic_woce,'/','BOTTOM_DEPTH_METERS');
convent      = ncreadatt(fic_woce,'/','Conventions');
woce_version = ncreadatt(fic_woce,'/','WOCE_VERSION');

cstat = sprintf('%3.3i',i);

%ouverture du fichier cli correspondant
% pour AR07W11, les fichiers sont des fichiers Montee
cruise_nc = section_hydro;
if strcmp(section_hydro,'AR07W11')
    ncid=netcdf.create([cruise_nc 'a' '0' cstat '_' ccast(3:5) '_cli.nc'],'NC_CLOBBER');
else
    ncid=netcdf.create([cruise_nc 'd' '0' cstat '_' ccast(3:5) '_cli.nc'],'NC_CLOBBER');
end


% Declaration des dimensions.
dimstr4     = netcdf.defDim(ncid,'STRING4',4);
dimstr20    = netcdf.defDim(ncid,'STRING20',20);
dimstr7     = netcdf.defDim(ncid,'STRING7',7);
dimstr28    = netcdf.defDim(ncid,'STRING28',28);
dimnprof    = netcdf.defDim(ncid,'N_PROF',1);

nparam = 4;
dimnparam   = netcdf.defDim(ncid,'N_PARAM',nparam);
[~,nparam] = netcdf.inqDim(ncid,dimnparam);

dimnlevels  = netcdf.defDim(ncid,'N_LEVELS',nlevels);

dimdatetime = netcdf.defDim(ncid,'DATE_TIME',14);


% Declaration des attributs globaux
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'ORIGINAL_CLI',fic_woce);
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'SHIP_NAME',ship);

wmo_id='UNKNOW';

netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'SHIP_WMO_ID',wmo_id);

% il faut que pi soit à 16 caractères max,
% sinon ça bloque à la création du MLT !
pi2(1:16)=' ';
pi2(1:length(pi)) = pi;
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'PI_NAME',pi2);

pi_org(1:16) = ' ';
pi_org(1:length(org_resp(1,:))) = org_resp(1,:);
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'PI_ORGANISM',pi_org);

netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'CRUISE_NAME',cruise_nc);
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'STATION_NUMBER',i);
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'LEG_NUMBER',1);

netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'DIRECTION','d');

netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'DATA_PROCESSING_ORGANISM','CCHDO');
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'PROBE_TYPE',data_type);
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'PROBE_NUMBER',' ');
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'REFERENCE_DATE_TIME','19500101000000');
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'DATE_CREATION',datestr(now, 'yyyymmddHHMMSS'));
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'LAST_UPDATE',datestr(now, 'yyyymmddHHMMSS'));
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'COORD_SYSTEM','GEOGRAPHICAL-WGS84');


netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'PINGER','y');
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'SAMPLING_MODE','R');
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'SPUN_LINE',-9999);
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'DIST_PROBE_BOTTOM',abs(dist_probe));
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'PRESCRIBED_CTD_VELOCITY','1 m/s');
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'SOFTWARE_VERSION','Woce Software');

netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'CHEMISTRY_PARAMETERS','N');

comment = ['EXPOCODE=' expocode '  ' 'Conventions=' convent '  Woce_version=' woce_version '  cast = ' ccast];
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'COMMENTS',comment);


%% Declaration des variables

creat_newvar(ncid,'LATITUDE_BEGIN','NC_DOUBLE',dimnprof,'long_name','Latitude begin of the station, best estimates','units','degree_north','convention','decimal degree','valid_min',-90,'valid_max',90,'_FillValue',double(fillval));
creat_newvar(ncid,'LATITUDE_END','NC_DOUBLE',dimnprof,'long_name','Latitude end of the station, best estimates','units','degree_north','convention','decimal degree','valid_min',-90,'valid_max',90,'_FillValue',double(fillval));
creat_newvar(ncid,'LONGITUDE_BEGIN','NC_DOUBLE',dimnprof,'long_name','Longitude begin of the station, best estimates','units','degree_east','convention','decimal degree','valid_min',-180,'valid_max',180,'_FillValue',double(fillval));
creat_newvar(ncid,'LONGITUDE_END','NC_DOUBLE',dimnprof,'long_name','Longitude end of the station, best estimates','units','degree_east','convention','decimal degree','valid_min',-180,'valid_max',180,'_FillValue',double(fillval));
creat_newvar(ncid,'STATION_DATE_BEGIN','NC_CHAR',[dimdatetime,dimnprof],'long_name','Beginning Date_Time of the station','convention','YYYYMMDDHH24MISS','_FillValue',' ');
creat_newvar(ncid,'STATION_DATE_END','NC_CHAR',[dimdatetime,dimnprof],'long_name','End Date_Time of the station','convention','YYYYMMDDHH24MISS','_FillValue',' ');
creat_newvar(ncid,'JULD_BEGIN','NC_DOUBLE',dimnprof,'long_name','Julian day (UTC) of the beginning of the station relative to REFERENCE_DATE_TIME','units','days since 1950-01-01 00:00:00 UTC','convention','Relative julian Days with decimal part (as parts of day)','_FillValue',double(fillval));
creat_newvar(ncid,'JULD_END','NC_DOUBLE',dimnprof,'long_name','Julian day (UTC) of the end of the station relative to REFERENCE_DATE_TIME','units','days since 1950-01-01 00:00:00 UTC','convention','Relative julian Days with decimal part (as parts of day)','_FillValue',double(fillval));
creat_newvar(ncid,'BATHYMETRY_BEGIN','NC_FLOAT',dimnprof,'long_name','Bathymetry at the beginning of the station','units','meter','_FillValue',single(fillval));
creat_newvar(ncid,'BATHYMETRY_END','NC_FLOAT',dimnprof,'long_name','Bathymetry at the end of the station','units','meter','_FillValue',single(fillval));


% Creation des variables concernant les mesures sonde  
% ---------------------------------------------------
creat_newvar(ncid,'STATION_PARAMETER','NC_CHAR',[dimstr4,dimnparam],'long_name','Mesured parameter of the station','_FillValue',' ');
badprecision = fillval;

for ip=1:nparam
   creat_newvar(ncid,tabphys_nc(ip,:),'NC_FLOAT',[dimnlevels,dimnprof],'long_name',deblank(nomphys_nc(ip,:)),'resp_param',deblank(pi(1,:)),'Organism_resp',deblank(org_resp(1,:)),'units',deblank(unit_nc(ip,:)),'valid_min',valmin_nc(ip),'valid_max',valmax_nc(ip),'precision',single(fillval),'_FillValue',single(fillval));
   creat_newvar(ncid,[tabphys_nc(ip,:) '_QC'],'NC_FLOAT',[dimnlevels,dimnprof],'long_name',[deblank(nomphys_nc(ip,:)) ' quality flag'],'convention',text_flagp,'_FillValue',single(fillval));
end



netcdf.endDef(ncid);

%% Ecriture des informations dans les variables.

netcdf.putVar(ncid,netcdf.inqVarID(ncid,'STATION_PARAMETER'),tabphys_nc');


datedeb = [cwdate cwtime '00'];

netcdf.putVar(ncid,netcdf.inqVarID(ncid,'STATION_DATE_BEGIN'),datedeb);
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'STATION_DATE_END'),datedeb);

juldd=jul_0h([str2double(cwdate(1:4)) str2double(cwdate(5:6)) str2double(cwdate(7:8)) str2double(cwtime(1:2)) str2double(cwtime(3:4)) 0])-jul_0h(1950,01,01,00);
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'JULD_BEGIN'),juldd);
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'JULD_END'),juldd);

netcdf.putVar(ncid,netcdf.inqVarID(ncid,'LATITUDE_BEGIN'),lat);
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'LATITUDE_END'),lat);

netcdf.putVar(ncid,netcdf.inqVarID(ncid,'LONGITUDE_BEGIN'),lon);
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'LONGITUDE_END'),lon);


netcdf.putVar(ncid,netcdf.inqVarID(ncid,'BATHYMETRY_BEGIN'),fillval) % sonde debut de station.
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'BATHYMETRY_END'),fillval)   % sonde fin de station


% Ecriture des donnees issues de la sonde
% Ecriture des flags de qualite.

clear flag_nc

for jj=1:nparam
    
    % pas de flag dans les donnees CCHDO pour ces campagnes
    % on force le flag à 2 (probablement bonnes)
    % sauf pour les AR07W ou l'on force le flag à 1
   
    if strcmp(sect_hyd(1:5),'AR07W')
        flag_nc(1:nlevels) = 1;
    else
        flag_nc(1:nlevels) = 2;
    end
    i9 = find(~isfinite(tvalbon(jj,:)));
    tvalbon(jj,i9)= fillval;
    flag_nc(i9) =9; 
    
    netcdf.putVar(ncid,netcdf.inqVarID(ncid,tabphys_nc(jj,:)),tvalbon(jj,:));
    netcdf.putVar(ncid,netcdf.inqVarID(ncid,[tabphys_nc(jj,:) '_QC']),flag_nc);
end

netcdf.reDef(ncid);

text='';
for pp=1:nparam
    text=[text '  ' tabphys_nc(pp,:) ' NOT CALIBRATED; '];
end
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'COMMENT_CALIB',text);
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'DATA_MODE','not calibrated');

netcdf.close(ncid);

else
    message=['Fichier inexistant : ' fic_woce]
end
end


clear all
close all




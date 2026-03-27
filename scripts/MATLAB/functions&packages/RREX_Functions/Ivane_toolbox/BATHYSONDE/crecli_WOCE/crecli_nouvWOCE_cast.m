
%-----------------------------------------------------------
%
% transformation des fichiers Netcdf CCHDO en Netcdf cli LPO
% (_ctd.nc en _cli.nc)
%
% Catherine Lagadec / Juillet 2014 durant le CDD de Mathieu Hamon

% programmme special pour traiter les 2 campagnes 
% AR21_91 et AR21_93
% les numeros de cast varient de 1 à 92, le nom des fichiers
% est donc lu dans un fichier catalogue (liste_fic)
% dans AR21_93 : pas d'oxygene
%
% utilise aussi pour DIMES_UK4 car pas d'oxygene
% (pas de pb de cast dans cette campagne), on lit quand même 
% les noms de fichiers dans liste_fic (pour rester coherent)
% ----------------------------------------------------------

text_flagp =  '1: good; 2: probably good; 3: probably bad;  4: bad; 6: interpolated over >2 dbar interval; 7: despiked; 9: No data';
fillval = -9999;

nomphys_nc = ['Sea Pressure                  '; ...
              'In situ temperature ITS-90    '; ...
              'Practical Salinity PSS78      '; ...
              'Dissolved oxygen concentration'];
valmin_nc = [0;-2;0;0];
valmax_nc = [15000;40;60;600];

unit_nc   = ['decibar        '; ...
             'degree celsius '; ...
             'psu            '; ...
             'micromol/kg    '];
         
 param1=    'pressure';
 param1_qc= 'pressure_QC';
 param2=    'temperature';
 param2_qc= 'temperature_QC';
 param3=    'salinity';
 param3_qc= 'salinity_QC';
 param4=    'oxygen';
 param4_qc= 'oxygen_QC';  
         
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

fcat = fopen('liste_fic') ;
nfic = fgetl(fcat);
nfic = str2double(nfic);

sect_hyd    = input('Section Hydro ? ', 's');

if strcmp(sect_hyd,'AR21_91') 
     tabphys_nc = ['PRES';'TEMP';'PSAL';'OXYK'];
else
    tabphys_nc= ['PRES';'TEMP';'PSAL'];
end

messerr=lfcod_phys;

for i=1:length(CCHDO{1})
   if strcmp(CCHDO{8}(i), sect_hyd)
       section        = cell2mat(CCHDO{1}(i));    
       expocode       = cell2mat(CCHDO{2}(i));
       ship           = cell2mat(CCHDO{3}(i));
       cruise_dates   = cell2mat(CCHDO{4}(i));
       pi             = cell2mat(CCHDO{5}(i));
       org_resp       = cell2mat(CCHDO{7}(i));
       section_hydro  = cell2mat(CCHDO{8}(i));
   end
end

ccast = '00001';

for i=1:nfic
    
  clear tvalcli tflag tvalb tflagb tvalbon tflagbon;
 
  fic_woce=fgetl(fcat)
  if strcmp(sect_hyd,'AR21_93')
      cstat = fic_woce(11:14);
      ccast = fic_woce(18:20);
  elseif strcmp(sect_hyd,'AR21_91')
      cstat = fic_woce(7:10);
      ccast = fic_woce(14:16);
  else
      cstat=['0' fic_woce(16:18)];
      ccast='001';
  end

if exist(fic_woce,'file')

 
tvalcli(1,:)   = ncread(fic_woce,param1);
tvalcli(1,:)   = round(tvalcli(1,:));
[~,nlevels]=size(tvalcli);

tflag(1,:)= ncread(fic_woce,param1_qc);

tvalcli(2,:)   = ncread(fic_woce,param2);
tflag(2,:)= ncread(fic_woce,param2_qc);

tvalcli(3,:)   = ncread(fic_woce,param3);
tflag(3,:)= ncread(fic_woce,param3_qc);

% pas d'oxygen dans AR21_93
if strcmp(sect_hyd,'AR21_91')
    tvalcli(4,:)   = ncread(fic_woce,param4);
    tflag(4,:)= ncread(fic_woce,param4_qc);
    nparam = 4;
else
    nparam = 3;
end

lat   = ncread(fic_woce,'latitude');
lon   = ncread(fic_woce,'longitude');

wdate = ncread(fic_woce,'woce_date');
cwdate=num2str(wdate);
wtime = ncread(fic_woce,'woce_time');
cwtime=sprintf('%4.4i',wtime);

data_type    = ncreadatt(fic_woce,'/','DATA_TYPE');
stat         = ncreadatt(fic_woce,'/','STATION_NUMBER');
cast         = ncreadatt(fic_woce,'/','CAST_NUMBER');
bottom       = ncreadatt(fic_woce,'/','BOTTOM_DEPTH_METERS');
convent      = ncreadatt(fic_woce,'/','Conventions');
woce_version = ncreadatt(fic_woce,'/','WOCE_VERSION');

%ouverture du fichier cli correspondant

cruise_nc = section_hydro;
ncid=netcdf.create([cruise_nc 'd' cstat '_' ccast '_cli.nc'],'NC_CLOBBER');


% Declaration des dimensions.
dimstr4     = netcdf.defDim(ncid,'STRING4',4);
dimstr20    = netcdf.defDim(ncid,'STRING20',20);
dimstr7     = netcdf.defDim(ncid,'STRING7',7);
dimstr28    = netcdf.defDim(ncid,'STRING28',28);
dimnprof    = netcdf.defDim(ncid,'N_PROF',1);


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
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'CAST',str2double(ccast));
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
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'DIST_PROBE_BOTTOM',-9999);
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

if ischar(bottom)
    bottom=str2double(bottom);
end
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'BATHYMETRY_BEGIN'),bottom) % sonde debut de station.
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'BATHYMETRY_END'),bottom)   % sonde fin de station


% Ecriture des donnees issues de la sonde
% Ecriture des flags de qualite.

iflag1(1:nparam) = 0;
for jj=1:nparam
    % ATTENTION ATTENTION ATTENTION
    % dans Woce, les bonnes mesures sont flaguees à 2 (dans hydro à 1) !!!   
    % dans Woce, les mesures non calibrees sont flaguees à 1 (dans hydro à 2) !!!
    
    flag_nc=ones(nparam,nlevels);
    
    inotcalib = find(tflag(jj,:) ==1);
    if ~isempty(inotcalib)
       iflag1(jj) = 1;
       flag_nc(jj,inotcalib) = 1;
    end
    
    i3 = find(tflag(jj,:) == 3); 
    flag_nc(jj,i3) = 3;
    i6 = find(tflag(jj,:) == 6); 
    flag_nc(jj,i6) = 6; 
    i7 = find(tflag(jj,:) == 7); 
    flag_nc(jj,i7) = 7;
    
     
    i9 = find(tflag(jj,:)>= 9 | tflag(jj,:)<= 0 | tvalcli(jj,:) == -999);
    tvalcli(jj,i9)= fillval;
    flag_nc(i9) =9;
    
    netcdf.putVar(ncid,netcdf.inqVarID(ncid,tabphys_nc(jj,:)),tvalcli(jj,:));
    netcdf.putVar(ncid,netcdf.inqVarID(ncid,[tabphys_nc(jj,:) '_QC']),flag_nc(jj,:));
end

netcdf.reDef(ncid);

p=find(iflag1==1);

if ~isempty(p)
     netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'DATA_MODE','not calibrated');
else
     netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'DATA_MODE','calibrated');
end

text='';
for pp=1:nparam
    if iflag1(pp)==0
        text=[text '  ' tabphys_nc(pp,:) ' CALIBRATED; '];
    else
        text=[text '  ' tabphys_nc(pp,:) ' NOT CALIBRATED; '];
    end
end
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'COMMENT_CALIB',text);


netcdf.close(ncid);

else
    message=['Fichier inexistant : ' fic_woce]
end
end


clear all
close all




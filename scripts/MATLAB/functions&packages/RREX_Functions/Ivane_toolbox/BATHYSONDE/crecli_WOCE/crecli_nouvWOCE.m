
%-----------------------------------------------------------
%
% transformation des fichiers Netcdf CCHDO en Netcdf cli LPO
% (_ctd.nc en _cli.nc)
%
% Catherine Lagadec / Juillet 2014 durant le CDD de Mathieu Hamon
%
% ----------------------------------------------------------

text_flagp =  '1: good; 2: probably good; 3: probably bad;  4: bad; 6: interpolated over >2 dbar interval; 7: despiked; 9: No data';
fillval = -9999;
tabphys_nc = ['PRES';'TEMP';'PSAL';'OXYK'];
tabphys_anas2_nc = ['PRES';'TEMP';'PSAL'];

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
    
 clear tvalcli tflag tvalb tflagb tvalbon tflagbon
 
if strcmp(sect_hyd,'A20_03')
    cstat = sprintf('%3.3i',i);
    if cast==1
      fic_woce=[cstat '01_ctd.nc']
    else
      fic_woce=[cstat '02_ctd.nc']  
    end
else
    if strcmp(sect_hyd,'AR25_99')
        cstat = sprintf('%3.3i',i);
    elseif strcmp(sect_hyd,'AR09_93B')
        cstat = sprintf('%2.2i',i);
       else
        cstat = sprintf('%4.5i',i);
    end
%    ccast='00001'; rajoute pour recreer cli de AR10_92B
    fic_woce=[identcamp '_' cstat '_' ccast '_ctd.nc']
end

if strcmp(sect_hyd,'A13_5_10')
    fic_woce(length(fic_woce)-5:length(fic_woce)-3)='hy1'
end

if strcmp(sect_hyd,'AR01_98')
    fic_woce(length(fic_woce)-5:length(fic_woce)-3)='ct1'
end

if exist(fic_woce,'file')

% lecture fichier Woce : pour certains fichiers,
% le code param est different !!
if strcmp(sect_hyd,'A13_5_10')
    param1= 'Pressure';
    param1_qc = 'CTDPRS_QC';
    param2= 'Temperature';
    param2_qc = 'CTDTMP_QC';
    param3= 'Salinity';
    param3_qc= 'CTDSAL_QC';
    param4= 'Oxygen_CTD';
    param4_qc='CTDOXY_QC';
else
    param1=    'pressure';
    param1_qc= 'pressure_QC';
    param2=    'temperature';
    param2_qc= 'temperature_QC';
    param3=    'salinity';
    param3_qc= 'salinity_QC';
    param4=    'oxygen';
    param4_qc= 'oxygen_QC';  
end

if strcmp(sect_hyd,'A07E_10')
    tvalcli(1,:)   = round(ncread(fic_woce,param1));
else 
    tvalcli(1,:)   = ncread(fic_woce,param1);
end
tflag(1,:)     = ncread(fic_woce,param1_qc);
isok = find(tflag(1,:)== 1 | tflag(1,:) == 2);
tvalb(1,:)=tvalcli(1,isok(1):isok(end));
if ~isfinite(tvalb(1,1))
    tvalb(1,1)=0;
end
    
tflagb(1,:)=tflag(1,isok(1):isok(end));

tvalcli(2,:) = ncread(fic_woce,param2);
tflag(2,:)   = ncread(fic_woce,param2_qc);
tvalb(2,:)   = tvalcli(2,isok(1):isok(end));
tflagb(2,:)  = tflag(2,isok(1):isok(end));

tvalcli(3,:) = ncread(fic_woce,param3);
tflag(3,:)   = ncread(fic_woce,param3_qc);
tvalb(3,:)   = tvalcli(3,isok(1):isok(end));
tflagb(3,:)  = tflag(3,isok(1):isok(end));

tvalcli(4,:) = ncread(fic_woce,param4);
tflag(4,:)   = ncread(fic_woce,param4_qc);
tvalb(4,:)   = tvalcli(4,isok(1):isok(end));
tflagb(4,:)  = tflag(4,isok(1):isok(end));

[~,nbb] = size(tvalb);

% après avoir elimine les mauvaises pressions,
% on regarde si flags a 6 et/ou 7 en sal et/ou tmp
% et on ne prend que les valeurs flaguees a bonnes dans les 2 param
isok = find(tvalb(3,:) ~= -999.);

if length(isok) == nbb
    isok1=find(tflagb(3,:)== 1 | tflagb(3,:)==2 );
    isok2=find(tflagb(2,:)==1 | tflagb(2,:)==2);
    isok=intersect(isok1,isok2);
end

tvalbon(1,:) = tvalb(1,isok(1):isok(end));
tvalbon(2,:) = tvalb(2,isok(1):isok(end));
tvalbon(3,:) = tvalb(3,isok(1):isok(end));
tvalbon(4,:) = tvalb(4,isok(1):isok(end));

tflagbon(1,:) = tflagb(1,isok(1):isok(end));
tflagbon(2,:) = tflagb(2,isok(1):isok(end));
tflagbon(3,:) = tflagb(3,isok(1):isok(end));
tflagbon(4,:) = tflagb(4,isok(1):isok(end));

[~,nlevels]=size(tvalbon);

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

cstat = sprintf('%4.4i',i);
ncast=str2double(ccast);
ccast_cli=sprintf('%3.3i',ncast);

%ouverture du fichier cli correspondant

cruise_nc = section_hydro;
ncid=netcdf.create([cruise_nc 'd' cstat '_' ccast_cli '_cli.nc'],'NC_CLOBBER');


% Declaration des dimensions.
dimstr4     = netcdf.defDim(ncid,'STRING4',4);
dimstr20    = netcdf.defDim(ncid,'STRING20',20);
dimstr7     = netcdf.defDim(ncid,'STRING7',7);
dimstr28    = netcdf.defDim(ncid,'STRING28',28);
dimnprof    = netcdf.defDim(ncid,'N_PROF',1);

% dans les campagnes ANAS (2, 3, 4, 5, 6, 7) les valeurs OXYK de toutes les stations
% sont à -9999. pas de reecriture de ce param
% idem pour AR01_98 (avec flag = 5)
% idem pour AR03 et AR10_92B, AR11_91C et AR11_93B
% AR08_94A : oxygen à 0 dans tous les fichiers et flag = 1
% AR08_96  : oxygen entre 0.1 et 2 et flag à 2
% AR09_93B, AR09_92 : flags oxygene à 9
% ---------------------------------------------------------------
if strcmp(sect_hyd(1:4),'ANAS') || strcmp(sect_hyd,'AR25_99')  ...
        || strcmp(sect_hyd,'AR03_00') || strcmp(sect_hyd,'AR10_92B') || strcmp(sect_hyd,'AR11_91C') ...
        || strcmp(sect_hyd,'AR11_93B') || strcmp(sect_hyd,'AR08_94A') || strcmp(sect_hyd,'AR08_96') ...
        || strcmp(sect_hyd,'AR09_93B') || strcmp(sect_hyd,'AR09_92')
    
    nparam = 3;
else 
    nparam = 4;
end

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
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'PI_NAME',deblank(pi2));

pi_org(1:16) = ' ';
pi_org(1:length(org_resp(1,:))) = org_resp(1,:);
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'PI_ORGANISM',deblank(pi_org));

netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'CRUISE_NAME',cruise_nc);
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'STATION_NUMBER',i);
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'CAST',str2num(ccast));
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'LEG_NUMBER',1);

netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'DIRECTION','d');

netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'DATA_PROCESSING_ORGANISM','CCHDO');
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'PROBE_TYPE',data_type);
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'PROBE_NUMBER',' ');
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'REFERENCE_DATE_TIME','19500101000000');
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'DATE_CREATION',datestr(now, 'yyyymmddHHMMSS'));
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'LAST_UPDATE',datestr(now, 'yyyymmddHHMMSS'));
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'COORD_SYSTEM','GEOGRAPHICAL-WGS84');


if ischar(bottom)
    bottom=str2double(bottom);
end
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'PINGER','y');
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'SAMPLING_MODE','R');
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'SPUN_LINE',-9999);
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'DIST_PROBE_BOTTOM',bottom);
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

if strcmp(sect_hyd(1:4),'ANAS') || strcmp(sect_hyd,'AR25_99') || strcmp(sect_hyd,'AR03_00') ...
        || strcmp(sect_hyd,'AR10_92B') || strcmp(sect_hyd,'AR11_91C') ...
        || strcmp(sect_hyd,'AR11_93B') || strcmp(sect_hyd,'AR08_94A') || strcmp(sect_hyd,'AR08_96') ...
        || strcmp(sect_hyd,'AR09_93B') || strcmp(sect_hyd,'AR09_92') 
      
   netcdf.putVar(ncid,netcdf.inqVarID(ncid,'STATION_PARAMETER'),tabphys_anas2_nc');
else
   netcdf.putVar(ncid,netcdf.inqVarID(ncid,'STATION_PARAMETER'),tabphys_nc');
end


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

% faux : revoir les fichiers car bathymetry a ete mal renseigne ...
% (bottom)
%netcdf.putVar(ncid,netcdf.inqVarID(ncid,'BATHYMETRY_BEGIN'),bottom) % sonde debut de station.
%netcdf.putVar(ncid,netcdf.inqVarID(ncid,'BATHYMETRY_END'),bottom)   % sonde fin de station
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'BATHYMETRY_BEGIN'),fillval) % sonde debut de station.
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'BATHYMETRY_END'),fillval)   % sonde fin de station

% Ecriture des donnees issues de la sonde
% Ecriture des flags de qualite.

 iflag1(1:nparam)=0;
for jj=1:nparam
    % ATTENTION ATTENTION ATTENTION
    % dans Woce, les bonnes mesures sont flaguees à 2 (dans hydro à 1) !!!   
    % dans Woce, les mesures non calibrees sont flaguees à 1 (dans hydro à 1 et DATA_MODE=not calibrated) !!!
    
    flag_nc=ones(4,nlevels);
    
    inotcalib = find(tflagbon(jj,:) ==1);
    if ~isempty(inotcalib)
       iflag1(jj) = 1;
       flag_nc(jj,inotcalib) = 1;
    end
    
    i3 = find(tflagbon(jj,:) == 3); 
    flag_nc(jj,i3) = 3;
    i6 = find(tflagbon(jj,:) == 6); 
    flag_nc(jj,i6) = 6; 
    i7 = find(tflagbon(jj,:) == 7); 
    flag_nc(jj,i7) = 7;
     
    i9 = find(tflagbon(jj,:)>= 9 | tflagbon(jj,:)<= 0 |tvalbon(jj,:) == -999);
    tvalbon(jj,i9)= fillval;
    flag_nc(jj,i9) =9;
    % test sur valeurs OXYK qui paraissent aberrantes,
    % avec des flags aberrants !
    if jj==4
      i9=find(tvalbon(jj,:) < 10);
      tvalbon(jj,i9) = fillval;
      flag_nc(jj,i9) =9;
    end

        netcdf.putVar(ncid,netcdf.inqVarID(ncid,tabphys_nc(jj,:)),tvalbon(jj,:));
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





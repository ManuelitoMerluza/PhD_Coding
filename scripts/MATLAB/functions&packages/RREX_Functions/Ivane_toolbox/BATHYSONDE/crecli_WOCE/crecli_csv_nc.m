

%-----------------------------------------------------------
%
% transformation des fichiers ASCII CCHDO en Netcdf cli LPO
% (.csv en _cli.nc)
%
% Catherine Lagadec / Octobre 2014 durant le CDD de Mathieu Hamon
%
% ----------------------------------------------------------
% programme utilisé pour les campagnes 
% ALBATROSS, AR04_3B, AR04_02, AR04_04, AR04_03A, AR07E05, AR18_94,
% AR18_93, AR15_00

clear all; close all;

ligne_flagp =  '1: good; 2: probably good; 3: probably bad;  4: bad; 6: interpolated over >2 dbar interval; 7: despiked; 9: No data';
fillval = -9999;
tabphys_nc = ['PRES';'TEMP';'PSAL';'OXYK'];

nomphys_nc = ['Sea Pressure                  '; ...
              'In situ temperature ITS-90    '; ...
              'Practical Salinity PSS78      '; ...
              'Dissolved oxygen concentration'];

%nomphys_nc = ['Sea Pressure                  '; ...
%              'Practical Salinity PSS78      '; ...
%              'In situ temperature ITS-90    ']; ...

valmin_nc = [0;-2;0;0];
valmax_nc = [15000;40;60;600];

unit_nc   = ['decibar        '; ...
             'degree celsius '; ...
             'psu            '; ...
             'micromol/kg    '];   
         
%valmin_nc = [0;0;-2];
%valmax_nc = [15000;60;40];

%unit_nc   = ['decibar        '; ...
%             'psu            '; ...
%             'degree celsius '];
         
% informations concernant la campagne devant être lues
% dans le fichier xls des campagnes (créé par Mathieu Hamon)

% lecture du fichier CCHDO_CSV.csv transformé à partir
% du fichier CCHDO_CSV.xlsx cree par Mathieu Hamon
% ce fichier contient :
% code section, EXPOCODE, navire, 
% dates de la campagne, pi, pays, organisme pi,section hydro

ff=fopen('/home1/homedir5/perso/clagadec/PROG_MATLAB/refonte_hydro_2013/crecli_WOCE/CCHDO_CSV.csv');
CCHDO=textscan(ff,'%s%s%s%s%s%s%s%s','Delimiter',',');
fclose(ff);
          
sect_hyd    = input('Section Hydro ? ', 's');

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


fcat = fopen('liste_fic') ;
nfic = fgetl(fcat);
nfic = str2double(nfic);

for i=1:nfic
    
 fic_woce=fgetl(fcat)
 fw=fopen(fic_woce);
 
 line1 = fgetl(fw);

iexpocode=false;
if exist(fic_woce,'file')
while ~iexpocode
    ligne=fgetl(fw);
    if strcmp(ligne(1:1),'E')
        iexpocode=true;
    end
end
expocode=ligne(12:end);

ligne=fgetl(fw);
sect_id=ligne(11:end);

ligne=fgetl(fw);
stat=str2double(ligne(10:end));
%if strcmp(sect_hyd,'AR18_94')
     cstat=sprintf('%4.4i',stat);
%  else
%     cstat=sprintf('%3.3i',stat);
%end

ligne=fgetl(fw);
ccast=ligne(10:end);
cast=str2num(ccast);

ligne=fgetl(fw);
cwdate=ligne(8:end);

ligne=fgetl(fw);
if strcmp(ligne(8:8),' ')
    cwtime=ligne(9:end);
else
    cwtime=ligne(8:end);
end

ligne=fgetl(fw);
lat=str2double(ligne(12:end));

ligne=fgetl(fw);
lon=str2double(ligne(13:end));

ligne=fgetl(fw);
deph=ligne(9:end);
bottom = str2double(deph);

ligne=fgetl(fw);
ligne=fgetl(fw);

% lecture des parametres du fichier csv
% on considere qu'il y a 4 param et un flag/ param
% d'ou N=8
% on ne reecrit pas theta (4eme param)

clear tvalcli tflag tvalbon tflagbon
if strcmp(sect_hyd,'AR15_00')
    N=12;
else
    N=8;
end
ifin = false;
nlevels = 0;

%  sections AR18_94 et AR18_93 : on ne traite pas OXYK car = à -999
% section  AR07E05 : on ne réécrit pas THETA

if strcmp(sect_hyd,'AR18_94') || strcmp(sect_hyd,'AR18_93') || strcmp(sect_hyd,'AR07E05')
    tabphys_nc =  ['PRES';'TEMP';'PSAL'];
end
[nparam,~] = size(tabphys_nc);

while ~ifin
         c=textscan(fw,'%s',N,'delimiter',',');
         if strcmp(cell2mat(c{1}(1)),'END_DATA')
              ifin = true;
         else
             nlevels = nlevels + 1;
             if strcmp(sect_hyd,'AR15_00')
                 % param :
                 % prs,flag,oxy,flag,ewct,flag,tmp,flag,nsct,flag,sal,sflag
                 tvalcli(1,nlevels) =   str2double(cell2mat(c{1}(1)));
                 tvalcli(2,nlevels) =   str2double(cell2mat(c{1}(7)));
                 tvalcli(3,nlevels) =   str2double(cell2mat(c{1}(11)));
                 tvalcli(4,nlevels) =   str2double(cell2mat(c{1}(3)));
                 tflag(1,nlevels) =  str2double(cell2mat(c{1}(2)));
                 tflag(2,nlevels) =  str2double(cell2mat(c{1}(8)));
                 tflag(3,nlevels) =  str2double(cell2mat(c{1}(12)));
                 tflag(4,nlevels) =  str2double(cell2mat(c{1}(4)));
             else
                 % param :
                 % prs,flag,tmp,flag,sal,flag,oxy(ou theta);flag
                 tvalcli(1,nlevels) =   str2double(cell2mat(c{1}(1)));
                 tvalcli(2,nlevels) =   str2double(cell2mat(c{1}(3)));
                 tvalcli(3,nlevels) =   str2double(cell2mat(c{1}(5)));
                 tvalcli(4,nlevels) =   str2double(cell2mat(c{1}(7)));
                 tflag(1,nlevels) =  str2double(cell2mat(c{1}(2)));
                 tflag(2,nlevels) =  str2double(cell2mat(c{1}(4)));
                 tflag(3,nlevels) =  str2double(cell2mat(c{1}(6)));
                 tflag(4,nlevels) =  str2double(cell2mat(c{1}(8)));
             end
         end
end

% suppression des valeurs de S et/ou de T égales à -99.99 en surface
% et/ou des flags à 9 en T et/ou S

isok1 = find(tvalcli(2,:) ~=-999. | tflag(2,:) ~= 9);
isok2 = find(tvalcli(3,:) ~=-999. | tflag(3,:) ~= 9);
isok=intersect(isok1,isok2);

tvalbon(1,:) = tvalcli(1,isok(1):isok(end));
tvalbon(2,:) = tvalcli(2,isok(1):isok(end));
tvalbon(3,:) = tvalcli(3,isok(1):isok(end));
tvalbon(4,:) = tvalcli(4,isok(1):isok(end));

tflagbon(1,:) = tflag(1,isok(1):isok(end));
tflagbon(2,:) = tflag(2,isok(1):isok(end));
tflagbon(3,:) = tflag(3,isok(1):isok(end));
tflagbon(4,:) = tflag(4,isok(1):isok(end));

[~,nlevels]=size(tvalbon);


%ouverture du fichier cli correspondant

ncid=netcdf.create([sect_hyd 'd' cstat '_' num2str(cast,'%3.3d') '_cli.nc'],'NC_CLOBBER');

% Declaration des dimensions.
dimstr4     = netcdf.defDim(ncid,'STRING4',4);
dimstr20    = netcdf.defDim(ncid,'STRING20',20);
dimstr7     = netcdf.defDim(ncid,'STRING7',7);
dimstr28    = netcdf.defDim(ncid,'STRING28',28);
dimnprof    = netcdf.defDim(ncid,'N_PROF',1);

dimnparam   = netcdf.defDim(ncid,'N_PARAM',nparam);
[~,nparam]  = netcdf.inqDim(ncid,dimnparam);

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

netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'CRUISE_NAME',section_hydro);
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'STATION_NUMBER',stat);
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'CAST',cast);
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'LEG_NUMBER',1);

netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'DIRECTION','d');

netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'DATA_PROCESSING_ORGANISM','CCHDO');
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'PROBE_TYPE','CTD');
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

comment = ['EXPOCODE= ' expocode  '   sect_hyd = ' sect_hyd  '    cast = ' ccast  '    line = ' line1];
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
   creat_newvar(ncid,[tabphys_nc(ip,:) '_QC'],'NC_FLOAT',[dimnlevels,dimnprof],'long_name',[deblank(nomphys_nc(ip,:)) ' quality flag'],'convention',ligne_flagp,'_FillValue',single(fillval));
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

 iflag1(1:nparam)=0;
for jj=1:nparam
    % ATTENTION ATTENTION ATTENTION
    % dans Woce, les bonnes mesures sont flaguees à 2 (dans hydro à 1) !!!   
    % dans Woce, les mesures non calibrees sont flaguees à 1 (dans hydro à 1 et DATA_MODE=not calibrated) !!!
    % si flag CCHDO = 1 : flag cli = 1 et not calibrated
    % si flag CCHDO = 0 ou absent : flag cli = 2 et not calibrated
    
    flag_nc=ones(4,nlevels);
    
    inotcalib = find(tflagbon(jj,:) == 1 | tflagbon(jj,:) == 0 );
    if ~isempty(inotcalib)
       iflag1(jj) = 1;
    end
    
    i0 = find(tflagbon(jj,:) == 0); 
    flag_nc(jj,i0) = 2;
    i3 = find(tflagbon(jj,:) == 3); 
    flag_nc(jj,i3) = 3;
    i6 = find(tflagbon(jj,:) == 6); 
    flag_nc(jj,i6) = 6; 
    i7 = find(tflagbon(jj,:) == 7); 
    flag_nc(jj,i7) = 7;
     
    i9 = find(tflagbon(jj,:)>= 9 | tflagbon(jj,:)< 0 | tvalbon(jj,:) == -999| tvalbon(jj,:) == -99.99);
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


clear all
close all




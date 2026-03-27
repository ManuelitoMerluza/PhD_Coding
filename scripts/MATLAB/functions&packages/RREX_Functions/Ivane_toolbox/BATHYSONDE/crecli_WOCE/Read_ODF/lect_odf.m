clear all; close all;

ligne_flagp =  '1: good; 2: probably good; 3: probably bad;  4: bad; 6: interpolated over >2 dbar interval; 7: despiked; 9: No data';
fillval = -9999;
tabphys_nc = ['PRES';'TEMP';'PSAL';'OXYL'];

% dans ODF (AR07W, campagnes de Igor Yashayaev), l'oxygene est OXYL

nomphys_nc = ['Sea Pressure                  '; ...
              'In situ temperature ITS-90    '; ...
              'Practical Salinity PSS78      '; ...
              'Dissolved oxygen concentration'];

valmin_nc = [0;-2;0;0];
valmax_nc = [15000;40;60;40];

unit_nc   = ['decibar        '; ...
             'degree celsius '; ...
             'psu            '; ...
             'ml/l           '];  
         
tab_mois = 'JANFEBMARAPRMAYJUNJULAUGSEPOCTNOVDEC';
         
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
nbfic = str2double(fgetl(fcat));

% fichiers ODF : on les lit a l'aide de read_odf
% et on obtient une structure S

for i=1:nbfic
    fic_odf=deblank(fgetl(fcat))

    if exist(fic_odf,'file')
      S= read_odf(fic_odf);
 %lecture des donnees
      clear tvalcli tvalbon isok nlevels
      tvalcli(1,:) = S.Data.PRES_01;
      tvalcli(2,:) = S.Data.TEMP_01;
      tvalcli(3,:) = S.Data.PSAL_01;
      tvalcli(4,:) = S.Data.DOXY_01;

% dans le 1er fichier, la dernière valeur de P est = 516,
% et l'avant-derniere à 517 : suppression de la derniere valeur
% dans le 2eme fichier, la dernière valeur de P est = 331,
% et l'avant-derniere à 332 : suppression de la derniere valeur
% dans le 3eme fichier, la dernière valeur de P est = 3449,
% et l'avant-derniere à 3450 : suppression de la derniere valeur

if strcmp(fic_odf,'D032A052.ODF') || strcmp(fic_odf,'D019A053.ODF') || strcmp(fic_odf,'D019A167.ODF') ...
         || strcmp(fic_odf,'CTD_HUD2008009_224_1_DN.ODF')  || strcmp(fic_odf,'CTD_HUD2010014_286_1_DN.ODF')
    clear tvalcli 
    tvalcli(1,:) = S.Data.PRES_01(1:end-1);
    tvalcli(2,:) = S.Data.TEMP_01(1:end-1);
    tvalcli(3,:) = S.Data.PSAL_01(1:end-1);
    tvalcli(4,:) = S.Data.DOXY_01(1:end-1);
end

if strcmp(fic_odf,'CTD_HUD2008009_223_1_DN.ODF')
    clear tvalcli
    tvalcli(1,:) = S.Data.PRES_01(2:end-1);
    tvalcli(2,:) = S.Data.TEMP_01(2:end-1);
    tvalcli(3,:) = S.Data.PSAL_01(2:end-1);
    tvalcli(4,:) = S.Data.DOXY_01(2:end-1);
end

% suppression des salinites ou temperature à -999 ou NaN

isok1=find(isfinite(tvalcli(3,:)));
isok2=find(isfinite(tvalcli(2,:)));
isok =intersect(isok1,isok2);

tvalbon(1,:) = tvalcli(1,isok(1):isok(end));
tvalbon(2,:) = tvalcli(2,isok(1):isok(end));
tvalbon(3,:) = tvalcli(3,isok(1):isok(end));
tvalbon(4,:) = tvalcli(4,isok(1):isok(end));

% remplacement des valeurs OXY à NaN par -9999
isnotok = ~isfinite(tvalbon(4,:));
tvalbon(4,isnotok)=fillval;
isnotok=find(tvalbon(4,:) < 0);
tvalbon(4,isnotok)=fillval;

[~,nlevels] = size(tvalbon);

% ouverture du fichier cli correspondant

% modif speciale pour D032B142.ODF car numero 
% de station pas renseigne dans fichier
%if strcmp(fic_odf,'D032B142.ODF')
%      cstat= '142';

% pour AR07W04A et B, on prend no station dans nom fichier
% (car pas tjs renseigne dans header)
       if strcmp(sect_hyd,'AR07W04A') || strcmp(sect_hyd,'AR07W04B')
         cstat = fic_odf(6:8);
       else
         cstat=S.Event_Header.Event_Number{1};
      end
      stat=str2double(cstat);  
      cstat=sprintf('%4.4i',stat);
      
% on suppose que le numéro de cast  se trouve dans   S.Event_Header.Event_Qualifier1   
      ccast = S.Event_Header.Event_Qualifier1{1};
      cast=str2double(ccast);
      ccast=sprintf('%3.3i',cast);
      
      ncid=netcdf.create([sect_hyd 'd' cstat '_' ccast '_cli.nc'],'NC_CLOBBER');


% Declaration des dimensions 

nparam = 4;
dimstr4     = netcdf.defDim(ncid,'STRING4',4);
dimstr20    = netcdf.defDim(ncid,'STRING20',20);
dimstr7     = netcdf.defDim(ncid,'STRING7',7);
dimstr28    = netcdf.defDim(ncid,'STRING28',28);
dimnprof    = netcdf.defDim(ncid,'N_PROF',1);

dimnparam   = netcdf.defDim(ncid,'N_PARAM',nparam);
[~,nparam]  = netcdf.inqDim(ncid,dimnparam);

% probleme de derniere valeur de P dans ces fichiers :
% suppression de la derniere valeur de PRES
% AR07W02 et D032A052.ODF : la dernière valeur de P est = 516,
% et l'avant-derniere à 517 
% AR07W04B et D019A053.ODF :la dernière valeur de P est = 331,
% et l'avant-derniere à 332 
% AR07W06 et D019A167.ODF :la dernière valeur de P est = 3449,
% et l'avant-derniere à 3450 
% AR07W08 et CTD_HUD2008009_223_1_DN.ODF :la dernière valeur de P est = 220,
% et l'avant-derniere à 221 (+ 1ere valeur PSALà NaN)

%if strcmp(fic_odf,'D032A052.ODF') || strcmp(fic_odf,'D019A053.ODF')|| strcmp(fic_odf,'D019A167.ODF') || strcmp(fic_odf,'CTD_HUD2008009_224_1_DN.ODF')
%    nlevels = nlevels - 1;
%end
%if strcmp(fic_odf,'CTD_HUD2008009_223_1_DN.ODF')
%    nlevels = nlevels - 2;
%end

dimnlevels  = netcdf.defDim(ncid,'N_LEVELS',nlevels);

dimdatetime = netcdf.defDim(ncid,'DATE_TIME',14);

% Declaration des attributs globaux
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'ORIGINAL_CLI',fic_odf);
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
if length(S.Cruise_Header.Cruise_Name{1}) >16
    cruise = S.Cruise_Header.Cruise_Name{1}(1:16);
else
    cruise = S.Cruise_Header.Cruise_Name{1};
end
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'CRUISE_NAME',cruise);
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'STATION_NUMBER',stat);
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'CAST',cast);

netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'LEG_NUMBER',1);

netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'DIRECTION','d');

netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'DATA_PROCESSING_ORGANISM','CCHDO');
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'PROBE_TYPE',S.Instrument_Header.Inst_Type{1});
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'PROBE_NUMBER',S.Instrument_Header.Model{1});
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'REFERENCE_DATE_TIME','19500101000000');
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'DATE_CREATION',datestr(now, 'yyyymmddHHMMSS'));
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'LAST_UPDATE',datestr(now, 'yyyymmddHHMMSS'));
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'COORD_SYSTEM','GEOGRAPHICAL-WGS84');


netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'PINGER','y');
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'SAMPLING_MODE','R');
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'SPUN_LINE',-9999);
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'DIST_PROBE_BOTTOM',abs(S.Event_Header.Depth_Off_Bottom));
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'PRESCRIBED_CTD_VELOCITY','1 m/s');
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'SOFTWARE_VERSION','Woce Software');

netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'CHEMISTRY_PARAMETERS','N');

%comment = ['EXPOCODE= ' expocode  '   sect_hyd = ' sect_hyd  '    cast = ' 1  '    line = ' line1];
comment = ['EXPOCODE= ' expocode  '   sect_hyd = ' sect_hyd  '    cast = ' 1' ];
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

% decodage de la date (sous la forme 20-JAN-2005 15:11:55:22)
% a ecrire sous la forme 20050120151155
dateodf = S.Event_Header.Start_Date_Time{1};
imois=strfind(tab_mois,dateodf(4:6));
if imois==0
    sprintf('date invalide');
else
    m=floor(imois/3)+1;
    mois=sprintf('%2.2i',m);
end

datedeb=[dateodf(8:11) mois dateodf(1:2) dateodf(13:14) dateodf(16:17) dateodf(19:20)];
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'STATION_DATE_BEGIN'),datedeb);
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'STATION_DATE_END'),datedeb);

juldd=jul_0h([str2double(datedeb(1:4)) str2double(datedeb(5:6)) str2double(datedeb(7:8)) str2double(datedeb(9:10)) str2double(datedeb(11:12)) 0])-jul_0h(1950,01,01,00);
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'JULD_BEGIN'),juldd);
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'JULD_END'),juldd);
lat=S.Event_Header.Initial_Latitude;
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'LATITUDE_BEGIN'),S.Event_Header.Initial_Latitude);
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'LATITUDE_END'),S.Event_Header.Initial_Latitude);

netcdf.putVar(ncid,netcdf.inqVarID(ncid,'LONGITUDE_BEGIN'),S.Event_Header.Initial_Longitude);
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'LONGITUDE_END'),S.Event_Header.Initial_Longitude);

% modif 29/01/15 - C.Lagadec
% recalcul du fond : dans les ficheirs ODF, Sounding est égal à 
% Pression max + Depth_Off_Bottom au lieu de Depth max (d'ou recalcul de DEPH)
% calcul de SIGI et de DEPH 
% on considere que les parametres du fichier cli sont dans l'ordre : P,T,S

 [~,tsig] = swstat90(tvalbon(3,end),tvalbon(2,end),tvalbon(1,end));
 deph  = prsenz(tvalbon(1,end), tsig, S.Event_Header.Initial_Latitude);
 deph = abs(deph);
 bottom=deph + abs(S.Event_Header.Depth_Off_Bottom)
 
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'BATHYMETRY_BEGIN'),bottom) % sonde debut de station.
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'BATHYMETRY_END'),bottom)   % sonde fin de station


% Ecriture des donnees issues de la sonde
% Ecriture des flags de qualite.

 iflag1(1:nparam)=0;
for jj=1:nparam
    % pas de flag : 1 dans les cli et not_calibrated
    
    flag_nc=ones(4,nlevels);
    
    iflag1(jj) = 1;
    
    netcdf.putVar(ncid,netcdf.inqVarID(ncid,tabphys_nc(jj,:)),tvalbon(jj,:));
    isnotok = find(tvalbon(jj,:)==fillval);
    flag_nc(jj,isnotok)=9;
    
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
    message=['Fichier inexistant : ' fic_odf]
end
end

fic=[sect_hyd '_rms.mat']
save fic rms_psalcalc rms_tempcalc

clear all
close all



    
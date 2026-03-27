function creenc(repwork,data_reduite,fic_chimie,fic_info,direction,cpttmp,cptoxy,cptcnd,tmp1_sensor_scale,tmp2_sensor_scale,prs_sensor_type,oxy1_sensor_type,oxy2_sensor_type)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Creation de la structure d'un fichier netcdf.  
%      
%  Exemple : 
%           repwork: repertoire de travail.
%           filename: nom du fichier résultat.
%           data_reduite: structure issue du programme de reduction(données
%           reduite et calibrées)
%           direction: Sens montee ou descente (A/D)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fillval=-9999; % Valeur de la FillValue de variables NetCDF.

% Information sur le type de capteur.
% Ces informations ne figurent ni dans les fichiers .con, ni dans les cnv.
% Lorsqu'il sera possible de les récupérer dans les fichier cnv de facon
% automatique le code sera change en consequence.

    tmp_sensor_type='SBE3';
    cnd_sensor_type='conductivity sensor :SBE4';

% Recuperation des numeros de serie des capteurs de la sonde.
% Les numeros sont lus dans data_reduite.entete .
sn=recup_SN_structdata(data_reduite.entete);
for i=1:length(sn)
    if (strcmpi(sn(i,2),'Pressure'))
        SNpres=sn{i,3};
    elseif (strcmpi(sn(i,2),'oxygen'))
        SNoxy1=sn{i,3};
    elseif (strcmpi(sn(i,2),'oxygen2'))
        SNoxy2=sn{i,3};
    elseif (strcmpi(sn(i,2),'Temperature'))
        SNtemp1=sn{i,3};
    elseif (strcmpi(sn(i,2),'Temperature2'))
        SNtemp2=sn{i,3};
    elseif (strcmpi(sn(i,2),'Conductivity'))
        SNcond1=sn{i,3};
    elseif (strcmpi(sn(i,2),'Conductivity2'))
        SNcond2=sn{i,3};
    end
end

% On test les capteurs selctionnes par l'utilisateur
% et on renseigne les informations capteur en fonction des informations
% recupéré dans l'entete des fichiers CNV (fct: read_sbe.m)
% Nota : pas d'info pour la conductivite.

if (cpttmp==1)
    tmp_sensor_scale=tmp1_sensor_scale;
    SN_temp=SNtemp1;
else
    tmp_sensor_scale=tmp2_sensor_scale;
    SN_temp=SNtemp2;
end

if (cptoxy==1)
    oxy_sensor_type=oxy1_sensor_type;
    SN_oxy=SNoxy1;
else
    oxy_sensor_type=oxy2_sensor_type;
    SN_oxy=SNoxy2;
end

if (cptcnd==1)
    SN_cnd=SNcond1;
else
    SN_cnd=SNcond2;
end


%recuperation des infos du fichier de PB. (sonde, ligne filee, dist. P/F, ...)
fid=fopen(fic_info,'r');
fgetl(fid);
chim_resp=upper(fgetl(fid));
chim_resp_organism=upper(fgetl(fid));
fgets(fid);
phys_resp=upper(fgetl(fid));
phys_resp_organism=upper(fgetl(fid));
frewind(fid);
pb=textscan(fid,'%d %d %f %f %f %f %d','headerlines',7);
fclose(fid);
%
% Lecture fichier chimie info pour recuperer les polynomes conductivite
% utilises et charger les fichiers flags correspondants.
%
fic_a_lire = [fic_chimie '_info.txt'];
fid = fopen(fic_a_lire,'r');
ligne = fgets(fid);
info_flag = [];
while ligne~=-1
     res = sscanf(ligne,'%*s %*s %*s %*s %*s %*s : %*s %*s %*s %*s %s');
     if cptcnd==1
      if strncmp(res,'cnd_',4)==1 & ~isempty(strfind(res,'cptcnd_p'))
         fic_flag = [repwork filesep 'flag_cond_swt90_' res(5:end)];
         info_flag = [info_flag; load(fic_flag)];
      end 
     else
         if strncmp(res,'cnd_',4)==1 & ~isempty(strfind(res,'cptcnd_s'))
         fic_flag = [repwork filesep 'flag_cond_swt90_' res(5:end)];
         info_flag = [info_flag; load(fic_flag)];
      end 
     end
     ligne = fgets(fid);
end
chaine = sprintf('Lecture du fichier des flag : %s',fic_flag);
warndlg(chaine);

fclose(fid);
% Lecture du fichier chimie
data_chimie = read_chimie(fic_chimie);
flag_cond = data_chimie.prs;

flag_cond(:) = 4; % Par defaut, tous les flags a mauvais.

for i_btl=1:length(flag_cond)
    if ~isempty(find(info_flag(:,1)==data_chimie.station(i_btl) & info_flag(:,2)==data_chimie.bottle(i_btl), 1))
        flag_cond(i_btl) = 1;
    end
end

% On recupere les infos utiles saisies dans l'interface depuis le fichier
% de configuration.
load(fullfile(repwork,'conf_user.mat'),'nom_navire','nom_mission','nom_responsable','organisme_pi','num_leg')


% Table de correspondance Navire / WMO;

if ~isempty(strfind(lower(nom_navire),'thal'))
    wmoid='FNFP';
elseif ~isempty(strfind(lower(nom_navire),'atal'))
    wmoid='FNCM';
elseif ~isempty(strfind(lower(nom_navire),'suro'))
    wmoid='FZVN';
elseif ~isempty(regexpi(nom_navire,'[a-z]'))
    wmoid='';
end


i=1;
res='';
while (strncmp(res,'* FileName',10)==0)
    res=data_reduite.entete(i,:);
    i=i+1;
end

ind_sta=strfind(res,'st');
num_sta=res(ind_sta(end)+2:ind_sta(end)+4);

% Creation du nom de fichier NetCdf a partir des noms de fichier contenu
% dans l'entete des fichiers cnv.
chaine = textscan(res,'%s','delimiter','\\');
filename=char(chaine{1}(end));
[a,filename,c] = fileparts(filename);
ind=findstr(filename,'st');
filenc=[repwork filesep filename(1:ind-1) direction num_sta '_cli.nc']; 
shortficname=[filename(1:ind-1) direction num_sta '_cli.nc'];
num_sta=str2num(num_sta);
%
% Recuperation des donnees chimie de cette station.
%
isok = find(data_chimie.station==num_sta);
bout_en_cours = data_chimie.bottle(isok);
nbot=length(bout_en_cours); % Nombre de bouteilles
flag_salc_sta = NaN(nbot,1);
flag_salc_sta(:) = -9999;
flag_salc_sta(bout_en_cours-2) = flag_cond(isok);
salc_sta = NaN(nbot,1);
salc_sta(:) = -9999;
salc_sta(bout_en_cours-2)=data_chimie.salc(isok);
oxyc_sta = NaN(nbot,1);
oxyc_sta(:) = -9999;
oxyc_sta(bout_en_cours-2)=data_chimie.oxyc(isok);
prsc_sta = NaN(nbot,1);
prsc_sta(:)=-9999;
prsc_sta(bout_en_cours-2)=data_chimie.prs(isok);
temp_sta = NaN(nbot,1);
temp_sta(:)=-9999;

if (cpttmp==1)
    temp_sta(bout_en_cours-2)=data_chimie.temp1(isok);
else
    temp_sta(bout_en_cours-2)=data_chimie.temp2(isok);
end

% On recherche la nombre de bouteille fermees
% pour la station en cours.
% boutok=find(data_chimie.station==num_sta);
% nbot=length(data_chimie.bottle(boutok));


ncid=netcdf.create(filenc,'NC_NOCLOBBER');

% Declaration des dimensions.
dimstr4=netcdf.defDim(ncid,'STRING4',4);
dimstr20=netcdf.defDim(ncid,'STRING20',20);
dimstr5=netcdf.defDim(ncid,'STRING5',5);
dimstr28=netcdf.defDim(ncid,'STRING28',28);
dimnprof=netcdf.defDim(ncid,'N_PROF',1);
dimnparam=netcdf.defDim(ncid,'N_PARAM',6);
dimnlevels=netcdf.defDim(ncid,'N_LEVELS',length(data_reduite.prs));
dimnbott=netcdf.defDim(ncid,'N_BOTTLES',nbot);
dimnparchim=netcdf.defDim(ncid,'N_PARAM_CHIM',4);
dimdatetime=netcdf.defDim(ncid,'DATE_TIME',14);


% Attribubut globaux recuperes depuis de fichier de info_ctd (PB).
% Dans un premier temps on recupere l'indice auquel on recupera les
% informations correspondant a la station.

if (strcmpi(direction,'a')==1)
    ind=find((pb{1}==num_sta) & (pb{2}==1));
else
    ind=find((pb{1}==num_sta) & (pb{2}==0));
end

dist_pf=pb{3}(ind);
sonde_deb=pb{4}(ind);
sonde_fin=pb{5}(ind);
ligne_filee=pb{6}(ind);
num_sonde=pb{7}(ind);



% Declaration des attributs globaux
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'ORIGINAL_CLI',shortficname);
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'SHIP_NAME',nom_navire);
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'SHIP_WMO_ID',wmoid);
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'PI_NAME',upper(nom_responsable));
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'PI_ORGANISM',upper(organisme_pi));
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'CRUISE_NAME',upper(nom_mission));
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'STATION_NUMBER',num_sta);
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'LEG_NUMBER',num_leg);
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'DIRECTION',direction);
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'DATA_PROCESSING_ORGANISM','LPO/IFREMER');
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'PROBE_TYPE','SBE 911');
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'PROBE_NUMBER',num_sonde);
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'REFERENCE_DATE_TIME','19500101000000');
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'DATE_CREATION',datestr(now, 'yyyymmddHHMMSS'));
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'LAST_UPDATE',datestr(now, 'yyyymmddHHMMSS'));
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'COORD_SYSTEM','GEOGRAPHICAL-WGS84');
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'BOTTLE_VOL','8L');
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'ROSETTE_TYPE','PASH New Generation');
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'PINGER','y');
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'SAMPLING_MODE','r');
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'DATA_MODE','calibrated');
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'LEG_NUMBER',num_leg);
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'SPUN_LINE',ligne_filee);
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'DIST_PROBE_BOTTOM',dist_pf);
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'PRESCRIBED_CTD_VELOCITY','1 m/s');

%% Declaration des variables

f_creer_newvar2(ncid,'LATITUDE_BEGIN','NC_DOUBLE',dimnprof,'long_name','Latitude begin of the station, best estimates','units','degree_north','convention','decimal degres','valid_min',-90,'valid_max',90,'_FillValue',double(fillval));
f_creer_newvar2(ncid,'LATITUDE_END','NC_DOUBLE',dimnprof,'long_name','Latitude end of the station, best estimates','units','degree_north','convention','decimal degres','valid_min',-90,'valid_max',90,'_FillValue',double(fillval));
f_creer_newvar2(ncid,'LONGITUDE_BEGIN','NC_DOUBLE',dimnprof,'long_name','Longitude begin of the station, best estimates','units','degree_east','convention','decimal degres','valid_min',-180,'valid_max',180,'_FillValue',double(fillval));
f_creer_newvar2(ncid,'LONGITUDE_END','NC_DOUBLE',dimnprof,'long_name','Longitude end of the station, best estimates','units','degree_east','convention','decimal degres','valid_min',-180,'valid_max',180,'_FillValue',double(fillval));
f_creer_newvar2(ncid,'STATION_DATE_BEGIN','NC_CHAR',[dimdatetime,dimnprof],'long_name','Beginning Date_Time of the station','conventions','YYYYMMDDHH24MISS');
f_creer_newvar2(ncid,'STATION_DATE_END','NC_CHAR',[dimdatetime,dimnprof],'long_name','End Date_Time of the station','conventions','YYYYMMDDHH24MISS');
f_creer_newvar2(ncid,'JULD_BEGIN','NC_DOUBLE',dimnprof,'long_name','Julian day (UTC) of the beginning of the station relative to REFERENCE_DATE_TIME','units','days since 1950-01-01 00:00:00 UTC','conventions','Relative julian Days with decimal part (as parts of day)','_FillValue',double(fillval));
f_creer_newvar2(ncid,'JULD_END','NC_DOUBLE',dimnprof,'long_name','Julian day (UTC) of the end of the station relative to REFERENCE_DATE_TIME','units','days since 1950-01-01 00:00:00 UTC','convetions','Relative julian Days with decimal part (as parts of day)','_FillValue',double(fillval));
f_creer_newvar2(ncid,'BATHYMETRY_BEGIN','NC_FLOAT',dimnprof,'long_name','Bathymetry at the beginning of the station','units','meters');
f_creer_newvar2(ncid,'BATHYMETRY_END','NC_FLOAT',dimnprof,'long_name','Bathymetry at the end of the station','units','meters');
f_creer_newvar2(ncid,'BOTTLE_NUMBER','NC_FLOAT',[dimnbott,dimnprof],'long_name','Bottle number','_FillValue',single(fillval));

% Création des variables concernant les mesures sonde  (P,T,S,O)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
f_creer_newvar2(ncid,'STATION_PARAMETER','NC_CHAR',[dimstr4,dimnparam],'long_name','Mesured parameter of the station');

f_creer_newvar2(ncid,'PRES','NC_FLOAT',[dimnlevels,dimnprof],'long_name','Pressure','Sensor_type',prs_sensor_type,'sensor_serial_number',SNpres,'resp_param',phys_resp,'srganisme_resp.',phys_resp_organism,'units','decibars','valid_min',0,'valid_max',15000,'_FillValue',single(fillval));
f_creer_newvar2(ncid,'TEMP','NC_FLOAT',[dimnlevels,dimnprof],'long_name',['In situ temperature ' tmp_sensor_scale],'sensor_number',cpttmp,'sensor_type',tmp_sensor_type,'sensor_serial_number',SN_temp,'resp_param',phys_resp,'organisme_resp.',phys_resp_organism,'units','degree_Celsius','valid_min',-15,'valid_max',50,'_FillValue',single(fillval));
f_creer_newvar2(ncid,'PSAL','NC_FLOAT',[dimnlevels,dimnprof],'long_name','Practical Salinity PSS78','Sensor_number',cptcnd,'sensor_type',cnd_sensor_type,'resp. param',phys_resp,'organisme_resp.',phys_resp_organism,'units','psu','valid_min',0,'valid_max',60,'_FillValue',single(fillval));
f_creer_newvar2(ncid,'SALS','NC_FLOAT',[dimnbott,dimnprof],'long_name','Probe Salinity','Sensor_number',cptcnd,'Sensor_type',cnd_sensor_type,'resp. param',phys_resp,'organisme_resp.',phys_resp_organism,'units','psu','valid_min',0,'valid_max',60,'_FillValue',single(fillval));
f_creer_newvar2(ncid,'OXYL','NC_FLOAT',[dimnlevels,dimnprof],'long_name','Dissolved oxygen concentration','sensor_number',cptoxy,'sensor_type',oxy_sensor_type,'sensor_serial_number',SN_oxy,'resp_param',phys_resp,'Organisme_resp.',phys_resp_organism,'units','ml/l','valid_min',0,'valid_max',40,'_FillValue',single(fillval));
f_creer_newvar2(ncid,'OXYK','NC_FLOAT',[dimnlevels,dimnprof],'long_name','Oxygen','sensor_number',cptoxy,'sensor_type',oxy_sensor_type,'sensor_serial_number',SN_oxy,'resp_param',phys_resp,'organisme_resp.',phys_resp_organism,'units','micromole/kg','valid_min',0,'valid_max',400,'_FillValue',single(fillval));

% Variables concrenant la chimie.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
f_creer_newvar2(ncid,'STATION_PARAMETER_CHIM','NC_CHAR',[dimstr5,dimnparchim],'long_name','Mesured chemistry parameter of the station');

f_creer_newvar2(ncid,'CHPRS','NC_FLOAT',[dimnbott,dimnprof],'long_name','Pressure','resp_param',chim_resp,'organisme_resp.',chim_resp_organism,'units','decibars','valid_min',0,'valid_max',15000,'_FillValue',single(fillval));
f_creer_newvar2(ncid,'CHTMP','NC_FLOAT',[dimnbott,dimnprof],'long_name','Temperature','resp_param',chim_resp,'organisme_resp.',chim_resp_organism,'units','degree_Celsius','valid_min',-15,'valid_max',40,'_FillValue',single(fillval));
f_creer_newvar2(ncid,'CHSAL','NC_FLOAT',[dimnbott,dimnprof],'long_name','Salinity ','resp_param.',chim_resp,'organism_resp.',chim_resp_organism,'units','psu','valid_min',0,'valid_max',60,'_FillValue',single(fillval));
f_creer_newvar2(ncid,'CHOXY','NC_FLOAT',[dimnbott,dimnprof],'long_name','Oxygen','resp_param.',chim_resp,'organism_resp.',chim_resp_organism,'units','ml/l','valid_min',0,'valid_max',40,'_FillValue',single(fillval));
f_creer_newvar2(ncid,'CHSAL_QC','NC_FLOAT',[dimnbott,dimnprof],'long_name','Salinity flag quality ','units','','_FillValue',single(fillval));
f_creer_newvar2(ncid,'CHOXY_QC','NC_FLOAT',[dimnbott,dimnprof],'long_name','Oxygen flag quality','units','','_FillValue',single(fillval));

netcdf.endDef(ncid);

% Calcul et conversion des paramètres de la sonde avant d'ecrire dans le
% fichier netCdf.

% Calcul de la salinite.
sal = sw_salt(data_reduite.cond/sw_c3515,data_reduite.temp,data_reduite.prs);

% Calcul de la salinite sonde associee au niveau bouteille calibree de la Sonde (Probe Salinity).
select_cond=['cond' num2str(cptcnd)];
select_temp=['temp' num2str(cpttmp)];

sals=NaN(nbot,1);
sals(:)=-9999;
salres = sw_salt(data_chimie.(select_cond)/sw_c3515,data_chimie.(select_temp),data_chimie.prs);
isok = find(data_chimie.station==num_sta);
sals(bout_en_cours-2)=salres(isok);
sals=sals';

% % Liste de bouteilles
% bout=NaN(nbot,1);
% bout(:)=-9999;
% bout(bout_en_cours-2)=bout_en_cours';

% Information constructeur propre au Capteur d'oxygene 
soc = 0.3941;
Voffset = -0.4915;
A = -9.8308e-4;             % NOTA: a mettre en parametre de la fct.
B = 1.2095e-4;
C = -1.9623e-6;
E = 0.036;


% Conversion de l'oxygene en Volt en millilitres/litre 
[phi, oxy_ml]=cal_oxyml(data_reduite.prs,data_reduite.temp,sal,data_reduite.oxy,soc, Voffset, A, B, C, E);

oxy_umol = convert_oxygen(oxy_ml,'mL/L','mumol/kg',sw_dens0(sal,data_reduite.temp)-1000);


%% Ecriture des informations dans les variables.
param=['TEMP';'PSAL';'SALS';'OXYL';'OXYK';'PRES'];
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'STATION_PARAMETER'),param');
%netcdf.putVar(ncid,netcdf.inqVarID(ncid,'STATION_PARAMETER'),'TEMP,PSAL,OXYL,OXYK');
paramchim=['CHTMP';'CHSAL';'CHOXY';'CHPRS'];
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'STATION_PARAMETER_CHIM'),paramchim');
%netcdf.putVar(ncid,netcdf.inqVarID(ncid,'STATION_PARAMETER_CHIM'),'TEMP_CHIM,PSAL_CHIM,OXY_CHIM');


netcdf.putVar(ncid,netcdf.inqVarID(ncid,'STATION_DATE_BEGIN'),datestr(greg_0h(data_reduite.jourdeb+jul_0h(data_reduite.an_ctd,1,0)),'yyyymmddHHMMSS'));
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'STATION_DATE_END'),datestr(greg_0h(data_reduite.jourfin+jul_0h(data_reduite.an_ctd,1,0)),'yyyymmddHHMMSS'));

netcdf.putVar(ncid,netcdf.inqVarID(ncid,'JULD_BEGIN'),(data_reduite.jourdeb+jul_0h(2008,1,1)-1-jul_0h(1950,1,1)));
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'JULD_END'),(data_reduite.jourfin+jul_0h(2008,1,1)-1-jul_0h(1950,1,1)));

netcdf.putVar(ncid,netcdf.inqVarID(ncid,'LATITUDE_BEGIN'),data_reduite.latdeb);
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'LATITUDE_END'),data_reduite.latfin);
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'LONGITUDE_BEGIN'),data_reduite.londeb);
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'LONGITUDE_END'),data_reduite.lonfin);

%netcdf.putVar(ncid,netcdf.inqVarID(ncid,'POSITIONING_SYSTEM'),'GPS ');
%netcdf.putVar(ncid,netcdf.inqVarID(ncid,'SVEL'),1500) % vitesse du son.

netcdf.putVar(ncid,netcdf.inqVarID(ncid,'BATHYMETRY_BEGIN'),sonde_deb) % sonde dedut de station.
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'BATHYMETRY_END'),sonde_fin) % sonde fin de station.

netcdf.putVar(ncid,netcdf.inqVarID(ncid,'BOTTLE_NUMBER'),flipud(bout_en_cours')) % Numeros des bouteilles fermées ordre decroissant

% Ecriture des données issues de la sonde.
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'PRES'),data_reduite.prs);
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'TEMP'),data_reduite.temp);
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'PSAL'),sal);
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'SALS'),sals);
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'OXYL'),oxy_ml);
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'OXYK'),oxy_umol);

% Ecriture des données chimie.
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'CHPRS'),flipud(prsc_sta));
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'CHTMP'),flipud(temp_sta));
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'CHSAL'),flipud(salc_sta));
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'CHOXY'),flipud(oxyc_sta));
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'CHSAL_QC'),flipud(flag_salc_sta));


netcdf.close(ncid);
%-------------------------------------------------------------------------------
%
%  nc_ARGO_mlt_header    - Creation du fichier Multistations 
%                          utilise au LPO
%                          (inspire du format NetCDF ARGO
%                          Argo Profile File Format 2.0)                
% %-------------------------------------------------------------------------------
%
%
%
%  Version:
%  --------
%
%  1.01   Creation/inspiration                          08/07/99  C.Lagadec
%       
%  1.02  Quelques modifs + ajout ecriture variables     03/09/99  F.Gaillard
%  1.03  Objectif CORIOLIS                              09/02/00  F.Gaillard
%        Separation ecriture en-tete et variable        
%        Modele d'en-tete : OCTOPUS (programme de T. Terre)  
%  1.04  Format CORIOLIS juin 2000                      19/06/00  F.Gaillard
%  1.05  Format CORIOLIS sept 2000                      21/09/00  F.Gaillard
%  1.06  Parametre de ref variable                      26/03/01  F.Gaillard
%  1.07  Ajout de la variable PI_ORGANISM               03/05/05  C.Lagadec
%        (organisme du chef de mission)
%  1.08  Ajout de la variable DATA_PROCESSING
%              (16 caracteres)                          20/06/05  C.Lagadec
%        codes possibles : HB2 pour Hydrobase2
%                          LPO/IFREMER 
%                          CCHDO pour les donnees provenant de WOCE
%                          (Clivar and Carbon Hydrographic Data Office)
%----------------------------------------------------------------------------
%
%    ficmlt_nc                  nom du fichier Multistation Netcdf                               
%    nb_profils                 nombre de profils (stations)
%    MLT.nbniv                  nombre de niveaux
%    navire                     nom du navire
%    wmo_id                     code du navire
%    inst_reference             sonde de reference
%    datref                     date de reference en jour julien (195001010000)
%    datsta                     date de debut des stations
%    datsta_fin                 date de fin des stations
%    latsta_deb
%    lonsta_deb
%    latsta_fin
%    lonsta_fin
%    pmax_stations
%    prefmax_stations
%    sondes_stations
%    chefmiss
%    org_resp
%    direction
%    cast
%    nomcamp
%    parametre_ref
%    project
%    MLT.parameters
%    station_number
%
%-----------------------------------------------------------------------------
 


function[msg_error] = nc_ARGO_mlt_header(ficmlt_nc);

                                  
globalVMLT;

% ------------------------
%    Create the new file
% ------------------------

fillval = -9999;         % Valeur FillValue des variables Netcdf

ncid = netcdf.create(ficmlt_nc,'NC_CLOBBER');

if ncid == -1,
   msg_error = ['nc_mlt_header : Probleme d''ouverture du fichier : ' ficmlt_nc];
   return
else
   msg_error = 'ok';
end

% taille de la liste des parametres
[nbpar_nc,n] = size(MLT.parameters);

% -----------------------------
%    Dimensions and Definitions
% -----------------------------
%  Fixed dimensions
% -----------------------------

dimstr14  = netcdf.defDim(ncid,'DATE_TIME',14);    %  Chaine date fichier (YYYYMMDDHHMISS)
dimstr2   = netcdf.defDim(ncid,'STRING2',2);            
dimstr4   = netcdf.defDim(ncid,'STRING4',4);              
dimstr8   = netcdf.defDim(ncid,'STRING8',8);              
dimstr16  = netcdf.defDim(ncid,'STRING16',16);
dimstr30  = netcdf.defDim(ncid,'STRING30',30);                        
dimstr64  = netcdf.defDim(ncid,'STRING64',64);              

%  Variable dimensions
% --------------------

dimnprof   = netcdf.defDim(ncid,'N_PROF', MLT.nbprof) ;        %  Number of profiles
dimnparam  = netcdf.defDim(ncid,'N_PARAM', nbpar_nc)  ;        %  Max number of parameters
dimnlevels = netcdf.defDim(ncid,'N_LEVELS',MLT.nbniv) ;        %  Number of levels

% -------------------------------
%    Defines NC_GLOBAL attributes
% ------------------------------- 

data_type = 'CTD';
if   (MLT.inst_reference(1,1) == 'X')
          data_type = 'XCTD';
end; 

netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'Data_type',data_type);


% test pour savoir si fichier clc traite par HYDROCAL 
% ou logiciel calibration fortran ou logiciel transcodage fichiers Woce 
if strcmp(MLT.data_processing,'LPO') & str2num(MLT.dat_begin(1,1:4)) > 2009 
      form_vers = 'Post CADHYAC 1.0-2014 ';
  else 
      form_vers = 'MLT 1.0-2014';
end
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'Format_version',form_vers);

date_ref = '19500101000000';
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'Reference_date_time',date_ref);


netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'Reference_param',CODE_REF);

project = input('Nom du projet ? ','s');
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'Project_name',project);


datecreat = datestr(now,30);
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'Date_creation',[datecreat(1:8) datecreat(10:15)]);
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'Last_update',[datecreat(1:8) datecreat(10:15)]);

COMMENTS = '';
if strfind(MLT.data_processing(1,:),'CCHDO')
   COMMENTS='Update HYDROCEAN with CCHDO';
end
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'COMMENTS',[COMMENTS '   ' COMMENT_CLC])

netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'Start_date',MLT.dat_begin(1,:))
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'Stop_date',MLT.dat_end(end,:))

netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'South_latitude',MLT.latmin)
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'North_latitude',MLT.latmax)
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'West_longitude',MLT.lonmin)
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'East_longitude',MLT.lonmax);
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'Coord_system','GEOGRAPHICAL-WGS84');

netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'Data_level','L2B'); 
if ~isempty(strfind(upper(MLT.data_mode),'NOT'))           
         netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'Data_level','L2A');
end
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'CHEMISTRY_PARAMETERS','N');

% ------------------------------------------
%    General information on the profile file
%
%    This section contains information 
%    about the whole file
% ------------------------------------------


nc_ARGO_mlt_var(ncid,'STATION_PARAMETER','NC_CHAR',[dimstr4,dimnparam], ...
                'long_name','List of available parameters for the station', ...
                'convention','GF3 code of the indexed parameter among (DEPH, PRES, PSAL, TEMP + extended codes)');

% ----------------------------------------
%    General information for each profile
%
%    Each item of this section has a 
%    N_PROF(number of profiles) dimension
% ----------------------------------------

nc_ARGO_mlt_var(ncid,'SHIP_NAME','NC_CHAR',[dimstr30,dimnprof], ...
                     'long_name','Name of the ship');

nc_ARGO_mlt_var(ncid,'SHIP_WMO_ID','NC_CHAR',[dimstr16,dimnprof], ...
                'long_name','WMO identifier of the ship');
            
nc_ARGO_mlt_var(ncid,'PI_NAME','NC_CHAR',[dimstr16,dimnprof], ...
                'long_name','Name of the principal investigator');
                
nc_ARGO_mlt_var(ncid,'PI_ORGANISM','NC_CHAR',[dimstr16,dimnprof], ...
                'long_name','Organism of the principal investigator');

nc_ARGO_mlt_var(ncid,'CRUISE_NAME','NC_CHAR',[dimstr16,dimnprof], ...
                'long_name','Name of the cruise');
        
nc_ARGO_mlt_var(ncid,'STATION_NUMBER','NC_FLOAT',dimnprof, ...
                'long_name','Station_NUMBER', ...
                'convention', 'From 1 to N' , ...
                '_FillValue', single(fillval));

nc_ARGO_mlt_var(ncid,'CAST','NC_FLOAT',dimnprof, ...
                'long_name','CAST', ...
                '_FillValue', single(fillval));

nc_ARGO_mlt_var(ncid,'DIRECTION','NC_CHAR',dimnprof, ...
                'long_name','Direction of the station : A, D', ...
                'convention', 'A:ascending profiles, D:descending profiles');
          
nc_ARGO_mlt_var(ncid,'DATA_PROCESSING_ORGANISM','NC_CHAR',[dimstr16,dimnprof], ...
                'long_name','Responsable of the data processing');

nc_ARGO_mlt_var(ncid,'INST_REFERENCE','NC_CHAR',[dimstr64,dimnprof], ...
                'long_name','Instrument type', ...
                'convention', 'Brand, type, serial number');

nc_ARGO_mlt_var(ncid,'STATION_DATE_BEGIN','NC_CHAR',[dimstr14,dimnprof], ...
                'long_name','Beginning date_time of each profile', ...
                'convention', 'YYYYMMDDHH24MISS');

nc_ARGO_mlt_var(ncid,'STATION_DATE_END','NC_CHAR',[dimstr14,dimnprof], ...
                'long_name','End date_time of each profile', ...
                'convention', 'YYYYMMDDHH24MISS');

nc_ARGO_mlt_var(ncid,'JULD_BEGIN','NC_FLOAT',dimnprof, ...
                'long_name','Julian day UTC of the beginning of the station relative to REFERENCE_DATE_TIME', ...
                'convention', 'Relative julian days with decimal part (as part of day)' , ...
                'units', 'days since 1950-01-01 00:00:00 UTC', ...
                '_FillValue', single(fillval));
            
nc_ARGO_mlt_var(ncid,'JULD_END','NC_FLOAT',dimnprof, ...
                'long_name','Julian day UTC of the end of the station relative to REFERENCE_DATE_TIME', ...
                'convention', 'Relative julian days with decimal part (as part of day)' , ...
                'units', 'days since 1950-01-01 00:00:00 UTC', ...
                '_FillValue', single(fillval));
            
nc_ARGO_mlt_var(ncid,'JULD','NC_FLOAT',dimnprof, ...
                'long_name','Julian day UTC  of the station relative to REFERENCE_DATE_TIME', ...
                'convention', 'Relative julian days with decimal part (as part of day)' , ...
                'units', 'days since 1950-01-01 00:00:00 UTC', ...
                '_FillValue', single(fillval));

 nc_ARGO_mlt_var(ncid,'LATITUDE_BEGIN','NC_DOUBLE',dimnprof, ...
                'long_name','Latitude begin of the station, best estimated', ...
                'units', 'degrees_north' , ...
                '_FillValue', fillval, ...
                'valid_min',-90, ...
                'valid_max',+90);
           
 nc_ARGO_mlt_var(ncid,'LATITUDE_END','NC_DOUBLE',dimnprof, ...
                'long_name','Latitude end of the station, best estimated', ...
                'units', 'degrees_north' , ...
                '_FillValue', fillval, ...
                'valid_min',-90, ...
                'valid_max',+90);    
            
 nc_ARGO_mlt_var(ncid,'LATITUDE','NC_DOUBLE',dimnprof, ...
                'long_name','Latitude of the station, best estimated', ...
                'units', 'degrees_north' , ...
                '_FillValue', fillval, ...
                'valid_min',-90, ...
                'valid_max',+90);
            
nc_ARGO_mlt_var(ncid,'LONGITUDE_BEGIN','NC_DOUBLE',dimnprof, ...
                'long_name','Longitude begin of the station, best estimated', ...
                'units', 'degrees_east' , ...
                '_FillValue', fillval, ...
                'valid_min',-180, ...
                'valid_max',+180); 
            
nc_ARGO_mlt_var(ncid,'LONGITUDE_END','NC_DOUBLE',dimnprof, ...
                'long_name','Longitude end of the station, best estimated', ...
                'units', 'degrees_east' , ...
                '_FillValue',fillval, ...
                'valid_min',-180, ...
                'valid_max',+180); 
            
nc_ARGO_mlt_var(ncid,'LONGITUDE','NC_DOUBLE',dimnprof, ...
                'long_name','Longitude of the station, best estimated', ...
                'units', 'degrees_east' , ...
                '_FillValue', fillval, ...
                'valid_min',-180, ...
                'valid_max',+180); 

nc_ARGO_mlt_var(ncid,'BOTTOM_DEPTH','NC_FLOAT',dimnprof, ...
                'long_name','Bottom depth of profiles ', ...
                'convention', 'in meters' , ...
                '_FillValue', single(fillval), ...
                'valid_min',0, ...
                'valid_max',15000); 

nc_ARGO_mlt_var(ncid,'MAX_PRESSURE','NC_FLOAT',dimnprof, ...
                'long_name','Maximum pressure of profiles ', ...
                'convention', 'in decibars' , ...
                '_FillValue', single(fillval), ...
                'valid_min',0, ...
                'valid_max',15000); 
   
nc_ARGO_mlt_var(ncid,'MAX_VALUE_PARAM_REF','NC_FLOAT',dimnprof, ...
                'long_name','Reference Parameter : max value of each profile',  ...
                '_FillValue', single(fillval));

netcdf.endDef(ncid);


% ----------------------------------------
%    Fills the position/date variables
% ----------------------------------------

netcdf.putVar(ncid,netcdf.inqVarID(ncid,'PI_NAME'),MLT.pi_name');
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'SHIP_NAME'),MLT.ship_name');
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'STATION_PARAMETER'),MLT.parameters');
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'DIRECTION'),MLT.direction);
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'INST_REFERENCE'),MLT.inst_reference');
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'STATION_NUMBER'),MLT.station_number);
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'CAST'),MLT.cast);
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'SHIP_WMO_ID'),MLT.ship_wmo_id');
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'PI_ORGANISM'),MLT.pi_organism');
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'CRUISE_NAME'),MLT.cruise_name');
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'DATA_PROCESSING_ORGANISM'),MLT.data_processing');
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'STATION_DATE_BEGIN'),MLT.dat_begin');
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'STATION_DATE_END'),MLT.dat_end');
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'JULD_BEGIN'),MLT.juld_begin');
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'JULD_END'),MLT.juld_end');
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'LATITUDE_BEGIN'),MLT.lat_begin');
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'LONGITUDE_BEGIN'),MLT.lon_begin');


% Latitudes fin et longitudes fin ne sont remplies
% que si elles sont differentes des latitudes et longitudes debut
% ----------------------------------------------------------------

ilat=find(MLT.lat_begin == MLT.lat_end);
if isempty(ilat) | length(ilat)<length(MLT.lat_begin)
       netcdf.putVar(ncid,netcdf.inqVarID(ncid,'LATITUDE_END'),MLT.lat_end');
end;

ilon=find(MLT.lon_begin == MLT.lon_end);
if isempty(ilon) | length(ilon)<length(MLT.lon_begin)
       netcdf.putVar(ncid,netcdf.inqVarID(ncid,'LONGITUDE_END'),MLT.lon_end');   
end

netcdf.putVar(ncid,netcdf.inqVarID(ncid,'BOTTOM_DEPTH'),MLT.sonde');
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'MAX_PRESSURE'),MLT.prmax');
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'MAX_VALUE_PARAM_REF'),MLT.parrefmax');

% modif 6/3/13 C.Lagadec
% ajout des variables LATITUDE, LONGITUDE et JULD
% qui sont les moyennes des variables BEGIN et END

latitude = (MLT.lat_begin + MLT.lat_end) / 2;
longitude = (MLT.lon_begin + MLT.lon_end) / 2;
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'LATITUDE'),latitude');
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'LONGITUDE'),longitude');
juldd=(MLT.juld_begin + MLT.juld_end)/2;
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'JULD'),juldd');

% fermeture du fichier NetCDF
% ---------------------------

netcdf.close(ncid);


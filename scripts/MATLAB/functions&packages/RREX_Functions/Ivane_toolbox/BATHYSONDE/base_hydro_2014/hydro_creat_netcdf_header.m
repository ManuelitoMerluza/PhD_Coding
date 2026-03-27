%-------------------------------------------------------------------------------
%
%  hydro_creat_netcdf_header    - Creation du fichier Multistations 
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
%  1.01   Creation                                      08/07/99  C.Lagadec
%       (largement inspire des sources des copines et copains ....
%
%  1.02  Quelques modifs + ajout ecriture variables     03/09/99  F.Gaillard
%  1.03  Objectif CORIOLIS                              09/02/00  F.Gaillard
%        Separation ecriture en-tete et variable        
%        Modele d'en-tete : OCTOPUS (programme de T. Terre)  
%  1.04  Format CORIOLIS juin 2000                      19/06/00  F.Gaillard
%  1.05  Format CORIOLIS sept 2000                      21/09/00  F.Gaillard
%  1.06  Parametre de ref variable                      26/03/01  F.Gaillard
%----------------------------------------------------------------------------
%
%    ficmlt_nc                                  
%    nb_stat_extract
%    nb_niv_extract
%    navire_sta
%    inst_reference_sta
%    datref
%    date_begin_sta
%    date_end_sta
%    juld_begin_sta
%    juld_end_sta
%    latsta_deb
%    lonsta_deb
%    latsta_fin
%    lonsta_fin
%    pmax_sta
%    prefmax_sta
%    sondes_sta
%    pi_sta
%    pi_org_sta
%    codwmo_sta
%    direction_sta
%    camp_sta
%    project
%    param_extract
%    station_number_sta
%
%-----------------------------------------------------------------------------
 


function hydro_creat_netcdf_header(ficmlt_nc, project)



%-------------------------------------------------------------------------------
%-------------------------------------------------------------------------------

% ------------------------
%    Create the new file
% ------------------------

parameters;

fillval = -9999;

ncid = netcdf.create(ficmlt_nc, 'NC_CLOBBER');



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

dimnprof   = netcdf.defDim(ncid,'N_PROF', nb_stat_extract) ;        %  Number of profiles
dimnparam  = netcdf.defDim(ncid,'N_PARAM', nb_par_extract)  ;        %  Max number of parameters
dimnlevels = netcdf.defDim(ncid,'N_LEVELS',nb_niv_extract) ;        %  Number of levels


% ----------------------------
%    Defines global attributes
% ----------------------------


data_type = 'CTD';
if inst_reference_sta(1:3) == 'XCT'
         data_type = 'XCTD';
  elseif inst_reference_sta(1,3) == 'XBT'
         data_type = 'XBT';
end
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'Data_type',data_type);

form_vers = 'MLT 1.0-2014';
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'Format_version',form_vers);


date_ref = '19500101000000';
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'Reference_date_time',date_ref);
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'Reference_param','DEPH');

netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'Project_name',project);


datecreat = datestr(now,30);
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'Date_creation',[datecreat(1:8) datecreat(10:15)]);

netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'Last_update',[datecreat(1:8) datecreat(10:15)]);


% calcul des dates limites des stations

datref(1) = str2double(date_ref(1:4));
datref(2) = str2double(date_ref(5:6));
datref(3) = str2double(date_ref(7:8));
hr_ref    = 0;
jjulref  = jul_0h(datref(1), datref(2), datref(3), hr_ref);

a = min(juldeb_sta);
b = max(julfin_sta);

netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'Start_date',date_conv(greg_0h(a + jjulref),'a'))
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'Stop_date',date_conv(greg_0h(b + jjulref),'a'))

netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'South_latitude',min(latdeb_sta))
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'North_latitude',max(latdeb_sta))
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'West_longitude',min(londeb_sta))
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'East_longitude',max(londeb_sta));

netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'Coord_system','GEOGRAPHICAL-WGS84');
netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'Data_level','L2B'); 

% verifier si chimie
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

nc_ARGO_mlt_var(ncid,'DIRECTION','NC_CHAR',dimnprof, ...
                'long_name','Direction of the station : A, D', ...
                'convention', 'A:ascending profiles, D:descending profiles');
          

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
            
% si l'on a des donnees H2V2 dans le fichier cree, on ecrit la variable FLAG_DBL

if ~isempty(flag_dbl_sta)
	nc_ARGO_mlt_var(ncid,'FLAG_DBL','NC_FLOAT',dimnprof, ...
	                'long_name','Flag=1 if H2V2 double with LPO', ...
	                'conventions','0 (not double) or 1 (double)', ...
	                '_FillValue',single(fillval), ...
	                'valid_min',0, ...
	                'valid_max',1);
   	
end

netcdf.endDef(ncid);

% ----------------------------------------
%    Fills the position/date variables
% ----------------------------------------

netcdf.putVar(ncid,netcdf.inqVarID(ncid,'PI_NAME'),pi_sta');
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'SHIP_NAME'),navire_sta');
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'STATION_PARAMETER'),param_extract');
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'DIRECTION'),direction_sta);
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'INST_REFERENCE'),inst_reference_sta');
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'STATION_NUMBER'),station_number_sta);
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'SHIP_WMO_ID'),codwmo_sta');
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'PI_ORGANISM'),pi_org_sta');
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'CRUISE_NAME'),camp_sta');
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'STATION_DATE_BEGIN'),datedeb_sta');
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'STATION_DATE_END'),datefin_sta');
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'JULD_BEGIN'),juldeb_sta');
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'JULD_END'),julfin_sta');
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'LATITUDE_BEGIN'),latdeb_sta');
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'LONGITUDE_BEGIN'),londeb_sta');

%revoir
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'LATITUDE_END'),latfin_sta');
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'LONGITUDE_END'),lonfin_sta');   

netcdf.putVar(ncid,netcdf.inqVarID(ncid,'BOTTOM_DEPTH'),sondes_sta');
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'MAX_PRESSURE'),pmax_sta');
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'MAX_VALUE_PARAM_REF'),prefmax_sta');

latitude = (latdeb_sta + latfin_sta) / 2;
longitude = (londeb_sta + lonfin_sta) / 2;
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'LATITUDE'),latitude');
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'LONGITUDE'),longitude');
juldd=(juldeb_sta + julfin_sta)/2;
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'JULD'),juldd');

if ~isempty(flag_dbl_sta)
    netcdf.putVar(ncid,netcdf.inqVarID(ncid,'FLAG_DBL'), flag_dbl_sta');
end



% fermeture du fichier NetCDF
% ---------------------------

netcdf.close(ncid);





function  lcetis(ficuni)

% fonction LCETIS 
% Lecture des renseignements descriptifs 
% d'un fichier Unistation Netcdf (cli ou clc )
% creation d'une structure ETIQ comprenant :
% -------------------------------------------------
% typereduc        SAMPLING_MODE
% pi               PI_NAME
% orgresp          PI_ORGANISM
% navire           SHIP_NAME
% cruise           CRUISE_NAME
% direction        DIRECTION
% cast             CAST (si existe)
% nval             Nb niveaux physiques
% codes_paramc     STATION_PARAMETER_CHIM
% codes_paramp     STATION_PARAMETER
% lat_deb          LATITUDE_BEGIN
% lon_deb          LONGITUDE_BEGIN
% lat_fin          LATITUDE_END
% lon_fin          LONGITUDE_END
% sonde_deb        BATHYMETRY_BEGIN
% sonde_fin        BATHYMETRY_END
% juld_begin       JULD_BEGIN
% juld_end         JULD_END
% nparp            Nb param physiques
% nparc            Nb param chimiques
% nbottles         nb bouteilles (si chimie)
%---------------------------------------------------

globalVarEtiquni

a         = ncinfo(ficuni);
nameAtt   = {a.Attributes.Name};
[~,nbAtt] = size(nameAtt);

ETIQ.typereduc       = ncreadatt(ficuni,'/','SAMPLING_MODE');
ETIQ.pi              = ncreadatt(ficuni,'/','PI_NAME');
ETIQ.orgresp         = ncreadatt(ficuni,'/','PI_ORGANISM');
ETIQ.navire          = ncreadatt(ficuni,'/','SHIP_NAME');
ETIQ.ship_wmo_id     = ncreadatt(ficuni,'/','SHIP_WMO_ID');
ETIQ.cruise          = ncreadatt(ficuni,'/','CRUISE_NAME');
ETIQ.direction       = ncreadatt(ficuni,'/','DIRECTION');
ETIQ.probe_type      = ncreadatt(ficuni,'/','PROBE_TYPE');
ETIQ.probe_number    = ncreadatt(ficuni,'/','PROBE_NUMBER');
ETIQ.station_number  = ncreadatt(ficuni,'/','STATION_NUMBER');
ETIQ.data_mode       = ncreadatt(ficuni,'/','DATA_MODE');
ETIQ.dataprocessing  = ncreadatt(ficuni,'/','DATA_PROCESSING_ORGANISM');

% le cast n'existe pas dans tous les fichiers cli (ou clc)
% modif faite en janvier 2015 par C.L.

ETIQ.cast = 1;
for i=1:nbAtt
    if strcmp(nameAtt{i},'CAST')
        ETIQ.cast = ncreadatt(ficuni,'/','CAST');
    end
end

dimlength = {a.Dimensions.Length};
[~,ldim]=size(dimlength);
ETIQ.nval = dimlength{7};
ETIQ.nparp = dimlength{6};

ETIQ.nparc    = 0;
ETIQ.nbottles = 0;

%test si chimie
 if ldim > 8
          ETIQ.nparc         = dimlength{9};
          ETIQ.nbottles      = dimlength{8};
          ETIQ.codes_paramc  = ncread(ficuni,'STATION_PARAMETER_CHIM')';
end

ETIQ.codes_paramp  = ncread(ficuni,'STATION_PARAMETER')';

ETIQ.lat_deb       = ncread(ficuni,'LATITUDE_BEGIN');
ETIQ.lon_deb       = ncread(ficuni,'LONGITUDE_BEGIN');

ETIQ.lat_fin       = ncread(ficuni,'LATITUDE_END');
ETIQ.lon_fin       = ncread(ficuni,'LONGITUDE_END');

ETIQ.sonde_deb     = ncread(ficuni,'BATHYMETRY_BEGIN');
ETIQ.sonde_fin     = ncread(ficuni,'BATHYMETRY_END');

ETIQ.juld_begin    = ncread(ficuni,'JULD_BEGIN');
ETIQ.juld_end      = ncread(ficuni,'JULD_END');

ETIQ.station_date_begin  = ncread(ficuni,'STATION_DATE_BEGIN');
ETIQ.station_date_end    = ncread(ficuni,'STATION_DATE_END');


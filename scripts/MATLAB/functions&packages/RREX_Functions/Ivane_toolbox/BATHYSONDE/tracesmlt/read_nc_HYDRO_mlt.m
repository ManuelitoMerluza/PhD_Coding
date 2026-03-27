% 
% function [lat,lon,juld,cycnum,varargout]=read_nc_ARGO_mlt_prof(file_name,varargin)
%
% Programme de lecture des fichiers multiprofils
% des flotteurs ARGO
%
% Creation : V. Thierry, mars 2005
% 

function [lat,lon,juld,statnum,direction,varargout]=read_nc_HYDRO_mlt(nc,varargin)

    % Reads general informations
         
    lat          = netcdf.getVar(nc,netcdf.inqVarID(nc,'LATITUDE_BEGIN'));  % Latitude of the station, best estimate
    lon          = netcdf.getVar(nc,netcdf.inqVarID(nc,'LONGITUDE_BEGIN')); % Longitude of the station, best estimate
    statnum      = netcdf.getVar(nc,netcdf.inqVarID(nc,'STATION_NUMBER'));  % Float cycle number 
    juld         = netcdf.getVar(nc,netcdf.inqVarID(nc,'JULD_BEGIN')); 
    direction    = netcdf.getVar(nc,netcdf.inqVarID(nc,'DIRECTION'));
    
    
    if nargin > 1
      for i=2:nargin
        tempo=varargin{i-1};
        varid=netcdf.inqVarID(nc,tempo);
        varia=netcdf.getVar(nc,varid);
        varargout{i-1}=varia;
      end
    end
    
    netcdf.close(nc)
    
end


  



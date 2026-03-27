
function ecchms(filenc,ncid,codvar,nomvar,respnom,resporg,unitvar,minvar,maxvar,fillval,tabvar,iexist)

% -------------------------------------------------------------------------------------
% ecriture d'un parametre chimique dans un fichier Netcdf Unistation (cli.nc ou clc.nc)
% -------------------------------------------------------------------------------------
%
% filenc       : nom du fichier Netcdf
% ncid         : unite du fichier Netcdf
% codvar       : code parametre
% nomvar       : nom du parametre
% respnom      : nom du responsable des mesures de ce param
% resporg      : organisme du responsable des mesures
% unitvar      : unites
% minvar       : valeur mini autorisee
% maxvar       : valeur maxi autorisee
% fillval      : fillevalue
% tabvar       : tableau des valeurs
% iexist       si = 0, ajout du param, si = 1, écrasement du param



globalVarEtiquni;

if  iexist == 0
     netcdf.reDef(ncid);

% lecture des dimensions 
     dimnprof = netcdf.inqDimID(ncid,'N_PROF');
     dimnbot  = netcdf.inqDimID(ncid,'N_BOTTLES');
     dimparam = netcdf.inqDimID(ncid,'N_PARAM_CHIM');
     [~,nparam] = netcdf.inqDim(ncid,dimparam);
 
% definition du nouveau parametre et des ses attributs

%     f_creer_newvar2(ncid,codvar,'NC_FLOAT',[dimnbot,dimnprof],'long_name',nomvar,'units',unitvar,'Smoothing',attr_liss,'Method',attr_meth,'valid_min',minvar,'valid_max',maxvar,'_FillValue',single(fillval));
%netcdf.endDef(ncid);
     creer_newvar(ncid,codvar,'NC_FLOAT',[dimnbot,dimnprof],'long_name',nomvar,'units',unitvar,'Smoothing',attr_liss,'Method',attr_meth,'valid_min',minvar,'valid_max',maxvar,'_FillValue',single(fillval));
netcdf.endDef(ncid);
% ecriture des valeurs du nouveau parametre 

  netcdf.putVar(ncid,netcdf.inqVarID(ncid,codvar),tabvar');

% Modification du tableau STATION_PARAMETER_CHIM : 
%   ajout du code du paramètre calculé

  ETIQ.codes_paramc = strvcat(ETIQ.codes_paramc,codvar);
  netcdf.putVar(ncid,netcdf.inqVarID(ncid,'STATION_PARAMETER_CHIM'),[0 nparam],[4 1],codvar');
  nparam=nparam+1;
  ETIQ.nparc = nparam; 
else
    
% ecrasement des valeurs du parametre existant 
% et modification de 2 attributs
  netcdf.putVar(ncid,netcdf.inqVarID(ncid,codvar),tabvar'); 
 % ncwriteatt(filenc,codvar,'Smoothing',attr_liss);
 % ncwriteatt(filenc,codvar,'Method',attr_meth);
  
end




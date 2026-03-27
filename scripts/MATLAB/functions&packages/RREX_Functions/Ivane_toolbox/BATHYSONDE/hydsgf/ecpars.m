
function ecpars(filenc,ncid,codvar,nomvar,unitvar,attr_prec,attr_liss,attr_meth,minvar,maxvar,fillval,tabvar, ...
                            codvar_qc, nomvar_qc, tabvar_qc, iexist)

% ------------------------------------------------------------------
% ecriture d'un parametre dans un fichier Netcdf Unistation (clc.nc)
% ------------------------------------------------------------------
%
% filenc       : nom du fichier Netcdf
% ncid         : unite du fichier Netcdf
% codvar       : code parametre
% nomvar       : nom du parametre
% unitvar      : unites
% attr_liss    : decodage lissage
% attr_meth    : decodage methode calcul
% minvar       : valeur mini autorisee
% maxvar       : valeur maxi autorisee
% fillval      : fillevalue
% tabvar       : tableau des valeurs
% iexist       si = 0, ajout du param, si = 1, ecrasement du param


globalVarEtiquni;

attr_conv =  '1: good, 2: probably good; 8: interpolated, 9: No data';

% le parametre n'existe pas, il faut creer la variable, les dimensions ...
% et rajouter le caode param dans STATION_PARAMETER

if  iexist == 0
     netcdf.reDef(ncid);

% lecture des dimensions 
     dimnprof = netcdf.inqDimID(ncid,'N_PROF');
     dimnlev  = netcdf.inqDimID(ncid,'N_LEVELS');
     dimparam = netcdf.inqDimID(ncid,'N_PARAM');
     [~,nparam] = netcdf.inqDim(ncid,dimparam);
 
% definition du nouveau parametre et des ses attributs
% definition du nouveau code qualite et de ses attributs

     creat_newvar(ncid,codvar,'NC_FLOAT',[dimnlev,dimnprof],'long_name',nomvar,'units',deblank(unitvar),'precision',attr_prec,'Smoothing',attr_liss,'Method',attr_meth, 'valid_min',minvar,'valid_max',maxvar,'_FillValue',single(fillval));
     creat_newvar(ncid,codvar_qc,'NC_FLOAT',[dimnlev,dimnprof],'long_name',nomvar_qc,'convention',attr_conv,'_FillValue',single(fillval));
netcdf.endDef(ncid);

% Modification du tableau STATION_PARAMETER : 
%   ajout du code du parametre calcule

%  ETIQ.codes_paramp = strvcat(ETIQ.codes_paramp,codvar); 
  ETIQ.codes_paramp = char(ETIQ.codes_paramp,codvar);
  netcdf.putVar(ncid,netcdf.inqVarID(ncid,'STATION_PARAMETER'),[0 nparam],[4 1],codvar');
  nparam=nparam+1;
  ETIQ.nparp = nparam; 
  
end

% ecriture des valeurs du parametre si nouveau et des attributs
% ou   
% ecrasement des valeurs du parametre existant 
% et modification de 2 attributs
  
  netcdf.putVar(ncid,netcdf.inqVarID(ncid,codvar),tabvar'); 
  ncwriteatt(filenc,codvar,'Smoothing',attr_liss);
  ncwriteatt(filenc,codvar,'Method',attr_meth);
  
% ecriture des flags associes au parametre
 netcdf.putVar(ncid,netcdf.inqVarID(ncid,codvar_qc),tabvar_qc');
 ncwriteatt(filenc,codvar_qc,'convention',attr_conv);
 
% LAST_UPDATE modifiee à chaque ecriture d'un nouveau parametre
 
 ncwriteatt(filenc,'/','LAST_UPDATE',datestr(now, 'yyyymmddHHMMSS'));



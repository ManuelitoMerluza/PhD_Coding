function creat_newvar(nc,namevar,type,dimid,varargin)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Cascade Exploitation :
% -----------------------
%
%  Fonction permettant de creer une nouvelle 
%   Variable dans un fichier netcdf deja ouvert.
%   Fonction a utiliser pour creer plusieurs variables dans un meme fichier NetCDF existant.
%
%   creat_newvar(filenc,namevar,type,dimvar,varargin)
%
% En entree :
% -------------
%   nc : identifiant du fichier NetCDF ou la variable doit etre creee (doit deja etre en mode reDef).
%   namevar : nom de la variable a creer
%   type : Type de la variable
%   dimid :  Liste des identifiants des dimensions de la variable. 
%   varargin : liste(nom,valeur) des attributs de la variable a creer.  ex: 'long_name','Vitessse en ms'
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%      cree a partir de creat_newvar.m 
%      de C. Kermabon - P Le Bot Avril 2009
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PL, Mai 2013: modification pour tenir compte que depuis Matlab 2012a, on
% ne peut plus definir la _FillValue comme un attribut standard
% (correspond a un chgt pour du netcdf 4.1.3 au lieu de 4.1.2, mais ce
% n'est pas sur) uniquement sur les netcdf4

% Definition/Creation de la variable.

id_var=netcdf.defVar(nc,namevar,type,dimid);
format_netcdf = netcdf.inqFormat(nc);
% Et de ses attributs.
for iatt=1:2:size(varargin,2)
    if strcmp(varargin{iatt},'_FillValue')
      if verLessThan('matlab','8.0.0') || ~strcmp(format_netcdf,'FORMAT_NETCDF4')
        netcdf.putAtt(nc,id_var,varargin{iatt},varargin{iatt+1});
      else
        netcdf.defVarFill(nc,id_var,false,varargin{iatt+1});
      end
    else
        netcdf.putAtt(nc,id_var,varargin{iatt},varargin{iatt+1});
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Script permettant de renommer un ensemble de fichier CLI afin
% que le nom de fichier fasse apparaitre le numéro de position géographique
% (=numéro de station) et le numéro de profil.
% 
% Nomenclature avant renommage :
%       IDENTCAMP{d/a}XXX_cli.nc avec :
%               d   : pour descente ou a : pour montée
%               XXX : numéro séquentiel de fichier sur 3 caractères.
% Nomenclature après renommage :
%       IDENTCAMP{d/a}XXXX_YYY_cli.nc avec :
%               d   : pour descente ou a : pour montée
%               XXXX : numéro de station/position geographique sur 4 caractères.
%               YYY : numéro de profil sur 3 caractères.
%
% La correspondance des numéros de fichiers avec les numéros de positions
% géographiques et profils est fournie dans un fichier ASCII comprenant 3
% colonnes :
%           Numero_de_fichier   Numero_de_position  Numero_de_profil
%
%
% Ce script a été développé suite à la campagne GEOVIDE pour laquelle
% plusieurs profils CTD ont été acquis à une même position géographique.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Creation :    C. Kermabon     13/01/2015
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;
close all;

fillval = -9999;         % Valeur FillValue des variables Netcdf

fic_liste= input('Liste des MLT ? ','s');
fl=fopen(fic_liste)
nfic=str2num(fgetl(fl))
for i=1:nfic

 %fic_mlt = input('Nom du MLT ? ','s');
 fic_mlt=fgetl(fl)
 
mltnc   = netcdf.open(fic_mlt,'NC_WRITE');
 
netcdf.reDef(mltnc);
 
 a         = ncinfo(fic_mlt);
 dimlength = {a.Dimensions.Length};
[~,ldim]=size(dimlength);
nprof = dimlength{8};

dimnprof      = netcdf.inqDimID(mltnc,'N_PROF');

 creat_newvar(mltnc,'CAST','NC_FLOAT',dimnprof, ...
                'long_name','CAST', ...
                '_FillValue', single(fillval));

netcdf.endDef(mltnc);

cast=ones(nprof,1);
ncwrite(fic_mlt,'CAST',cast);
ncwriteatt(fic_mlt,'/','Last_update',datestr(now,'yyyymmddHHMMSS')); 
netcdf.close(mltnc);

end
clear all
close all


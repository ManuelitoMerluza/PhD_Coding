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

% ***********************************************************************
% a adapter pour corriger tous MLT HYDROCEAN (sauf MAJ 2014)

   rep_MLT_NC = '/home/lpo5/HYDROCEAN/MLT_NC/ATLANTIQUE_NORD/'
   rep_COMPLET          = '';
   zones_COMPLET        = '';
   files_rep            = '';
   
   fillval = -9999;         % Valeur FillValue des variables Netcdf



% Recherche dans le repertoire de la base ARCHIVAGE CTD
% (repertoire par repertoire) de tous les fichiers
% Multistations Netcdf (NOM_FIC_MLT)
% -------------------------------------------------------

   ff1 = dir(rep_MLT_NC);

   for ix=1:length(ff1)
           if (~(strcmp(ff1(ix).name, '.')) && ~(strcmp(ff1(ix).name, '..')) && ff1(ix).isdir)
              zones_COMPLET=char(zones_COMPLET,[rep_MLT_NC ff1(ix).name]);
           end;
   end;

% Recherche dans le repertoire de la base ARCHIVAGE CTD
% (repertoire par repertoire) de tous les fichiers
% Multistations Netcdf (NOM_FIC_MLT)
% -------------------------------------------------------

   [nbdir,~] = size(zones_COMPLET)

   for ii = 1:nbdir
           ff2 = dir(deblank(zones_COMPLET(ii,:)));

           for ix=1:length(ff2)
               if (~(strcmp(ff2(ix).name, '.')) && ~(strcmp(ff2(ix).name, '..')) && ff2(ix).isdir)
                    rep_COMPLET=char(rep_COMPLET,[deblank(zones_COMPLET(ii,:)) '/' ff2(ix).name]);
               end;
           end;
  end

 

   for i=1:nbdir

         rep = [deblank(rep_COMPLET(i,:)) '/']
         if strcmp(rep,'/home/lpo5/HYDROCEAN/MLT_NC/ATLANTIQUE_NORD/A01E/')  || ...
            strcmp(rep,'/home/lpo5/HYDROCEAN/MLT_NC/ATLANTIQUE_NORD/A05/')  || ...
            strcmp(rep,'/home/lpo5/HYDROCEAN/MLT_NC/ATLANTIQUE_NORD/A16N/')  || ...
            strcmp(rep,'/home/lpo5/HYDROCEAN/MLT_NC/ATLANTIQUE_NORD/A20/')  || ...
            strcmp(rep,'/home/lpo5/HYDROCEAN/MLT_NC/ATLANTIQUE_NORD/A22/')  || ...
            strcmp(rep,'/home/lpo5/HYDROCEAN/MLT_NC/ATLANTIQUE_NORD/A24/')  || ...
            strcmp(rep,'/home/lpo5/HYDROCEAN/MLT_NC/ATLANTIQUE_NORD/A25/')  || ...
            strcmp(rep,'/home/lpo5/HYDROCEAN/MLT_NC/ATLANTIQUE_NORD/A6-24N/')  
               text='deja fait !'
           else
         
               suff = '_DEPH.nc';
         
               mask = sprintf('%s%s', '*', suff);
               filtre = sprintf('%s%1c%s', rep,  mask);
               ff=dir(filtre)

               for ix=1:length(ff) 
                 if ~ff(ix).isdir
                  files_rep=char(files_rep,[rep ff(ix).name])
                 end
               end
          end
   end

   fic_MLT_COMPLET       = sortrows(files_rep)
   [nbfic_MLT_COMPLET,~] = size(fic_MLT_COMPLET)



% -------------------------------
% boucle sur les fichiers Netcdf
% -------------------------------

 if nbfic_MLT_COMPLET > 0

   for i =  2:nbfic_MLT_COMPLET
      fic_mlt = deblank(fic_MLT_COMPLET(i,:))
      mltnc = netcdf.open(fic_mlt,'NC_WRITE');
      
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

   else
        a='erreur'
 end

% *********************************************************************

 

clear all
close all


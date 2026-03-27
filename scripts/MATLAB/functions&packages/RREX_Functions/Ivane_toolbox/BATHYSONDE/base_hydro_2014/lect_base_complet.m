%------------------------------------------------------------------------------
%  Projet ATLANTIQUE NORD
%  ----------------------
%  Version: 1.0
%  ------------
%  Creation :Fevrier 2003 /  C.Lagadec
%                                            
%------------------------------------------------------------------------------
%  Visualisation des positions des stations de toute la base
%------------------------------------------------------------------------------


function [rep_COMPLET, fic_MLT_COMPLET, nbfic_MLT_COMPLET, ...
          data_type_complet, project_complet, ... 
          start_date_complet, stop_date_complet, ...
          south_lat_complet,  north_lat_complet, ...
          west_lon_complet,  east_lon_complet, ...
          latdeb_complet, londeb_complet]     = lect_base_complet()


parameters;

global_rep;


   rep_COMPLET          = '';
   zones_COMPLET        = '';
   files_rep            = '';
   latdeb_complet       = [];
   londeb_complet       = [];
   project_complet      = '';
   data_type_complet    = '';
   start_date_complet   = '';
   stop_date_complet    = '';
   south_lat_complet    = [];
   north_lat_complet    = [];
   west_lon_complet     = [];
   east_lon_complet     = [];


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

   [nbdir,~] = size(zones_COMPLET);

   for ii = 1:nbdir
           ff2 = dir(deblank(zones_COMPLET(ii,:)));

           for ix=1:length(ff2)
               if (~(strcmp(ff2(ix).name, '.')) && ~(strcmp(ff2(ix).name, '..')) && ff2(ix).isdir)
                    rep_COMPLET=char(rep_COMPLET,[deblank(zones_COMPLET(ii,:)) '/' ff2(ix).name]);
               end;
           end;
  end

   [nbdir,~] = size(rep_COMPLET);

   for i=1:nbdir

         rep = [deblank(rep_COMPLET(i,:)) '/'];
         
         suff = '_DEPH.nc';
         
         mask = sprintf('%s%s', '*', suff);
         filtre = sprintf('%s%1c%s', rep,  mask);
         ff=dir(filtre);

         for ix=1:length(ff) 
            if ~ff(ix).isdir
                files_rep=char(files_rep,[rep ff(ix).name]);
            end
         end
   end

   fic_MLT_COMPLET       = sortrows(files_rep);
   [nbfic_MLT_COMPLET,~] = size(fic_MLT_COMPLET);



% -------------------------------
% boucle sur les fichiers Netcdf
% -------------------------------

 if nbfic_MLT_COMPLET > 0

   for i =  2:nbfic_MLT_COMPLET
      fic_nc = deblank(fic_MLT_COMPLET(i,:))
      nc = netcdf.open(deblank(fic_MLT_COMPLET(i,:)),'NOWRITE');
      if strcmp(fic_nc,'A16N_13_PRES.nc')
          start_date_complet      = strvcat(start_date_complet,ncreadatt(fic_nc,'/','Start_date'))
      end
      
      data_type_complet       = strvcat(data_type_complet,ncreadatt(fic_nc,'/','Data_type'));
      cruise = ncread(fic_nc,'CRUISE_NAME')';

      project_complet         = strvcat(project_complet,cruise(1,:));
      
      start_date_complet      = strvcat(start_date_complet,ncreadatt(fic_nc,'/','Start_date'));
      stop_date_complet       = strvcat(stop_date_complet,ncreadatt(fic_nc,'/','Stop_date'));
      
      south_lat_complet (i)   = ncreadatt(fic_nc,'/','South_latitude');
      north_lat_complet (i)   = ncreadatt(fic_nc,'/','North_latitude');
          
      west_lon_complet (i)    = ncreadatt(fic_nc,'/','West_longitude');
      east_lon_complet(i)     = ncreadatt(fic_nc,'/','East_longitude');
      
       lat_deb_don = ncread(fic_nc,'LATITUDE_BEGIN');
       [nprof,~] = size(lat_deb_don);
       
       latdeb_complet (i,1:nprof)      = ncread(fic_nc,'LATITUDE_BEGIN');
       londeb_complet (i,1:nprof)      = ncread(fic_nc,'LONGITUDE_BEGIN');

      netcdf.close(nc);
   end

   else
        a='erreur'
 end

clear ff1 ff2 mask a nbdir 

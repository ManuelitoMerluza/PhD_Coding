%-----------------------------------------------------------------------------------
%  Projet ARCHIVAGE HYDROLOGIE
%  ---------------------------
%  Version: 1.0
%  ------------
%  Creation : Juillet 2005 /  T.Loaëc          
%-----------------------------------------------------------------------------------
%  Programme de traitement BASE DE DONNEES ARCHIVAGE HYDROLOGIE : inventaire
%-----------------------------------------------------------------------------------
%
% Repris par C. Lagadec (novembre 2005)
%
%=====================================================

global_rep;
init_rep;

global nocletri indtri;

fic_inventcamp = 'wk_resu/inventaire_hydro_C.lst';

% le fichier Inventaire Campagne existe : maj possible      (accueilmaj)
%                       il n'existe pas : creation possible (accueilnew)

if exist(fic_inventcamp,'file')
         indtrait = inventaire_faccueilmaj;

% modification possible du fichier Inventaire Campagne 
% invent_camp.mat sous wk_resu
% ----------------------------------------------------

         if  indtrait ~= 1
             indtrait2 = inventaire_fmodifcamp;
         end
     else
         indtrait = inventaire_faccueilnew;
         indtrait2 = 0;
end

if    (indtrait ~= 1 & indtrait2 ~= 1)

% initialisation pour lecture fichiers netcdf
%--------------------------------------------

      ncstartup

% recuperation du nombre de campagnes traitees
% a partir du fichier Matlab (taille de la zone fic_nc)
% -----------------------------------------------------

      nomfic_mat = 'wk_resu/invent_camp.mat';
      nomvar_mat = 'fic_nc';
      command = sprintf('%s%s%s%s','load -mat ',nomfic_mat, ' ', nomvar_mat);
      eval(command);

      [nbcamp, zz] = size(fic_nc);

      [invs_nocamp, invs_ficnc, invs_camp, ...
       invs_station_number, invs_indsta, invs_lat, ...
       invs_long, invs_date, invs_juld, invs_maxdepth,invs_bottom, nbcamp] = inventaire_extract_S;

%=====================================================
% Extraction des données Station
%=====================================================

 
        indtri = 0;

        inventaire_ftri(nbcamp);

        while indtri ~= 1        
           inventaire_liste_S(invs_nocamp, invs_ficnc, invs_camp, ...
                              invs_station_number, invs_indsta, invs_lat, ...
                              invs_long, invs_date, invs_juld, invs_maxdepth, invs_bottom, nbcamp);
           inventaire_ftri(nbcamp);
        end
                 

end;

clear all




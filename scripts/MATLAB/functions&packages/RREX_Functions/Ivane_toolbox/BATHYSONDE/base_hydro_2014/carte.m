%-----------------------------------------------------------------------------------
%  Projet ARCHIVAGE HYDROLOGIE
%  ---------------------------
%  Version: 1.0
%  ------------
%  Creation : Avril 2007 /  T.Loaëc
%  (inspire de base_hydro et visual_tout)
%                                            
%-----------------------------------------------------------------------------------
%  Programme de traitement BASE DE DONNEES ARCHIVAGE HYDROLOGIE : obtenir cartes
%	carte avec toutes les stations 
%	carte avec uniquement les stations en doubles
%-----------------------------------------------------------------------------------

%=====================================================

% mise a nul des variables matlab
%----------------------------------
clear all;
close all;

parameters;

global_rep;
global zones_select;

init_rep_dbl;


% initialisation pour lecture fichiers netcdf
%--------------------------------------------

ncstartup



% constitution du tableau des campagnes avec positions et dates
% -------------------------------------------------------------

[rep_COMPLET, fic_MLT_COMPLET, nbfic_MLT_COMPLET, ...
 data_type_complet, project_complet,  ... 
 start_date_complet, stop_date_complet, ...
 south_lat_complet,  north_lat_complet, ...
 west_lon_complet,  east_lon_complet, ...
 latdeb_complet, londeb_complet, flag_dbl_complet]     = lect_base_complet_dbl;


%=====================================================
% Menu principal
%=====================================================

k_mlt = 0;
k_mlt_max = 6;

while(k_mlt~= k_mlt_max);
   k_mlt = menu('CARTE DE DONNEES HYDROLOGIQUES ', ...
                    'Extraction d''une partie de la base', ...
                    'Liste des donnees extraites', ...
		    'Visualisations des donnees extraites', ...
		    'Visualisations des stations en double', ...
                    'Aide', ...
                    'Fin');

   close all;

   switch k_mlt

  case 1
%=====================================================
% Lecture du fichier table pour initialisations
% dans le cas de l'extraction d'une partie de 
% la base de donnees
%=====================================================
      imess_lect=[]; % incremente de 1 a chaque etape pour continuer

       dialog    = 'Zones de l''ocean';
       pathname  = rep_MLT_NC;
       zones_select = [];
       zones_select= strvcat(zones_select,rep_MLT_NC);
       [files_nc, nbfic_nc] = hydro_sel_camp_dbl;

       fic_MLT_NC = files_nc;
       [nbfic_mlt,b]  = size(fic_MLT_NC);


     
       if   isempty(imess_lect)

%=====================================================
% Extraction des profils sur zone  
% selon la demande de l'utilisateur
%=====================================================

           extract_dbl;
           imess_lect=1;
      end

      k_mlt = 0;
      k_mlt_max = 6;

  case 2
%=====================================================
% Ouverture du fichier .lst sous wk_resu/
%=====================================================
      if ~isempty(imess_lect)
       liste;
      else
       h=warndlg('Extraction non executee','Attention');
      end;

  case 3
%=====================================================
% Visualisation des données extraites (toutes les stations)
%=====================================================
      if ~isempty(imess_lect)
       visual_tout_dbl;
      else
       h=warndlg('Extraction non executee','Attention');
      end;

  case 4
%=====================================================
%Visualisation carte des stations en double des données extraites
%=====================================================
      if ~isempty(imess_lect)
       visual_dbl;
      else
       h=warndlg('Extraction non executee','Attention');
      end;

  case 5
%=====================================================
% aide en detail
%=====================================================
    aide_carte(1);   

    end;
    		

end;


             clear all;
             close all;
      

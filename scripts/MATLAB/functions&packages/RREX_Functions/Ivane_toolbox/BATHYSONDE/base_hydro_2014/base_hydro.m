%-----------------------------------------------------------------------------------
%  Projet ARCHIVAGE HYDROLOGIE
%  ---------------------------
%  Version: 1.0
%  ------------
%  Creation : Fevrier 2003 /  C.Lagadec
%  (inspire de base_gyro)
%                                            
%-----------------------------------------------------------------------------------
%  Programme principal traitement BASE DE DONNEES ARCHIVAGE HYDROLOGIE
%-----------------------------------------------------------------------------------

%=====================================================

% mise a nul des variables matlab
%----------------------------------
clear all;
close all;

parameters;

global_rep;

dialog1 = 'Base de donnees Hydrologie LPO';
carteHydrocean = '/home/lpo5/BASES_ANNUELLES/CARTES/Hydrocean.png';

rep_MLT_NC=init_rep;

% constitution du tableau des campagnes avec positions et dates
% -------------------------------------------------------------

[rep_COMPLET, fic_MLT_COMPLET, nbfic_MLT_COMPLET, ...
data_type_complet, project_complet, ... 
 start_date_complet, stop_date_complet, ...
 south_lat_complet,  north_lat_complet, ...
 west_lon_complet,  east_lon_complet, ...
 latdeb_complet, londeb_complet]     = lect_base_complet;


%=====================================================
% Menu principal
%=====================================================

k_mlt = 0;
k_mlt_max = 7;

while(k_mlt~= k_mlt_max);
   k_mlt = menu(dialog1, ...
                    'Visualisation de toute la base', ...
                    'Extraction d''une partie de la base', ...
                    'Creation d''un fichier Multistation', ...
                    'Liste des donnees extraites', ...
		            'Visualisations des donnees extraites',...
                    'Informations sur Hydrocean', ...
                    'Fin');

   close all;

   switch k_mlt


  case 1
%=====================================================
% Visualisation de toute la base
%=====================================================


carte = input('Nouvelle carte de stations (o/n) ?  ', 's');
if strcmp(carte,'n')

    eval (['!\display ' carteHydrocean]);

else     

       visual_tout(rep_COMPLET, fic_MLT_COMPLET, ...
                   nbfic_MLT_COMPLET, ...
                   latdeb_complet,londeb_complet);
end

  case 2
%=====================================================
% Lecture du fichier table pour initialisations
% dans le cas de l'extraction d'une partie de 
% la base de donnees
%=====================================================
       imess_lect=[]; % incremente de 1 a chaque etape pour continuer

       pathname  = rep_MLT_NC;

      [files_nc, nbfic_nc] = hydro_sel_rep(pathname);

       fic_MLT_NC = files_nc;
       [nbfic_mlt,b]  = size(fic_MLT_NC);
     
       if   isempty(imess_lect)

%=====================================================
% Extraction des profils sur zone  
% selon la demande de l'utilisateur
%=====================================================

           extract;
           imess_lect=1;
      end

      k_mlt = 0;
      k_mlt_max = 7;

  case 3
%=====================================================
% Creation du fichier Multistation Netcdf
% imesslect mis a 2
%=====================================================
      if ~isempty(imess_lect)
       hydro_creat_netcdf;
       imess_lect = 2;
      else
       h=warndlg('Extraction non executee','Attention');
      end;

  case 4
%=====================================================
% Ouverture du fichier .lst sous wk_resu/
%=====================================================
      if ~isempty(imess_lect)
       liste;
      else
       h=warndlg('Extraction non executee','Attention');
      end;

  case 5
%=====================================================
% Plot de controles
%=====================================================
      if ~isempty(imess_lect)
       visual;
      else
       h=warndlg('Extraction non executee','Attention');
      end;

  case 6
%=====================================================
% aide en detail
%=====================================================
    aide_hydro(1);   

    end;
  

end;

   if imess_lect ~= 2
        button = questdlg('Vous n''avez pas cree de fichier Multistation. Desirez-vous le faire ?', ...,
 'Message', 'Oui', 'Non', 'Non');
 
        if strcmp(button, 'Oui')
             hydro_creat_netcdf;
        end;
   end;
   
   
clear all;
close all;

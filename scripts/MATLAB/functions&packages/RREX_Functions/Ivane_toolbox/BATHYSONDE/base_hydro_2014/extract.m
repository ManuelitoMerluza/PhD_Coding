%---------------------------------------------------------------------
%  Projet ATLANTIQUE NORD
%  ----------------------
%  Version: 1.0
%  ------------
%                                            
%---------------------------------------------------------------------
%  Recherche des paramètres demandés par l'utilisateur (choix_param)
%  et recherche des profils intéressants (hyd_lec_mlt)
%---------------------------------------------------------------------

%=====================================================

global_rep;

parameters;

%=====================================================
% 1 - interface utilisateur
%=====================================================

      choix_param(start_date_complet, stop_date_complet);

      lat_don_ok = [lat_extract_min;lat_extract_max];
      lon_don_ok = [lon_extract_min;lon_extract_max];


      
%=====================================================
% 2 - recherche des profils intéressants :
%     si aucune station comprise entre les dates
%     ou aucun mois selectionne
%=====================================================

if (size(jul_extract_min) == [0,0] & size(mois_extract) == [0,0])

    break;

else
    
%===============================================================================
% 3-  commence l'extraction et finira par la création du fichier Netcdf résultat
%===============================================================================

    hyd_lec_mlt(rep_MLT_NC, nbfic_mlt, fic_MLT_NC, ...
                    lat_don_ok, lon_don_ok, ...
                    imm_extract_min, imm_extract_max);  
end;

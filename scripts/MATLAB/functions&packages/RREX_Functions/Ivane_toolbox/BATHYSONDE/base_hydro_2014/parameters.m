%-----------------------------------------------------------------------------------
%  Projet POMME
%  -----------------
%  Version: 1.0
%  ------------
%  Creation : Octobre 2001 /  C.Grit
%  Modification : Juin 2002
%                                            
%-----------------------------------------------------------------------------
%  Declaration en variables globales des parametres 
%  choisis par l'utilisateur pour l'extraction
%-----------------------------------------------------------------------------

%=====================================================

global imess_lect;

% proposition des choix pour l'utilisateur
%-----------------------------------------

global list_day;
global list_month;
global list_year;

% type de base : HYDROCEAN ou Bases ANNUELLES
% -------------------------------------------

global trait_base;

% dates d'extraction des donnees
% --------------------------------
global first_day;
global first_month;
global first_year;

global last_day;
global last_month;
global last_year;

global jul_extract_min;
global jul_extract_max;
global dates_extract;
global dates_deb;
global dates_fin;

global mois_extract;


%zone geographique retenue pour l'extraction
%-------------------------------------------

global lat_extract_min;
global lat_extract_max;
global lon_extract_min;
global lon_extract_max;


% immersions min et max retenues pour l'extraction
%------------------------------------------------
global imm_extract_min;
global imm_extract_max;

% liste des parametres retenus pour l'extraction
%-----------------------------------------------
global param_extract;
global nb_par_extract


% nombre de stations retenues
%----------------------------
global nb_stat_extract;

% nombre de niveaux retenus
%--------------------------
global nb_niv_extract;


% pour le defile des figures pdt l'extraction
%---------------------------------------------
global ipause;
global icontrole;


% tableaux des parametres retenus apres extraction
% ------------------------------------------------
global TPOT_sta;
global SIG0_sta SIG1_sta SIG2_sta 
global SIG3_sta SIG4_sta SIG5_sta ;
global SIG6_sta SIGI_sta SI15_sta;
global BRV2_sta VORP_sta TEMP_sta;
global DYNH_sta SSDG_sta OXYL_sta OXYK_sta;
global GAMM_sta;
global PRES_sta;
global PSAL_sta;
global DEPH_sta;
global prec_var_sta;
global flag_dbl_sta;

% variables des stations retenues et reecrites dans le fichier Netcdf
% -------------------------------------------------------------------

%nom des fichiers Netcdf
global fic_nc_sta;
%Nom de l'organisme responsable des donnees         
global data_processing_sta;
global camp_sta latdeb_sta londeb_sta datedeb_sta datefin_sta;
global latfin_sta lonfin_sta;
global juldeb_sta julfin_sta pi_sta pi_org_sta navire_sta direction_sta;    
global inst_reference_sta codwmo_sta sondes_sta  pmax_sta  prefmax_sta;        
global station_number_sta date_ref;
global flag_dbl_sta;

% pour la visualisation
%-----------------------
global icarte iprofil;
global param;


global list_param;




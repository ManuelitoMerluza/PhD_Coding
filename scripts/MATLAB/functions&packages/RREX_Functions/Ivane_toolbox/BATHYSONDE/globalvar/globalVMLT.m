			
	    % -------------------------------------------%
	    % Variables globales concernant les fichiers %
	    % -------------------------------------------%

% Matrices des codes et des labels des parametres de reference autorises
% par defaut
% -----------------------------------------------------------------------

global CODES_AUT_DEF LABELS_AUT_DEF ;

% valeurs minimale et maximale de tous les parametres de reference autorises
% --------------------------------------------------------------------------

global VMINTOT VMAXTOT ;


% Matrice des codes et des labels des parametres de reference autorises 
% presents dans tous les fichiers
% ----------------------------------------------------------------------

global CODES_AFFICHES LABELS_AFFICHES ;

% Matrices des valeurs minimales et maximales des parametres de
% reference autorises presents dans tous les fichiers
% --------------------------------------------------------------

global VMIN_AFFICHES VMAX_AFFICHES ;

% code du parametre de reference choisi par l'utilisateur parmi la 
% liste des autorises
% --------------------------------------------------------

global CODE_REF ;

% valeurs minimale et maximale du parametre de reference choisi par
% l'utilisateur 
% -------------------------------------------------------------------

global VALMIN VALMAX ;

% Pas d'echantillonnage du parametre de reference choisi par l'utilisateur
% -------------------------------------------------------------------------

global ECHANT_REF ;

% nombre de niveaux
% ------------------

global NB_NIV ;

% flag qui permet de connaître la presence d'un parametre de reference 
% autorise dans tous les fichiers
% -----------------------------------------------------------------------

global FLAG_AUT ;

% noms des zones edit qui representent les caracteristiques (code, valmin
% valmax, pas d'echantillonnage) du parametre de reference choisi 
% par l'utilisateur (cf. param_ref_mlt.m)
% -------------------------------------------------------------------------

global h_CODE h_VMIN h_VMAX h_ECHANT ;
	
% noms des zones edit qui representent les caracteristiques (code, valmin
% valmax, pas d'echantillonnage) du parametre de reference choisi 
% par l'utilisateur (cf. param_ref_choisi.m)
% -------------------------------------------------------------------------

global PAR_AUTO VMIN_AUTO VMAX_AUTO ;

% variables qui repesentent les caracteristiques (code, valmin, valmax, 
% pas d'echantillonnage) du parametre de reference choisi par 
% l'utilisateur et qui servent à la mise-à-jour des fenêtres
% param_ref_mlt et recap_mlt
% -----------------------------------------------------------------------

global paramcod ;
global parammin ;
global parammax ;
global ECHANT_AUTO ;

% codes des parametres physiques choisis
% ---------------------------------------

global CODES_PARAMP_CHOISI ;

% nombre de parametres physiques choisis par l'utilisateur
% ---------------------------------------------------------

global NB_PARAMP_CHOISI ;


% nom du fichier mlt cree
% ce nom est par defaut le nom de la campagne choisie mais peut être modifie
% par l'utilisateur
% --------------------------------------------------------------------------

global NOM_FIC_DEF ;


% grille 
% --------

global GRILLE ;
global MLT;

% ajout nov 2014 (CL)
% test de presence de l'attribut global COMMENT_CALIB dans les fichiers clc
% -------------------------------------------------------------------------
global COMMENT_CLC



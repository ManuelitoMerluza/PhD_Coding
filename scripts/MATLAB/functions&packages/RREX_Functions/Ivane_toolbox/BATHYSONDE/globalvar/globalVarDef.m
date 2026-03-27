
% --------------------------------------------
%  variables globales des options par defaut
% --------------------------------------------


% Nom du programme
% ----------------

global NOMPROG;


% Nom du fichier Options par defaut
% ---------------------------------

global  NOMFIC_SAV ;

% grille intermediaire
% --------------------

global P_INT;


% grille finale 
% -------------

global P_FINAL;


% paramètres de complémentation
% ============================= 

 global PASINT_DEF;          % pas de la grille intermédiaire


 global PMININT_DEF;         % pression mini grille intermédiaire


 global PMAXINT_DEF;         % pression maxi grille intermédiaire


% complémentation de surface
% --------------------------


 global TROUSURF_DEF;        % taille maxi du trou complété 



 global HAUTSURF_DEF;        % hauteur



% complémentation de milieu de profil
% -----------------------------------



 global TROUMIL_DEF;         % taille maxi du trou complété 



 global MODINT_DEF;          % mode d'interpolation
 

% paramètres de décimation
% ======================== 

global DECIM_DEF             % égal à 0 si grille finale = grille interm.
                             % égal à 1 si  decimation


global PASDECIM_DEF;         % pas de decimation (multiple du pas de la 
                             % grille intermediaire 



% paramètres de lissage
% =====================


global TYPLISS_DEF;              % type de lissage par parametre


global C_LARG_DEF;           % largeur par defaut pour lissage creneau


global L_LARG_DEF;           % largeur par defaut pour lissage lanczos

global L_FREQ_DEF;           % frequence par defaut pour lissage lanczos 


global B_PERIOD_DEF;         % periode de coupure pour lissage Butterworth

global B_ORDR_DEF            % ordre pour lissage Butterworth


% parametres d'affichage du lissage choisi
% ========================================

global P1_DEF;  

global P2_DEF;
  

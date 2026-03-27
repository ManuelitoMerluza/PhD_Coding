
globalVarEtiquni;

globalVarDef;

globalajo;

CODES_CALC=['TPOT';'SIGI';'DEPH';'ZCOO';'IMMR';'DYNH';'FBRV';'BRV2';'VSON';'SSDG';'VORP';'GAMM';'SIG0';'SIG1';'SIG2';'SIG3';'SIG4';'SIG5';'SIG6';'SI15'];


LABELS_CALC=['TEMPERATURE POTENTIELLE ';
             'ANOMALIE DENSITE IN SITU';
             'COORDONNEE Z (positive) ';
             'COORDONNEE Z (negative) ';
             'IMMERSION               ';
             'HAUTEUR DYNAMIQUE       ';
             'FREQ. BRUNT-VAISALA     ';
             'FREQ. BRUNT-VAIS.(CARRE)';
             'VIT. DU SON (CHEN)      ';
             'VIT. DU SON (DEL GROSSO)';
             'VORTICITE POTENTIELLE   ';
             'GAMMA                   ';
             'SIGMA (PRESSION 0 )     ';
             'SIGMA (PRESSION 1000)   ';
             'SIGMA (PRESSION 2000)   ';
             'SIGMA (PRESSION 3000)   ';
             'SIGMA (PRESSION 4000)   ';
             'SIGMA (PRESSION 5000)   ';
             'SIGMA (PRESSION 6000)   ';
             'SIGMA (PRESSION 1500)   '];

[NBPARCALC,b] = size(CODES_CALC);

% options de lissage : valeurs valables quand pas de la grille finale = 1
% ------------------

C_LARG_DEF = 5;

L_LARG_DEF = 25;
L_FREQ_DEF = 0.04;

B_ORDR_DEF = 2;
B_PERIOD_DEF = 5;

AJO.nomfic = '';
ECR.nomfic = '';

% initialisation du nombre de parametres calcules
% pour ecriture dans fichier .ajo si l'utilisateur le desire

ECR.nbpar = 0;

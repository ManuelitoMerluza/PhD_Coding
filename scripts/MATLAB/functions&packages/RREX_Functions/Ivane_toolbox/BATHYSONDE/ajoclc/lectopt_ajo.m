function lectopt_ajo()

% lecture du fichier des options par défaut de CRECLC
% ---------------------------------------------------


globalVarEtiquni;

globalVarDef;



% options de lissage : valeurs valables quand pas de la grille finale = 1
% ------------------


TYPLISS_DEF(1:4,1:11) = ' ';       
TYPLISS_DEF = char(TYPLISS_DEF);

C_LARG_DEF = 5;

L_LARG_DEF = 25;
L_FREQ_DEF = 0.04;

B_ORDR_DEF = 2;
B_PERIOD_DEF = 5;



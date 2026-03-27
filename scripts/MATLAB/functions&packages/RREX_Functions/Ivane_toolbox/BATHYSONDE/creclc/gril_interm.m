function gril_interm ();

% variables globales etiquette unistation
globalVarEtiquni;

% variables globales fichier options par defaut
globalVarDef;


% creation de la grille intermediaire
% -----------------------------------

  PMAXINT_DEF = PMAXTOT;

  P_INT = PMININT_DEF:PASINT_DEF:PMAXINT_DEF;

  P_FINAL = PMININT_DEF:PASDECIM_DEF:PMAXINT_DEF;

  if  PASDECIM_DEF > 1
        DECIM_DEF = 1;
  end;


clear current;


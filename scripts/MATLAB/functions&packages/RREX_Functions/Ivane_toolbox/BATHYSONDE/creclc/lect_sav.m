function iretour = lect_sav(ficsav);


%
%-------------------------------------------
%
% Lecture du fichier   Options (dans creclc) 
%
%-------------------------------------------
%
% ficsav    : nom du fichier Options a charger

iretour = 0;

globalVarDef;

     command = sprintf('%s%s%s','load ', ficsav,  ' -mat  P_INT P_FINAL PASINT_DEF  PMININT_DEF PMAXINT_DEF TROUSURF_DEF HAUTSURF_DEF TROUMIL_DEF MODINT_DEF DECIM_DEF PASDECIM_DEF TYPLISS_DEF C_LARG_DEF  L_LARG_DEF  L_FREQ_DEF B_PERIOD_DEF B_ORDR_DEF P1_DEF P2_DEF');
     try
 	     eval(command);
             iretour = 0;
     catch
   	     msgerr = sprintf('%s %s %s', 'Erreur lors du chargement des options de sauvegarde du fichier: ', ficsav);
	     h=errordlg(msgerr,'Erreur','on');
	     waitfor(h);
             iretour = 1;


     end;

  
  
  

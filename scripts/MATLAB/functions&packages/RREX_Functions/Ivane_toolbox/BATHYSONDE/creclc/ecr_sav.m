function iretour = ecr_sav(ficsav);


%
%------------------------------------------
%
% Ecriture du fichier   Options
%
% C.Lagadec : Nov 98- Creation
%
%-------------------------------------------
                    


% Paramètres en entrée 
% ~~~~~~~~~~~~~~~~~~~~
% ficsav   : nom du fichier Options à sauver

iretour = 0;

globalVarEtiquni;

globalVarDef;

     command = sprintf('%s%s%s','save ', ficsav,  ' -mat   P_INT P_FINAL PASINT_DEF  PMININT_DEF PMAXINT_DEF TROUSURF_DEF HAUTSURF_DEF TROUMIL_DEF MODINT_DEF DECIM_DEF PASDECIM_DEF TYPLISS_DEF C_LARG_DEF L_LARG_DEF  L_FREQ_DEF B_PERIOD_DEF B_ORDR_DEF  P1_DEF P2_DEF')
     try
	     eval(command);
         iretour = 0
     catch
   	     msgerr = sprintf('%s %s %s', 'Erreur lors de la sauvegarde du fichier Options : ', ficsav);
	     h=errordlg(msgerr,'Erreur','on');
	     waitfor(h);
         iretour = 1
     end;




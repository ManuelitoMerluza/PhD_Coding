function lectopt()

% lecture du fichier des options par d�faut de CRECLC
% ---------------------------------------------------


globalVarEtiquni;

globalVarDef;


% options de compl�mentation
% --------------------------

HAUTSURF_DEF = 0.;
TROUSURF_DEF = 10.;
TROUMIL_DEF  = 10.;
PASINT_DEF   = 1.;

PMININT_DEF = [];
PMAXINT_DEF = [];


% valeurs mode interpolation : s(spline) ou m(lineaire)

MODINT_DEF  = 'Lin�aire';


% options de d�cimation
% ---------------------

% DECIM_DEF = 0 : pas de decimation
% DECIM_DEF = 1 : decimation

DECIM_DEF = 0;

PASDECIM_DEF = 1.;


% options de lissage : valeurs valables quand pas de la grille finale = 1
% ------------------

TYPLISS_DEF(1:4,1:11) = ' '; 
TYPLISS_DEF = char(TYPLISS_DEF);

C_LARG_DEF = 5;

L_LARG_DEF = 25;
L_FREQ_DEF = 0.04;

B_ORDR_DEF = 2;
B_PERIOD_DEF = 5;

P1_DEF(1,5) = zeros;
P2_DEF(1,5) = zeros;

ficsav = 'creclc_def.sav';

command = sprintf('%s%s%s', 'save ', ficsav, ' -mat P_INT P_FINAL PASINT_DEF  PMININT_DEF PMAXINT_DEF TROUSURF_DEF HAUTSURF_DEF TROUMIL_DEF MODINT_DEF DECIM_DEF PASDECIM_DEF TYPLISS_DEF C_LARG_DEF L_LARG_DEF L_FREQ_DEF B_PERIOD_DEF B_ORDR_DEF P1_DEF P2_DEF');



try
	eval(command);
catch
   	msgerr = sprintf('%s %s %s', 'Erreur lors de la creation du fichier options par defaut de CRECLC: ', ficsav);
	h=errordlg(msgerr,'Erreur','on');
	waitfor(h);
end;



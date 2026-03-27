function selectechant()

globalVarEtiquni;
global CHOIX;

global h_ProfMin;
global h_ProfMax;
global h_PasEchant;

CHOIX.pmintot = str2num(get(h_ProfMin, 'String'));
CHOIX.pmaxtot = str2num(get(h_ProfMax, 'String'));
CHOIX.echant  = str2num(get(h_PasEchant, 'String'));

if CHOIX.pmintot < PMINTOT
	   CHOIX.pmintot = PMINTOT;
end;

if CHOIX.pmaxtot > PMAXTOT
	   CHOIX.pmaxtot = PMAXTOT;	
end;

if CHOIX.echant < 1
	   CHOIX.echant = 1;
end;

close;


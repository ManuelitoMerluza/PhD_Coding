function MenuQuitter()
%
%%%%%%%%%%%%%%%%%%%%
%
% Fin d'utilisation
%
% C.B. 21/05/97
%
%%%%%%%%%%%%%%%%%%%%
%

% Question fin ?
Rep=questdlg('Voulez-vous vraiment quitter','','     Oui     ','     Non     ','    Non     ');
  
% Traitement de la reponse
if Rep == '     Oui     ',
	     close all,
	     clear all;
end;

% Et voila c'est fini ...
	

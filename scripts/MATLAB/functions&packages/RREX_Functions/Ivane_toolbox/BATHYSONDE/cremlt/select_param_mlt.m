 function [ierr] = select_param_mlt()

%---------------------------------------------------------
%						        
% fonction qui permet a  l'utilisateur de selectionner   
% les parametres physiques  qu'il                       
% veut voir apparaitre dans son fichier multistation    
%						        
%---------------------------------------------------------

globalVarASCI ;
globalVarEtiquni ;
globalajo ;
globalVMLT;

global val ;

global h_CODESPARAMPC ;
global h_ListLabP ;
global h_ListLabPC ;

ierr = 0;


for kk=1:NPARP_TOT
     if   strcmp(CODPARP_TOT (kk, :),CODE_REF)
            ivalref = kk;
     end
end


val = get(gcbo,'Value') ;
if val >= ivalref
    val=val+1;
end

% ajout de parametres physiques
% -----------------------------

if PRESENCP_TOT(val) == '*'
		h = warndlg(['Impossible de creer un fichier Multistation avec des parametres  n''existant pas dans tous les fichiers Unistation. ' val],'Attention') ;
	waitfor(h) ;
        ierr = 1;
	return ;
end ;

set(h_ListLabP,'Value',val) ;

test2 = 0 ;

if NB_PARAMP_CHOISI > 0
	for j = 1:NB_PARAMP_CHOISI

% parametres physiques
% ---------------------
	   test = strcmp(CODPARP_TOT(val,:), CODES_PARAMP_CHOISI(j,:)); 


	   if test == 1
		 test2 = 1 ;	% attention, il existe deja ...
	   end ;

	end ;

	if test2 == 0	% attention, il n'a pas encore ete selectionne ...


% parametres physiques
% ---------------------
	  NB_PARAMP_CHOISI = NB_PARAMP_CHOISI + 1; 
	  CODES_PARAMP_CHOISI(NB_PARAMP_CHOISI,:) = CODPARP_TOT(val,:) ;
	  CODES_PARAMP_CHOISI = char (CODES_PARAMP_CHOISI) ;
	  set(h_CODESPARAMPC,'string',CODES_PARAMP_CHOISI) ;
		
	
	end ;


else

% ce ELSE s'execute lorsque l'on n'a encore rien selectionne et que l'on effectue donc
% le premier choix de parametre physique.
% ------------------------------------------------------------------------------------

% parametres physiques
% --------------------

	NB_PARAMP_CHOISI = NB_PARAMP_CHOISI + 1 ;
	CODES_PARAMP_CHOISI(NB_PARAMP_CHOISI,:) = CODPARP_TOT(val,:) ;
	set(h_CODESPARAMPC,'String',CODES_PARAMP_CHOISI) ;

end ;

if NB_PARAMP_CHOISI > 0
	set(h_CODESPARAMPC,'Value',1) ;
else
	set(h_CODESPARAMPC,'Value',0) ;
end ;

set(h_ListLabPC,'Value',1) ;

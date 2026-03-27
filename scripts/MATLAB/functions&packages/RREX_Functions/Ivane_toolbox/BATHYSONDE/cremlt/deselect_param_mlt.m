function deselect_param_mlt()

%-------------------------------------------------------
% fonction qui permet, en cas d'erreur de déselectionner
% un(ou des) paramètre(s) physiques                     
%-------------------------------------------------------

globalVarASCI ;

global h_CODESPARAMPC ;
global h_ListLabPC ;

val = get(gcbo, 'Value') ;


if NB_PARAMP_CHOISI > 1
	set (h_ListLabPC,'Value',1) ;
   else
	set (h_ListLabPC,'Value',0) ;
end ;

CODES_PARAMP_CHOISI (val,:) = '' ;
NB_PARAMP_CHOISI = NB_PARAMP_CHOISI - 1 ; 
set (h_CODESPARAMPC,'String',CODES_PARAMP_CHOISI) ;


if NB_PARAMP_CHOISI > 0
	set (h_CODESPARAMPC,'Value',1) ;
  else
 	set (h_CODESPARAMPC,'Value',0) ;
end ;

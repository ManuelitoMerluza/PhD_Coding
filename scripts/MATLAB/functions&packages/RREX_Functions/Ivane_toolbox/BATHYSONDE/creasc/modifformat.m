function modifformat()

%Cette fonction permet de tester la validite du nouveau format rentre

clear nouv_form;

globalVarEtiquni;
global COD CHOIX valc;
global h_FormatsAModifier;
global h_ListFormats;

nouv_form = get(h_FormatsAModifier,'string');

lf = length(nouv_form);


if nouv_form(lf:lf) ~= 'f' & nouv_form(lf:lf) ~= 'e'
	warndlg('Ce format n''est pas valable, il faut un f ou un e en derniere position','ATTENTION');
    
elseif lf == 4 
	nouv_form = [nouv_form ' '];
	CHOIX.format(valc,:) = nouv_form;
	set(h_ListFormats,'string',CHOIX.format);
	
elseif lf == 5 

	CHOIX.format(valc,:) = nouv_form;
	set(h_ListFormats,'string',CHOIX.format);

else

	warndlg('Ce n''est pas un type de format valable','ATTENTION');	

end;

	clear lf;

	set(h_FormatsAModifier,'String',[]);

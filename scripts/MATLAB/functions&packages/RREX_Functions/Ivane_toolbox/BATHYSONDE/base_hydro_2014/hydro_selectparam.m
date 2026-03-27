function hydro_selectparam;


parameters;

global valc;
global h_PPC h_ListLabP;

valc = get(gcbo, 'Value');

nb = nb_par_extract;
set(h_ListLabP,'Value',valc);


test2 = 0;

if nb > 0

	for j=1:nb
	
	test = strcmp(list_param(valc,:), param_extract(j,:));

	    if test == 1

		test2 = 1;
% warndlg('il existe deja','attention');

 	    end;   %fin du if test == 1

	end;   	% fin du for j=1:nb

	    if test2 == 0 

% il n'a pas encore ete selectionne
			
 			nb_par_extract = nb_par_extract + 1;

			param_extract(nb_par_extract,:) =  list_param(valc,:);

			param_extract = char (param_extract);

			set(h_PPC,'String',param_extract);


%fin du if test == 0
	   end; 		 

else 
 
% ce else s'execute lorsque on a encore rien selectionne et qu'on
% effectue  donc le premier choix de parametre  


    nb_par_extract = nb_par_extract + 1

    param_extract(nb_par_extract,:) =  list_param(valc,:);

    param_extract = char (param_extract);

    set(h_PPC,'String',param_extract);

end

	

if nb_par_extract > 0

	set(h_PPC,'Value',1);

elseif nb_par_extract == 0
	
	set(h_PPC,'Value',0);
end;

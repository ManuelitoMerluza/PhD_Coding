function de_selectparam(type)

global CHOIX;
globalVarEtiquni;

global h_PPC;
global h_PCC; 
global h_ListLabPC;
global h_ListLabCC;

valc = get(gcbo, 'Value');



%----------------------------------------------------
% cette partie du if s'execute si on deselectionne un	
% Parametre physique					
%-------------------------------------------------------

if type == 1 

	if  CHOIX.nbparp > 1
		set(h_ListLabPC,'Value',1);
	else
		set(h_ListLabPC,'Value',0);
	end;

	%CODES
    
	CHOIX.codp (valc,:) = '' ;
	CHOIX.nbparp = CHOIX.nbparp - 1;
	set(h_PPC,'String',CHOIX.codp);

	% FORMATS

        if ~isempty(CHOIX.format)
            CHOIX.format(valc,:) = '';
        end;

% "deselection" d'un Parametre chimique				    

elseif type == 2 

	if  CHOIX.nbparc > 1
		set(h_ListLabCC,'Value',1);
	else
		set(h_ListLabCC,'Value',0);
	end;

	% CODES	

	CHOIX.codc (valc,:) = '' ;
	CHOIX.nbparc = CHOIX.nbparc - 1;
	set(h_PCC,'String',CHOIX.codc);


	% FORMATS

    if ~isempty(CHOIX.format)
         CHOIX.format(valc,:) = '';
    end;

end;

if CHOIX.nbparc > 0

	set(h_PCC,'Value',1);
else	
        set(h_PCC,'Value',0);
end;

if CHOIX.nbparp > 0

	set(h_PPC,'Value',1);
else
	set(h_PPC,'Value',0);
end;


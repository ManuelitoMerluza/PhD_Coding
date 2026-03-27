
function selectparam(type)

globalVarEtiquni;

global CHOIX valc;
global h_PPC;
global h_PCC;
global h_ListLabP;
global h_ListLabC;
global h_ListLabPC;
global h_ListLabCC;

valc = get(gcbo, 'Value');


if type == 1   % ajoute parametre physique

	nb = CHOIX.nbparp;
	set(h_ListLabP,'Value',valc);

elseif type == 2  % ajoute parametre chimique

	nb = CHOIX.nbparc;
	set(h_ListLabC,'Value',valc);

end;

test2 = 0;

if nb > 0

	for j=1:nb
	
		if type ==1   %  parametre physique
			test = strcmp(ETIQ.codes_paramp(valc,:), CHOIX.codp(j,:));
		elseif type == 2  %  parametre chimique
			test = strcmp(ETIQ.codes_paramc(valc,:), CHOIX.codc(j,:));
		end;	

		if test == 1

			test2 = 1;
% warndlg('il existe deja','attention');

 		end;   %fin du if test == 1

	end;   	% fin du for j=1:nb

		if test2 == 0 

% warndlg('il n a pas encore ete selectionne','attention');			
		   if type ==1   %  parametre physique
               
 			CHOIX.nbparp = CHOIX.nbparp + 1;
			CHOIX.codp(CHOIX.nbparp,:) =  ETIQ.codes_paramp(valc,:); 
            CHOIX.codp=char(CHOIX.codp); 
			set(h_PPC,'String',CHOIX.codp);

		   elseif type == 2  %  parametre chimique

			CHOIX.nbparc = CHOIX.nbparc + 1;			
			CHOIX.codc(CHOIX.nbparc,:) =  ETIQ.codes_paramc(valc,:);
            CHOIX.codc = char(CHOIX.codc);
			set(h_PCC,'String',CHOIX.codc);

	
		   end;
%fin du if test == 0
		end; 		 

else  
% ce else s''execute lorsque on a encore rien selectionne et qu''on
% effectue  donc le premier choix de parametre physique ou chimique
% warndlg('le premier selectionne','attention');

%  parametre physique

if type ==1   
 	CHOIX.nbparp = CHOIX.nbparp + 1;

% Partie CODES

	CHOIX.codp(CHOIX.nbparp,:) =  ETIQ.codes_paramp(valc,:);
    CHOIX.codp = char(CHOIX.codp);
	set(h_PPC,'String',CHOIX.codp);


%  parametre chimique
elseif type == 2 

	CHOIX.nbparc = CHOIX.nbparc + 1;

% Partie CODES

	CHOIX.codc(CHOIX.nbparc,:) =  ETIQ.codes_paramc(valc,:);
    CHOIX.codc = char(CHOIX.codc);
	set(h_PCC,'String',CHOIX.codc);



end;  		%fin du if
end;
	
if CHOIX.nbparc > 0

	set(h_PCC,'Value',1);


elseif CHOIX.nbparc == 0
	
	set(h_PCC,'Value',0);
end;

if CHOIX.nbparp > 0

	set(h_PPC,'Value',1);

elseif CHOIX.nbparp == 0
	
	set(h_PPC,'Value',0);
end;


	set(h_ListLabPC,'Value',1);
	set(h_ListLabCC,'Value',1);

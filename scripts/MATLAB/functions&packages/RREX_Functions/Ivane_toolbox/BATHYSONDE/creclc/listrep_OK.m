%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%	listrep_Ok
%
% callback OK de la fenetre de choix des stations dans le repertoire de donnees
%
% Ecrit a partir du source 'lisstr_CBOk' de C.Fontaine - Atlantide
%
%  Dec. 98
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function listrep_Ok();

globalVarEtiquni;

cptr = 0;

NOM_FILES = [];
hfsel = findobj(gcbf, 'Tag', 'list_fsels');
hsuff = findobj(gcbf, 'Tag', 'pup_suff');
str=get(hfsel,'String');

% test validite repertoire donnees et service
% -------------------------------------------
	nbf = 0;
	if (~isempty(str))
		NBFILES = length(str(:,1));
	end
	repf = [];
	if (NBFILES > 0)
		for i = 1 : NBFILES
			NOM_FILES(i,:) =  str(i,:);
		end

		NOM_FILES = char(NOM_FILES);
                NOM_FILES = deblank(NOM_FILES);

	end


	

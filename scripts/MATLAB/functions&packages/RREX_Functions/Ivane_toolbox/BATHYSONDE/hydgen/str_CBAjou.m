%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%	str_CBAjou
%
% callback bouton ajouter de la fenetre de choix des stations dans le repertoire de donnees
%
% C.Fontaine - Atlantide
%
% le 23/2/98
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function str_CBAjou()

 
msgerr = '';
hfsel = findobj(gcbf, 'Tag', 'list_fsels');
hfpres = findobj(gcbf, 'Tag', 'list_fics');
str2aj=get(hfpres,'String');
val2aj=get(hfpres,'Value');
f2aj = [];
if (~isempty(str2aj) & ~isempty(val2aj))
	f2aj = str2aj(val2aj,:);
end
fsel = [];
fsel = get(hfsel, 'String');
if (~isempty(f2aj))
	i=length(f2aj(:,1));
	while (i > 0)
		nom = f2aj(i,:);
		ind = strmatch(nom, fsel, 'exact');
		if (~isempty(ind))
			f2aj(i,:) = [];
		end
		i = i-1;
	end
	fsel = strvcat(fsel,f2aj);
	fsel=sortrows(fsel);
	set(hfsel, 'String',fsel);
	set(hfsel, 'Value',1);
	set(hfsel, 'Max',length(fsel(:,1)));
end 


	

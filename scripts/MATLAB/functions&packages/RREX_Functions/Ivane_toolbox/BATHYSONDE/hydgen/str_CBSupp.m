%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%	str_CBSupp
%
% callback bouton Supprimer de la fenetre de choix des stations dans le repertoire de donnees
%
% C.Fontaine - Atlantide
%
% le 23/2/98
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function str_CBSupp()

 
msgerr = '';
fsel = [];
hfsel = findobj(gcbf, 'Tag', 'list_fsels');
fsel=get(hfsel,'String');
val2sup=get(hfsel,'Value');
if (~isempty(fsel) & ~isempty(val2sup))
	ind = length(val2sup);
	while (ind > 0)
		i2sup = val2sup(ind);
		fsel(i2sup,:) = [];
		ind = ind-1;
	end
end
if (~isempty(fsel))	
	fsel=sortrows(fsel);
	nbf = length(fsel(:,1));
else
	nbf = 0;
end

set(hfsel, 'Max', nbf);
set(hfsel, 'String',fsel);
if (nbf < 1)
	val = 0;
else
	val = 1;
end
set(hfsel, 'Value',val);



get(hfsel);






	

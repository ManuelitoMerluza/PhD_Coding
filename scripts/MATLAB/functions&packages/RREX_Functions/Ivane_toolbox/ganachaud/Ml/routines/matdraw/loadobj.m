function h = loadobj(command,handles);
% LOADOBJ Restores a saved object
% loadobj(command,handles) recreates an object
% stored with saveobj.
% 
% See Also:  saveobj
%
% Keith Rogers  2/95

% Mods:

% Copyright (c) 1995 by Keith Rogers
for(i=1:size(handles,1))
	eval([get(handles(i,1),'UserData') '= get(handles(i,2),''UserData'');']);
end
eval(['h = ' command]);

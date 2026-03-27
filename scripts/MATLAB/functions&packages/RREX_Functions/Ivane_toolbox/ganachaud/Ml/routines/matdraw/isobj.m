function boolean  = isobj(handle,object)
% ISOBJ	True for objects
% ISOBJ(HANDLE) returns 1's where the elements of HANDLE are valid handles
% and 0's where they are not.
% ISOBJ(HANDLE,OBJECT) narrows the search to children of OBJECT.
%
%	Keith Rogers 4/95


% Mods: 
% 4/27/95  Modified to cope with multiple handles.

% Copyright (c) 1995 by Keith Rogers

if(length(handle)==1)
	if(nargin > 1)
		boolean = any(handle == findobj(object));
	else
		boolean = any(handle == findobj);
	end
else
	boolean = handle;
	[rows,cols] = size(handle);
	handle = handle(:)';
	if(nargin > 1)
		objs = findobj(object);
	else
		objs = findobj;
	end
	if(length(objs == 1))
		objs = objs([1;1]);
	end
	boolean(:) = any(handle(ones(length(objs),1),:) == objs(:,ones(1,length(handle))));
end




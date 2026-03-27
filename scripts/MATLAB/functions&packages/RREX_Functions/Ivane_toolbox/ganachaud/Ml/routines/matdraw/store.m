function dataObjs = store(fig,numObjs,tag)
%STORE create storage space for user data 
%DATAOBJS = STORE(NUMOBJS) Creates NUMOBJS invisible 
%pushbutton UIControls and returns their handles.
%The objects may then be used for their UserData. By 
%default, the objects will be created in the current 
%figure.  Use  STORE(FIG,NUMOBJS) to store in a 
%different figure, and STORE(NUMOBJS,TAG) or 
%STORE(FIG,NUMOBJS,TAG) to attach a tag to the
%storage items.
%
% 	Keith Rogers 11/94

% Mods:
%
% 01/29/95: Store in UIControls instead of text objects
%           and allow storage in other figures.
% 05/11/95: Added tag argument.
%
% Copyright (c) by Keith Rogers 1995

if(nargin == 2)
	if(isstr(numObjs))
		tag = numObjs;
		numobjs = fig;
	else
		tag = '';
	end
end
if(nargin < 2) 
	numObjs = fig;
	fig = gcf;
	tag = '';
end
dataObjs=zeros(numObjs,1);
for i=1:numObjs 
	dataObjs(i)=uicontrol(fig,'Position',[0 0 1 1],'visible','off','Tag',tag);
end

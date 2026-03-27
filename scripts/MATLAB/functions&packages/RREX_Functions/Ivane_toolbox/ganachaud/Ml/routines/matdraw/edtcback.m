function edtcback(command)

% EDTCBACK Callback for Edit Menu
% Function edtcback(prop)
% This is a callback function, and should not be
% called directly!
%
% Keith Rogers  1/95

% Mods:

%Copyright (c) 1995 by Keith Rogers

pfig = findfig('Draw Tools');
datObjs = get(pfig,'UserData');

if(command == 1)
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% UNDO:
%
% datObjs(8) holds an Nx3 matrix of objects, where
% N is the number of Undo actions to be taken. The
% first column holds the effected objects.  The 
% second column holds objects which contain the 
% effected properties in their UserData.  Here 
% the course of action can be indicated for cases 
% where the action to be undone was not a property.
% The third column contains objects which have in 
% their User Data the original values of the properties
% stored in the second column's objects.
%
% datObjs(9) is a secondary clipboard for undoing
% actions which affected the primary clipboard.
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	UndoList = get(datObjs(8),'UserData');
	prop = get(UndoList(1,2),'UserData');

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% UNDELETE and REPASTE
	% 1.  Unselect everything
	% 2.  Load Objects from UndoClipboard
	% 3.  Add them to the selectList
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	if(strcmp(prop,'Undelete') | strcmp(prop,'RePaste'))
		if(strcmp(prop,'Undelete'))
			clip = 9;
		else
			clip = 10;
		end
		UClip = get(datObjs(clip),'UserData');
		selectList = get(datObjs(3),'UserData');
		for(i=1:size(selectList,1))
			set(selectList(i,1),'Selected','off');
			type = get(selectList(i,1),'type');
			if(strcmp(type,'line'))
				set(selectList(i,1),'Color',selectList(i,2:4));
			elseif(strcmp(type,'patch'))
				set(selectList(i,1),'EdgeColor',selectList(i,2:4));
			end
		end
		selectList = zeros(size(UndoList,1),4);
		i = 1;
		command = get(UClip(1,1),'UserData');
		moreItems = size(UClip,1) + 1 - size(UndoList,1);
		if(moreItems > 0)
			UndoList  = [UndoList;[zeros(moreItems,1) ...
			reshape(store(pfig,2*moreItems),moreItems,2)]];
		end
		while(isstr(command))
			obj = loadobj(command,get(UClip(i,2),'UserData'));
			UndoList(i,1) = obj;
			if(clip == 9)
				set(UndoList(i,2),'UserData','ReDelete');
			else
				set(UndoList(i,2),'UserData','UnPaste');
			end
			type = get(obj,'Type');
			if(strcmp(get(obj,'Selected'),'on'))
				if(strcmp(type,'line'))
					selectList(i,:) = [obj get(UClip(i,3),'UserData')];
				elseif(strcmp(type,'patch'))
					selectList(i,:) = [obj get(UClip(i,3),'UserData')];
				else
					selectList(i,:) = [obj 0 0 0];
				end
			end
			i = i+1;
			command = get(UClip(i,1),'UserData');
		end
		set(UndoList(i,2),'UserData',-1);
		selectList = selectList(i-1,:);
		set(datObjs(8),'UserData',UndoList);
		set(datObjs(3),'UserData',selectList);

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% REDELETE  and UNPASTE
	% 1.  For each object in UndoList
	%     a.  If it's selected, remove it from the selectList
	%     b.  Delete it.
	%     c.  (For Undoing Pastes) Copy Clipboard
	%         to Undo Clipboard
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	elseif(strcmp(prop,'ReDelete') | strcmp(prop,'UnPaste'))
		i = 1;
		if(strcmp(prop,'UnPaste'))
			set(UndoList(1,2),'UserData','RePaste');
		else
			set(UndoList(1,2),'UserData','Undelete');
		end
		while(isstr(prop))
			if(any(UndoList(i,1) == selectList))
				selectList = selectList(find(selectList(:,1)~=UndoList(i,1)));
			end
			delete(UndoList(i,1));
			i = i+1;
			prop = get(UndoList(i,2),'UserData');
		end
		set(datObjs(8),'UserData',UndoList);
		set(datObjs(3),'UserData',selectList);
		
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% UNCUT
	% 1.  Move Clipboard to UndoClipboard
	% 2.  Move UndoClipboard to Clipboard
	% 3.  Unselect everything
	% 4.  Load Objects from UndoClipboard
	% 5.  Add them to the selectList
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	elseif(strcmp(prop,'UnCut'))
		UClip = get(datObjs(10),'UserData');
		set(datObjs(10),'UserData',get(datObjs(9),'UserData'));
		set(datObjs(9),'UserData',UClip);
		selectList = get(datObjs(3),'UserData');
		for(i=1:size(selectList,1))
			set(selectList(i,1),'Selected','off');
			type = get(selectList(i,1),'type');
			if(strcmp(type,'line'))
				set(selectList(i,1),'Color',selectList(i,2:4));
			elseif(strcmp(type,'patch'))
				set(selectList(i,1),'EdgeColor',selectList(i,2:4));
			end
		end
		selectList = zeros(size(UndoList,1),4);
		i = 1;
		command = get(UClip(1,1),'UserData');
		moreItems = size(UClip,1) + 1 - size(UndoList,1);
		if(moreItems > 0)
			UndoList  = [UndoList;[zeros(moreItems,1) ...
			reshape(store(pfig,2*moreItems),moreItems,2)]];
		end
		while(isstr(command))
			obj = loadobj(command,get(UClip(i,2),'UserData'));
			UndoList(i,1) = obj;
			set(UndoList(i,2),'UserData','ReCut');
			if(strcmp(type,'line'))
				selectList(i,:) = [obj get(UClip(i,3),'UserData')];
			elseif(strcmp(type,'patch'))
				selectList(i,:) = [obj get(UClip(i,3),'UserData')];
			else
				selectList(i,:) = [obj 0 0 0];
			end
			i = i+1;
			command = get(UClip(i,1),'UserData');
		end
		set(UndoList(i,2),'UserData',-1);
		selectList = selectList(i-1,:);
		set(datObjs(8),'UserData',UndoList);
		set(datObjs(3),'UserData',selectList);
		
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% RECUT
	% 1.  Move Clipboard to UndoClipboard
	% 2.  Move UndoClipboard to Clipboard
	% 3.  For each object in UndoList
	%     a.  If it's selected, remove it from the selectList
	%     b.  Delete it.
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	elseif(strcmp(prop,'ReCut'))
		clipboard = get(datObjs(9),'UserData');
		set(datObjs(9),'UserData',get(datObjs(10),'UserData'));
		set(datObjs(10),'UserData',clipboard);
		i = 1;
		set(UndoList(1,2),'UserData','UnCut');
		while(isstr(prop))
			if(any(UndoList(i,1) == selectList))
				selectList = selectList(find(selectList(:,1)~=UndoList(i,1)));
			end
			delete(UndoList(i,1));
			i = i+1;
			prop = get(UndoList(i,2),'UserData');
		end
		set(datObjs(8),'UserData',UndoList);
		set(datObjs(3),'UserData',selectList);

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%
	% If the property is 'Delete' then the object was
	% just created, and undoing it just means deleting
	% it. First, though, we have to copy the object 
	% into the undo clipboard. Also remember that
	% since we are undoing the creation of an object,
	% there is only one item to delete, so no loop
	% is necessary.
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	elseif(strcmp(prop,'Delete'))
		selectList = get(datObjs(3),'UserData');
		UClip = get(datObjs(9),'UserData');
		if(any(UndoList(1,1) == selectList))
			set(UClip(1,3),'UserData',selectList(find(UndoList(1,1)==selectList),2:4));
			set(datObjs(3),selectList(find(UndoList~=selectList),:));
		end
		[prop,handles] = saveobj(UndoList(1,1),pfig);
		set(UClip(1,1),'UserData',prop);
		set(UClip(1,2),'UserData',handles);
		delete(UndoList(1,1));
		set(UndoList(1,2),'UserData','Undelete');
		set(datObjs(8),'UserData',UndoList);
		set(datObjs(9),'UserData',UClip);

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%  Otherwise, just go through the list and undo 
	%  stuff. 
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	else
		i = 1;
		prop = get(UndoList(1,2),'UserData');
		while(isstr(prop))
			val = get(UndoList(i,3),'UserData');
			curval = get(UndoList(i,1),prop);
			set(UndoList(i,1),prop,val);
			set(UndoList(i,3),'UserData',curval);
			i = i+1;
			prop = get(UndoList(i,2),'UserData');
		end
		set(datObjs(8),'UserData',UndoList);
	end
elseif(command == 2)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CUT:
%  1: Set first Property in UndoList to "UnCut"
%  2: Copy clipboard to undo clipboard
%  3: Copy undo clipboard to clipboard
%  4: For each selected item:
%     a)  save it
%     b)  store the command and objects in clipboard
%     d)  delete it
%  5: Terminate the clipboard
%  6: Erase selectList and store UndoList and
%     clipboard
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	UndoList = get(datObjs(8),'UserData');
	set(UndoList(1,2),'UserData','UnCut');	
	set(UndoList(2,2),'UserData',-1);
	clipboard = get(datObjs(9),'UserData');
	set(datObjs(9),'UserData',get(datObjs(10),'UserData'));
	selectList = get(datObjs(3),'UserData');
	
	moreItems = size(selectList,1) + 1 - size(clipboard,1);
	if(moreItems > 0)
		clipboard  = [clipboard;reshape(store(pfig,3*moreItems),moreItems,3)];
	end
	for(i=1:size(selectList,1))
		[command,objs] = saveobj(selectList(i,1),pfig);
		set(clipboard(i,1),'UserData',command);
		set(clipboard(i,2),'UserData',objs);
		set(clipboard(i,3),'UserData',selectList(i,2:4));
		delete(selectList(i,1));
	end
	set(clipboard(i+1,1),'UserData',-1);
	
	set(datObjs(3),'UserData',[]);
	set(datObjs(8),'UserData',UndoList);
	set(datObjs(10),'UserData',clipboard);

elseif(command == 3)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% COPY:
%  1: Move clipboard to undo clipboard
%  2: Save selected objects to clipboard
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	selectList = get(datObjs(3),'UserData');
	UndoList = get(datObjs(8),'UserData');
	set(UndoList(1,2),'UserData','Uncopy');
	set(UndoList(2,2),'UserData',-1);
	clipboard = get(datObjs(9),'UserData');
	set(datObjs(9),'UserData',get(datObjs(10),'UserData'));
	moreItems = size(selectList,1) + 1 - size(clipboard,1);
	if(moreItems > 0)
		clipboard  = [clipboard;reshape(store(pfig,3*moreItems),moreItems,3)];
	end
	for(i=1:size(selectList,1))
		[command,objs] = saveobj(selectList(i,1),pfig);
		set(clipboard(i,1),'UserData',command);
		set(clipboard(i,2),'UserData',objs);
		set(clipboard(i,3),'UserData',selectList(i,2:4));
	end
	set(clipboard(i+1,1),'UserData',-1);
	set(datObjs(8),'UserData',UndoList);
	set(datObjs(10),'UserData',clipboard);

elseif(command == 4)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PASTE:
% 1: Load objects in clipboard.
% 2: Deselect currently selected objects
% 3: Select objects that have been loaded.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	selectList = get(datObjs(3),'UserData');
	UndoList = get(datObjs(8),'UserData');
	clipboard = get(datObjs(10),'UserData');
	for(i=1:size(selectList,1))
		set(selectList(i,1),'Selected','off');
		type = get(selectList(i,1),'type');
		if(strcmp(type,'line'))
			set(selectList(i,1),'Color',selectList(i,2:4));
		elseif(strcmp(type,'patch'))
			set(selectList(i,1),'EdgeColor',selectList(i,2:4));
		end
	end
	selectList = zeros(size(clipboard,1),4);
	moreItems = size(clipboard,1) + 1 - size(UndoList,1);
	if(moreItems > 0)
		UndoList  = [UndoList;zeros(moreItems,1) ...
							  reshape(store(pfig,2*moreItems),moreItems,2)];
	end
	i = 1;
	command = get(clipboard(1,1),'UserData');
	while(isstr(command))
		selectList(i,1) = loadobj(command,get(clipboard(i,2),'UserData'));
		selectList(i,2:4) = get(clipboard(i,3),'UserData');
		UndoList(i,1) = selectList(i,1);
		set(UndoList(i,2),'UserData','ReDelete');
		i = i+1;
		command = get(clipboard(i,1),'UserData');
	end
	set(UndoList(i,2),'UserData',-1);
	selectList = selectList(1:i-1,:);
	set(datObjs(3),'UserData',selectList);
	set(datObjs(8),'UserData',UndoList);

elseif(command == 5)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Delete:
%  1: Set first Property in UndoList to "Undelete" and
%     then terminate it.
%  2: For each selected item:
%     a)  save it
%     b)  store the command and objects in undoclipboard
%     d)  delete it
%  3: Terminate the undo clipboard
%  6: Erase selectList and store UndoList and
%     undo clipboard
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	UndoList = get(datObjs(8),'UserData');	
	set(UndoList(1,2),'UserData','Undelete');
	set(UndoList(2,2),'UserData',-1);
	UClip = get(datObjs(9),'UserData');
	selectList = get(datObjs(3),'UserData');
	
	moreItems = size(selectList,1) + 1 - size(UClip,1);
	if(moreItems > 0)
		UClip  = [UClip;reshape(store(pfig,3*moreItems),moreItems,3)];
	end
	for(i=1:size(selectList,1))
		[command,objs] = saveobj(selectList(i,1),pfig);
		set(UClip(i,1),'UserData',command);
		set(UClip(i,2),'UserData',objs);
		set(UClip(i,3),'UserData',selectList(i,2:4));
		delete(selectList(i,1));
	end
	set(UClip(i+1,1),'UserData',-1);
	
	set(datObjs(3),'UserData',[]);
	set(datObjs(8),'UserData',UndoList);
	set(datObjs(9),'UserData',UClip);
end

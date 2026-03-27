%  This callback routine has to be an m-file, not a function
%  because it modifies the workspace.  We know which function to
%  execute by examining the label of the current menu item.
%
% Keith Rogers 11/93
% Mods:
%     12/02/94  Shorten name to appease DOS users,
%               Change "makemenus" to "matdraw"

SavedFile = get(get(gcm,'Parent'),'UserData');

if (strcmp(get(gcm,'Label'),'Load'))
	[filename,pathname] = uigetfile('*.mat',...
	'Choose a MATLAB Data file',50,50);
	if (filename ~= 0)
		SavedFile = [pathname filename];
		clear filename pathname;
		eval(['load ' SavedFile ';']);
		set(get(gcm,'Parent'),'UserData',SavedFile);
	end
elseif (strcmp(get(gcm,'Label'),'Save'))
	if (strcmp(SavedFile,''))
		[filename,pathname] = uiputfile('*.mat','Data Filename',...
			50,50);
		if (filename ~= 0)
			SavedFile = [pathname filename];
			clear filename pathname;
			eval(['save ' SavedFile ';']);
			set(get(gcm,'Parent'),'UserData',SavedFile);
		end
	else
		eval(['save ' SavedFile ';']);
	end
elseif (strcmp(get(gcm,'Label'),'Save As'))
	if (strcmp(SavedFile,''))
		[filename,pathname] = uiputfile('*.mat','Data Filename',...
			50,50);
	else
		[filename,pathname] = uiputfile(SavedFile,'Data Filename',...
			50,50);
	end
	if (filename ~= 0)
		SavedFile = [pathname filename];
		clear filename pathname;
		eval(['save ' SavedFile ';']);
		set(get(gcm,'Parent'),'UserData',SavedFile);
	end
elseif (strcmp(get(gcm,'Label'),'New Figure'))
	figure;
	matdraw;
elseif (strcmp(get(gcm,'Label'),'Add to Path'))
    [MDpathfile,MDpathpath] = uigetfile('*','Select a file in the directory which you wish to add.');
    path(path,MDpathpath(1:length(MDpathpath)-1));
	 clear MDpathfile MDpathpath;
end


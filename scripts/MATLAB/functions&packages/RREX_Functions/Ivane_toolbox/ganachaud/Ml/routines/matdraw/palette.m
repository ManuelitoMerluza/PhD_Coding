function pfig = palette(toolList,paletteName,callback,numberOfDataItems)
%
% function pfig = palette(toolList,paletteName,callback,numberOfDataItems)
% Creates a palette figure.
% toolList     is a string of single character symbols, each of
%              which will become a palette item.
% paletteName  is the name that the palette figure will be
%              given.
% callback     is the function where processing of user
%              actions involving the palette will take
%              place.  When the user selects a palette item,
%              a command of the form <callback>(switch)
%              is generated, where <callback> is the string
%              specified here and "switch" will contain the
%              character label of the item selected.
% numberofDataItems    This must be at least 2.  It
%              specifies the number of storage spaces to
%              create for the developer's use.
%
%	Keith Rogers 11/94

%Mods:
%
%  01/19/95:  Turn off 'Resize', and 'NumberTitle' properties

%Copyright (c) 1995 by Keith Rogers 

numberOfTools = length(toolList);
	   
% Create the Palette figure

if(nargin == 4)
	pfig = figure('Position',[50 350 30 30*numberOfTools],...
				  'Color',[1 1 1],...
				  'NextPlot','new',...
				  'Resize','off',...
				  'NumberTitle','off',...
				  'Name',paletteName);
					  
% Create Data Storage Space for the Palette
% datObjs(1): matrix of handles of patches and text  
% 			 objects for the tools in the palette
% datObjs(2): Currently selected tool
%
% Initialize other data objects in callback

	if(numberOfDataItems < 2)
		error('Palette requires at least 2 data items!')
	else
		datObjs = store(numberOfDataItems);
		set(pfig,'UserData',datObjs);
		set(datObjs(2),'UserData',0);
	end
	
	% Create the Palette axes
	
	pax = axes('Position',[.05 .05 .9 .9],'Visible','off');
%	axes(pax);
	
	ptool = zeros(1,numberOfTools);
	ptext = zeros(1,numberOfTools);
	dy = 1/numberOfTools;
	yrange = 0:dy:1-dy;
	for(i=1:length(yrange))
		ptool(i) = patch('XData',[0 1 1 0 0],...
		                 'YData',yrange(i)+[0 0 dy dy 0],...
						 'ZData',-ones(1,5),...
						 'FaceColor',[1 1 1],...
						 'EdgeColor',[0 0 0],...
						 'ButtonDownFcn',['palette(1,''' callback ''')']);
		ptext(i) = text('Position',[.5 yrange(i)+dy/2],...
		                'HorizontalAlignment','center',...
						'VerticalAlignment','middle',...
						'String',toolList(i),...
						'Color','k',...
						'ButtonDownFcn',['palette(1,''' callback ''')']);
	end
	set(datObjs(1),'UserData',[ptool; ptext]);
	eval(callback);
else
	callback = paletteName;
	datObjs = get(gcf,'UserData');
	PData = get(datObjs(1),'UserData');
	tool = get(datObjs(2),'UserData');
	selectedTool = fix((find(gco == PData)-1)/2)+1;
	if(tool ~= 0)
		set(PData(1,tool),'FaceColor',[1 1 1]);
		set(PData(2,tool),'Color','k');
	end
	if(tool == selectedTool)
		selectedTool = '';	
		set(datObjs(2),'UserData',0);
	else
		set(PData(1,selectedTool),'FaceColor',[0 0 0]);
		set(PData(2,selectedTool),'Color','w');
		set(datObjs(2),'UserData',selectedTool);
		selectedTool = get(PData(2,selectedTool),'String');
	end
	eval([callback '(selectedTool)']);
end

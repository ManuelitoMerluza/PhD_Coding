function dmencback(command,option)
% DMENCBACK Callback for Draw Menu
% Function dmencback(command,option)
% This is a callback function, and should not be
% called directly!
%
% Keith Rogers  11/94

% Mods:
%     12/02/94 Shortened name to appease DOS users
%     12/5/94  Adapted to deal with single palette for all
%              figures,changed name to lower case to
%              appease VMS users.
%     12/14/94 Add Delete item callback
%     12/15/94 Fixed bugs.
%     12/20/94 When deleting an object, delete its 
%              SelectLine as well.
%     12/28/94 Add support for UISetcolor or Other
%              colors using the input function for
%              those not on Macs or PC's.
%              Also fixed things so if we undo the
%              creation of an object after selecting
%              it we reset the SelectedObject
%      01/5/95 Change from using "input" to "prmptdlg"
%
% Copyright (c) 1995 by Keith Rogers

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	Commands
%
%  1:	Set LineStyle of selected object to OPTION
%  2:	Set LineWidth of selected object to OPTION;
%       if 0, get LineWidth from Prompter Dialog box
%  3:   Set Pen Color of selected object to OPTION;
%       "Other" brings up a color picker on Mac and PC	
%  4:   Set Fill Color of selected object to OPTION;
%       "Other" brings up a color picker on Mac and PC	
%  5:	Undo last change (disabled if undo not possible)
%  6:	Delete selected object	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

pfig = findfig('Draw Tools');
datObjs = get(pfig,'UserData');
UndoList = get(datObjs(8),'UserData');
SelectList = get(datObjs(3),'UserData');
numObjs = size(SelectList,1)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Line Style Menu
%  
%  Option is a line style
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if(command == 1)

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Set Defaults if no object selected
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	if(numObjs == 0)
		Defaults = get(datObjs(5),'UserData');
		menu = get(gcf,'CurrentMenu');
		Mom = get(menu,'Parent');
		set(get(Mom,'UserData'),'Checked','off');
		set(Mom,'UserData',gcm);
		set(menu,'Checked','on');
		set(Defaults(7),'UserData',option);
		set(datObjs(5),'UserData',Defaults);

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Main Stuff:
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	elseif(numObjs == 1)	
		if(strcmp(get(SelectList(1),'Type'),'line'))
			UndoList(1,1) = SelectList(1);
			set(UndoList(1,2),'UserData','LineStyle');
			set(UndoList(1,3),'UserData',get(SelectList(1),'LineStyle'));
			set(UndoList(2,2),'UserData',-1);
			set(SelectList(1),'LineStyle',option);
		end
	else
		moreItems = numObjs + 1 - size(UndoList,1);
		if(moreitems > 0)
			UndoList  = [UndoList; zeros(moreItems,1) ...
			reshape(store(pfig,2*moreItems),moreItems,2)];
		end
		j = 1;
		for(i=1:numObjs)
			if(strcmp(get(SelectList(i,1),'Type'),'line'))
				UndoList(j,1) = SelectList(i,1);
				set(UndoList(j,2),'UserData','LineStyle');
				set(UndoList(j,3),'UserData',get(SelectList(i,1),'LineStyle'));
				set(SelectList(i,1),'LineStyle',option);
				j = j+1;
			end
		end
		set(UndoList(j,2),'UserData',-1);
	end
	set(datObjs(8),'UserData',UndoList);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Line Width Menu
%  
%  Option is either a number 
%  (width in points) or 0 for
%  'Other'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

elseif(command == 2)

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Deal with 'Other' Menu Item
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	if(option==0)
		option = str2num(prmptdlg('Line Width?','.5'));
	end

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Set Defaults if no object selected
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	if(numObjs == 0)
		Defaults = get(datObjs(5),'UserData');
		menu = get(gcf,'CurrentMenu');
		Mom = get(menu,'Parent');
		set(get(Mom,'UserData'),'Checked','off');
		set(Mom,'UserData',gcm);
		set(menu,'Checked','on');
		set(Defaults(8),'UserData',option);
		if(~isempty(findstr(get(menu,'Label'),'Other')))
			set(menu,'Label',['Other (' num2str(option) ')']);
		end
		set(datObjs(5),'UserData',Defaults);

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Main Stuff:
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	elseif(numObjs == 1)	
			type = get(SelectList(1),'Type');
			if(strcmp(type,'line') | strcmp(type,'patch'))
				UndoList(1,1) = SelectList(1);
				set(UndoList(1,2),'UserData','LineWidth');
				set(UndoList(1,3),'UserData',get(SelectList(1),'LineWidth'));
				set(UndoList(2,2),'UserData',-1);
				set(SelectList(1),'LineWidth',option);
			end
	else
		moreItems = numObjs + 1 - size(UndoList,1);
		if(moreItems > 0)
			UndoList  = [UndoList; zeros(moreItems,1) ...
			reshape(store(pfig,2*moreItems),moreItems,2)];
		end
		j = 1;
		for(i=1:numObjs)
			type = get(SelectList(1),'Type');
			if(strcmp(type,'line') | strcmp(type,'patch'))
				UndoList(j,1) = SelectList(i,1);
				set(UndoList(j,2),'UserData','LineWidth');
				set(UndoList(j,3),'UserData',get(SelectList(i,1),'LineWidth'));
				set(SelectList(i,1),'LineStyle',option);
				j = j+1;
			end
		end
		set(UndoList(j,2),'UserData',-1);
	end
	set(datObjs(8),'UserData',UndoList);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Pen Color Menu
%  
%  Option is one of
%    RGB Triple
%    'Other'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

elseif(command == 3)

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Deal with 'Other' Menu Item
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	if(strcmp(option,'Other'))
		if(strcmp(computer,'MAC2') | strcmp(computer,'PCWIN'))
			option = uisetcolor('Set Pen Color');
			if(option == 0) 
				return; 
			end
		else
			option = str2num(prmptdlg('Color Spec?  (Must be 1x3 vector)  '));
			if(~all(size(option)==[1 3]))
				error('Color spec must be of the form [R G B]');
			end
		end
	end

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Set Defaults if no object selected
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	if(numObjs == 0)
		Defaults = get(datObjs(5),'UserData');
		menu = get(gcf,'CurrentMenu');
		Mom = get(menu,'Parent');
		set(get(Mom,'UserData'),'Checked','off');
		set(Mom,'UserData',gcm);
		set(menu,'Checked','on');
		set(Defaults(9),'UserData',option);
		if(~isempty(findstr(get(menu,'Label'),'Other')))
			set(menu,'Label',['Other (' num2str(option) ')']);
		end
		set(datObjs(5),'UserData',Defaults);

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Main Stuff:
	% 
	% Behavior is different for lines,
	% patches, and text. What a pain! 
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	elseif(numObjs == 1)	
		UndoList(1,1) = SelectList(1);
		type = get(SelectList(1),'Type');
		if(strcmp(type,'line'))
			set(UndoList(1,2),'UserData','Color');
			set(UndoList(1,3),'UserData',SelectList(2:4));
			set(SelectList(1),'Color',option,'Selected','off');
			set(datObjs(3),'UserData',[]);
		elseif(strcmp(type,'text'))
			set(UndoList(1,2),'UserData','Color');
			set(UndoList(1,3),'UserData',get(SelectList(1),'Color'));
			set(SelectList(1),'Color',option);
		elseif(strcmp(type,'patch'))
			set(UndoList(1,2),'UserData','EdgeColor');
			set(UndoList(1,3),'UserData',SelectList(2:4));
			set(SelectList(1),'EdgeColor',option,'Selected','off');
			set(datObjs(3),'UserData',[]);
		end
		set(UndoList(2,2),'UserData',-1);
	else
		moreItems = numObjs + 1 - size(UndoList,1);
		if(moreItems > 0)
			UndoList  = [UndoList; zeros(moreItems,1) ...
			reshape(store(pfig,2*moreItems),moreItems,2)];
		end
		j = 1; i = 1;
		while(i <= size(SelectList,1))
			type = get(SelectList(i,1),'Type');
			if(strcmp(type,'line')) 
			   UndoList(j,1) = SelectList(i,1);
				set(UndoList(j,2),'UserData','Color');
				set(UndoList(j,3),'UserData',SelectList(i,2:4));
				set(SelectList(i,1),'Color',option,'Selected','off');
				SelectList = SelectList(find(SelectList(:,1)~=SelectList(i,1)),:);
				j = j+1;
			elseif(strcmp(type,'text'))
			   UndoList(j,1) = SelectList(i,1);
				set(UndoList(j,2),'UserData','Color');
				set(UndoList(j,3),'UserData',get(SelectList(i,1),'Color'));
				set(SelectList(i,1),'Color',option);
				i = i+1;
				j = j+1;
			elseif(strcmp(type,'patch'))
			   UndoList(j,1) = SelectList(i,1);
				set(UndoList(j,2),'UserData','EdgeColor');
				set(UndoList(j,3),'UserData',SelectList(i,2:4));
				set(SelectList(i,1),'EdgeColor',option,'Selected','off');
				SelectList = SelectList(find(SelectList(:,1)~=SelectList(i,1)),:);
				j = j+1;
			else
				i = i+1;
			end
		end
		set(datObjs(3),'UserData',SelectList);
		set(UndoList(j,2),'UserData',-1);
	end
	set(datObjs(8),'UserData',UndoList);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Fill Color Menu
%  
%  Option is one of
%    RGB Triple
%    'None'
%    'Other'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

elseif(command == 4)

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Deal with 'Other' Menu Item
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	if(strcmp(option,'Other'))
		if(strcmp(computer,'MAC2') | strcmp(computer,'PCWIN'))
			option = uisetcolor('Set Fill Color');
			if(option == 0) 
				return; 
			end
		else
			option = str2num(prmptdlg('Color Spec?  (Must be 1x3 vector)  '));
			if(~all(size(option)==[1 3]))
				error('Color spec must be of the form [R G B]');
			end
		end
	end

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Set Defaults if no object selected
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	if(numObjs == 0)
		Defaults = get(datObjs(5),'UserData');
		menu = get(gcf,'CurrentMenu');
		Mom = get(menu,'Parent');
		set(get(Mom,'UserData'),'Checked','off');
		set(Mom,'UserData',gcm);
		set(menu,'Checked','on');
		set(Defaults(10),'UserData',option);
		if(~isempty(findstr(get(menu,'Label'),'Other')))
			set(menu,'Label',['Other (' num2str(option) ')']);
		end
		set(datObjs(5),'UserData',Defaults);

	%%%%%%%%%%%%%%%
	% Main Stuff
	%%%%%%%%%%%%%%%
	
	elseif(numObjs == 1)	
		if(strcmp(get(SelectList(1,1),'type'),'patch'))
			UndoList(1,1) = SelectList(1);
			set(UndoList(1,2),'UserData','FaceColor');
			set(UndoList(1,3),'UserData',get(SelectList(1),'FaceColor'));
			set(UndoList(2,2),'UserData',-1);
			set(SelectList(1),'FaceColor',option);
		end
	else
		moreItems = numObjs + 1 - size(UndoList,1);
		if(moreitems > 0)
			UndoList  = [UndoList; zeros(moreItems,1) ...
			reshape(store(pfig,2*moreItems),moreItems,2)];
		end
		j = 1;
		for(i=1:numObjs)
			if(strcmp(get(SelectList(i,1),'type'),'patch'))
				UndoList(j,1) = SelectList(i,1);
				set(UndoList(j,2),'UserData','FaceColor');
				set(UndoList(j,3),'UserData',get(SelectList(i,1),'FaceColor'));
				set(SelectList(i,1),'LineStyle',option);
				j = j+1;
			end
		end
		set(UndoList(j,2),'UserData',-1);
	end
	set(datObjs(8),'UserData',UndoList);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Arrow Menu
%
%  Option can be:
%  '>'  Arrow at end
%  '-'  No Arrow
%  '<'  Arrow at start
%  'x'  Arrow at both ends
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

elseif(command == 5)
	Defaults = get(datObjs(5),'UserData');
	ArrowDefs = get(Defaults(11),'UserData');
	if(numObjs == 0)
		ArrowDefs(5) = option;
		set(datObjs(5),'UserData',Defaults);
		menu = get(gcf,'CurrentMenu');
		Mom = get(menu,'Parent');
		set(get(Mom,'UserData'),'Checked','off');
		set(Mom,'UserData',gcm);
		set(menu,'Checked','on');
		set(Defaults(11),'UserData',ArrowDefs);
	end
	for(i=1:numObjs)
		if(strcmp(get(SelectList(i,1),'Type'),'line'))
			if(option == '>')
				SelectList(i,1) = arrow(SelectList(i,1),...
										'Length',ArrowDefs(1),...
										'Width',ArrowDefs(2),...
										'BaseAngle',ArrowDefs(3),...
										'TipAngle',ArrowDefs(4),...
										'FaceColor',SelectList(i,2:4));
			elseif(option == '<')
				SelectList(i,1) = arrow(SelectList(i,1),...
										'Length',ArrowDefs(1),...
										'Width',ArrowDefs(2),...
										'BaseAngle',ArrowDefs(3),...
										'TipAngle',ArrowDefs(4),...
										'Ends','start',...
										'FaceColor',SelectList(i,2:4));
			elseif(option == 'x')
				SelectList(i,1) = arrow(SelectList(i,1),...
										'Length',ArrowDefs(1),...
										'Width',ArrowDefs(2),...
										'BaseAngle',ArrowDefs(3),...
										'TipAngle',ArrowDefs(4),...
										'Ends','both',...
										'FaceColor',SelectList(i,2:4));
			end
		elseif(strcmp(get(SelectList(i,1),'Tag'),'Arrow'))
			if(option == '>')
				SelectList(i,1) = arrow(SelectList(i,1),...
										'Length',ArrowDefs(1),...
										'Width',ArrowDefs(2),...
										'BaseAngle',ArrowDefs(3),...
										'TipAngle',ArrowDefs(4));
			elseif(option == '-')
				xdata = get(SelectList(i,1),'XData');
				ydata = get(SelectList(i,1),'YData');
				obj = SelectList(i,1);
				SelectList(i,1) = line('xdata',[xdata(6) xdata(1)],'ydata',[ydata(6) ydata(1)]);
				if(strcmp(get(obj,'Type'),'line'))
					set(SelectList(i,1),'Color',get(obj,'Color'),...
					                    'LineStyle',get(obj,'LineStyle'));
				else
					set(SelectList(i,1),'Color',get(obj,'EdgeColor'));
				end
				delete(obj);
			elseif(option == '<')
				SelectList(i,1) = arrow(SelectList(i,1),...
										'Length',ArrowDefs(1),...
										'Width',ArrowDefs(2),...
										'BaseAngle',ArrowDefs(3),...
										'TipAngle',ArrowDefs(4),...
										'Ends','start');
			elseif(option == 'x')
				SelectList(i,1) = arrow(SelectList(i,1),...
										'Length',ArrowDefs(1),...
										'Width',ArrowDefs(2),...
										'BaseAngle',ArrowDefs(3),...
										'TipAngle',ArrowDefs(4),...
										'Ends','both');
			end
		end
	end
	if(numObjs)
		set(gcf,'CurrentObject',SelectList(i,1));
		set(datObjs(3),'UserData',SelectList);
	end
elseif(command == 6)
	Arrows = findobj(gcf,'Tag','Arrow');
	arrow(Arrows,'Page',1);
end


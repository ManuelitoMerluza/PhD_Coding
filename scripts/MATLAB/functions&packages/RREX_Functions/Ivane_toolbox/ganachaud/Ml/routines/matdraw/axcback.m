function axcback(command,ax)

% AXCBACK Callback for MatDraw Axis Menu
% Function axcback(command,ax)
% This is a callback function, and should not be
% called directly!
%
% Keith Rogers  11/93

% Mods:
%    09/16/94  Added in labeling functions
%    12/01/94  Changed Toggling to update automatically
%    12/02/94  Shortened name to appease DOS Users
%    01/04/95  Magnification level changed by dialog box
%              instead of "input" now, labeling functions
%              taken out and put into "labels" m-file.
%	 02/28/95  Added in expand and reduce functions
% Copyright (c) 1995 by Keith Rogers

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	Commands
%
%  0:   Update submenus
%  1:	axis 'x'	X-Axis Lin/Log toggle	
%  2:	axis 'x'	X-Axis Auto Scale lower limit	
%  3:	axis 'x'	X-Axis Auto Scale upper limit	
%  4:	Toggle Hold On/Off
%  5:	Toggle Axis Limits Freeze/Auto
%  6:	axis 'x' 	Toggle Zoom Axis control 
%  7:	Adjust Magnification Level for zoom
%  8:	Expand subplot to full screen
%  9:	Reduce full screen back to subplot
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (command == 0)
	submenu = get(gcm,'UserData');
	if(strcmp(axis('state'),'manual'))
		set(submenu(1),'Label','Auto','Callback','axcback(5,0)');
	else
		set(submenu(1),'Label','Freeze','Callback','axcback(5,0)');
	end
	if(strcmp(get(gca,'Xscale'),'log'))
		set(submenu(2),'Label','Linear','Callback','axcback(1,''X'')');
	else
		set(submenu(2),'Label','Log','Callback','axcback(1,''X'')');
	end
	if(strcmp(get(gca,'Yscale'),'log'))
		set(submenu(3),'Label','Linear','Callback','axcback(1,''Y'')');
	else
		set(submenu(3),'Label','Log','Callback','axcback(1,''Y'')');
	end
	if(strcmp(get(gca,'Zscale'),'log'))
		set(submenu(4),'Label','Linear','Callback','axcback(1,''Z'')');
	else
		set(submenu(4),'Label','Log','Callback','axcback(1,''Z'')');
	end
	if(ishold)
		set(submenu(5),'Label','Hold off',...
							'Callback','axcback(4,0)',...
							'Accelerator','H');
	else
		set(submenu(5),'Label','Hold on',...
							'Callback','axcback(4,0)',...
							'Accelerator','H');
	end
elseif (command == 1)
	if (ax == 'X')
		if(strcmp(get(gcm,'Label'),'Log'))
			set(gca,'Xscale','log');
		else
			set(gca,'Xscale','linear');
		end
		Arrows = findobj(gca,'Tag','Arrow');
		if(~isempty(Arrows))
			arrow(Arrows);
		end
	elseif (ax == 'Y')
		if(strcmp(get(gcm,'Label'),'Log'))
			set(gca,'Yscale','log');
			set(gcm,'Label','Linear');
		else
			set(gca,'Yscale','linear');
			set(gcm,'Label','Log');
		end
		Arrows = findobj(gca,'Tag','Arrow');
		if(~isempty(Arrows))
			arrow(Arrows);
		end
	elseif (ax == 'Z')
		if(strcmp(get(gcm,'Label'),'Log'))
			set(gca,'Zscale','log');
			set(gcm,'Label','Linear');
		else
			set(gca,'Zscale','linear');
			set(gcm,'Label','Log');
		end
		Arrows = findobj(gca,'Tag','Arrow');
		if(~isempty(Arrows))
			arrow(Arrows);
		end
	end
elseif (command == 2)
	if (ax == 'X')
		minmax = get(gca,'XLim');
		set(gca,'XLim',[-inf minmax(2)]);
	elseif (ax == 'Y')
		minmax = get(gca,'YLim');
		set(gca,'YLim',[-inf minmax(2)]);
	elseif (ax == 'Z')
		minmax = get(gca,'ZLim');
		set(gca,'ZLim',[-inf minmax(2)]);
	end
elseif (command == 3)
	if (ax == 'X')
		minmax = get(gca,'XLim');
		set(gca,'XLim',[minmax(1) inf]);
	elseif (ax == 'Y')
		minmax = get(gca,'YLim');
		set(gca,'YLim',[minmax(1) inf]);
	elseif (ax == 'Z')
		minmax = get(gca,'ZLim');
		set(gca,'ZLim',[minmax(1) inf]);
	end
elseif (command == 4)
	if (ishold)
		hold off;
		set(gcm,'Label','Hold on');
	else
		hold on;
		set(gcm,'Label','Hold off');
	end
elseif (command == 5)
	if(strcmp(get(gcm,'Label'),'Freeze'))
		axis(axis);
		set(gcm,'Label','Auto');
	else
		axis('auto');
		set(gcm,'Label','Freeze');
	end
elseif (command == 6)
	menuhandle = get(gcm,'Parent');
	UserData = get(menuhandle,'UserData');
	if (ax == 'X')
		if (UserData(1))
			set(gcm,'Checked','off');
			UserData(1) = 0;
		else
			set(gcm,'Checked','on');
			UserData(1) = 1;
		end
	elseif (ax == 'Y')
		if (UserData(2))
			set(gcm,'checked','off');
			UserData(2) = 0;
		else
			set(gcm,'Checked','on');
			UserData(2) = 1;
		end
	else
		if (UserData(3))
			set(gcm,'Checked','off');
			UserData(3) = 0;
		else
			set(gcm,'Checked','on');
			UserData(3) = 1;
		end
	end
	set(menuhandle,'UserData',UserData);
elseif (command == 7)
	UserData = get(get(gcm,'Parent'),'UserData');
	UserData(4) = str2num(prompterdlg('Magnification Level?',num2str(UserData(4))));	
	set(gcm,'Label',['Mag Level -' num2str(UserData(4)) '-']);
	set(get(gcm,'Parent'),'UserData',UserData);
elseif (command == 8)
	allax = findobj(gcf,'Type','axes','Visible','on');
	set(findobj(allax(find(allax~=gca))),'Visible','off','Tag','Restore');
	set(gcm,'UserData',get(gca,'Position'),...
			  'Label','Reduce',...
			  'Callback','axcback(9)',...
			  'Accelerator','R');
	set(gca,'Position',get(gcf,'DefaultAxesPosition'));
elseif (command == 9)
	allax = findobj(gcf,'type','axes','Tag','Restore');
	set(gca,'Position',get(gcm,'UserData'))
	set(findobj(allax),'Visible','on','Tag','');
	set(gcm,'Label','Expand',...
			  'Callback','axcback(8)',...
			  'Accelerator','E');
end

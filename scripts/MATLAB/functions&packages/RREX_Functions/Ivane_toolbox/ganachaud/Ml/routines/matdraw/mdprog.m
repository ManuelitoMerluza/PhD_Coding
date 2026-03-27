function mdprog(command)
% MATDRAW  adds menus and draw functions to Matlab
% MATDRAW()
% Adds a suite of menus and a Draw palette to
% the Matlab environment.  This is an extension
% of the earlier package matmenus, which was
% written in November of 1993.
%
%
% Keith Rogers 11/94

%
% Mods:
%    12/01/94 Changed Toggle items to update automatically
%    12/5/94  Adapted to deal with single palette for all
%             figures,changed name to lower case to
%             appease VMS users.
%    12/13/94 Got rid of tsel leftover from matmenus
%             Changed zoom to mdzoom to avoid conflict with 
%             Mathworks zoom function
%    12/14/94 Add PageSetup dialog box, remove 
%             Portrait/Landscape Toggle
%             Add Delete item under Draw Menu
%    12/26/94 Add symbols to draw Line Style menu
%             Install modified zoom function
%    12/28/94 Add support for UISetColor or other
%             colors via the Input function for
%             those not using Macs or PC's.
%    01/12/95 Kill MatDraw Menus on all figures
%             when Draw Palette is destroyed.
%    01/13/95 Cleaned up some ugliness with the
%             MenuList which would cause errors 
%             under certain conditions.
%    01/20/95 Change PageSetup to pgsetup

% Copyright (c) 1995 by Keith Rogers


% First off, create the Draw Tools Palette

if(nargin < 1)
	fig = gcf;
	figure(gcf);
	if(strcmp(get(fig,'NextPlot'),'new'))
		questdlg(['This Figure has NEXTPLOT set to ''New.''  ' ...
				  'Are you sure you want to start up MatDraw?'],...
				  'Yes','No');
		if(strcmp(ans,'No'))
			return;
		end
	end
	set(gcf,'Pointer','watch');
	
% Compile everything
	if(0)
		axcback;dmncback;drwcback;edtcback;ellipse;figcback;
		findfig;isobj;kdialog;labels;loadobj;pick3d;mdzoom;movetext;
		objsize;palette;pgsetup;prmptdlg;saveobj;select;store;streamer;
		textlen;txtcback;viewer;vwrcback;wrkcback;zoom3d;
	end	
	pfig = findfig('Draw Tools');
	if(pfig)
		datObjs = get(pfig,'UserData');
		figList = get(datObjs(14),'UserData');
		if(find(figList==fig))
			menuList = get(datObjs(7),'UserData');
			if(isobj(menuList(find(figList==fig),1),fig))
				error('MatDraw is already active in this  window!');
			end
			menuList = menuList(find(figList~=fig),:);
			figList = figList(find(figList~=fig));
			set(datObjs(14),'UserData',figList);
			set(datObjs(7),'UserData',menuList);
		end
		figure(pfig);
		drwcback;
	else
		pfig = palette('#O/T+','Draw Tools','drwcback',16);
		if(strcmp(version,'4.2d'))
			set(pfig,'DestroyFcn','mdprog(1)');
			set(get(pfig,'CurrentAxes'),'DestroyFcn',...
			'delete(findfig(''Draw Tools''))');
		end
		datObjs = get(pfig,'UserData');
	end
	figure(fig);
	set(fig,'KeyPressFcn','select(11)',...
			'MenuBar','none');
	eval('set(fig,''ResizeFcn'',''mdprog(2)'')','');
	Defaults = get(datObjs(5),'UserData');

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% WORKSPACE MENU
	%
	% wrkcback commands
	% 1:	Load 
	% 2:	Save
	% 3:	Save As
	% 4:	New Figure
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	workspace = uimenu('Label','Workspace','Tag','MatDrawMenu');
	uimenu(workspace,'Label','New Figure', 'Callback','wrkcback',...
		'Accelerator','N');
	uimenu(workspace,'Label','Load', 'Callback','wrkcback');
	uimenu(workspace,'Label','Save Workspace', 'Callback','wrkcback',...
		'Accelerator','S');
	uimenu(workspace,'Label','Save As', 'Callback','wrkcback',...
		'Accelerator','A');
	uimenu(workspace,'Label','Add to Path','Callback','wrkcback');
	uimenu(workspace,'Label','Print','Callback','Print',...
		'Accelerator','P');
	uimenu(workspace,'Label','Quit', 'Callback','exit',...
		'Accelerator','Q','Separator','on');
	

	%%%%%%%%%%%%%%%%
	% MDEDIT Menu
	%
	% edtcback commands
	% 1:	Undo 
	% 2:	Cut
	% 3:	Copy
	% 4:	Paste
	%%%%%%%%%%%%%%%%

	EditMenu = uimenu('Label','MDEdit');
	UndoMenu = uimenu(EditMenu,'Label','Undo','Callback','edtcback(1)','Accelerator','Z');
	uimenu(EditMenu,'Label','Cut','Callback','edtcback(2)','Accelerator','X');
	uimenu(EditMenu,'Label','Copy','Callback','edtcback(3)','Accelerator','C');
	uimenu(EditMenu,'Label','Paste','Callback','edtcback(4)','Accelerator','V');
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% TEXT Menu
	% For txtcback the command parameter is 
	% 1:	Set font
	% 2:	Set angle
	% 3:	Set weight
	% 4:    Set to plain
	% 5:	Set Size
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	TextMenu = uimenu('Label','Text','Tag','MatDrawMenu');
	FontMenu = uimenu(TextMenu,'Label','Font');
	StyleMenu = uimenu(TextMenu,'Label','Style');
	SizeMenu = uimenu(TextMenu,'Label','Size');

	%%%%%%%%%%%%%
	% Font Menu
	%%%%%%%%%%%%%

	fontfile = fopen('sys.fnt','r');
	if(fontfile == -1)
		error('Can''t read file ''sys.fnt''');
	end

	fontname = fgetl(fontfile);
	while(fontname ~= -1)
		uimenu(FontMenu,'Label',fontname, ...
						'Callback',['txtcback(1,''' fontname ''')']);
		fontname = fgetl(fontfile);
	end
	fclose(fontfile);

	DefFont = get(Defaults(3),'UserData');
	
	% If the default font is not in the user's "sys.fnt" file
	% then we have to add it manually.
	
	DefMen = findobj(FontMenu,'Label',DefFont);
	if(isempty(DefMen))
		set(FontMenu,'UserData',uimenu(FontMenu,'Label',DefFont,...
		'Callback',['txtcback(1,''' DefFont ''')'],'Checked','on'));
	else
		set(DefMen,'Checked','on');
		set(FontMenu,'UserData',DefMen);
	end
	

	%%%%%%%%%%%%%
	% Style Menu
	%%%%%%%%%%%%%

	pmenu = uimenu(StyleMenu,'Label','Plain','Callback','txtcback(4,''plain'')');
	uimenu(StyleMenu,'Label','Italic','Callback','txtcback(2,''italic'')');
	uimenu(StyleMenu,'Label','Oblique','Callback','txtcback(2,''oblique'')');
	uimenu(StyleMenu,'Label','Light','Callback','txtcback(3,''light'')');
	uimenu(StyleMenu,'Label','Demi','Callback','txtcback(3,''demi'')');
	uimenu(StyleMenu,'Label','Bold','Callback','txtcback(3,''bold'')');
	DefAngle = get(Defaults(6),'UserData');
	DefWeight = get(Defaults(5),'UserData');
	AMenu = findobj(StyleMenu,'Label',DefAngle);
	WMenu = findobj(StyleMenu,'Label',DefWeight);
	if(~isempty(AMenu))
		set(AMenu,'Checked','on');
		set(StyleMenu,'UserData',AMenu);
	elseif(isempty(WMenu))
		set(pmenu,'Checked','on','UserData',[]);
		set(StyleMenu,'UserData',pmenu);
	end
	if(~isempty(WMenu))
		set(WMenu,'Checked','on');
		set(pmenu,'UserData',WMenu);
	end

	%%%%%%%%%%%%%
	% Size Menu
	%%%%%%%%%%%%%

	uimenu(SizeMenu,'Label','6','Callback','txtcback(5,6)');
	uimenu(SizeMenu,'Label','9','Callback','txtcback(5,9)');
	uimenu(SizeMenu,'Label','12','Callback','txtcback(5,12)');
	uimenu(SizeMenu,'Label','14','Callback','txtcback(5,14)');
	uimenu(SizeMenu,'Label','18','Callback','txtcback(5,18)');
	uimenu(SizeMenu,'Label','24','Callback','txtcback(5,24)');
	OtherMenu = uimenu(SizeMenu,'Label','Other','Callback','txtcback(5,0)');
	DefSize = get(Defaults(4),'UserData');
	DefMenu = findobj(SizeMenu,'Label',num2str(DefSize));
	if(isempty(DefMenu))
		set(OtherMenu,'Label',['Other (' num2str(DefSize) ')'],...
					  'Checked','on');
		set(SizeMenu,'UserData',OtherMenu);
	else
		set(DefMenu,'Checked','on');
		set(SizeMenu,'UserData',DefMenu);
	end

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% DRAW Menu
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	DrawMenu = uimenu('Label','Draw','Tag','MatDrawMenu');
	LineStyleMenu = uimenu(DrawMenu,'Label','Line Style');
	LineWidthMenu = uimenu(DrawMenu,'Label','Line Width');
	PenColorMenu = uimenu(DrawMenu,'Label','Pen Color');
	FillColorMenu = uimenu(DrawMenu,'Label','Fill Color');
	ArrowMenu = uimenu(DrawMenu,'Label','Arrows');

	% Save the Menu Handles

	MenuList = get(datObjs(7),'UserData');
	MenuList = [MenuList;
			    DrawMenu LineStyleMenu ...
			   	LineWidthMenu PenColorMenu ...
				FillColorMenu UndoMenu];
	set(datObjs(7),'UserData',MenuList);

	%%%%%%%%%%%%%%%%%%
	% LineStyle Menu
	%%%%%%%%%%%%%%%%%%

	defmen = uimenu(LineStyleMenu,'Label','''-''','Callback','dmncback(1,''-'')','Checked','on');
	uimenu(LineStyleMenu,'Label',''':''','Callback','dmncback(1,'':'')');
	uimenu(LineStyleMenu,'Label','''--''','Callback','dmncback(1,''--'')');
	uimenu(LineStyleMenu,'Label','''-.''','Callback','dmncback(1,''-.'')');
	uimenu(LineStyleMenu,'Label','''+''','Callback','dmncback(1,''+'')');
	uimenu(LineStyleMenu,'Label','''x''','Callback','dmncback(1,''x'')');
	uimenu(LineStyleMenu,'Label','''o''','Callback','dmncback(1,''o'')');
	uimenu(LineStyleMenu,'Label','''.''','Callback','dmncback(1,''.'')');
	uimenu(LineStyleMenu,'Label','''*''','Callback','dmncback(1,''*'')');
	set(LineStyleMenu,'UserData',defmen);

	%%%%%%%%%%%%%%%%%%
	% Line Width Menu
	%%%%%%%%%%%%%%%%%%

	defmen = uimenu(LineWidthMenu,'Label','0.5 point','Checked','on','Callback','dmncback(2,.5)');
	uimenu(LineWidthMenu,'Label','1.0 point','Callback','dmncback(2,1)');
	uimenu(LineWidthMenu,'Label','2.0 point','Callback','dmncback(2,2)');
	uimenu(LineWidthMenu,'Label','4.0 point','Callback','dmncback(2,4)');
	uimenu(LineWidthMenu,'Label','Other','Callback','dmncback(2,0)','UserData',1);
	set(LineWidthMenu,'UserData',defmen);

	%%%%%%%%%%%%%%%%%%
	% Pen Color Menu
	%%%%%%%%%%%%%%%%%%

	uimenu(PenColorMenu,'Label','Yellow','Callback','dmncback(3,[1 1 0])',...
	'ForegroundColor','y','BackgroundColor','y');
	uimenu(PenColorMenu,'Label','Magenta','Callback','dmncback(3,[1 0 1])',...
	'ForegroundColor','m','BackgroundColor','m');
	uimenu(PenColorMenu,'Label','Cyan','Callback','dmncback(3,[0 1 1])',...
	'ForegroundColor','c','BackgroundColor','c');
	uimenu(PenColorMenu,'Label','Red','Callback','dmncback(3,[1 0 0])',...
	'ForegroundColor','r','BackgroundColor','r');
	uimenu(PenColorMenu,'Label','Green','Callback','dmncback(3,[0 1 0])',...
	'ForegroundColor','g','BackgroundColor','g');
	uimenu(PenColorMenu,'Label','Blue','Callback','dmncback(3,[0 0 1])',...
	'ForegroundColor','b','BackgroundColor','b');
	defmen = uimenu(PenColorMenu,'Label','White','Callback','dmncback(3,[1 1 1])','Checked','on');
	uimenu(PenColorMenu,'Label','Black','Callback','dmncback(3,[0 0 0])');
	uimenu(PenColorMenu,'Label','Other','Callback','dmncback(3,''Other'')');
	set(PenColorMenu','UserData',defmen);

	%%%%%%%%%%%%%%%%%%
	% Fill Color Menu
	%%%%%%%%%%%%%%%%%%

	uimenu(FillColorMenu,'Label','Yellow','Callback','dmncback(4,[1 1 0])',...
	'ForegroundColor','y','BackgroundColor','y');
	uimenu(FillColorMenu,'Label','Magenta','Callback','dmncback(4,[1 0 1])',...
	'ForegroundColor','m','BackgroundColor','m');
	uimenu(FillColorMenu,'Label','Cyan','Callback','dmncback(4,[0 1 1])',...
	'ForegroundColor','c','BackgroundColor','c');
	uimenu(FillColorMenu,'Label','Red','Callback','dmncback(4,[1 0 0])',...
	'ForegroundColor','r','BackgroundColor','r');
	uimenu(FillColorMenu,'Label','Green','Callback','dmncback(4,[0 1 0])',...
	'ForegroundColor','g','BackgroundColor','g');
	uimenu(FillColorMenu,'Label','Blue','Callback','dmncback(4,[0 0 1])',...
	'ForegroundColor','b','BackgroundColor','b');
	uimenu(FillColorMenu,'Label','White','Callback','dmncback(4,[1 1 1])');
	uimenu(FillColorMenu,'Label','Black','Callback','dmncback(4,[0 0 0])');
	uimenu(FillColorMenu,'Label','Other','Callback','dmncback(4,''Other'')');
	defmen = uimenu(FillColorMenu,'Label','None','Checked','on','Callback','dmncback(4,''none'')');
	set(FillColorMenu,'UserData',defmen);

	%%%%%%%%%%%%%%%%%%
	% Arrow Menu
	%%%%%%%%%%%%%%%%%%

	uimenu(ArrowMenu,'Label',' ----->','Callback','dmncback(5,''>'')');
	defmen = uimenu(ArrowMenu,'Label',' ------','Callback','dmncback(5,''-'')','Checked','on');
	uimenu(ArrowMenu,'Label',' <-----','Callback','dmncback(5,''<'')');
	uimenu(ArrowMenu,'Label',' <---->','Callback','dmncback(5,''x'')');
	uimenu(ArrowMenu,'Label','Tips...','Callback','arrowdlg','separator','on');
	uimenu(ArrowMenu,'Label','Print Scale','Callback','dmncback(6)');
	set(ArrowMenu,'UserData',defmen);

	%%%%%%%%%%%%%%%%
	% FIGURE Menu 
	%%%%%%%%%%%%%%%%

	FigMenu = uimenu('Label','Figure','Tag','MatDrawMenu','Callback','figcback(0)');
	uimenu(FigMenu,'Label','Page Setup','Callback','pgsetup');
	uimenu(FigMenu,'Label','WYSIWYG','Callback','figcback(3)');

	%%%%%%%%%%%%%%%%%
	% Colormap Menu
	%%%%%%%%%%%%%%%%%

	ColorMenu = uimenu(FigMenu,'Label','ColorMap');

	uimenu(ColorMenu,'Label','Default','Callback',...
		'colormap(''default'')');
	uimenu(ColorMenu,'Label','Gray','Callback',...
		'colormap(''gray'')');
	uimenu(ColorMenu,'Label','Hot','Callback',...
		'colormap(''hot'')');
	uimenu(ColorMenu,'Label','Cool','Callback',...
		'colormap(''cool'')');
	uimenu(ColorMenu,'Label','Copper','Callback',...
		'colormap(''copper'')');
	uimenu(ColorMenu,'Label','Pink','Callback',...
		'colormap(''pink'')');


    MBarMenu = uimenu(FigMenu,'Label','Full Menus','Callback','figcback(1)','Separator','on');
	set(FigMenu,'UserData',MBarMenu);
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% AXIS Menu
	%
	% axcback commands
	% 1:	Linear/Log toggle
	% 2:	AutoRange Min
	% 3:	AutoRange Max
	% 4:	Hold on/off toggle
	% 5: 	Axis Auto/Freeze toggle
	% 6:	Zoom Axis toggles
	% 7:	Zoom Magnification Level
	% 8: Expand/Reduce
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	AxMenu = uimenu('Label','Axis','Callback','axcback(0)','Tag','MatDrawMenu');
	uimenu(AxMenu,'Label','Labels','Callback','labels','Accelerator','L');
	uimenu(AxMenu,'Label','Expand','Callback','axcback(8)','Accelerator','E');
	uimenu(AxMenu,'Label','Clear','Callback','cla','Accelerator','K');
	uimenu(AxMenu,'Label','Grid','Callback','grid','Accelerator','G');

	autofreeze = uimenu(AxMenu,'Label','Freeze');

	%%%%%%%%%%%%%%
	% Aspect Menu
	%%%%%%%%%%%%%%

	AspectMenu = uimenu(AxMenu,'Label','Aspect');
	uimenu(AspectMenu,'Label','Normal','Callback','axis(''normal'')');
	uimenu(AspectMenu,'Label','Square','Callback','axis(''square'')');
	uimenu(AspectMenu,'Label','Image','Callback','axis(''image'')');
	uimenu(AspectMenu,'Label','Equal','Callback','axis(''equal'')');

	Xaxis = uimenu(AxMenu,'Label','X Opts');
	Yaxis = uimenu(AxMenu,'Label','Y Opts');
	Zaxis = uimenu(AxMenu,'Label','Z Opts');

	xloglin = uimenu(Xaxis,'Label','LogLin');
	yloglin = uimenu(Yaxis,'Label','LogLin');
	zloglin = uimenu(Zaxis,'Label','LogLin');
	uimenu(Xaxis,'Label','Auto Min','Callback','axcback(2,''X'')');
	uimenu(Xaxis,'Label','Auto Max','Callback','axcback(3,''X'')');
	uimenu(Yaxis,'Label','Auto Min','Callback','axcback(2,''Y'')');
	uimenu(Yaxis,'Label','Auto Max','Callback','axcback(3,''Y'')');
	uimenu(Zaxis,'Label','Auto Min','Callback','axcback(2,''Z'')');
	uimenu(Zaxis,'Label','Auto Max','Callback','axcback(3,''Z'')');

	holditem = uimenu(AxMenu,'Label','Hold');

	set(AxMenu,'UserData',[autofreeze;
						   xloglin;
						   yloglin;
						   zloglin;
						   holditem;]);

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% ZOOM Menu
	%
	% UserData(1)     X axis zoom flag
	% UserData(2)     Y axis zoom flag
	% UserData(3)     Z axis zoom flag
	% UserData(4)     Magnification Level
	% UserData(5)     Direction Flag (1 = IN, 2 = OUT)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	ZoomMenu = uimenu(AxMenu,'Label','Zoom');

	maglevel = 2;

	set(ZoomMenu,'UserData',[1;1;0;maglevel;zeros(6,1)]);

	uimenu(ZoomMenu,'Label','Zoom In','Callback','mdzoom(''in'')',...
		'Accelerator','I');
	uimenu(ZoomMenu,'Label','Zoom Out','Callback','mdzoom(''out'')',...
		'Accelerator','O');
	uimenu(ZoomMenu,'Label','Zoom Home','Callback','mdzoom(''home'')',...
		'Accelerator','U');
	uimenu(ZoomMenu,'Label','X Axis','Checked','on',...
		'Callback','axcback(6,''X'')','Separator','on');
	uimenu(ZoomMenu,'Label','Y Axis','Checked','on',...
		'Callback','axcback(6,''Y'')');
	uimenu(ZoomMenu,'Label','Z Axis','Checked','off',...
		'Callback','axcback(6,''Z'')');
	uimenu(ZoomMenu,'Label',['Mag Level -' num2str(maglevel) '-'],'Callback','axcback(7,0)',...
		'Separator','on');

	uimenu(AxMenu,'Label','Viewer','Callback','viewer','Separator','on');
	
	set(gcf,'Pointer','arrow');

elseif(command == 1)
	allfigs = get(0,'Children');
	for (fig = allfigs)
		menus = findobj(fig,'Type','uimenu','Tag','MatDrawMenu');
		for(menu = menus);
			delete(menu);
		end
	end
elseif(command == 2)
	   Arrows = findobj(gcf,'Tag','Arrow');
	   if(~isempty(Arrows))
			arrow(Arrows);
	   end
end

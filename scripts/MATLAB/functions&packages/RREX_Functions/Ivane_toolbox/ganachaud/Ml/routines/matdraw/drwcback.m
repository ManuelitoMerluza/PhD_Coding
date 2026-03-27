function drwcback(command)
% DRWCBACK Callback for Draw Tools Palette
% Function drwcback(command)
% This is a callback function, and should not be
% called directly!
%
% Keith Rogers  11/94
 
% Mods:
%     12/02/94  Shortened name to appease DOS users
%     12/5/94	 Adapted to deal with single palette for all
%               figures,changed name to lower case to
%               appease VMS users.
%     12/14/94  Fixed bug in circle from center section
%               Individualized pointers for *all* palette
%               tools
%     01/13/95  Took out initialization of DatObjs(7)
%     01/16/95  Line snap to angle when SelectionType is Extend
%     03/02/95  Major revision for version 2.

% Copyright (c) 1995 by Keith Rogers

datObjs = get(findfig('Draw Tools'),'UserData');
allfigs = get(0,'Children');
lastfig = allfigs(2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	Commands
%
%  None:    Initialize Data Objects
%  String:  Process command from palette
%  1:       Text tool WindowButtonDownFcn
%  1.1:       Callback for Text Edit UIControl
%  2:       Line tool WindowButtonDownFcn
%  2.1:       Line WindowButtonMotionFcn: Normal
%  2.2:       Line WindowButtonMotionFcn: Extend
%  2.2:       Line WindowButtonUpFcn
%  3:       Ellipse tool WindowButtonDownFcn
%  3.1:       Ellipse WindowButtonMotionFcn: Normal
%  3.2:       Ellipse WindowButtonMotionFcn: Extend
%  3.3:       Ellipse WindowButtonMotionFcn: Alt
%  3.4:       Ellipse WindowButtonUpFcn
%  4:       Box WindowButtonDownFcn
%  4.1:       Box WindowButtonMotionFcn
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if(nargin < 1)  % Initialize drwcback Data Space

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% datObjs(3): Currently selected object
% datObjs(4): Reference Location
% datObjs(5): Defaults
%	Defaults(1) = Number of points in Circle
%   Defaults(2) = Selection Color
%   Defaults(3) = Default TextFont
%   Defaults(4) = Default TextSize
%   Defaults(5) = Default TextWeight
%   Defaults(6) = Default TextAngle
%   Defaults(7) = Default Line Style
%   Defaults(8) = Default Line Width
%   Defaults(9) = Default Pen Color
%   Defaults(10) = Default Fill Color
%   Defaults(11) = Defaults for Arrows 
%                  (Length,Width,Baseangle,Tipangle)
%   Defaults(12) = Arrow Style; '<','>','-',or 'x'
% datObjs(6): general purpose handle space
% datObjs(7): Menu handles for enabling/disabling
% datObjs(8): Undo Data
% datObjs(9): Clipboard for Undo
% datObjs(10): Clipboard
% datObjs(11): 
% datObjs(12): 
% datObjs(13): Undo Values II
% datObjs(14): Figure List
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	if(isempty(get(datObjs(5),'UserData')))
		set(datObjs(3),'UserData',[]);
		set(datObjs(4),'UserData',[]);
		Defaults = zeros(11,1);
		Defaults(1) = 50;
		Defaults(2:11) = store(10);
		set(Defaults(2),'UserData',[.5 .5 .5]);
		set(Defaults(3),'UserData',get(0,'DefaultTextFontName'));
		set(Defaults(4),'UserData',get(0,'DefaultTextFontSize'));
		set(Defaults(5),'UserData',get(0,'DefaultTextFontWeight'));	
		set(Defaults(6),'UserData',get(0,'DefaultTextFontAngle'));	
		set(Defaults(7),'UserData',get(0,'DefaultLineLineStyle'));	
		set(Defaults(8),'UserData',get(0,'DefaultLineLineWidth'));	
		set(Defaults(9),'UserData',[1 1 1]);	
		set(Defaults(10),'UserData','none');	
		set(Defaults(11),'UserData',[16;0;90;16;'-';0;0;0]);	
		set(datObjs(5),'UserData',Defaults);
		set(datObjs(6),'UserData',[]);
		UndoList = [zeros(3,1) reshape(store(6),3,2)];
		set(UndoList(1,2),'UserData',-1);
		set(datObjs(8),'UserData',UndoList);
		UClip = reshape(store(9),3,3);
		set(UClip(1,1),'UserData',-1);
		set(datObjs(9),'UserData',UClip);
		clipboard = reshape(store(9),3,3);
		set(clipboard(1,1),'UserData',-1);
		set(datObjs(10),'UserData',clipboard);
		set(datObjs(11),'UserData',[]);
		set(datObjs(12),'UserData',[]);
		set(datObjs(13),'UserData',[]);
	end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% If the figure isn't in the list, add it             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	figList = get(datObjs(14),'UserData');	
	if(isempty(find(figList==lastfig)))		
		set(datObjs(14),'UserData',[figList;lastfig;]); 
	end					

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% If COMMAND is a string, we're receiving data 
% from PALETTE(), and need to process it.
% 
% ''  means we've deselected a palette item
% '+' means we've gone into SELECT mode
% 'T' means we've gone into TEXT mode
% '/' means we've gone into LINE drawing mode
% '0' means we've gone into CIRCLE drawing mode
% '#' means we've gone into BOX drawing mode
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

elseif(isstr(command))                          
	allfigs = get(0,'children');
	if(length(allfigs) > 1)
		i=1;
		while(strcmp(get(allfigs(i),'NextPlot'),'new'))
			i=i+1;
		end
		if(command~='')
			figure(allfigs(i));
		end
	end
	if(command=='')
		set(allfigs(i),'Pointer','arrow',...
					   'WindowButtonDownFcn','',...
					   'WindowButtonUpFcn','',...
					   'WindowButtonMotionFcn','');
	elseif(command=='T')
		set(allfigs(i),'Pointer','botl','WindowButtonDownFcn','drwcback(1)');
	elseif(command=='/')
		set(allfigs(i),'Pointer','crosshair','WindowButtonDownFcn','drwcback(2)');	
	elseif(command=='+')
		set(allfigs(i),'WindowButtonDownFcn','select',...
		               'Pointer','arrow');	
	elseif(command=='O')
		set(allfigs(i),'WindowButtonDownFcn','drwcback(3)',...
							'Pointer','circle');
	elseif(command=='#')
		set(allfigs(i),'WindowButtonDownFcn','drwcback(4)',...
							'Pointer','cross');
	end

	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Text Placing Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

elseif(command == 1)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Create Text ButtonDown
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	if(findobj(gcf,'Tag','MDEdit'))
		drwcback(1.1);
	end
	cpf = getset(gcf,'CurrentPoint','Units','Points');
	obj = uicontrol('Style','edit',...
					 'Units','Points',...
				    'Position',[cpf 60 25],...
				    'Callback','drwcback(1.1)',...
					'Tag','MDEdit');
	set(datObjs(6),'UserData',obj);
	set(datObjs(4),'UserData',get(gca,'CurrentPoint'));
	
elseif(command == 1.1)  
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Text Edit Callback
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	textObj = get(datObjs(6),'UserData');
	pos = get(datObjs(4),'UserData');
	Defaults = get(datObjs(5),'UserData');
	string = get(textObj,'String');
	delete(textObj);
	if(~isempty(string))
		tobj = text('String',string,...
			 'Units','data',...
			 'Position',pos(1,1:2),...
			 'HorizontalAlignment','left',...
			 'VerticalAlignment','bottom',...
			 'Color',get(Defaults(9),'UserData'));
		UndoList = get(datObjs(8),'UserData');
		UndoList(1,1) = tobj;
		set(UndoList(1,2),'UserData','Delete');
		set(UndoList(2,2),'UserData',-1);
		set(datObjs(8),'UserData',UndoList);
	end
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Line drawing functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

elseif(command == 2)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Line Drawing ButtonDown
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	hold on;
	axis(axis);
	ax = axis;
	if(length(ax) == 4)
		cp = get(gca,'CurrentPoint');
		defaults = get(datObjs(5),'UserData');
		pencolor = get(defaults(9),'UserData');
		obj = line('XData',[cp(1,1);cp(1,1)],'YData',[cp(1,2);cp(1,2)],'Color',pencolor);
		set(obj,'Erasemode','xor');

		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		% If shift key his held down, limit
		% line angle to multiples of pi/12
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

		if(strcmp(get(gcf,'SelectionType'),'extend'))
			set(gcf,'WindowButtonMotionFcn','drwcback(2.2)');
		else
			set(gcf,'WindowButtonMotionFcn','drwcback(2.1)');
		end
		set(gcf,'WindowButtonUpFcn','drwcback(2.3)');
		set(datObjs(6),'UserData',obj);
	else
		pfig  = findfig('Draw Tools');
		delete(findobj('Tag','3D Create Line'));
		storage = store(pfig,4,'3D Create Line');
		set(gcf,'WindowButtonUpFcn','drwcback(2.4)');
		pick3d('3D Create Line');
	end

elseif(command == 2.1)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Line Drawing Normal ButtonMotion
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 	obj = get(datObjs(6),'UserData');
	cp = get(gca,'CurrentPoint');
	xd = get(obj,'XData');
	xd(2) = cp(1,1);
	yd = get(obj,'YData');
	yd(2) = cp(1,2);
	set(obj,'XData',xd,'YData',yd);

elseif(command == 2.2)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Line Drawing Extended ButtonMotion
	% (Round angles to multiples of pi/12)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 	obj = get(datObjs(6),'UserData');
	cp = get(gca,'CurrentPoint');
	XData = get(obj,'XData');
	YData = get(obj,'YData');
	ax = axis;
	dx = ax(2)-ax(1);
	dy = ax(4)-ax(3);
	NX = XData/dx;
	NY = YData/dy;
	
	s32 = .5*sqrt(3);
	s22 = .5*sqrt(2);
	Pmat = [1.0  0.0;  s32  0.5;  s22  s22;  0.5  s32;
	        0.0  1.0; -0.5  s32; -s22  s22; -s32  0.5;
	       -1.0  0.0; -s32 -0.5; -s22 -s22; -0.5 -s32;
	        0.0 -1.0;  0.5 -s32;  s22 -s22;  s32 -0.5];
	proj = Pmat*[cp(1,1)/dx-NX(1);cp(1,2)/dy-NY(1)];
	[m,i] = max(proj);
	m = m*Pmat(i,:);
	XData(2) = XData(1)+m(1)*dx;
	YData(2) = YData(1)+m(2)*dy;
	set(obj,'XData',XData,'YData',YData);

elseif(command == 2.3)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% ButtonUp for Lines and Boxes
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  	obj = get(datObjs(6),'UserData');
	set(gcf,'WindowButtonMotionFcn','');
	set(gcf,'WindowButtonUpFcn','');
	set(obj,'EraseMode','normal');
	if(strcmp(get(obj,'Type'),'line'))
		Defaults = get(datObjs(5),'UserData');
		ArrowDefs = get(Defaults(11),'UserData');
		if(ArrowDefs(5) == '>')
			obj = arrow(obj,'Width',ArrowDefs(2),...
					  'Length',ArrowDefs(1),...
			          'BaseAngle',ArrowDefs(3),...
					  'TipAngle',ArrowDefs(4),...
					  'Crossdir',ArrowDefs(6:8));
		elseif(ArrowDefs(5) == '<')
			obj = arrow(obj,'Width',ArrowDefs(2),...
					  'Length',ArrowDefs(1),...
			        'BaseAngle',ArrowDefs(3),...
					  'TipAngle',ArrowDefs(4),...
					  'Ends','start',...
					  'Crossdir',ArrowDefs(6:8));
		elseif(ArrowDefs(5) == 'x')
			obj = arrow(obj,'Width',ArrowDefs(2),...
					  'Length',ArrowDefs(1),...
			        'BaseAngle',ArrowDefs(3),...
					  'TipAngle',ArrowDefs(4),...
					  'Ends','both',...
					  'Crossdir',ArrowDefs(6:8));
		end
	end
	UndoList = get(datObjs(8),'UserData');
	UndoList(1,1) = obj;
	set(UndoList(1,2),'UserData','Delete');
	set(UndoList(2,2),'UserData',-1);
	set(datObjs(8),'UserData',UndoList);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Button up for first point in 3D line
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

elseif(command == 2.4)
	storage = sort(findobj('Tag','3D Create Line'));
	UserData = get(storage(4),'UserData');
	defaults = get(datObjs(5),'UserData');
	pencolor = get(defaults(9),'UserData');
	obj = line('XData',UserData(4)*[1 1],...
	           'YData',UserData(5)*[1 1],...
				  'ZData',UserData(6)*[1 1],...
				  'Color',pencolor);
	set(obj,'Erasemode','xor');
	pfig  = findfig('Draw Tools');
	newstorage = store(pfig,3,'3D Create Line');
	set(newstorage(1),'UserData',obj);
	set(newstorage(2),'UserData',UserData(4:6,[1 1]));
	set(newstorage(3),'UserData',2);
	set(gcf,'WindowButtonUpFcn','drwcback(2.5)');
	pick3d('3D Create Line');
elseif(command == 2.5)
	delete(findobj('Tag','3D Create Line'));
  	obj = gco;
	set(gcf,'WindowButtonDownFcn','');
	set(gcf,'WindowButtonMotionFcn','');
	set(gcf,'WindowButtonUpFcn','');
	set(obj,'EraseMode','normal');
	Defaults = get(datObjs(5),'UserData');
	ArrowDefs = get(Defaults(11),'UserData');
	if(ArrowDefs(5) == '>')
		obj = arrow(obj,'Width',ArrowDefs(2),...
				  'Length',ArrowDefs(1),...
					 'BaseAngle',ArrowDefs(3),...
				  'TipAngle',ArrowDefs(4),...
				  'Crossdir',ArrowDefs(6:8));
	elseif(ArrowDefs(5) == '<')
		obj = arrow(obj,'Width',ArrowDefs(2),...
				  'Length',ArrowDefs(1),...
				  'BaseAngle',ArrowDefs(3),...
				  'TipAngle',ArrowDefs(4),...
				  'Ends','start',...
				  'Crossdir',ArrowDefs(6:8));
	elseif(ArrowDefs(5) == 'x')
		obj = arrow(obj,'Width',ArrowDefs(2),...
				  'Length',ArrowDefs(1),...
				  'BaseAngle',ArrowDefs(3),...
				  'TipAngle',ArrowDefs(4),...
				  'Ends','both',...
				  'Crossdir',ArrowDefs(6:8));
	end
	UndoList = get(datObjs(8),'UserData');
	UndoList(1,1) = obj;
	set(UndoList(1,2),'UserData','Delete');
	set(UndoList(2,2),'UserData',-1);
	set(datObjs(8),'UserData',UndoList);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Circle/Ellipse Drawing functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

elseif(command == 3)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Ellipse Drawing ButtonDown
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	defaults = get(datObjs(5),'UserData');
	FaceColor = get(defaults(10),'UserData');
	numpts = defaults(1);
	hold on;
	axis(axis);
	cp = get(gca,'CurrentPoint');
	obj = patch('XData',cp(1,1)*ones(numpts,1),...
				'YData',cp(1,2)*ones(numpts,1),...
				'FaceColor',FaceColor,...
				'EdgeColor',get(defaults(9),'UserData'),...
				'Erasemode','xor');
	if(strcmp(get(gcf,'SelectionType'),'extend'))
		set(gcf,'WindowButtonMotionFcn','drwcback(3.2)');
	elseif(strcmp(get(gcf,'SelectionType'),'alt'))
		set(gcf,'WindowButtonMotionFcn','drwcback(3.3)');
	else
		set(gcf,'WindowButtonMotionFcn','drwcback(3.1)');
	end
	set(gcf,'WindowButtonUpFcn','drwcback(3.4)');
	set(datObjs(4),'UserData',cp);
 	set(datObjs(6),'UserData',obj);

elseif(command == 3.1) 
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Draw Ellipse from edge
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	firstpoint = get(datObjs(4),'UserData');
 	obj = get(datObjs(6),'UserData');
	cp = get(gca,'CurrentPoint');
	ax = axis;
	defaults = get(datObjs(5),'UserData');
	numpts = defaults(1);
	ext = [min([cp(:,1:2);firstpoint(:,1:2)]) ...
		   abs(cp(1,1:2)-firstpoint(1,1:2))];
	[x,y] = ellipse(ext,numpts,ax);
	set(obj,'XData',x,'YData',y);
elseif(command == 3.2)  
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Draw Circle from edge
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	firstpoint = get(datObjs(4),'UserData');
 	obj = get(datObjs(6),'UserData');
	cp = get(gca,'CurrentPoint');
	maxd = max(abs(cp(1,1:2)-firstpoint(1,1:2)));
	ext = [min([cp(:,1:2);firstpoint(:,1:2)]) maxd maxd];
	defaults = get(datObjs(5),'UserData');
	numpts = defaults(1);
	ax = axis;
	[x,y] = ellipse(ext,numpts,ax);
	set(obj,'XData',x,'YData',y);
elseif(command == 3.3)  
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Draw Circle from Center
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	center = get(datObjs(4),'UserData');
 	obj = get(datObjs(6),'UserData');
	cp = get(gca,'CurrentPoint');
	ax = axis;
	radius = sqrt(((cp(1,1)-center(1,1))/(ax(2)-ax(1)))^2+((cp(1,2)-center(1,2))/(ax(4)-ax(3)))^2);
	ext = [center(1,1:2)-[radius radius] 2*radius 2*radius];
	defaults = get(datObjs(5),'UserData');
	numpts = defaults(1);
	[x,y] = ellipse(ext,numpts,ax);
	set(obj,'XData',x,'YData',y);
elseif(command == 3.4)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Ellipse ButtonUp
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 	obj = get(datObjs(6),'UserData');
	set(obj,'EraseMode','normal',...
			'Tag','MDEllipse');
	set(gcf,'WindowButtonMotionFcn','');
	set(gcf,'WindowButtonUpFcn','');
	UndoList = get(datObjs(8),'UserData');
	UndoList(1,1) = obj;
	set(UndoList(1,2),'UserData','Delete');
	set(UndoList(2,2),'UserData',-1);
	set(datObjs(8),'UserData',UndoList);
			
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Box drawing functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

elseif(command == 4)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Box Drawing ButtonDown
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	defaults = get(datObjs(5),'UserData');
	FaceColor = get(defaults(10),'UserData');
	hold on;
	axis(axis);
	cp = get(gca,'CurrentPoint');
	obj = patch('XData',cp(1,1)*ones(4,1),...
				'YData',cp(1,2)*ones(4,1),...
				'FaceColor',FaceColor,...
				'EdgeColor',get(defaults(9),'UserData'),...
				'Tag','MDBox',...
				'Erasemode','xor');
	set(gcf,'WindowButtonMotionFcn','drwcback(4.1)');
	set(gcf,'WindowButtonUpFcn','drwcback(2.3)');
	set(datObjs(4),'UserData',cp);
 	set(datObjs(6),'UserData',obj);
elseif(command == 4.1)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Box Drawing ButtonDown
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	firstpoint=get(datObjs(4),'UserData');
	obj = get(datObjs(6),'UserData');
	cp = get(gca,'CurrentPoint');
	ext = [firstpoint(1,1:2) cp(1,1:2)-firstpoint(1,1:2)];
	XData = ext(1)+[0 ext(3) ext(3) 0 0];
	YData = ext(2)+[0 0 ext(4) ext(4)  0];
	set(obj,'XData',XData,'YData',YData);	
end

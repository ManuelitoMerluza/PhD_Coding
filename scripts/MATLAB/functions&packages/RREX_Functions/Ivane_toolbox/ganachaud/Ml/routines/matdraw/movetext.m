function movetext(command)
% FUNCTION MOVETEXT(COMMAND)
% This is a callback designed to be called by a
% WindowButtonDown event.  COMMAND dictates the
% function's behavior. Basically, the function 
% handles mouse-controlled movement and rotation
% of text.
%
% Keith Rogers 9/26/94

datObjs = get(findfig('Draw Tools'),'UserData');

if(nargin == 0)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ButtonDown Behavior:
% If SelectionType is open, create 
% EDIT uicontrol to edit the text.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	obj = gco;
	ext = getset(obj,'Extent','Units','Normalized');
	cp = getset(gcf,'CurrentPoint','Units','Normalized');
	axpos = getset(gca,'Position','Units','Normalized');
	cp = (cp-axpos(1:2))./axpos(3:4);
	UndoList = get(datObjs(8),'UserData');
	UndoList(1,1) = obj;
	if(strcmp(get(gcf,'SelectionType'),'open'))
		uipos = [min([axpos(1)+axpos(3)*ext(1) 1-2*axpos(3)*ext(3)]),...
				 min([axpos(2)+axpos(4)*ext(2) 1-1.5*axpos(4)*ext(4)]),...
				 2*axpos(3)*ext(3) 1.5*axpos(4)*ext(4)];
		if(uipos(4)>uipos(3))
			uipos(3:4)=uipos(4:-1:3);
		end
		textedit = uicontrol('style','edit',...
							'string',get(obj,'String'),...
							'units','Normalized',...
							'Position',uipos,...
						    'Callback','movetext(4)');
		set(textedit,'UserData',[obj;textedit]);
		
		% Set Undo Info
		
		set(UndoList(1,2),'UserData','String');
		set(UndoList(1,3),'UserData',get(obj,'String'));
		set(UndoList(2,2),'UserData',-1);	
		set(datObjs(8),'UserData',UndoList);	
	else
		set(obj,'EraseMode','xor');
		if((cp(1)<(ext(1)+.2*ext(3)) | cp(1)>(ext(1)+.8*ext(3))) &...
		   (cp(2)<(ext(2)+.2*ext(4)) | cp(2)>(ext(2)+.8*ext(4))))
				
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			% Set up functions for a text rotate
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			set(datObjs(6),'UserData',get(obj,'Position'));
			set(UndoList(1,2),'UserData','Rotation');
			set(UndoList(1,3),'UserData',get(obj,'Rotation'));
			set(UndoList(2,2),'UserData',-1);
			
			set(gcf,'WindowButtonMotionFcn','movetext(1)',...
			'WindowButtonUpFcn','movetext(2)');
		
		else
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			% Set up functions for a text move
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		
			set(UndoList(1,2),'UserData','Position');
			set(UndoList(1,3),'UserData',get(obj,'Position'));
			set(UndoList(2,2),'UserData',-1);
			set(gcf,'WindowButtonMotionFcn','movetext(3)');
			set(gcf,'WindowButtonUpFcn','movetext(2)');
			set(obj,'Units','Data');
			cp = get(gca,'CurrentPoint');
			set(datObjs(6),'UserData',cp(1,:)-get(obj,'Position'));
		end
	end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Do the rotate (this is for WindowButtonMotionFcn) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

elseif(command == 1)
	cp = get(gca,'CurrentPoint');
	movetext_pos = get(datObjs(6),'UserData');
	theta=atan2(cp(1,2)-movetext_pos(2),cp(1,1)-movetext_pos(1));
	if(strcmp(get(gcf,'SelectionType'),'extend'))
		set(gco,'rotation',180/12*round(12/pi*theta));
	else
		set(gco,'rotation',180/pi*theta);
	end
	
%%%%%%%%%%%%%%%%%%%%
% WindowButtonUpFcn 
%%%%%%%%%%%%%%%%%%%%

elseif(command == 2)
		set(gco,'erasemode','normal');
		set(gcf,'WindowButtonMotionFcn','',... 
		        'WindowButtonUpFcn','');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Do the Text Move (this is for WindowButtonMotionFcn) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

elseif(command == 3)
	offset = get(datObjs(6),'UserData');
	cp = get(gca,'CurrentPoint');
	set(gco,'Position',cp(1,:)-offset);
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callback for EDIT UIControl
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
elseif(command == 4)
	objs = get(gco,'UserData');
	set(objs(1),'string',get(objs(2),'string'));
	delete(objs(2));
end

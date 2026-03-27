function select(command,position)
% Function select(command,position)
% This is a callback function, and should not be
% called directly!
%
% Keith Rogers  2/95
%
% Mods: 

% Copyright (c) 1995 by Keith Rogers

% Get Data Storage Space from the Palette
% datObjs(1): Reserved for Palette  
% datObjs(2): Reserved for Palette 
% datObjs(3): Currently selected object
% datObjs(4): Reference Location
% datObjs(5): Defaults
% datObjs(6): general purpose handle space
% datObjs(7): Menu handles for enabling/disabling
% datObjs(8): Undo List
% datObjs(9): Undo Clipboard
% datObjs(10): Primary Clipboard
% datObjs(11): 
% datObjs(12): 
% datObjs(13): 

datObjs = get(findfig('Draw Tools'),'UserData');
obj = gco;
fig = gcf;

if(nargin < 1)
	Defaults = get(datObjs(5),'UserData');
	SelColor = get(Defaults(2),'UserData');
	SelectList = get(datObjs(3),'UserData');
	type = get(gco,'Type');
	if(isempty(SelectList))
		if(~strcmp(type,'figure')) 
			set(obj,'Selected','on');  
			if(strcmp(type,'line')) 
				set(datObjs(3),'UserData',[obj get(obj,'Color')]);
				set(obj,'Color',SelColor);
			elseif(strcmp(type,'patch'))
				EdgeColor = get(obj,'EdgeColor');
				if(isstr(EdgeColor))
					if(EdgeColor(1) == 'n')  % 'none'
						set(datObjs(3),'UserData',[obj -1 -1 -1]);
					elseif(EdgeColor(1) == 'f')  % 'flat'
						set(datObjs(3),'UserData',[obj -2 -2 -2]);
					elseif(EdgeColor(1) == 'i')  % 'interp'
						set(datObjs(3),'UserData',[obj -3 -3 -3]);
					end
				else
					set(datObjs(3),'UserData',[obj EdgeColor]);
				end
				set(obj,'EdgeColor',SelColor);
			else
				set(datObjs(3),'UserData',[obj zeros(1,3)]); %Add obj to select list
			end
		end
	else
		% Handle Shift-clicking to select multiple objects
		
		if(strcmp(get(gcf,'SelectionType'),'extend'))

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% If obj is already selected
	%        DESELECT IT
	% 1) If this is the only object selected then we must
	%    check to make see if the object has a special 
	%    "extended" property that has been activated.
	%    If so, then we do *not* deselect.
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

			if(any(SelectList(:,1)==obj)) 
				flag = 0;
				if(size(SelectList,1) == 1)    
					if(strcmp(type,'text'))
						movetext;
						flag = 1;
					elseif(strcmp(type,'line') | strcmp(get(obj,'Tag'),'Arrow'))
						select(12);
						flag = 1;
					elseif(strcmp(type,'patch'))
						select(13);
						flag = 1;
					end
				end
				if(~flag) % Then nothing special happened, so just deselect obj
					if(isobj(obj))
						set(obj,'Selected','off');
						if(strcmp(type,'line'))
							set(obj,'Color',SelectList(find(SelectList(:,1)==obj),2:4));
						elseif(strcmp(type,'patch'))
							if(SelectList(i,2) == -1)
								set(SelectList(i,1),'EdgeColor','none');
							elseif(SelectList(i,2) == -2)
								set(SelectList(i,1),'EdgeColor','flat');
							elseif(SelectList(i,2) == -3)
								set(SelectList(i,1),'EdgeColor','interp');
							else
								set(SelectList(i,1),'EdgeColor',SelectList(i,2:4));
							end						
						end
					end
					SelectList = SelectList(find(SelectList(:,1)~=obj),:);  %Remove obj from select list
					set(datObjs(3),'UserData',SelectList);
				end
				
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%   Still doing actions for EXTEND click
	%
	% If OBJ is not selected, SELECT it
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

			elseif(~strcmp(type,'figure')) 
				set(obj,'Selected','on');  
				if(strcmp(type,'line')) 
					set(datObjs(3),'UserData',[SelectList; obj get(obj,'Color')]);
					set(obj,'Color',SelColor);
				elseif(strcmp(type,'patch'))
					EdgeColor = get(obj,'EdgeColor');
					if(isstr(EdgeColor))
						if(EdgeColor(1) == 'n')  % 'none'
							set(datObjs(3),'UserData',[obj -1 -1 -1]);
						elseif(EdgeColor(1) == 'f')  % 'flat'
							set(datObjs(3),'UserData',[obj -2 -2 -2]);
						elseif(EdgeColor(1) == 'i')  % 'interp'
							set(datObjs(3),'UserData',[obj -3 -3 -3]);
						end
					else
						set(datObjs(3),'UserData',[obj EdgeColor]);
					end
					set(obj,'EdgeColor',SelColor);
				else
					set(datObjs(3),'UserData',[SelectList; obj zeros(1,3)]); %Add obj to select list
				end
				
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%			
	% Extend-clicking on on an axes just selects it.
	% To DESELECT EVERYTHING click outside the axes
	% so that OBJ is the current figure
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

			else 
				for(i=1:size(SelectList,1))
					if(isobj(SelectList(i,1)))
						set(SelectList(i,1),'Selected','off');
						typ = get(SelectList(i,1),'Type');
						if(strcmp(typ,'line'))
							set(SelectList(i,1),'Color',SelectList(i,2:4));
						elseif(strcmp(typ,'patch'))
							if(SelectList(i,2) == -1)
								set(SelectList(i,1),'EdgeColor','none');
							elseif(SelectList(i,2) == -2)
								set(SelectList(i,1),'EdgeColor','flat');
							elseif(SelectList(i,2) == -3)
								set(SelectList(i,1),'EdgeColor','interp');
							else
								set(SelectList(i,1),'EdgeColor',SelectList(i,2:4));
							end						
						end
					end
				end
				set(datObjs(3),'UserData',[]);
			end
			
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%			
	% On to NORMAL clicking...
	% If OBJ is *not* selected
	% 1) Deselect everything else
	% 2) Select OBJ (Unless it's a figure).
	%    This, for now, just means adding it
	%    to the select list and changing its
	%    pen color for lines and patches.
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

		elseif(~any(SelectList(:,1)==obj))
			for(i=1:size(SelectList,1)) %Deselect everything but obj.
				if(isobj(SelectList(i,1)))
					set(SelectList(i,1),'Selected','off');
					typ = get(SelectList(i,1),'Type');
					if(strcmp(typ,'line'))
						set(SelectList(i,1),'Color',SelectList(i,2:4));
					elseif(strcmp(typ,'patch'))
						if(SelectList(i,2) == -1)
							set(SelectList(i,1),'EdgeColor','none');
						elseif(SelectList(i,2) == -2)
							set(SelectList(i,1),'EdgeColor','flat');
						elseif(SelectList(i,2) == -3)
							set(SelectList(i,1),'EdgeColor','interp');
						else
							set(SelectList(i,1),'EdgeColor',SelectList(i,2:4));
						end
					end
				end
			end
			set(obj,'Selected','on');  %select obj.
			if(strcmp(type,'line')) 
				set(datObjs(3),'UserData',[obj get(obj,'Color')]);
				set(obj,'Color',SelColor);
			elseif(strcmp(type,'patch'))
				EdgeColor = get(obj,'EdgeColor');
				if(isstr(EdgeColor))
					if(EdgeColor(1) == 'n')  % 'none'
						set(datObjs(3),'UserData',[obj -1 -1 -1]);
					elseif(EdgeColor(1) == 'f')  % 'flat'
						set(datObjs(3),'UserData',[obj -2 -2 -2]);
					elseif(EdgeColor(1) == 'i')  % 'interp'
						set(datObjs(3),'UserData',[obj -3 -3 -3]);
					end
				else
					set(datObjs(3),'UserData',[obj EdgeColor]);
				end
				set(obj,'EdgeColor',SelColor);
			elseif(~strcmp(type,'figure'))
				set(datObjs(3),'UserData',[obj zeros(1,3)]); %Add obj to select list
			else %OBJ is a figure, so deselect everything
				set(datObjs(3),'UserData',[]);
			end

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
	%We've established that OBJ is already selected
	%If OBJ is just one of many, then we get to 
	%          MOVE THE WHOLE GROUP	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
		
		elseif(size(SelectList,1) > 1)  
			set(gcf,'WindowButtonMotionFcn','select(9)');
			set(gcf,'WindowButtonUpFcn','select(10)');
			set(datObjs(4),'UserData',get(gca,'CurrentPoint'));
			UndoList = get(datObjs(8),'UserData');
			moreItems = 2*size(SelectList,1)+1 - size(UndoList,1);
			if(moreItems > 0)
				pfig  = findfig('Draw Tools');
				UndoList  = [UndoList; zeros(moreItems,1) ...
				reshape(store(pfig,2*moreItems),moreItems,2)];
			end
			j = 1;
			for(i=1:size(SelectList,1))
				typ = get(SelectList(i,1),'Type');
				if(strcmp(typ,'line') | strcmp(typ,'patch'))
					UndoList(j,1) = SelectList(i,1);
					UndoList(j+1,1) = SelectList(i,1);
					set(UndoList(j,2),'UserData','XData');
					set(UndoList(j,3),'UserData',get(SelectList(i,1),'XData'));
					set(UndoList(j+1,2),'UserData','YData');
					set(UndoList(j+1,3),'UserData',get(SelectList(i,1),'YData'));
					set(SelectList(i,1),'EraseMode','xor');
					j = j+2;
				elseif(strcmp(typ,'text'))
					UndoList(j,1) = SelectList(i,1);
					set(UndoList(j,2),'UserData','Position');
					set(UndoList(j,3),'UserData',get(SelectList(i,1),'Position'));
	   				set(SelectList(i,1),'EraseMode','xor');
					j = j+1;
				end
				set(UndoList(j,2),'UserData',-1);
			end
			set(datObjs(8),'UserData',UndoList);

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
	% Having eliminated all other possibilities, we now
	% go to procedures for when a single, already selected
	% object has been clicked on.  This includes moving,
	% reshaping, and otherwise editing the objects.
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
			
		elseif(strcmp(type,'text'))
			
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		% Selected object is text
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		
			movetext;	
				
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		% Selected object is a box or ellipse
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				
		elseif(strcmp(type,'patch') & (strcmp(get(obj,'Tag'),'MDBox') | strcmp(get(obj,'Tag'),'MDEllipse')))
		
			select(13);
			
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		% Selected object is a 2 point line
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		
		elseif(strcmp(type,'line') | strcmp(get(obj,'Tag'),'Arrow'))
			select(12);
		end
	end
elseif(command == 1)
	p = get(gca,'CurrentPoint');
	set(obj,'Units','data','Position',[p(1,1) p(1,2) p(1,3)]);
elseif(command == 2)
	set(obj,'erasemode','normal');
	set(fig,'WindowButtonMotionFcn','');
	set(fig,'WindowButtonUpFcn','');
elseif(command == 3)  % Resize Line
	cp = get(gca,'CurrentPoint');
	XData = get(obj,'XData');
	YData = get(obj,'YData');
	if(strcmp(get(obj,'Tag'),'Arrow'))
		XData = [XData(6) XData(1)];
		YData = [YData(6) YData(1)];
	end
	ax = axis;
	dx = ax(2)-ax(1);
	dy = ax(4)-ax(3);
	NX = XData/dx;
	NY = YData/dy;
	if(strcmp(get(gcf,'SelectionType'),'extend'))
		s32 = .5*sqrt(3);
		s22 = .5*sqrt(2);
		Pmat = [1.0  0.0;  s32  0.5;  s22  s22;  0.5  s32;
		        0.0  1.0; -0.5  s32; -s22  s22; -s32  0.5;
		       -1.0  0.0; -s32 -0.5; -s22 -s22; -0.5 -s32;
		        0.0 -1.0;  0.5 -s32;  s22 -s22;  s32 -0.5];
		proj = Pmat*[cp(1,1)/dx-NX(1);cp(1,2)/dy-NY(1)];
		[m,i] = max(proj);
		m = m*Pmat(i,:);
		XData(1) = XData(2)+m(1)*dx;
		YData(1) = YData(2)+m(2)*dy;
	else
		XData(1) = cp(1,1);
		YData(1) = cp(1,2);
	end
	if(strcmp(get(obj,'Tag'),'Arrow'))
		arrow(obj,'Start',[XData(1) YData(1)]);
	else
		set(obj,'XData',XData,'YData',YData);
	end
elseif(command == 4)  % Resize Line
	cp = get(gca,'CurrentPoint');
	XData = get(obj,'XData');
	YData = get(obj,'YData');
	if(strcmp(get(obj,'Tag'),'Arrow'))
		XData = [XData(6) XData(1)];
		YData = [YData(6) YData(1)];
	end
	ax = axis;
	dx = ax(2)-ax(1);
	dy = ax(4)-ax(3);
	NX = XData/dx;
	NY = YData/dy;
	if(strcmp(get(gcf,'SelectionType'),'extend'))
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
	else
		XData(2) = cp(1,1);
		YData(2) = cp(1,2);
	end
	if(strcmp(get(obj,'Tag'),'Arrow'))
		arrow(obj,'Stop',[XData(2) YData(2)]);
	else
		set(obj,'XData',XData,'YData',YData);
	end
elseif(command == 5)  % Move Line or Box
	startpoint = get(datObjs(4),'UserData');
	cp = get(gca,'CurrentPoint');
	XData = get(obj,'XData');
	YData = get(obj,'YData');
	XData = XData+cp(1,1)-startpoint(1,1);
	YData = YData+cp(1,2)-startpoint(1,2);
	set(obj,'XData',XData,'YData',YData);
	set(datObjs(4),'UserData',cp);
elseif(command == 6)  % Finished with Line, Box, or Circle
	if(strcmp(get(obj,'Tag'),'Arrow'))
		UserData = get(obj,'UserData');
		XData = get(obj,'XData');
		YData = get(obj,'YData');
		ZData = get(obj,'ZData');
		UserData(1:6) = [XData(6) YData(6) ZData(6) XData(1) YData(1) ZData(1)];
		set(obj,'UserData',UserData);
	end
	set(obj,'EraseMode','normal');
	set(fig,'WindowButtonMotionFcn','');
	set(fig,'WindowButtonUpFcn','');
	delete(findobj('Tag','3D Resize'));
elseif(command == 7) % Resize Box from corner
	ext = get(datObjs(4),'UserData');
	cp = get(gca,'CurrentPoint');
	if(position == 1)
		ext = [cp(1,1:2) ext(1:2)+ext(3:4)-cp(1,1:2)];
	elseif(position == 2)
		ext = [cp(1,1) ext(2) ext(1)+ext(3)-cp(1,1) cp(1,2)-ext(2)];
	elseif(position == 3)
		ext(3:4) = cp(1,1:2)-ext(1:2);
	else
		ext(2:4) = [cp(1,2) cp(1,1)-ext(1) ext(2)+ext(4)-cp(1,2)];
	end
	XData = ext(1)+[0 ext(3) ext(3) 0 0];
	YData = ext(2)+[0 0 ext(4) ext(4) 0];
	if(length(get(obj,'XData')) ~= 5)  % true for a Ellipse
		ax = axis;
		defaults = get(datObjs(5),'UserData');
		numpts = defaults(1);
		[XData, YData] = ellipse(ext,numpts,ax);
	end
	set(obj,'XData',XData,'YData',YData);
elseif(command == 8) % Resize box from edge
	ext = get(datObjs(4),'UserData');
	cp = get(gca,'CurrentPoint');
	if(position == 1)
		ext = [cp(1,1) ext(2) ext(1)+ext(3)-cp(1,1) ext(4)];
	elseif(position == 2)
		ext = [ext(1) ext(2) ext(3) cp(1,2)-ext(2)];
	elseif(position == 3)
		ext = [ext(1) ext(2) cp(1,1)-ext(1) ext(4)];
	else
		ext = [ext(1) cp(1,2) ext(3) ext(2)+ext(4)-cp(1,2)];
	end
	XData = ext(1)+[0 ext(3) ext(3) 0 0];
	YData = ext(2)+[0 0 ext(4) ext(4) 0];
	if(length(get(obj,'XData')) ~= 5)  % true for a Ellipse
		ax = axis;
		defaults = get(datObjs(5),'UserData');
		numpts = defaults(1);
		[XData, YData] = ellipse(ext,numpts,ax);
	end
	set(obj,'XData',XData,'YData',YData);	
elseif(command == 9) % Move a bunch of objects
	SelectList = get(datObjs(3),'UserData');
	startpoint = get(datObjs(4),'UserData');
	cp = get(gca,'CurrentPoint');
	for(i=1:size(SelectList,1))
		typ = get(SelectList(i,1),'Type');
		if(strcmp(typ,'line') | strcmp(typ,'patch'))
			XData = get(SelectList(i,1),'XData');
			YData = get(SelectList(i,1),'YData');
			XData = XData+cp(1,1)-startpoint(1,1);
			YData = YData+cp(1,2)-startpoint(1,2);
			set(SelectList(i,1),'XData',XData,'YData',YData);
		elseif(strcmp(typ,'text'))
			set(SelectList(i,1),'Position',get(SelectList(i,1),'Position')... 
									             +cp(1,:)-startpoint(2,:));
		end
	end
	set(datObjs(4),'UserData',cp);
elseif(command == 10) % ButtonUpFcn for above	
	SelectList = get(datObjs(3),'UserData');
	Arrows = findobj(SelectList,'Tag','Arrow');
	for(i=1:length(Arrows))
		UserData = get(Arrows(i),'UserData');
		XData = get(Arrows(i),'XData');
		YData = get(Arrows(i),'YData');
		ZData = get(Arrows(i),'ZData');
		UserData(1:6) = [XData(6) YData(6) ZData(6) XData(1) YData(1) ZData(1)];
		set(Arrows(i),'UserData',UserData);
	end
	set(gcf,'WindowButtonMotionFcn','');
	set(gcf,'WindowButtonUpFcn','');
	for(i=1:size(SelectList,1))
		set(SelectList(i,1),'EraseMode','normal');
	end
elseif(command == 11)
	char = get(gcf,'CurrentCharacter');
	if(strcmp(computer,'SUN4'))
		if(char == 127)
			edtcback(5);
		end
	elseif(char == 8)
		edtcback(5);
	end
	if(char == '+' | char == 'T' | char == '/' |...
		   char == 'O' | char == '#')
		drwcback(char);
	elseif(char > '0' & char <= '9')
		axlist = findobj(gcf,'Type','axes','Visible','on');
		numaxes = length(axlist);
		if(numaxes > 1 & char-'0' <= numaxes)
			axpos = zeros(numaxes,2);
			for(i=1:numaxes)
				pos = get(axlist(i),'Position');
				axpos(i,:) = pos(2:-1:1);
			end
			[s,ind] = sort(axpos(:,1));
			axlist = axlist(ind(numaxes:-1:1));
			axpos = axpos(ind(numaxes:-1:1),:);
			for(i=1:numaxes-1)
				if(axpos(i,1) == axpos(i+1))
					if(axpos(i,2) > axpos(i+1,2))
						axlist(i:i+1) = axlist(i+1:-1:i);
					end
				end
			end
			set(gcf,'CurrentAxes',axlist(char-'0'));
		end
	elseif(length(axis) == 4) 
		if(char == 28)  % Left Arrow
			xtick = get(gca,'Xtick');
			dx = xtick(2)-xtick(1);
			ax = axis;
			ax(1) = ax(1)-dx;
			ax(2) = ax(2)-dx;
			axis(ax);
		elseif(char == 29)  % Right Arrow
			xtick = get(gca,'Xtick');
			dx = xtick(2)-xtick(1);
			ax = axis;
			ax(1) = ax(1)+dx;
			ax(2) = ax(2)+dx;
			axis(ax);
		elseif(char == 30)  % Right Arrow
			ytick = get(gca,'Ytick');
			dy = ytick(2)-ytick(1);
			ax = axis;
			ax(3) = ax(3)+dy;
			ax(4) = ax(4)+dy;
			axis(ax);
		elseif(char == 31)  % Right Arrow
			ytick = get(gca,'Ytick');
			dy = ytick(2)-ytick(1);
			ax = axis;
			ax(3) = ax(3)-dy;
			ax(4) = ax(4)-dy;
			axis(ax);
		end
	end
elseif(command == 12)
	XData = get(obj,'XData');
	YData = get(obj,'YData');
	if(strcmp(get(obj,'Tag'),'Arrow'))
		XData = [XData(6) XData(1)];
		YData = [YData(6) YData(1)];
	end
	if(length(XData) == 2)
		ax = axis;
		cp = get(gca,'CurrentPoint');
		set(obj,'EraseMode','xor');
		if(length(ax) == 6)
			ZData = get(obj,'ZData');
			if(strcmp(get(obj,'Tag'),'Arrow'))
				ZData = [ZData(6) ZData(1)];
			end
			p1 = [XData(1) YData(1) ZData(1)];
			p2 = [XData(2) YData(2) ZData(2)];
			a = diff(cp);
			b = cp(1,:);
			t = -sum(a.*(b-p1))/(a*a');
			distToP1 = sqrt(sum(((b-p1)+a*t).^2));
			t = -a*(b-p2)'/(a*a');
			distToP2 = sqrt(sum(((b-p2)+a*t).^2));
			linelen = sqrt(a*a');
			if(distToP1 < .2*linelen)
				pfig  = findfig('Draw Tools');
				delete(findobj('Tag','3D Resize'));
				storage = store(pfig,7,'3D Resize');
				set(storage(5),'UserData',obj);
				set(storage(6),'UserData',[XData;YData;ZData]);
				set(storage(7),'UserData',1);
				% Maybe store needs to allow a tag to be attached.
				set(fig,'WindowButtonUpFcn','select(6)');
				pick3d('3D Resize');
			elseif(distToP2 < .2*linelen)
				pfig  = findfig('Draw Tools');
				delete(findobj('Tag','3D Resize'));
				storage = store(pfig,7,'3D Resize');
				set(storage(5),'UserData',obj);
				set(storage(6),'UserData',[XData;YData;ZData]);
				set(storage(7),'UserData',2);
				set(fig,'WindowButtonUpFcn','select(6)');
				pick3d('3D Resize');
			end	
		else
%			dy = ax(4)-ax(3);
%			dx = ax(2)-ax(1);
%			YN = YData/dy; 
%			XN = XData/dx; 
%			distToP1 = sqrt((cp(1,1)/dx-XN(1))^2+(cp(1,2)/dy-YN(1))^2);
%			distToP2 = sqrt((cp(1,1)/dx-XN(2))^2+(cp(1,2)/dy-YN(2))^2);
%			linelen = sqrt(diff(XN)^2+diff(YN)^2);
			distToP1 = sqrt((cp(1,1)-XData(1))^2+(cp(1,2)-YData(1))^2);
			distToP2 = sqrt((cp(1,1)-XData(2))^2+(cp(1,2)-YData(2))^2);
			linelen = sqrt(diff(XData)^2+diff(YData)^2);
			if(distToP1 < .2*linelen)
				set(fig,'WindowButtonMotionFcn','select(3)');
			elseif(distToP2 < .2*linelen)
				set(fig,'WindowButtonMotionFcn','select(4)');
			else
				set(datObjs(4),'UserData',cp);
				set(fig,'WindowButtonMotionFcn','select(5)');
			end	
			set(fig,'WindowButtonUpFcn','select(6)');
		end
		
		% Set Undo Info
		
		UndoList = get(datObjs(8),'UserData');
		moreItems = 3 - size(UndoList,1);
		if(moreItems > 0)
			pfig  = findfig('Draw Tools');
			UndoList  = [UndoList; zeros(moreItems,1) ...
			reshape(store(pfig,2*moreItems),moreItems,2)];
		end
		set(UndoList(3,2),'UserData',-1);
		UndoList(1:2,1) = [obj;obj];
		set(UndoList(1,2),'UserData','XData');
		set(UndoList(2,2),'UserData','YData');
		set(UndoList(1,3),'UserData',get(obj,'XData'));
		set(UndoList(2,3),'UserData',get(obj,'YData'));
		set(datObjs(8),'UserData',UndoList);
	end
elseif(command == 13)
	XData = get(obj,'XData');
	YData = get(obj,'YData');
	set(gco,'EraseMode','xor');
	cp = get(gca,'CurrentPoint');
	minx = min(XData);
	miny = min(YData);
	ext = [minx miny max(XData)-minx max(YData)-miny];
	set(datObjs(4),'UserData',ext);
	if(cp(1,1)<ext(1)+.2*ext(3))
		if(cp(1,2)<ext(2)+.2*ext(4)) 		% Lower Left Corner
			set(fig,'WindowButtonMotionFcn','select(7,1)');
		elseif(cp(1,2)>ext(2)+.8*ext(4)) 	% Upper Left Corner
			set(fig,'WindowButtonMotionFcn','select(7,2)');
		else								% Left Side
			set(fig,'WindowButtonMotionFcn','select(8,1)');
		end
	elseif(cp(1,1)>ext(1)+.8*ext(3))
		if(cp(1,2)<ext(2)+.2*ext(4)) 		% Lower Right Corner
			set(fig,'WindowButtonMotionFcn','select(7,4)');
		elseif(cp(1,2)>ext(2)+.8*ext(4)) 	% Upper Right Corner
			set(fig,'WindowButtonMotionFcn','select(7,3)');
		else								% Right Side
			set(fig,'WindowButtonMotionFcn','select(8,3)');
		end
	elseif(cp(1,2)>ext(2)+.8*ext(4))		% Top Side
			set(fig,'WindowButtonMotionFcn','select(8,2)')
	elseif(cp(1,2)<ext(2)+.2*ext(4))		% Bottom Side
			set(fig,'WindowButtonMotionFcn','select(8,4)')
	else									% Center
		set(datObjs(4),'UserData',cp);
		set(fig,'WindowButtonMotionFcn','select(5)');
	end
	set(fig,'WindowButtonUpFcn','select(2)');
	
	% Set Undo Info
	
	UndoList = get(datObjs(8),'UserData');
	moreItems = 3 - size(UndoList,1);
	if(moreItems > 0)
		pfig  = findfig('Draw Tools');
		UndoList  = [UndoList; zeros(moreItems,1) ...
		reshape(store(pfig,2*moreItems),moreItems,2)];
	end
	set(UndoList(3,2),'UserData',-1);
	UndoList(1:2,1) = [obj;obj];
	set(UndoList(1,2),'UserData','XData');
	set(UndoList(2,2),'UserData','YData');
	set(UndoList(1,3),'UserData',get(obj,'XData'));
	set(UndoList(2,3),'UserData',get(obj,'YData'));
	set(UndoList(3,2),'UserData',-1);
	set(datObjs(8),'UserData',UndoList);
end

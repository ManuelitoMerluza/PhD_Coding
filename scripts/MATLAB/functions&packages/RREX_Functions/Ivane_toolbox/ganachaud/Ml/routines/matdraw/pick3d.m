function pick3d(command,StorageTag)
%Keith Rogers 05/03/95

%Copyright (c) 1995 by Keith Rogers

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% storage(1):  Old WindowButtonDownFcn
% storage(2):  Old WindowButtonMotionFcn
% storage(3):  Old WindowButtonUpFcn
% storage(4):  UserData
%           :  (1)  Xline
%           :  (2)  Yline
%           :  (3)  Zline
%           :  (4)  Px
%           :  (5)  Py
%           :  (6)  Pz
% storage(5):  Optional - Handle
% storage(6):  Optional - Data
% storage(7):  Optional - Start/End indicator
%

if(nargin < 2)
	StorageTag = command;
end
%   interruptible = get(gcf,'interruptible');
%   set(gcf,'interruptible','yes');

	storage = sort(findobj('Tag',StorageTag));
	UserData = get(storage(4),'UserData');	

	if(isstr(command))  % Setup
		set(storage(1),'UserData',get(gcf,'WindowButtonDownFcn'));
		set(storage(2),'UserData',get(gcf,'WindowButtonMotionFcn'));
		set(storage(3),'UserData',get(gcf,'WindowButtonUpFcn'));
		set(gcf,'pointer','crosshair');
		set(gcf,'WindowButtonMotionFcn',['pick3d(1,''' StorageTag ''')']);
		set(gcf,'WindowButtonDownFcn',['pick3d(2,''' StorageTag ''')']);
		set(gcf,'WindowButtonUpFcn','');
		disp(get(gcf,'WindowButtonUpFcn'));
		ax = axis;
		if(length(storage) > 4)
			Data = get(storage(6),'UserData');
			if(get(storage(7),'UserData')==1)
				pz = Data(3,1);
			else
				pz = Data(3,2);
			end
		else
			pz = (ax(5)+ax(6))/2;
		end
		set(gcf,'units','normalized');
		pt = get(gcf,'CurrentPoint');
		px = pt(1,1)*(ax(2)-ax(1))+ax(1);
		py = pt(1,2)*(ax(4)-ax(3))+ax(3);
		xline = line('Xdata',[ax(1);ax(1);ax(2);ax(2);ax(1);ax(1);ax(2)],...
						 'Ydata',[py ax(3) ax(3) ax(4) ax(4) py py],...
						 'Zdata',pz*ones(7,1),...
		             'LineStyle',':','Color','w');
		yline = line('Xdata',px*ones(7,1),...
						 'Ydata',[ax(3);ax(3);ax(4);ax(4);ax(3);ax(3);ax(4)],...
						 'Zdata',[pz;ax(5);ax(5);ax(6);ax(6);pz;pz],...
			          'LineStyle',':','Color','w');
		zline = line('Xdata',[px;ax(1);ax(1);ax(2);ax(2);px;px],...
						 'Ydata',py*ones(7,1),...
						 'Zdata',[ax(5);ax(5);ax(6);ax(6);ax(5);ax(5);ax(6)],...
			          'LineStyle',':','Color','w');
		if(strcmp(computer,'MAC2'))
			set([xline yline zline],'Color','r');
		end
		set(yline,'EraseMode','xor');
		set(xline,'EraseMode','xor');
		set(zline,'EraseMode','xor');
		if(length(storage) > 4)
			set(get(storage(5),'UserData'),'EraseMode','xor');
		end
		UserData = [xline;yline;zline;px;py;pz];
		set(storage(4),'UserData',UserData);
	elseif (command == 1)
%		disp(get(gcf,'WindowButtonUpFcn'));
		px = UserData(4);
		py = UserData(5);
		pz = UserData(6);
		ax = axis;
		pt = get(gcf,'CurrentPoint');
		if(strcmp(get(gcf,'SelectionType'),'alt'))
			pz = pt(2)*(ax(6)-ax(5))+ax(5);
			set(UserData(2),'ZData',pz*ones(7,1));
			set(UserData(3),'ZData',pz*ones(7,1));
			UserData(6) = pz;
			if(length(storage) > 4)
				obj = get(storage(5),'UserData');
				objdata = get(storage(6),'UserData');
				StartStop = get(storage(7),'UserData');
				if(StartStop == 1)
					objdata(3,1) = pz;
				else
					objdata(3,2) = pz;
				end
				if(strcmp(get(obj,'Tag'),'Arrow'))
					arrow(obj,'Start',objdata(:,1),'Stop',objdata(:,2));
				else
					set(obj,'ZData',objdata(3,:));
				end
				set(storage(6),'UserData',objdata);
			end
			set(storage(4),'UserData',UserData);
		else
			px = pt(1,1)*(ax(2)-ax(1))+ax(1);
			py = pt(1,2)*(ax(4)-ax(3))+ax(3);
			set(UserData(1),'Ydata',[py ax(3) ax(3) ax(4) ax(4) py py]);
			set(UserData(2),'XData',px*ones(7,1));
			set(UserData(3),'XData',[px;ax(1);ax(1);ax(2);ax(2);px;px],...
								 'YData',py*ones(7,1));
			UserData(4) = px; UserData(5) = py;
			if(length(storage) > 4)
				obj = get(storage(5),'UserData');
				objdata = get(storage(6),'UserData');
				StartStop = get(storage(7),'UserData');
				if(StartStop == 1)
					objdata(1:2,1) = [px;py];
				else
					objdata(1:2,2) = [px;py];
				end
				if(strcmp(get(obj,'Tag'),'Arrow'))
					arrow(obj,'Start',objdata(:,1),'Stop',objdata(:,2));
				else
					set(obj,'XData',objdata(1,:),'YData',objdata(2,:));
				end
				set(storage(6),'UserData',objdata);
			end
			set(storage(4),'UserData',UserData);
		end
	elseif(command == 2)
		disp(get(gcf,'WindowButtonUpFcn'));
		px = UserData(4);
		if(strcmp(get(gcf,'SelectionType'),'extend'))
			delete(UserData(1));
			delete(UserData(2));
			delete(UserData(3));
			set(gcf,'WindowButtonUpFcn',get(storage(3),'UserData'),...
					'WindowButtonMotionFcn',get(storage(2),'UserData'),...
					'WindowButtonDownFcn',get(storage(1),'UserData'));
			storage = sort(findobj('Tag',StorageTag));
			if(length(storage) > 4)
				obj = get(storage(5),'UserData');
				set(gcf,'pointer','arrow','currentobject',obj);
			end
		end
	end
end

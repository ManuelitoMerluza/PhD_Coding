function txtcback(command,data)
% Function txtcback(command,data)
% This is a callback function, and should not be
% called directly!
%
% Keith Rogers  11/94
%
% Mods:
%    12/02/94  Shortened name to appease DOS Users
%    12/28/94  Allow Axes Font parameters to be changed

pfig = findfig('Draw Tools');
datObjs = get(pfig,'UserData');
selectList = get(datObjs(3),'UserData');
UndoList = get(datObjs(8),'UserData');
Usize = size(UndoList,1);
if(isempty(selectList))
	Defaults = get(datObjs(5),'UserData');
	menu = gcm;
	Mom = get(menu,'Parent');
	if(command == 1)
		set(Defaults(3),'UserData',data);
		set(get(Mom,'UserData'),'Checked','off');
		set(Mom,'UserData',menu);		
	elseif(command == 2)
		set(Defaults(6),'UserData',data);
		if(~isempty(get(Mom,'UserData')))
			set(get(Mom,'UserData'),'Checked','off');
		end
		set(Mom,'UserData',menu);		
	elseif(command == 3)
		set(Defaults(5),'UserData',data);
		pmen = findobj(Mom,'Label','Plain');
		if(~isempty(pmen))
			set(get(pmen,'UserData'),'Checked','off');
		end
		if(get(Mom,'UserData')==pmen)
			set(pmen,'Checked','off')
			set(Mom,'UserData',[]);
		end
		set(pmen,'UserData',menu);		
	elseif(command == 4)
		set(Defaults(5),'UserData',data);
		if(~isempty(get(Mom,'UserData')))
			set(get(Mom,'UserData'),'Checked','off');
		end
		if(~isempty(get(menu,'UserData')))
			set(get(menu,'UserData'),'Checked','off');
		end
		set(Mom,'UserData',menu);
		set(menu,'UserData',[]);		
	elseif(command == 5)
		set(Defaults(4),'UserData',data);
		set(get(Mom,'UserData'),'Checked','off');
		set(Mom,'UserData',menu);		
	end
else
	for(i=1:size(selectList,1))
		type = get(selectList(i,1),'Type');
		moreItems = j+3-Usize;
		if(moreItems > 0)
			UndoList  = [UndoList; zeros(moreItems,1) ...
			reshape(store(pfig,2*moreItems),moreItems,2)];
		end
		j = 1;
		if(strcmp(type,'text') | strcmp(type,'axes'))
			set(UndoList(2,2),'UserData',-1);
			if(command == 1)
				UndoList(j,1) = selectList(i,1);
				set(UndoList(j,2),'UserData','FontName');
				set(UndoList(j,3),'UserData',get(selectList(i,1),'FontName'));
				set(selectList(i,1),'FontName',data);
				j = j+1;
			elseif(command == 2)
				UndoList(j,1) = selectList(i,1);
				set(UndoList(j,2),'UserData','FontAngle');
				set(UndoList(j,3),'UserData',get(selectList(i,1),'FontAngle'));
				set(selectList(i,1),'FontAngle',data);
				j = j+1;
			elseif(command == 3)
				UndoList(j,1) = selectList(i,1);
				set(UndoList(j,2),'UserData','FontWeight');
				set(UndoList(j,3),'UserData',get(selectList(i,1),'FontWeight'));
				set(selectList(i,1),'FontWeight',data);
				j = j+1;
			elseif(command == 4)
				UndoList(j,1) = selectList(i,1);
				UndoList(j+1,1) = selectList(i,1);
				set(UndoList(j,2),'UserData','FontWeight');
				set(UndoList(j,3),'UserData',get(selectList(i,1),'FontWeight'));
				set(UndoList(j+1,2),'UserData','FontAngle');
				set(UndoList(j+1,3),'UserData',get(selectList(i,1),'FontAngle'));
				set(selectList(i,1),'FontAngle','normal','FontWeight','normal');
				j = j+2;
			elseif(command == 5)
				UndoList(j,1) = selectList(i,1);
				set(UndoList(j,2),'UserData','FontSize');
				set(UndoList(j,3),'UserData',get(selectList(i,1),'FontSize'));
				if(data == 0)
					set(selectList(i,1),'FontSize',str2num(prmptdlg('Text Size?')));
				else
					set(selectList(i,1),'FontSize',data);
				end
				j = j + 1;
			end
		end
	end
end
set(UndoList(j,2),'UserData',-1);
set(datObjs(8),'UserData',UndoList);

function objdata = zoom3d(newlims,DataObj)
% Issues:
% Must save data for each surface object
% What about line objects?
% What about new plots after a zoom?

objdata = get(DataObj,'UserData');
pfig = findfig('Draw Tools');
kids = get(gca,'Children');
for(i=1:size(objdata,1))
	if(~any(kids == objdata(i,2)))
		objdata = objdata(find(objdata(:,2)~=objdata(i,2)),:);
	end
end
for(i = 1:length(kids))
	if(strcmp(get(kids(i),'Type'),'surface'))
		if(isempty(objdata))
			h = store(pfig,1);
			objdata = [h kids(i)];
			set(h,'UserData',[get(kids(i),'XData');
									get(kids(i),'YData');
									get(kids(i),'ZData');
									get(kids(i),'CData')]);
		elseif(all(kids(i) ~= objdata(:,2)))  % If unstored surface
			h = store(pfig,1);
			objdata = [objdata;h kids(i)];
			set(h,'UserData',[get(kids(i),'XData');
									get(kids(i),'YData');
									get(kids(i),'ZData');
									get(kids(i),'CData')]);
		end
	elseif(strcmp(get(kids(i),'Type'),'line'))
		if(isempty(objdata))
			h = store(pfig,1);
			objdata = [h(1) kids(i)];
			set(h,'UserData',[get(kids(i),'XData');
									get(kids(i),'YData');
									get(kids(i),'ZData')]);
		elseif(all(kids(i) ~= objdata(:,2)))  % If unstored line
			h = store(pfig,1);
			objdata = [objdata;h(1) kids(i)];
			set(h,'UserData',[get(kids(i),'XData');
									get(kids(i),'YData');
									get(kids(i),'ZData')]);
		end
	end
end
set(DataObj,'UserData',objdata);
if(ishold)
	h = 1;
else
	h = 0;
end
hold on;
for(i = 1:size(objdata,1))
	C = get(objdata(i,1),'UserData');
	if(size(C,1) > 3)
		meshsize = size(C,2);
		X = C(1:meshsize,:);
		Y = C(meshsize+1:2*meshsize,:);
		Z = C(2*meshsize+1:3*meshsize,:);
		C = C(3*meshsize+1:4*meshsize,:);
		Xlims = find((X(1,:) > newlims(1)) & (X(1,:) < newlims(2)));
		Ylims = find((Y(:,1) > newlims(3)) & (Y(:,1) < newlims(4)));
		X = X(Ylims,Xlims);
		Y = Y(Ylims,Xlims);
		Z = Z(Ylims,Xlims);
		C = C(Ylims,Xlims);
		ZHclip = find(Z > newlims(6));
		Z(ZHclip) = newlims(6)*ones(size(ZHclip));
		ZLclip = find(Z < newlims(5));
		Z(ZLclip) = newlims(5)*ones(size(ZLclip));
		set(objdata(i,2),'XData',X,'YData',Y,'ZData',Z,'CData',C);
	else
		X = C(1,:);
		Y = C(2,:);
		Z = C(3,:);
		OOB = find((X < newlims(1)) |...
					  (X > newlims(2)) |...
					  (Y < newlims(3)) |...
					  (Y > newlims(4)) |...
					  (Z < newlims(5)) |...
					  (Z > newlims(6)));
		Z(OOB) = NaN*ones(size(OOB));
		set(objdata(i,2),'XData',X,'YData',Y,'ZData',Z);
	end
end

if(~h)
	hold off;
end
axis(newlims);

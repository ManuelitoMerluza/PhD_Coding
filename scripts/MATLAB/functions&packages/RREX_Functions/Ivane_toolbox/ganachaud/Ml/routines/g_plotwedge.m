function g_plotwedge(method,ipair,depth,pname,punit,ppropp,xx,shpropp,depropp, ...
	    distgp,lat,lon)
%key: 3D plot the result of the bottom extrapolation by plane fit
%synopsis :
% 
%
%
%
%description : 
%
%
%
%
%uses :
%
%side effects :
%
%author : A.Ganachaud (ganacho@gulf.mit.edu) , Oct 95
%
%see also :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ndep=length(shpropp);
%sets xx to 0 at the shallow station, scales it in km
xxp=distgp*(1-[0.5;xx/2])/1e3;
% xxp is the distance from the middle of the stations.
if length(xxp)<1 %case where there is no depth difference
  xxp=(distgp/2/1e3);
end
%plot the data with 'o' signs
figure(1)
hold off;
plot(depth(1),shpropp(1),'o')
hold on;grid on;
plot([depth],[depropp],'-')
plot([depth],[shpropp],'-')
plot([depth],[ppropp],':')


figure(15)
hold off;
%plot3([0;distgp*1e-3*ones(ndep,1)],[depth(1);depth],[shpropp(1);depropp],'o')
plot3(0,depth(1),shpropp(1),'o')
hold on;grid on;
plot3([distgp*1e-3*ones(ndep,1)],[depth],[depropp],'-')
%plot3(xxp,[depth],[ppropp],'-')
%plot3(xxp,[depth],[ppropp],'+')
%%%plot3([0.5*distgp*1e-3*ones(ndep,1)],[depth],[ppropp])
%%%plot3([0.5*distgp*1e-3*ones(ndep,1)],[depth],[ppropp],'+')

%plot projection for comparison

set(gca,'Xlim',[0 distgp*1e-3+20])
%if length(depth)>1
%  set(gca,'Ylim',[min(depth) max(depth)])
%end

%plot the extrapolated data, '*'
%plot3(zeros(ndep-1,1),depth(2:ndep),shpropp(2:ndep),'*')
%plot3(zeros(ndep-1,1),depth(2:ndep),shpropp(2:ndep))
%plot3([distgp*1e-3*ones(ndep-1,1)],depth(2:ndep),shpropp(2:ndep),'*')
%plot3([distgp*1e-3*ones(ndep,1)],[depth],[shpropp],':')
plot3(zeros(ndep,1),[depth],[shpropp],'-')

plot3([distgp*1e-3*ones(ndep,1)],[depth],[shpropp],'-')

plot3([distgp*1e-3*ones(ndep,1)],[depth],[ppropp],':')

xlabel('  shallow    -  distance(km) -    deep')
hdl=get(gca,'Xlabel');
set(hdl,'Rotation',15,'HorizontalAlignment','center')
ylabel('pressure (db)')
zlabel([pname ' (' punit ') (/10 for dynh)'])

title(sprintf([method ' extrapolation pair %i' ...
    ' lon: %3.2f lat:%3.2f'],ipair, lon(1),lat(1)))
%legend('o','data','*','extrapolation','+','pair data',...
%  ':','projection')

if 0
  hpop3 = uicontrol('style', 'push', 'Position', [460 360 100 30], ...
    'string', 'PRINT', ...
    'ForeGroundColor', 'k', 'call', 'delete(hpop3);print;');
  delete(hpop3);
end
ppause


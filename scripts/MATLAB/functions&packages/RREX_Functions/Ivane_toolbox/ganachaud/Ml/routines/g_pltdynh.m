function g_pltdynh(fig,ipair,Pres,gvelp,s_dynh,maxds,d_dynh,maxdd,...
strt,extrapolated_temp,isdeep,Slat,Slon)
%KEY: plot pair data, 
% SYNOPSIS : g_pltpair1(fig,ipair,Pres,gvelp,s_dynh,maxds,d_dynh,maxdd)
% 
% INPUT
%  fig:    figure in which to plot
%  ipair:  pair indice (for title)
%  Pres:   pressure values (in db)
%  gvelp:  geostrophic velocity at that pair
%  s_dynh: dynamic height (vector, zero at surface) for shallow station
%  maxds:  max depth shallow station= Last Common Depth
%  d_dynh: dynamic height (vector, zero at surface) for deep station
%  maxdd:  max depth deep station
%  strt:   string function for the title
%
% DESCRIPTION : 
%
%
% side effects:
%
% author : A.Ganachaud (ganacho@gulf.mit.edu) , Oct 95
%
% CALLER: g_hotpair.m (geovel.m)
% CALLEE: none
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure(fig);

% Pres is taken till the deep station Pres:
  gid   = 1:maxdd; 
% extrapolated indices:
  gidsd = maxds+1:maxdd; 
% last common Pres:
  lcd    = -Pres(maxds); 

subplot(1, 2, 1);
 plot(gvelp(gid), -Pres(gid), gvelp(gid), -Pres(gid), '+');
 grid on;
 ax = axis; 
 hold on; 
 plot([ax(1) ax(2)], [ lcd lcd ])
 title('Velocity'); 
 xlabel(' cm / s ')
 ylabel('Pres (db)');
 tx1 = text(ax(1), lcd, 'LCD', 'VerticalAlignment', 'bottom');
 set(gca, 'fontsize', 8)
 
subplot(1, 2, 2)
if ~isempty(isdeep) & length(maxds+1:maxdd)>1
  ci=[-2:0.1:9.9,10:0.5:40];
  gis=sort([ipair,ipair+1,isdeep]);
  gie=[ipair,ipair+1];
  gie_=[find(gis==ipair),find(gis==(ipair+1))];
  if max(gis)==isdeep
    ishal=ipair;
  else
    ishal=ipair+1;
  end
  ddd=[0;cumsum(sw_dist(Slat(gis),Slon(gis),'km'))];
  [c,h]=contour(ddd(gie_),-Pres(maxds+1:maxdd),...
    extrapolated_temp(maxds+1:maxdd,gie),ci,'r');
  hold on;
  extrapolated_temp(maxds+1:maxdd,ishal)=NaN;
  contour(ddd,-Pres(gid),extrapolated_temp(gid,gis),ci,'b');
  axis([0,ddd(3),-max(Pres(gid)),0])
  set(gca,'xtick',ddd,'ytick',flipud(-Pres(gid)))
  zoom on;grid on;
  if ~isempty(c)
    clabel(c,h)
  end
  title('temp: red=extrapolated')
  ax = axis; 
  plot([ax(1) ax(2)], [ lcd lcd ],'k','linewidth',2)

else %gpan plot
  plot(d_dynh(gid), -Pres(gid), d_dynh(gid), -Pres(gid), 'o');
  hold on;
  plot(s_dynh(gid), -Pres(gid), s_dynh(gid), -Pres(gid), 'x');
  grid on
  plot(s_dynh(gidsd), -Pres(gidsd), s_dynh(gidsd), -Pres(gidsd), '*');
  title('dyn. height uder LCD');
  set(gca, 'YTickLabel', []);
  xlabel('m^2 / s^2')
  ax = [ floor(min([s_dynh(gidsd); d_dynh(gidsd)])) ...
      ceil(max([s_dynh(gidsd); d_dynh(gidsd)])) ax(3:4)];
  if length(ax)==4
    axis(ax)
  end
end
  ylabel('o = data (deep st.), * = guess (shal st.)')

 
 set(gca, 'fontsize', 8)

 suptitle([strt ' PAIR ' int2str(ipair)])

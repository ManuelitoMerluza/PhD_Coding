function cpstair2(win,x,y,xax,xxlim)
% KEY: do a stair plot of x,y (horizontal stairs) above previous plot cpstair1
% USAGE :
% 
% DESCRIPTION : 
%
%
% INPUT: win     window number
%        x,y     field to plot
%        xax     x axis label (not used in the end 
%        xxlim   x axis limits
%
% AUTHOR :  A. Macdonald 
% UPDATES : A.Ganachaud (ganacho@noumea.ird.nc) , 2002
%
% SIDE EFFECTS :
%
% SEE ALSO :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER: general purpose / trans_plot.m
% CALLEE:

%shift graphic down

gcapos=get(win,'position');
gcapos= gcapos -[0 0.02 0 0]; %shifts downward to put title
set(win,'position',gcapos);

%shift title up
httl=get(win,'title');
ttpos=get(httl,'position');
set(httl,'position',[ttpos(1), ttpos(2)*2,0])

ylim=get(gca,'ylim');
xlim=get(gca,'xlim');
set(win,'xlim',[-max(abs(xlim)),max(abs(xlim))])

ax2=axes('position',gcapos,'box','off','xaxislocation','top',...
  'ylim',ylim,'ydir','reverse','ytick',[],...
  'xlim',xxlim,'Color','none','Xcolor','k',...
  'ycolor','k')
[m,n]=size(x);
[xx,yy]=flstairs(x,abs(y));
pl=line(xx*1e4,yy,'color','k','linewidth',1.5,'parent',ax2);
if 0
  xlim2=get(ax2,'xlim');
  xch=xlabel(xax);
  xlbpos=get(xch,'position');
  set(xch,'position',[xlim2(2)*0.85, xlbpos(2)*0.4,0],...
    'HorizontalAlignment','right','fontangle','italic')
end  

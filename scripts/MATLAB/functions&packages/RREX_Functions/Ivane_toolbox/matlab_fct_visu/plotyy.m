function [ax1, ax2] = plotyy(x,y1,y2,labelx,labely1,labely2,ptitle,lw)
% plot Y1, Y2 as a function of x with y1-axis on the left, Y2-axis on the right
% lw is the linewidth


ax1=gca;
hold on;
pl1=plot(x,y1,'k','LineWidth',lw);


ax2_position=get(ax1,'Position');
ax2=axes('Position',ax2_position,'XAxislocation','bottom','YaxisLocation','right',...
'Color','none','XColor','k','Ycolor','r'); % trace de l'axe y à droite
hold on;
pl2=plot(x,y2,'r','Parent',ax2,'LineWidth',lw);
linkaxes([ax1 ax2],'x'); % on s'assure que ces deux axes sont liés

pos1=[0.13 0.13 0.7 0.6]; % left bottom width height
set(ax1,'Position',pos1); 
set(ax2,'Position',pos1);

xlabel(ax1,labelx,'FontSize',16); % quelques finalisations 
ylabel(ax2,labely2,'FontSize',16);
ylabel(ax1,labely1,'FontSize',16);
title(ptitle,'Interpreter','none');
grid(ax1,'on');
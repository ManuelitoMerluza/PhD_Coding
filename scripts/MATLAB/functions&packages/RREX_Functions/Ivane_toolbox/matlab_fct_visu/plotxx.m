function [ax1, ax2] = plotxx(x1,x2,y,labelx1,labelx2,labely,ptitle,lw)
% plot Y1, Y2 as a function of x with y1-axis on the left, Y2-axis on the right
% lw is the linewidth


ax1=gca;
hold on;
plot(x1,y,'k','LineWidth',lw);

ax2_position=get(ax1,'Position');
ax2=axes('Position',ax2_position,'XAxislocation','top','YaxisLocation','left',...
'Color','none','XColor','r','Ycolor','k'); % trace de l'axe x en haut
hold on;
plot(x2,y,'r','Parent',ax2,'LineWidth',lw);
linkaxes([ax1 ax2],'y'); % on s'assure que ces deux axes sont liés

pos1=[0.13 0.13 0.4 0.8]; % left bottom width height
set(ax1,'Position',pos1); 
set(ax2,'Position',pos1);

xlabel(ax1,labelx1,'FontSize',16); % quelques finalisations 
xlabel(ax2,labelx2,'FontSize',16);
ylabel(ax1,labely,'FontSize',16);
title(ptitle,'Interpreter','none');
grid(ax1,'on');
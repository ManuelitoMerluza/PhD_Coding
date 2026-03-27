function [ax1, ax2, ax3] = plotyyy(x,y1,y2,y3,labelx,labely1,labely2,labely3,ptitle,lw)
% plot Y1, Y2 and Y3 as a function of x with y1-axis on the left, Y2-axis and Y3-axis on the right
% lw is the linewidth
% Y3 can be omitted

ax1=gca;
hold on;
pl1=plot(x,y1,'k','LineWidth',lw);

ax3_position=get(ax1,'Position');
ax3=axes('Position',ax3_position,'XAxislocation','bottom','YaxisLocation','right',...
'Color','none','XColor','w','Ycolor','c'); % troisième axe à droite
hold on;
pl3=plot(x,y3,'c','Parent',ax3,'LineWidth',lw);
set(ax3,'XTick',[ ],'Clipping','off');

ax2_position=get(ax1,'Position');
ax2=axes('Position',ax2_position,'XAxislocation','bottom','YaxisLocation','right',...
'Color','none','XColor','k','Ycolor','r'); % trace de l'axe y à droite
hold on;
pl2=plot(x,y2,'r','Parent',ax2,'LineWidth',lw);
linkaxes([ax1 ax2],'x'); % on s'assure que ces deux axes sont liés

offset=1.15; % et maintenant il faut decaler le troisième axe a vers la droite
pos1=[0.13 0.13 0.6 0.4]; % left bottom width height
set(ax1,'Position',pos1); 
set(ax2,'Position',pos1);
pos3=pos1;
pos3(3)=offset*pos1(3); % off s'applique sur la largeur
set(ax3,'Position',pos3);
limx1=get(ax1,'Xlim');
limx3=get(ax3,'Xlim');
limx3(2)=limx1(1)+offset*(limx1(2)-limx1(1));
set(ax3,'Xlim',limx3);

xlabel(ax1,labelx,'FontSize',16); % quelques finalisations 
ylabel(ax2,labely2,'FontSize',16);
ylabel(ax1,labely1,'FontSize',16);
ylabel(ax3,labely3,'FontSize',16);
title(ptitle,'Interpreter','none');
grid(ax1,'on');

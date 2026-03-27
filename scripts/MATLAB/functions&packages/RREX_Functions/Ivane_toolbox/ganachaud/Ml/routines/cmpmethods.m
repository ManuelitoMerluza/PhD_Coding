load trans_mod_730_852_planefit.mat
Tg(:,1)=Tnga';
Meth{1}='plane fit';

load trans_mod_730_852_zerov.mat 
Tg(:,2)=(Tnga');
Meth{2}='null velocity';

load trans_mod_730_852_slp0.mat     
Tg(:,3)=(Tnga');
Meth{3}='constant velocity';

load trans_mod_730_852_slp1.mat  
Tg(:,4)=(Tnga');
Meth{4}='slope max = 1';

%transport from model geostrophy
Tg(:,5)=sum(Sgst)';
Meth{5}='model geostrophy';

%transport from model velocity
Tm=Tnm-Tekm;

%COMPUTE RMS OF THE DIFFERENCES
%PLANE FIT-SLOPE1
rms(Tg(:,1)-Tg(:,4)) %4.6 Sv
%slope 0 - slope 1
rms(Tg(:,3)-Tg(:,4)) %6   Sv
%PLANE FIT-NULL
rms(Tg(:,1)-Tg(:,2)) %4.25

xx=1:length(Tm);
clf;
pl1=plot(xx,Tg(:,1),'rs-','markersize',4,'linewidth',.2);
grid on;hold on;ylabel('Sv');axis([1, max(xx),-15,25])

pl3=plot(xx,Tg(:,3),'gd-','markersize',4,'linewidth',.2);
pl4=plot(xx,Tg(:,4),'mo-','markersize',4,'linewidth',.2);

pl2=plot(xx,Tg(:,2),'bx-','markersize',4,'linewidth',.2);

%pl6=plot(xx,Tm,'c-','markersize',4,'linewidth',.1);
pl5=plot(Tg(:,5),'k-','linewidth',1);

set(gca,'xtick',0:10:123,'xlim',[0 123])
month=['J';'F';'M';'A';'M';'J';'J';'A'; ...
  'S';'O';'N';'D'];
set(gca,'xticklabel','')
yl=get(gca,'ylim');
htx=text(5:10:123,(yl(1)-diff(yl)/70)*ones(1,12),month,'verticalalignment','cap');

pl=[pl5;pl1;pl3;pl4;pl2];%;pl6];
legend(pl,Meth{5},Meth{1},Meth{3},Meth{4},Meth{2}) %,'Model v - Ekman')
%print -deps /data4/ganacho/SW25/FIGURES/fig_thesis_115.eps

title('Bottom Wedge Experiments')
signature
set(gcf,'papero','land');set(gcf, 'Paperposition', [1 1 8 6])
print -depsc /data4/ganacho/SW25/FIGURES/fig_talk_001.epsc


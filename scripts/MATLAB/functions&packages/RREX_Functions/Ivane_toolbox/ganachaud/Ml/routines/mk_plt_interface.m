function mk_plt_interface(lipres,Slat,Slon,pres,Botp,gsecs,boxi,isb)
% KEY: script to plot interfaces
% USAGE :
% 
%
%
%
% DESCRIPTION : 
%
%
% INPUT: 
%
%
% OUTPUT:
%
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , Jan 98
%
% SIDE EFFECTS :
%
% SEE ALSO :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER:
% CALLEE: mk_set_layprop
Nstat=length(Slon);
Npair=Nstat-1;

   figure;clf
   np=length(pres);
   distg = 1e3*sw_dist(Slat,Slon,'km');
   distg(distg==0)=0.001;
   distt = cumsum(distg);
   tdist = 1e-3 * [0; distt];          	% linear distance between stations
   dpt = 1e-3 * (0.5*distg(1) + [1; cumsum(0.5*...
     (distg(1:Nstat-2)+distg(2:Nstat-1)))]);	
      % linear distance between pairs  

   %dpt=.5*(Slon(1:Nstat-1)+Slon(2:Nstat));
   %tdist=Slon;
   ns = Nstat;
   d1 = min(-pres);
   
   isstat=0; %pair properties
   hdist=dpt;
   statpairstr='Pair';

   maxy=min(8000,500*ceil(max(Botp)/500));
   fill([tdist(1); tdist(ns); tdist(ns:-1:1)], ...
     [-abs(maxy); -abs(maxy);  -Botp(ns:-1:1)], .95*[1 1 1]);
   hold on
   pl=plot(dpt,-lipres{isb});
   put_sigmasurf(dpt,fix(2*Npair/3),lipres{isb}','black',6);
   set(gca,'Xlim', [tdist(1) tdist(ns)],'ylim',[-maxy 0]);
   set(gca,'TickDir','out')
   gca1=gca;
   %Put a second axes at the top
   ax2=axes('position',get(gca1,'Position'),...
     'xaxislocation','top','yaxislocation','right',...
     'color','none','xcolor','k','ycolor','k',...
     'TickDir','out','TickLength',.5*[0.01 0.025],...
     'Xlim', [tdist(1) tdist(ns)],'Xtick',tdist,...
     'ylim',[-abs(maxy),0],'Ytick', flipud(-pres),...
     'XTickLabel','','YTickLabel','');
   str=sprintf('%3i',(1:length(tdist)));
   str=reshape(str,3,length(tdist))';
   for il=2:length(tdist)
     if (il/5)~=round(il/5)
       str(il,:)='   ';
     end
   end
   set(gca,'XTickLabel',str,'FontSize',6)
   ylabel('standard depths')
   axes(gca1);set(gca1,'box','on')
   xlabel('Linear distance (km)');
   title(sprintf('Layer Interfaces, section %s, model %s',...
     gsecs.name{isb},boxi.modelid))
   tp=get(get(gca,'title'),'position');
   yl=get(gca,'ylim');dy=abs(diff(yl));
   set(get(gca,'title'),'position',[tp(1),tp(2)*2,tp(3)])

   land;setlargefig;
   s=input('print ? ','s');
   
   if s & s(1)=='y'
     pg;
   end
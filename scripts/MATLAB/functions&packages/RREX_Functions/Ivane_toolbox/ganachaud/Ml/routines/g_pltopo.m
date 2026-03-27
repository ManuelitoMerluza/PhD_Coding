function g_pltopo(Nstat,ds,Pres,Maxd,Botd)
%key: plot the topography and contour of the velocity
%synopsis : g_pltopo(Nstat,ds,Pres,Maxd,Botd)
% 
%  ds is the desired X axis
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

    ns=Nstat;d1=min(-100*ceil(Botd/100));
    if size(ds,1)==1
      ds=ds';
      end
    fill([ds(1);ds(ns);ds(ns:-1:1)], ...
    	[d1;d1;-Botd(ns:-1:1)],[.9, .9, .9]);hold on;
    set(gca,'FontSize',8)
    plot(ds,-Pres(Maxd),'.',ds,-Pres(Maxd),'-');grid on
    %title('Deepest measurement - stars are large depth differences')
    
    %set yticks at the standart depths
    % and put only some labels
    set(gca,'Ytick',flipud(-Pres),'Tickdir','out')
    iynlab=1+find(diff(Pres)<((Pres(length(Pres))-Pres(1))/50));
    iynlab(find(iynlab>=length(Pres)))=[];
    ylab = [];
    for ii = 1:length(Pres)
      ylab = str2mat(ylab, sprintf('%5i', round(Pres(ii))));
    end
    ylab = ylab(2:length(ylab), :);
    for ii = 1:length(iynlab)
      ylab(iynlab(ii), :) = '     ';
    end

    
    set(gca,'Yticklabel',flipud(ylab),'Xlim',[ds(1) ds(ns)])
    set(gca,'ylim',[d1 0])
    %xlabel('Linear distance (km)');
    ylabel('Standart Depth')
    drawnow
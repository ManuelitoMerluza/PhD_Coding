function plot_thetaS(nbstat,wmonum,pres,temp,psal,oxyl,tpot)

plotpath = 'resu/';
map=jet(nbstat);
% Diagramme T/S, theta/S, theta/oxyl
    h2=figure;
    orient landscape
    set(gca,'Fontsize',18);
    hold on
    for iprof=1:nbstat
      plot(psal(iprof,:),temp(iprof,:),'color',map(iprof,:),'marker','.','linewidth',2);
    end
    vxmax=max(ceil(psal(:)*100))/100;
    vxmin=min(floor(psal(:)*100))/100;
    vymax=max(ceil(temp(:)*100))/100;
    vymin=min(floor(temp(:)*100))/100;
    set(gca,'xlim',[vxmin vxmax],'ylim',[vymin vymax]);
    ylabel('Temperature')
    xlabel('Salinity')
    grid
    title([wmonum ' T/S']);
    eval(['print -depsc2 ' plotpath wmonum '_TS_raw.eps']);
 
 h3=figure;
    orient landscape
    set(gca,'Fontsize',18);
    hold on
    for iprof=1:nbstat
      plot(psal(iprof,:),tpot(iprof,:),'color',map(iprof,:),'marker','.','linewidth',2);
    end
    ctpot=[floor(min(tpot(:)))-1:0.1:ceil(max(tpot(:)))+1]';
    cpsal=[floor(10*min(psal(:)))/10-0.1:0.1:ceil(max(psal(:))*10)/10+0.1]';
    [tabct,tabcp]=meshgrid(ctpot,cpsal);
    [null,csig]=swstat90(tabcp,tabct,0);
    [c,h]=contour(tabcp,tabct,csig,[20:0.5:35],'k');
    clabel(c,h);
    ylabel('Potential Temp. (ref. to 0db)')
    xlabel('Salinity')
    vxmax=max(ceil(psal(:)*100))/100;
    vxmin=min(floor(psal(:)*100))/100;
    vymax=max(ceil(tpot(:)*100))/100;
    vymin=min(floor(tpot(:)*100))/100;
    set(gca,'xlim',[vxmin vxmax],'ylim',[vymin vymax]);

    grid
    title([ wmonum ' theta/S']);
    eval(['print -depsc2 ' plotpath wmonum '_thetaS.eps']);
    
    iok = isfinite(oxyl);
    if iok
 
        h5=figure;
        orient landscape
        set(gca,'Fontsize',18);
        hold on

        for iprof=1:nbstat
          plot(oxyl(iprof,:),tpot(iprof,:),'color',map(iprof,:),'marker','.','linewidth',2);
        end
        ctpot=[floor(min(tpot(:)))-1:0.1:ceil(max(tpot(:)))+1]';
        coxyl=[min(oxyl(:))-10:10:max(oxyl(:))+10]';
        [tabct,tabcp]=meshgrid(ctpot,coxyl);
        ylabel('Potential Temp. (ref. to 0db)')
        xlabel('Oxygen')
        vxmax=max(ceil(oxyl(:)*100))/100;
        vxmin=min(floor(oxyl(:)*100))/100;
        vymax=max(ceil(tpot(:)*100))/100;
        vymin=min(floor(tpot(:)*100))/100;
        set(gca,'xlim',[vxmin vxmax],'ylim',[vymin vymax]);
        %set(gca,'xlim',[coxyl(1) coxyl(end)],'ylim',[ctpot(1) ctpot(end)]);
        grid
        title([ wmonum ' theta/O2 ']);
        eval(['print -depsc2 ' plotpath wmonum '_thetaoxy.eps']); 
    end
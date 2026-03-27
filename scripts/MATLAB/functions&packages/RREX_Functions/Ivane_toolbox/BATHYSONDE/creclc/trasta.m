   
function plot_dbrut(plotpath,wmonum,pres,doxy,psat,temp,psal,sig0,tpot,cycnum,lon)

    map=jet(length(cycnum));

    figure; 
    set(gca,'fontsize',18)
    grid
    hold on
    
    vymin = 0;
    vymax= 10*max(ceil(pres(:)/10));
 
    for ii=1:length(lon)
        h=plot(doxy(ii,:),pres(ii,:),'-');
        set(h,'color',map(ii,:))
        set(gca,'ydir','reverse')
        set(gca,'ylim',[vymin vymax]);

 %       set(gca,'ydir','reverse') 
    end
    title(['WMO ' wmonum ' - DOXY']);
    xlabel('DOXY in mumol/kg')
    ylabel('PRES (dbar)')
    eval(['print -depsc2 ' plotpath wmonum '_PRES_DOXY.eps']);

    figure; 
    set(gca,'fontsize',18)
    grid
    hold on
    for ii=1:length(lon)
        h=plot(temp(ii,:),pres(ii,:),'-');
        set(h,'color',map(ii,:))
        set(gca,'ydir','reverse') 
        set(gca,'ylim',[vymin vymax]);
    end
    title(['WMO ' wmonum ' - TEMP']);
    xlabel('TEMP (deg. Celsius)')
    ylabel('PRES (dbar)')
    eval(['print -depsc2 ' plotpath wmonum '_PRES_TEMP.eps']);

    figure ;
    set(gca,'fontsize',18)
    grid
    hold on
    for ii=1:length(lon)
        h=plot(psal(ii,:),pres(ii,:),'-');
        set(h,'color',map(ii,:))
        set(gca,'ydir','reverse') 
        set(gca,'ylim',[vymin vymax]);
    end
    title(['WMO ' wmonum ' - PSAL']);
    xlabel('PSAL')
    ylabel('PRES (dbar)')
    eval(['print -depsc2 ' plotpath  wmonum '_psal.eps']);

    figure; 
    set(gca,'fontsize',18)
    grid
    hold on
    for ii=1:length(lon)
        h=plot(sig0(ii,:),pres(ii,:),'-');
        set(h,'color',map(ii,:))
        set(gca,'ydir','reverse') 
        set(gca,'ylim',[vymin vymax]);
        
    end
    title(['WMO ' wmonum ' - SIG0']);
    xlabel('SIG0')
    ylabel('PRES (dbar)')
    eval(['print -depsc2 ' plotpath  wmonum '_PRES_SIG0.eps']);
  
    figure ;
    set(gca,'fontsize',18)
    grid
    hold on
    for ii=1:length(lon)
        h=plot(tpot(ii,:),pres(ii,:),'-');
        set(h,'color',map(ii,:))
        set(gca,'ydir','reverse') 
        set(gca,'ylim',[vymin vymax]);
    end
    title(['WMO ' wmonum ' - TPOT']);
    xlabel('TPOT (deg. Celsius)')
    ylabel('PRES (dbar)')
    eval(['print -depsc2 ' plotpath  wmonum '_PRES_TPOT.eps']);
 
    if length(cycnum)>2
        % Plot saturation aux 3 premiers niveaux

        cycnum2=cycnum;
        icz=find(cycnum==0);
        if length(icz) == 2
            cycnum2(icz(1))=-1;
        end

        map=jet(4);
        figure
        subplot(2,1,1),
        set(gca,'fontsize',18)
        grid
        hold on
 % revoir
        psat=psat';
        for ii=1:4
            h=plot(cycnum2,psat(ii,:),'k-*')
            set(h,'color',map(ii,:))
        end
        ylabel('O2, % saturation');
        xlabel('Cycle number');
        set(gca,'xlim',[-1 max(cycnum2)+1]);
        subplot(2,1,2),
        set(gca,'fontsize',18)
        grid
        hold on
        % revoir
        pres = pres';
        for ii=1:4
            h=plot(cycnum2,pres(ii,:),'k-*');
            set(gca,'ydir','reverse')
            set(h,'color',map(ii,:))
        end
        ylabel('PRES (dbar)');
        xlabel('Cycle number');
        set(gca,'xlim',[-1 max(cycnum2)+1]);

        hs=suptitle(['WMO ' wmonum ' - O2sat']);
        set(hs,'fontsize',18)
        eval(['print -depsc2 ' plotpath '/' wmonum '_O2sat.eps']);
  
    end
    


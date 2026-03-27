function plot_sections_mld(titre,icas,pres,temp,psal,oxyl,tpot,sig0,statnum,juld,tabval,nomval,valini,nomvalini,coef,pas)

   plotpath = 'resu/';
   vmin=min(floor(tabval(:)*coef)/coef);
   vmax=max(ceil(tabval(:)*coef)/coef);
   tabcont=[vmin:pas:vmax];
   
 % Profondeur couche de melange
   clear tabmld
   critere='dsig&dt';critval=[0.03 0.2];
   for iprf=1:length(statnum)
       [mlde,mlpt,mlps,mlpd]=calmld_val(sig0(iprf,:),pres(iprf,:),tpot(iprf,:),psal(iprf,:),critere,critval);
       tabmld(iprf)=mlde;
   end
    
[hf] = pcolor_argodata(statnum,pres',tabval',nomval,'interp');
    
    plot(statnum,tabmld,'w-','linewidth',2);

    orient landscape
    set(gca,'fontsize',18)
    
    tabtime=(juld-juld(1))*ones(1,size(pres,2));

    set(gca,'ydir','reverse');
    colorbar
    caxis([vmin vmax]);
    
    juld=double(juld);
    vtick=get(gca,'xtick');
    vticklabel=datestr(datenum(1950,1,1)+vtick+juld(1),12);
    set(gca,'xtick',vtick,'xticklabel',vticklabel);
        
    set(gca,'xtick',vtick,'xticklabel',vticklabel);
    title([titre ' ' nomval]);
    ylabel('Pressure (db)')
    xlabel('Date')
  
    eval(['print -depsc2 ' plotpath titre '_' nomval '_noninterp' '.eps'])
               
    
    
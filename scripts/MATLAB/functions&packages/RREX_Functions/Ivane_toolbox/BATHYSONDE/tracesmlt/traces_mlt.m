
ficmlt=input('Nom du fichier Multistation (PRES ou DEPH) ? ','s');

nc= netcdf.open(ficmlt,'NOWRITE');

codes_paramp = ncread(ficmlt,'STATION_PARAMETER')';
[nparmlt,~] = size(codes_paramp);

ioxy = false;
paramoxy = 'OXYL';
for ii = 1:nparmlt
   if strcmp(codes_paramp(ii,:),'OXYL') 
       ioxy = true;
       paramoxy='OXYL';
   end
   if strcmp(codes_paramp(ii,:),'OXYK')
       ioxy = true;
       paramoxy='OXYK';
   end
end
if strfind(ficmlt,'PRES')
    if ioxy
     [lat,lon,juld,statnum,direction,pres,temp,psal,brv2,tpot,oxy,sig0] = read_nc_HYDRO_mlt(nc,'PRES','TEMP','PSAL','BRV2','TPOT',paramoxy,'SIG0');
       else
     [lat,lon,juld,statnum,direction,pres,temp,psal,brv2,tpot,sig0] = read_nc_HYDRO_mlt(nc,'PRES','TEMP','PSAL','BRV2','TPOT','SIG0');
    end
else
    if ioxy
     [lat,lon,juld,statnum,direction,pres,temp,psal,brv2,tpot,oxy,sig0] = read_nc_HYDRO_mlt(nc,'DEPH','TEMP','PSAL','BRV2','TPOT',paramoxy,'SIG0');
       else
     [lat,lon,juld,statnum,direction,pres,temp,psal,brv2,tpot,sig0] = read_nc_HYDRO_mlt(nc,'DEPH','TEMP','PSAL','BRV2','TPOT','SIG0');
    end
end

tabparam = ['PSAL';'SIG0';'TPOT';paramoxy];
[nparam,~] = size(tabparam);

fillval = -9999.;

pres = pres';
temp = temp';
psal = psal';
tpot = tpot';
sig0 = sig0';
brv2 = brv2';

[nbprof,nblevel]=size(pres);
if ioxy
      oxy=oxy';
else
      oxy = NaN*ones(nbprof,nblevel);
end

for i=1:nbprof
   yy=find(brv2(i,:) == fillval);
   brv2(i,yy)=NaN;
end

for i=1:nbprof
     it=find(pres(i,:) == fillval);
     pres(i,it) =  NaN;
end
for i=1:nbprof
     it=find(tpot(i,:) == fillval);
     tpot(i,it) =  NaN;
     psal(i,it) =  NaN;
     sig0(i,it) =  NaN;
     temp(i,it) =  NaN;
end

plotpath = 'resu/';
itiret=strfind(ficmlt,'_');
ficmlt(itiret:itiret)= '-';
plot_title = [ficmlt(1:end-3) '  '];

figure
plot(tpot,-pres)
title([plot_title ' TPOT']) 
eval(['print -depsc2 ' [plotpath ficmlt(1:end-3) '_TPOT.eps']]);

figure
plot(psal,-pres)
title([plot_title ' PSAL']) 
eval(['print -depsc2 ' [plotpath ficmlt(1:end-3) '_PSAL.eps']]);

figure
plot(brv2,-pres)
title([plot_title ' BRV2']) 
eval(['print -depsc2 ' [plotpath ficmlt(1:end-3) '_BRV2.eps']]);

figure
plot(sig0,-pres)
title([plot_title ' SIG0'])
eval(['print -depsc2 ' [plotpath ficmlt(1:end-3) '_SIG0.eps']]);

for i=1:nbprof
     it=find(oxy(i,:) == -9999);
     oxy(i,it) =  NaN;
end
figure
plot(oxy,-pres)
title([plot_title ' ' paramoxy]) 
eval(['print -depsc2 ' [plotpath ficmlt(1:end-3) '_oxy.eps']]);

nbstat= length(statnum);
plot_thetaS(nbstat,ficmlt(1:end-3),pres,temp,psal,oxy,tpot)

tpas      = [0.05,0.1,0.5,0.1];
tcoef     = [10,10,1,10];
    
    for icas=1:4
        pas = tpas (icas);
        coef = tcoef(icas);
        if icas == 1 %PSAL
          tabval=psal;
          nomval=tabparam(icas,:);
          valini=psal;
          nomvalini='PSAL';
        elseif icas == 2 %SIG0
          tabval=sig0;
          nomval=tabparam(icas,:);
        elseif icas == 3 %TPOT
            tabval=tpot;
            nomval=tabparam(icas,:);
            valini=temp;
            nomvalini='TEMP';
        elseif icas == 4 %oxy      
            tabval=oxy;
            nomval=tabparam(icas,:);
            valini=oxy;
            nomvalini='oxy';
        end 
    
        plot_sections_mld(ficmlt(1:end-3),icas,pres,temp,psal,oxy,tpot,sig0,juld,statnum,tabval,nomval,valini,nomvalini,coef,pas)
    end
   
% carte 1 (positions) 
% -------------------
    map=jet(nbstat);
    zone_visu=[floor(min(lat))-5 ceil(max(lat))+5  floor(min(lon))-5 ceil(max(lon))+5];
    reso='LR';proj='mercator';
    [hf,ha]=fct_pltmap(zone_visu,reso,proj);
    
    for ii=2:length(lon)-1
      m_plot(lon(ii),lat(ii),'color',map(ii,:),'marker','o','markerfacecolor',map(ii,:),'markersize',5)
    end
    ii=1;
    hl(1)=m_plot(lon(ii),lat(ii),'color',map(ii,:),'marker','d','markerfacecolor',map(ii,:),'markersize',8);
    ii=length(lon);
    hl(2)=m_plot(lon(ii),lat(ii),'color',map(ii,:),'marker','s','markerfacecolor',map(ii,:),'markersize',8);
    
    xlabel('Longitude')
    ylabel('Latitude')
    title(plot_title);
    
    eval(['print -depsc2 ' [plotpath ficmlt(1:end-3) '_pos.eps']]);
    
    % carte 2 (positions)
    % -------------------
    
    zone_visu=[floor(min(lat))-20 ceil(max(lat))+20  floor(min(lon))-30 ceil(max(lon))+30];
    reso='LR';proj='mercator';
    [hf,ha]=fct_pltmap(zone_visu,reso,proj);
    %h=m_plot(lon,lat,'k-')
    [elev,lonbath,latbath]=m_tbase([floor(min(lon))-30 ceil(max(lon))+30 floor(min(lat))-20 ceil(max(lat))+20]);
    m_contour(lonbath,latbath,elev,(-4000:1000:0),'color',[0.5 0.5 0.5])
    for ii=2:length(lon)-1
      m_plot(lon(ii),lat(ii),'color',map(ii,:),'marker','o','markerfacecolor',map(ii,:),'markersize',5)
    end
    ii=1;
    hl(1)=m_plot(lon(ii),lat(ii),'color',map(ii,:),'marker','d','markerfacecolor',map(ii,:),'markersize',8);
    ii=length(lon);
    hl(2)=m_plot(lon(ii),lat(ii),'color',map(ii,:),'marker','s','markerfacecolor',map(ii,:),'markersize',8);
    
    xlabel('Longitude')
    ylabel('Latitude')
    title(plot_title);
   
    eval(['print -depsc2 ' [plotpath ficmlt(1:end-3) '_pos2.eps']]);

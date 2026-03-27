
ficmlt_ann = input('Nom du fichier Multistation  ? Taper uniquement l''année ','s');
ficmlt = ['Hydroann-' ficmlt_ann '-2014.nc']
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

    if ioxy
     [lat,lon,juld,statnum,direction,pres,temp,psal,oxy] = read_nc_HYDRO_mlt(nc,'DEPH','TEMP','PSAL',paramoxy);
       else
     [lat,lon,juld,statnum,direction,pres,temp,psal] = read_nc_HYDRO_mlt(nc,'DEPH','TEMP','PSAL');
    end


tabparam = ['PSAL';paramoxy];
[nparam,~] = size(tabparam);

fillval = -9999.;

pres = pres';
temp = temp';
psal = psal';

[nbprof,nblevel]=size(pres);
if ioxy
      oxy=oxy';
else
      oxy = NaN*ones(nbprof,nblevel);
end



for i=1:nbprof
     it=find(pres(i,:) == fillval);
     pres(i,it) =  NaN;
end


plotpath = 'resu/';
itiret=strfind(ficmlt,'_');
ficmlt(itiret:itiret)= '-';
plot_title = [ficmlt(1:end-3) '  '];

figure
plot(psal,-pres)
title([plot_title ' PSAL']) 
eval(['print -depsc2 ' [plotpath ficmlt(1:end-3) '_PSAL.eps']]);


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

tpas      = [0.05,0.1];
tcoef     = [10,10];
    
    for icas=1:2
        pas = tpas (icas);
        coef = tcoef(icas);
        if icas == 1 %PSAL
          tabval=psal;
          nomval=tabparam(icas,:);
          valini=psal;
          nomvalini='PSAL';
        elseif icas == 2 %oxy      
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

% function
% KEY: computes geostrophic transport after geovel output
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , May 97
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%ISOPYCNALS
ca
sigint= [22.00 26.40 26.80 27.10 27.30 27.50 27.70, ...
    36.87 36.94 36.98 37.02, ...
    45.81 45.85 45.87 45.895 45.91 45.925 48.00]';
sigipref=[ 1 1 1 1 1 1 1, ...
    2 2 2 2,...
    3 3 3 3 3 3 3]';
pref=[0 2000 4000]; %DB (Meters for the model case)

%REFERENCE LEVELS sigid
sigid=[12 12 8]; %AS IN ALISON'S 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
p_ref_lcd=0;
p_load=1;
Meth={'slope0';'slope0';'slope1';'pfit';'polyfit';'hpolyfit'};
Marker={'b-o' ;'r-^'   ;'g-s'   ;'m-x' ;'c-d'    ;'k-h'};

Secid='a48n'; isec=3;
Secid='a24n'; isec=1;
Secid='flst'; isec=1;
Secid='a36n'; isec=2;

datadir=['/data1/ganacho/Hdata/' Secid '/Geovelm/'];
%datadir=['/data1/ganacho/Hdata/' 'a24n' '/Geovelm/']; %for flst
for imethod=1:6
  if imethod==1
    p_trig=-1;   %-1 for zero velocity (to use with slope0 only)
  else
    p_trig=1;
  end
  if p_load
    secid=[Secid Meth{imethod}];
    getpdat
    sd=sw_dist(Slat,Slon,'km');
    sdd=[0;cumsum(sd)];
    sdp=0.5*(sdd(1:Nstat-1)+sdd(2:Nstat));
  end

  %    FIND THE REFERENCE LEVEL DEPTH
  [rlpres]=find_sig_interface(sigint(sigid(isec)),1, ...
    pref(sigipref(sigid(isec))),ptemp,psali,Pres,Maxdp(:,1),Pbotp);
  
  if p_ref_lcd
    disp('SET REF. TO THE LAST COMMON DEPTH IF IT WAS UNDERNEATH')
    ishdp = [1:Nstat-1; 2:Nstat];isw = find( diff(Botp) < 0 ); 
    ishdp([1 2],isw) = ishdp([2 1],isw);
    limitdep=Botp(ishdp(1,:));
    gis_at_bot=find(rlpres>limitdep);
    rlpres(gis_at_bot)=limitdep(gis_at_bot);
  else
    disp('REF TO DEEPEST STATION')
  end
  %GET REFERENCE LEVEL VELOCITY VELOCITY
  gvel_rl = getsigprop(Pres(:,1),gvel,Pbotp,rlpres);

  % GET RELATIVE VELOCITY
  Ndep=size(gvel,1);
  gvel_rel=gvel-ones(Ndep,1)*(gvel_rl');
  gidry=find(isnan(gvel));
  gvel(gidry)=zeros(size(gidry));
  gvel_rel(gidry)=zeros(size(gidry));
 
  A0=mk_A0(p_trig,MPres,Pres,Botp,Slat,Slon,ptemp,Maxd,Maxdp,Npair);
  Ci=ones(size(ptemp));   %ro/1e3;
  Ci(gidry)=zeros(size(gidry));
  %gvelint=(1e3*sd').*trapz(Pres, gvel_rel/100)/1e6; %(in Sv)
  geotrans=A0.*Ci.*gvel_rel/100/1e6;
  gvelint=sum(geotrans);
  %integrate from East end
  tottran{imethod}=[fliplr(cumsum(fliplr(gvelint)))];
  %tottran=cumsum(gvelint);
  Tnga{imethod}=sum(gvelint)
  %
  if imethod==1
    %plots bottom topography
    clf;
    a1=axes('position',[.13 .7 .775 .25 ],'box','on');
    plot(sdp,-rlpres,'-.');hold on
    ns=Nstat;ds=[0;cumsum(sw_dist(Slat,Slon,'km'))];
    dp=0.5*(ds(1:ns-1)+ds(2:ns));d1=min(-100*ceil(Botp/100));
    fill([ds(1);ds(ns);ds(ns:-1:1)], ...
      [d1;d1;-Botp(ns:-1:1)],[.8, .8, .8]);
    grid on;axis([0 max(ds) d1 0 ]);set(gca,'xticklabel','');
    title([Secid(1:4)])
    a2=axes('position',[.13 .11 .775 .55 ],'box','on');hold on
    grid on
  end
  pl(imethod)=plot(dp,tottran{imethod},Marker{imethod},'markersize',3);
end %imethod  

set(gca,'xlim',[0 max(ds)])
legend(pl,'null velocity','constant vel','max slope = 1','plane fit',...
  'polynomial','horizontal')
title('');ylabel('Sv');xlabel('distance (km)')
setlargefig

if 0
%FOR REFERENCE AT THE BOTTOM
    %print -deps /data4/ganacho/SW25/FIGURES/fig_thesis_116.eps %a36N%
    %print -deps /data4/ganacho/SW25/FIGURES/fig_thesis_124.eps %a48N%
    %print -deps /data4/ganacho/SW25/FIGURES/fig_thesis_125.eps %a24N%
    %print -deps /data4/ganacho/SW25/FIGURES/fig_thesis_126.eps %flst%
    
    %FOR RERERENCE AT LCD
    %print -deps /data4/ganacho/SW25/FIGURES/fig_thesis_127.eps %a24N%
    %print -deps /data4/ganacho/SW25/FIGURES/fig_thesis_128.eps %flst%
    %print -deps /data4/ganacho/SW25/FIGURES/fig_thesis_129.eps %a36N%
    %print -deps /data4/ganacho/SW25/FIGURES/fig_thesis_130.eps %a48N%
     
  
  %title([secid(1:4) ' relative transport'])
  %print -depsc /data4/ganacho/SW25/FIGURES/fig_talk_002.epsc

  surf(Plon,-Pres,gvel_rel)
  set(gca,'ylim',[-4000 0])
  set(gca,'zlim',[-200 200])
  xlabel('longitude');ylabel('depth');zlabel('velocity');
  title([secid ' geostrophic velocity'])
  signature
  set(gcf,'papero','land')
  set(gcf, 'Paperposition', [1 1 8 6])
end  

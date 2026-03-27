%function Ekmant
% KEY: computes Ekman transport across a section
% USAGE :
% 
%
%
%
% DESCRIPTION : 
%   Transport is positive TO THE RIGHT of the section
%   Watch out for sections going southward or westward
%   set the parameter p_reverse to one to have the right sign
%
% INPUT:
%  See parameters at the beginning of the script
%  (A section plus the NMC fields)
%
% OUTPUT:
%  pdist: distance between pairs of grid points of integration
%  Tek(ip,it): Ekman transport, pair ip, time it
%   ip is a pair of grid points (not of stations)
%  Tektot(it): total Ekman transport at time it
%  save in <OPdirek> Ekmt_<secid>_<yrstart>_<ntot>
%
%
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , Sep 97
%
% SIDE EFFECTS :
%
% SEE ALSO : ekmanT
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER:
% CALLEE:

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PARAMETERS

if 0
  clear all
  p_nmc=0;
  p_reverse=0;
  latshift=.2%LATITUDE SHIFT TO AVOID WIGGLELING IF LATITUDE NEAR n.5
  secid= 'a24n';
  datadir= '/data1/ganacho/Hdata/';
  if p_nmc
    OPdirek='/data1/ganacho/Ekman/NMC/'; %OUTPUT DIRECTORY
    yrstart=81;  %STARTING DAY 
    curhalfday=1;
    ntot=365*2*2; %TOTAL NUMBER OF POINTS (EVERY 6HR)
    xgridoffset=0;
    ygridoffset=0;
  else
    ntot=1;
    xgridoffset=.5;
    ygridoffset=.5;
  end
end

  clear Tek TauE TauN Taux Tauxm Tauxx Tauy Tauym Tauyy

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CODE
D2R=pi/180;
%LOAD SECTION INFO
  disp([ 'SECTION ' secid ' Ekman transport ...'])
  eval(['load ' datadir secid '_stat.hdr.mat' ])
  Slat=Slat+latshift;
  Slon=long_cont(Slon+lonshift);

if any(Slon>180)
  p_cross_zerodate=1;
else 
  p_cross_zerodate=0;
end

if (Slon(1)>Slon(Nstat))&((Slon(1)-Slon(Nstat))>abs(Slat(1)-Slat(Nstat)))
  disp( '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')
  disp( ' Section not positive to West  !')
  disp( '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')
elseif (Slat(1)>Slat(Nstat))&((Slat(1)-Slat(Nstat))>abs(Slon(1)-Slon(Nstat)))
  disp( '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')
  disp( ' Section not positive to North  !')
  disp( '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')
end

if p_nmc
  %NMC GRID
  dx=1;dy=1;
  Nx=360;Ny=160;
  X=0.5:dx:359.5;
  Y=-79.5:dy:79.5;
  glon=0:dx:359; %CORRESPONDS TO XU
  glat=-80:dx:79;%CORRESPONDS TO YV
  glat=glat(2:Ny);%because glat(1) is lost after interpolation
  
  %Tau MUST BE IN N/m2 = 10 dyn/cm2 (Gill, Appendix 1)
  Taux=randn(length(glon), length(glat));
  Tauy=randn(length(glon), length(glat));
  Tauxm=zeros(Nx,Ny-1);
  Tauym=zeros(Nx,Ny-1);
  yr=yrstart;
end

nit=0;
for itime=1:ntot
  nit=nit+1;
  if p_nmc
    if curhalfday>(365*2) | ~exist('fidu')
      curhalfday=1;
      if exist('fidu')
	fclose(fidu);fclose(fidv);
	yr=yr+1;
      end
      disp(sprintf('OPENNING YEAR %i',yr))
      fidu=fopen(sprintf('/data40/temp/R_ustr%i',yr),'r');
      fidv=fopen(sprintf('/data40/temp/R_vstr%i',yr),'r');
    end
    ustr=fread(fidu,[Nx,Ny],'float');
    %PUT STRESS ON COMMON GRID
    Taux=0.5*(ustr(:,1:Ny-1)+ustr(:,2:160));
    vstr=fread(fidv,[Nx,Ny],'float');
    Tauy=0.5*(vstr([Nx,1:Nx-1],2:Ny)+vstr(1:Nx,2:Ny));
    Tauxm=Tauxm+Taux;
    Tauym=Tauym+Tauy;
  else %if p_nmc
    fname='/data37/king/ANAL_92/NMC_3-149';
    nskip=0;
    [glon,glat,Taux]=read_gridded(fname,nskip);
    nskip=1;
    [ylon,ylat,Tauy]=read_gridded(fname,nskip);
    if any(glon~=ylon)|any(glat~=ylat)
      error('not the same grid !')
    end
    if p_cross_zerodate
      gii=find(glon<0);
      glon(gii)=360+glon(gii);
    end
    dx=diff(glon);
    dx=dx(1);
    dy=diff(glat);
    dy=dy(1);
    if nit==1
      Tauxm=Taux;
      Tauym=Tauy;
    else
      Tauxm=Tauxm+Taux;
      Tauym=Tauym+Tauy;
    end
  end %if p_nmc
  Sglon=round((Slon-xgridoffset)/dx)*dx+360+xgridoffset;
  if any(Slon>0 & Slon<0)
    error('can not handle positive and negative longitude')
  end
  Sglat=round(Slat-ygridoffset/dy)*dy+ygridoffset;
  %eliminate repeat points
  girep=find(diff(Sglon)==0 & diff(Sglat)==0);
  Sglon(girep)=[];
  Sglat(girep)=[];
  if any(Sglon>360)
    Sglon=Sglon-360;
    if ~p_cross_zerodate
      gishift=find(glon>180);
      glon(gishift)=glon(gishift)-360;
    end
  end

  if 0&curhalfday==60*round(curhalfday/60);
    curhalfday
    f1;cc=pcolor(glon,glat,Taux');set(cc,'edgecolor','none');colorbar
    f2;cc=pcolor(glon,glat,Tauy');set(cc,'edgecolor','none');colorbar
    drawnow
  end
  
  if length(Sglon)==1
    [pdist,pangle]=sw_dist(Slat([1,Nstat]),Slon([1,Nstat]),'km');
    ilon1=find(Sglon==glon);
    ilat1=find(Sglat==glat);
    TauE=Taux(ilon1,ilat1)*cos(D2R*pangle)+Tauy(ilon1,ilat1)*sin(D2R*pangle);
    Tek(itime)=TauE*pdist/fcoriolis(Sglat)/1e6; %In 10^9 kg/s
  elseif length(Sglat)==1
    error('this case not programmed')
  else
    [pdist,pangle]=sw_dist(Sglat,Sglon,'km');
    npair=length(Sglon)-1;
    for ipair=1:npair
      ilon1=find(Sglon(ipair)==glon);
      ilat1=find(Sglat(ipair)==glat);
      ilon2=find(Sglon(ipair+1)==glon);
      ilat2=find(Sglat(ipair+1)==glat);
      TauE(ipair)=.5*(Taux(ilon1,ilat1)+Taux(ilon2,ilat2))*cos(D2R*pangle(ipair)) + ...
	          .5*(Tauy(ilon1,ilat1)+Tauy(ilon2,ilat2))*sin(D2R*pangle(ipair));
    end;
    Tek(:,itime)=TauE'.*pdist./...
      fcoriolis((Sglat(1:npair)+Sglat(2:npair+1))/2)/1e6; %In 10^9 kg/s
    %SCALES RESULTS BY THE LENGTH OF THE SECTION IF SHORT
    if length(Sglon)<=3
      ddist=sw_dist(Slat([1,Nstat]),Slon([1,Nstat]),'km');
      ddist1=sum(pdist);
      Tek(:,itime)=Tek(:,itime)*ddist/ddist1;
    end
    
    %SIMPLISTIC CALCULATION FOR COMPARISON (Just one line)
    if nit==1
      if abs(Slon(Nstat)-Slon(1))>abs(Slat(Nstat)-Slat(1))
	disp('Zonal section calculation for 1line transport')
	p_zonal=1;
      else
	disp('Meridional section calculation for 1line transport')
	p_zonal=0;
      end  
    end
    if p_zonal
      if nit==1
	latnom=input('enter nominal latitude ');
      end
      ila= find( (round(latnom-ygridoffset)+ygridoffset)==glat);
      %ila=find( (round(mean(Slat-ygridoffset))+ygridoffset)==glat);
      if any(glon<0) | p_cross_zerodate%zero crossing case
	ilo1=find((round(Slon(1)    -xgridoffset)+xgridoffset)==glon);
	ilo2=find((round(Slon(Nstat)-xgridoffset)+xgridoffset)==glon);
	if 0&p_cross_zerodate %replaced ~p_cross_zerodate for indian
	  disp('WATCH OUT THIS LINE OF CODE !!')
	  nlon=length(glon);
	  gilo=[ilo1:nlon, 1:ilo2];
	else
	  gilo=ilo1:ilo2;
	end
      else
	ilo1=find((round(360+Slon(1)    -xgridoffset)+xgridoffset)==glon);
	ilo2=find((round(360+Slon(Nstat)-xgridoffset)+xgridoffset)==glon);
	gilo=min(ilo1,ilo2):max(ilo1,ilo2);
      end
      dist_=cumsum(sw_dist(glat(ila)*ones(length(gilo),1),glon(gilo),'km'));
      Teksimple(itime)=1/fcoriolis(glat(ila))*...
	trapz([0;dist_],Taux(gilo,ila))/1e6;
      Tauxx(:,itime)=Taux(gilo,ila);
      lineid=glat(ila);
    else
      %meridional
      if nit==1
	lonnom=input('enter nominal longitude ');
      end
      if any(glon<0) %zero crossing case
	ilo= find( (round(lonnom-xgridoffset)+xgridoffset)==glon);
      else
	ilo= find( (round(360+lonnom-xgridoffset)+xgridoffset)==glon);
      end
      ila1=find( (round(Slat(1)    -ygridoffset)+ygridoffset)==glat );
      ila2=find( (round(Slat(Nstat)-ygridoffset)+ygridoffset)==glat );
      a=min(ila1,ila2);
      ila2=max(ila1,ila2);
      ila1=a;
      dist_=cumsum(sw_dist(glat(ila1:ila2),glon(ilo)*ones(ila2-ila1+1,1),'km'));
      Teksimple(itime)=-trapz([0;dist_],Tauy(ilo,ila1:ila2)./...
	fcoriolis(glat(ila1:ila2))')/1e6;
      Tauyy(:,itime)=Tauy(ilo,ila1:ila2)';
      lineid=glon(ilo);
    end
  end %if length(Sglon)==1
  if p_nmc
    curhalfday=curhalfday+1;
    if curhalfday==60*round(curhalfday/60)
      disp('next month ...')
    end
  end
end %itime

if length(Sglon)<=3
  disp('Transport is scaled to section length ...')
end
if p_nmc
  fclose(fidu);fclose(fidv);
end
if p_reverse
  npt=size(Tek,1);
  Tek=-Tek(npt:-1:1,:);
  pdist=pdist(npt:-1:1);
end
Tektot=sum(Tek,1);
Tauxm=Tauxm/nit;
Tauym=Tauym/nit;
gii=2:4:360;
gjj=2:4:159;
%quiver(glon(gii),glat(gjj),Tauxm(gii,gjj)',Tauym(gii,gjj)',6)
%axis equal

% SAVE RESULTS
if p_nmc
  nf=sprintf('Ekmt_%s_%i_%i.mat',secid,yrstart,ntot);
  disp(['Saving ' OPdirek nf])
  today=date;
  eval(['save ' OPdirek nf ' pdist yrstart ntot today Tek Tektot '...
      ' Slat Slon Sglat Sglon Teksimple'])
else
  nf=sprintf('Ekmt_%s_%s.mat',secid,'charmainejan98');
  disp(['Saving ' pwd '/' nf])
  today=date;
  eval(['save '  nf ' pdist fname ntot today Tek Tektot '...
      ' Slat Slon Sglat Sglon Teksimple'])
end

% GRAPHICS
if p_nmc
  f1;
  plot(0.5:0.5:ntot/2,Tektot);
  title(sprintf('%s Ekman transport, %6.3g\\pm%6.3g Sv (%5.2g on %5.3g)',...
    secid,mean(Tektot),std(Tektot),sum(Teksimple),lineid))
  grid on;set(gca,'xtick',0:365/12:2*365);
  month=['     J';'     F';'     M';'     A';'     M';'     J';'     J';'     A'; ...
    '     S';'     O';'     N';'     D'];
  set(gca,'xticklabel',month)
end

f1;clf
subplot(2,1,1)
mTek=mean(Tek,2);
sTek=std(Tek')';
cpd=cumsum(pdist);
cumek=[cumsum(mTek)];
plot(cpd,cumek,'-o',cpd,cumek+sTek,'--',cpd,cumek-sTek,'--');
title(sprintf('%s Total Ekman T: %5.3g\\pm%5.3g Sv (%5.2g on %5.3g)',...
    secid,mean(Tektot),std(Tektot),sum(Teksimple),lineid))
grid on;ylabel([secid ' Cumulative transport ']);
xlabel('distance(km)');set(gca,'xlim',[0 max(cpd)])

subplot(2,1,2)
if any(glon<0)|p_cross_zerodate
  ll=Slon-lonshift;
else
  ll=360+Slon-lonshift;
end
plot(ll,Slat-latshift,'r+',Sglon,Sglat,'bo');grid on;title(secid)
text(Sglon(1),Sglat(1),'1','verticalal','bottom')
setlargefig

if nit>1 %spectral calculations
  f4;
  spectrum(Tektot,[],[],[],1/0.5);
  set(gca,'ylim',[0.1 1000],'xscale','log','xlim',[7e-3 1]); grid on;
  xlabel('Frequency (day^{-1})')
  [P,F]=spectrum(Tektot,[],[],[],1/0.5);
  title([secid ' power spectrum'])
  f5;
  loglog(F,cumtrapz(F,P(:,1)))
  set(gca,'ylim',[1 20],'xscale','log','xlim',[7e-3 1]); grid on;
  xlabel('Frequency (day^{-1})');title([secid ' cumulative variance'])
end


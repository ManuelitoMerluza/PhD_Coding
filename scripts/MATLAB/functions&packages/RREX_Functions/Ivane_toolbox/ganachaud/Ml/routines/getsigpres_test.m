%script to text the function getsigpres
% A. Ganachaud, Nov 1996

%one interpolation:
pres=[0 500 1000 2000]';
botdep=3000;
imaxd=4
sigs=pres;
sigint=1000;
[psig] = getsigpres(pres,botdep,imaxd,sigs,sigint)

%one surface data:
pres=[1 2 3 4]';
botdep=[3.5,4];
imaxd=[3,4];
sigs=[[10 20 40 NaN]',...
     [15 25 45  65]'];
sigint=[5 17 25 30 45 50 60 70]

[psig] = getsigpres(pres,botdep,imaxd,sigs,sigint)

plot(sigs,-pres,'-',sigs,-pres,'+')
hold on
plot(sigint,-psig,'ro')
hold off

%REAL DATA
%SIGMA INTERFACES DEFINITION, NORTH ATLANTIC
sigint= [22.00 26.40 26.80 27.10 27.30 27.50 27.70, ...
    36.87 36.94 36.98 37.02, ...
    45.81 45.85 45.87 45.895 45.91 45.925 48.00]';
     
sigipref=[ 1 1 1 1 1 1 1, ...
    2 2 2 2,...
    3 3 3 3 3 3 3]';

pref=[0 2000 4000]; %DB

path(path,'/data4/ganacho/HYDROSYS')
secid='a36n'; secrelindice='4'; ylim=[-7000,0];isig=12;
datadir='/data1/ganacho/HDATA/';
getpdat
if 0
  %TEST OF different ref.levels for 1 pair
  ipair=85
  sigteta=-1000+sw_pden(sali(:,ipair),temp(:,ipair),Pres,0);
  sig1=-1000+sw_pden(sali(:,ipair),temp(:,ipair),Pres,2000);
  pl=plot(sigteta,-Pres,'-',sig1,-Pres,'+');
  axis([25 38 -4000 0])
  title(sprintf('Location, Lat= %4.1f Lon=%4.1f',Plat(ipair),Plon(ipair)))
  grid on
  %GET ALISON'S ROUTINES IN THE PATH
  path('FORTRANSW',path);
  iwater=find(~isnan(temp(:,ipair)));
  for idum=1:length(iwater)
    id=iwater(idum);
    ptemp0=theta(Pres(id),temp(id,ipair),sali(id,ipair),0);
    sigteta_A(id)=sigma(0,ptemp0,sali(id,ipair));
    ptemp2=theta(Pres(id),temp(id,ipair),sali(id,ipair),2000);
    sig1_A(id)=sigma(2000,ptemp2,sali(id,ipair));
  end
  hold on
  pl3=plot(sigteta_A,-Pres(iwater),'o',sig1_A,-Pres(iwater),'o');
  legend([pl;pl3(1)],'sigteta','sig_2000','Fortran routines')
end

[psigint]=find_sig_interface(sigint,sigipref, ...
  pref,ptemp,psali,Pres,Maxdp(:,Itemp),Pdep);
whitebg
pl1=plot(Plon,-psigint);

%COMPARISON WITH THE LAYBOUND RESULTS
load /data1/ganacho/LAYBOUND/natl/natl_pltlay.mat
eval(['sigsurf=SIGPR_' secrelindice ';' ])

%sigpres=sigsurf(isig,:)';
hold on;
pl2=plot(Plon,-sigsurf,'.');
grid on
ll=legend([pl1;pl2],'find_sig_interface','laybound');
title(secid)
set(gcf,'paperor','land')
setlargefig

[sigvel] = getsigprop(Pres,gvel,Pdep,sigsurf');


%PLOT USING CONTOURS

for ipref=1:max(sigipref)
  disp(sprintf('reference pressure = %i db',pref(ipref)))
  %get the sigma indices for this reference pressure
  gipref=find(sigipref==ipref);
  
  %get sigmas relative to that pressure reference over the whole section
  sig_curpref = -1000+sw_pden(sali,temp,Pres,pref(ipref));
  hold on
  [cc,hh]=extcontour(Plon,-Pres,sig_curpref,sigint(gipref),...
    'b:','label','fontsize',6); 
end %ipref=1:max(sigipref)


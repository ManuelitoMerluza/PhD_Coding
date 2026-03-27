datadir='/data1/ganacho/HDATA/';
secid='a36n';
secrelindice='4';
getpdat

path(path,'/data4/ganacho/SW')
dd=sw_dist(Plat,Plon,'km');
cdd=[0;cumsum(dd)];
sd=sw_dist(Slat,Slon,'km');

%REFERENCES THE VELOCITY TO THE BOTTOM
isig=18;
load /data1/ganacho/LAYBOUND/natl/matlab.mat
eval(['sigsurf=SIGPR_' secrelindice ';' ])
[sigvel] = getsigprop(Pres,gvel,Pdep,sigsurf');
gvelref=ones(size(gvel,1),1)*(sigvel(:,isig)')-gvel;


surf(cdd(1:50),-Pres,gvelref(:,1:50));
axis([0 3000 -5000 0 -150 150])
xlabel('along section distance (km)');ylabel('depth (m)');
zlabel('velocity (cm/s)')
print -deps fig_gvel_surf_a36n.eps

isground=find(isnan(gvelref));
gvelref0=gvelref;
gvelref0(isground)=zeros(size(isground));
gvelint=(1e3*sd').*trapz(Pres, gvelref0/100)/1e6; %(in Sv)

pbin=diff(Pres);
gvelint1=([pbin;0]'*gvelref0/100).*(1e3*sd')/1e6; %(in Sv)
plot(cdd,gvelint)
%hold on;plot(cdd,gvelint1,'+')
%integrate from East end
tottran=[fliplr(cumsum(fliplr(gvelint)))];
%plot(cdd,tottran/1e6,'linewidth',4)
xlabel('distance along the section (km)');
ylabel('mass transport (Sv)')
grid on
print -deps fig_verinttran_a36n.eps

%rms velocityu at the surface
rmsurfvel=rms(gvelref(1,:))








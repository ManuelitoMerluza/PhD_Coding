%Plot EN129 fields
datadir='/data4/ganacho/Hydrosys/EN129/';
secid='EN129_PG_65W_mer';
eval(['load ' datadir secid '_hdr.mat' ])

Botp=Botd;
Maxdp=max([Maxd(1:Nstat-1,1),Maxd(2:Nstat,1)]')';
iprop=Itemp;
temp=rhydro([datadir Pairfiles(iprop,:)], Precision(iprop,:), ...
        MPres(iprop), Npair, Maxdp);
      
iprop=Isali;
sali=rhydro([datadir Pairfiles(iprop,:)], Precision(iprop,:), ...
        MPres(iprop), Npair, Maxdp);
f1;
subplot(2,1,1)
plt_prop(temp, 'temp', 'deg', ...
     Cruise, Pres, Maxd, Botp, Slat, Slon);
   
subplot(2,1,2)
plt_prop(sali, 'sali', 'psu', ...
     Cruise, Pres, Maxd, Botp, Slat, Slon);
setlargefig   

f2;clf
subplot(2,1,1)
plt_prop(sw_pden(35*ones(size(temp)),temp,Pres,0)-1000, 'pden', 'potential', ...
     Cruise, Pres, Maxd, Botp, Slat, Slon);
subplot(2,1,2)
plt_prop(sw_pden(sali,3*ones(size(temp)),Pres,0)-1000, 'pden', 'potential', ...
     Cruise, Pres, Maxd, Botp, Slat, Slon);
setlargefig;
f3;clf;plot(Slon,Slat,'+');axis equal;grid on

f4;
plt_prop(sw_pden(sali,temp,Pres,0)-1000, 'pden', 'potential', ...
     Cruise, Pres, Maxd, Botp, Slat, Slon);

dynht=sw_gpan(35*ones(size(temp)),temp,Pres);
dynhs=sw_gpan(sali,ones(size(temp)),Pres);
dynh=sw_gpan(sali,temp,Pres);

for ip=1:Npair
  gic=1:Maxd(ip);
  tempm(ip)=trapz(Pres(gic),temp(gic,ip))./trapz(Pres(gic),ones(length(gic),1));
  salim(ip)=trapz(Pres(gic),sali(gic,ip))./trapz(Pres(gic),ones(length(gic),1));
end
f5;
subplot(3,1,1)
plot(Plat,tempm);grid on;axis([min(Plat) max(Plat) 0 20]);
grid on;title('Tmean');
subplot(3,1,2)
plot(Plat,salim);grid on;axis([min(Plat) max(Plat) 34.5 35.5]);
grid on;title('Smean');
subplot(3,1,3)
pl=plot(Plat,dynht(25,:)-dynht(25,4),'r+-',...
  Plat,dynhs(25,:)-dynhs(25,4),'bx-',...
  Plat,dynh(25,:)-dynh(25,4),'mo-')
grid on;title('Dynamic height, ref=3000m, each contribution')
legend('Temp','Sali','Total')
setlargefig

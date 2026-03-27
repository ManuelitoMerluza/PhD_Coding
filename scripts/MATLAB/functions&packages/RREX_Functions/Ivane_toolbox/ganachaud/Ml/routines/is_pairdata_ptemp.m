% TO FIND OUT IF IF THE O/P OF GEOVEL
% CONTAINS TEMP OR POT. TEMP

datadir='/data1/ganacho/HDATA/';
secid='a24n'

getpdat

ipair=31

sw_dist([24,24],[-60,Plon(31)],'km')

load lev94_t_s_summer_24N_60W.dat
levdep=lev94_t_s_summer_24(:,2);
levtemp=lev94_t_s_summer_24(:,3);
levsali=lev94_t_s_summer_24(:,4);

pl1=plot(temp(:,ipair),-Pres);
hold on
pl2=plot(levtemp,-levdep,'+');

ptemp=sw_ptmp(sali,temp,Pres,0);

pl3=plot(ptemp(:,ipair),-Pres,'.');
grid on;axis([0 30 -6000 0]);

title('temperature comparison')
legend([pl1;pl2;pl3],'in situ, cruise',...
  'in situ, Levitus','potential, cruise')
set(gcf,'papero','land')
setlargefig



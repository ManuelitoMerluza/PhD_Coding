


% -----------------------------------------
% comparaison cli et clc 
% tracés TEMP et PSAL en fonction de PRES
% -----------------------------------------

identcamp = input('Identificateur Campagne ? ','s');
stdeb = input('Station debut ? ');
stfin = input('Station fin ? ');

titreplot = input ('Titre pour les tracés ? ','s');

for i = stdeb:stfin
  cstat=sprintf('%03d',i)  
  ficuni1= [identcamp 'd' cstat '_cli.nc'];
  ficuni2= [identcamp 'd' cstat '_clc.nc'];

  fic_cli= netcdf.open(ficuni1,'NOWRITE');
  fic_clc= netcdf.open(ficuni2,'NOWRITE');

  [tprscli,fillvalue,namepi,unitpi,valmin,valmax,flagpi] = lcpars ('PRES', ficuni1);
  [tsalcli,fillvalue,namesi,unitsi,valmin,valmax,flagsi] = lcpars ('PSAL', ficuni1);
  [ttmpcli,fillvalue,nameti,unitti,valmin,valmax,flagti] = lcpars ('TEMP', ficuni1);

  [tprsclc,fillvalue,namepc,unitpc,valmin,valmax,flagpc] = lcpars ('PRES', ficuni2);
  [tsalclc,fillvalue,namesc,unitsc,valmin,valmax,flagsc] = lcpars ('PSAL', ficuni2);
  [ttmpclc,fillvalue,nametc,unittc,valmin,valmax,flagtc] = lcpars ('TEMP', ficuni2);
  
  
  
 figure
 subplot(1,2,1);
 set(gca,'fontsize',10)
 grid
 hold on
 plot(ttmpcli,-tprscli,'g.',ttmpclc,-tprsclc,'r')
 title(['   ' titreplot '  Station ' num2str(i) ]);
 xlabel([nameti ' (' unitti ')'])
 ylabel([namepi ' (' unitpi ')'])
 
 subplot(1,2,2)
 set(gca,'fontsize',10)
 grid
 
 plot(tsalcli,-tprscli,'g.',tsalclc,-tprsclc,'r')
 title(['   ' titreplot ' Station ' num2str(i) ]);
 xlabel([namesi ' (' unitsi ')'])
 ylabel([namepi ' (' unitpi ')'])
 eval(['print -depsc2 resu/' identcamp cstat '_PTS.eps'])
 hold off
 
netcdf.close(fic_cli);
netcdf.close(fic_clc);

end
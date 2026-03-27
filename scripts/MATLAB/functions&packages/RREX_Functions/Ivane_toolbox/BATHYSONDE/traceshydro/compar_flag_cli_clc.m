

clear all
close all

% -----------------------------------------
% comparaison cli et clc 
% tracés TEMP et PSAL en fonction de PRES
% -----------------------------------------

identcamp = input('Identificateur Campagne ? ','s');
stdeb = input('Station debut ? ');
stfin = input('Station fin ? ');

titreplot = input ('Titre pour les tracés ? ','s');

for i = stdeb:stfin
  cstat=sprintf('%03d',i);  
  ficuni1= [identcamp 'd' cstat '_cli.nc'];
  ficuni2= [identcamp 'd' cstat '_clc.nc'];

  %fic_cli= netcdf.open(ficuni1,'NOWRITE');
  %fic_clc= netcdf.open(ficuni2,'NOWRITE');

  [tprscli,~,namepi,unitpi,valmin,valmax,flagpi] = lcpars ('PRES', ficuni1);
  [tsalcli,~,namesi,unitsi,valmin,valmax,flagsi] = lcpars ('PSAL', ficuni1);
  [ttmpcli,~,nameti,unitti,valmin,valmax,flagti] = lcpars ('TEMP', ficuni1);

  [tprsclc,~,namepc,unitpc,valmin,valmax,flagpc] = lcpars ('PRES', ficuni2);
  [tsalclc,~,namesc,unitsc,valmin,valmax,flagsc] = lcpars ('PSAL', ficuni2);
  [ttmpclc,~,nametc,unittc,valmin,valmax,flagtc] = lcpars ('TEMP', ficuni2);
  
  
  
 figure
 subplot(1,2,1);
 set(gca,'fontsize',10)
 grid
 hold on
 i4=find(flagti==4);
 plot(ttmpcli,-tprscli,'g',ttmpcli(i4),-tprscli(i4),'r.')
 
 title(['   ' titreplot '  Station ' num2str(i) ' CLI']);
 xlabel([nameti ' (' unitti ')'])
 ylabel([namepi ' (' unitpi ')'])
 
 subplot(1,2,2)
 set(gca,'fontsize',10)
 grid
 hold on
 i8=find(flagtc==8);
 plot(ttmpclc,-tprsclc,'g',ttmpclc(i8),-tprsclc(i8),'b+')
 title(['   ' titreplot ' Station ' num2str(i) ' CLC']);
 xlabel([nametc ' (' unittc ')'])
 ylabel([namepc ' (' unitpc ')'])
 eval(['print -depsc2 resu/' identcamp cstat '_compar_flag_T.eps'])
 hold off
 
figure
 subplot(1,2,1);
 set(gca,'fontsize',10)
 grid
 hold on 
 i4=find(flagsi==4);
 plot(tsalcli,-tprscli,'g',tsalcli(i4),-tprscli(i4),'r.')
 title(['   ' titreplot '  Station ' num2str(i) ' CLI']);
 xlabel([namesi ' (' unitsi ')'])
 ylabel([namepi ' (' unitpi ')'])
 
 subplot(1,2,2)
 set(gca,'fontsize',10)
 grid
 hold on
  i8=find(flagsc==8);
 plot(tsalclc,-tprsclc,'g',tsalclc(i8),-tprsclc(i8),'b+')
 title(['   ' titreplot ' Station ' num2str(i) ' CLC']);
 xlabel([namesc ' (' unitsc ')'])
 ylabel([namepc ' (' unitpc ')'])
 eval(['print -depsc2 resu/' identcamp cstat '_compar_flag_S.eps'])
 hold off 
 
%netcdf.close(fic_cli);
%netcdf.close(fic_clc);

end

clear all
close all

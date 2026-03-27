%***************************************************************************
%   Macro pour tracer les figures pour les rapports de donnees 
%   2013. P.Branellec et C. Kermabon
%   Fonction plots.m
%
%   NB : la generation automatique du fichier .png marche avec matlab.
%   option hgexport. 
%
%   Retailler la figure avec xnview, faire rotation -90Âdeg., inserer sous word
%
%   labels en francais ou anglais
%***************************************************************************
%
 clear all;
 close all;
%
% boucle sur les fichiers sonde
%

rep_publi = 'resu/'; 
%
identcamp = input('Identificateur Campagne ? ','s');

langue = input('Choix de la langue : A=Anglais, F=Francais ','s');
langue = upper(langue);

stdeb=input('Station debut ? ');
stfin=input('Station fin ? ');

sta = (stdeb : stfin);

%
for i_sta = sta(1,:)
%
% lecture fichiers sonde calibres (descente)
%
cstat=sprintf('%03d',i_sta);
ficuni = [identcamp 'd' cstat '_clc.nc'];

% test si le fichier existe
if exist(ficuni,'file')

  xp  = ncread(ficuni,'PRES');
  xt  = ncread(ficuni,'TEMP');
  xs  = ncread(ficuni,'PSAL');
  xo  = ncread(ficuni,'OXYK');
  xtp = ncread(ficuni,'TPOT');

%
% 2 types de figure selon num de station (0 a  87 et 103 a  109) (88 a  102)
%

figure;

%if i_sta < 85 || i_sta > 101 
if i_sta < 85 

%set(gcf,'Position',get(0,'screensize'));
set(gcf,'Position',[100 100 1100 800]);
%set(gcf,'Name',sprintf('CATARINA 2012 : traces publication'));
set(gcf, 'PaperOrientation', 'landscape');

subplot('Position',[0.13 0.11 0.335 0.815]);
%
% graphe de gauche
% 1ere courbe
%

if strcmp(langue,'F')
   lab = strjust(char('Pression (dbar)','Temperature (deg.C)','Salinite (psu)','Oxygene (umol/kg)'),'center');
else
   lab = strjust(char('Pressure (dbar)','Temperature (deg.C)','Salinity (psu)','Oxygen (umol/kg)'),'center');
end

[a,b] = plots(-xp,[xt,xs,xo],'top',lab);
grid on;
set(b(1),'xcolor','r');
set(b(2),'xcolor','b');
set(b(3),'xcolor','g');

set(a(1),'color','r');
set(a(2),'color','b');
set(a(3),'color','g');

set(b(1),'XLim',[-5 20]);
set(b(2),'XLim',[34.5 36.5],'Xtick',34.5:0.4:36.5);
set(b(3),'XLim',[100 350]);

hold on;

%
text(-12,-1523,sprintf(' Cast : %i  ',i_sta),'Rotation',270,'Color','k','FontSize',14.5,'Fontweight','bold','BackgroundColor','y');
%

hold on;

%
% graphe droite haut
%
%subplot(2,2,2);
subplot('Position',[0.57 0.584 0.335 0.341]);
plot (xs,xtp,'b.','MarkerSize',4);
%
if strcmp(langue,'F')
    xlabel('Salinite (psu)','Color','b','FontSize',11,'Fontweight','bold');
    ylabel('Temperature Potentielle (deg.C)','FontSize',11,'Fontweight','bold');
else
    xlabel('Salinity (psu)','fontsize',11,'fontweight','b');
    ylabel('Potential Temperature (deg.C)','fontsize',11,'fontweight','b');
end

 ax1 = gca;
 axis([34.5 36.5 -5 20]);
 set(ax1,'Xtick',34.5:0.5:36.5);
 set(ax1,'XColor','b');
 set(ax1,'TickDir','out');
 set(ax1,'XminorTick','on');
 set(ax1,'Ytick',-5:5:20);
 set(ax1,'YminorTick','on');
grid on;
%
% graphe droite bas
%
%subplot(2,2,4);
subplot('Position',[0.57 0.11 0.335 0.341]);
plot (xo,xtp,'g.','MarkerSize',4);
%
if strcmp(langue,'F')
    xlabel('Oxygene (umol/kg)','Color','g','FontSize',11,'Fontweight','bold');
    ylabel('Temperature Potentielle (deg.C)','FontSize',11,'Fontweight','bold');
  else
    xlabel('Oxygen (um/kg)','fontsize',11,'fontweight','b');
    ylabel('Potential Temperature (deg.C)','fontsize',11,'fontweight','b');
end

 ax1 = gca;
 axis([100 350 -5 20]);
 set(ax1,'Xtick',100:50:350);
 set(ax1,'XColor','g');
 set(ax1,'TickDir','out');
 set(ax1,'XminorTick','on');
 set(ax1,'Ytick',-5:5:20);
 set(ax1,'YminorTick','on');
grid on;
hold off;
%
%pause;
%
else
%  stat > 85

%set(gcf,'Position',get(0,'screensize'));
set(gcf,'Position',[100 100 1100 800]);
%set(gcf,'Name',sprintf('CATARINA 2012 : traces publication'));
set(gcf, 'PaperOrientation', 'landscape');

%subplot(1,2,1);
%subplot('Position',[0.13 0.11 0.335 0.815]);
subplot('Position',[0.13 0.11 0.335 0.815]);
%
% graphe de gauche
% 1ere courbe
%
if strcmp(langue,'F')
    lab = strjust(char('Pression (dbar)','Temperature (deg.C)','Salinite (psu)','Oxygene (umol/kg)'),'center');
else
    lab = strjust(char('Pressure (dbar)','Temperature (deg.C)','Salinity (psu)','Oxygen (umol/kg)'),'center');
end

[a,b] = plots(-xp,[xt,xs,xo],'top',lab);
grid on;
set(b(1),'xcolor','r');
set(b(2),'xcolor','b');
set(b(3),'xcolor','g');

set(a(1),'color','r');
set(a(2),'color','b');
set(a(3),'color','g');

set(b(1),'XLim',[-5 20]);
set(b(2),'XLim',[29.5 35.5],'Xtick',29.5:1.2:35.5);
set(b(3),'XLim',[250 500]);

hold on;

text(-12,-1523,sprintf(' Cast : %i  ',i_sta),'Rotation',270,'Color','k','FontSize',14.5,'Fontweight','bold','BackgroundColor','y');

%
% graphe droite haut
%
%subplot(2,2,2);
subplot('Position',[0.57 0.584 0.335 0.341]);
plot (xs,xtp,'b.','MarkerSize',4);
%
if strcmp(langue,'F')
    xlabel('Salinite (psu)','Color','b','FontSize',11,'Fontweight','bold');
    ylabel('Temperature potentielle (deg.C)','FontSize',11,'Fontweight','bold');
else
    xlabel('Salinity (psu)','fontsize',11,'fontweight','b');
    ylabel('Potential temperature (deg.C)','fontsize',11,'fontweight','b');
end

 ax1 = gca;
 axis([29.5 35.5 -5 20]);
 set(ax1,'Xtick',29.5:1.0:35.5);
 set(ax1,'XColor','b');
 set(ax1,'TickDir','out');
 set(ax1,'XminorTick','on');
 set(ax1,'Ytick',-5:5:20);
 set(ax1,'YminorTick','on');
grid on;

%
% graphe droite bas
%
%subplot(2,2,4);
subplot('Position',[0.57 0.11 0.335 0.341]);
plot (xo,xtp,'g.','MarkerSize',4);
%
if strcmp(langue,'F')
    xlabel('Oxygene (umol/kg)','Color','g','FontSize',11,'Fontweight','bold');
    ylabel('Temperature potentielle (deg.C)','FontSize',11,'Fontweight','bold');
else
    xlabel('Oxygen (um/kg)','fontsize',11,'fontweight','b');
    ylabel('Potential Temperature (deg.C)','fontsize',11,'fontweight','b');
end

 ax1 = gca;
 axis([250 500 -5 20]);
 set(ax1,'Xtick',250:50:500);
 set(ax1,'XColor','g');
 set(ax1,'TickDir','out');
 set(ax1,'XminorTick','on');
 set(ax1,'Ytick',-5:5:20);
 set(ax1,'YminorTick','on');
grid on;
hold off;
%
%pause;
%
% fin du test sur num station
%
end



%
% creation du fichier figure
%

% la meilleure facon de creer un fichier figure est de faire un save a  partir de la fenetre figure
% directement. On a exactement ce que l'on a a  l'ecran.

% nouvelle methode (juill 2013) trouvee par CK et ca marche
hgexport(gcf,sprintf('%s%s_%3.3d.png',rep_publi,identcamp,i_sta),...
hgexport('factorystyle'),'Format','png');

close(figure);
close (figure(1));
close (figure(2));
% fin boucle for

else 
    
     message = ['Fichier inexistant ' ficuni] 


end
end

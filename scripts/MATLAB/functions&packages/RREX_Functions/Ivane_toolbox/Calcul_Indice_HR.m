% Calcul_Indice_HR.m
% ------------------
% METTRE A JOUR LE FICHIER AVISO_mensuelles_AN.mat avec Lec_Aviso_Suite.m
% si nécessaire
% ---> 07/12/2017
%      eigs rend le résultat inverse: rajouter 'sm'
%
% Derniere version apres discussion avec Herle:
% pour repasser dans le domaine physique il faut choisir une point
% et reconstruire le signal avec une seule composante.
% H&R: 52W ; 57N.
% ---> J'utilise tous les points de l'espace et du temps 
% ---> Modif du 12/09/2014
%      Les donnees AVISO ont change: nouvelle grille 
% ---> Absolute Dynamic Height (sla)
%      Je peux raccourcir la serie pour comparer avec H&R
%      Suppression moyenne locale
%      Suppression signal saisonnier
%      Latitudinal ponderation
%      TEST :j'enleve la moyenne globale
%      Question subsidiaire: dans quel ordre toutes ces opérations?
% ------------------------------------------------------------------------
clear;close all;
%%
Lon_W=-60;Lon_E=10;Lat_S=32;Lat_N= 68;
% Lon_W=-84;Lon_E=4;Lat_S=20;Lat_N= 65;
% Lon_W=-85;Lon_E=10;Lat_S=-2;Lat_N= 65;
% Lon_W=-90;Lon_E=10;Lat_S=15;Lat_N= 62;
%Lon_W=-60;Lon_E=10;Lat_S=50;Lat_N= 65; %SPG
% Lon_W=-85;Lon_E=10;Lat_S=-2;Lat_N= 65;
% Lon_W=-85;Lon_E=10;Lat_S=-2;Lat_N= 48;
ficSv='AVISO_mensuelles_AN';
load(ficSv)
iLa=find(lat>=Lat_S & lat<=Lat_N);nLa=length(iLa);
iLo=find(lon>=Lon_W & lon<=Lon_E);nLo=length(iLo);
lat=lat(iLa);lon=lon(iLo);sla=sla(iLa,iLo,:);
[M, N, L]=size(sla); % lat lon time
bid=datevec(Vtime(1));nYearD=bid(1);
bid=datevec(Vtime(end));nYearF=bid(1);


%% ---> Je peux raccourcir la serie pour comparer avec H&R
% Commenter si toute la serie
sprintf('Longueur de la serie en mois: %d',L)
Lr=input('Nombre de mois pris en compte? ');
if isempty(Lr),Lr=L;end
if Lr~=L
   disp('Attention, serie raccourcie (ligne 111)');
   L=Lr;
   Vtime=Vtime(1:L);
   bidY =datevec(Vtime(1));nYearD =bidY(1);
   bidY =datevec(Vtime(end));nYearF =bidY(1);
   sla=sla(:,:,1:L);
end
%% ---> TEST du 06/01/2015 (j'enleve la moyenne globale)
rep_MNA=input('On supprime la moyenne globales?','s');
if strcmpi(rep_MNA,'o')
   disp('Attention, moyenne globale soustraite (ligne 106)');
   aa=nanmean(sla,2);
   bb=squeeze(nanmean(aa,1))';
   sla=sla-repmat(reshape(bb,[1 1 L]),[M N 1]);
end

%% ---> Suppression moyenne locale
rep_ML=input('On supprime la moyenne locale?','s');
if strcmpi(rep_ML,'o')
   Msla=mean(sla,3);
   sla1=sla-repmat(Msla,[1 1 L]);
else
   sla1=sla;
end
%% ---> Suppression signal saisonnier
sla2=NaN(M,N,L);
[~,Mm,~]=datevec(Vtime);
for jj=1:12
   DD=Mm==jj;
   Cycle_Ssla=mean(sla1(:,:,DD),3);
   sla2(:,:,DD)=sla1(:,:,DD)-repmat(Cycle_Ssla,[1 1 sum(DD)]);
end

%% ---> Latitudinal ponderation
Plat=sqrt(cosd(lat));
sla3=sla2.*repmat(Plat,[1 N L]);

%% ---> Calcul ecart type et normalisation
STDsla=nanstd(sla3,0,3);
STDsla=repmat(STDsla,[1 1 L]);
sla4=sla3./STDsla;


%% ---> Creation d'une matrice M_h (espace,temps)
%      et suppression des NaN
Msla=mean(sla4,3); % pas de NaN dans les series temporelles locales
sla4(isnan(Msla))=nan;
bid=reshape(sla4,M*N,L);
JJ=find(~isnan(bid(:,1))); % pour reconstruire apres analyse
M_h=bid(JJ,:);[m, ~]=size(M_h); % m=espace, ie nombre de points de grille
% --->  Covariance matrix
RR=M_h'*M_h;

% ---> Find eigenvalues, eigenvectors
% V=diag(D) valeurs propres de RR
[E,D]=eigs(RR,L,'sm'); % c'est l'inverse de ce qui est dans la doc
V=diag(D);             % sm=smallest magnitude
% EOFs, Composantes Principales (SPATIALES) normalisees (en colonne).
% PC, Composantes Principales (TEMPORELLES) (en colonne).
EOFs=(M_h*E)./repmat(sqrt(V'),m,1); 
PC=M_h'*EOFs; % Projection sur les Composantes principales

%% la variance du premier coefficient est
disp('variance du premier coefficient');
disp(sum(PC(:,1).*PC(:,1)))
disp(V(1))
disp('pourcentage de variance expliquee');
disp(100*V(1)/sum(V,1))
%%
eof1=EOFs(:,1); % Premier mode de la  structure spatiale
PC1=PC(:,1);    % Premiere mode de la structure temporelle
PourVar=100*diag(D)./sum(diag(D)); % Variabilite prise en compte

%% ---> Traces
figure('color','w');
subplot('Position',[0.750    0.7093    0.15    0.15]);
bar((1:10),PourVar(1:10));
axis([0 11 0 ceil(max(PourVar(1:10)*10)/10)]);
ht=title('Normalized eigenvalues ','fontsize',8);
xlabel('EOF number','fontsize',8);
ylabel('%','fontsize',8);grid on;set(gca,'fontsize',8);

h34=subplot(3,1,2);p34=get(h34,'position');
set(h34,'position',[p34(1) 0.35 p34(3) 0.27])
bid=PC(:,1);
if bid(1) < 0 % on change les signe pour suivre H&R
   bid =-bid; 
   eof1=-eof1;
end
plot(Vtime,bid,'-');hold on;
bod=moygliss(bid,7,0,2);
plot(Vtime,bod,'r-','linewidth',2);
xData = datenum(nYearD:nYearF+1,1,1);
set(gca,'XTick',xData);
datetick('x','yy','keepticks');grid on;set(gca,'XTickLabel',[]);
title(['PC 1,  percent variance expl=',num2str(PourVar(1),2),'% ']);
set(gca,'ylim',[floor(min(bid*10)/10) ceil(max(bid*10)/10)]);

% ---> Je recupere les NaN et reconstruis la matrice (lat x lon)
Ppc1=NaN(M*N,1);Ppc1(JJ,1)=eof1; 
PC1r=reshape(Ppc1,[M N]);
subplot('Position',[0.1 0.7093 0.6 0.25]);
m_proj('mercator','longitudes',[Lon_W Lon_E],'lat',[Lat_S Lat_N]);
m_coast('patch',[.9 .9 .9],'edgecolor','k');
m_grid('fontsize',8,'XaxisLocation','bottom','YaxisLocation','left');
hold on;m_contourf(lon,lat,PC1r,20,'edgecolor','none');
m_contour(lon,lat,PC1r,[0 0],'k');
caxis([-0.01 0.01]);
vm=load('bwr.txt');
colormap(vm);colorbar;%cbfit(1,0);
title(['EOF 1 (' rep_MNA ' - ' rep_ML ')']);

h56=subplot(3,1,3);p56=get(h56,'position');
pos=input('Position de la projection? [lon,lat]');
if isempty(pos),pos=[-52,57];end
[~,ila]=min(abs(lat-pos(2)));[~,ilo]=min(abs(lon-pos(1)));
% ---> Je reconstruis le signal analyse pour verifier
Ppc=NaN(M*N,L);
Ppc(JJ,:)=EOFs;
PCr=reshape(Ppc,[M N L]);
sshrec=zeros([M N L]);
for k=1:L
   for kk=1:3 % kk=1,L = signal complet mais c'est long)
      sshrec(:,:,k)=sshrec(:,:,k)+PCr(:,:,kk)*PC(k,kk);
   end
end
bid=-100*squeeze(sshrec(ila,ilo,:).*STDsla(ila,ilo,:));
plot(Vtime,bid,'k');hold on;
bod=moygliss(bid,13,0,2);
plot(Vtime,bod,'b')
set(gca,'XTick',xData);
set(gca,'ylim',[floor(min(bid*100))/100 ceil(max(bid*100))/100]);
datetick('x','yy','keepticks');grid on;
ylabel('SSH (cm)');
xlabel(['PC1 at ' num2str(pos(1)) '^oW ;' num2str(pos(2)) '^oN']);
bid=-100*squeeze(sla4(ila,ilo,:).*STDsla(ila,ilo,:));
bod=moygliss(bid,7,0,2);
plot(Vtime,bod,'r--');
%% Pour comparaison article Science
figure('color','w');
set(gca,'Position',[0.13 0.11 0.6683 0.815])
bidS=-100*squeeze(sshrec(ila,ilo,:).*STDsla(ila,ilo,:));
plot(Vtime,bidS,'k','linewidth',2);hold on;
bodS=moygliss(bidS,13,0,2);
plot(Vtime,bodS,'b','linewidth',2)
set(gca,'XTick',xData);
%set(gca,'ylim',[-6 6]);
datetick('x','yy','keepticks');grid on;
ylabel('SSH AVISO mensuelle (cm)');
xlabel(['PC1 at ' num2str(pos(1)) '^oW ;' num2str(pos(2)) '^oN']);
bidA=-100*squeeze(sla4(ila,ilo,:).*STDsla(ila,ilo,:));
bodA=moygliss(bidA,13,0,2);
plot(Vtime,bodA,'r--');
p = polyfit(Vtime-Vtime(1),bodS',1);
f = polyval(p,Vtime-Vtime(1));
plot([Vtime(1) Vtime(end)],[f(1) f(end)],'r--')
title('Figure 1B de H&R (Science,2004)','fontsize',12,'fontweight','b')



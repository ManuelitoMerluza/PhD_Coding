% author(s): I. Salaun 10/2018 from H. Mercier & T. Petit (RREX2015)
% Modified by: Manuel Torres 04/2026
%
% description : 
% Computation of SADCP velocities perpendicular to the hydrological 
% sections of the RREX 2015 cruise. Divide segments of 2 km from the SADCP
% of the RREX2015 cruise.
%
% see also : vit_geo_2015.m vit_geo_abs_2015.m 

%% ========================================================================
clear all; 
close all;

addpath(genpath('C:/Users/mitg1n25/Desktop/PhD/PhD_Coding'))
%% ========================================================================
save_output = 1;
save_figure = 0;
save_figures_rapport = 0;

% CHOIX ADCP = 'OS38' ou 'OS150'
sadcp = 'OS38'; disp(sadcp);

% CHOIX DE LA SECTION parmi les sections 'north', 'ovide', 'south', 'ride'
section='ride'; disp(section);
%% ========================================================================
switch sadcp
    case 'OS38'
        fsadcp = 'C:/Users/mitg1n25/Desktop/PhD/PhD_Coding/data/RREX/Hydrography/'; %(sorties CASCADE Herlé)
        file_sadcp = 'RREX2015_ADCP38khz.nc';
        corr_value = 'm09_004_12_fhv21_sec_02mx21';
        file_save=['vitesse_sadcp_RREX15_',sadcp,'_',section,'_',corr_value,]; %nom du fichier de sortie sauvegardé 
    case 'OS150'
        fsadcp = 'C:/Users/mitg1n25/Desktop/PhD/PhD_Coding/data/RREX/Hydrography'; %(sorties CASCADE Herlé)
        file_sadcp = 'RREX2015_ADCP150khz.nc';
        corr_value = '08_015_38_fhv1_sec_02mx1';
        file_save=['vitesse_sadcp_RREX15_',sadcp,'_',section,'_',corr_value,];
         
end
rept = 'C:/Users/mitg1n25/Desktop/PhD/PhD_Coding/data/RREX/Ivane_output_RREX15/vitesse_adcp/'; %repertoire save file
%% ========================================================================
% implications du choix de la section
if strcmp(section,'north')
    
    numero = [25]; numero=numero(:); % sections a traiter
    switch sadcp 
        case 'OS38'
            titre='vitesses sadcp RREX 2017 OS38 North Section'; 
            titre_fig = 'vitesses_adcp_rrex17_OS38_north';  
        case 'OS150'
            titre='vitesses sadcp RREX 2017 OS150 North Section';
            titre_fig = 'vitesses_adcp_rrex17_OS150_north';
    end

    % definition du signe de la vitesse orthogonale la convention est la meme que pour la vitesse geostrophique
    % une vitesse positive indique une vitesse dirigée sur la droite de la section definie par le premier et dernier segment.
    sign=-1;
    xref='lon';    
    
elseif strcmp(section,'ovide')
    numero = [9 11 13 15 18 22 23] ; numero=numero(:);
    switch sadcp 
        case 'OS38'
            titre='vitesses sadcp RREX 2017 OS38 Ovide Section';
            titre_fig = 'vitesses_adcp_rrex17_OS38_ovide';
        case 'OS150'
            titre='vitesses sadcp RREX 2017 OS150 Ovide Section';
            titre_fig = 'vitesses_adcp_rrex17_OS150_ovide';
    end
%     sign_est=1; %attention une partie de la section +1 et une partie -1
%     sign_ouest=-1;
      sign=1;
    
    xref='lon';
    
 elseif strcmp(section,'south')
    numero = [04 05 07]; numero=numero(:);
    switch sadcp 
        case 'OS38'
            titre='vitesses sadcp RREX 2017 OS38 South Section';
            titre_fig = 'vitesses_adcp_rrex17_OS38_south';
        case 'OS150'
            titre='vitesses sadcp RREX 2017 OS150 South Section';
            titre_fig = 'vitesses_adcp_rrex17_OS150_south';
    end
    sign=-1;
    xref='lon';
    
 elseif strcmp(section,'ride')
    numero = [26 27 29 32:36]; numero=numero(:); 
    switch sadcp 
        case 'OS38'
            titre='vitesses sadcp RREX 2017 OS38 Reykjanes Ride Section';
            titre_fig = 'vitesses_adcp_rrex17_OS38_ride';
        case 'OS150'
            titre='vitesses sadcp RREX 2017 OS150 Reykjanes Ride Section';
            titre_fig = 'vitesses_adcp_rrex17_OS150_ride';
    end
    sign=-1;
    xref='lat';
   
end
%% ========================================================================
%Lecture des données SADCP

[UVEL_ADCP, VVEL_ADCP, SecLat, SecLon, DEPH, JULD, U_TIDE, V_TIDE, INDICE, BATHY] = rsadcp_rrex([fsadcp file_sadcp]);
% determination du nombre de sections à traiter
nsec=size(numero,1);

% on recupère les dimensions
njuld=size(JULD,1);
ndeph=size(DEPH,1);

% lecture du fichier section
fsec = 'C:/Users/mitg1n25/Desktop/PhD/PhD_Coding/data/RREX/Hydrography/rrex2015_all_sec.list'; 

[numero_sec, deb_sec, fin_sec, INDICE_DEB, INDICE_FIN]=rfic_sec_rrex(fsec,JULD,SecLat);

% nombre de sections dans le fichier
nsec_max=size(INDICE_DEB,1);
datestr(JULD(INDICE_DEB(numero)))

% concatener les indices juld que l'on garde
ijuld_keep = [];
npts_sec = NaN(nsec,1);

for i=1:nsec
    ijuld_keep=[ijuld_keep INDICE_DEB(numero(i)):INDICE_FIN(numero(i))];
    npts_sec(i)=INDICE_FIN(numero(i))-INDICE_DEB(numero(i))+1;
end

ijuld_keep=ijuld_keep';

% Affectation des variables 
zl=DEPH;

Ulnt=UVEL_ADCP(ijuld_keep,:); Ulnt = Ulnt';       
Vlnt=VVEL_ADCP(ijuld_keep,:); Vlnt = Vlnt';       
LatSta=SecLat(ijuld_keep);
LonSta=SecLon(ijuld_keep);

% Sorts it depending on the transect

if strcmp(section,'ride')
    [LatSta aux]=sort(LatSta,'descend');
    LonSta=LonSta(aux);
else
    [LonSta aux]=sort(LonSta,'ascend');
    LatSta=LatSta(aux);
end
Ulnt=Ulnt(:,aux); Vlnt=Vlnt(:,aux);

% % Pour la section ovide section est-ouest à l'est de la ridge et aller-retour du bateau à l'ouest de la ridge =>
% on utilise la section ouest-est on a donc en X -27=>-30 (X(111)) puis -37=>-30 
% Error using contourf: Vector X must be strictly increasing or strictly decreasing with no repeated values.
% remarque: on ne peut pas simplement ranger X en odre
% croissant/décroissant car il faut faire les mêmes permutations pour Vplot

if strcmp(section,'ovide')
    for j = 1:length(Ulnt(:,1))
        A = fliplr(Ulnt(j,112:end));  Ulnt(j,112:end) = A;
        B = fliplr(Vlnt(j,112:end));  Vlnt(j,112:end) = B;
    end    

    
    C = fliplr(LatSta(112:end)'); C=C'; LatSta(112:end) = C;
    D = fliplr(LonSta(112:end)'); D=D'; LonSta(112:end) = D;
end

% Projection des profils moyens par paire sur le plan perpendiculaire a la  section 
% utilisation de la fonction dist_hm qui retourne la distance en metres et
% l'angle en degré par rapport au nord avec [0-180] quadrant west et [0
% 180] quadrant Est
[Dsta,phi1,~]=dist_hm(LatSta,LonSta);
Dsta=Dsta(:);

% On transforme en reference par rapport à l'est et sens trigonométrique
% sur 0-360 (0=est, 90=nord, 180=west, 270=sud)
phi1=phi1-90; phi1=-phi1;  phi1(phi1<0)=phi1(phi1<0)+360;                         
phi=phi1*pi/180; 
phi=phi(:);
phi=[phi;phi(end)];

% suppression des outliers (et NaN resultant de deux fois le meme point dans la section)

idebut=1;

for i=1:nsec;
    
    phi_mean = meanoutnan(phi(idebut:idebut+npts_sec(i)-1));
    phi_std = stdoutnan(phi(idebut:idebut+npts_sec(i)-1));
    
    ioutl = phi(idebut:idebut+npts_sec(i)-1) < phi_mean-phi_std; interm=phi(idebut:idebut+npts_sec(i)-1); interm(ioutl)=phi_mean; interm(isnan(interm))=phi_mean;
    phi(idebut:idebut+npts_sec(i)-1)=interm;
    ioutl = phi(idebut:idebut+npts_sec(i)-1) > phi_mean+phi_std; interm=phi(idebut:idebut+npts_sec(i)-1); interm(ioutl)=phi_mean; interm(isnan(interm))=phi_mean;
    phi(idebut:idebut+npts_sec(i)-1)=interm;
    
    idebut=idebut+npts_sec(i);
    
end

% on affecte l'angle moyen au phi de chaque section
    idebut=1;
for i=1:nsec;
    phi_mean = meanoutnan(phi(idebut:idebut+npts_sec(i)-1));
    phi(idebut:idebut+npts_sec(i)-1)=phi_mean;
    idebut=idebut+npts_sec(i);
end

idebut=1;
for i=1:nsec;
    idebut=idebut+npts_sec(i);
end

% Projection des profils moyens par paire sur le plan perpendiculaire a la section
% rotation sur l'axe a 90° à droite de l'axe de la section
% Vortho sera donc positif pour une vitesse dirigee à 90° à droite de l'axe de la section
phi=repmat(phi,1,ndeph);

% Calcul avec la vitesse courant
Vortho = Ulnt'.*cos(phi-pi/2*ones(size(phi))) + Vlnt'.*sin(phi-pi/2*ones(size(phi))); % = U*sin(phi)-V*cos(phi) ortho par rapport a Est=0.

Vortho = sign*Vortho;
[lsec,nzl] = size(Vortho);

% cette projection pose des problèmes de conservation des distances
% on teste les degats et on corrige par une repartition uniforme des ecarts
idebut=1;
for i=1:nsec
    dist_sec1=sum(Dsta(idebut:idebut+npts_sec(i)-2));
    [dist_sec2,~,~]=dist_hm( [LatSta(idebut); LatSta(idebut+npts_sec(i)-1)], [LonSta(idebut); LonSta(idebut+npts_sec(i)-1)] );
    Dsta(idebut:idebut+npts_sec(i)-2)=Dsta(idebut:idebut+npts_sec(i)-2)/dist_sec1*dist_sec2;
end

% calcul de la distance associée à chaque valeur de Vortho
dpair=NaN(lsec,1);
dpair(1)=0.5*Dsta(1);
dpair(lsec)=Dsta(lsec-1)*0.5;

for i=2:lsec-1
    dpair(i)=0.5*(Dsta(i-1)+Dsta(i));
end

%% sauvegarde des données ADCP le long de la section
if save_output == 1;
u_sadcp=Ulnt; v_sadcp=Vlnt; lat_sadcp=LatSta; lon_sadcp=LonSta; dist_inter_profil=Dsta; z_adcp=-zl; vorth_sadcp= Vortho;
save([rept file_save],'u_sadcp','v_sadcp', 'vorth_sadcp', 'lat_sadcp', 'lon_sadcp', 'dpair', 'dist_inter_profil', 'z_adcp','phi');
end
%% Plot profil des vitesses ADCP perpendiculaires
% position plot
if strcmp(section,'ride')
    fposi=[.1 .13 .7 .8]; % position départ et largeur plot #ride
    cposi=[.82 .15 .02 .3]; %position de la colorbar
else
    fposi=[.1 .13 .5 .8]; % position départ et largeur plot #north, ovide, south
    cposi=[.62 .15 .02 .3]; %position de la colorbar
end

bw=0;
ZLim=[-1500 0]; % profondeur max pour le tracé
if strcmp(xref,'lon'); X=LonSta; xlab='Longitude �E'; elseif strcmp(xref,'lat'); X=LatSta; xlab='Latitude �N'; end

Vplot=Vortho' ;

figure('Color','w');
set(gcf,'PaperType','A4','PaperOrientation','portrait','PaperUnits','centimeters','PaperPosition',[1,15,19,10],'Posi',[185 0 1200 800]);
addpath('/home4/homedir4/perso/isalaun/Matlab/toolbox/my_colormap');
load vmap0
[C,H]=contourf(X,zl,Vplot,-.4:.1:.4); hold on;
set(gca,'YLim',ZLim, 'Posi',fposi,'FontSize',12);
xlabel(xlab); ylabel('Depth (m)');

title(titre,'FontSize',12);
limcol=[-0.40 .40]; vcol=-.4:.1:.4; caxis(limcol); colormap(vmap);
[C0,H0]=contour(X,zl,Vplot,-.4:.1:.4,'k');
set(H0,'LineWidth',0.2);

cbar = colorbar; 
cbar.Label.String = 'm/s'
set(cbar, 'position', cposi)

if save_figure == 1;
    saveas(gcf, ['../figures/',titre_fig,'.png'])
end

%%
if save_figures_rapport == 1;
    
    switch sadcp
    case 'OS38'
figure('Color','w');
set(gcf,'PaperType','A4','PaperOrientation','portrait','PaperUnits','centimeters','PaperPosition',[1,15,19,10],'Posi',[185 0 1200 800]);
addpath('../toolbox/my_colormap');
load vmap0
[C,H]=contourf(X,zl,Vplot,-.4:.1:.4); hold on;
set(gca,'YLim',ZLim, 'Posi',fposi,'FontSize',12);
xlabel(xlab); ylabel('Depth (m)');
a1=gca;
%title(a1,titre,'FontSize',12);
limcol=[-0.40 .40]; vcol=-.4:.1:.4; caxis(limcol); colormap(vmap);
[C0,H0]=contour(X,zl,Vplot,-.4:.1:.4,'k');
set(H0,'LineWidth',0.2);

cbar = colorbar; 
cbar.Label.String = 'm/s'
set(cbar, 'position', cposi)        
        
    case 'OS150' 
        
figure('Color','w');
set(gcf,'PaperType','A4','PaperOrientation','portrait','PaperUnits','centimeters','PaperPosition',[1,15,19,10],'Posi',[185 0 1200 800]);
addpath('../toolbox/my_colormap');
load vmap0
[C,H]=contourf(X,zl,Vplot,-.4:.1:.4); hold on;
set(gca,'YLim',ZLim, 'Posi',fposi,'FontSize',12);
xlabel(xlab); ylabel('Depth (m)');
a1=gca;
%title(a1,titre,'FontSize',12);
limcol=[-0.40 .40]; vcol=-.4:.1:.4; caxis(limcol); colormap(vmap);
[C0,H0]=contour(X,zl,Vplot,-.4:.1:.4,'k');
set(H0,'LineWidth',0.2);

cbar = colorbar; 
cbar.Label.String = 'm/s'
set(cbar, 'position', cposi)

    end
    
    saveas(gcf, ['../figures/',titre_fig,'.png'])
end

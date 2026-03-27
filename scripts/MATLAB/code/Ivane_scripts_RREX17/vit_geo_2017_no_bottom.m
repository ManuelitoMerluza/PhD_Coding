% author(s): I. Salaun 10/2018 from H. Mercier & T. Petit (RREX2015)
%
% description : 
% Computation of geostrophic velocities across each hydrographic section of 
% the RREX2017 cruise (with or without bottom triangles, bottom triangles can be extrapolated by 4 different methods: planfit, 
% polyfit, cstslope, horizontale extrap (ie Ganachaud A., 1999)) and a reference depth (at surface or at 1200-m depth). 
% Derived from the thermal wind equation by using the dynamical height.
%
% see also : vit_SADCP_2017.m vit_geo_abs_2017.m 

%% ========================================================================
clear all; 
close all;

%addpath(genpath('/home/lpo5/herle/matlab_environnement_de_traitement/devlp/logiciels_lpo/matlab/outils_matlab/seawater/seawater_330_its90_lpo'));
%addpath(genpath('/home/lpo5/herle/matlab_environnement_de_traitement/devlp/logiciels_lpo/matlab/outils_matlab/'seawater/gsw_matlab_v3_04));
addpath('../toolbox/seawater/seawater_330_its90_lpo/');
%addpath('/home4/homedir4/perso/isalaun/Matlab/toolbox/seawater/gsw_matlab_v3_04/');
%doc sw et gsw: http://www.teos-10.org/pubs/gsw/v3_04/pdf/Getting_Started.pdf
%% ========================================================================
save_vgeo = 0;
save_figure = 0;
% CHOIX DE LA SECTION parmi les sections 'north', 'ovide','south' , 'ride'
section = 'ride';

% Choix du niveau de reference STA
ref = 'vect';

%% ========================================================================
% Definition des stations hydro pour chaque section
if strcmp(section,'north')
    xref='lo'; % lat/lg en degre N/E
    STA = [44:55 57]; STA=STA(:); nsta=size(STA,1); npair=nsta-1;
    titre_fig = 'vitesses_geo_rrex17_north';
elseif strcmp(section,'ovide')
    xref='lo';
    STA = [18:20 22:24 27:28 43:-1:41 38:-1:31];STA=STA(:); nsta=size(STA,1); npair=nsta-1;
    titre_fig = 'vitesses_geo_rrex17_ovide';
elseif strcmp(section,'south')
    xref='lo';
    STA = [1:8 11:17]; STA=STA(:); nsta=size(STA,1); npair=nsta-1;
    titre_fig = 'vitesses_geo_rrex17_south';
elseif strcmp(section,'ride')
    xref='lat';
    STA = [56:69 76:125]; STA=STA(:); nsta=size(STA,1); npair=nsta-1;
    titre_fig = 'vitesses_geo_rrex17_ride';
end

%% ========================================================================
%%% Lecture des fichiers hydro
%fctd = '/home/lpo5/HYDROCEAN/MLT_NC/LPO/RREX/RREX17/rr17_PRES.nc';
fctd = '../../DATA/HYDRO/RREX2017/ctd/nc/rr17_PRES.nc';

S = ncread(fctd,'PSAL'); 
% on sectionne la data et supprime la premiere station 0 (station test)
S = S(:,2:end); S = S(:,STA);
T = ncread(fctd,'TPOT'); 
T = T(:,2:end); T = T(:,STA);
P = ncread(fctd,'PRES'); 
P = P(:,2:end); P = P(:,STA);
% hauteur dyn dans fichier hydro
H = ncread(fctd,'DYNH'); 
H = H(:,2:end); H = H(:,STA);

lat = ncread(fctd,'LATITUDE'); 
lat = lat(2:end); lat = lat(STA);
lg = ncread(fctd,'LONGITUDE'); 
lg = lg(2:end); lg = lg(STA);

%% ========================================================================

%%% Calcul de la hauteur dynamique par SeaWater_90_lpo
ga = sw_gpan(S,T,P);

%%% Pour le calcul du triangle de fond
addpath('../toolbox/ganachaud/Ml/routines');

%%% determination des pressions max pour toutes les stations
n = size(P,1);
m = size(P,2);
for i = 1:m
    M = P(:,i);
    inan = isnan(M);
    ind_keep = find(inan==0);
    pmae(i) = ind_keep(end)-1;  %-1 car valeur pmae = indice ind_keep-1
end


%%% Determination des profondeurs max atteinte par la ctd pour chaque pair
ipair = [1:m-1];
% ip = difference des prof des stations 2 a 2 (pente positive/negative) 
ip=find(diff(pmae)>=0); im=find(diff(pmae)<0);
% tableau des pressions sh (col1) et dp (col2) pour chaque pair
% pression en db donc indice = valeur+1
ishdp(ip,1)=pmae(ip)+1; ishdp(ip,2)=pmae(ip+1)+1;
ishdp(im,1)=pmae(im+1)+1; ishdp(im,2)=pmae(im)+1;
% tableau des indices de stations sh (iss) et dp (isd) pour chaque pair
iss(ip) = ip; iss(im) = im+1; 
isd(ip) = ip+1; isd(im) = im;

  
%%% dynamic height of the pair
sgpan = ga(:,iss);
dgpan = ga(:,isd);
pgpan = 0.5 * (sgpan + dgpan); 
%% ========================================================================
%%% Calcul de la vitesse géostrophique

% niveau de reference
switch ref
    case 'CDL'
        vect = inf(1,m-1); %deep common level
    case 'vect'
        vect = 1200;
end

%utilisation de refc et dpair..
[us,xu,refc,reffond,dpair]=vgeo_hm(P,H,lat,lg,xref,vect,pmae); 
dpair = dpair';

clear us xu reffond 

%sgpan_1 = sgpan; dgpan_1 = dgpan;
%%% triangle de fond (planfit, polyfit, cstslope)
% calcul de hdyn dans le triangle de fond 
Slat = lat ; Slon = lg;

%global Slat Slon
var = diff(pmae);
d_interp_p=NaN*ones(size(sgpan,1),length(dpair)); %d_interp_poly=NaN*ones(size(sgpan,1),length(dpair));


% selection du niveau de reference
switch ref
    case 'vect' 
        %vect = 0.*ones(1,m-1); % ici ref en surface
        % on selectionne la station au niveau commun DCL 
        if ~isempty(ip), reffondd(ip)=pmae(ip); end; 
        if ~isempty(im), reffondd(im)=pmae(im+1); end;
  
        vect = reffondd;
        for i = 1:m-1
            irefc(i) = find(P(:,i)==vect(i));
        end    
               
end

%%% calcul de vgeo via le gradient de hauteur dyn
% calcul de coriolis
latpair=(lat(1:m-1)+lat(2:m))/2;
f=2*7.29e-5*sin(latpair/180*pi);
for i=1:m-1,
  if isempty(irefc), irefc=max(find(P<=reffondd(i))); end;
  if var(i)>=0
      % hauteur dynamique au niveau de reference pour chaque couple de stations
      href = [sgpan(irefc(i),i) dgpan(irefc(i),i)]; 
      htot = [sgpan(:,i) dgpan(:,i)];
  else
      href = [dgpan(irefc(i),i) sgpan(irefc(i),i)];
      htot = [dgpan(:,i) sgpan(:,i)];
  end
  Hf=htot-ones(n,1)*href;
  dH=(diff(Hf'))'; 
  ud(:,i)=dH/(f(i)*dpair(i)); 
end;     
       
%%% Retrait de la vitesse a 1200m maintenant 0 est definit comme niveau de
%%% ref pour uh et ud: generalisation pour toutes les sections
vect2 = repmat(1200,1,m-1);
for i=1:m-1
      Md = ud(:,i);
      inand = isnan(Md);
      indd = find(inand==0);
      pmae_D(i) = indd(end);

end

    ireftouchfondd = find(pmae_D-vect2<0);  
    vect2(ireftouchfondd)=pmae_D(ireftouchfondd); 

for i=1:m-1
        ud(:,i) = ud(:,i) - ud(vect2(i),i);
end

%% ========================================================================
%%% Plot de la vitesse geostrophique (positif a droite du bateau)

%%% Calcul des positions geo lat/lon au milieu des stations hydro
lgmoy = (lg(1:length(lg)-1) + lg(2:length(lg))) ./2; 
latmoy = (lat(1:length(lat)-1) + lat(2:length(lat))) ./2;
if strcmp(section,'ride');
    Xmoy = latmoy;
else 
    Xmoy = lgmoy;
end

%%% conversion P dbar en metre
P = repmat([1:size(P,1)]',1,m-1);
P = sw_dpth(P(:,1:m-1),latmoy');

%%% cache blanc de la vrai bathy du bateau (RREX) = fct fill
%bathy en metre
[bathy_ship,X,Y]=bathy_bateau(section); %si on veut mettre bathy RREX15..

%load(['/home/lpo5/RREX17/SCIENCE/Tillys/TP/Bathy_Sonde/Bathy_RREX17/bathy_rr17_nord.mat']);
%bth_sec = bth_sec.*1e-3;

%%% trace la coupe de vitesse

        U = ud;
   
    vm=load('bwr.txt'); 
    vcol=[-0.3:0.01:0.3];
    ncol=length(vcol)-1;
    ncol2=ncol/2;
    npas=floor(64/ncol2);
    vm2=vm(1:npas:npas*ncol2,:);
    vm2=[vm2;flipud(vm(end:-npas:end-npas*ncol2+1,:))];
    switch section 
        case {'ovide','north','south'}
            figure
            [c,h]=contourf(repmat(Xmoy',size(P,1),1),-P,U,[-0.3:0.01:0.3]);
            colormap(vm2);
            colorbar  
            caxis([-0.3 0.3])
            switch section
                case 'nord'
                    set(gca,'ylim',[-3000 0])
                    set(gca,'xlim',[-33.0008723 -20.9687344])
                case 'ovide'
                    set(gca,'ylim',[-3117.20995 0])
                    set(gca,'xlim',[-37.04 -27.33761])
                case 'sud'
                    set(gca,'ylim',[-3200 0])
                    set(gca,'xlim',[-38 -31.3])
            end
            ylabel('Depth (m)')
            xlabel('Longitude (°W)')
            
            % On les numÃ©rote
            xlab = num2str(STA,'%g');
            for ii=1:length(latmoy)
                testa(ii)=text(Xmoy(ii),0,xlab(ii,:),'Horizo','center','Color','k','Vertical','bottom');
            end
            set(testa,'FontName','Arial Narrow','FontSize',6,'FontAngle','italic','FontWeight','b');

        case 'ride'
            figure
            ax1 = gca;
            hold on
            [c,h]=contourf(repmat(Xmoy',size(S,1),1),-P,U,[-0.3:0.01:0.3]);
             xlabel('latitude (°N)')
             ylabel('Depth (m)')
             set(gca,'ylim',[-4350 0])
             set(gca,'xlim',[50.34861 63.3498])
             hold on
             colormap(vm2);
             caxis([-0.3 0.3])
             colorbar
                    
             % On les numÃ©rote
             xlab = num2str(STA,'%g');
             for ii=1:length(latmoy)
                 testa(ii)=text(latmoy(ii),0,xlab(ii,:),'Horizo','center','Color','k','Vertical','bottom');
             end
             set(testa,'FontName','Arial Narrow','FontSize',6,'FontAngle','italic','FontWeight','b');
               
      
    end


if save_vgeo == 1
    saveas(gcf, ['../figures/',titre_fig,'.png'])
end
%% ========================================================================
%%% Sauvegarde des vitesses geostrophiques pour chaque pair de station
    
if save_vgeo == 1

    rept = '../matlab_output_RREX17/';
    for i=1:npair
        % generation du nom du fichier de sortie
        fic_vgeo = ['vitesse_geo/vgeo_' section '_no_bottom_' num2str(STA(i),'%3.3d') '_' num2str(STA(i+1),'%3.3d')]; 
        display(['Traitement du fichier ' fic_vgeo]);
        dpair_geo=dpair(i); vgeo=ud(:,i); zl=P(:,find(max([pmae(i);pmae(i+1)]))); zl = zl(:); lat_geo = latmoy(i); lon_geo = lgmoy(i); ref_up_bott_triangle = ishdp(i,1); ref_d_bott_triangle = ishdp(i,2); 
        save([rept fic_vgeo '.mat'],'dpair_geo','vgeo', 'zl', 'refc','lat_geo','lon_geo','ref_up_bott_triangle','ref_d_bott_triangle');
    end
end

%% ========================================================================



% author(s): I. Salaun 10/2018 new 06/2020
%
%description : 
% Computation of absolute geostrophic velocities across each hydrographic 
% section of the RREX2017 cruise 
% Geostrophic velocities constrained by SADCP velocities (OS38) horizontally 
% and vertically filtred (2km -16m) and averaged between stations at a 
% reference depth determined by comparison between geostrophic and ADCP 
% profiles 
%
%see also : vit_geo_2017.m  section2km_SADCP_2017.m

%% ========================================================================
close all; 
clear all;

addpath(genpath('../toolbox/matlab/matlab/adcp_lpo_V6.2')); %meanoutnan
addpath(genpath('../toolbox/matlab/matlab/outils_matlab/lpo')); %Lanczos
addpath(genpath('../toolbox/netcdf_lpo'));
addpath(genpath('../toolbox/matlab/matlab/outils_matlab/statistique'));
addpath(genpath('../toolbox/my_colormap'));
%% ========================================================================
plot_figures_ADCP = 0;
plot_figures_profils = 0;
save_figure = 0;

save_vabs = 0;
save_trsp = 0;

% choix du fichier ctd
fctd = '../../DATA/HYDRO/RREX2017/ctd/nc/rr17_PRES.nc';

% CHOIX DE LA SECTION parmi les section='south','ovide', north', 'ride'
section='ride'; display(['section ' section]);

% Execution de la correction spe aux zones de fractures CGFZ/BFZ ou non
corr=1;

corr_internal_wave = 0; %si vref moyen pour presence onde interne

manual_REF = 0;

methode = 'no_bottom'; %'pfit' (fit a plane), 'polyfit' (fit a polynomial), 'cstslope' (constant slope), 'horiz' (horizontal extrapolation)

bottom_v = 0;
%% ========================================================================

if strcmp(section,'north')

    
elseif strcmp(section,'ovide')

    
 elseif strcmp(section,'south')
 
    
 elseif strcmp(section,'ride')
    titre='vitesses geostrophiques absolues RREX 2017 Reykjanes Ride Section'; 
    titre_fig = 'vitesses_geo_abs_rrex17_ride'; 
    STA = [56:69 76:125];STA=STA(:); nsta=size(STA,1); npair=nsta-1; 
    
    tit='RREX 2017 Ride Section';
    file_save='../matlab_output_RREX17/vitesse_adcp/vitesse_sadcp_RREX17_OS150_ride_08_015_38_fhv1_sec_02mx1';
    sign=-1;
    xref='lat'; 
 
end

%%% lecture des donnees sadcp 
load(file_save,'u_sadcp','v_sadcp', 'vorth_sadcp', 'lat_sadcp', 'lon_sadcp', 'dpair', 'dist_inter_profil', 'z_adcp');
z_adcp=abs(z_adcp);
nsec=size(vorth_sadcp,1); nz=length(z_adcp);

%% ========================================================================
%%% INTERPOLATION ET FILTRAGE DES DONNEES ADCP
% Figure de la portée des ADCPs
if plot_figures_ADCP == 1
    
figure;
pcolor(repmat([1:nsec]',1,size(vorth_sadcp,2)),repmat(z_adcp',size(vorth_sadcp,1),1),vorth_sadcp)
title('vorth_OS sur grille initiale avant bouchage trous en surface','Interpreter','none');
hold on;
shading flat;
set(gca,'YDir','reverse');
set(gca,'XDir','reverse');
ylim([0 1500]);

end

% Boucher les trous en surface dans les donnees vorth_sadcp
vorth_sadcp_good=~isnan(vorth_sadcp);
[i,j]=find(vorth_sadcp_good,1,'first');
for i=1:nsec
    
    j=find(vorth_sadcp_good(i,:),1,'first');
    if j~= 1
    vorth_sadcp(i,1:j-1)=vorth_sadcp(i,j);
    end
    
end

% Figure de la porté des ADCPs
if plot_figures_ADCP == 1

figure;
pcolor(repmat([1:nsec]',1,size(vorth_sadcp,2)),repmat(z_adcp',size(vorth_sadcp,1),1),vorth_sadcp)
title('vorth_OS sur grille initiale apres bouchage trous en surface','Interpreter','none');
hold on;
shading flat;
set(gca,'YDir','reverse');
set(gca,'XDir','reverse');
ylim([0 1500]);

end

% pour les valeurs a NaN interpolation (surface fond)
isec_bad=isnan(vorth_sadcp(:,1)); isec_bad=find(isec_bad); 

for i=1:size(isec_bad)
        vorth_sadcp(isec_bad(i),:)=0.5*(vorth_sadcp(isec_bad(i)-1,:)+vorth_sadcp(isec_bad(i)+1,:));    
end

% Figure de la porté des ADCPs
if plot_figures_ADCP == 1

figure;
pcolor(repmat([1:nsec]',1,size(vorth_sadcp,2)),repmat(z_adcp',size(vorth_sadcp,1),1),vorth_sadcp)
title('vorth_OS sur grille initiale apres interpolation NaN','Interpreter','none');
hold on;
shading flat;
set(gca,'YDir','reverse');
set(gca,'XDir','reverse');
ylim([0 1500]);

end
%close all
% Question: modifier si ADCP OS150
% valeurs a NaN ponctuels pour OS150 corrigées manuellement! :

vorth_sadcp(490,6)=0.5*(vorth_sadcp(490,5)+vorth_sadcp(490,7));
vorth_sadcp(125,8)=0.5*(vorth_sadcp(125,7)+vorth_sadcp(125,9));
vorth_sadcp(124,9:14)=0.5*(vorth_sadcp(12',8)+vorth_sadcp(125,15));
vorth_sadcp(43,10:12)=0.5*(vorth_sadcp(43,9)+vorth_sadcp(43,13));
vorth_sadcp(10,3)=0.5*(vorth_sadcp(10,2)+vorth_sadcp(10,4));
vorth_sadcp(10,6:8)=0.5*(vorth_sadcp(10,5)+vorth_sadcp(10,9));

% Figure de la porté des ADCPs
if plot_figures_ADCP == 1

figure;
pcolor(repmat([1:nsec]',1,size(vorth_sadcp,2)),repmat(z_adcp',size(vorth_sadcp,1),1),vorth_sadcp)
title('vorth_OS sur grille initiale apres interpolation NaN autre','Interpreter','none');
hold on;
shading flat;
set(gca,'YDir','reverse');
set(gca,'XDir','reverse');
ylim([0 1500]);

end
% Interpolation des donnees SADCP sur une mm grille verticale (pas=5m) 
z_keep = [0 300];
z_grid = [25:5:z_keep(2)];  % z_grid(1) doit etre ajuste de maniere a  etre a une profondeur superieure au premier niveau sadcp valide sinon le filtre de lanczos propage les nan
z_interp = z_adcp(z_adcp <= z_keep(2) & z_adcp >= z_keep(1));

Vorth_OS150 = vorth_sadcp(:,z_adcp <= z_keep(2) & z_adcp >= z_keep(1)); 
Vinterp1 = interp1(z_interp,Vorth_OS150',z_grid); 

if plot_figures_ADCP == 1
    
figure;
pcolor(repmat([1:nsec]',1,size(Vinterp1',2)),repmat(z_grid,size(Vinterp1',1),1),Vinterp1')
title('vorth_OS interpole a 5 m dans la bande z_keep','Interpreter','none');
hold on;
shading flat;
set(gca,'YDir','reverse');
set(gca,'XDir','reverse');
ylim([0 1500]);

end
%% ------------------------------------------------------------------------
% Filtrage de Lanczos des donnees sur la verticale (400m):
vorth_filt_vert = NaN(length(z_grid),nsec);

for i=1:nsec    
    ind_nan = isnan(Vinterp1(:,i)); ind_nan_un = find(ind_nan ==1); ind_ok = ind_nan_un(1)-1;
    
    if ind_ok<80 np=round(ind_ok/2); else np=40; end
    
    vorth_filt_vert(1:ind_ok,i) = lanczos(Vinterp1(1:ind_ok,i),0.002,np);
    
end

vorth_filt_vert = vorth_filt_vert'; z_adcp = z_grid; Vinterp1 = Vinterp1';
nz=length(z_grid);

if plot_figures_ADCP == 1
figure;
pcolor(repmat([1:nsec]',1,size(vorth_filt_vert,2)),repmat(z_adcp,size(vorth_filt_vert,1),1),vorth_filt_vert)
title('vorth filtre sur la verticale');
hold on;
shading flat;
set(gca,'YDir','reverse');
set(gca,'XDir','reverse');
ylim([0 1500]);
end

% Filtrage de Lanczos sur l'horizontal (8km):  

for i=1:nz   
    vorth_filt_horiz(:,i) = lanczos(vorth_filt_vert(:,i),0.04,10);      
end

if plot_figures_ADCP == 1
figure;
pcolor(repmat([1:nsec]',1,size(vorth_filt_horiz,2)),repmat(z_adcp,size(vorth_filt_horiz,1),1),vorth_filt_horiz)
title('vorth filtre sur horizontal');
hold on;
shading flat;
set(gca,'YDir','reverse');
set(gca,'XDir','reverse');
ylim([0 1500]);
end

%close all

vorth_use = vorth_filt_horiz; %Utilisé comme vitesse ref..
plot_compare_filt_horiz = 0;
%Vinterp1 (sans filtrage) vorth_filt_vert (filtre de Lanczos vertical) 
% ou vorth_filt_horiz (filtre de Lanczos vertical+horizontal)

%% ------------------------------------------------------------------------
%%% DETERMINATION DE VREF ET MOYENNE DES DONNEES SADCP ENTRE DEUX STATIONS HYDROLOGIQUES

lon_ctd = ncload(fctd,'LONGITUDE'); lon_ctd = lon_ctd(2:end); lon_ctd = lon_ctd(STA);
lat_ctd = ncload(fctd,'LATITUDE'); lat_ctd = lat_ctd(2:end); lat_ctd = lat_ctd(STA);

% Definition de la couche de reference (fonction de la puissance du ADCP)
z_ref = [200;250]; %OS150


z_ref_det = NaN(nsec,2); %couche ref determine pour chaque profil adcp

for isec=1:nsec
    
    ind_nan = isnan(vorth_use(isec,:)); ind_nan_un = find(ind_nan ==1); ind_fond = ind_nan_un(1);
    z_fond = round(z_adcp(ind_fond))
    
    if z_fond>=z_ref(1)
        z_ref_det(isec,:) = [z_fond-150;z_fond-50]; %100m mais plus profonde que 50 pour eviter ageo
    else
        z_ref_det(isec,:) = [50;z_fond-10]; %tres peu profond on prend une fine couche en surface
    end
    
        
end

% Determination de la couche ref commune entre STA
z_vref_use_pair=NaN(npair,2); z_vref_use=NaN(nsec,2);

for i=1:npair
    
    if strcmp(section,'ride'); 
        ok = lat_sadcp <= lat_ctd(i) & lat_sadcp >= lat_ctd(i+1);
        
    elseif strcmp(section,'south') || strcmp(section,'north');
        ok = lon_sadcp >= lon_ctd(i) & lon_sadcp <= lon_ctd(i+1);
        
    elseif strcmp(section,'ovide');
        ok = lon_sadcp <= lon_ctd(i) & lon_sadcp >= lon_ctd(i+1);   
    end
        
    sup_sec = nanmin(z_ref_det(ok,1)); if isempty(sup_sec) sup_sec = NaN; end
    inf_sec = nanmin(z_ref_det(ok,2)); if isempty(inf_sec) inf_sec = NaN; end
     
    z_vref_use_pair(i,:) = [sup_sec,inf_sec];
    
    z_vref_use(find(ok==1),1) = sup_sec;
    z_vref_use(find(ok==1),2) = inf_sec;
end

%Pour comparaison avec AVISO REF surface!
% z_vref_use_pair=NaN(npair,2); z_vref_use=NaN(nsec,2);
% 
% for i=1:npair
%     z_vref_use_pair(i,1) = 50; z_vref_use_pair(i,2) = 100;
% end
% 
% for i=1:nsec
%     z_vref_use(i,1) = 50; z_vref_use(i,2) = 100;
% end

if plot_figures_ADCP == 1
figure;
pcolor(repmat([1:nsec]',1,size(vorth_use,2)),repmat(z_adcp,size(vorth_use,1),1),vorth_use)
title('couche de reference avant correction');
hold on;
shading flat;
set(gca,'YDir','reverse');
set(gca,'XDir','reverse');

plot([1:nsec],z_vref_use(:,1),'r--','LineWidth',1)
plot([1:nsec],z_vref_use(:,2),'k--','LineWidth',1)

end

if manual_REF == 1
    
for i=1:npair
    
    if strcmp(section,'ride'); 
        ok = lat_sadcp <= lat_ctd(i) & lat_sadcp >= lat_ctd(i+1);
        
    if i==1; %paire 56
    z_vref_use_pair(i,:) = [60,70];    
    z_vref_use(find(ok==1),1) = 60;
    z_vref_use(find(ok==1),2) = 70;        
%     elseif i==35 || i==36 || i==37; %paires 96 97 98
%     z_vref_use_pair(i,:) = [270,870];    
%     z_vref_use(find(ok==1),1) = 270;
%     z_vref_use(find(ok==1),2) = 870;
%     elseif i==39 || i==40 || i==41; %paires 100 101 102
%     z_vref_use_pair(i,:) = [200,900];    
%     z_vref_use(find(ok==1),1) = 200;
%     z_vref_use(find(ok==1),2) = 900;    
%     elseif i== 43; %paire 104
%     z_vref_use_pair(i,:) = [250,950];    
%     z_vref_use(find(ok==1),1) = 250;
%     z_vref_use(find(ok==1),2) = 950;    
    end
    
    elseif strcmp(section,'north');
        ok = lon_sadcp >= lon_ctd(i) & lon_sadcp <= lon_ctd(i+1);
        
    elseif strcmp(section,'south');
        ok = lon_sadcp >= lon_ctd(i) & lon_sadcp <= lon_ctd(i+1);
          
    elseif strcmp(section,'ovide');
        ok = lon_sadcp <= lon_ctd(i) & lon_sadcp >= lon_ctd(i+1);   
    end
end    
    
    
if plot_figures_ADCP == 1
figure;
pcolor(repmat([1:nsec]',1,size(vorth_use,2)),repmat(z_adcp,size(vorth_use,1),1),vorth_use)
title('couche de reference après correction');
hold on;
shading flat;
set(gca,'YDir','reverse');
set(gca,'XDir','reverse');

plot([1:nsec],z_vref_use(:,1),'r--','LineWidth',1)
plot([1:nsec],z_vref_use(:,2),'k--','LineWidth',1)

end   

end



for isec=1:nsec
    
        v_ref(isec) = meanoutnan(vorth_use(isec,z_adcp <= z_vref_use(isec,2) & z_adcp >= z_vref_use(isec,1)));     
        v_ref_nf(isec) = meanoutnan(Vinterp1(isec,z_adcp <= z_vref_use(isec,2) & z_adcp >= z_vref_use(isec,1)));
        
        v_ref_filt(isec) = meanoutnan(vorth_filt_horiz(isec,z_adcp <= z_vref_use(isec,2) & z_adcp >= z_vref_use(isec,1)));
        
        iok = find(z_adcp <= z_vref_use(isec,2) & z_adcp >= z_vref_use(isec,1));
        
%         if plot_figures_profils == 1
%         figure;
%         hold on;
%         plot(Vinterp1(isec,:),-z_adcp,'g','LineWidth',1) %profil ADCP non filtré sur la verticale
%         plot([v_ref_nf(isec) v_ref_nf(isec)],-[z_adcp(iok(1)) z_adcp(iok(end))],'g--','LineWidth',1)
%         plot(vorth_use(isec,:),-z_adcp,'k','LineWidth',1.5) %profil ADCP filtré sur la verticale
%         %plot(vorth_use(isec,iok),-z_adcp(iok),'r','LineWidth',1.5) %profil ADCP filtré sur la verticale couche ref
%         plot([v_ref(isec) v_ref(isec)],-[z_adcp(iok(1)) z_adcp(iok(end))],'r--','LineWidth',1) %profil ADCP moyenne dans la couche ref
%         
%         
%         plot([v_ref(isec)-0.1 v_ref(isec)+0.1],[-z_vref_use(isec,1) -z_vref_use(isec,1)],'k--','LineWidth',0.5)
%         plot([v_ref(isec)-0.1 v_ref(isec)+0.1],[-z_vref_use(isec,2) -z_vref_use(isec,2)],'k--','LineWidth',0.5)       
%         
%         if save_figure == 1;
%             saveas(gcf, ['../figures/prof_vSADCP_vgeo_RREX17/prof_vSADCP_ref_' section '_' num2str(isec) '_filtre400m_RREX17.png'])
%         end
%         %pause
%         close all
%         end

end

v_ref = v_ref'; v_ref_filt = v_ref_filt';

%v_ref_filt_after = lanczos(v_ref,0.04,20); v_ref_filt_after=v_ref_filt_after(:); 
%pour comparer le filtrage horiz avant et après la moyenne entre STA geo,
%fonctionne si vorth_use = vorth_filt_vert (pas encore filtré sur horiz..)

v_filt_vert_moy = NaN(npair,length(z_grid));
v_no_filt_vert_moy = NaN(npair,length(z_grid));

for i=1:npair
    
    if strcmp(section,'ride'); 
        ok = lat_sadcp <= lat_ctd(i) & lat_sadcp >= lat_ctd(i+1);
        
    elseif strcmp(section,'south') || strcmp(section,'north');
        ok = lon_sadcp >= lon_ctd(i) & lon_sadcp <= lon_ctd(i+1);
        
    elseif strcmp(section,'ovide');
        ok = lon_sadcp <= lon_ctd(i) & lon_sadcp >= lon_ctd(i+1);   
    end   
    
    v_ref_moy(i) = meanoutnan(v_ref(ok));
    v_ref_filt_horiz_moy(i) = meanoutnan(v_ref_filt(ok));
    %v_ref_filt_horiz_after_moy(i) = meanoutnan(v_ref_filt_after(ok));
    
    iok = find(z_grid <= z_vref_use_pair(i,2) & z_grid >= z_vref_use_pair(i,1));
    
    v_filt_vert_moy_tot(i,:) = meanoutnan(vorth_use(ok,:));
    v_filt_vert_moy(i,iok) = meanoutnan(vorth_use(ok,iok));
    v_no_filt_vert_moy(i,iok) = meanoutnan(Vinterp1(ok,iok));
    
end
v_ref_moy = v_ref_moy';

if  plot_compare_filt_horiz == 1
figure
hold on
plot(lat_sadcp,v_ref,'k');
plot(lat_sadcp,v_ref_filt,'b');
plot((lat_ctd(1:end-1)+lat_ctd(2:end))/2,v_ref_moy,'r')
plot((lat_ctd(1:end-1)+lat_ctd(2:end))/2,v_ref_filt_horiz_moy,'g')

%plot(lat_sadcp,v_ref_filt_after,'b--','LineWidth',2);
%plot((lat_ctd(1:end-1)+lat_ctd(2:end))/2,v_ref_filt_horiz_after_moy,'g--','LineWidth',2)
end
%close all
%--------------------------------------------------------------------------
%% CALAGE DU PROFIL GEOSTROPHIQUE SUR LA VITESSE SADCP  DANS LA COUCHE DE REFERENCE SELECTIONNEE
%%% Ajout d'une vitesse de reference aux vitesses geostrophiques
% lecture du fichier vitesse geostrophique
dpair=[]; v=[]; z=[]; zref=[]; lat=[]; lon=[]; ref_up_bott_tr=[]; ref_d_bott_tr=[];

for i=1:npair
    fic_vgeo = ['vitesse_geo/vgeo_' section '_' methode '_' num2str(STA(i),'%3.3d') '_' num2str(STA(i+1),'%3.3d')];
    %load(['/home4/homedir4/perso/isalaun/Matlab/matlab_output_RREX17/' fic_vgeo '.mat'],'dpair_geo','vgeo', 'zl', 'refc','lat_geo','lon_geo','ref_up_bott_triangle');
    load(['../matlab_output_RREX17/' fic_vgeo '.mat'],'dpair_geo','vgeo', 'zl', 'refc','lat_geo','lon_geo','ref_up_bott_triangle');
    dpair=[dpair dpair_geo]; v=[v vgeo]; z=[z zl]; zref=[zref refc]; lat=[lat lat_geo]; lon=[lon lon_geo]; ref_up_bott_tr = [ref_up_bott_tr ref_up_bott_triangle];
    
    if bottom_v == 1;
        load(['../matlab_output_RREX17/' fic_vgeo '.mat'],'ref_d_bott_triangle');
        ref_d_bott_tr = [ref_d_bott_tr ref_d_bott_triangle];
    end    
end;

% correction du signe de la vitesse

if strcmp(section,'ride') || strcmp(section,'south') || strcmp(section,'north');
    v=sign*v;
elseif strcmp(section,'ovide');
    v(:,1:7)=sign_est*v(:,1:7);
    v(:,8:end)=sign_ouest*v(:,8:end);
end

    
% on passe les tableaux de sortie en vecteur ligne. v et z de
% dimension (nz_geo,npair). zat profil avec valeur maximum de z
dpair=dpair(:); lat=lat(:); lon=lon(:); zref=zref(:);
zl = NaN*ones(length(z),npair);
for i=1:npair
    ind_nan = find(isnan(v(:,i))==1);
    if isempty(ind_nan); 
        zl(:,i)=z(1:size(v,1));
    else
        zl(1:ind_nan(1)-1,i)=z(1:ind_nan(1)-1); 
    end
end
[zm,k]=max(zl,[],1);[~,l]=max(zm); zat=z(:,l);

    
 %%% Valeur de reference utilisÃ©e pour contraindre les donnees SADCP 
 % pas d'interpolation pour les donnees moyennees avec "station" car latitude proche
 v_ref1 = v_ref_moy; lref1=z_vref_use_pair;
 
 if strcmp(xref,'lat');
     xlab='Latitude (°N)'; X1=lat;
 elseif strcmp(xref,'lon');
     xlab='Longitude (°E)'; X1=lon;
 end

 
%%% on utilise un v_ref1 moyen commun pour les stations proches aux zones de fractures (attÃ©nuer le bruit ageo)
if corr==1 & strcmp(section,'ride');
    moy_BFZ = meanoutnan(v_ref1(25:29)); % Profil geo et ADCP proche a la paire 30: profils pas perturbe de la BFZ   
    moy_CGFZ = meanoutnan([v_ref1(46) v_ref1(48)]);
    v_ref1 = [v_ref1(1:24)' repmat(moy_BFZ,1,5) v_ref1(30:46)' repmat(moy_CGFZ,1,1) v_ref1(48:end)'];
    
    % idem pour les couches z_ref
    Z_BFZ = meanoutnan(lref1(25:29,1)); 
    Z_CGFZ = meanoutnan(lref1(46:48,1));
    lref1(:,1) = [lref1(1:24,1)' repmat(Z_BFZ,1,5) lref1(30:46,1)' repmat(Z_CGFZ,1,1) lref1(48:end,1)'];
    
    Z_BFZ = meanoutnan(lref1(25:29,2)); 
    Z_CGFZ = meanoutnan(lref1(46:48,2));
    lref1(:,2) = [lref1(1:24,2)' repmat(Z_BFZ,1,5) lref1(30:46,2)' repmat(Z_CGFZ,1,1) lref1(48:end,2)'];
end

%%% on utilise un v_ref1 moyen commun pour les stations présence onde interne
if corr_internal_wave ==1 & strcmp(section,'ride');
    v_ref1 = v_ref1';
    
    moy_97 = meanoutnan(v_ref1(35:37));   
    moy_101 = meanoutnan(v_ref1(39:41));
    v_ref1 = [v_ref1(1:34)' repmat(moy_97,1,3) v_ref1(38)' repmat(moy_101,1,3) v_ref1(42:end)'];
    
    % idem pour les couches z_ref
    Z_97 = meanoutnan(lref1(35:37,1)); 
    Z_101 = meanoutnan(lref1(39:41,1));
    lref1(:,1) = [lref1(1:34,1)' repmat(Z_97,1,3) lref1(38,1)' repmat(Z_101,1,3) lref1(42:end,1)'];
    
    Z_97 = meanoutnan(lref1(35:37,2)); 
    Z_101 = meanoutnan(lref1(39:41,2));
    lref1(:,2) = [lref1(1:34,2)' repmat(Z_97,1,3) lref1(38,2)' repmat(Z_101,1,3) lref1(42:end,2)'];
end

%------------------------------------------------------------------------------------------------------------------
%%% Forcage de la vitesse geo par la vitesse adcp de ref
v_barocline = NaN*ones(length(z),npair);
 for i=1:npair
     
    % selectionne Zctd le plus proche de Zadcp moy [z_vref(1) z_vref(2)] et son indice J
    % on retire la vitesse geo MOYENNE dans la couche de
    % ref et on la remplace par la vitesse ADCP moyenne 
    [~,Jmin] = min(abs(z(~isnan(v(:,i)),i)-lref1(i,1)));
    [~,Jmax] = min(abs(z(~isnan(v(:,i)),i)-lref1(i,2)));
    
    if ~isempty(Jmin) && ~isempty(Jmax); v(1:end,i) = v(1:end,i) - (nanmean(v(Jmin:Jmax,i))) + v_ref1(i); end;

    if ~isempty(Jmin) && ~isempty(Jmax); v_barocline(1:end,i) = v(1:end,i) - (nanmean(v(Jmin:Jmax,i))); end;
    
 end
%% ========================================================================
if bottom_v == 1;

for ipair=1:npair
    e = length(v(ref_up_bott_tr(ipair):ref_d_bott_tr(ipair),ipair))-1;
    e = v(ref_up_bott_tr(ipair),ipair)/e;
    v_bottom = 0:e:v(ref_up_bott_tr(ipair),ipair); 
    %v_bottom = reverse(v_bottom);
    v_bottom = flip(v_bottom);
    v(ref_up_bott_tr(ipair):ref_d_bott_tr(ipair),ipair)= v_bottom;
end

end

%% ========================================================================
%profil geostrophique v zat STA force par OS38 Lref et filtrage
%profil v_ref_moy filtrage vert Lanczos

% Plot profils vitesses geo abs et v_ref

if plot_figures_profils == 1;

for ipair=1:npair

z_ref = ref_up_bott_tr(ipair);   
    
figure;
hold on;
plot(v(1:z_ref,ipair),-z(1:z_ref,ipair),'r','LineWidth',1)
plot(v(z_ref:end,ipair),-z(z_ref:end,ipair),'b','LineWidth',1)

plot(v_filt_vert_moy_tot(ipair,:),-z_adcp,'k','LineWidth',1)

plot([v_ref1(ipair) v_ref1(ipair)],[-lref1(ipair,1) -lref1(ipair,2)],'k--','LineWidth',1.5)

plot([v_ref1(ipair)-0.02 v_ref1(ipair)+0.02],[-lref1(ipair,1) -lref1(ipair,1)],'k--','LineWidth',0.5)
plot([v_ref1(ipair)-0.02 v_ref1(ipair)+0.02],[-lref1(ipair,2) -lref1(ipair,2)],'k--','LineWidth',0.5)

title(['Pair ' num2str(STA(ipair))],'fontsize',8);

xlabel('v_o_r_t_h_o (m.s^-^1)');
ylabel('Depth (m)');
%xlim([-0.2 0.2]);
ax1 = gca; ax1.FontSize = 14;

if save_figure == 1;
    %saveas(gcf, ['/home4/homedir4/perso/isalaun/Matlab/figures/prof_vSADCP_vgeo/prof_vgeo_vSADCP_pair' num2str(STA(ipair)) 'filtre' num2str(filtre) 'm_RREX17.png'])
    saveas(gcf, ['../figures/prof_vSADCP_vgeo_RREX17/prof_vgeo_' methode '_vSADCP_OS150_pair' num2str(STA(ipair)) '_filtre400m_RREX17.png'])
end
close all
end

end

%% ========================================================================
%Enregistrement de la vitesse absolue

if save_vabs == 1
    rept = '../matlab_output_RREX17/';
    
    % generation du nom du fichier de sortie
    fic_vabs = ['vitesse_abs/OS150_section_' section '_' methode ];
    display(['Traitement du fichier ' fic_vabs]);

    dpair_abs=dpair; v_abs=v; z_abs = zat(:); lat_abs = lat; lon_abs = lon; Vref = v_ref1; Z_vref = z_vref_use_pair; ref_up_bott_triangle = ref_up_bott_tr;
    save([rept fic_vabs '.mat'],'dpair_abs','v_abs','v_barocline', 'z_abs','lat_abs','lon_abs','Vref','Z_vref','ref_up_bott_triangle');

end

%% ========================================================================

%calcul du transport

if strcmp(section,'ride'); 
    X = lat_ctd;

elseif strcmp(section,'south') || strcmp(section,'north')|| strcmp(section,'ovide') ; 
    X = lon_ctd;
end

%%% Transport surface-fond
tr_z=trsp_geo_tp(v,zat,dpair);   tr_barocline=trsp_geo_tp(v_barocline,zat,dpair); 
tr_z = tr_z*1e-06;               tr_barocline = tr_barocline*1e-06;

for i=1:npair; T_tot(i) = sum(tr_z(:,i)); end
for i=1:npair; T_up_bott_tr(i) = sum(tr_z(1:ref_up_bott_tr(i),i)); end

for i=1:npair; T_barocline(i) = sum(tr_barocline(:,i));  T_barotrope(i) = T_tot(i)-T_barocline(i); end


% Enregistrement du transport
rept='../matlab_output_RREX17/transport_geo/';
file_save=['transport_RREX17_' section '_' methode '_OS150'];
if save_trsp == 1
    save([rept file_save],'X','T_tot','T_up_bott_tr','T_barocline','T_barotrope');
end

%% ========================================================================

%%% Trace de la vitesse geostrophique absolue
[bathy_ship,X_bathy,Y_bathy]=bathy_bateau_17(section);
bathy_ship = bathy_ship.*1e-3;

if strcmp(section,'south')||strcmp(section,'ride')||strcmp(section,'ovide');

if strcmp(section,'south')||strcmp(section,'ovide');
    ind_bad=find(bathy_ship(2:end-1)<1);
elseif strcmp(section,'ride'); 
    ind_bad=find(bathy_ship(2:end-1)<0.1);
end  
 
for i=1:length(ind_bad)
    j=length(ind_bad)+1-i;
    bathy_ship(ind_bad(j)+1)=[];
    X_bathy(ind_bad(j)+1)=[];
    Y_bathy(ind_bad(j)+1)=[];
end    

if strcmp(section,'south')||strcmp(section,'ovide');
    ind_bad=find(3.2<bathy_ship(2:end-3));
elseif strcmp(section,'ride'); 
    ind_bad=find(4.5<bathy_ship(2:end-3));
end   

for i=1:length(ind_bad)
    j=length(ind_bad)+1-i;
    bathy_ship(ind_bad(j)+1)=[];
    X_bathy(ind_bad(j)+1)=[];
    Y_bathy(ind_bad(j)+1)=[];
end

end

% %Prolongation des profils jusqu'au fond pour une belle figure
% if strcmp(section,'north') || strcmp(section,'ovide') || strcmp(section,'south');
% for i=1:length(dpair)
%     ind_nan = find(isnan(v(:,i)));
%     v(ind_nan(1):end,i) = v(ind_nan(1)-1,i);
% end
% end

if save_figure == 1
    
figure;
set(gcf,'PaperType','A4','PaperOrientation','landscape','PaperUnits','centimeters','PaperPosition',[1,1,24,18],'Posi',[185 0 1200 800]);
%load mapcolor2; 
%addpath('/home4/homedir4/perso/isalaun/Matlab/toolbox/my_colormap');
load vmap0
vcol=-.2:.02:.2;
[c,h]=contourf(X1(:),zat(1:4339).*1e-3,v(1:4339,:),vcol);
set(gca,'ydir','reverse')
xlabel(xlab); ylabel('Depth (km)');
limcol=[vcol(1) vcol(end)]; caxis(limcol); colormap(vmap); colorbar;
colormap(vmap); colorbar;
hold on; 
hold on; fill(X_bathy(:),bathy_ship,[0.5 0.5 0.5]);

if strcmp(section,'ovide');
    ylim([0 3.2]);
    xlim([-37 -27]);
elseif strcmp(section,'south');
    ylim([0 3.2]);
    xlim([-38.5 -31]);
elseif strcmp(section,'north');
    ylim([0 3]);
    xlim([-34 -20]);
elseif strcmp(section,'ride');
    ylim([0 4.35]); 
    xlim([48 64]);
end

%title(titre,'FontSize',12);
cbar = colorbar; 
cbar.Label.String = 'm/s'
 
% if strcmp(section,'ride'); 
%     hold on; text(55,4.75,'(c) RREX 2017','FontWeight','bold','FontSize',12)
% elseif strcmp(section,'north');
%     hold on; text(-27.9,3.3,'(b) RREX 2017','FontWeight','bold','FontSize',12)
% elseif strcmp(section,'ovide');
%     hold on; text(-32.7,3.5,'(c) RREX 2017','FontWeight','bold','FontSize',12)
% elseif strcmp(section,'south');
%     hold on; text(-35.3,3.5,'(b) RREX 2017','FontWeight','bold','FontSize',12)
% end

% Position des stations
x_lim = [48 64];
str_numero=num2str(STA); X_sta_pos = X;
if X_sta_pos(1) > X_sta_pos(end); X_sta_pos=flip(X_sta_pos); str_numero=flip(str_numero); end
posi=get(gca,'Posi');
a2=axes('Posi',[posi(1) posi(2)+posi(4) posi(3) 0],'Color','none','FontSize',10);
set(a2,'XLim',x_lim,'XTick',X_sta_pos,'XTickLabel',[],'YTick',[]);
%A = num2str([]);
%a2.XTickLabel = {A,str_numero(2,:),A,str_numero(4,:),A,str_numero(6,:),A,str_numero(8,:),A,str_numero(10,:),A,str_numero(12,:),A,A,A,A,A,A,A,str_numero(20,:),A,str_numero(22,:),A,str_numero(24,:),A,str_numero(26,:),A,str_numero(28,:)...
%    A,str_numero(30,:),A,str_numero(32,:),A,str_numero(34,:),A,A,A,A,A,A,A,A,A,str_numero(44,:),A,str_numero(46,:),A,str_numero(48,:),A,str_numero(50,:),A,str_numero(52,:),A,str_numero(54,:)...
%    A,str_numero(56,:),A,str_numero(58,:),A,str_numero(60,:),A,str_numero(62,:),A,A};
%set(a2,'XaxisLocation','top');


    saveas(gcf, ['../figures/',titre_fig,'.png'])
end

%% ========================================================================
% clear all
% close all
% 
% 
% file_v_abs_polyfit = '../matlab_output_RREX17/vitesse_abs/OS150_section_ride_polyfit';
% load(file_v_abs_polyfit); v_polyfit = v_abs; v_polyfit_barocline = v_barocline;
% file_v_abs_cstslope = '../matlab_output_RREX17/vitesse_abs/OS150_section_ride_cstslope';
% load(file_v_abs_cstslope,'v_abs'); v_cstslope = v_abs; v_cstslope_barocline = v_barocline;
% file_v_abs_v_bottom = '../matlab_output_RREX17/vitesse_abs/OS150_section_ride_triangle_bottom';
% load(file_v_abs_v_bottom,'v_abs'); v_bottom = v_abs; v_bottom_barocline = v_barocline;
% %file_v_abs_no_bottom = '../matlab_output_RREX17/vitesse_abs/OS150_section_ride_no_bottom';
% %load(file_v_abs_no_bottom,'z_vref_use_pair');
% 
% %polyfit:57,58,61,62,63,64,65,67,68,69,76,77,78,80,81,82,84,85,86,87,89,90,91,92,94,97,99,105,
% %106,111,112,113,114,115,116,117,118,119,120,121,122,123
% %cstslope:66,83,98,101,108,109
% %v_bottom:56,59,60,79,88,93,95,96,100,102,103,104,107, 110,124
% 
% v_use= v_polyfit;
% v_use(:,1)=v_bottom(:,1);  v_use(:,4)=v_bottom(:,4); v_use(:,5)=v_bottom(:,5);
% v_use(:,11)=v_cstslope(:,11); v_use(:,18)= v_bottom(:,18); v_use(:,22)=v_cstslope(:,22);
% v_use(:,27)=v_bottom(:,27); v_use(:,32)=v_bottom(:,32); v_use(:,34)=v_bottom(:,34);
% v_use(:,35)=v_bottom(:,35); v_use(:,37)=v_cstslope(:,37); v_use(:,39)=v_bottom(:,39);
% v_use(:,40)=v_cstslope(:,40); v_use(:,41)=v_bottom(:,41); v_use(:,42)=v_bottom(:,42);
% v_use(:,43)=v_bottom(:,43); v_use(:,46)=v_bottom(:,46); v_use(:,47)=v_cstslope(:,47);
% v_use(:,48)=v_cstslope(:,48); v_use(:,49)=v_bottom(:,49); v_use(:,63)=v_bottom(:,63);
% 
% v_abs = v_use;
% 
% v_barocline_use= v_polyfit_barocline;
% v_barocline_use(:,1)=v_bottom_barocline(:,1);  v_barocline_use(:,4)=v_bottom_barocline(:,4); v_barocline_use(:,5)=v_bottom_barocline(:,5);
% v_barocline_use(:,11)=v_cstslope_barocline(:,11); v_barocline_use(:,18)= v_bottom_barocline(:,18); v_barocline_use(:,22)=v_cstslope_barocline(:,22);
% v_barocline_use(:,27)=v_bottom_barocline(:,27); v_barocline_use(:,32)=v_bottom_barocline(:,32); v_barocline_use(:,34)=v_bottom_barocline(:,34);
% v_barocline_use(:,35)=v_bottom_barocline(:,35); v_use(:,37)=v_cstslope_barocline(:,37); v_barocline_use(:,39)=v_bottom_barocline(:,39);
% v_barocline_use(:,40)=v_cstslope_barocline(:,40); v_barocline_use(:,41)=v_bottom_barocline(:,41); v_barocline_use(:,42)=v_bottom_barocline(:,42);
% v_barocline_use(:,43)=v_bottom_barocline(:,43); v_barocline_use(:,46)=v_bottom_barocline(:,46); v_barocline_use(:,47)=v_cstslope_barocline(:,47);
% v_barocline_use(:,48)=v_cstslope_barocline(:,48); v_barocline_use(:,49)=v_bottom_barocline(:,49); v_barocline_use(:,63)=v_bottom_barocline(:,63);
% 
% v_barocline = v_barocline_use;
% 
% save('../matlab_output_RREX17/vitesse_abs/OS150_section_ride_use.mat','dpair_abs','v_abs','v_barocline', 'z_abs','lat_abs','lon_abs','Vref','Z_vref','ref_up_bott_triangle');
% 
% load('../matlab_output_RREX17/transport_geo/transport_RREX17_ride_polyfit','X','T_up_bott_tr');
% 
% %%% Transport surface-fond
% tr_z=trsp_geo_tp(v_use,z_abs,dpair_abs);  tr_barocline=trsp_geo_tp(v_barocline_use,z_abs,dpair_abs); 
% tr_z = tr_z*1e-06;                        tr_barocline = tr_barocline*1e-06;
% 
% for i=1:63; T_tot(i) = sum(tr_z(:,i)); end
% for i=1:63; T_barocline(i) = sum(tr_barocline(:,i));  T_barotrope(i) = T_tot(i)-T_barocline(i); end
% 
% 
% % Enregistrement du transport
% save('../matlab_output_RREX17/transport_geo/transport_RREX17_ride_use_OS150' ,'X','T_tot','T_up_bott_tr','T_barocline','T_barotrope');


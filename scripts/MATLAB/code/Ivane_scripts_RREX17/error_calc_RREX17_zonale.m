function [Er_tot,Er_ek,Er_synopt,Er_phy,Er_bott,Er_nois,ins_nois,er_ins,er_aleatoire] = error_calc_RREX17_zonale(section,ind_reg,region,region_vert)
%%% Fonction qui calcul les erreurs dans chaque region choisi par l'utilisateur
%%%
%%% L'erreur totale en sortie er_tot comprend l'erreur de synopticite 
%%% (precision du Tr_ekman (donc tension de vent) moyenne sur 1mois ou a la 
%%% date de chaque station) + l'erreur des triangles de fond (uniquement si 
%%% la region selectionnee par l'utilisateur les prend en compte) +
%%% l'erreur physique (approx geostrophique) qui correspond a l'erreur ageostrophique 
%%% ET instrumentale des donnees. 

addpath(genpath('../toolbox/matlab/matlab/outils_matlab/lpo'));
addpath('../toolbox/netcdf_lpo'); 
addpath('../toolbox/matlab/matlab/outils_matlab/m_map1.4f/')
%% ========================================================================
cruise = 'RREX17';

%'layer1','NACW','SAW','layer2','SPMW','SAIW','IW','residual'
%'layer3','LSW','ISW','layer4','LDW','ISOW','none'

if strcmp(region,'R_IC_17')
    display(['cruise ' cruise ', section ' section ', IC, water mass ' region_vert]);
elseif strcmp(region,'R_ERRC_17')
    display(['cruise ' cruise ', section ' section ', ERRC, water mass ' region_vert]);
end

%% ========================================================================

if strcmp(section,'north')
    STA = [44:55 57]; STA=STA(:); nsta=size(STA,1); npair=nsta-1; m=length(STA); 
elseif strcmp(section,'ovide')
    STA = [18:20 22:24 27:28 43:-1:41 38:-1:31]; STA=STA(:); nsta=size(STA,1); npair=nsta-1; m=length(STA); 
elseif strcmp(section,'south')
    STA = [1:8 11:17]; STA=STA(:); nsta=size(STA,1); npair=nsta-1; m=length(STA); 
end

%% ========================================================================
%%% Données hydro pour délimiter les masses d'eau
load(['../matlab_output_RREX17/vitesse_abs/OS38_section_' section '_polyfit']);
load(['../matlab_output_RREX17/hydro/hydro_bottom_section_' section '_RREX17.mat']);
load(['../matlab_output_RREX17/hydro/hydro_bottom_PVOR_section_' section '_RREX17.mat']);

O_mid = (O(:,1:end-1)+O(:,2:end))./2; 
S_mid = (S(:,1:end-1)+S(:,2:end))./2; 
Q_mid = (q(:,1:end-1)+q(:,2:end))./2; 
q = q_filt;
dens0 = (dens0_abs(:,1:end-1)+dens0_abs(:,2:end))./2;
dens1 = (dens1_abs(:,1:end-1)+dens1_abs(:,2:end))./2;
    
fctd = '../../DATA/HYDRO/RREX2017/ctd/nc/rr17_PRES.nc';
P = ncread(fctd,'PRES'); 
P = P(:,2:end); P = P(:,STA);
%%% determination des pressions max pour toutes les stations
n = size(P,1);
m = size(P,2);
for i = 1:m
    M = P(:,i);
    inan = isnan(M);
    ind_keep = find(inan==0);
    pmae(i) = ind_keep(end)-1;  %-1 car valeur pmae = indice ind_keep-1
end 
%%  =======================================================================
% Erreurs liees au transport d'Ekman
% Erreurs liees a l'estimation des tensions de vents 
load(['../matlab_output_RREX17/transport_Ekman/trsp_ek_' section '_ncep_each.mat']); Tr_ek_ncep = tr_ek;
clear tr_ek v_ek
load(['../matlab_output_RREX17/transport_Ekman/trsp_ek_' section '_era_each.mat']); Tr_ek_era = tr_ek; 
clear tr_ek v_ek

%%% On ne peut pas avoir de NaN pour le calcul RMS donc les NaN dans ncep
%%% sont remplacés par les valeurs de era
if isempty(find(isnan(Tr_ek_ncep)))
else
    Tr_ek_ncep(find(isnan(Tr_ek_ncep))) = Tr_ek_era(find(isnan(Tr_ek_ncep)));
end
    
Er_estimat = rms(Tr_ek_ncep(ind_reg) - Tr_ek_era(ind_reg));

% Erreurs liees a la synopticite du transport d'Ekman
% Lecture des transports d'Ekman moyennés par paire ET sur toute la mission
load(['../matlab_output_RREX17/transport_Ekman/trsp_ek_' section '_era_each.mat']); Tr_ek_each = tr_ek; 
load(['../matlab_output_RREX17/transport_Ekman/trsp_ek_' section '_era_moyenne.mat']); Tr_ek_moy = tr_ek; 
clear tr_ek v_ek

Er_synopt = rms(Tr_ek_moy(ind_reg) - Tr_ek_each(ind_reg));

if strcmp(region_vert,'layer1') || strcmp(region_vert,'NACW') || strcmp(region_vert,'SAW') || strcmp(region_vert,'SPMW') || strcmp(region_vert,'none');
    % Erreur total du transport d'Ekman en surface
    Er_ek = sqrt(Er_synopt^2 + Er_estimat^2);
else
    %'layer2','SAIW','IW','layer3','LSW','ISW','layer4','LDW','ISOW'
    Er_ek = 0;
    
end

if isnan(Er_ek) 
    display('error Ekman transport ERROR')
else
    display(['Ekman transport error ' num2str(Er_ek) ])
end

%%  =======================================================================
% Erreurs des triangles de fond
% lecture des transports dans les triangles de fond avec plusieurs methodes

load(['../matlab_output_RREX17/transport_geo/transport_RREX17_' section '_polyfit.mat'],'X','T_tot','T_up_bott_tr'); Tr_polyfit = T_tot'-T_up_bott_tr'; lon_ctd = X';
load(['../matlab_output_RREX17/transport_geo/transport_RREX17_' section '_pfit.mat'],'X','T_tot','T_up_bott_tr'); Tr_planfit = T_tot'-T_up_bott_tr'; lon_ctd = X';
load(['../matlab_output_RREX17/transport_geo/transport_RREX17_' section '_cstslope.mat'],'X','T_tot','T_up_bott_tr'); Tr_cstslope = T_tot'-T_up_bott_tr'; lon_ctd = X';
%load(['../matlab_output_RREX17/transport_geo/transport_RREX17_' section '_horiz.mat'],'X','T_tot','T_up_bott_tr'); Tr_horiz = T_tot'-T_up_bott_tr'; lon_ctd = X';
load(['../matlab_output_RREX17/transport_geo/transport_RREX17_' section '_triangle_bottom.mat'],'X','T_tot','T_up_bott_tr'); Tr_triangle_bottom = T_tot'-T_up_bott_tr'; lon_ctd = X';

%diff_bott = [(Tr_polyfit-Tr_planfit) (Tr_polyfit-Tr_cstslope) (Tr_polyfit-Tr_horiz) (Tr_planfit-Tr_cstslope) (Tr_planfit-Tr_horiz) (Tr_cstslope-Tr_horiz)];
diff_bott = [(Tr_polyfit-Tr_planfit) (Tr_polyfit-Tr_cstslope) (Tr_polyfit-Tr_triangle_bottom) (Tr_planfit-Tr_cstslope) (Tr_planfit-Tr_triangle_bottom) (Tr_cstslope-Tr_triangle_bottom)];
Er_bott = rms(diff_bott,2); % calcul sur la 2e dim car diff entre 4 jeu de donnees ==> matrice 2D INDEPENDANT entre chaque paire

%%% Prise en compte des erreurs sur les triangles de fond uniquement aux
%%% paires concernées

for ipair=1:npair 
    z_ref = ref_up_bott_triangle(ipair);
    
    if strcmp(region_vert,'layer1') || strcmp(region_vert,'NACW') || strcmp(region_vert,'SAW') || strcmp(region_vert,'SPMW');
        if dens0(z_ref,ipair) >= 27.51; Er_bott(ipair) = 0; end
    elseif strcmp(region_vert,'layer2') || strcmp(region_vert,'SAIW') || strcmp(region_vert,'IW') || strcmp(region_vert,'residual');   
        if dens0(z_ref,ipair) >= 27.71 || dens0(z_ref,ipair) < 27.51; Er_bott(ipair) = 0; end 
    elseif strcmp(region_vert,'layer3') || strcmp(region_vert,'LSW') || strcmp(region_vert,'ISW');
        if dens0(z_ref,ipair) >= 27.8 || dens0(z_ref,ipair) < 27.71; Er_bott(ipair) = 0; end
    elseif strcmp(region_vert,'layer4') || strcmp(region_vert,'ISOW') || strcmp(region_vert,'LDW');    
        if dens0(z_ref,ipair) < 27.8; Er_bott(ipair) = 0; end   
    end

end

%%% Selection de la region considere
%Er_bott = Er_bott(ind_reg);

er_bott = sqrt(nansum(Er_bott(ind_reg).^2)); %pour avoir une idée

if isnan(er_bott) 
    display('error in bottom triangle ERROR')
    %Er_bott(isnan(Er_bott))=0;
else
    display(['Bottom triangles error ' num2str(er_bott) ])
end

%%  =======================================================================
% Erreur physique de l'approximation geostrophique (ondes internes) 
% via script de Pascale: bruit sur les profils moyens sur Lg la longueur 
% geostrophique (Lg=LR/2 avec LR le rayon de Rossby environ a 14km)
% et suppression de bruit instrumental
% Calcul pour l'OS38 uniquement

% Lecture des donnees SADCP en segment de 2km
load(['../matlab_output_RREX17/vitesse_adcp/vitesse_sadcp_RREX17_OS38_' section '_m09_004_12_fhv21_sec_02mx21.mat']);


%%% Firstly: erreur du bruit instrumental decorrele a ajoute dans l'erreur totale
%%% cette erreur diminue lorsque la distance augmente 

% nombre de segment de 2km dans la distance prise en compte dans ind_reg


if strcmp(section,'south') || strcmp(section,'north');
    ind_seg2km = find(lon_sadcp > lon_ctd(1) & lon_sadcp < lon_ctd(end));
        
elseif strcmp(section,'ovide');
    ind_seg2km = find(lon_sadcp < lon_ctd(1) & lon_sadcp > lon_ctd(end));
  
end

N = length(ind_seg2km);

% variance en cm/s donc conversion en m/s
% 3 ensembles de 2min (6min) pour faire 2km et N segment de 2km sur dpair

% erreur instrumentale par ping defini par le constructeur et nombre de
% ping par ensemble de 2min defini dans Madida (fct de OS et NB/BB) 
var_par_ping = 0.23;  %cf constructeur même ADCP en 2015 et 2017
nb_ping_2min = 29;

ins_nois = sqrt(var_par_ping.*var_par_ping) ./ sqrt(nb_ping_2min * 3.25 * N * 17);
%%  =======================================================================
% calcul de la surface S dans ind_reg

for ipair=1:npair 
    % Calcul de dz
    if strcmp(region_vert,'layer1') 
        z_dens0 = find(dens0(:,ipair) < 27.51);
    elseif strcmp(region_vert,'NACW')
        z_dens0_1 = find(dens0(:,ipair) < 27.51 & S_mid(:,ipair) >= 34.94 & O_mid(:,ipair) < 272);
        z_dens0_2 = find(dens0(1:end-1,ipair) < 27.51 & S_mid(1:end-1,ipair) >= 34.94 & O_mid(1:end-1,ipair) >= 272 & Q_mid(:,ipair) >= 6e-11);
        z_dens0 = sort([z_dens0_1 ; z_dens0_2]);   
    elseif strcmp(region_vert,'SAW')
        z_dens0 = find(dens0(:,ipair) < 27.51 & S_mid(:,ipair) < 34.94);
    elseif strcmp(region_vert,'SPMW')
        z_dens0 = find(dens0(1:end-1,ipair) < 27.51 & S_mid(1:end-1,ipair) >= 34.94 & Q_mid(:,ipair) < 6e-11);
    elseif strcmp(region_vert,'layer2')
        z_dens0 = find(dens0(:,ipair) >= 27.51 & dens0(:,ipair) < 27.71);
    elseif strcmp(region_vert,'SAIW')
        z_dens0 = find(dens0(:,ipair) >= 27.51 & dens0(:,ipair) < 27.71 & S_mid(:,ipair) < 34.94);
    elseif strcmp(region_vert,'IW')
        z_dens0 = find(dens0(:,ipair) >= 27.51 & dens0(:,ipair) < 27.71 & S_mid(:,ipair) >= 34.94 & O_mid(:,ipair) < 272);
    elseif strcmp(region_vert,'residual')
        z_dens0 = find(dens0(:,ipair) >= 27.51 & dens0(:,ipair) < 27.71 & S_mid(:,ipair) >= 34.94 & O_mid(:,ipair) >= 272);
    elseif strcmp(region_vert,'layer3')
        z_dens0 = find(dens0(:,ipair) >= 27.71 & dens0(:,ipair) < 27.8);
    elseif strcmp(region_vert,'LSW')
        z_dens0 = find(dens0(:,ipair) >= 27.71 & dens0(:,ipair) < 27.8 & S_mid(:,ipair) < 34.94);
    elseif strcmp(region_vert,'ISW')
        z_dens0 = find(dens0(:,ipair) >= 27.71 & dens0(:,ipair) < 27.8 & S_mid(:,ipair) >= 34.94);
    elseif strcmp(region_vert,'layer4')
        z_dens0 = find(dens0(:,ipair) >= 27.8);
    elseif strcmp(region_vert,'ISOW')
        z_dens0 = find(dens0(:,ipair) >= 27.8 & S_mid(:,ipair) >= 34.94);
    elseif strcmp(region_vert,'LDW')
        z_dens0 = find(dens0(:,ipair) >= 27.8 & S_mid(:,ipair) < 34.94);     
    end
  
    if strcmp(region_vert,'none')
        dz = nanmax(pmae(ipair),pmae(ipair+1));
        
    elseif isempty(z_dens0)
        dz = 0;
    else
        dz = z_abs(z_dens0(end))-z_abs(z_dens0(1));
    end
    
    Surf(ipair) = dpair_abs(ipair) .* dz;

end
clear dz
clear z_dens0
%%  =======================================================================
% calcul de l'erreur du bruit instrumental sur le transport
t_nois = ins_nois .* nansum(Surf(ind_reg));
if isempty(t_nois) | t_nois==Inf; t_nois=NaN; end
Er_nois = t_nois * 1e-06;


if isnan(Er_nois) 
    display('Instrumental noise ERROR')
else
    display(['Instrumental noise ' num2str(Er_nois) ])
end

%%  =======================================================================
%%% Secondly: erreur ageostrophique a decorreler du bruit instrumental
% Lecture des vitesses sadcp (OS38) ortho aux paires de stations et de 2km
% et determination de N, le nombre de segment de 2km dans
% chaque Lg, pour supprimer le bruit instrumental de l'erreur petite echelle

%%% Moyenne de toute la paire dans la couche Lref
Lref_sup = z_vref_use(:,1); Lref_inf = z_vref_use(:,2);

for j=1:length(Lref_sup)
    [mini,ind_sup] = min(abs(z_adcp-Lref_sup(j)));
    [mini,ind_inf] = min(abs(z_adcp-Lref_inf(j)));
    
    vorth_lref(j) = nanmean(vorth_sadcp(j,[ind_sup:ind_inf]));
    
    % dans le cas ou la mauvaise couche de ref a ete renseigne, on prend depuis la surface
    if isnan(vorth_lref(j))
        vorth_lref(j) = nanmean(vorth_sadcp(j,[1:ind_inf]));
    end
    
end

% dans le cas ou toutes les donnees SADCP sont a NaN 
ind_nan = find(isnan(vorth_lref));
vorth_lref(ind_nan) = [];

%%% Filtrage des donnees SADCP sur 8km 
coef = 0.04;
v_ref_filt = lanczos_labo(vorth_lref(:),coef,20); v_ref_filt = v_ref_filt';

% on repositionne les NaN pour ne pas fausser les std sur les distances Lg
for j=1:length(ind_nan)
    v_ref_filt = [v_ref_filt(1:length(v_ref_filt) < ind_nan(j)), NaN, v_ref_filt(1:length(v_ref_filt) >= ind_nan(j))];
end
v_ref = v_ref_filt;

%%% Calcul de la longueur geostrophique a partir des donnees SADCP de 2km

LR = extract_rossby_radius(lat_sadcp,lon_sadcp);
Lg = LR./2;

% Decoupage de segments de longueur Lg=5km des donnees SADCP de 2km
dist_all=[]; ind_2km=1;
for iN=1:length(lon_sadcp)-1
    dist = m_lldist([lon_sadcp(iN) lon_sadcp(iN+1)],[lat_sadcp(iN) lat_sadcp(iN+1)]);
    dist_all = [dist_all dist];
    
    if nansum(dist_all) >= Lg(ind_2km(end))
        ind_2km = [ind_2km iN];
        dist_all = [];
    end
end
ind_keep = [ind_2km length(lon_sadcp)]; %[ind_2km length(lat_sadcp)];


%%% Ecart a la moyenne dans chaque bin de longueur Lg (std) 
for i_moy = 1:length(ind_keep)-1
    vorth_std(:,i_moy) = stdoutnan(v_ref(ind_keep(i_moy):ind_keep(i_moy+1)));    
    lat_sadcp_moy(i_moy) = meanoutnan(lat_sadcp(ind_keep(i_moy):ind_keep(i_moy+1))); 
    lon_sadcp_moy(i_moy) = meanoutnan(lon_sadcp(ind_keep(i_moy):ind_keep(i_moy+1))); 
end
    

%%% Moyenne des segments geostorphiques dans les pairs de station
for i=1:npair
    % Division des profils moyens dans chaque paire de station
    if strcmp(section,'south') || strcmp(section,'north');
        ok = lon_sadcp_moy >= lon_ctd(i) & lon_sadcp_moy <= lon_ctd(i+1);
        
    elseif strcmp(section,'ovide');
        ok = lon_sadcp_moy <= lon_ctd(i) & lon_sadcp_moy >= lon_ctd(i+1);   
    end
    v_inpair = vorth_std(:,ok);
    
    % Moyenne de tous les std des bins dans chaque paire (on suppose une
    % meme onde ageo qui perturbe tous les profils de la paire)
    v_moy_pair = meanoutnan(meanoutnan(v_inpair)) ./ sqrt(size(v_inpair,2));
    if isempty(v_moy_pair); v_par_pair(i)=NaN;
    else v_par_pair(i) = v_moy_pair; end
end

%%  =======================================================================

%%% Passage des erreurs sur les vitesses a des erreurs sur les transports

for ipair=1:npair
    % Calcul de dz
    if strcmp(region_vert,'layer1') 
        z_dens0 = find(dens0(:,ipair) < 27.51);
    elseif strcmp(region_vert,'NACW')
        z_dens0_1 = find(dens0(:,ipair) < 27.51 & S_mid(:,ipair) >= 34.94 & O_mid(:,ipair) < 272);
        z_dens0_2 = find(dens0(1:end-1,ipair) < 27.51 & S_mid(1:end-1,ipair) >= 34.94 & O_mid(1:end-1,ipair) >= 272 & Q_mid(:,ipair) >= 6e-11);
        z_dens0 = sort([z_dens0_1 ; z_dens0_2]);   
    elseif strcmp(region_vert,'SAW')
        z_dens0 = find(dens0(:,ipair) < 27.51 & S_mid(:,ipair) < 34.94);
    elseif strcmp(region_vert,'SPMW')
        z_dens0 = find(dens0(1:end-1,ipair) < 27.51 & S_mid(1:end-1,ipair) >= 34.94 & Q_mid(:,ipair) < 6e-11);
    elseif strcmp(region_vert,'layer2')
        z_dens0 = find(dens0(:,ipair) >= 27.51 & dens0(:,ipair) < 27.71);
    elseif strcmp(region_vert,'SAIW')
        z_dens0 = find(dens0(:,ipair) >= 27.51 & dens0(:,ipair) < 27.71 & S_mid(:,ipair) < 34.94);
    elseif strcmp(region_vert,'IW')
        z_dens0 = find(dens0(:,ipair) >= 27.51 & dens0(:,ipair) < 27.71 & S_mid(:,ipair) >= 34.94 & O_mid(:,ipair) < 272);
    elseif strcmp(region_vert,'residual')
        z_dens0 = find(dens0(:,ipair) >= 27.51 & dens0(:,ipair) < 27.71 & S_mid(:,ipair) >= 34.94 & O_mid(:,ipair) >= 272);
    elseif strcmp(region_vert,'layer3')
        z_dens0 = find(dens0(:,ipair) >= 27.71 & dens0(:,ipair) < 27.8);
    elseif strcmp(region_vert,'LSW')
        z_dens0 = find(dens0(:,ipair) >= 27.71 & dens0(:,ipair) < 27.8 & S_mid(:,ipair) < 34.94);
    elseif strcmp(region_vert,'ISW')
        z_dens0 = find(dens0(:,ipair) >= 27.71 & dens0(:,ipair) < 27.8 & S_mid(:,ipair) >= 34.94);
    elseif strcmp(region_vert,'layer4')
        z_dens0 = find(dens0(:,ipair) >= 27.8);
    elseif strcmp(region_vert,'ISOW')
        z_dens0 = find(dens0(:,ipair) >= 27.8 & S_mid(:,ipair) >= 34.94);
    elseif strcmp(region_vert,'LDW')
        z_dens0 = find(dens0(:,ipair) >= 27.8 & S_mid(:,ipair) < 34.94);     
    end

    if strcmp(region_vert,'none') 
        dz = nanmax(pmae(ipair),pmae(ipair+1));
    elseif isempty(z_dens0)
        dz = 0;
    else
        dz = z_abs(z_dens0(end))-z_abs(z_dens0(1));
    end    
    
    % Erreur ageostrophique 
    t_par_pair = v_par_pair(ipair) .* dpair_abs(ipair) .* dz;
    t_par_pair = t_par_pair * 1e-06; %Convertion de m/s en Sv 
    
    if isempty(t_par_pair); t_par_pair=NaN; end
    Er_phy(ipair) = t_par_pair;

end    

%%  =======================================================================
%%% Selection de la region considere
%Er_phy = Er_phy(ind_reg);

er_phy = sqrt(nansum(Er_phy(ind_reg).^2)); %pour avoir une idée

if isnan(Er_phy) 
    display('Ageostrophic error ERROR')
else
    display(['Ageostrophic error ' num2str(er_phy) ])    
end

%%  =======================================================================
% Biais de la correction en desalignement du SADCP (biais instrumental) calculé dans chapiter Misalignement correction 
% Calcul du biais

% z_vref = [0 -250];
% z_grid = [-47.06:-12:z_vref(2)]; %pour interpolation sur une même grille
% 
% file_sadcp = ['../matlab_output_RREX17/vitesse_adcp/vitesse_sadcp_RREX17_OS38_' section '_m09_004_12_fhv21_sec_02mx21'];
% load(file_sadcp,'vorth_sadcp','z_adcp');
% V_OS38 = vorth_sadcp(1:end-1,:)'; zl = -z_adcp; clear z_adcp
% 
% V_OS38 = V_OS38(zl >= z_vref(2) & zl <= z_vref(1),:);
% z_adcp = zl(find(zl >= z_vref(2) & zl <= z_vref(1)));
% V_OS38 = interp1(z_adcp,V_OS38,z_grid);
% 
% file_sadcp = ['../matlab_output_RREX17/vitesse_adcp/vitesse_sadcp_RREX17_OS150_' section '_08_015_38_sec_02mx21'];
% load(file_sadcp,'vorth_sadcp','z_adcp');
% V_OS150 = vorth_sadcp'; zl = -z_adcp; clear z_adcp
% 
% V_OS150 = V_OS150(zl >= z_vref(2) & zl <= z_vref(1),:);
% z_adcp = zl(find(zl >= z_vref(2) & zl <= z_vref(1)));
% V_OS150 = interp1(z_adcp,V_OS150,z_grid);
% 
% diff = V_OS38 - V_OS150;
% 
% diff2 = []; 
% for i=1:size(diff,2)
%     diff_prof = nanmean(diff(:,i));
%     diff2 = [diff2 diff_prof];
% end
% 
% for i=1:length(diff2)
%     diff_cum2(i) = nanmean(diff2(1:i));
% end
% 
% diff2(isnan(diff2)) = 0;
% diff_cum = cumsum(diff2);

% disp(diff_cum(end)./size(diff,2)) % le biais
% disp(diff_cum(end))
% diff(isnan(diff)) = 0;
% disp(nanmean(std(diff))) % ecart-type

%instr_bias = abs(diff_cum(end)./size(diff,2));

instr_bias = 0.000434; %m/s biais ride 
    
er_ins = instr_bias .* nansum(Surf(ind_reg)) .* 1e-6;

if isnan(er_ins) 
    display('Instrumental bias ERROR')
else
    display(['Bias ' num2str(instr_bias) ])
    display(['Instrumental bias ' num2str(er_ins) ])
end

%%  =======================================================================
% Calcul de l'erreur totale 

%%% Cumul des erreurs pour chaque zone de la region et section considerees
% Somme des erreurs pour chaque pair de station (considerees independantes)
for ipair=1:npair
    er_tot_pair(ipair) = sqrt(Er_bott(ipair).^2 + Er_phy(ipair).^2); 
end


% Cumul des stations (considerees independantes) pour les erreurs par station
er_hydro = sqrt(nansum(er_tot_pair(ind_reg).^2));

if isnan(er_hydro) 
    display('Ageo + bottom ERROR')
else
    display(['Ageo + bottom error ' num2str(er_hydro) ])
end


% Ajout du bruit des ADCPs et de l'erreur d'Ekman sur ind_reg
er_aleatoire = sqrt(er_hydro.^2 + Er_ek.^2 + Er_nois.^2); 

% Ajout du biais instrumental
Er_tot = er_aleatoire + er_ins;

if isnan(Er_tot) 
    display('Total transport error ERROR')
else
    display(['Total transport error ' num2str(Er_tot) ])
end



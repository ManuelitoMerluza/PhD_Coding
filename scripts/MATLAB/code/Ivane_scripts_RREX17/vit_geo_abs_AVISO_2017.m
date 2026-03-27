% author(s): I. Salaun 11/2019 
%
%description : 
% Computation of absolute geostrophic velocities across each hydrographic 
% section of the RREX2017 cruise 
% Geostrophic velocities constrained by surface velocities from AVISO

%see also : vit_geo_2017.m  vit_surf_AVISO_ref_cruise.m

%% ========================================================================
close all; 
clear all;

addpath(genpath('../toolbox/matlab/matlab/adcp_lpo_V6.2')); %meanoutnan
addpath(genpath('../toolbox/matlab/matlab/outils_matlab/lpo')); %Lanczos
addpath(genpath('../toolbox/netcdf_lpo'));
addpath(genpath('../toolbox/matlab/matlab/outils_matlab/statistique'));
addpath(genpath('../toolbox/my_colormap'));
%% ========================================================================
save_vabs = 0;
save_figure = 0;
save_trsp = 0;

% CHOIX DE LA SECTION parmi les section='south','ovide', north', 'ride'
section='ride'; display(['section ' section]);

% Execution de la correction spe aux zones de fractures CGFZ/BFZ ou non
corr=1;

corr2=0; %test 100km si non filtré ou filtre 10km

filtre = 0; %0, 10, 20, 50, 100

methode = 'no_bottom'; %'pfit' (fit a plane), 'polyfit' (fit a polynomial), 'cstslope' (constant slope), 'horiz' (horizontal extrapolation)

bottom_v = 0;
%% ========================================================================
%file_ref=['../matlab_output_RREX17/vitesse_AVISO/v_AVISO_interp_section_' section '_RREX17'];
file_ref=['../matlab_output_RREX17/vitesse_AVISO/v_from_adt_AVISO_interp_section_' section '_RREX17'];

file_vgeo = ['../matlab_output_RREX17/vitesse_abs/OS38_section_' section '_' methode];

titre_fig = ['vitesses_geo_abs_AVISO_rrex17_' section];

if strcmp(section,'north')
    STA = [44:55 57]; STA=STA(:); nsta=size(STA,1); npair=nsta-1;
    sign=-1;
    xref='lon';
    
elseif strcmp(section,'ovide')
    STA = [18:20 22:24 27:28 43:-1:41 38:-1:31];STA=STA(:); nsta=size(STA,1); npair=nsta-1;   
    sign_est=1; %attention une partie de la section +1 et une partie -1
    sign_ouest=1;  
    xref='lon';
    
 elseif strcmp(section,'south') 
    STA = [1:8 11:17]; STA=STA(:); nsta=size(STA,1); npair=nsta-1;
    sign=-1;
    xref='lon'; 
    
 elseif strcmp(section,'ride')
    STA = [56:69 76:125];STA=STA(:); nsta=size(STA,1); npair=nsta-1; 
    sign=-1;
    xref='lat'; 
 
end


%%% lecture des donnees AVISO interp
load(file_ref,'dpair','Vortho_AVISO','VREF_AVISO_10km','VREF_AVISO_20km','VREF_AVISO_50km','VREF_AVISO_100km','lat','lon'); 
Vortho_AVISO = flip(Vortho_AVISO); %lat_aviso = lat; lon_aviso = lon;
VREF_AVISO_10km = flip(VREF_AVISO_10km); VREF_AVISO_20km = flip(VREF_AVISO_20km); VREF_AVISO_50km = flip(VREF_AVISO_50km); VREF_AVISO_100km = flip(VREF_AVISO_100km);

load(file_vgeo,'v_abs'); Vortho_geo_OS38 = v_abs(1,:);

% choix du fichier ctd pour figures
fctd = '../../DATA/HYDRO/RREX2017/ctd/nc/rr17_PRES.nc';
lon_ctd = ncload(fctd,'LONGITUDE'); lon_ctd = lon_ctd(2:end); lon_ctd = lon_ctd(STA);
lat_ctd = ncload(fctd,'LATITUDE'); lat_ctd = lat_ctd(2:end); lat_ctd = lat_ctd(STA);

%% ========================================================================
% CALAGE DU PROFIL GEOSTROPHIQUE SUR LA VITESSE REF AVISO SURFACE DANS LA COUCHE DE REFERENCE SELECTIONNEE
%%% Ajout d'une vitesse de reference aux vitesses geostrophiques
% lecture du fichier vitesse geostrophique
dpair=[]; v=[]; z=[]; zref=[]; lat=[]; lon=[]; ref_up_bott_tr=[]; ref_d_bott_tr=[];

for i=1:npair
    fic_vgeo = ['vitesse_geo/vgeo_' section '_' methode '_' num2str(STA(i),'%3.3d') '_' num2str(STA(i+1),'%3.3d')];
    load(['../matlab_output_RREX17/' fic_vgeo '.mat'],'dpair_geo','vgeo', 'zl', 'refc','lat_geo','lon_geo','ref_up_bott_triangle');
    dpair=[dpair dpair_geo]; v=[v vgeo]; z=[z zl]; zref=[zref refc]; lat=[lat lat_geo]; lon=[lon lon_geo]; ref_up_bott_tr = [ref_up_bott_tr ref_up_bott_triangle];
   
    if bottom_v == 1;
        load(['../matlab_output_RREX17/' fic_vgeo '.mat'],'ref_d_bott_triangle');
        ref_d_bott_tr = [ref_d_bott_tr ref_d_bott_triangle];
    end     
    
end;

v=sign*v;

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

    
 %%% Valeur de reference utilisee pour contraindre
 
 if filtre == 0
     v_ref = Vortho_AVISO; 
 elseif filtre == 10
     v_ref = VREF_AVISO_10km; 
 elseif filtre == 20
     v_ref = VREF_AVISO_20km; 
 elseif filtre == 50
     v_ref = VREF_AVISO_50km; 
 elseif filtre == 100
     v_ref = VREF_AVISO_100km; 
 end
 
 %v_ref = Vortho_geo_OS38'; %Pour comparaison
 
 if strcmp(xref,'lat');
     xlab='Latitude (°N)'; X1=lat;
 elseif strcmp(xref,'lon');
     xlab='Longitude (°E)'; X1=lon;
 end

 
%%% on utilise un v_ref1 moyen commun pour les stations proches aux zones de fractures (attÃ©nuer le bruit ageo)
if corr==1 & strcmp(section,'ride');
    moy_BFZ = meanoutnan(v_ref(25:29)); % Profil geo et ADCP proche a la paire 30: profils pas perturbe de la BFZ   
    moy_CGFZ = meanoutnan([v_ref(46) v_ref(48)]);
    v_ref = [v_ref(1:24)' repmat(moy_BFZ,1,5) v_ref(30:46)' repmat(moy_CGFZ,1,1) v_ref(48:end)'];
    
end

%test 1 "moyenne" sur trois paires de stations => 100km

% if corr2==1 & strcmp(section,'ride');
%     
% %     v_ref(1)=v_ref(2); %NaN
% %     for i=2:napair-1
% %         if dpair(i)<10e+04
% %             v_ref(i)=mean([v_ref(i-1) v_ref(i) v_ref(i+1)]);
% %         end
% %         
% %         
% %     end
% %     v_ref(npair)=mean([v_ref(npair-1) v_ref(npair)]);
%     
%      v_ref(1)=mean([v_ref(2) v_ref(3)]);
%      v_ref(2)=mean([v_ref(2) v_ref(3)]);
%      v_ref(npair)=mean([v_ref(npair-1) v_ref(npair)]);
%      for i=3:npair-1
%          v_ref(i)=mean([v_ref(i-1) v_ref(i) v_ref(i+1)]); 
%      end
% 
%      
% end

%test 2 moyenne sur 100km

% if corr2==1 & strcmp(section,'ride');
% 
% %     for i=1:npair
% %         n = 0;
% %         L = dpair(i);
% %         while L< 100e+03
% %             n = n+1;
% %             if n<=i-1 && n<=npair-i
% %                 L = sum(dpair(i-n:i+n));     
% %             elseif n>i-1 
% %                 L = sum(dpair(1:i+n));  
% %             elseif n>npair-i
% %                 L = sum(dpair(i-n:npair));
% %             end
% %         end
% %         
% %         if n<=i-1 && n<=npair-i
% %             v_ref(i)=mean(v_ref(i-n:i+n)); 
% %         elseif n>i-1 
% %             v_ref(i)=mean(v_ref(1:i+n));
% %         elseif n>npair-i
% %             v_ref(i)=mean(v_ref(i-n:npair));
% %         end
% %     end
% L = NaN*ones(npair,1); AB = NaN*ones(npair,2); 
% 
%     for i=1:npair
%         
%         a = 0; La = dpair(i)/2;
%         b = 0; Lb = dpair(i)/2;
%         
%         while La< 50e+03 && i < npair
%             a = a+1;
%             if a<=npair-i
%                 La = dpair(i)/2+sum(dpair(i+1:i+a));      
%             elseif a>npair-i  
%                 La = dpair(i)/2+sum(dpair(i+1:npair)); 
%             end
%         end
% 
%         while Lb< 50e+03 && i > 1
%             b = b+1;   
%             if b>i-1 
%                 Lb = dpair(i)/2+sum(dpair(1:i-1));     
%             elseif b<=i-1 
%                 Lb = dpair(i)/2+sum(dpair(i-b:i-1));
%             end
%         end    
%         
%         L(i) = La + Lb;
%         AB(i,1) = a; AB(i,2) = b; 
%         
%         v_ref(i)=mean(v_ref(i-b:i+a));
%               
%     end
%      
% end
% %test 3: [100km] vitesse meme signe..
% if corr2==1 & strcmp(section,'ride');
% figure;
% plot(lat,v_ref,'k.-','LineWidth',1);
% hold on; plot(repmat(lat(1),1,2),[-0.5 0.5],'Color',[0.5 0.5 0.5])
%          plot(repmat(lat(4),1,2),[-0.5 0.5],'Color',[0.5 0.5 0.5])
%          plot(repmat(lat(7),1,2),[-0.5 0.5],'Color',[0.5 0.5 0.5])
%          plot(repmat(lat(12),1,2),[-0.5 0.5],'Color',[0.5 0.5 0.5])
%          plot(repmat(lat(14),1,2),[-0.5 0.5],'Color',[0.5 0.5 0.5])
%          plot(repmat(lat(16),1,2),[-0.5 0.5],'Color',[0.5 0.5 0.5])
%          plot(repmat(lat(18),1,2),[-0.5 0.5],'Color',[0.5 0.5 0.5])
%          plot(repmat(lat(20),1,2),[-0.5 0.5],'Color',[0.5 0.5 0.5])
%          plot(repmat(lat(22),1,2),[-0.5 0.5],'Color',[0.5 0.5 0.5])
%          plot(repmat(lat(31),1,2),[-0.5 0.5],'Color',[0.5 0.5 0.5])
%          plot(repmat(lat(33),1,2),[-0.5 0.5],'Color',[0.5 0.5 0.5])
%          plot(repmat(lat(37),1,2),[-0.5 0.5],'Color',[0.5 0.5 0.5])
%          plot(repmat(lat(46),1,2),[-0.5 0.5],'Color',[0.5 0.5 0.5])
%          plot(repmat(lat(54),1,2),[-0.5 0.5],'Color',[0.5 0.5 0.5])
%          plot(repmat(lat(57),1,2),[-0.5 0.5],'Color',[0.5 0.5 0.5])
%          plot(repmat(lat(61),1,2),[-0.5 0.5],'Color',[0.5 0.5 0.5])
%          %plot(repmat(lat(62),1,2),[-0.5 0.5],'Color',[0.5 0.5 0.5])         
% %
%     v_ref(1:3)=mean(v_ref(1:4)); 
%     v_ref(5:6)=mean(v_ref(4:7)); v_ref(4)=mean(v_ref(3:5));
%     v_ref(8:11)=mean(v_ref(7:12)); v_ref(7)=mean(v_ref(6:8)); 
%     v_ref(13)=mean(v_ref(12:14)); v_ref(12)=mean(v_ref(11:13));
%     v_ref(15)=mean(v_ref(14:16)); v_ref(14)=mean(v_ref(14:15));
%     v_ref(17)=mean(v_ref(16:18)); v_ref(16)=mean(v_ref(15:17));
%     v_ref(19)=mean(v_ref(18:20)); v_ref(18)=mean(v_ref(17:19));
%     v_ref(21)=mean(v_ref(20:22)); v_ref(20)=mean(v_ref(19:21));
%     v_ref(23:30)=mean(v_ref(22:31)); v_ref(22)=mean(v_ref(21:23));
%     v_ref(32)=mean(v_ref(31:33)); v_ref(31)=mean(v_ref(30:32));
%     v_ref(34:36)=mean(v_ref(33:37)); v_ref(33)=mean(v_ref(32:34));
%     v_ref(38:45)=mean(v_ref(37:46)); v_ref(37)=mean(v_ref(36:38));
%     v_ref(47:53)=mean(v_ref(46:54)); v_ref(46)=mean(v_ref(45:47));
%     v_ref(55:56)=mean(v_ref(54:57)); v_ref(54)=mean(v_ref(53:55));
%     v_ref(58:60)=mean(v_ref(57:61)); v_ref(57)=mean(v_ref(56:58));
%     v_ref(62:end)=mean(v_ref(61:end)); v_ref(61)=mean(v_ref(60:62));
% 
% plot(lat,v_ref,'k.-','LineWidth',1);
% 
% end
%test 4: [100km] vitesse meme signe..
if corr2==1 & strcmp(section,'ride');
figure;
plot(lat,v_ref,'k.-','LineWidth',1);
grid on

hold on; 
plot(repmat(lat_ctd(1),1,2),[-0.5 0.5],'Color',[0.5 0.5 0.5])
plot(repmat(lat_ctd(3),1,2),[-0.5 0.5],'Color',[0.5 0.5 0.5])
plot(repmat(lat_ctd(4),1,2),[-0.5 0.5],'Color',[0.5 0.5 0.5])
plot(repmat(lat_ctd(5),1,2),[-0.5 0.5],'Color',[0.5 0.5 0.5])
plot(repmat(lat_ctd(7),1,2),[-0.5 0.5],'Color',[0.5 0.5 0.5])
plot(repmat(lat_ctd(10),1,2),[-0.5 0.5],'b')
plot(repmat(lat_ctd(14),1,2),[-0.5 0.5],'Color',[0.5 0.5 0.5])
plot(repmat(lat_ctd(15),1,2),[-0.5 0.5],'Color',[0.5 0.5 0.5],'Linestyle','--')
plot(repmat(lat_ctd(17),1,2),[-0.5 0.5],'Color',[0.5 0.5 0.5])
plot(repmat(lat_ctd(19),1,2),[-0.5 0.5],'Color',[0.5 0.5 0.5])
plot(repmat(lat_ctd(21),1,2),[-0.5 0.5],'Color',[0.5 0.5 0.5])
plot(repmat(lat_ctd(24),1,2),[-0.5 0.5],'Color',[0.5 0.5 0.5],'Linestyle','--')
plot(repmat(lat_ctd(31),1,2),[-0.5 0.5],'Color',[0.5 0.5 0.5])
plot(repmat(lat_ctd(36),1,2),[-0.5 0.5],'Color',[0.5 0.5 0.5])
plot(repmat(lat_ctd(39),1,2),[-0.5 0.5],'Color',[0.5 0.5 0.5])
plot(repmat(lat_ctd(44),1,2),[-0.5 0.5],'b')
plot(repmat(lat_ctd(46),1,2),[-0.5 0.5],'Color',[0.5 0.5 0.5],'Linestyle','--')
plot(repmat(lat_ctd(53),1,2),[-0.5 0.5],'b')
plot(repmat(lat_ctd(56),1,2),[-0.5 0.5],'Color',[0.5 0.5 0.5])
plot(repmat(lat_ctd(59),1,2),[-0.5 0.5],'Color',[0.5 0.5 0.5])
plot(repmat(lat_ctd(62),1,2),[-0.5 0.5],'Color',[0.5 0.5 0.5])
%

    v_ref(1:2)=mean(v_ref(1:2)); 
    v_ref(5:9)=mean(v_ref(5:9)); 
    v_ref(10:13)=mean(v_ref(10:13));
    v_ref(14:16)=mean(v_ref(14:16)); 
    v_ref(17:18)=mean(v_ref(17:18)); 
    v_ref(19:20)=mean(v_ref(19:20));
    v_ref(21:30)=mean(v_ref(21:30));
    v_ref(31:35)=mean(v_ref(31:35)); 
    v_ref(36:38)=mean(v_ref(36:38));
    v_ref(39:43)=mean(v_ref(39:43)); 
    v_ref(44:52)=mean(v_ref(44:52));
    v_ref(53:55)=mean(v_ref(53:55));
    v_ref(56:58)=mean(v_ref(56:58)); 
    v_ref(59:61)=mean(v_ref(59:61));
    v_ref(62:end)=mean(v_ref(61:end)); 

plot(lat,v_ref,'k.-','LineWidth',1);

end
%------------------------------------------------------------------------------------------------------------------
%%% Forcage de la vitesse geo par la vitesse ref AVISO
v_barocline = NaN*ones(length(z),npair);
 for i=1:npair
     %v(1:end,i) = v(1:end,i) - v(1,i) + v_ref(i)'; 
     v(1:end,i) = v(1:end,i) - (nanmean(v(1:101,i))) + v_ref(i)'; 
     v_barocline(1:end,i) = v(1:end,i) - (nanmean(v(1:101,i)));
 end
 
 %% ========================================================================
if bottom_v == 1;

for ipair=1:npair
    e = length(v(ref_up_bott_tr(ipair):ref_d_bott_tr(ipair),ipair))-1;
    e = v(ref_up_bott_tr(ipair),ipair)/e;
    v_bottom = 0:e:v(ref_up_bott_tr(ipair),ipair); 
    v_bottom = flip(v_bottom);
    v(ref_up_bott_tr(ipair):ref_d_bott_tr(ipair),ipair)= v_bottom;
end

end

%% ========================================================================


%Enregistrement de la vitesse absolue

if save_vabs == 1
    rept = '../matlab_output_RREX17/';
    
    % generation du nom du fichier de sortie
    fic_vabs = ['vitesse_abs/AVISO_filt' num2str(filtre) 'km_section_' section '_' methode ];
    display(['Traitement du fichier ' fic_vabs]);
    dpair_abs=dpair; v_abs_AVISO=v; v_barocline_AVISO=v_barocline; z_abs = zat(:); lat_abs_AVISO = lat; lon_abs_AVISO = lon; ref_up_bott_triangle = ref_up_bott_tr;
    save([rept fic_vabs '.mat'],'dpair_abs','v_abs_AVISO', 'v_barocline_AVISO', 'z_abs','lat_abs_AVISO','lon_abs_AVISO','ref_up_bott_triangle');

end

%% ========================================================================
% calcul du transport
% 
if strcmp(section,'ride'); 
    X = lat_ctd;

elseif strcmp(section,'south') || strcmp(section,'north')|| strcmp(section,'ovide') ; 
    X = lon_ctd;
end

%% Transport surface-fond
tr_z=trsp_geo_tp(v,zat,dpair);   tr_barocline=trsp_geo_tp(v_barocline,zat,dpair);
tr_z = tr_z*1e-06;               tr_barocline = tr_barocline*1e-06;

for i=1:npair; T_tot(i) = sum(tr_z(:,i)); end
for i=1:npair; T_up_bott_tr(i) = sum(tr_z(1:ref_up_bott_tr(i),i)); end

for i=1:npair; T_barocline(i) = sum(tr_barocline(:,i));  T_barotrope(i) = T_tot(i)-T_barocline(i); end

% Enregistrement du transport
rept='../matlab_output_RREX17/transport_geo/';
file_save=['transport_RREX17_AVISO_filt' num2str(filtre) 'km_section_' section '_' methode];

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
% 

    saveas(gcf, ['../figures/',titre_fig,'.png'])
end

%% ========================================================================
% clear all
% close all
% 
% filtre = 0; %0, 10, 20, 50, 100
% 
% file_v_abs_polyfit = ['../matlab_output_RREX17/vitesse_abs/AVISO_filt' num2str(filtre) 'km_section_ride_polyfit'];
% load(file_v_abs_polyfit); v_polyfit = v_abs_AVISO; v_polyfit_barocline = v_barocline_AVISO;
% file_v_abs_cstslope = ['../matlab_output_RREX17/vitesse_abs/AVISO_filt' num2str(filtre) 'km_section_ride_cstslope'];
% load(file_v_abs_cstslope,'v_abs_AVISO'); v_cstslope = v_abs_AVISO; v_cstslope_barocline = v_barocline_AVISO;
% file_v_abs_v_bottom = ['../matlab_output_RREX17/vitesse_abs/AVISO_filt' num2str(filtre) 'km_section_ride_triangle_bottom'];
% load(file_v_abs_v_bottom,'v_abs_AVISO'); v_bottom = v_abs_AVISO; v_bottom_barocline = v_barocline_AVISO;
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
% v_abs_AVISO = v_use;
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
% v_barocline_AVISO = v_barocline_use;
% 
% save(['../matlab_output_RREX17/vitesse_abs/AVISO_filt' num2str(filtre) 'km_section_ride_use.mat'],'dpair_abs','v_abs_AVISO','v_barocline_AVISO', 'z_abs','lat_abs_AVISO','lon_abs_AVISO','ref_up_bott_triangle');
% load('../matlab_output_RREX17/transport_geo/transport_RREX17_AVISO_ride_no_bottom','X','T_up_bott_tr');
% 
% 
% %%% Transport surface-fond
% tr_z=trsp_geo_tp(v_use,z_abs,dpair_abs); tr_barocline=trsp_geo_tp(v_barocline_use,z_abs,dpair_abs); 
% tr_z = tr_z*1e-06;                       tr_barocline = tr_barocline*1e-06;
% 
% for i=1:63; T_tot(i) = sum(tr_z(:,i)); end
% for i=1:63; T_barocline(i) = sum(tr_barocline(:,i));  T_barotrope(i) = T_tot(i)-T_barocline(i); end
% 
% % Enregistrement du transport
% save(['../matlab_output_RREX17/transport_geo/transport_RREX17_AVISO_filt' num2str(filtre) 'km_section_ride_use'],'X','T_tot','T_up_bott_tr','T_barocline','T_barotrope');












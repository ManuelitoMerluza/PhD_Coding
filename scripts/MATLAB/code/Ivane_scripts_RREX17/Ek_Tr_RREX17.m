%%% Calcul du transport d'Ekman perpendiculaire a  la section a partir de
%%% donnees de tension de vent era_interim et ncep

clear all
close all

addpath('../toolbox/matlab_fct_visu');
addpath(genpath('../toolbox/netcdf_lpo'));

save_ek = 0;

%%% Caracteristiques de chaque section et choix de la methode ('moyenne'
%%% ou 'each') et de la base de donnee ('era' ou 'ncep')
section='ride'; disp(['section ' section]);
methode='each'; disp(['methode ' methode]);
data='ncep'; disp(['data ' data]);

if strcmp(section,'ride')
    STA = [56:69 76:125]; STA=STA(:); nsta=size(STA,1); npair=nsta-1;
    keep_juld_era = [424:447];
    keep_juld_ncep = [853:900];
    geo_juld = [01 01 02 02 02 02 02 02 03 03 03 03 03 03 04 04 04 04 05 05 05 05 05 06 06 06 06 06 06 06 06 07 07 07 07 07 07 08 08 08 08 08 08 08 09 09 09 09 09 09 09 10 10 10 10 10 11 11 11 11 12 12 12];
    load ../matlab_output_RREX17/vitesse_abs/OS38_section_ride_polyfit.mat
    keep_lat_era = [26:-1:5]; keep_lon_era = [62:-1:46];
    keep_lat_ncep = [14:22]; keep_lon_ncep = [41:-1:35];
    
elseif strcmp(section,'ovide')
    STA = [18:20 22:24 27:28 43:-1:41 38:-1:31]; STA=STA(:); nsta=size(STA,1); npair=nsta-1; % Pour fichier CTD (angle phi)
    keep_juld_era = [404:419];
    keep_juld_ncep = [813:844];
    geo_juld = [22 22 23 23 23 24 24 25 26 26 26 27 27 27 27 27 27 28]; % Jours associes aux positions geo 
    load ../matlab_output_RREX17/vitesse_abs/OS38_section_ovide_polyfit.mat % fichier pour lat_abs/lon_abs
    keep_lat_era = [16:21]; keep_lon_era = [45:59]; 
    keep_lat_ncep = [16:18]; keep_lon_ncep = [34:40]; % idem pour les donnees NCEP
    
elseif strcmp(section,'south')
    STA = [1:8 11:17]; STA=STA(:); nsta=size(STA,1); npair=nsta-1;
    keep_juld_era = [396:404]; %[396:399];
    keep_juld_ncep = [797:804];
    geo_juld = [18 18 18 19 19 19 19 19 20 21 21 21 21 21];
    load ../matlab_output_RREX17/vitesse_abs/OS38_section_south_polyfit.mat
    keep_lat_era = [14:19]; keep_lon_era = [41:52];
    keep_lat_ncep = [19:-1:17]; keep_lon_ncep = [37:-1:33];
    
elseif strcmp(section,'north')
    STA = [44:55 57]; STA=STA(:); nsta=size(STA,1); npair=nsta-1;
    keep_juld_era = [420:425];
    keep_juld_ncep = [845:856];
    geo_juld = [30 30 30 30 31 31 31 31 01 01 01 01];
    load ../matlab_output_RREX17/vitesse_abs/OS38_section_north_polyfit.mat
    keep_lat_era = [21:26]; keep_lon_era = [49:67];
    keep_lat_ncep = [16:-1:14]; keep_lon_ncep = [43:-1:36];
end

if strcmp(data,'era')
    keep_juld = keep_juld_era;
    keep_lat = keep_lat_era;
    keep_lon = keep_lon_era;
    
    ewss_era = ncread('../../DATA/tension_vent/era/data2017_ewss.nc','ewss');
    nsss_era = ncread('../../DATA/tension_vent/era/data2017_nsss.nc','nsss');
    gregd_era = ncread('../../DATA/tension_vent/era/data2017_ewss.nc','time');
    lon_era = ncread('../../DATA/tension_vent/era/data2017_ewss.nc','longitude');
    lat_era = ncread('../../DATA/tension_vent/era/data2017_ewss.nc','latitude');
    
    lon = lon_era(388:479)-360;
    lat = flip(lat_era(28:61));
    
    ewss_era = ewss_era(388:479,28:61,:); ewss_era = flip(ewss_era,2); ewss_era = permute(ewss_era,[3 2 1]); ewss_era = ewss_era/43200; % /43200 car cumulé sur 12h
    nsss_era = nsss_era(388:479,28:61,:); nsss_era = flip(nsss_era,2); nsss_era = permute(nsss_era,[3 2 1]); nsss_era = nsss_era/43200;

    taux = ewss_era;
    tauy = nsss_era;
    gregd_era = double(gregd_era); %attention, calendrier gregorien heures depuis 01/01/1900 00h00
    juld = 693962 + gregd_era/24; juld = juld';
    time_era = datevec(juld);
    
elseif strcmp(data,'ncep')
    keep_juld = keep_juld_ncep;
    keep_lat = keep_lat_ncep;
    keep_lon = keep_lon_ncep;
    
    %%% Donnees NCEP de l'atlantique Nord
    taux = ncread('../../DATA/tension_vent/ncep/ncep2_atln_uflx_2017.nc','uflx'); taux = permute(taux,[3 2 1]);
    tauy = ncread('../../DATA/tension_vent/ncep/ncep2_atln_vflx_2017.nc','vflx'); tauy = permute(tauy,[3 2 1]);
    juld = ncread('../../DATA/tension_vent/ncep/ncep2_atln_uflx_2017.nc','time');
    lon = ncread('../../DATA/tension_vent/ncep/ncep2_atln_uflx_2017.nc','lon');
    lat = ncread('../../DATA/tension_vent/ncep/ncep2_atln_uflx_2017.nc','lat');
    
    juld = double(juld);
    time_ncep = datevec(juld);
end


%%% Differentes methodes de calcul: moyenne totale vs date des stations
switch methode
    case 'moyenne'
        taux = mean(taux(keep_juld,:,:),1); ewss = permute(taux,[2 3 1]);
        tauy = mean(tauy(keep_juld,:,:),1); nsss = permute(tauy,[2 3 1]);
        
        %%% Lat/lon des tensions de vent aux points geostrophiques entre station
        lat_tens = lat(keep_lat); lon_tens = lon(keep_lon);
        tens_ns = nsss(keep_lat,keep_lon);
        tens_ew = ewss(keep_lat,keep_lon);
        
        nsss_interp = interp1(lon_tens,tens_ns',lon_abs);
        ewss_interp = interp1(lon_tens,tens_ew',lon_abs);
        nsss_interp2 = interp1(lat_tens,nsss_interp',lat_abs);
        ewss_interp2 = interp1(lat_tens,ewss_interp',lat_abs);
        
        for i=1:length(lat_abs)
            ns_geo(i) = nsss_interp2(i,i);
            ew_geo(i) = ewss_interp2(i,i);
        end
        
    case 'each'
        
        for i=1:length(geo_juld) 
            keep_each = [];
            
            for j=1:length(keep_juld)
                A = datestr(juld(keep_juld(j)));
                
                if geo_juld(i) == str2num(A(1:2))
                    keep_each = [keep_each keep_juld(j)];
                end
                
            end
            
            taux_sta = mean(taux(keep_each,:,:),1); ewss = permute(taux_sta,[2 3 1]);
            tauy_sta = mean(tauy(keep_each,:,:),1); nsss = permute(tauy_sta,[2 3 1]);
            
            %%% Lat/lon des tensions de vent aux points geostrophiques entre station
            lat_tens = lat(keep_lat); lon_tens = lon(keep_lon);
            tens_ns = nsss(keep_lat,keep_lon);
            tens_ew = ewss(keep_lat,keep_lon);
            
            nsss_interp = interp1(lon_tens,tens_ns',lon_abs);
            ewss_interp = interp1(lon_tens,tens_ew',lon_abs);
            nsss_interp2 = interp1(lat_tens,nsss_interp',lat_abs);
            ewss_interp2 = interp1(lat_tens,ewss_interp',lat_abs);
            
            % selection de la lat/lon correspondant a la date keep_each
            ns_geo(i) = nsss_interp2(i,i);
            ew_geo(i) = ewss_interp2(i,i);

        end
             
end

ns_geo=ns_geo(:); ew_geo=ew_geo(:);

%figure; quiver(lon_abs,lat_abs,ewss_interp2,nsss_interp2);
%hold on ; plot(lon_abs,lat_abs)


%%% Orthogonalisation des tensions de vent
%%% Calcul d'angle entre 2 stations CTD
fctd = '../../DATA/HYDRO/RREX2017/ctd/nc/rr17_PRES.nc';
[d,lat,lon]=rctd_rrex_1(STA,fctd,'LATITUDE','LONGITUDE');
lat=lat(:); lon=lon(:); d=d(:);

[dpair,phi1,~]=dist_hm(lat,lon);
dpair=dpair(:);
phi1=phi1-90; phi1=-phi1;  phi1(phi1<0)=phi1(phi1<0)+360;                         
phi=phi1*pi/180; phi = phi(:);

tens_ortho = ew_geo.*cos(phi-pi/2) + ns_geo.*sin(phi-pi/2);


%%% Calcul du transport d'Ekman: la vitesse = -tau / (rho*f)
f=2*7.29e-5*sin(lat_abs/180*pi);
rho = 1027;
v_ek = -tens_ortho ./ (f*rho); % v_ek = vitesse dans la couche d'ekman (=1m)

for ip=1:length(dpair_abs)
    tr_ek(ip)=v_ek(ip).*dpair_abs(ip);
end
tr_ek = tr_ek(:)*1e-06;

figure; plot(lon_abs,tr_ek)


%%% Enregistrement des transports d'Ekman

if save_ek == 1
    rept = '../matlab_output_RREX17/transport_Ekman/';
    
    % generation du nom du fichier de sortie
    fic_ek = ['trsp_ek_' section '_' data '_' methode];
    display(['Traitement du fichier ' fic_ek]);
    save([rept fic_ek '.mat'],'dpair_abs','v_ek', 'tr_ek','lat_abs','lon_abs');

end





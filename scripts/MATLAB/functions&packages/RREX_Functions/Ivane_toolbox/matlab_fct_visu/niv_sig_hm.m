function [z,zf,lat_sta,lon_sta]=niv_sig_hm(fctd,numero,signame,sigval)

% [sta,z,zf] = niveau_sig(fctd,'SIG2',36.95);
% Détermination de la profondeur d'un niveau sigma defini par signame et
% sigval pour les stations du vecteur numero
% adapté du programme de Pascale

% lecture des données
ncload(fctd,'DEPH','PRES','STATION_NUMBER','LATITUDE_BEGIN','LONGITUDE_BEGIN','BOTTOM_DEPTH',signame);


% definition du parametre de référence et mises à NaN des valeurs absentes
if strfind(fctd,'PRES'),
  param = PRES;
elseif strfind(fctd,'DEPH'),
  param = DEPH;
end

param(param<-999)=NaN;


% recupération de la densité choisie et filtrage sinon le profil est trop
% bruité
s = eval(signame); s(s<-999)=NaN; 
s = filt_param(s,11);


% détermination de l'indice pour lequel la densité observée est égale à la
% densité cible sigval
% iz a la dimension du nombre de stations
[~,iz]=min(abs(s'-sigval));


% on recupere la valeur du parametre de reference pour l'isopycne et 
% la valeur maximale du parametre de reference à la station
z = meanoutnan(param);
Z = z(iz)';
param(isnan(param))=0;
ZF = max(param')';


% en raison du lissage, les niveaux de sigma trouves a moins de 10m du fond
% sont ramenes au fond
iifond=find(abs(Z-ZF)<10);
Z(iifond)=ZF(iifond);
Z = Z(:); ZF = ZF(:);


% si la parametre de reference est la pression on convertit en profondeur
if strfind(fctd,'PRES'),
  Z = depth(Z,LATITUDE_BEGIN);
  ZF = depth(ZF,LATITUDE_BEGIN);
end


% il n'y a plus qu'à extraire les staions qui nous interessent
numero=numero(:); nsta=size(numero,1); z=NaN(nsta,1); zf=NaN(nsta,1);
lat_sta=NaN(nsta,1); lon_sta=NaN(nsta,1);

for i=1:nsta
    z(i)=Z(STATION_NUMBER==numero(i));
    zf(i)=ZF(STATION_NUMBER==numero(i));
    lat_sta(i)=LATITUDE_BEGIN(STATION_NUMBER==numero(i));
    lon_sta(i)=LONGITUDE_BEGIN(STATION_NUMBER==numero(i));
end

z=z(:); zf=zf(:);  lat_sta=lat_sta(:);  lon_sta=lon_sta(:); 

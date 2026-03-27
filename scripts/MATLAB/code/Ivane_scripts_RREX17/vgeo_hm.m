function [u,xu,refc,reffond,dpair]=vgeo_hm(p,H,lat,lg,xunite,ref,pmae)

%key: Calcul des vitesses geostrophiques
%synopsis : vgeo_hm.m
%
%description : 
% fonction permettant le  calcul des vitesses geostrophiques a partir des  
% fichiers hydro de rrex 
%
%uses: 
% n : nombre de stations
% m : nombre de profondeurs
%
% si coupe WE (lg croissantes et xunite='long'), u>0 si dH>0
% si coupe NS (lat croissantes et xunite='lat'), v<0 si dH>0; => u=-u 
% si coupe oblique (xunite='mille' ou 'km'), u>0 indique une composante 'a droite'.
%
% u: vitesse perpendiculaire aux paires de stations (dim:m*n-1)
% xu: abscisses des profils de u en unites xunite (dim:n-1)
% refc: reference (differente de ref si ref=inf, dim:1 ou n-1)
% reffond: reference du fond
% dpair: distance entre station (positive)
%
% H : matrice des hauteurs dynamiques (dim:m*n)
% lat,lg : vecteurs des coord. des stations (dim:n)
% xunite : 'long','lat','mille' ou 'km'
% ref : scalaire, vect. (dim:n-1) ou 'inf'; 
%       ref=inf =>ref a la pression la plus grande possible.
% pmae : vecteur des pressions max des mesures (dim:n);
%
%
%author(s) : P. Lherminier
%               H. Mercier (herle.mercier@ifremer.fr) Sept 2018 revised
%
%References:
%  Petit, T., Mercier, H. and Thierry T. (2018), First direct estimates of 
%  volume and water mass transports across the Reykjanes Ridge. Journal of
%  Geophysical Research: ocean, doi:10.1029/2018JC013999
%
%see also: rctd_rrex_1.m




display('vgeo_hm ne fonctionne que avec les fichiers *PRES.nc') 


% initialisations 
[m,n]=size(H);
u=NaN*ones(size(H)); u(:,n)=[];


% calcul du parametre de coriolis
latpair=(lat(1:n-1)+lat(2:n))/2;
f=2*7.29e-5*sin(latpair/180*pi);


% distance entre les deux stations de la paire
dpair=my_dist(lat,lg);
dpair=abs(dpair);


%ce vecteur de 'fond' reffond est toujours utile pour le cache de la coupe
%(dim de pmae-1 car difference des stations i et i+1 indique en i)
if nargin<7, error('indiquer les dernieres pressions exp. en 5e argument');end;
ip=find(diff(pmae)>=0); im=find(diff(pmae)<0);
if ~isempty(ip), reffond(ip)=pmae(ip); end; % on selectionne la station la moins profonde entre 2 
if ~isempty(im), reffond(im)=pmae(im+1); end;


%si ref=inf, reference pour chaque couple de station = la + gde pression commune
if isinf(ref), refc=reffond;
else if length(ref)==1, refc=ref*ones(n-1,1); end;
     if length(ref)==n-1, refc=ref; reshape(refc,n-1,1); end;
     ireftouchfond=find(reffond-refc'<0);
     refc(ireftouchfond)=reffond(ireftouchfond);
end;

% determination des indices du niveau de reference a appliquer pour H
for i = 1:n-1
    irefc(i) = find(p(:,i)==refc(i));
end

% calcul de la vitesse geostrophique à partir de la hauteur dynamique
for i=1:n-1,
  % irefc=find(p==refc(i)); % indices en 1D (par colonne) donc pas
  % applicable a la premiere dimension de H...
  if isempty(irefc), irefc=max(find(p<=refc(i))); end;
  href=H(irefc(i),[i i+1]); % hauteur dynamique au niveau de reference pour chaque couple de stations
  Hf=H(:,[i i+1])-ones(m,1)*href;
  dH=(diff(Hf'))'*10;
  u(:,i)=-dH/(f(i)*dpair(i));
end;


%determination de xu :
if     strcmpi(xunite(1:2),'la'), xu=(lat(1:n-1)+lat(2:n))/2; 
elseif strcmpi(xunite(1:2),'lo'), xu=(lg(1:n-1)+lg(2:n))/2;
elseif strcmpi(xunite(1:2),'mi'),d=cumsum([0,dpair]/1853);xu=(d(1:n-1)+d(2:n))/2;
elseif strcmpi(xunite(1:2),'km'),d=cumsum([0,dpair]/1000);xu=(d(1:n-1)+d(2:n))/2;
end;
xu=xu(:); dpair=dpair(:);


function tr=trsp_geo(u,zl,dpair)

% calcul du transport tr(npair) associé au champ de vitesse u, entre deux
% limites de profondeur fixées

% u(nz,npair) vitesse
% zl(nz) profondeur positive qui commence à zero
% dpair distance affectée à chaque vitesse u
% zup(npair) limite supérieure du transport
% zbot(npair) limite inferieure du transport

% initialisations
npair=size(u,2); tr=NaN(length(zl),npair);


% on remplace les vitesse à NaN par zero, par facilité
u(isnan(u))=0;

% on calcule le deltaz sur la verticale
zl=zl(:); 
zl=zl(~isnan(zl)); za=zl(1:end-1); zb=zl(2:end); dz=zb-za; dz1=[0;dz]; dz2=[dz;0];
dz=0.5*(dz2+dz1);

for ip=1:npair

    % on calcule les transports
    tr(:,ip)= u(:,ip).*dz(:).*dpair(ip);
    
end
end

function tr=trsp_sadcp(u,zl,dpair,zup,zbo,zmax)

% calcul du transport tr(npair) associé au champ de vitesse u, entre deux
% limites de profondeur fixées

% u(nz,npair) vitesse
% zl(nz) profondeur positive qui commence à zero
% dpair distance affectée à chaque vitesse u
% zup(npair) limite supérieure du transport
% zbot(npair) limite inferieure du transport

% initialisations
u=u';
npair=size(u,2); tr=NaN(npair,1);


% on remplace les vitesse à NaN par zero, par facilité
u(isnan(u))=0;


% on calcule le deltaz sur la verticale
zl=zl(:); za=zl(1:end-1); zb=zl(2:end); dz=zb-za; dz1=[0;dz]; dz2=[dz;0];
dz=0.5*(dz2+dz1);


% on calcule les transports
for ip=1:npair
    
    if zbo(ip)< zmax(ip)
        iz = zl >= zup(ip) & zl < zbo(ip);
    else
        iz = zl >= zup(ip) & zl <= zmax(ip);
    end
        
    tr(ip)= sum(u(iz,ip).*dz(iz)).*dpair(ip);
    
end
end

function tr_brc=trsp_brc_sadcp(u,zl,dpair,zup,zbo,zmax,ref)

% calcul du transport barocline tr_brc(npair) associé au champ de vitesse u, entre deux
% limites de profondeur fixées

% u(nz,npair) vitesse
% zl(nz) profondeur positive qui commence à zero
% dpair distance affectée à chaque vitesse u
% zup(npair) limite supérieure du transport
% zbot(npair) limite inferieure du transport
% ref est le niveau de référence par rapport auquel le transport est
% calculé

% initialisations
u=u';
npair=size(u,2); tr_brc=NaN(npair,1);


% on remplace les vitesses à NaN par zero, par facilité
u(isnan(u))=0;


% on calcule le deltaz sur la verticale
zl=zl(:); za=zl(1:end-1); zb=zl(2:end); dz=zb-za; dz1=[0;dz]; dz2=[dz;0];
dz=0.5*(dz2+dz1);


% on recherche le niveau le plus proche du niveau de reference ref
[~,I]=min(abs(zl-ref));

% on calcule les transports
for ip=1:npair
    
    if zbo(ip)< zmax(ip)
        iz = zl >= zup(ip) & zl < zbo(ip);
    else
        iz = zl >= zup(ip) & zl <= zmax(ip);
    end
        
    tr_brc(ip)= sum( (u(iz,ip)-u(I,ip)).*dz(iz) ).*dpair(ip);
    
end
end

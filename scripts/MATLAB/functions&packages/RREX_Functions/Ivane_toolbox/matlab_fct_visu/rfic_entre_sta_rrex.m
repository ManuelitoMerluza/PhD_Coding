function [numero_entre_sta, deb_sec, fin_sec, INDICE_DEB, INDICE_FIN]=rfic_entre_sta_rrex(fsec,JULD,SecLat)

% lecture des fichiers entre station sadcp et retour des parametres
fid = fopen(fsec,'r');
res=fscanf(fid,'%d %d/%d/%d %d:%d:%d %d %d/%d/%d %d:%d:%d',[14 inf]);
fclose(fid);


% numero des sections
numero_entre_sta(:,1)=res(1,:); numero_entre_sta(:,2)=res(8,:); nentre_sta=size(numero_entre_sta,1);


% decodage des dates début et fin
deb_sec=datenum([res(4,:) ;res(3,:) ;res(2,:) ;res(5,:) ;res(6,:) ;res(7,:)]');
fin_sec=datenum([res(11,:) ;res(10,:) ;res(9,:) ;res(12,:) ;res(13,:) ;res(14,:)]');


% on affecte à db_sec et fin_sec des jours juliens format matlab existant
% dans le fichier SADCP
deb_sec_ok=deb_sec; fin_sec_ok=fin_sec;

for i_sec=1:nentre_sta
    
    interm = JULD( (JULD>=deb_sec(i_sec)) & (JULD<=fin_sec(i_sec)) & isfinite(SecLat) );
             
    if ~isempty(interm) 
        deb_sec_ok(i_sec)=interm(1); fin_sec_ok(i_sec)=interm(end);
    else
        fprintf('%s %3d \n','pas de données sadcp pour entre station',i_sec);
        deb_sec_ok(i_sec)=NaN; fin_sec_ok(i_sec)=NaN;
    end
end

deb_sec=deb_sec_ok; deb_sec=deb_sec(:);
fin_sec=fin_sec_ok; fin_sec=fin_sec(:);


% on recherche les indices des debuts et fin de section dans le fichier
% SADCP
for i_sec=1:nentre_sta
    
    if ~isnan(deb_sec(i_sec)) && ~isnan(fin_sec(i_sec))
        
        [I,~]=find(JULD==deb_sec(i_sec)); INDICE_DEB(i_sec)= I;
        [I,~]=find(JULD==fin_sec(i_sec)); INDICE_FIN(i_sec)= I;
    
    else
        
        INDICE_DEB(i_sec)=NaN; INDICE_FIN(i_sec)=NaN;
    end
        
end

INDICE_DEB=INDICE_DEB(:);
INDICE_FIN=INDICE_FIN(:);
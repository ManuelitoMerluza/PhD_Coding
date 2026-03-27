function [UVEL_ADCP,VVEL_ADCP,SecLat,SecLon,DEPH,JULD,U_TIDE,V_TIDE,INDICE,BATHY,URMS_ADCP,VRMS_ADCP] = rsadcp_rrex(fsadcp)

% lecture des données sadcp en sortie de cascade


% ouverture du fichier
[UVEL_ADCP,VVEL_ADCP,SecLat,SecLon,DEPH,JULD,U_TIDE,V_TIDE,INDICE,BATHY,URMS_ADCP,VRMS_ADCP]=...
    ncload(fsadcp,'UVEL_ADCP','VVEL_ADCP','SecLat','SecLon','DEPH','JULD','U_TIDE','V_TIDE','INDICE','BATHY','URMS_ADCP','VRMS_ADCP');


% passage en date matlab
JULD=JULD+datenum(1950,1,1);


% remplacer les valeur erreur -999999 par NaN
UVEL_ADCP(UVEL_ADCP < -999998)=NaN;
VVEL_ADCP(VVEL_ADCP < -999998)=NaN;
U_TIDE(U_TIDE < -999998)=NaN;
V_TIDE(V_TIDE < -999998)=NaN;
BATHY(BATHY < -999998)=NaN;
URMS_ADCP(URMS_ADCP < -999998)=NaN;
VRMS_ADCP(VRMS_ADCP < -999998)=NaN;


% on affecte les autres variables
SecLat=SecLat(:); SecLon=SecLon(:); INDICE=INDICE(:); BATHY=BATHY(:); JULD=JULD(:); DEPH=DEPH(:);
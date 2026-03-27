%-----------------------------------------------------------------------------------
%  Projet ATLANTIQUE
%  -----------------
%  Version: 1.0
%  ------------
%  Creation : Octobre 2001 /  C.Grit
%  Modification : Juin 2002
%  repris par C. Lagadec pour projet Atlantique
% 
%  Modification : Avril 2007 T.Loaëc                                           
%-------------------------------------------------------------------------------
%  Plots de contrôle suivant la demande de l'utilisateur
%-------------------------------------------------------------------------------

parameters;

% ajustement des latitudes  min et max 
%         et des longitudes min et max 
% aux stations selectionnees
% ------------------------------------

lon_extract_min = min(londeb_sta)-2.;
lon_extract_max = max(londeb_sta)+2.;
lat_extract_min = min(latdeb_sta)-2.;
lat_extract_max = max(latdeb_sta)+2.;
	

%=======================================================
% Trace de la carte des positions des stations en double 
%=======================================================
     messdbl = 'Stations en double';
     idbl = find(flag_dbl_sta == 1);

     if  (idbl > 0)
        londeb_dbl = londeb_sta(idbl);
        latdeb_dbl = latdeb_sta(idbl);
 
        figure;
        m_proj('mercator','lon',[lon_extract_min lon_extract_max],'lat',[lat_extract_min lat_extract_max]);
        hold on;

        m_gshhs_i('patch',[0.60  0.50  0.40],'edgecolor','none');
        m_grid('box','fancy','color',[0 0 0],'linestyle','-.');
        [x,y]=m_ll2xy(londeb_dbl,latdeb_dbl);

        plot(x,y,'r.');
     
        xlabel('LONGITUDE');
        ylabel('LATITUDE'); 

        messnbdbl = str2mat('Nbre de stations en double dans les fichiers H2V2 sélectionnés : ', num2str(length(idbl)));  

        msgbox(messnbdbl, messdbl);
     else
        
        messnbdbl = 'Pas de station en double dans les fichiers sélectionnés';  

        msgbox(messnbdbl, messdbl);
     end


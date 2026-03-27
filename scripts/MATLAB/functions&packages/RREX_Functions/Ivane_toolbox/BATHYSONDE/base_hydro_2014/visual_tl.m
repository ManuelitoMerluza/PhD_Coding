%-----------------------------------------------------------------------------------
%  Projet ATLANTIQUE
%  -----------------
%  Version: 1.0
%  ------------
%  Creation : Octobre 2001 /  C.Grit
%  Modification : Juin 2002
%  Modification : Avril 2007 T.Loaëc
%  repris par C. Lagadec pour projet Atlantique
%                                            
%-------------------------------------------------------------------------------
%  Plots de contrôle suivant la demande de l'utilisateur
%-------------------------------------------------------------------------------

parameters_dbl;



% initialisations par defaut
%---------------------------

icarte   = 0;
iprofil  = 0;
isection = 0;
param    = [];
indice   = [];
lon_sav=[];
lat_sav=[];

% initialisation de la table des couleurs
tab_coul = ['b';'g';'r';'v';'m';'y';'k'];

[a,b] = size(param_extract);

% le parametre DEPH est systematiquement selectionne 
param_visu(1:a-1,:) = param_extract(2:a,:);


% ajustement des latitudes  min et max 
%        et des longitudes min et max 
%  aux stations selectionnees

lon_extract_min = min(londeb_sta)-5.;
lon_extract_max = max(londeb_sta)+5.;
lat_extract_min = min(latdeb_sta)-5.;
lat_extract_max = max(latdeb_sta)+5.;



% on peut tracer la carte de positions des stations  
%---------------------------------------------------------------

fig_import = figure('Units','normalized', ...
	'Color',[0.8 0.8 0.8], ...
        'Name','CHOIX DE VISUALISATION', ...
	'PaperPosition',[18 180 576 432], ...
	'PaperUnits','points', ...
	'Position',[0.487 0.376 0.3 0.3], ...
        'NumberTitle','off',...
	'MenuBar','none');
	
% trace de la carte de positions des profils
%--------------------------------------------
uicontrol('Parent',fig_import, ...
	'Units','normalized', ...
	'BackgroundColor',[0.8 0.8 0.8], ...
	'FontSize',12, ...
	'ListboxTop',0, ...
	'Position',[0.01 0.7 0.8 0.08], ...
	'String','Carte de positions des stations', ...
	'Style','text');

h1 = uicontrol('Parent',fig_import, ...
	'Units','normalized', ...
	'BackgroundColor',[0.70196 0.70196 0.70196], ...
	'ListboxTop',0, ...
       'Callback',['global icarte;',...
		    'icarte=get(gco,''Value'');'], ...
	'Position',[0.85 0.7 0.08 0.08], ...
	'Style','CheckBox');

% push ok
%---------
uicontrol('Parent',fig_import, ...
	'Units','normalized', ...
	'BackgroundColor',[0.70196 0.70196 0.70196], ...
	'FontSize',10, ...
	'ListboxTop',0, ...
	'Position',[0.4 0.06 0.2 0.1], ...
       'Callback',['global icarte iprofil isection;',...
	'if isempty(icarte),',...
	'    icarte=0;',...
	'end;',...
	'if isempty(iprofil),',...
	'    iprofil=0;',...
	'end;',...
        'if isempty(isection),',...
	'    isection=0;',...
	'end;',...
	'close;'],...
	'String','OK',...
	'Style','Pushbutton');

% push annuler
%-------------
uicontrol('Parent',fig_import, ...
	'Units','normalized', ...
	'FontSize',10, ...
	'ListboxTop',0, ...
	'Position',[0.6 0.06 0.2 0.1], ...
        'Callback','close', ...
	'String','Annuler');
	
uiwait(fig_import);


%=============================================
% Trace de la carte des positions des stations
%=============================================

if (icarte==1) 

%sauvegarde des données initiales
	lon_sav=londeb_sta;
	lat_sav=latdeb_sta;

%enlever les stations non double de latdeb_sta et londeb_sta
	londeb_sta=[];
	latdeb_sta=[];
	cpt=1;cptt=1;
        
        for i=1:nb_stat_extract
		if (flag_dbl_sta(i)==0)
			cpt=cpt+1;
		else
                      londeb_sta(cptt)=lon_sav(i);
		      latdeb_sta(cptt)=lat_sav(i);
		      cptt=cptt+1;
		end
	end
        nombre_de_stations_en_doubles=nb_stat_extract-cpt+1
     figure;
     m_proj('mercator','lon',[lon_extract_min lon_extract_max],'lat',[lat_extract_min lat_extract_max]);
     hold on;
%     m_coast('linewidth',2,'color',[1 0 0]);
%    m_coast('patch',[0.60  0.50  0.40],'edgecolor','none');
     m_gshhs_i('patch',[0.60  0.50  0.40],'edgecolor','none');
     m_grid('box','fancy','color',[0 0 0],'linestyle','-.');
     [x,y]=m_ll2xy(londeb_sta,latdeb_sta);

     plot(x,y,'r.');
     
     xlabel('LONGITUDE');
     ylabel('LATITUDE');

%restitution des données initiales
     londeb_sta=lon_sav;
     latdeb_sta=lat_sav;

end; % end du icarte=1

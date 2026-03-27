
		        %----------------------------------------%
              		%                                        %
	        	%  CREATION DE FICHIERS MULTISTATION A   %
         		%  PARTIR DE FICHIERS UNISTATION         %
        		%----------------------------------------%

close all; clear all;

globalVarEtiquni ;
globalajo ;
globalRepDef ;
globalVarDef ;
globalVarASCI ;
globalVMLT ;

global type ;

% variables qui servent a determiner si l'utilisateur a choisi un parametre 
% de reference (pass_ref) ou s'il faut prendre celui par defaut, et si 
% l'utilisateur a choisi des parametres physiques (pass_par)
% ou s'il faut tous les prendre par defaut.
% ----------------------------------------------------------------------------

global pass_ref pass_par ;


init_cre ;
init_cre_mlt ;


% par defaut, le code de reference est la pression
CODE_REF = 'PRES';

f = figure('Units','normalized', ...
           'Color',[0.8 0.8 0.8], ...
           'Name','Cremlt', ...
           'NumberTitle','off', ...
	   'Position',[0.45 0.81 0.54 0.12], ...
           'MenuBar','none');



% ==============================================================

% CONFIGURATION
% ---------------

h1=uimenu(f,'Label','Configuration');

% sous-menu du menu Configuration : il permet a l'utilisateur de lire des
% fichiers qui ne sont pas dans son repertoire courant, et d'ecrire
% les resultats obtenus dans un autre repertoire.
% -------------------------------------------------------------------------

uimenu(h1,'Label','Environnement de travail ...',...
                'Separator', 'off', ...
                'Callback','choix_envir_cli');



% ==================================================================

% STATIONS
% --------

h3 = uimenu(f,'Label','Stations');

% sous-menu du menu stations 
% ---------------------------

% sous-menu qui permet de selectionner les fichiers par suite continue,
% en donnant le premier et le dernier d'une liste
% **********************************************************************

uimenu(h3,'Label','Suite continue ...', ...
                'Separator','off', ...
                'Callback',' suf=''_clc.nc'';stat_suit') ;

% sous-menu qui permet a l'utilisateur de choisir des fichiers a partir 
% d'un fichier catalogue 
% ***********************************************************************

uimenu(h3,'Label','Catalogue ...', ...
                'Separator','on', ...
                'Callback','global masq_cat; masq_cat=''*clc.cat'';stat_cat(masq_cat)') ;

% sous-menu qui permet a l'utilisateur de choisir des fichiers qui sont 
% dans le repertoire de lecture qu'il a donne dans le precedent menu
% **********************************************************************

uimenu(h3,'Label','Repertoire ...', ...
                'Separator','on', ...
                'Callback','suf=''clc.nc'';stat_rep') ;

	

% =============================================================

% PARAMETRAGE
% -----------

h4 = uimenu(f,'Label','Parametrage');

% sous-menu du menu Parametrage
% -----------------------------

% sous-menu qui permet a l'utilisateur de changer les valeurs min et/ou max
% et le pas d'echantillonnage de la pression(parametre de reference par 
% defaut), et qui permet egalement de changer le parametre de reference,
% ainsi que les valeurs min et max et le pas.
% **************************************************************************

uimenu(h4,'Label','Parametre de reference ...', ...
		'Separator','on', ...
		'Callback',[' if isempty(NBFILES),', ...
			    	'h = warndlg(''Vous devez d''''abord choisir des stations'',''Attention'') ;', ...
			    	'waitfor(h),', ...
			    'else,param_ref_mlt ;', ...
			    	'pass_ref = 1;', ...	
			    'end']) ;

% sous-menu qui permet a l'utilisateur de choisir des parametres physiques
% ************************************************************************

uimenu(h4,'Label','Choix des parametres physiques ...', ...
		'Separator','off', ...
		'Callback',['if (isempty(NBFILES)),', ...
			    'h = warndlg(''Vous devez d''''abord choisir des stations'',''Attention'') ;', ...
		            'waitfor(h),', ...    
			    'else,choix_param_phys;', ...
			    'pass_par = 1;', ...
		            'end']) ;




% =======================================================================

% CREATION DES FICHIERS
% --------------------

h5 = uimenu(f,'Label','Creation du Fichier ');

% sous-menu du menu Creations des fichiers
% -----------------------------------------

% sous-menu qui permet a l'utilisateur de controler tous les choix qu'il
% a pu faire auparavant et de modifier certains de ces choix, ou de creer
% directement son fichier multistation.
% ************************************************************************

uimenu(h5,'Label','Recapitulatif ...', ...
             'CallBack',['if ( isempty(pass_ref) & isempty(pass_par) ),', ...
				'h = warndlg(''Vous devez choisir des parametres et  valider le param de reference.'',''Attention'');', ...
			  'elseif isempty (pass_ref),', ...
			 	'h = questdlg(''Vous devez valider un parametre de reference.'',''Attention'');', ...
			 'elseif isempty (pass_par),', ...
				'h = questdlg(''Vous desirez choisir des parametres'',''Attention'');', ...
			 'else,recap_phys_mlt ; end']); 


% sous-menu qui permet a l'utilisateur de créer le fichier multistation
% *********************************************************************

h_supp = uimenu(h5,'Label','Creation ...', ...
                'Separator','on', ...
	            'Callback',['if ( isempty(pass_ref) & isempty(pass_par) ),', ...
				'h = warndlg(''Vous devez choisir des parametres et  valider le param de reference.'',''Attention'');', ...
			  'elseif isempty (pass_ref),', ...
			 	'h = warndlg(''Vous devez valider un parametre de reference.'',''Attention'');', ...
			  'elseif isempty (pass_par),', ...
				'h = questdlg(''Vous desirez choisir des parametres'',''Attention'');', ...
              'else,creat_phys_mlt; end']);

% =======================================================================

% Ajout de la chimie LPO dans le fichier créé
% -------------------------------------------

h6 = uimenu(f,'Label','Ajout de la chimie LPO');
 %             'Callback','ajomlt_chim');
uimenu(h6,'Label','Param chimiques', ...
       'Callback',['button = questdlg([''Ajout dans le MLT de tous les paramètres chimiques des fichiers clc ? ''],', ...
                   '''Chimie'',''Oui'',''Non'',''Non'');', ...
                   'if strcmp(button,(''Oui'')),', ...
                    'ajomlt_chim; end']);


% =======================================================================

% BOUTON QUITTER APPLICATION
% --------------------------

h7=uimenu(f, 'Label', 'Quitter ');


% sous-menu du menu Quitter
% --------------------------

% sous-menu qui permet a l'utilisateur de quitter l'application, de fermer toutes
% les fenetres qui sont restees eventuellement ouvertes et d'effacer toutes les variables.
% ****************************************************************************************

uimenu(h7,'Label','Quitter l''application', ...
          'Callback','clear all,close all');


% -----------------------------------------------------------------

% Titre de l'interface
% ---------------------

uicontrol('Parent',f, ...
	'Units','normalized', ...
	'BackgroundColor',[0.8 0.8 0.8], ...
	'FontSize',16, ...
	'Position',[0.2 0.50 0.45 0.2], ...
	'String','CREATION DE FICHIERS', ...
	'Style','text');

uicontrol('Parent',f, ...
	'Units','normalized', ...
	'BackgroundColor',[0.8 0.8 0.8], ...
	'FontSize',16, ...
	'Position',[0.2 0.20 0.45 0.2], ...
	'String','MULTISTATION', ...
	'Style','text');


% Zone du logo
% ------------
	
axes('position',[0.75 0.1 0.2 0.8]);

% Logo
% ----

[x, map]=imread('lpo.jpg');
image(x);
colormap(map);
axis off;

clear current;

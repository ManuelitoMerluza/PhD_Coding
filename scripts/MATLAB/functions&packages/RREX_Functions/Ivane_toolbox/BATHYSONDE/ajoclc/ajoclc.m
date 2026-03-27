globalVarEtiquni;

globalVarDef;
 
globalRepDef;

globalajo;

% nom de la fenetre pour le suivi des calculs
global hsuivi_ajo;
global COD;
% -----------------------------------------------------------

AJO.decalbrv2 = [];
AJO.decalfbrv = [];
AJO.decaldynh = [];

init_cre;

init_ajoclc;

messtat = 'Vous devez d''abord choisir les fichiers a traiter.';
messajo = 'Vous devez d''abord choisir un nom de fichier .ajo contenant les codes des parametres a ajouter.';


f= figure('Units','normalized', ...
           'Color',[0.8 0.8 0.8], ...
           'Name','Ajoclc', ...
           'NumberTitle','off', ...
	       'Position',[0.45 0.81 0.54 0.12], ...
           'MenuBar','none');

% ----------------------------------------------------------

% Lecture du fichier des codes parametres (fichier modele) 
% --------------------------------------------------------

%COD.nomfic = 'service/ficodf';
[messerr] = lfcod_phys;


% CONFIGURATION
% =============

h1=uimenu(f,'Label','Configuration          ');

uimenu(h1,'Label','Environnement de travail ...',...
                'Separator', 'off', ...
                'Callback','choix_envir_ajo');


% ---------------------------------------------------------


% STATIONS
% --------

h2 = uimenu(f,'Label','Stations          ');

% sous menus du menu stations 
% ---------------------------

h21 = uimenu(h2,'Label','Suite continue ...', ...
                'Separator','off', ...
                'Callback',('suf=''_clc.nc'';stat_suit'));

h22 = uimenu(h2,'Label','Catalogue ...', ...
                'Separator','on', ...
                'Callback',('global masq_cat, masq_cat=''*clc.cat'';stat_cat(masq_cat)'));

h23 = uimenu(h2,'Label','Repertoire ...', ...
                'Separator','on', ...
                'Callback',('suf=''clc.nc'';stat_rep'));



% ---------------------------------------------------
% ---------------------------------------------------

h3 = uimenu(f,'Label','Ajout  des  parametres   ');

% sous menus du menu Ajout 
% ------------------------

h31 = uimenu(h3,'Label','Ajout a partir d''un fichier ...', ...
	      'CallBack', ['if (isempty(ETIQ.codes_paramp)),', ...
                                 'h=warndlg(messtat,''Attention'');', ...
                                 'waitfor(h);', ...
                              'else,', ...
                                 'messerr=charg_ajo;', ...
                                 'if ~isempty(messerr),', ...
                                      'close,', ...
                                 'else,', ...
                                      'rech_param_calc(AJO);end;end']);                          

h32 = uimenu(h3,'Label','Ajout a partir de la liste par defaut ...', ...
	      'CallBack',['if (isempty(ETIQ.codes_paramp)),', ...
                                 'h=warndlg(messtat,''Attention'');', ...
                                 'waitfor(h);', ...
                              'else,', ...
                                 'choix_param_calc;end;']);


% bouton Quitter application
% --------------------------

h4 = uimenu(f, 'Label','Quitter');

uimenu(h4,'Label','Quitter l''application', ...
          'Callback',['global hsuivi_ajo;close(hsuivi_ajo);', ...
                      'if (ECR.nbpar ~= 0),', ...
                    'button = questdlg(''Desirez-vous sauver la liste des parametres calcules ?'' ,  ''Message'', ''Oui'', ''Non'', ''Non'');', ...
                      'if strcmp(button, ''Oui''),', ...
                        'sauv_ajo,', ...
                      'end;', ...
                 'end;', ...
                    'clear all,close']);




% Titre de l'interface
% ---------------------

uicontrol('Parent',f, ...
	'Units','normalized', ...
	'BackgroundColor',[0.8 0.8 0.8], ...
	'FontSize',16, ...
	'Position',[0.15 0.50 0.45 0.2], ...
	'String','AJOUT  DE  PARAMETRES', ...
	'Style','text');
uicontrol('Parent',f, ...
	'Units','normalized', ...
	'BackgroundColor',[0.8 0.8 0.8], ...
	'FontSize',16, ...
	'Position',[0.15 0.20 0.50 0.2], ...
	'String','DANS  LES  FICHIERS  CALCULES', ...
	'Style','text');




% Zone du logo
% ------------
	
axes('position',[0.75 0.1 0.2 0.8]);

% Logo
% ----

[x map]=imread('lpo.jpg');
image(x);
colormap(map);
axis off;




clear current;

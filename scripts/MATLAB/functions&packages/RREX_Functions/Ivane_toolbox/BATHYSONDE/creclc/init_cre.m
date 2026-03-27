
function init_cre ()

% passage des paramètres pour les fonctions appelées 
% dans 'bathysonde'

globalRepDef;

% initialisations
% ===============

% répertoire de lecture
% ----------------------

if   isempty(REPLECT)
        REPLECT = [pwd '/'];
end



% répertoire d'écriture
% ---------------------

 if    isempty(REPECR)
        REPECR  = [pwd '/'];
 end
 


% repertoire de service
% ---------------------

DIRSERV = [REPLECT 'service/'];
if ~exist(DIRSERV,'dir'),
   mkdir(REPLECT,'service');
end;

% repertoire 'resu' (pour les fichiers resultat'
% ----------------------------------------------

DIRRESU = [REPECR 'resu/'];
if  ~exist(DIRRESU,'dir'),
   mkdir(REPECR,'resu');
end

% fichier des codes
% -----------------

COD.NOMFIC = 'ficodf_modele';


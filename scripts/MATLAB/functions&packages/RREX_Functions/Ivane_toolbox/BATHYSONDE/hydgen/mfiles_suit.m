function mfiles_suit()

%
%--------------------------------------------------
% Creation du nom d'un fichier a partir
%   - du repertoire de lecture    : REPLECT
%   - du code de la campagne      : IDENTCAMP  
%   - du code montee ou descente  : DIRECTION 
%   - du numero de station        : STAT1 a STATN
%   - du suffixe du fichier.
%
% C.Lagadec : Nov. 97- Creation
%             Janv.12 - MAJ refonte Hydro
%
%-------------------------------------------------


% suf : suffixe des fichiers a traiter :
%    _cli.nc, _clc.nc

% Variables globales modifiees
globalVarEtiquni;

% Initialisation
NOM_FILES='';
NBFILES = 0;
if isempty(DIRECTION)
    DIRECTION = 'd';
end

% Calcul du nombre de fichiers a  traiter 

NBFILES = STATN - STAT1 + 1;

% Creation des noms des fichiers 

for j=1:NBFILES
        cstat = sprintf('%03d',(STAT1 + j - 1));
	    NOM_FILES(j,:)=[IDENTCAMP DIRECTION cstat suf];
end;


NOM_FILES=char(NOM_FILES);

clear current;

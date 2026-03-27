function load_cat()
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Lecture du fichier  Catalogue
%
% C.Lagadec : Nov 97- Création
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


globalVarEtiquni;

% Ouverture du fichier
fid=fopen(NOMFIC_CAT,'r');

% Lecture de la ligne 1: nombres de fichiers
% ------------------------------------------
 
NBFILES=fscanf(fid,'%3d\n' ,[1 1]);

% Lecture des lignes suivantes: noms des fichiers
% -----------------------------------------------

NOM_FILES = '';

for index=1:NBFILES
        fic_cli_clc = fscanf(fid,'%s',[1 1]);
 	    NOM_FILES = strvcat(NOM_FILES, deblank(fic_cli_clc));
end;


% Fermeture du fichier
fclose(fid);


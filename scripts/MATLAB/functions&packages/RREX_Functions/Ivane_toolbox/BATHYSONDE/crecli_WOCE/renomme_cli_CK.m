%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Script permettant de renommer un ensemble de fichier CLI afin
% que le nom de fichier fasse apparaitre le numéro de position géographique
% (=numéro de station) et le numéro de profil.
% 
% Nomenclature avant renommage :
%       IDENTCAMP{d/a}XXX_cli.nc avec :
%               d   : pour descente ou a : pour montée
%               XXX : numéro séquentiel de fichier sur 3 caractères.
% Nomenclature après renommage :
%       IDENTCAMP{d/a}XXXX_YYY_cli.nc avec :
%               d   : pour descente ou a : pour montée
%               XXXX : numéro de station/position geographique sur 4 caractères.
%               YYY : numéro de profil sur 3 caractères.
%
% La correspondance des numéros de fichiers avec les numéros de positions
% géographiques et profils est fournie dans un fichier ASCII comprenant 3
% colonnes :
%           Numero_de_fichier   Numero_de_position  Numero_de_profil
%
%
% Ce script a été développé suite à la campagne GEOVIDE pour laquelle
% plusieurs profils CTD ont été acquis à une même position géographique.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Creation :    C. Kermabon     13/01/2015
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all;
close all;
% Selection par l'utilisateur  : des fichiers à renommer,
[liste_cli,path_cli] = uigetfile('*_cli.nc','Fichiers CLI à renommer','MultiSelect','on');
% du fichier de correspondance (numero de fichier) <--> (numero station/numero profil)
[fic_correspondance,path_correspondance] = uigetfile('*','Fichier correspondance Numero de fichier <--> Station/Cast');
if fic_correspondance ~=0
 info_numero = load(fullfile(path_correspondance,fic_correspondance));
end
% du repertoire de travail.
path_final = uigetdir(pwd,'Repertoire resultat');
for i_cli = 1:length(liste_cli)
    fic_cli_en_cours = liste_cli{i_cli};
    ind_cli = strfind(fic_cli_en_cours,'_cli.nc');
    numsta = str2num(fic_cli_en_cours(ind_cli-3:ind_cli-1));
    identcamp = fic_cli_en_cours(1:ind_cli-4); % identcamp + {d/a}
    if exist('info_numero','var')
        isok = find(info_numero(:,1)==numsta);
        station = info_numero(isok,2);
        cast = info_numero(isok,3);
    else
        station = numsta;
        cast = 1;
    end
    fic_sortie = fullfile(path_final,[identcamp num2str(station,'%4.4d') '_' num2str(cast,'%3.3d') '_cli.nc']);
    copyfile(fullfile(path_cli,fic_cli_en_cours),fic_sortie);
    ncwriteatt(fic_sortie,'/','STATION_NUMBER',station);
    ncwriteatt(fic_sortie,'/','CAST',cast);
    ncwriteatt(fic_sortie,'/','DATE_CREATION',datestr(now,'yyyymmddHHMMSS'));

end
    

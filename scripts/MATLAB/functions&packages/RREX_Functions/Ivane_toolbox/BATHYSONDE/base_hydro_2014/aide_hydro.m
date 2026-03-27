
function aide_hydro(i);

%-----------------------------------------------------------------------------------
%  Projet ARCHIVAGE HYDRO
%  ----------------------
%  Version: 1.0
%  ------------
%  Creation : Fevrier 2003
%                                            
%------------------------------------------------------------------------
%  BASE DE DONNEES ARCHIVAGE HYDROLOGIE : AIDE MEMENTO pour l'utilisateur
%------------------------------------------------------------------------


mess_hydro{1} = str2mat('Le logiciel base_hydro permet de travailler separement sur les donnees de la base HYDROCEAN (base d''archivage du LPO par campagnes) ou sur les donnees des bases annuelles, de 1980 à 2004 : Hydrobase2_V2 (avec ou sans Oxygene) de Woods Hole et Hydrocean annuels.', ...
                        'Cette base de donnees Hydrologie contient des fichiers Multistation au format Netcdf derive du format ARGO (voir le format dans le document Descriptif ...) repartis par campagne. Le parametre de reference est l''immersion (en positif, parametre DEPH), les donnees sont sur une grille reguliere par pas de 1 metre. Les fichiers contiennent les parametres mesures calibres (pression, temperature, salinite, oxygene) et de nombreux parametres calcules. La base de donnees contient a ce jour toutes les campagnes du LPO, les campagnes historiques Atlantique Nord et Atlantique Sud, au total 189 campagnes representant 13 502 stations au 1er octobre 2008.', ...
                       'L''extraction se fait sur les fichiers Multistation Netcdf classes dans des repertoires, campagne par campagne. Il est possible de creer un fichier Multistation issu de campagnes differentes, a partir de nombreux criteres d''interrogation : date, position, campagnes ... et de selectionner ou non les parametres ainsi que les niveaux.', ...
                       'Il est possible de visualiser le contenu de la base avant de faire une extraction.', ...
                       'Toutes les donnees retenues selon les criteres de l''utilisateur (date, position) sont rassemblees sous la forme d''un seul fichier Netcdf ''nomprojet.nc''.', ...
                       'Le paramètre DEPH est systematiquement selectionne pour la creation du fichier Netcdf Resultat, ainsi que pour le trace de parametres. Tous les parametres n''existent pas obligatoirement dans tous les fichiers. Dans le fichier Netcdf Resultat, les valeurs seront remplacees par la valeur donnee dans le Fill Value du parametre (en general -9999).', ...                        
                        'Il est possible de travailler sur les donnees de couches superficielles (inferieures à 100 dbar) ou sur les donnees profondes. Les fichiers Multistation Netcdf n''etant pas sur le meme pas de grille, vous devez choisir l''un ou l''autre de ces repertoires.', ...
                        'Les bases de donnees annuelles sont constituées des fichiers Hydrologie annuels (periode 1980-2003) de la base Hydrobase2 (H2V2) de Woods Hole et des fichiers de la base Hydrocean du LPO repartis par année (de 1980 à 2004). Chaque fichier Multistation annuel est au format Netcdf derive du format ARGO (voir le format dans le document Descriptif ...). Les données H2V2 sont découpées en couches superficielles (inferieures à 100 dbar) et en donnees profondes avec ou sans oxygène. Le parametre de reference est l''immersion(en positif, parametre DEPH), les donnees sont sur une grille reguliere par pas de 10 metres, sauf pour les couches superficielles (par pas de 1 metre). Les fichiers contiennent les parametres mesures calibres (pression, temperature, salinite, oxygene) et 7 parametres calcules.');

messaffich = mess_hydro{1};
helpdlg(messaffich(i,:),'Guide');
%uiwait;


function aide(i)

% i = numero du message
% =====================



% 1 = message de presentation du logiciel

% messages 2 a 7 + 13 : explications sur les parametres de lissage
% ----------------------------------------------------------------


% 2 = largeur              (lissage Lanczos)
% 3 = frequence de coupure (lissage lanczos)

% 4 = largeur              (lissage creneau)

% 5 = largeur              (lissage Gauss)
% 6 = ecart-type           (lissage Gauss)

% 7 = periode de coupure   (lissage Butterworth)
% 13 = ordre du filtre     (lissage Butterworth)

% messages 8 a 12 : explications provenant de la creation des fichiers Echange
% ---------------------------------------------------------------------------

% 8 = Choix des parametres

% 9 = Modification de pmin, pmax et du pas 

% 10

% 11 = Echantillonnage

% 12 = Modification de format

messaide {1} = str2mat('Ce logiciel permet d''effectuer le traitement standard (a terre) des donnees d''hydrologie et de geochimie. Il est possible de creer des fichiers calcules (clc), d''y ajouter des parametres, de faire des traces standard, de creer des fichiers Multistation (plusieurs formats possibles) et de faire des traces de section. Il est recommande de toujours quitter un sous-menu  avant d''en ouvrir un autre (ex : ne pas lancer ''Ajout param'' avant de fermer ''Creation clc'').', ...
                       'Demi-largeur du filtre exprimee en nombre de points dans la grille intermediaire', ...
                       'Frequence de coupure du filtre definie comme l''inverse d''un nombre de points. Valeur comprise entre 1/2 et 1/nombre total de points dans le profil.', ...
                       'Demi-largeur du filtre exprimee en nombre de points dans la grille intermediaire', ...
                       'Demi-largeur du filtre exprimee en nombre de points dans la grille intermediaire', ...
                       'Ecart-Type', ...
                       'Periode de coupure exprimee en nombre de points dans la grille intermediaire', ...
                       ' Ce menu vous permet de choisir les parametres physiques et chimiques que vous desirez voir apparaitre dans vos fichiers d''echange. Pour selectionner un parametre, il suffit de cliquer sur son code dans la zone ''Disponibles'', pour le deselectionner, de cliquer dans la zone ''Choisis''.', ...
                       ' Ce menu vous permet de transformer a volonte les formats des donnees que vous desirez lister dans vos fichiers d''echange.', ...
                       '  Ce menu vous permet de ne mettre dans vos fichiers d''echange que les donnees recuperees dans une tranche de pression.', ...
                       ' Ce menu vous permet d''etablir un pas d''echantillonnage dans vos fichiers d''echange. Ainsi un pas de 10 recuperera une donnee sur 10 dans le fichier origine. Le pas par defaut est de 1. Vous pouvez egalement choisir de n''etudier qu''une partie des donnees des stations, vous modifierez alors les pressions minimum et maximum.', ...
                       ' Ce menu vous permet de modifier les formats de donnees des parametres que vous avez choisis. Cliquez sur le code du parametre dont vous desirez modifier le format, et modifiez-le dans la zone de texte situee a droite de l''ecran en le validant par une simple pression du bouton Modifier.', ...
                       'Ordre du filtre (voir explications Matlab pour les fonctions butter et filtfilt)');

messaffich = messaide{1};


helpdlg(messaffich(i,:),'Guide'); 

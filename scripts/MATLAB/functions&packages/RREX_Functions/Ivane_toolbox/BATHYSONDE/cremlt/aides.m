function aides(i)

%---------------------------------------------------------------------									
% fonction qui permet, a l'aide de messages demandes par l'utilisateur, 
% de renseigner ce dernier sur le fonctionnement de certaines parties   
% du programme								
% --------------------------------------------------------------------									

% i = numero du message
% ---------------------

% 1 = message d'explication sur le parametre de reference par defaut

% 2 = message d'explication sur les choix des parametres physiques
% et chimiques

% 3 = message d'explication sur le changement de parametre de reference

messaides {1} = str2mat('Ce menu vous permet de constater les caracteristiques du parametre de reference par defaut, de changer eventuellement ces caracteristiques en modifiant les zones valeur min, valeur max et pas d''echantillonnage de la partie MLT. Si vous desirez changer de parametre de reference, il suffit de cliquer sur le bouton correspondant.', ...
		       'Ce menu vous permet de choisir les parametres physiques que vous desirez voir apparaitre dans vos fichiers multistation. Pour selectionner un parametre, il suffit de cliquer sur son code dans la zone ''Disponibles'', pour le deselectionner, de cliquer dans la zone ''Choisis''', ...
			'Pour choisir un nouveau parametre de reference, il faut cliquer sur un element de la liste. Le code de ce parametre s''affiche en dessous de la liste ainsi que sa valeur min, sa valeur max et son pas d''echantillonnage. Il vous est possible de modifier ces trois dernieres valeurs en cliquant sur la zone edit correspondante.') ;

messaffichage = messaides {1} ;

helpdlg(messaffichage(i,:),'Guide') ;


 

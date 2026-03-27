%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% global_cgTraces
%
% variables globales -<-> tableaux de choix 
% pour caracteristiques graph de traces
%
% CF (Atlantide)
% 
% le 26/02/98
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% couleurs proposees ->	COULEURS
% styles de traces ->	STYLES
% types de traits ->	TRAITS
% types de marqueurs ->	SYMBS


global COULEURS STYLES TRAITS SYMBS;

% couleurs
COULEURS{1} = str2mat('rouge fonce', 'rouge moyen', 'rouge orange', 'vert fonce', 'vert moyen', 'vert clair', 'bleu fonce', 'bleu moyen', 'bleu clair', 'mauve', 'magenta', 'noir');

COULEURS{2} = [0.67 0 0; 1 0 0; 1 0.4 0; 0 0.27 0; 0 1 0; 0.2 1 0; 0 0 1; 0.2 0.4 0.6; 0 1 1; 0.6 0 1; 1 0 1; 0 0 0];


% styles
STYLES{1} = str2mat('courbe', 'points');

STYLES{2} = str2mat('c', 'p');


% traits
TRAITS{1} = str2mat('trait plein', 'pointille', 'tiret/pointille', 'tiret', 'aucun');
TRAITS{2} = str2mat('-', ':', '-.', '--', 'n');


% symboles
SYMBS{1} = str2mat('plus', 'cercle', 'asterisque', 'point', 'croix', 'carre', 'carreau', 'triangle haut', 'triangle bas', 'triangle droit', 'triangle gauche', 'etoile 5', 'etoile 6', 'aucun');

SYMBS{2} = str2mat('+', 'o', '*', '.', 'x', 's', 'd', '^', 'v', '>', '<', 'p', 'h', 'n');


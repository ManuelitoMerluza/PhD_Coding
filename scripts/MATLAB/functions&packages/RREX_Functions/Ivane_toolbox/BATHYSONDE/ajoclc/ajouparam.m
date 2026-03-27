
function ajouparam(param)

% -------------------------------------------------------
%
% fonction ajouparam - C.Lagadec - Nov 98
%
% fonction appelee par choix_param_calc
%
% - controle d'existence de parametres
%    obligatoires pour le calcul       => controle_param
% - calcul du parametre                => calc_param
% - mise a jour des tableaux si le 
%   calcul s'est bien passe            => misajour_codes
% - choix parametre suivant            => choix_param_calc
%
% --------------------------------------------------------

globalVarEtiquni;

globalajo;


[iretcont] = controle_param(param);

if  isempty(iretcont)

% si pas de probleme dans le controle, calcul du parametre 
  
      iretcalc = calc_param(param);

      if  isempty(iretcalc)

% si le calcul s'est bien passe, mise a jour du
% tableau des codes presents dans tous les fichiers

         misajour_codes(param);

      end;

end;

choix_param_calc;

clear iretcont iretcalc;


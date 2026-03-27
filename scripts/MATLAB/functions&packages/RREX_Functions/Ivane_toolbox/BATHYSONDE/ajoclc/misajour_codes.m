function  misajour_codes(param)

% ----------------------------------------------------------------------------
%
% mise a jour de la table des codes pour les parametres
% existant dans tous les fichiers.
%
% - si le param. existait deja dans le fichier :
%   on initialise le code presence a blanc (PRESENCP_TOT)
% - sinon :
%   mise a jour de tous les tableaux (codes, labels, presence, nb param total)
%
% ----------------------------------------------------------------------------


globalajo;

    icalc = strfind(reshape(CODPARP_TOT',1,NPARP_TOT*4),param);

    if  isempty(icalc)
         CODPARP_TOT  = [CODPARP_TOT; param];
         PRESENCP_TOT = [PRESENCP_TOT;' '];
         NPARP_TOT = NPARP_TOT + 1;

         icalc = strfind(reshape(CODES_CALC',1,NBPARCALC*4),param);
         icalc = ceil(icalc/4);

         LABPARP_TOT = char(LABPARP_TOT,LABELS_CALC(icalc,:));
         
    else
         
         icalc = ceil(icalc/4);
         PRESENCP_TOT(icalc) = ' ';

     end;

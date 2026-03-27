
 function rech_param_calc(AJO);

% ---------------------------------------------------
% ajout des parametres lus dans le fichier AJO.nomfic
%  (suffixe .ajo dans le repertoire service)
% ---------------------------------------------------

 globalVarEtiquni;

 globalajo;

 for i = 1:AJO.nbpar     
    param = AJO.param(i,:);
    TYP_LISS = ' ';
    
    switch AJO.typliss(i,:)

       case 'B'
        TYP_LISS = 'Butterworth';
       case 'L';
        TYP_LISS = 'Lanczos    ';
       case 'C';
        TYP_LISS = 'Créneau    ';
    end;

    P1_LISS = AJO.p1liss(i);
    P2_LISS = AJO.p2liss(i);

    [iretcont] = controle_param(param);

    if  isempty(iretcont)

% si pas de probleme dans le  controle, calcul du parametre 
 
        iretcalc = calc_param(param);

        if  isempty(iretcalc)

% si le calcul s'est bien passe, mise a jour du
% tableau des codes presents dans tous les fichiers

              misajour_codes(param);
        end;
     end;
 
   end;
 
   msgbox('Tous les parametres ont ete ajoutes !','Traitement termine');


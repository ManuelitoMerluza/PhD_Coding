
function [iretour] = controle_param(param)

% -------------------------------------------------------
%
% fonction controle_param - C.Lagadec - mars 99
%
% fonction appelee par ajouparam   (ajout a partir de la liste par defaut)
%                   et prepar_calc (ajout a partir d'une liste dans un fichier)
%
% - controle d'existence de parametres
%    obligatoires pour le calcul     
%      . pour DYNH: il faut SIGI
%      . pour ZCOO : il faut SIGI
%      . pour VORP : il faut BRV2
%
%  - iretour est mis a 1 si pb dans le controle
% --------------------------------------------------------

  globalVarEtiquni;

  globalajo;

  global  hsuivi_err ;
  global  messerr_suivi; 

  messcalcul = 'Calcul du parametre impossible !'; 
  messexist  = ' n''existe pas dans TOUS les fichiers'; 

  iretour     = '';
  
%  DYNH ou ZCOO : il faut que SIGI existe dans TOUS les fichiers
%  ------------------------------------------------------------

  if  strcmp(param, 'DYNH') || strcmp(param, 'ZCOO')
           ip1 = strfind(reshape(CODPARP_TOT',1,NPARP_TOT*4),'SIGI');
           ip2 = ceil(ip1/4);

           if  isempty(ip1) || PRESENCP_TOT(ip2) == '*'
                messerr_suivi = char(messerr_suivi,[param,messcalcul],[' SIGI ',messexist], ' ');
                set(hsuivi_err,'String',messerr_suivi);
                iretour = 1; 
                h = warndlg([param,messcalcul,' SIGI ',messexist],' Erreur'); 
                waitfor(h);
             else
                if  strcmp(param , 'DYNH')
                    if isempty(AJO.decaldynh)
                       AJO.decaldynh  = hdy_nivref;
                    end
                end;

           end;

%  VORP : il faut que BRV2 existe dans TOUS les fichiers
%  ---------------------------------------------------


       elseif    strcmp(param, 'VORP')
           ip1 = strfind(reshape(CODPARP_TOT',1,NPARP_TOT*4),'BRV2');
           ip2 = ceil(ip1/4);

           if  isempty(ip1)  ||  PRESENCP_TOT(ip2) == '*'
                iretour = 1;
                messerr_suivi = char(messerr_suivi,[param,messcalcul],[' BRV2 ',messexist],' ');
                set(hsuivi_err,'String',messerr_suivi); 
                h = warndlg([messcalcul,' BRV2'],'Erreur');
                waitfor(h);

           end;
  end

% BRV2 ou FBVR : demande du decalage en nombre de niveaux
% -------------------------------------------------------

  if   strcmp(param ,'BRV2') && isempty(AJO.decalbrv2)
               AJO.decalbrv2  = bv2_decal;
  end

  if   strcmp(param, 'FBRV') && isempty(AJO.decalfbrv)
             AJO.decalfbrv  = bv2_decal;  
  end;

 clear ip1 ip2 cc lcc a;

          


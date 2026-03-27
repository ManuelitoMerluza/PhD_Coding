function [messerr] = lect_ajo(ficajo);


% ------------------------------------
%
%  fonction lect_ajo : C.Lagadec  Fev.99
%
%    Lecture d'un fichier .ajo contenant 
%   la liste des parametres a calculer
%   ainsi que le type de lissage
% 
% -------------------------------------

globalajo;

fid_ajo = fopen(ficajo,'r');
messerr='';

if (fid_ajo == -1)
	messerr = [ 'Erreur d''ouverture du fichier param. pour ajoclc ', ficajo];
    h=warndlg(messerr,'Attention');
    waitfor(h);
   
   else,

       AJO.nbpar = 0;
       while (~feof(fid_ajo))
             AJO.nbpar = AJO.nbpar  + 1;
             a= fgetl(fid_ajo);
             la = length(a);
             AJO.param(AJO.nbpar,:) = a(1:4);
             AJO.typliss(AJO.nbpar,:) = ' ';
             AJO.p1liss(AJO.nbpar)     = 0;
             AJO.p2liss(AJO.nbpar)     = 0;

             if  AJO.param(AJO.nbpar,:) == 'BRV2'
                 AJO.decalbrv2 = str2num(a(6:8));
             elseif  AJO.param(AJO.nbpar,:) == 'FBRV' 
                 AJO.decalfbrv = str2num(a(6:8));
             elseif  AJO.param(AJO.nbpar,:) == 'DYNH'
                 AJO.decaldynh = str2num(a(6:8));
             end;

             if  la > 8
                 AJO.typliss(AJO.nbpar,:) = a(10:10);
                 AJO.p1liss(AJO.nbpar)   = str2num(a(12:13));
                 AJO.p2liss(AJO.nbpar)   = str2num(a(15:18));
             end
       end
       
end
 

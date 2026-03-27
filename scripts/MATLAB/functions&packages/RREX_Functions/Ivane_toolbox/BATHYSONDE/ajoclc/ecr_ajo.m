function [messerr] = ecr_ajo(ficajo_ecr);


% ------------------------------------
%
%  fonction ecr_ajo : C.Lagadec  Fev.99
%
%    Ecriture d'un fichier .ajo contenant 
%   la liste des paramètres calculés :
%   - si DYNH         : la pression de reference
%   - si FBVR ou BRV2 : le decalage en nombre de niveaux
%   - le type de lissage et les parametres associes (s'il y a eu lissage)
% 
% -------------------------------------

globalajo;

fid_ajo_ecr = fopen(ficajo_ecr,'w');

for i = 1:ECR.nbpar,

    d=sprintf('%4d',ECR.decal(i));

    if  ECR.param(i,:) ~= 'BRV2' | ECR.param(i,:) ~= 'FBVR' | ECR.param(i,:) ~= 'DYNH'

%        d=strrep(d,' 0','  ')';
    end;

    p1 = sprintf('%2d',ECR.p1liss(i));
    p1 = strrep(p1,' 0','  ');


    p2 = sprintf('%4.2f',ECR.p2liss(i));
    p2 = strrep(p2,'0.00','    ');

     if   ECR.typliss(i) == ' '
        if  strcmp(ECR.param(i,:),'BRV2') | strcmp(ECR.param(i,:),'FBVR') | strcmp(ECR.param(i,:),'DYNH')
               fprintf(fid_ajo_ecr,'%s%s\n',ECR.param(i,:),d);
            else
               fprintf(fid_ajo_ecr,'%s\n',ECR.param(i,1:4));
        end;
     else
          fprintf(fid_ajo_ecr,'%s%s %s %s %s\n',ECR.param(i,:),d,ECR.typliss(i),p1,p2);
     end;

end

clear d p1 p2;
  

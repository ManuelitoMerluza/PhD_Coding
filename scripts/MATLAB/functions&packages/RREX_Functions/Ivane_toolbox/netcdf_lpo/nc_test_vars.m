function res_var = f_test_vars(filenc,varname_encours)
% ==================================================
%
% Fonction permettant de verifier l'existance
% d'une variable dans un fichier Netcdf.
% En entree : le nom du fichier NetCDF et le nom de la variable a rechercher.
% En sortie : Un indicateur valant 1 si la variable existe dans le fichier, rendant 0 sinon.
%
% Avril 2009 : P. Le Bot.
%
% ================================================= 

nc=netcdf.open(filenc,'NOWRITE');
[~, nvars]=netcdf.inq(nc); % Recuperation du nombre de variables du fichier
i_var = 1;
trouve = 0;
while (i_var<=nvars && trouve==0) % Boucle sur toutes les variables
       [varname, ~, ~] = netcdf.inqVar(nc,i_var-1);
         if strcmp(varname,varname_encours)==1 % Comparaison entre la variable en cours et celle recherchee.
                 trouve = 1;
         else
                i_var = i_var + 1;
         end
end
netcdf.close(nc);

if (trouve==0)
           res_var=0;
else
           res_var=1;
end 

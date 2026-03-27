

function val = f_autonan(filenc, var)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%      Fonction similaire a autonan
%     remplace les Fillvalues par NaN
%
% En entree : nom du fichier � lire
%             variable � lire
% En sortie : valeur de la variable avec les FillValue remplacees par des Nan.
%
% Avril 2009 : P. Le Bot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
nc=netcdf.open(filenc,'NC_NOWRITE');
varid=netcdf.inqVarID(nc,var);
val=netcdf.getVar(nc,varid);
isbad=find(val==netcdf.getAtt(nc,varid,'_FillValue'));
val(isbad)=NaN;
netcdf.close(nc);
    
    
    

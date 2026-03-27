%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Script matlab permettant de concatener des fichiers ADCP.
% On ne concatene que les variables dependantes du temps.
%
% 7/12/2010 : C. Kermabon
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all;
close all;
% Liste des fichiers à concatener.
rep_fic = '/home1/kereon/OVIDE2008/vmadcp/NB75/ncc/';
liste_fic = strvcat('ovide08_nb75_d022_a0985.nc','ovide08_nb75_retour_d022_a0985.nc');
nb_fic = size(liste_fic,1);
newfile = [rep_fic 'newfile.nc'];
%
% Creation fichier resultat avec N_DATE_TIME en unlimited
% a partir du premier fichier.
% Si N_DATE_TIME non en unlimited, on ne peut rien rajouter dans le
% fichier.
%
nc = netcdf.open([rep_fic deblank(liste_fic(1,:))],'NC_NOWRITE');
nc_new = netcdf.create(newfile,'NC_NOCLOBBER');
[ndims nvars natts dimm] = netcdf.inq(nc);
for i_dim=0:ndims-1
% Création de toutes les dimensions.
  [dimname, dimlen] = netcdf.inqDim(nc,i_dim);
  if strcmp(dimname,'N_DATE_TIME')==1
   id_dim_date = i_dim;
   netcdf.defDim(nc_new,dimname,netcdf.getConstant('NC_UNLIMITED')); % On definit N_DATE_TIME en unlimited
  else
   netcdf.defDim(nc_new,dimname,dimlen);
  end
 end
 for i_var=0:nvars-1
% Creation de toutes les variables.
  [varname, xtype, varDimIDs, varAtts] = netcdf.inqVar(nc,i_var);
  varid = netcdf.defVar(nc_new,varname,xtype,varDimIDs);
  for i_att=0:varAtts-1
   netcdf.copyAtt(nc,varid,netcdf.inqAttName(nc,varid,i_att),nc_new,varid);
  end
 end
 for i_att=0:natts-1
%Creation de tous les attributs globaux.
  attname = netcdf.inqAttName(nc,netcdf.getConstant('NC_GLOBAL'),i_att);
  value = netcdf.getAtt(nc,netcdf.getConstant('NC_GLOBAL'),attname);
  netcdf.putAtt(nc_new,netcdf.getConstant('NC_GLOBAL'),attname,value);
 end
 netcdf.endDef(nc_new);
 %
 % Remplissage des variables.
 for i_var=0:nvars-1
   [varname, xtype, varDimIDs, varAtts] = netcdf.inqVar(nc,i_var);
   valeur = netcdf.getVar(nc,i_var);
   isok = find(varDimIDs==id_dim_date);
   if isempty(isok)
       netcdf.putVar(nc_new,i_var,valeur);
   else 
    % La variable comprend la dimension N_DATE_TIME.
    % Comme c'est une dimension unlimited, il faut donner le start et count
    % dans le putVar.
    %
       if (length(varDimIDs)==1)
        netcdf.putVar(nc_new,i_var,0,length(valeur),valeur);
       else
         netcdf.putVar(nc_new,i_var,[0 0],size(valeur),valeur);
       end
   end
 end
 netcdf.close(nc_new);
 netcdf.close(nc);
%
% Concatenation du fichier ainsi cree avec les autres fichiers.
%
for i_fic=2:nb_fic
    nc_new = netcdf.open(newfile,'NC_WRITE');
    dimid_date = netcdf.inqDimID(nc_new,'N_DATE_TIME'); % On recupere dimension N_DATE_TIME en cours.
    [dimname, dimlen_date] = netcdf.inqDim(nc_new,dimid_date);
    nc_lire = netcdf.open([rep_fic deblank(liste_fic(i_fic,:))],'NC_NOWRITE');
    [ndims nvars natts dimm] = netcdf.inq(nc_lire);
    for i_var=0:nvars-1
     [varname, xtype, dimids, numatts] = netcdf.inqVar(nc_lire,i_var);
     isok = find(dimids==dimid_date);
     if ~isempty(isok) % La variable contient la dimension N_DATE_TIME, on concatene
         val = netcdf.getVar(nc_lire,i_var); 
         if (length(dimids)==1) % variable 1D 
          netcdf.putVar(nc_new,i_var,dimlen_date,length(val),val);
         else % variable 2D
           netcdf.putVar(nc_new,i_var,[0 dimlen_date],size(val),val);
         end
     end
    end
    netcdf.close(nc_lire);
    netcdf.close(nc_new);
end
    




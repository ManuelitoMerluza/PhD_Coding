function ecetis(cli,clc,attribut_liss,datamode_clc)

globalVarEtiquni;

attr_conv =  '1: good, 2: probably good; 8: interpolated, 9: No data';

% Recup nbre de dimensions, nbre de variables, nbre d'attributs et dimension
% du fichier cli
                        
 [ndims, nvars, natts, dimm] = netcdf.inq(cli);

 for i_dim=1:ndims
     
% Creation des dimensions du fichier clc
% le nombre de niveaux a change (N_LEVELS)
  [dimname, dimlen] = netcdf.inqDim(cli,i_dim-1);

      if strcmp(dimname,'N_LEVELS')
        netcdf.defDim(clc,'N_LEVELS',ETIQ.nvalclc)
      elseif strcmp(dimname,'N_PARAM')
              netcdf.defDim(clc,'N_PARAM',netcdf.getConstant('NC_UNLIMITED'));
      else
              netcdf.defDim(clc,dimname,dimlen);
      end
 end
 
% Creation des variables du fichier clc
% -------------------------------------

for i_var=1:nvars
  [varname, xtype, varDimIDs, varAtts] = netcdf.inqVar(cli,i_var-1);
  varid = netcdf.defVar(clc,varname,xtype,varDimIDs);
  
% ecriture des attributs de chaque variable
% ajout de l'attribut 'Smoothing' pour tous les paramètres calculés (sauf PRES)
% modification de l'attribut 'convention' pour les flags de qualité

     for i_att=1:varAtts  
       netcdf.copyAtt(cli,varid,netcdf.inqAttName(cli,varid,i_att-1),clc,varid);
       if ETIQ.nparp ==4
            ivar=strcmp(varname,{'TEMP','PSAL','OXYK'});
       elseif ETIQ.nparp == 6
            ivar=strcmp(varname,{'TEMP','PSAL','COND','OXYL','OXYK'});
       else
            ivar=strcmp(varname,{'TEMP','PSAL','OXYL','OXYK'});
       end
       
       ivarbon=find(ivar==1);
       if ~isempty(ivarbon)
          netcdf.putAtt(clc,varid,'Smoothing',attribut_liss(ivarbon+1,:));
       end
       
       if ETIQ.nparp > 5
           ivar_qc=strcmp(varname,{'PRES_QC','TEMP_QC','PSAL_QC', 'COND_QC','OXYL_QC','OXYK_QC'});
       else
           ivar_qc=strcmp(varname,{'PRES_QC','TEMP_QC','PSAL_QC', 'OXYL_QC','OXYK_QC'});
       end
       ivar_qcbon=find(ivar_qc==1);
       if ~isempty(ivar_qcbon)
           netcdf.putAtt(clc,varid,'convention',attr_conv);
       end
     end
end
 

% Creation des attributs globaux
% -----------------------------
 for i_att=1:natts

  attname = netcdf.inqAttName(cli,netcdf.getConstant('NC_GLOBAL'),i_att-1);
  value = netcdf.getAtt(cli,netcdf.getConstant('NC_GLOBAL'),attname);
  netcdf.putAtt(clc,netcdf.getConstant('NC_GLOBAL'),attname,value);
  
 end
 
% Modification de certains attributs globaux
% ------------------------------------------

   date_creation = datestr(now, 'yyyymmddHHMMSS');
   netcdf.putAtt(clc,netcdf.getConstant('NC_GLOBAL'),'DATA_MODE',datamode_clc);
   netcdf.putAtt(clc,netcdf.getConstant('NC_GLOBAL'),'DATE_CREATION',date_creation);
   netcdf.putAtt(clc,netcdf.getConstant('NC_GLOBAL'),'LAST_UPDATE',date_creation);
   netcdf.putAtt(clc,netcdf.getConstant('NC_GLOBAL'),'SAMPLING_MODE','R');

   if ETIQ.nparc > 0
       netcdf.putAtt(clc,netcdf.getConstant('NC_GLOBAL'),'CHEMISTRY_PARAMETERS','Y');
     else
       netcdf.putAtt(clc,netcdf.getConstant('NC_GLOBAL'),'CHEMISTRY_PARAMETERS','N');
   end

% fin definition attributs, dimensions, variables fichier sortie
 netcdf.endDef(clc);



function ajomlt_chim

globalVarEtiquni;
globalRepDef;

globalVMLT;

fillval = -9999;

mltnc = netcdf.open(MLT.nomfic,'NC_WRITE');
netcdf.reDef(mltnc);

max_nbottles=max(MLT.nbottles);

ficuni1 = deblank([REPLECT NOM_FILES(1,:)]);
a=ncinfo(ficuni1);
dimlength = {a.Dimensions.Length};

%test si chimie sur 1er fichier  ... revoir ?
ichim = ncreadatt(ficuni1,'/','CHEMISTRY_PARAMETERS');
if strcmp(ichim,'N')  
   warndlg('Il n''y a pas de chimie dans le 1er fichier ' ,'Arret du traitement');
   return
else
   ETIQ.nparc = dimlength{9};
   ETIQ.codes_paramc  = ncread(ficuni1,'STATION_PARAMETER_CHIM')';

% recuperation des attributs de chaque param chimique dans le 1er fichier clc
for i=1:ETIQ.nparc
    [~,~,~,longname,units,~,~,~,valid_min, valid_max] = lcchms(ETIQ.codes_paramc(i,:), ficuni1);
    if i == 1
        mltlongname            = longname;
        mltunits               = units; 
    else
        mltlongname            = char(mltlongname,longname);
        mltunits               = char(mltunits,units);
    end
    mltvalid_min(i)        = valid_min;
    mltvalid_max(i)        = valid_max;
end


% initialisations

mlttabchim        = NaN*ones(NBFILES,ETIQ.nparc,max_nbottles);
mltflagchim       = NaN*ones(NBFILES,ETIQ.nparc,max_nbottles);
mltresp_param     = char(' '*ones(NBFILES,ETIQ.nparc,30));
mltorg_resp_param = char(' '*ones(NBFILES,ETIQ.nparc,30));
mltrosette        = char(' '*ones(NBFILES,30));
mltbottle_vol     = char(' '*ones(NBFILES,7));
mltprecision      = NaN*ones(NBFILES,ETIQ.nparc);

for ific= 1:NBFILES

   ficuni = deblank([REPLECT NOM_FILES(ific,:)])

   % test si chimie dans chaque fichier
   chemistry = ncreadatt(ficuni,'/','CHEMISTRY_PARAMETERS');
   if strcmp(upper(chemistry),'Y')
         ros=ncreadatt(ficuni,'/','ROSETTE_TYPE');  
         bot=ncreadatt(ficuni,'/','BOTTLE_VOL');

      else
         ros(1:30) = ' ';
         bot(1:7)  = ' ';
   end

   mltrosette(ific,1:length(ros))    = ros;
   mltbottle_vol(ific,1:length(bot)) = bot;

   for i=1:ETIQ.nparc
      if strcmp(upper(chemistry),'Y')
         [tabchim,flagchim,~,~,~,resp_param,org_resp_param,precision,~,~] = lcchms(ETIQ.codes_paramc(i,:), ficuni);
          
        else
         tabchim        = fillval;
         flagchim       = fillval;
         precision      = fillval;
         resp_param     = ' ';
         org_resp_param = ' ';
      end

      mlttabchim(ific,i,1:length(tabchim))    = tabchim;
      mltflagchim(ific,i,1:length(flagchim))  = flagchim; 
      mltprecision(ific,i)                    = precision;
      
      mltresp_param(ific,i,1:length(resp_param))          = resp_param;
      mltorg_resp_param (ific,i,1:length(org_resp_param)) = org_resp_param;
   end
end

% recuperation et initialisation des variables
dimnprof      = netcdf.inqDimID(mltnc,'N_PROF')
dimstr30      = netcdf.inqDimID(mltnc,'STRING30');

dimnbottles   = netcdf.defDim(mltnc,'N_BOTTLES', max_nbottles) ;
dimnparam     = netcdf.defDim(mltnc,'N_PARAM_CHIM', ETIQ.nparc) ;
dimstr7       = netcdf.defDim(mltnc,'STRING7',7);

nc_ARGO_mlt_var(mltnc,'STATION_PARAMETER_CHIM','NC_CHAR',[dimstr7,dimnparam], ...
                'long_name','List of available parameters for the station', ...
                '_FillValue',' ');
            
nc_ARGO_mlt_var(mltnc,'BOTTLE_VOL','NC_CHAR',[dimstr7,dimnprof], ...
                'long_name','Volume of the bottles', ...
                '_FillValue',' ');
            
nc_ARGO_mlt_var(mltnc,'ROSETTE_TYPE','NC_CHAR',[dimstr30,dimnprof], ...
                'long_name','Type of the rosette', ...
                '_FillValue',' ');       
            
for i=1:ETIQ.nparc
    nc_ARGO_mlt_var(mltnc,ETIQ.codes_paramc(i,:),'NC_FLOAT',[dimnbottles,dimnprof], ...
        'long_name',deblank(mltlongname(i,:)),'units',deblank(mltunits(i,:)), ...
        'valid_min',mltvalid_min(i), 'valid_max',mltvalid_max(i), ...
        '_FillValue',single(fillval));
    
    nc_ARGO_mlt_var(mltnc,[ETIQ.codes_paramc(i,:) '_QC'],'NC_FLOAT',[dimnbottles,dimnprof], ...
        'long_name',[deblank(mltlongname(i,:)) ' flag'], ...
        '_FillValue',single(fillval)); 
    
    nc_ARGO_mlt_var(mltnc,[ETIQ.codes_paramc(i,:) '_RESP'],'NC_CHAR',[dimstr30,dimnprof], ...
        'long_name',['Responsable name of ' deblank(mltlongname(i,:))], ...
        '_FillValue',' ');
    
    nc_ARGO_mlt_var(mltnc,[ETIQ.codes_paramc(i,:) '_RESP_ORG'],'NC_CHAR',[ dimstr30,dimnprof], ...
        'long_name',['Organism of the responsable of ' deblank(mltlongname(i,:))], ...
        '_FillValue',' ');
    
    nc_ARGO_mlt_var(mltnc,[ETIQ.codes_paramc(i,:) '_PREC'],'NC_FLOAT',dimnprof, ...
        'long_name',['Precision of ' deblank(mltlongname(i,:))] , ...
        '_FillValue',single(fillval));
end


% CHEMISTRY_PARAMETERS à Y
netcdf.putAtt(mltnc,netcdf.getConstant('NC_GLOBAL'),'CHEMISTRY_PARAMETERS','Y');

netcdf.endDef(mltnc);

for ific=1:NBFILES
    for ipar=1:ETIQ.nparc
        isnok = find(~isfinite(mlttabchim(ific,ipar,:)));
        mlttabchim(ific,ipar,isnok)=fillval;

        isnok = find(~isfinite(mltflagchim(ific,ipar,:)));
        mltflagchim(ific,ipar,isnok)=fillval;
    end
end
% ecriture des variables
for i=1:ETIQ.nparc
 val_param(:,:)  =   mlttabchim(:,i,:);
 flag_param(:,:) =   mltflagchim(:,i,:);

 netcdf.putVar(mltnc,netcdf.inqVarID(mltnc,ETIQ.codes_paramc(i,:)),val_param'); 
 netcdf.putVar(mltnc,netcdf.inqVarID(mltnc,[ETIQ.codes_paramc(i,:) '_QC']),flag_param');
 resp(:,:)=mltresp_param(:,i,:);
 netcdf.putVar(mltnc,netcdf.inqVarID(mltnc,[ETIQ.codes_paramc(i,:) '_RESP']),resp'); 
 
 org(:,:)=mltorg_resp_param(:,i,:);
 netcdf.putVar(mltnc,netcdf.inqVarID(mltnc,[ETIQ.codes_paramc(i,:) '_RESP_ORG']),org');
 
 netcdf.putVar(mltnc,netcdf.inqVarID(mltnc,[ETIQ.codes_paramc(i,:) '_PREC']),mltprecision(:,i));
 
end

netcdf.putVar(mltnc,netcdf.inqVarID(mltnc,'BOTTLE_VOL'),mltbottle_vol');
netcdf.putVar(mltnc,netcdf.inqVarID(mltnc,'ROSETTE_TYPE'),mltrosette');
netcdf.putVar(mltnc,netcdf.inqVarID(mltnc,'STATION_PARAMETER_CHIM'),ETIQ.codes_paramc');

netcdf.close(mltnc);
display ('   Bravo !! Chimie ajoutée dans le Multistation !!!!!')


end

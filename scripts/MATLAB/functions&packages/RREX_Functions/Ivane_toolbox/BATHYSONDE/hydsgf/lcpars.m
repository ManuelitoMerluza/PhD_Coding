
function [tabpar,fillvalue,long_name,units,prec,valmin,valmax,tabflag] = lcpars(codpar, ficuni);

globalVarEtiquni;

% lecture du parametre et de ses attributs

tabpar = ncread(ficuni,codpar);

fillvalue  = ncreadatt(ficuni,codpar,'_FillValue');
long_name  = ncreadatt(ficuni,codpar,'long_name');
units      = ncreadatt(ficuni,codpar,'units');
valmin     = ncreadatt(ficuni,codpar,'valid_min');
valmax     = ncreadatt(ficuni,codpar,'valid_max');
prec       = ncreadatt(ficuni,codpar,'precision');


if  strcmp(codpar,'PRES')
      tabpar=round(tabpar);
      ETIQ.nval = length(tabpar);
      diffprs=diff(tabpar);
      ETIQ.interv = min(diffprs);
end

% lecture des flags qualite associes au parametre
codflag = [codpar '_QC'];
tabflag = ncread(ficuni,codflag);


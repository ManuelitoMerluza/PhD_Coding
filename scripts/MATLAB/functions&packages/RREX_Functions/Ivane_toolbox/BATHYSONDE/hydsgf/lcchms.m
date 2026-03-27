function [tabchim,flagchim,fillvalue,long_name,units,resp_param,org_resp,precision,valid_min, valid_max] = lcchms(codparchim, ficuni);

globalVarEtiquni;

% lecture du parametre chmique et de ses attributs

tabchim  = ncread(ficuni,codparchim);
flagchim = ncread(ficuni,[codparchim '_QC']);

fillvalue   = ncreadatt(ficuni,codparchim,'_FillValue');
long_name   = ncreadatt(ficuni,codparchim,'long_name');
units       = ncreadatt(ficuni,codparchim,'units');
resp_param  = ncreadatt(ficuni,codparchim,'resp_param');
precision   = ncreadatt(ficuni,codparchim,'precision');
org_resp    = ncreadatt(ficuni,codparchim,'Organism_resp');

valid_min   = ncreadatt(ficuni,codparchim,'valid_min');
valid_max   = ncreadatt(ficuni,codparchim,'valid_max');


ifill=find(tabchim==fillvalue);
tabchim(ifill)=NaN;

ETIQ.bottle_number = ncread(ficuni,'BOTTLE_NUMBER');

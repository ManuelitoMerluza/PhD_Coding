function g_int_fillval = f_get_fillvalue(filenc,var)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% g_int_fillval = f_get_fillvalue(filenc,var)
%
% Fonction permettant de récupérer la Fillvalue
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%     Le Bot Ph.    Avril 2009
%     P. Lherminier Mai 2009: ok si _FillValue n'existe pas

g_int_fillval = [];   
nc = netcdf.open(filenc,'NOWRITE');
varid = netcdf.inqVarID(nc,var);
[varname,xtype,dimids,natts] = netcdf.inqVar(nc,varid);
for ii = 1:natts,
  attname = netcdf.inqAttName(nc,varid,ii-1);
  if strcmp(attname,'_FillValue'),
    g_int_fillval = netcdf.getAtt(nc,varid,'_FillValue');
  end
end
netcdf.close(nc);
    
function attvalue = loadatt_nc(ncname,varname,attname)

ncid=netcdf.open(ncname,'nowrite');

varid=netcdf.inqVarID(ncid,varname);

attvalue = netcdf.getAtt(ncid,varid, attname);

netcdf.close(ncid);







[Nbdims, Nbfields, Nbglob, theRecdimID] = netcdf.inq(nc);


% recupere tous les global attributes dans la structure Globatt
Globatt=[];

for kd=1:Nbglob
        nameatt = netcdf.inqAttName(nc,netcdf.getConstant('NC_GLOBAL'),kd-1);
        Globatt.(nameatt).att = netcdf.getAtt(nc,netcdf.getConstant('NC_GLOBAL'),nameatt);
        Globatt.(nameatt).name = nameatt;
end


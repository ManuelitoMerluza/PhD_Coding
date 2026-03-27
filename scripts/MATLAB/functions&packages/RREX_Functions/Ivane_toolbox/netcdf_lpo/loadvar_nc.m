function var=loadvar_nc(ncname,varname,ideb,ifin)
%function var=loadvar_nc2(ncname,varname,[ideb],[ifin]);
% ideb: vector of first indexes ( length(ideb)=ndims(var) );
% ifin: vector of last indexes ( length(ifin)=ndims(var) );

ncid=netcdf.open(ncname,'nowrite');
varid=netcdf.inqVarID(ncid,varname);
if nargin==2
    var=netcdf.getVar(ncid,varid);
else
ideb_perm=fliplr(ideb);
ifin_perm=fliplr(ifin);

vec_start=[ideb_perm]-1;
vec_count=([ifin_perm]-[ideb_perm])+1;

    var=netcdf.getVar(ncid,varid,vec_start,vec_count);
end
%var=double(var);

netcdf.close(ncid);


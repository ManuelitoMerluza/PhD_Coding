function nc_rename_var(ncfile,oldvarname,newvarname,deleteoption)
% nc_rename_var(ncfile,oldvarname,newvarname,deleteoption)
%  rename the oldvarname with the newvarname in ncfile
%  deleteoption = 0 (default)to keep the old variable or 1 to delete it

if nargin<4,
    deleteoption = 0;
end

exist_oldvar = f_test_vars(ncfile,oldvarname);
if ~exist_oldvar
    disp([oldvarname ' does not exist in ' ncfile '. STOP.'])
else
  exist_newvar = f_test_vars(ncfile,newvarname);
  if exist_newvar
    disp([newvarname ' already exists in ' ncfile]);
    disp('Delete or rename it first.');
  else
    VINFO = ncinfo(ncfile,oldvarname);
    VINFO.Name = newvarname;
    ncwriteschema(ncfile, VINFO);
    vardata = ncread(ncfile,oldvarname);
    ncwrite(ncfile,newvarname,vardata);

    if deleteoption
        if exist('/bin/ncks','file')
            disp(['ncks -x -v ' oldvarname ' ' ncfile ' temp.nc']);
            system(['ncks -x -v ' oldvarname ' ' ncfile ' temp.nc']);
            disp(['movefile(temp.nc,' ncfile ');']);
            movefile('temp.nc',ncfile);
        else
            disp('Too complex to delete the old variable:');
            disp('check if you could install NCO toolkit to delete the variable: http://nco.sourceforge.net/');
        end
    end
  end
end

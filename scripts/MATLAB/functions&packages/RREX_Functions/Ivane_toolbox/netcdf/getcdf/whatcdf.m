function whatcdf

%--------------------------------------------------------------------
%     Copyright (C) J. V. Mansbridge, CSIRO, january 24 1992
%     Revision $Revision: 1.4 $
%
% DESCRIPTION:
% whatcdf lists all of the netCDF files (including compressed ones) in
% the current directory.  It also lists all of the netcdf files in the
% common data set.
% Note 1) All files are listed without their .cdf or .nc suffices.
% Note 2) whatcdf will only work for unix systems since it calls the
%    unix commands ls and sed.
% Note 3) The path for the common data set is found by a call to
%    pos_data_cdf.
%
% INPUT:
% none
%
% OUTPUT:
% messages to the user's terminal
%
% EXAMPLE:
% Simply type whatcdf at the matlab prompt.
%
% CALLER:   general purpose
% CALLEE:   Unix ls, sed
%
% AUTHOR:   J. V. Mansbridge, CSIRO
%---------------------------------------------------------------------

%     Copyright (C), J.V. Mansbridge, 
%     Commonwealth Scientific and Industrial Research Organisation
%     Revision $Revision: 1.4 $
%     Author   $Author: mansbrid $
%     Date     $Date: 1996/06/12 06:29:02 $
%     RCSfile  $RCSfile: whatcdf.m,v $
% @(#)whatcdf.m   1.3   92/05/18
% 
%--------------------------------------------------------------------

disp(' ')
disp('-----  current directory netCDF files  -----')
!ls -C *.cdf *.nc | sed -e 's/\.cdf/    /g' | sed -e 's/\.nc/   /g'
disp(' ')
disp('-----  current directory compressed netCDF files  -----')
!ls -C *.cdf.Z *.nc.Z | sed -e 's/\.cdf\.Z/      /g' | sed -e 's/\.nc\.Z/     /g'
disp(' ')
disp('-----  common data set of netCDF files  -----')
path_name = pos_data_cdf;
command = [ '!cd ' path_name '; ls -C *.cdf *.nc' ...
	' | sed -e ''s/\.cdf/    /g'''  ' | sed -e ''s/\.nc/   /g''' ];
eval(command);
disp(' ')


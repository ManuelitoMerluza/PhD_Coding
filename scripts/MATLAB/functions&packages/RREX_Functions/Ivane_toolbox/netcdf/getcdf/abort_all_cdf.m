function num_aborted = abort_all_cdf
%--------------------------------------------------------------------
%     Copyright (C) J. V. Mansbridge, CSIRO, august 13 1993
%     Revision $Revision: 1.1 $
%  function num_aborted = abort_all_cdf
%
% DESCRIPTION:
%  This function aborts all open files.  It is called at the start of
%  inqcdf.m, getcdf.m, getcdf_batch.m because the present version of
%  mexcdf has a bug in it that causes errors if more than one file is
%  open.  The file may have been opened by a separate call to mexcdf
%  or it may have been left open by an aborted call to inqcdf.m,
%  getcdf.m, getcdf_batch.m.
%
% OUTPUT:
%  num_aborted: the number of open files that have been aborted.
%
% CALLER:   inqcdf.m, getcdf.m, getcdf_batch.m
% CALLEE:   mexcdf.mex
%
% AUTHOR:   J. V. Mansbridge, CSIRO
%---------------------------------------------------------------------

%     Copyright (C), J.V. Mansbridge, 
%     Commonwealth Scientific and Industrial Research Organisation
%     Revision $Revision: 1.1 $
%     Author   $Author: mansbrid $
%     Date     $Date: 1993/08/17 11:18:35 $
%     RCSfile  $RCSfile: abort_all_cdf.m,v $
% @(#)
% 
%--------------------------------------------------------------------


cdfid = 0;
status = mexcdf('ABORT', cdfid);
while status == 0
%  disp(['aborted cdfid = ' int2str(cdfid)])
  cdfid = cdfid + 1;
  status = mexcdf('ABORT', cdfid);
end

num_aborted = cdfid;

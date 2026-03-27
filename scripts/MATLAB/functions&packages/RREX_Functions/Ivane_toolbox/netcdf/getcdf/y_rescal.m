function [rescale_var, rescale_att] = y_rescal()
%--------------------------------------------------------------------
%     Copyright (C) J. V. Mansbridge, CSIRO, Wed Feb  9 11:20:27 EST 1994
%     Revision $Revision: 1.1 $
%
% DESCRIPTION:
% y_rescal returns the scalars rescale_var and rescale_att.  Returning
% them this way ensures that getcdf.m and getcdf_batch.m have the same
% values of these variables.  Only alter these if you are sure that
% you know what you are doing.
% 
% INPUT:
% none
%
% OUTPUT:
% rescale_var: If this == 1 then a variable read in by getcdf.m and
%              getcdf_batch.m will be rescaled by 'scale_factor' and
%              'add_offset' if these are attributes of the variable.
%              If == 0 then rescaling will not be done.
% rescale_att: If this == 1 then the attributes '_FillValue',
%              'valid_range', 'valid_min' and 'valid_max' read in by
%              getcdf.m and getcdf_batch.m will be rescaled by
%              'scale_factor' and 'add_offset' when applied to the
%              relevant variable.
%              If == 0 then rescaling will not be done.
%
% EXAMPLE:
% Simply type y_rescal at the matlab prompt.
%
% CALLER:   getcdf.m, getcdf_batch.m
% CALLEE:   None
%
% AUTHOR:   J. V. Mansbridge, CSIRO
%---------------------------------------------------------------------

%     Copyright (C), J.V. Mansbridge, 
%     Commonwealth Scientific and Industrial Research Organisation
%     Revision $Revision: 1.1 $
%     Author   $Author: mansbrid $
%     Date     $Date: 1994/02/16 01:47:46 $
%     RCSfile  $RCSfile: y_rescal.m,v $
% 
%--------------------------------------------------------------------

rescale_var = 1;
rescale_att = 1;

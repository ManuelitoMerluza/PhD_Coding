function path_name = pos_data_cdf() 

%--------------------------------------------------------------------
%     Copyright (C) J. V. Mansbridge, CSIRO, april 15 1992
%     Revision $Revision: 1.3 $
%
% DESCRIPTION:
% pos_data_cdf returns the path to the common data set directory.
% This is the directory containing netcdf files accessible to all
% users.
% 
% INPUT:
% none
%
% OUTPUT:
% path_name: the path to the common data set directory.
%
% EXAMPLE:
% Simply type path_name at the matlab prompt.
%
% CALLER:   check_cdf.m, getcdf.m, getcdf_batch.m, inqcdf.m, whatcdf.m
% CALLEE:   None
%
% AUTHOR:   J. V. Mansbridge, CSIRO
%---------------------------------------------------------------------

%     Copyright (C), J.V. Mansbridge, 
%     Commonwealth Scientific and Industrial Research Organisation
%     Revision $Revision: 1.3 $
%     Author   $Author: mansbrid $
%     Date     $Date: 1996/09/06 05:55:59 $
%     RCSfile  $RCSfile: pos_data_cdf.m,v $
% @(#)pos_data_cdf.m   1.1   92/04/16
% 
%--------------------------------------------------------------------
%
% 28/10/98 : Modif. C Kermabon.
%
% Par defaut, pos_data_cdf etait initialise a un repertoire inexistant
% sur nons machines LPO.
% Du coup, a chaque appel a getcdf, getcdf_batch, ...etc, dans la console,
% on avait des messages d'erreurs. Ces messages etaient enregistres
% dans le /var/adm/messages. Le /var devenait alors souvent full !...
%
% Pour y remedier, on initialise le repertoire pos_data_cdf a un
% repertoire existant.
%

%path_name = [ ];
path_name = [ '/home/heolbis/matlab5/toolbos/netcdf/' ];

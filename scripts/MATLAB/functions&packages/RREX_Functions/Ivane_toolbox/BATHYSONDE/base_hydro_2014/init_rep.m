
function rep_MLT_NC=init_rep;
%-----------------------------------------------------------------------------------
%  Projet HYDROCEAN
%  -----------------
%  Version: 1.0
%  ------------
%  Creation : Fevrier 2003 /  C.Lagadec
%                                            
%-----------------------------------------------------------------------------------
%  Identification des repertoires
%-----------------------------------------------------------------------------------

%=====================================================

close all
clear all

global_rep;

parameters;

rep_MLT_NC   = '/home/lpo5/HYDROCEAN/MLT_NC/';

lat_extract_min = -80 ;


%=====================
% repertoires resultat :
%
%  - wk_resu    : pour liste des profils selectionnes
%  - wk_extract : pour fichier Netcdf contenant les profils selectionnes
%=====================


rep_resu     = 'wk_resu';
if ~exist(rep_resu,'dir'),
  [dirok,mess1,mess2] = mkdir(rep_resu);
end

rep_extr     = 'wk_extract';
if ~exist(rep_extr,'dir'),
  [dirok,mess1,mess2] = mkdir(rep_extr);
end




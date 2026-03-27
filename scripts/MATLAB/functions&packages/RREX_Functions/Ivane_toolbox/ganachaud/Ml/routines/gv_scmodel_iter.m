% script gv_scmodel_iter
% KEY: run geovel without loading data, in the iterative mode
% USAGE : 
% 
%
%
%
% DESCRIPTION : 
%
%
% INPUT:
%
% OUTPUT:
%
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , Mar 97
%
% SIDE EFFECTS :
%
% SEE ALSO :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER: conv_popescus
% CALLEE: geovel

% PARAMETER SPECIFICATION FOR GEOVEL.M
% TYPE help geovel for more information
% optional parameters are asked interactively if not specified

%DO NOT SAVE OUTPUT
p_saveOP=0;
p_load=0;
 
%OVERWRITE DIARY
% ovwd=1;

%INPUT DIRECTORY:
% IPdir='/data1/ganacho/SCMODEL/OUTPUT/';
 
%SECTION ID
% secid='pop314_a36n'
% secid='pop918_a36n'
 
%input data header file
% IPhdr=[secid '_stat.hdr.mat'];

%OUTPUT DIRECTORY
%  OPdir='/data1/ganacho/SCMODEL/OUTPUT/';
%  prefix=[secid '_pair']

%VELOCITY SIGN CONVENTION (if deep reference level)
  % 1 / -1
  p_pos2left=1;

%SUBSECTION SPECIFICATION (optional)
  
  %NAME
  %Secname=secid;
  
  %STATION INDICE
  Gis2do=1:174;
  
%TREATMENT FOR BOTTOM WEDGE (optional)
  %  1: polynomial fit
  %  2: velocity   set constant under LCD
  %  3:  --------  set manually
  %  4:  --------  set by const. slope under LCD
  %  5:  --------  set to zero
  
  %SET DEFAULT METHOD
  %defaulttreat=1;

  %SET SLOPMX FOR g_BOTWEDGE (MAXIMUM SLOPE) IF method='cstslope':
  % Inf for no limits
  %slopmx = 0;
  %OPTION TO RECOVER THE GEOVEL.F RESULTS
  %USE WITH THE defaulttreat = 4
  %dynh_option=0;

  Ptreat=defaulttreat*ones(length(Gis2do)-1,1);
  
  %PAIRS TO PLOT (WITHIN A RERUN) (optional)
  %   used only if 'Ptreat' exists
  %P2plot=[1 76];

  
%GRAPHICS
   p_plots=0;         %do the graphics or quick run
   p_plt_vel=0;       %plot velocity
   p_plt_topo=0;      %plots pairs and topography
   p_plt_botwedge=0;  %plot bottom wedge extrapolation (for debug)
   p_cmp2stat=0;      %comparison to station data      (for debug)
   
%RUN GEOVEL
if ~exist('geovel')
  path(path,'/data4/ganacho/HYDROSYS')
end
if ~exist('sw_info')
  path(path,'/data4/ganacho/SW')
end 

%CONVERT DEPTH INTO PRESSURE FOR GEOVEL
disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')
disp('')
disp('!  FIRST DEPTH NOT CONVERTED FROM ZERO TO 12.5 !')
disp('')
disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')


geovel


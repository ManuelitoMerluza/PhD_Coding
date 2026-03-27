% PARAMETER SPECIFICATION FOR GEOVEL.M
% TYPE help geovel for more information
% optional parameters are asked interactively if not specified

% A.GANACHAUD, FEB 1st 97

clear

%OVERWRITE PRECEDING DIARY
  ovwd=1;

%INPUT DIRECTORY:
 IPdir='/data1/ganacho/HDATA/';
 
%SECTION ID
 secid='flst'
 
%input data header file
 IPhdr=[secid '_stat.hdr.mat'];

%OUTPUT DIRECTORY
  OPdir='/data1/ganacho/HDATA/GEOVELM/';
  prefix=[secid 'pfit_pair']

%VELOCITY SIGN CONVENTION (if deep reference level)
  % 1 / -1
  p_pos2left=1;

%SUBSECTION SPECIFICATION (optional)
  
  %NAME
  Secname=secid;
  
  %STATION INDICE
  Gis2do=[1:11];
  
%TREATMENT FOR BOTTOM WEDGE (optional)
  %  1: pair indices that are just maintained (plane fit)
  %  2: pair indices whose velocity will be set to be constant under LCD
  %  3:  --------  set manually
  %  4:  --------  set by const. slope under LCD
  %  5:  --------  set to zero
  
  %SET DEFAULT METHOD
  defaulttreat=4;

  %SET SLOPMX FOR g_BOTWEDGE (MAXIMUM SLOPE) IF method='cstslope':
  % Inf for no limits
  slopmx = 1;

  Ptreat=defaulttreat*ones(length(Gis2do)-1,1);
  
  %PAIRS TO PLOT (WITHIN A RERUN) (optional)
  %   used only if 'Ptreat' exists
  %P2plot=[1 76];
  Ptreat=defaulttreat*ones(length(Gis2do)-1,1);

%OPTION TO RECOVER THE GEOVEL.F RESULTS
  %USE WITH THE defaulttreat = 4
  dynh_option=1;
  
%GRAPHICS
   p_plots=0;         %do the graphics or quick run
   p_plt_vel=0;       %VELOCITY PLOT
   p_plt_botwedge=0;  %plot bottom wedge extrapolation (for debug)
   p_cmp2stat=0;      %comparison to station data      (for debug)
   
%RUN GEOVEL
format compact;
path(path,'/data4/ganacho/HYDROSYS')
geovel

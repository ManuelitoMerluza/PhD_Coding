%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function geovel
% KEY: calculates the geostrophic velocities
%
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , Oct 95
%
% UPDATES: Jan 96, D. Spiegel
%  Cosmetic changes to alphabetize variable comments and space command lines
%  Started diary earlier to include more information
%  NOT ANY MORE Default method is set to cstslope if 'method' has not yet been defined
%  Set slopmax=1 which is passed to g_botwedge from g_pairset for cstslope case
%  Read T and S if dynh must be calculated ie isnan(Idynh) or 
%  if dynh_option ie we calc dynh from T and S in bot triangle
%     to recover the results from geovel.f
%  Calculate and use Maxdp = Maxd(ishdp(2,:),:);
%  Provide parameter p_plots to make plots of choose stat, topog and gvel optional:
%     if p_plots        
%  Distinguished between pressure for ctd and non ctd data:
%     if Isctd(Itemp)   pres = Presctd; else  pres = Pres; end
%  Renamed shald to sdynh, deepd to ddynh for consistency with pdynh
%  Altered call of wyhdro to include OPdir and use Maxdp not Maxd
%  Replaced g_pltvel by more general plot_pprop (which used both Maxd and Maxdp)
%  Add Maxdp to variables saved in .mat file
%
% PROBLEMS : the sign convention has to be checked
%
% DESCRIPTION : 
%  For each pair of station the values are extrapolated,
%    when bottom depth is different, by fitting a plane.
%  The geostrophic velocities are then computed (ref level at the surface)
%  Bottom wedge: the treatment can be made interactively
%    default: specified by parameter defaulttreat
%      then, for the suspicious pairs, alternative treatments:
%          1-plane fit
%          2-constant velocity under Last Common Depth
% 	   -manually set           <not available>
%          -const. slope under LCD <not available>
%          5-polynomial fit        
%          6-squeezed deviations         
%
% MAJOR PARAMETERS:
%     IPdir IPhdr          : input  directory, header file name
%     OPdir OPhdr          : output directory, header file name
%     Gis2do               : vector specifying stations in subsection
%     p_plots = 0          : plotting parameter: =0 quick run, !=0 do the graphics
%     p_pos2left           : velocity sign convention: =1 positive sign
%     defaulttreat         : default bottom wedge treatment
%     Ptreat(Npair)        : OPTIONAL, if provided, pairs are treated using the
%                            specified treatment. If not, uses defaulttreat and
%                            prompt the user if pair is suspicious
%     P2plot(Npair)        : if Ptreat is precised, one can for prompt on
%                             suspicious pairs. then P2plot(ipair)=1
%
%     slopmx               : maximum slope for cstslope method (default is 1)
%     dynh_option (0/1)    : recovers the geovel.f results by computing T
%                            and S and matching dynamic heights at the bottom
%                            No prompt on suspicious pairs in this case.
%
%INPUT FILES (if variables are not in memory)
%  station data for a section or "cruise"
%  <sec>_SM_hdr.mat              : header file for the station data for the section 
%  <sec>_SM_<prop>.fbin          : station data files for the section 
%    for <prop> = dynh (if ctd) temp, sali, oxyg, phos, sili, etc.
%    i.e. station data which has been treated, interp at standard depths,
%    bottle and ctd merged, formatted by mk_hydrofile.m 
%    into binary (.fbin) files readable by Matlab.
%
% OUTPUT FILES                   : pair data for subsection of (or entire) input section 
%  <sec>_PG_<subsec>_hdr.mat     : header file for pair data for subsection
%  <sec>_PG_<subsec>_<prop>.fbin : pair data files for subsection 
%    for <prop> = dynh (if ctd) temp, sali, oxyg, phos, sili, etc.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INPUT STATION HEADER FILE VARIABLES:
%     Botp         (Nstat) : bottom pressure
%     Cast         (Nstat) : original station indice, before mergech
%     Cruise               : name of the cruise
%     Isctd        (Nprop) : 1 if this data is on the ctd Pressure intervals
%     Itemp,Isali,Idynh,   : integer, index of each property, NaN if not avail
%     Kt           (Nstat) : record number (not useful at the moment)
%     MPres        (Nprop) : # of "standard" depth
%     Maxd   (Nstat,Nprop) : index of deepest measurement
%     Nobs         (Nstat) : # of observations  
%     Nprop                : # of properties available (temp, sali, ...)
%     Nstat                : # of stations
%     Precision            : format for the binary files (cf mk_hydrofile.m)
%     Pres   (MPres(iprop)): depth (db)
%     Presctd(MPres(iprop)): depth (db) for ctd data
%     Statfiles            : names of the binary files (.fbin) containing property values
%     Propnm               : name of each property
%     Propunits            : units -
%     Remarks              : -
%     Secdate              : date of the section
%     Ship         (Nstat) : ship Id 
%     Slat Slon    (Nstat) : locations
%     Treatment            : done on the data
%     Xdep         (Nstat) : depths to the deepest measurement for each station
%
% OUTPUT PAIR HEADER FILE VARIABLES (all of the above plus the following):
%     Gis_select           : indice of the station selected from the input
%     Cast , ...           : corresponding original station number
%     Maxdp                : Max depth for the deeper station of the pair
%     Npair                : # of pairs
%     Pairfiles            : names of the binary files (.fbin) containing property values
%     Pbotp        (Npair) : depth (db) at this pair (deepest station depth)
%     Plat Plon    (Npair) : pair latitudes, longitudes     
%     Ptreat               : treatment done at this pair
%     Secname              : subsection name 
%     Velfile              : name of binary file containing velocities (ref. to surface)
%     Velprec              : precision (to read Velfile)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% UPDATE 
%   Jan 97, A. Ganachaud 
%    MODIF of ishdp Jan 97: Pres(Maxd(:,Itemp)) became Botp
%   Feb 97, A. Ganachaud 
%    change the default method system  
%    change the output file names (do not include prefix + Secname)     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SEE ALSO :
% CALLER: general purpose
% CALLEE: check_val, g_botwedge, g_pairset, g_hotpair, g_pltopo, rhydro, 
%  <sw_ library>
%         
%%%%%%%%%%%%%%%%%%%%%%%%%
% LIBRARIES
%%%%%%%%%%%%%%%%%%%%%%%%%
%path(path,'/data4/ganacho/Ml/Routines');
if ~exist('p_plt_topo')
  p_plt_topo=p_plots
end

%%%%%%%%%%%%%%%%%%%%%%%%%
% GLOBAL VARIABLES
%%%%%%%%%%%%%%%%%%%%%%%%%
global MENU_VARIABLE; %for the menus
if ~exist('Slon')
  global Slat Slon
end

if ~exist('p_load')
  p_load=exist('IPdir');
end
if ~exist('p_saveOP')
  p_saveOP=1;
end
  
if p_load
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %LOAD THE DATA ( cf comments re INPUT STATION HEADER FILE )
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  eval(['load ' IPdir  IPhdr])
  if ~iscell(Propnm)
    g_conv2cell %convert a few variables to cell arrays for 
    %compatibility with older data files
  end
  
  
  %OUTPUT HEADER FILE
  OPhdr = [prefix '.hdr.mat'];
  Treatment = ['geovel.m run on ' IPhdr ' ' date ];
  oo = ones(Nprop,1);
  for iprop=1:Nprop
    Pairfiles{iprop} = [prefix,'_',Propnm{iprop},'.fbin'];
  end
  Velfile = [prefix '_gvel.fbin'];
  Velprec = 'float32';
  Velunit = 'cm/s';
end

if p_saveOP
  if ~(exist(OPdir)==7)
    disp('Creating output directory ...')
    disp(['mkdir ' OPdir]);
    unix(['mkdir ' OPdir]);
  end

  %%%%%%%%%%%%%%%%%%%%%%%%%
  %START DIARY
  %%%%%%%%%%%%%%%%%%%%%%%%%
  disp(['Opening diary:'])
  disp([pwd '/geovel.dry'])
  if exist('geovel.dry')
    disp('removing old diary ...')
    unix('rm geovel.dry');
  end
  diary geovel.dry
  %ovw = diarystart('geovel.dry',ovwd); 
  %ovwd = "overwrite" previous version
  
  disp(['Input data from the directory :'])
  disp( IPdir )
end

%%%%%%%%%%%%%%%%%%%%%%%%%
% PARAMETER SPECIFICATION 
%%%%%%%%%%%%%%%%%%%%%%%%%
% DEFAULT METHOD FOR BOTTOM WEDGE
  if ~exist('defaulttreat')
    defaulttreat=1;
  end
  if ~exist('p_horiz_extrap')
    p_horiz_extrap=0;
    disp('Not horizontal extrapolation ... Sure ?')
    ppause
  elseif p_horiz_extrap
    disp('trying horizontal extrapolation by default')
    disp('setting dynh_option')
    dynh_option=1;
  else
    disp('Not horizontal extrapolation ')
  end
  switch defaulttreat
    case 1
      method='pfit';
    case 2
      method='cstvel';
    case 3
      error('not available')
    case 4
      method='cstslope';
      if (~dynh_option) 
         error('dynh_option should be set to one to get geovel.f results')
      end
    case 5
      method='polyfit';
    case 6
      method='squeezeddeviation';
    otherwise
      error('default method not available')
  end  %switch defaulttreat   
  disp(sprintf('Using method: %s by default',upper(method)))

  %DISPLAY DYNH OPTION
  if ~exist('dynh_option')
    dynh_option=0;
  end
  if dynh_option
    disp(sprintf('Using dynamic height option: %d',dynh_option))
    disp('temp and sali are extrapolated, then dynh is recomputed ')	
  else
    disp('dynamic height is directly extrapolated')
  end
  disp('below last common depth (LCD)')
  
%SET SLOPMX
  if ~exist('slopmx')
    slopmx = 1.0;
  end
  disp(sprintf('Using maximum slope: %5.1f',slopmx))
  disp(' ');disp(' ');disp(' ');disp(' ');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%REMOVE DISCONTINUITIES IN LONGITUDE (-180 to 181 or 360 to 1)
  Slon = long_cont(Slon);
  check_val(Slon,'lon');
  check_val(Slat,'lat');
  if ~exist('Presctd')
    Presctd=Pres;
  end
  if ~exist('Idynh')
    Idynh=NaN;
  end
  check_val(Presctd,'pres');
  check_val(Pres,'pres');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%SELECTION OF STATIONS
  if any(Isctd)
    pres=Presctd;
  else
    pres=Pres;
  end
  if p_plots
   if ~exist('Gis2do')
     global staymen exmen
     [Gis2do,Secname] = g_choose_stat(Slat,Slon,pres,Maxd,Botp,Cruise);
   else
     if Gis2do=='a'
       Gis2do=1:Nstat;
     end
     global staymen exmen
     [Gis2do,Secname] = g_choose_stat(Slat,Slon,pres,Maxd,Botp,...
       Secname,Gis2do);
   end
 end
 if Gis2do=='a'
   Gis2do=1:Nstat;
 end

 %REDUCES THE HEADER DATA TO THIS SUBSET
 Nstatold = Nstat; %preserved for reading the data.
 Maxdold = Maxd;
 g_extract

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%DYNAMIC HEIGHT (CREATE IF IT DOESN'T EXIST)
  if isnan(Idynh) | dynh_option
    % read temp and sali in either case, 
    % since we'll need to calculate dynh later in the bottom triangle

    if ~exist('temp')
      temp = rhydro([IPdir Statfiles{Itemp}],Precision{Itemp},...
	MPres(Itemp),Nstatold,Maxdold(:,Itemp));
    end
    if ~exist('sali')
      sali = rhydro([IPdir Statfiles{Isali}],Precision{Isali},...
	MPres(Isali),Nstatold,Maxdold(:,Isali));
    end
    % extract the selected stations
    temps = temp(:,Gis2do);
    check_val(temps,'temp')
    salis = sali(:,Gis2do);
    check_val(salis,'sali')
  end
  
%DISTANCES
%distance between the stations(in meters):
  distg = 1e3*sw_dist(Slat,Slon,'km');
  distt = cumsum(distg);
  Npair = Nstat-1;
  dst = 1e-3 * [0; distt];          	% linear distance between stations
  dpt = 1e-3 * [distt - 0.5 * distg];	% linear distance between pairs  
  
%DYNAMIC HEIGHT
  if isnan(Idynh) | (exist('p_filter_r')&p_filter_r)
    if p_filter_r
      disp(sprintf(...
	'Horizontally Filtering temp and sali on the first %i depths',...
	p_filter_ndep))
      plot(dst,temps(1:p_filter_ndep,:)','b--')
      temps(1:p_filter_ndep,:)=filter_rows_gaussian(dst,...
	temps(1:p_filter_ndep,:),p_filter_r);
      hold on;plot(dst,temps(1:p_filter_ndep,:)','r');
      title('filtered temperature');zoom
      figure;
      plot(dst,salis(1:p_filter_ndep,:)','b--')
      salis(1:p_filter_ndep,:)=filter_rows_gaussian(dst,...
	salis(1:p_filter_ndep,:),p_filter_r);
      hold on;plot(dst,salis(1:p_filter_ndep,:)','r');
      title('filtered salinity');zoom;ppause
    end
    disp('********************************')
    disp('* RECOMPUTE THE DYNAMIC HEIGHT *')
    disp('********************************')
    disp('computing the dynamic height at selected stations ...')
    gpans = sw_gpan(salis,temps,pres);
  else
    disp('reading the dynamic height at all stations ...')
    if ~exist('dynh')
      dynh = rhydro([IPdir Statfiles{Idynh}],Precision{Idynh},...
	MPres(Idynh),Nstatold,Maxdold(:,Idynh));
    end
    % MULTIPLY DYNH BY 10 to get geopotential used by sw_<routines> 
    % gpan(m^2/s^2) = (10 m/s^2) * dyn meters 
    gpan=10*dynh;
    clear dynh

    % extract the selected stations
    gpans = gpan(:,Gis2do);
    check_val(gpans/10,'dynh')
  end
  
  % clear T and S now if we're not using the optional dynh calc
  if ~dynh_option
    % clear temps salis %THAT IS ONLY USED IF MEMORY PROBLEMS
  end
  
%ISHDP: SHALLOW/DEEP STATION INDICE FOR EACH PAIR
  %(based on deepest observation, not actual depth)
  %initial order:   
  ishdp = [1:Nstat-1; 2:Nstat];
    
  %'iswitch':
    isw = find( diff(Botp) < 0 ); 
    %disp('MODIF of ishdp, Jan 97: Pres(Maxd(:,Itemp)) became Botp')
    
  %switch order if must:
    ishdp([1 2],isw) = ishdp([2 1],isw);
    signp      = p_pos2left * ones(Nstat-1,1); 
    signp(isw) = -1 *p_pos2left* ones(size(isw));
  % IMPORTANT: ishdp = index shallow - deep
  % ishdp(1,ipair) contains the indices of the shallow station
  % ishdp(2,ipair) contains the indices of the deep station
  % corresponding to pair 'ipair'
  % signp = +1 if shallow comes before deep
    Maxdp = Maxd(ishdp(2,:),:);
   
%GEOSTROPHIC VELOCITY: TREAT INDIVIDUALLY EACH PAIR
  %LCD = Last Common Depth
  gvel = NaN*ones(MPres(Itemp),Npair); %(cm/s)

  if ~exist('Ptreat')
    Ptreat=defaulttreat*ones(Npair,1);
    if p_horiz_extrap
      Ptreat=Ptreat+100;
    end
    %indice of the treatment done on the pair:
	% 1: pair indices that are just maintained (plane fit)
	% 2: pair indices whose velocity will be set to be constant under LCD
        % 3:  --------  set manually
	% 4:  --------  set by const. slope under LCD
	% 5:  --------  polynomial fit
    set_ptreat = ones(Npair,1);
  else
    if length(Ptreat) ~= Npair
      error(sprintf(['length(Ptreat) is %i and should be' ...
      ' Npair=%i'],length(Ptreat),Npair))
    end
    set_ptreat = zeros(Npair,1);
    if exist('P2plot')
      set_ptreat(P2plot) = ones(size(P2plot));
    end
  end %if ~exist('Ptreat')

  %TOPOGRAPHY PLOT
  %plot the topography and stations
  if p_plt_topo
    figure(1); 
    clf; 
    set(gcf, 'Position', [4 5 1000 250] );
    g_pltopo(Nstat, dst, pres, Maxd(:,Itemp), Botp)
    %figure(2); 
    %set(gcf, 'Position', [4 319 560 420])
  end
  
  if Isctd(Itemp)
    pres = Presctd;
  else
    pres = Pres;
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %LOOP OVER THE PAIRS FOR COMPUTING DYNH AND GVEL
  for ipair = 1:Npair
    bwedgemethod=defaulttreat;
    %treat wedge and compute velocity
    p_hz_ex=p_horiz_extrap;
    isdeep=[];
    g_compgvel
    %lookup for dangerous situations
    g_hotpair
  end %on ipair
  close all
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %COMPUTE SURFACE VELOCITY
  if exist('Eta')
    if ~all(isnan(Eta))
      disp('Computing surface velocity ...')
      grav=sw_g(Slat,0); %(m/s^2)
      svel=-p_pos2left*100*sw_gvel(Eta'.*grav',Slat,Slon); %in cm/s
    else
      svel=NaN*ones(1,Npair);  
    end
  else
    svel=NaN*ones(1,Npair);  
  end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%SAVE THE GEOSTROPHIC VELOCITY
  if p_saveOP
    if exist([OPdir Velfile])==2
      so=input(['overwrite existing output ?'],'s');
    else
      so='y';
    end
    if so=='y'
      ovw=1;
      whydro(gvel,[OPdir Velfile],Velprec,Maxdp(:,Itemp),ovw);
    else
      ovw=0;
    end
  end
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%CALCULATE THE PROPERTIES AT THE PAIRS AND
%SAVE THE PAIR PROPERTIES

  g_pairset

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%SAVE HEADER FILE

  %CORRECTS A POSSIBLE MESS IN MAXD
  for istat=1:Nstat
    if any(diff(Maxd(istat,:)))
      disp('Maxd corrected, stat:');disp(istat)
      Maxd(istat,:)=min(Maxd(istat,:));
      Pbotp(istat)=Pbotp(istat)-1;
    end
  end
  for ipair=1:Npair
    if any(diff(Maxd(ipair,:)))
      disp('Maxdp corrected, pair:');disp(ipair)
      Maxdp(ipair,:)=min(Maxdp(ipair,:));
      Botdp(ipair)=Botdp(ipair)-1;
    end
  end

if p_saveOP
  if ovw
    disp('Saving the environment in geovel.mat')
    save geovel.mat
    disp('Saving Ptreat in Ptreat.mat')
    save Ptreat.mat Ptreat
    disp(['Saving header file ' OPdir OPhdr])
    Gis_select=Gis2do; % 		stations selected from input file
    if p_saveOP
      eval(['save ' OPdir OPhdr  ...
	  ' IPhdr Treatment Remarks Cruise Secname ' ...
	  'Npair Plat Plon Velfile Velunit Velprec Ptreat Pbotp ' ...
	  'Secdate MPres Nstat Slat Slon ' ...
	  'Botp Pres Presctd Maxd Maxdp Nprop Isctd svel ' ...
	  'Itemp Isali Ioxyg Iphos Isili Idynh Propnm ' ...
	  'Propunits Pairfiles Precision ' ...
	  'Gis_select Ship Stnnbr Xdep Kt Nobs slopmx'])
      disp(' write header file : ')
      disp([OPdir OPhdr])
    end
  else
    disp('no output file written')
  end
end %if p_saveOP
 
%CLOSE DIARY
disp('geovel is done')
diary off
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plotting the referenced velocities
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('');
if p_plt_vel
  disp('-------------- PLOTS ------------------------')
  
  if Isctd(1)
    pres=Presctd;
  else
    pres=Pres;
  end
  gi2p=1:Npair;
  
  %gi2p=1:fix(Npair/2);
  %gi2p=fix(Npair/2):Npair;
  
  %gi2p=1:fix(Npair/3);
  %gi2p=fix(Npair/3):fix(2*Npair/3);
  %gi2p=fix(2*Npair/3):Npair;
  grelvel=g_refvel(gvel,pres,Botp,3000);
  disp('Plotting 3000db referenced velocity')
  gi2ps=[gi2p,max(gi2p+1)];
  figure;clf
  plt_prop(grelvel(:,gi2p), 'vel', 'cm/s', Cruise, pres, ...
    Maxd(gi2ps,1), Botp(gi2ps), Slat(gi2ps), Slon(gi2ps),...
    500*ceil(max(Botp)/500),1,gi2p)
  land
  setlargefig
end %if p_plt_vel

if p_plots
  disp('plotting pair properties ...')
  for iprop=1:Nprop
    pprop=rhydro([OPdir Pairfiles{iprop}],Precision{iprop},MPres(iprop),...
      Npair,Maxdp(:,iprop));
    if any(~isnan(pprop))
      disp(['plotting ' Propnm{iprop} ' ... '])
      figure; clf; 
      maxy=500*ceil(mmax(Botp)/500);
      if (iprop==Ioxyg)&any(any(pprop>100)) 
	pprop=pprop/44.6369;
	punits='ml/l';
	disp('approximation for Oxygen')
      else
	punits=Propunits{iprop};
      end
      plt_prop(pprop, Propnm{iprop}, punits, ...
	Cruise, pres, Maxd(:,iprop), Botp, Slat, Slon,maxy)
    end
    land;setlargefig
    zoom
  end
end %if p_plot
if p_plots&input('print all that ? (y/n)','s')=='y'
  dprint(1:gcf)  
end
  
%Clear everything in the iterative mode
if ~p_saveOP
  clear dynh temps salis dynhs oxyg phos sili nita
  clear uvel prop pprop signp sprop dprop dd ddynh
  clear distg distt dpt dst dyname 
  clear dyunit exmen grav icastc im ipair iprop is isd ishdp
  clear iss isw itreat lost_area m2 p_cmp2stat p_load p_plots 
  clear p_plt_botwedge p_plt_topo p_plt_vel p_pos2left p_saveOP 
  clear pdynh pname pprop_p pres sdynh set_ptreat staymen strwarn 
  clear MENU_VARIABLE method men
end

%%%%%%%%%%%%%%%%%%%%%%% END OF GEOVEL PROGRAM %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% See in Geovel/ for previous version with debug stuff
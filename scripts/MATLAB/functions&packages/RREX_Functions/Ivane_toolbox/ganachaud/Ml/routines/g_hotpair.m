% script g_hotpair
% KEY:
% USAGE :
%
% DESCRIPTION : 
%  analyse the situations where the calculation of the velocity
%  is done in dangerous situations. Gives a graphical warning
%  and allow to correct
%
%
% INPUT:  ipair
%
% OUTPUT: Ptreat(ipair)
%              1: pair indices that are just maintained (plane fit)
%              2: pair indices whose velocity will be set to be constant under LCD
%              3:  --------  set manually
%              4:  --------  set by const. slope under LCD
%              5:  --------  set to zero
%
%          gvel, velocities, modified if necessary
%
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , Oct 95
%
% UPDATES: Jan 96, D. Spiegel
%  Distinguished between pressure for ctd and non ctd data:
%     if Isctd(Itemp)   pres = Presctd; else  pres = Pres; end
%  Provide parameter p_plots to make plots optional:
%     if p_plots        figure(2); plot(dpt(ipair), ...
%  Replaced calls to functions g_pfit, g_cstvel, g_cstslope with g_getgvel
%     
% SIDE EFFECTS :
%
% SEE ALSO :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER: geovel.m
% CALLEE: g_pltdynh.m g_cstvel.m

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIND THE PAIRS WITH SITUATIONS THAT CAN YIELD ERRONEOUS RESULTS
% -STEEP SLOPE (extrapolation may have lead to foolish values)
% -SHALLOW WATER (>310m near seasonal thermocline)
% -SMALL DISTANCE BETWEEN THE STATIONS ( < 20 km )
% -LARGE GVEL (>100cm/s)
% 
% steep slope means:
%  shlw stat. | max depth difference
%         any | 2010 % enormous interval
%        5010 | 1010 % deep water
%        1510 | 510  % near the thermocline

warn=1;

dd = abs(diff(pres(Maxd([iss;isd],Itemp))));	% Depth difference
sd = pres(Maxd(iss,Itemp));	                % Depth of the shallow station
if( exist('P2plot')&set_ptreat(ipair)|...
    (dd > 2010)                | ...
   ((sd < 5010) & (dd > 1010)) | ...
   ((sd < 1510) & (dd >  510)) )
  strwarn='LARGE DEPTH DIFFERENCE';
elseif (sd < 310)
  strwarn='SHALLOW WATER';
elseif (distg(ipair) < 20e3)
  strwarn='CLOSE STATIONS';
elseif (any(abs(gvel(:,ipair)) > 100))
  strwarn='LARGE VELOCITY';
elseif sflag(ipair)
  strwarn='dangerous distance ratio for horizontal extrapolation';
else
  warn=0;
end

if warn
  if p_plt_topo  
    figure(1);%plot a star on the warning pair
    plot(dpt(ipair), -mean(pres(Maxd([isd,iss],Itemp))), 'r*','markersize',10)
  end
  disp([strwarn ', PAIR ' int2str(ipair)])
  disp(['stations    : ' sprintf('%5i %5i', ishdp(:,ipair))])
  disp(['Depth (db)  : ' sprintf('%5i %5i', pres(Maxd(ishdp(:,ipair),Itemp)))])
  disp(['lat         : ' sprintf('%5.1f %5.1f', Slat(ishdp(:,ipair)))])
  disp(['lon         : ' sprintf('%5.1f %5.1f', Slon(ishdp(:,ipair)))])
  disp(['distance(km): ' sprintf('%5.1f %5.1f', distg(ipair)/1e3)])
  lost_area = abs(dd) * distg(ipair)/2;
  disp(['delta depth x dist : ' sprintf('%5.2f km^2', lost_area./1e6)])
  
  if set_ptreat(ipair)
    figure(4); clf;
    hpop = uicontrol('style', 'popup', 'Position', [0 390 100 30], ...
      'string', ['plane-fit|const-vel|manual|'...
      'const-slope|poly-fit|squeezeddeviation|horizontal|limit'], ...
      'ForeGroundColor', 'k', 'call', 'im=get(hpop,''value'');');
    hpop1 = uicontrol('style', 'push', 'Position', [460 390 100 30], ...
      'string', 'ACCEPT', ...
      'ForeGroundColor', 'k', 'call', 'im=10;');
    hpop2 = uicontrol('style', 'push', 'Position', [460 360 100 30], ...
      'string', 'PRINT', ...
      'ForeGroundColor', 'k', 'call', 'print;');
  end
  
  men = 1;
  itreat = defaulttreat;
  while men
    if set_ptreat(ipair)
      % plot properties obtained
      g_pltdynh(4, ipair, pres, gvel(:,ipair), ...
	sgpan, Maxd(iss,Itemp), dgpan, Maxd(isd,Itemp), strwarn,...
	extrapolated_temp,isdeep,Slat,Slon)
        im = 0;
	while im==0
	  drawnow    %wait for user's selection
	end
    else
      im=Ptreat(ipair);
      if im>100
	im=7;
	itreat=Ptreat(ipair)-100;
      end
      men=0;
    end
    switch im
      case {1,2,5,6}
        itreat=im;
	bwedgemethod=itreat;
	p_hz_ex=0;
	g_compgvel
      case 3
        h = uicontrol('style', 'radiobutton', 'Position', [0 370 400 60], ...
	  'string', 'MANUAL FILLING NOT AVAILABLE', ...
	  'ForeGroundColor', 'k');
	%waitforbuttonpress; delete(h)
	%itreat=3;
	%gvel1=gvel(1:Maxdp(ipair,1),ipair);
	%gvel1
	%idp1=input('new geost velocity ? (use gvel1 variable)');
	%idp2=input('to depth ? (db)
      case 4
        itreat=im;
	bwedgemethod=itreat;
	p_hz_ex=0;
	if ~dynh_option
	  disp('setting dynh_option for constant slope extrapolation')
	  dynh_option=1;
	end
	g_compgvel
      case 7 %horizontal extrapolation
	bwedgemethod=itreat; %takes the last method for the remaining points
	p_hz_ex=1;
	if ~dynh_option
	  disp('setting dynh_option for horizontal extrapolation')
	  dynh_option=1;
	end
	g_compgvel
      case 10 %exit from menu loop
        men = 0;                   
	Ptreat(ipair)=itreat;
	if p_hz_ex & Ptreat(ipair)<100
	  Ptreat(ipair)=100+Ptreat(ipair);
	  disp('horizontal extrap')
	end
	switch itreat
	  case 1
	    disp('pfit');
	  case 2
	    disp('cstvel');
	  case 3
            disp('manual')
          case 4
	    disp('cstslope');
          case 5
            disp('polyfit');
          case 6
            disp('squeezeddeviation');
	end %switch itreat
    end %switch im
  end %while men on this pair 
  
  if set_ptreat(ipair)
    delete(hpop); delete(hpop1); delete(hpop2)
  end  
  
else
  if Ptreat(ipair)~=100*p_horiz_extrap+defaulttreat;
    disp('Ptreat different from defaulttreat for non-hot pairs')
    error('cannot be taken into account')
  end
end %if warn


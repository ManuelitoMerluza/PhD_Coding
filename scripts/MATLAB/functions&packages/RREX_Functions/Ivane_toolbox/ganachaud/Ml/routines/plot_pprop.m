function plot_pprop(prop, pname, punits, Nstat, ...
    cruise, ds, dp, pres, maxd, maxdp, botd, vcont)
% KEY: plot the topography and contour of the property
% USAGE :
% plot_pprop(prop, Propnm(iprop,:), Propunits(iprop,:), Nstat, ...
%   Cruise, dst, dpt, Pres, Maxd(:,Itemp), Maxdp(:,Itemp), Botd, Vcont(:,iprop));
%
% DESCRIPTION : 
%
% INPUT:
%
% OUTPUT:
%
% AUTHOR : D. Spiegel (diana@plume.mit.edu) , Dec 95
%          based on g_pltvel.m by 
%          A.Ganachaud (ganacho@gulf.mit.edu) , Oct 95
%
% SIDE EFFECTS :
%
% SEE ALSO :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER: geovel or disp_pprop
% CALLEE: extcontour
disp('plot_pprop OBSOLETE, use plt_prop instead')

   clf

    ns = Nstat;
    xd1=max(botd);
    id1=min([find(pres>xd1);length(pres)]);
    d1 = -pres(id1);
    set(gca, 'FontSize', 8)
    mi = min(mmin(prop));
    mx = max(mmax(prop));
    mxc = max(50, 20*floor(mx/20));
    mic = min(-50, 20*ceil(mi/20));
    
    % Set contour intervals for geostrophic velocity
    if ~exist('vcont')
      vcont = [-50:5:50]; 		
      if mxc > 50
        vcont = [vcont, 60:10:mxc];
      end
      if mic < -50
        vcont = [mic:10:-60, vcont];
      end
    end
    
    % Print ylabel, Yticklabels
    % set yticks at the standard depths
    % and put only some labels
    set(gca, 'Ytick', -pres)
    iynlab = find((250*round(-pres/250)) ~= -pres);
    ylab = [];
    for ii = 1:length(pres)
      ylab = str2mat(ylab, sprintf('%5i', -pres(ii)));
    end
    ylab = ylab(2:length(ylab), :);
    for ii = 1:length(iynlab)
      ylab(iynlab(ii), :) = '     ';
    end
    set(gca, 'Yticklabels', ylab, 'Xlim', [ds(1) ds(ns)])
    ylabel('Standard Depth')
    hold on;

    % To improve visual effect of contours
    % extend bottom values of prop down to depth 37 
    for ipair = 1:ns-1
      for idepth = maxdp(ipair, 1):37
        prop(idepth, ipair) = prop(maxdp(ipair, 1), ipair);
      end
    end

    % Fill negative contours
    [cs, h] = extcontour(dp, -pres, prop, [-1000 0], 'fill');
    cn = .9*[1 1 1];
    for i = 1:length(h)
      if get(h(i), 'CData') < 0
	set(h(i), 'FaceColor', cn)
      else
	set(h(i), 'FaceColor', 'k')
      end
    end
    set(gca, 'Ylim', [ d1, 0])   
    
    % Plot contours
    disp('Starting extcontour ...')
    extcontour(dp, -pres, prop, vcont, 'label', 'fontsize', 6);
    disp('Finished extcontour ...')
    
    % Print xlabel, title
    xlabel('Linear distance (km)');
    title(sprintf('%s - contours from %4.0f to %3.0f %s ', ...
      pname, mi, mx, punits))
   
%    grid on
    
    % Plot bottom topography
    plot(ds, -pres(maxd), '.');
    fill([ds(1); ds(ns); ds(ns:-1:1)], ...
         [d1;    d1;  -botd(ns:-1:1)], 'w');
    hold on;

    % Label and Timestamp plot
    axes('position',[0 0 1 1])
    axis off
    Label = sprintf('Cruise: %s   Pair Property: %s   \n',cruise,pname);
    text(.01,.02,Label)
    Time = sprintf('    %i/%i/%i -  %i:%i:%i',fix(clock));
    text(.7,.02,Time)

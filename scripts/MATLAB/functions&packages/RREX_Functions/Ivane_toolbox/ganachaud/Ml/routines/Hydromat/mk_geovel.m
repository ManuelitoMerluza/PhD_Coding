function [vel,area,tri_idx,maxd,ref_used] = mk_geovel(dyh,lat,lon,z,...
    ref_level,pr,tri_method,min_topo,bottom_topo)
%function [vel,area,tri_idx,maxd,ref_used] = mk_geovel(dyh,lat,lon,z,...
%    ref_level,pr,tri_method,min_topo,bottom_topo)
% 
% constructs geotrophic veolcity of a station pair of data
% allowing for observed bottom topography
%
%  dyh - 2 column array of dynamic height (in dyn-m) (each station in a column)
%  lat - 2 element vector of latitudes
%  lon - 2 element vector of longitude
%  z   - vector of values used to determine reference level (pressure or gamma)
%  ref_level - value to lookup up in z to determine revference_level
%  pr - vector of pressure corresponing to elements of duyh
%  tri_method - (opt) method of calculating velocity in bottom triangles
%                0 - no triangle velocities
%                1 - constant velocity below DCL
%                2 - constant shear below DCL (not implemented)
%  min_topo - (opt) use this value for intervening topography.  area below
%              this level is considered as bottom triangle
%  bottom_topo - (opt) a three column array [lat lon depth] for intervening
%              topogrphy (use station_topo to create)
%
%    returns
%        vel in m/s
%        area in m*m
%        tri_idx - vector with ones indicating location of bottom triangle
%        maxd - maximum depth of station pair (in meters)
%        ref_used - reference surface actually chosen
%
%copywrite Paul E. Robbins, 1995

z = z(:);
distance = sw_dist(lat, lon,'km')*1e3;
f = 2*7.292e-5*sin(mean(lat)*pi/180);

if ~isnan(ref_level) & ref_level <=  max(z)
  D0 = table1([z dyh],ref_level);
else
  D0 = [nan nan];
end
%

%find DCL
iDCL = sum(~any([isnan(dyh)]'));
DCL = z(iDCL);
%check to see if reference is below DCL
if any(isnan(D0))
  disp([' Input reference level ',num2str(ref_level),...
      ' too deep! : Using DCL of ',num2str(DCL)])
  ref_level = DCL;
  D0 = table1([z dyh],DCL);
end
ref_used = ref_level;

%check to see if reference is below the minimum intervening topography
if nargin > 7
  if DCL > min_topo
    disp([' Intervening topography! raising DCL from ',num2str(DCL),...
      ' to ',num2str(min_topo)])
    DCL = min_topo;
    iDCL = find(abs(z-DCL) == min(abs(z-DCL))); iDCL = iDCL(1);
  end
  if ref_level > min_topo
    disp([' Reference level ',num2str(ref_level),...
      ' deeper then intervening topography! : Using reference level ',...
        num2str(min_topo)])
    D0 = table1([z dyh],min_topo);
    ref_level = min_topo;
  end
end

% calculate dynamic height anomoly and geostrophic velocity
dha1 = dyh(:,1) - D0(1);
dha2 = dyh(:,2) - D0(2);
vel = -10*(dha2 - dha1)/(distance* f);

% calculate a depth of measurements
if nargin > 5
  d1 = sw_dpth(pr(:),lat(1)) + dyh(:,1)/.98;
  d2 = sw_dpth(pr(:),lat(2)) + dyh(:,2)/.98;
  maxd = max([max(d1(~isnan(d1))) max(d2(~isnan(d2)))]);
  % midpoints of measurements
  dm1 = filter(boxcar(2)/2,1,d1); dm1(1) = 0; % should start at sea surface
  dm2 = filter(boxcar(2)/2,1,d2); dm2(1) = 0;
  
  % depth intervals between measurements
  deld1 = diff(dm1);
  deld2 = diff(dm2);
    
  % add one more non-nan depth interval to bottom of cast
  dt = sum(~isnan(deld1)); 
  deld1 = [deld1(1:dt); deld1(dt) ; deld1(dt+1:length(deld1))];
  dt = sum(~isnan(deld2));
  deld2 = [deld2(1:dt); deld2(dt) ; deld2(dt+1:length(deld2))];
  area = [mean([deld1'; deld2'])*distance]';
end


%
% calculate a bottom triangle velocity
if nargin > 6
  tri_idx = 0*ones(length(vel),1); 	% index of where triangles are
  if tri_method ==0;
    disp([' Enforcing no transport in bottom triangle'])
    area(iDCL+1:length(area)) = 0*area(iDCL+1:length(area));
  elseif tri_method == 1
    % extrapolate on constant velocity
    disp([' Extrapolating constant velocity from DCL into bottom triangle'])
    vDCL = vel(iDCL);
    iDL = sum(any([~isnan(dyh)]'));
    ntri = iDL-iDCL;			% number of points in triangle
    if ntri > 0
      vel(iDCL+1:iDL) = vDCL*ones(ntri,1);
      tri_idx(iDCL+1:iDL) = ones(ntri,1);% index of where triangles aren
      % figure which cast is deeper
      if sum(~isnan(deld2)) > sum(~isnan(deld1))
	deltri = deld2;
	totd = d2;
      else
	deltri = deld1;
	totd = d1;
      end
      if nargin < 9
	% calculate a bottom triangle area assuming linear bottom topo between
	% deepest levels of each cast
	area(iDCL+1:iDL) = deltri(tri_idx).*[(ntri:-1:1)/ntri]'*distance;
      else
	% calculate the bottom triangle area based upon input topography
	% first fill in bottom as if a rectangle
 	disp([' Using ',num2str(size(bottom_topo,1)),...
	    ' intervening points to calculate bottom topography'])
	area(iDCL+1:iDL) = deltri(tri_idx)*distance;
	%
	%calculate the distances between successive soundings
	bottom_topo = [lat(1) lon(1) max(d1(~isnan(d1)));
	               bottom_topo;
		       lat(2) lon(2) max(d2(~isnan(d2)))];
	for d = 1:size(bottom_topo,1)-1
	  db(d) = sw_dist(bottom_topo([d d+1],1),bottom_topo([d d+1],2));
	end
	fdb = db/sum(db);          %fractional distance
	shallowest = min(bottom_topo(:,3)); % shallowist point
	ishal=find(abs(totd(~isnan(totd))-shallowest)== ...
	    min(abs(totd(~isnan(totd))-shallowest)));
	ishal = ishal(1);
	
	amsk = 0*ones(size(area));	% mask for areas
	amsk(1:ishal) = ones(ishal,1);
	for d = 1:size(bottom_topo,1)-1
	  % determine min and max of these two topo points
	  btmin = min(bottom_topo([d d+1],3));
	  btmax = max(bottom_topo([d d+1],3));
	  % determine indexes corresponding to min and max
	  i1=find(abs(totd(~isnan(totd))-btmin)==...
	      min(abs(totd(~isnan(totd))-btmin))); i1 = i1(1);
	  i2=find(abs(totd(~isnan(totd))-btmax)==...
	      min(abs(totd(~isnan(totd))-btmax))); i2 = i2(1);
	  amsk(ishal+1:i1) =amsk(ishal+1:i1)+ fdb(d)*ones(i1-ishal,1);
	  amsk(i1+1:i2) =   amsk(i1+1:i2) + ...
	     fdb(d)*ones([i2-i1],1).*[((i2-i1):-1:1)/(i2-i1)]';
	end	  
	
	% part added for mk_geovel4
	% use constant amsk to DCL or intervening topo;
	amsk(1:iDCL) = ones(iDCL,1);
	
	area = area.*amsk;
      end
    else
      disp(['Casts are same depth: no bottom triangle'])
    end
  end
end

% fill in zeros for nan's in area
area(isnan(area)) = 0*ones(sum(isnan(area)),1);
vel(isnan(vel)) = 0*ones(sum(isnan(vel)),1);

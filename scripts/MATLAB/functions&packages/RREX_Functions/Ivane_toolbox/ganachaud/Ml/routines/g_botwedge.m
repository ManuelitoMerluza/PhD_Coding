function [shp, pprop, dhp] = g_botwedge(method, p_plot, ipair, pname, punit, ...
    pres, shprop, lpshal, deprop, lpdeep, pprop, distg, slopmx)
%
% key: fill-in the bottom values for the shallow station
% synopsis: [shprop, pprop] = g_botwedge(method, p_plot, ipair, pname, punit, ...
%   pres, shprop, lpshal, deprop, lpdeep, pprop, distg)
% 
% property mean temperature, salinity, or any other quantity
%
% INPUT: 
%    method : 'pfit'  to fit a plane
%             'cstvel' to set them at the same value, same gradient if dynh
%             'cstslope' to set to constant slope (as in old geovel.f)
%    p_plot:  3-d plot of the result
%    ipair :  pair index
%    pname :  string, name of this property ('temp', 'sali', . , dynh ..)
%    punit :  string, unit of this property ('dcel', 'g/kg', ...)
%    pres  :  pressure(db)
%    shprop:  property(<idepth>) for the shallow station
%    lpshal:  deepest data index for the shallow station
%    deprop:  property(<idepth>) for the deep station
%    lpdeep:  deepest data index for the deep station
%    pprop :  mean property at the pair
%    ishdp :  ishdp(1) = shallow station index for pair 'ipair'
%             ishdp(2) = deep    station index for pair 'ipair'
%    distg :   = distance between the two stations
%
% OUTPUT: 
%    shp   :  same as input shprop, but the values below the bottom
%	       are filled by extrapolation			 
%	       that will be used to compute the geostrophic velocity
%	       (the value has no physical meaning)			 
%    prop   :  same as input pprop, but the values last shallow station
%	       are filled by extrapolation			 
%              it is the property data for each station pair
%    dhp   :  same as deprop, but might be put on the plane if
%             plane fit.
%
% LOCAL VARIABLES:
%    idtrig:  pressure indices for std depths at and below LCP, ie
%              from last common pres (lpshal) 
%              to   last 'deep' pres (lpdeep)
%
% TREATMENT:
%   LCD =  last common depth for the two stations
% 
%   method 'cstvel': set pprop = shprop = deprop
%     under LCD
%   
%   method 'pfit': fit a plane on the 'deprop' data under LCD (included)
%     and the 'shprop' data at LCD. 
%     Extrapolate shprop and pprop under LCD on that plane
% 
%   method 'polyfit': fit a polynomial on the 'deprop' data under LCD (included)
%     and the 'shprop' data at LCD. 
%     Extrapolate shprop and pprop under LCD on that plane
% 
%   method 'cstslope':
%					 
% USES :
%
% SIDE EFFECTS :
%
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , Oct 95
%
% UPDATES: Jan 96, D. Spiegel
%   Most of the Jan 96 updates are strictly cosmetic (comments, spacing)
%   The following are the only real differences:
%	'cstvel' replaces 'equal' for consistency with menu in g_hotpair
% 	slopmx is passed as a parameter to be used in cstslope section
% 	the entire cstslope section is new to recreate geovel.f o/p
% 	    xx = distg * (pres(idtrig(ndep)) - pres(idtrig(2:ndep-1))) / ...
%                        (pres(idtrig(ndep)) - pres(idtrig(1)));
%   Mar 97, A.Ganachaud
%   Tried to Change the Plane fit to polynomial fit:
%    t = ax + bz^2 + cz + d
%
%   Feb 98, A.Ganachaud: added the 'squeezeddeviation' method
%                        from Jean-Michel Pinot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% CALLER : geovel g_hotpair
% CALLEE : g_plotwedge
global Slat Slon
% fin depth indices to extrapolate
    % idtrig = pres indices from last common pres to last 'deep' pres:
    idtrig   = lpshal:lpdeep;

    % relDepth = pres relative to the last common pres:
    relpres    = pres(idtrig) - pres(lpshal) * ones(size(idtrig')); 

    % number of depth to treat:
    ndep = length(idtrig); 

if length(ipair)>1
  error('ipair must be 1x1')
end
if ~isstr(method)
  if method==1
    method='pfit';
  elseif method==2
    method='cstvel';
  elseif method==3
    error('not available')
  elseif method==4
    method='cstslope';
  elseif method==5
    method='polyfit';
  elseif method==6
    method='squeezeddeviation';
  else
    error('method not available')
  end    
end

shp = shprop;
if nargout==3
  dhp = deprop;
end

if ndep>1               %  the bottom is not at the same depth

  if strcmp(method, 'cstvel')
    % this pair is to fill with constant velocities under the deepest common depth
    % thus shprop = deprop for values to extrapolate:
    if strcmp(pname, 'dynh')|strcmp(pname, 'gpan')
      ddy = deprop(idtrig(1)) - shprop(idtrig(1));
    else
      ddy = 0;
    end
     
    shp  (idtrig(2:ndep)) = (-ddy)   + deprop(idtrig(2:ndep));
    %pprop(idtrig(2:ndep)) = (-ddy/2) + deprop(idtrig(2:ndep));
    %REMOVED BY ALEX JULY 97  AS COMPUTED AT THE END FURTHER
    disp (sprintf('%s :pair %3i set to zero gradient under %6i', ...
        pname, ipair, pres(idtrig(1))'))
 
  elseif strcmp(method, 'pfit')|strcmp(method, 'polyfit')
    % fit a polynimial to the triangular data:
    
    %A) PLANE
    E = zeros(ndep+1, 3);
                      % col1: x - distance from deep station (distg)
                      % col2: depth deviation from last common depth (LCD)
	              % col3: 1 (constant)
    E(:,3) = ones(ndep+1, 1);		
    
    % first row of E (for shallow station last measurement):

    E(1,1) = distg;
    % E(1,2) = 0;		% defined above
    % E(1,3) = 1;		% defined above
    
    % other rows of E (for deep station measurements at/below LCD):

    E(2:ndep+1, 2) = relpres;
    % E(2:ndep+1,1) = 0;	% defined above
    % E(2:ndep+1,3) = 1;	% defined above
    
    X=[distg * ones(ndep-1,1), relpres(2:ndep), ones(ndep-1,1)];
    XD=[zeros(ndep,1), relpres(1:ndep),ones(ndep,1)];
    %B) if enough data, fit a 2nd order in depth
    
    if (ndep>=3) & strcmp(method, 'polyfit')
      E=[E,[0;relpres.^2]];
      X=[X,relpres(2:ndep).^2];
      XD=[XD,relpres(1:ndep).^2];
    end
    
    % CHANGEMENT Tillys 2017/02/22
    shprop = shprop(:); deprop = deprop(:);
    
    % Y is the observed property for each row of E:
    Y = [shprop(idtrig(1)); deprop(idtrig)];
    
    % P will contain the three coefficients of the plane
    % (where E\Y calculates a least square fit): 
    P = E\Y;

    % thus for any (relative depth(d), distance from deep station(x))
    % a property p is on the polynomial if 
    % p(d,x) = P(1) * x + P(2) * d + P(3) + P(4) * d^2

    % fill in the values of shprop on this plane:
    shp(idtrig(2:ndep)) = X * P;
    
    % CHANGEMENT Tillys 2016/06/17
    shp = shp(:);
    coef = P;
    save coef coef
    save relpres relpres
    
    %fill in the values for dprop too
    if 0 % nargout==3
      disp('fill in the values for dprop too')
      dhp(idtrig)=XD * P;
    end
    
  elseif strcmp(method, 'cstslope')
    denom = (deprop(lpshal-1) - deprop(lpshal));
    eps = .0009;
    if (abs(denom) < eps) 
      disp(sprintf(...
	'at ipair %8i: denom= %8.4f < eps= %8.4f in g_botwedge cstslope',...
	ipair,denom,eps))
      if (denom == 0)
        denom = .001;
      else
        denom = sign(denom) * .001;
      end
    end

    slope = (deprop(lpshal)   - shprop(lpshal)) / denom;
    if(abs(slope) > slopmx)
      disp(sprintf('at ipair %8i:slope = %8.4f > slopmx = %8.4f, denom = %8.4f', ...
          ipair,slope,slopmx,denom));
      slope = sign(slope) * slopmx;
    end
              
    fac = (pres(lpshal) - pres(lpshal-1)) * ...
          (diff(pres(idtrig(1:ndep)))) .^(-1);
      
    shp(idtrig(2:ndep)) =  ...
                deprop(idtrig(2:ndep)) + slope * fac .* ...
           diff(deprop(idtrig(1:ndep)));

  elseif strcmp(method, 'squeezeddeviation')
    %the deep-shal difference decreases with depth (Jean-Michel)
    deltap=(shprop(lpshal)-deprop(lpshal))*...
      ((pres(lpdeep)-pres(idtrig(2:ndep)))/(pres(lpdeep)-pres(lpshal)));
    shp(idtrig(2:ndep))=deprop(idtrig(2:ndep))+deltap;
    %figure(10);clf;gid=1:lpdeep;
    %plot(deprop(gid),-pres(gid),'b-+',shp(gid),-pres(gid),...
    %  'r-',shp(idtrig),-pres(idtrig),'ro');
    %zoom on;ppause
  else
    error(['method ' method ' not available'])
  end
  
    % fill in the values of pprop on this plane
    % we use the bottom triangle, pprop =  weighted avg of deep/shallow:

    % calc distance weighted average below Deepest Common Depth
    xx = (pres(idtrig(ndep)) - pres(idtrig(2:ndep))) / ...
         (pres(idtrig(ndep)) - pres(idtrig(1)));

    pprop(idtrig(2:ndep)) = deprop(idtrig(2:ndep)) + ...
        0.5 * (( shp(idtrig(2:ndep))  - deprop(idtrig(2:ndep))) .* ...
         xx);

end % if ndep>1

if p_plot
  if ~exist('xx')
    xx=(pres(idtrig(ndep)) - pres(idtrig(2:ndep))) / ...
      (pres(idtrig(ndep)) - pres(idtrig(1)));
  end
  g_plotwedge(method, ipair, pres(idtrig), ...
      pname, punit, pprop(idtrig), xx, ...
      shp(idtrig), dhp(idtrig), ...
      distg, Slat(ipair), Slon(ipair))
  % NOTE:Slat(ipair) has not exact meaning (rather Slat(istat))
end

% see difference in E normalized


function [shp, dhp] = g_botwedge(method, ipair, pname, punit, ...
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
%             'polyfit'  to fit a 2nd order plane
%             'cstslope' to set to constant slope 

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
%              it is the property data for each station pair
%    dhp   :  same as deprop but put on the plane
%
% LOCAL VARIABLES:
%    idtrig:  pressure indices for std depths at and below LCP, ie
%              from last common pres (lpshal) 
%              to   last 'deep' pres (lpdeep)
%
% TREATMENT:
%   LCD =  last common depth for the two stations
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
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , Oct 95
% Change 10/2020 I. Salaün
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALL : g_plotwedge
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
 
shp = shprop;
dhp = deprop;

if ndep>1 %bottom triangle if the bottom is not at the same depth!
    
    if strcmp(method, 'pfit')|strcmp(method, 'polyfit') 
    % fit a polynimial to the triangular data:

    E = zeros(ndep+1, 3);
    % col1: x - distance from deep station (distg)
    % first row of E (for shallow station last measurement):
    E(1,1) = distg; 
    
    % col2: depth deviation from last common depth (LCD)
    % other rows of E (for deep station measurements at/below LCD):
    E(2:ndep+1, 2) = relpres;
    
	% col3: 1 (constant)
    E(:,3) = ones(ndep+1, 1);		
    
    X=[distg * ones(ndep-1,1), relpres(2:ndep), ones(ndep-1,1)];
    XD=[zeros(ndep,1), relpres(1:ndep),ones(ndep,1)];
    
    if (ndep>=3) & strcmp(method, 'polyfit') %fit a 2nd order in depth if enough data
      E=[E,[0;relpres.^2]];
      X=[X,relpres(2:ndep).^2];
      XD=[XD,relpres(1:ndep).^2];
    end
    
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

    disp('fill in the values for dprop too')
    dhp(idtrig)=XD * P; %fill in the values for dprop too
    
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

    else
    error(['method ' method ' not available'])
    end
  
end

end 



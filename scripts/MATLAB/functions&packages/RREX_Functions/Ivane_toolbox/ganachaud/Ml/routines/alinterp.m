function nprop=alinterp(oprop,opres,apres,w1,w2,wl1,wl2)
% KEY: Aitken-Lagrange interpolation, 2nd degree
% USAGE : nprop=alinterp(oprop,opres,apres,w1,w2,wl1,wl2)
%   try to find 3 data points near apres
%   uses the second degree polynomial through these data
%   to interpolate
%   If the interpolated values is outside the two enclosing
%   data points, uses linear interpolation.
%
% DESCRIPTION : 
%
%
% INPUT:
%   oprop,opres: data
%   apres: point to interpolate
%   w1,w2,wl1,wl2: windows limiting departure from point to data
%
% OUTPUT:
%
% AUTHOR : Original code: A. Macdonald
%    Interface to matlab: A.Ganachaud (ganacho@gulf.mit.edu) , Nov 97
%
% SIDE EFFECTS :
%
% SEE ALSO : alinterp.f for more details
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER:
% CALLEE: alinterpg.mexsol

%REMOVES NaN HEAD AND TAIL IN THE DATA
while ~isempty(oprop)&isnan(oprop(1))
  oprop=oprop(2:length(oprop));
  opres=opres(2:length(opres));
end
while ~isempty(oprop)&isnan(oprop(length(oprop)))
  oprop=oprop(1:length(oprop)-1);
  opres=opres(1:length(opres)-1);
end


gibad=find(isnan(oprop));
if size(oprop,1) ~=1 & size(oprop,2) ~=1 
  error('oprop must be a vector')
end
oprop(gibad)=-999;
if ~isempty(oprop)
  [nprop]=alinterpg(oprop,opres,apres,w1,w2,wl1,wl2);
else
  nprop=NaN*apres;
end
gnan=find(nprop==-999);
nprop(gnan)=NaN;

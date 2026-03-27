function [lprop] = integlay(lidep,lipropint,dep,ppropint,sdist,botdep)
% KEY:   integrate the property in each layer
% USAGE :
%  [lprop] = integlay(np,nl,nd,lidep,lipropint,dep,ppropint,sdist,botdep)
% 
%
% DESCRIPTION : 
%   integrate the property between layer interfaces, last
%   is the top to bottom one
%
%   Trapezoidal integration, takes the bottom triangle into account
%
% INPUT:
%   [np,nl]=size(lidep);
%   nd=size(Dep,1);
%
%   ip = pair indice
%   il = layer indice
%   id = std. depth indice
%   is = station indice
%
%   lidep(ip,il)     (m)  depth at layer interface
%   lipropint(ip,il)      property to integrate at layer interface
%   Dep(id,ip)       (m)  std. depth
%   ppropint(id,ip)       property to integrate, at std. depth
%   sdist(ip)        (km) distance between stations
%   Botdep(is)       (m)  bottom depth
%
% OUTPUT:
%
%   lprop(ip,il)     (m^2)*property : integrated property in layer 
%
%
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , April 97
%
% SIDE EFFECTS : Do not check if layer depth underneath bottom !
%                This allows elimination of triangles for 
%                model transports computation
% SEE ALSO : integ_lay.m
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%lidep (np,nl)                         real
%lipropint (np,nl)                     real
%dep (nd,np)                           real
%ppropint (nd,np)                      real
%sdist (np)                            real
%botdep (np+1)                         real
%lprop (np,nl)                         real
%
%
%Call the MEX function
%
  [np,nl]=size(lidep);   
  nd=size(dep,1);

  %CHECK IF ANY LAYER DEPTH IS UNDER BOTTOM
  pbotd=max([botdep(1:np)';botdep(2:np+1)'])';
  allpbot=pbotd*ones(1,nl);
  if any(find(lidep > allpbot))
    error('Pair depth below bottom !')
  end


 [lprop] = integlayg(lidep,lipropint,dep,...
 ppropint,sdist,botdep);
%

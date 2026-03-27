function [sigprop] = getsigprop(dep,prop,botdep,sigdep,gcm)
%
%
%[sigprop] = getsigprop(dep,prop,botdep,sigdep)
%
%description : 
% 
%  interpolates linearily the property prop to values along at
%  certain depths (following an isopycnal typically)
%  given by sigdep
%
%INPUTS
%  dep(nd)     :standard depths for the data
%  prop(nd,np)  :property to interpolate, for each pair
%  botdep(np)  :bottom depth for each pair
%
%  sigdep(np,nl):depth of the isopycnal for each pair, and
%                for each isopycnal layer
%
%OUTPUTS
%  sigprop(np,nl):interpolated property
%
%side effects : if we are outside the data range 
%               sigprop is linearily extrapolated
%
%author : A.Ganachaud, Nov 96
%             [NAGWare Gateway Generator]
%Copyright (c) 1993-94 by the Numerical Algorithms Group Ltd 2.0 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[nd,np]=size(prop);
if nd~=length(dep)
  error('nd~=length(dep)')
end
if any(dep < 0) | any(botdep<0) | any(sigdep<0)
  error('depth must be positive')
end
if np~=size(sigdep,1)
  error('sigdep and prop number of pair must agree')
end
nl=size(sigdep,2); %n layer
sigprop=-9999*ones(np,nl);
if ~exist('gcm')&any(sigdep>max(dep))
  error('sigma curve not within the standard depths range')
end
%
%Call the MEX function
%
% [sigprop] = getsigpropg(nd,np,dep,prop,botdep,nl,sigdep,...
% sigprop);
 [sigprop] = getsigpropg(dep,prop,botdep,sigdep,sigprop);
%

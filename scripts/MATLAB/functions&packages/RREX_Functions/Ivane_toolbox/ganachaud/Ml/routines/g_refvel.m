function grelvel=g_refvel(gvel,pres,Botp,rlpres)
% KEY: reference the velocity to the given level (rlpres)
% USAGE :
% 
%
%
%
% DESCRIPTION : 
%
%
% INPUT: 
%
%
% OUTPUT:
%
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , Jan 98
%
% SIDE EFFECTS :
%
% SEE ALSO :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER: geovel or general purpose
% CALLEE: getsigprop

Nstat=length(Botp);
if (size(rlpres,1)*size(rlpres,2))==1
  rlpres=rlpres*ones(Nstat-1,1);
end

ishdp = [1:Nstat-1; 2:Nstat];isw = find( diff(Botp) < 0 ); 
ishdp([1 2],isw) = ishdp([2 1],isw);
Pbotp=Botp(ishdp(2,:));

%find the Last common depth
limitdep=Botp(ishdp(1,:));
gis_at_bot=find(rlpres>limitdep);
rlpres(gis_at_bot)=limitdep(gis_at_bot);

% R.L.VELOCITY
rlgv= getsigprop(pres,gvel,Pbotp,rlpres);

% RELATIVE VELOCITY IN CM/S
Ndep=size(gvel,1);
grelvel=(gvel-ones(Ndep,1)*(rlgv')); %in cm/s

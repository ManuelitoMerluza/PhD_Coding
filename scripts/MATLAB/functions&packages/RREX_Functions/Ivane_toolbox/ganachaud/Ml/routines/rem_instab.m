function [rho,strlog]=rem_instab(rho);
% KEY: remove static instabilities from a density field
% USAGE :
% 
%
%
%
% DESCRIPTION : 
%
%
% INPUT: rho: M(depth)*N(location) field
%
% OUTPUT:rho: stable field
%        strlog: string with report of routine
%
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , Jul 97
%
% SIDE EFFECTS :
%
% SEE ALSO :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER:
% CALLEE:
Ndep=size(rho,1);
strlog=[];

for ip=1:size(rho,2);
  giunstable=find(diff(rho(:,ip))<0);
  if ~isempty(giunstable)
    str=sprintf(['**************************************\n', ...
	'STATIC INSTABILITY DETECTED PAIR %i\n'],ip);
    strlog=[strlog, str]; disp(str);
  end    
  while ~isempty(giunstable)
    
    ifst=min(giunstable);
    drho=rho(ifst+1,ip)-rho(ifst,ip)-0.0001;
    rho(ifst+1,ip)=rho(ifst+1,ip)-drho;
    str=sprintf('add %g to depth %i\n',-drho,ifst+1);
    strlog=[strlog, str]; disp(str);
    
    giunstable=find(diff(rho(:,ip))<0);
  end
end 
 
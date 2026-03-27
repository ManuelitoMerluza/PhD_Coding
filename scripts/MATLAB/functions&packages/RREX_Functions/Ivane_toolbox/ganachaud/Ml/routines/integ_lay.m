function lprop=integ_lay(lidep,lipropint,Dep,ppropint,sdist,Botdep)
% KEY:   integrate the property in each layer
% USAGE :
% 
%
% DESCRIPTION : 
%   integrate the property between layer interfaces, last
%   is the top to bottom one
%
%   Trapezoidal integration, takes the bottom triangle into account
%
% INPUT:
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
%   lprop(ip.il)     (m^2)*property : integrated property in layer 
%
%
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , April 97
%
% SIDE EFFECTS :
%
% SEE ALSO :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER:
% CALLEE:
[np,nl]=size(lidep);
nd=size(Dep,1);

% LOOP OVER LAYERS
for il=1:nl
  %DEFINE INDICES FOR TOP/BOTTOM INTERFACE
  if il<nl
    ltop=il;
    lbot=il+1;
  else %last is top to bottom
    ltop=1;
    lbot=nl;
  end
  
  %LOOP OVER PAIRS
  for ip=1:np
    laydepth=lidep(ip,lbot)-lidep(ip,ltop);
    if laydepth<1e-6
      lprop(ip,il)=0;
    else
      deep=max([Botdep(ip),Botdep(ip+1)]);
      shallow=min([Botdep(ip),Botdep(ip+1)]);
      if deep==shallow
	dratio=NaN
      else
	dratio=1e3*sdist(ip)/(deep-shallow);
      end
      
      %IDEP WILL BE THE NUMBER OF DEPTH OVER WHICH THE INTEGRATION
      %IS MADE = 1 (top interface)+ 1(bot.int.) + number of std.
      %depths between top and bot interfaces 
      idep=1;
      linteg=[];
      zinteg=[];
      
      %SET INTEGRAND AT TOP OF LAYER
      if lidep(ip,ltop)>shallow
	ldist=dratio*(deep-lidep(ip,ltop));
      else
	ldist=1e3*sdist(ip);
      end
       %INTEGRAND
      linteg(idep)=ldist*lipropint(ip,ltop); 
      zinteg(idep)=lidep(ip,ltop);
      
      %SET INTEGRAND IN THE INTERMEDIATE STANDART DEPTHS
      gid=find( (Dep(:,ip)>lidep(ip,ltop)) & ...
	(Dep(:,ip)<lidep(ip,lbot)) );
      for iid=1:length(gid)
	id=gid(iid);
	idep=idep+1;
	if Dep(id,ip)>shallow
	  ldist=dratio*(deep-Dep(id,ip));
	else
	  ldist=1e3*sdist(ip);
	end
	linteg(idep)=ldist*ppropint(id,ip);
	zinteg(idep)=Dep(id,ip);
      end %on id
      
      %SET INTEGRAND AT BOTTOM OF LAYER
      idep=idep+1;
      if lidep(ip,lbot)>shallow
	ldist=dratio*(deep-lidep(ip,lbot));
      else
	ldist=1e3*sdist(ip);
      end
      linteg(idep)=ldist*lipropint(ip,lbot);
      zinteg(idep)=lidep(ip,lbot);
      
      %DO THE INTEGRATION FOR THIS LAYER, THIS PAIR
      lprop(ip,il)=trapz(zinteg,linteg);
    end %if laydepth<1e-6
  end %loop on ip
  
end %loop on nl

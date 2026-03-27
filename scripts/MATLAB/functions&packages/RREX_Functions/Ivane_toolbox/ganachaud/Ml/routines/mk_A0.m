function A0=mk_A0(p_trig,MPres,Dep,Botd,Slat,Slon,temp,Maxd,Maxdp,Npair)
% KEY: builds the integrating matrix containing for each (depth,pair)
%      the area of the corresponding cell
% USAGE :
% 
%
%
%
% DESCRIPTION : 
%   
%
% INPUT:
%    p_trig: if 1, shave the cells with a triangle. 
%            if 0, consider full distance down to pair bottom
%            (maximum depth for the two stations)
%            if -1, puts zero in the triangle
%    MPres:
%    Dep : depth level
%
%
%
%
%
% OUTPUT:
%  A0: area in each bin in meters^2
%
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , Mar 97
%
% SIDE EFFECTS : Triangle stuff controlled as well as possible
%                but no absolute tests for some limiting cases.
%
% SEE ALSO :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER:
% CALLEE:

%1-CREATE ROUGH MATRIX (without triangles)
np=MPres(1);
pshift=[0;0.5*(Dep(1:np-1)+Dep(2:np))];
pbin=[diff(pshift);(max(Botd)-pshift(np))];
sdist=1000*sw_dist(Slat,Slon,'km')';
A0=pbin*sdist;

%REMOVE DRY POINTS
gidry=find(isnan(temp));
A0(gidry)=zeros(size(gidry));

%2-COMPUTE TRIANGLE AREAS
if p_trig
  dDep=abs(Botd(1:Npair)-Botd(2:Npair+1));
  %before last common depth (LCD)
  for ip=1:Npair
    ilcd=min(Maxd(ip:ip+1,1));
    dbot=max(Botd(ip:ip+1));
    sbot=min(Botd(ip:ip+1));
    go=0;
    if ilcd ~=np
      if dbot<Dep(ilcd+1)
	go=1;
      end
    end
    if (ilcd==np)|go
      A0(ilcd,ip)=sdist(ip)*(sbot+dbot-2*pshift(ilcd))/2;
    else
      if dDep(ip)~=0
	if p_trig==-1
	  flag=0;
	else
	  flag=1;
	end
	%1-treat the trapezes within the triangles
	for id=ilcd+1:(Maxdp(ip,1)-1)
	  A0(id,ip)=flag*pbin(id)*...
	    sdist(ip)/dDep(ip)*0.5*(-pshift(id+1)-pshift(id)+2*dbot);
	end
	%last trapeze is a triangle with deep bottom
	A0(Maxdp(ip,1),ip)=flag*0.5*(dbot-pshift(Maxdp(ip,1)))*...
	  sdist(ip)/dDep(ip)*(dbot-pshift(Maxdp(ip,1)));
	
	%2-corrects the problem near LCD
	if sbot<pshift(ilcd+1)
	  A0(ilcd,ip)=sdist(ip)*(sbot-pshift(ilcd)) +...
	    (pshift(ilcd+1)-sbot)*...
	    0.5*sdist(ip)/dDep(ip)*(2*dbot-sbot-pshift(ilcd+1));
	else
	  if (ilcd+2)<Maxdp(ip,1)
	    p1=pshift(ilcd+2);
	  else
	    p1=dbot;
	  end
	  A0(ilcd+1,ip)=flag*sdist(ip)*(sbot-pshift(ilcd+1))+...
	    (p1-sbot)*...
	    0.5*sdist(ip)/dDep(ip)*(2*dbot-sbot-p1);
	end %if sbot<pshift(ilcd+1)
	
      end %if ilcd~=np
    end %if dDep(ip)~=0
  end %on each pair
  
end %if p_trig  
  
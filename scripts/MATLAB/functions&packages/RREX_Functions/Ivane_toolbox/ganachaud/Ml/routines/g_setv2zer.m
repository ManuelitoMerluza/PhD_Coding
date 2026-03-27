% script g_setv2zer 
%key: set velocity shear to zero under LCD
%synopsis : g_setv2zer
% 
% I/O : s_temp(:,ihp), .., p_temp(:,ihp), ...
%       gvel(:,ihp)
%
%description : 
%
%re-run bottom wedge and g_gvel only on that particular pair 'ihp'
% ihp, all horizontal gradients are set to  zero under LCD
% dyn. hgt difference is constant
%
%uses :
%
%side effects :
%
%author : A.Ganachaud (ganacho@gulf.mit.edu) , Oct 95
%
%see also : geovel.m
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% all the routine concerns only one pair, 'ihp'
% set the gradient for each property to zero

for iprop=1:Nprop
  eval(['prop=' Propnm(iprop,:) '(:,ishdp(:,ihp));'])
  shprop=prop(:,1);
  deprop=prop(:,2);
  pname=Propnm(iprop,:);
  punit=Propunits(iprop,:);
  pprop=0.5*(shprop+deprop);
  [shprop,pprop,deprop]=g_botwedge('equal',0,ihp,pname,punit,Pres,Maxd(:,iprop),shprop, ...
    deprop,pprop,ishdp(:,ihp),distg(ihp));
  
  eval(['s_' Propnm(iprop,:) '(:,ihp)=shprop;'])
  eval(['p_' Propnm(iprop,:) '(:,ihp)=pprop;'])
end %on iprop

%calculates the geost. velocity
gvel(:,ihp)=g_gvel(plat(ihp),distg(ihp),signp(ihp),Pres, ...
  1,s_dynh(:,ihp),d_dynh(:,ihp));

%add the ihp indice to ip2z

if length(ip2z)>1
  if ip2z(length(ip2z))~=ihp
    ip2z=[ip2z;ihp]; %men=0;
  end
end

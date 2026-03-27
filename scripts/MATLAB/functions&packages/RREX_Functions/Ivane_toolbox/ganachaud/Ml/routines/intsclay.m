function intsclay(gvel)
% KEY:    integrate transport within isopycnal layers
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
% OUTPUT:
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

%SIGMA INTERFACES DEFINITION, NORTH ATLANTIC
sigint= [22.00 26.40 26.80 27.10 27.30 27.50 27.70, ...
    36.87 36.94 36.98 37.02, ...
    45.81 45.85 45.87 45.895 45.91 45.925 48.00]';
     
sigipref=[ 1 1 1 1 1 1 1, ...
    2 2 2 2,...
    3 3 3 3 3 3 3]';

pref=[0 2000 4000]; %DB

[psigint]=find_sig_interface(sigint,sigipref, ...
  pref,temp,sali,Pres,Maxdp(:,Itemp),Pdep);

%sigpres=sigsurf(isig,:)';
[sigvel] = getsigprop(Pres,gvel,Pdep,sigsurf');
hold on;
pl2=plot(Plon,-sigsurf,'.');
grid on
ll=legend([pl1;pl2],'find_sig_interface','laybound');
title(secid)
set(gcf,'paperor','land')
setlargefig

%PLOT USING CONTOURS

for ipref=1:max(sigipref)
  disp(sprintf('reference pressure = %i db',pref(ipref)))
  %get the sigma indices for this reference pressure
  gipref=find(sigipref==ipref);
  
  %get sigmas relative to that pressure reference over the whole section
  sig_curpref = -1000+sw_pden(sali,temp,Pres,pref(ipref));
  hold on
  [cc,hh]=extcontour(Plon,-Pres,sig_curpref,sigint(gipref),...
    'b:','label','fontsize',6); 
end %ipref=1:max(sigipref)


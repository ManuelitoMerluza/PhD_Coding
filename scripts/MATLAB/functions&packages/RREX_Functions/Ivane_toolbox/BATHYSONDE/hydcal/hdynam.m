% -----------------------------------------------------------------
%
      function [hdy, iref, dist] =  hdynam0(pres, sig, sig35, pref)

% -----------------------------------------------------------------
%
%  Calcul de hauteur dynamique
%
%     input : 
%     ------   
%        pres    : tableau des pressions (db)
%        sig  : tableau des anomalies de densite in situ (kg/m**3)
%        sig35 :  tableau des anomalies de densite in situ 
%                pour t = 0 et s = 35 (kg/m*3)
%       pref : reference pressure. If pres(n) < pref, pref = pres(n)
%  
%     output : 
%     ------   
%        hdy  : tableau des hauteurs dynamiques en mdyn (10J/kg)
%        iref : reference level effectively used 
%        dist : distance pres(iref) to pref
% 
%  version:
%  --------
%  original fortran: Fevrier 90 D.Jacolot
%           15/09/1992    C.Lagadec
%  matlab  janv.99  C.Lagadec
%  5.2      28/06/2010  F.Gaillard
%                                            
%--------------------------------------------------------------------------

[n1,n2] = size(pres);
n = max(n1,n2);

dsi   = sig - sig35;
sisum = 1000.0 + sig + sig35 + sig.*sig35*0.001;
fi    = dsi./sisum;
fiave = (fi(2:n) + fi(1:n-1))*0.5;
dp    =  pres(1:n-1) - pres(2:n);
delta = fiave.*dp;
if n2>n1
    delta = delta';
end

hdy = nan*ones(n,1);

xpr  = min(pres(n),pref);

% suppression de abs dans le test(C. Lagadec - Juillet 2010)
% ----------------------------------------------------------

%[dist,iref] = min(abs(pres-xpr));

[dist,iref] = min(pres-xpr);

% modification du test sur iref (dist)
if dist < 0, return, end


hdy(iref) = 0.;
hdy(iref+1:n) = -cumsum(delta(iref:n-1));
hdy(1:iref-1) = flipud(cumsum(flipud(delta(1:iref-1))));

if n2>n1
    hdy = hdy';
end



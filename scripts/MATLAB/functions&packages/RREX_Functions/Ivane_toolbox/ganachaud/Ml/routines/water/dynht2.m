function [dh, delta] =dynht2(p,t,s,pref)
% function [dh,delta] =dynht2(p,t,s,pref)
%
% dynamic height [dynamic m = 10 m**2/s**2] referenced to 'pref'
% units:
%       reference press pref     decibars
%       pressure        p        decibars
%       temperature     t        deg celsius (ipts-68)
%       salinity        s        psu (ipss-78)
%        delta          spec. vol. anomaly  dimensionless
% r. schlitzer  (5/18/89) modified by c. wunsch 2/2/90
  %%(replaced loop by cumsum operation for speed) and
   %%returns specific volume anomaly -delta
xmiss=-1; n=max(find(t~=xmiss)); id=find(p==pref);
if length(id)==0, fprintf('dynht: no data at pref= %g\n',pref), end
delta=eos80(p,t,s)-v350p(p); dp=p(2:n)-p(1:n-1);
mdel=(delta(1:n-1)+delta(2:n))/2; dh=zeros(n-1,1);
 dh=-cumsum(dp.*mdel); dh=[0;dh];   %%minus sign because of direction of
 %%integration; 0 for surface value
  dh=dh-dh(id);

function [sprop,sflag,istatdeep]=g_horiz_extrap(prop,ishdp,ipair,Slat, Slon)
% KEY: horizontal property extrapolation
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
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , Jan 98
%
% SIDE EFFECTS :
%
% SEE ALSO :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER:
% CALLEE: geovel routines

%shallow station indice
iss=ishdp(1,ipair);
sprop=prop(:,iss);

%deep station indice
isd=ishdp(2,ipair);

%indice of the third station used for extrapolation
%(on the deep station side)
if (isd-iss)==1
  is2=isd+1;
elseif (isd-iss)==-1
  is2=isd-1;
else
  error('problem with ishdp !')
end

if nargout==3
  istatdeep=is2;
end
%stop if we hit the limits
if is2<1 | is2 > length(Slat) 
  sflag=0;
  if nargout==3
    istatdeep=[];
  end
  return
end

d1=sw_dist(Slat([iss,isd]),Slon([iss,isd]),'km');
d2=sw_dist(Slat([isd,is2]),Slon([isd,is2]),'km');

%flag if the ratio of the distances is small
if d2<(d1/2)
  sflag=1;
else
  sflag=0;
end

%indices of depths under LCD
gi2fill=(max(find(~isnan(sprop)))+1):...
  min(size(sprop,1),max(find(~isnan(prop(:,isd))))+1);
if isempty(gi2fill)
  sflag=0;
  return
end

%extrapolation
slopes=(prop(gi2fill,isd)-prop(gi2fill,is2))/d2;
ind_nan=find(isnan(slopes)==1);
slopes = slopes(1:ind_nan-1); gi2fill = gi2fill(1:ind_nan-1);
sprop(gi2fill)=prop(gi2fill,isd)+d1*slopes; 

%contour(prop(:,sort([iss,is2])),[0:0.5:40],'r');
%hold on;[c,h]=contour(prop(:,sort([iss,is2])),[0:0.5:40],'b');
%clabel(c,h)
if 0
  figure(16);clf
  plot(sprop,'r-o')
  hold on;plot(prop(:,iss),'b-+');
  set(gca,'xlim',[1 max(gi2fill)])
  plot(prop(:,isd),'g+');
  plot(prop(:,is2),'md');
  zoom on
  ppause
end
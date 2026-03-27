function [wcolor]=water_id(T,S,p_graph)
% KEY: give the identity of the watermass
%  
% USAGE :  [wcolor]=water_id(T,S,p_graph)
%          chdl=pcolor(pdist,-Pres,wcolor); 
%          set(chdl,'MeshStyle','column');
%          caxis([1 64]) % DO NOT FORGET !!
%          shade_topo(sdist,Botd,.5);
%  
% INPUT: 
%  
%   T=temperature
%   S=salinity
%   p_graph -> plots the ID color code if 1
%   
% OUTPUT:
%
%   wcolor: jet color indice, 1 to 64
%
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , Nov 96
%
% SIDE EFFECTS :
%
% SEE ALSO :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER:
% CALLEE:
p_test=0;

tmin=-2;
tmax=20;
smin=33.5;
smax=36.5;
if p_test
  t=tmin:(tmax-tmin)/200:tmax;
  s=smin:(smax-smin)/200:smax;
  [S,T]=meshgrid(s,t);
end

% WATER IDENTITY DEFINITIONS
wstr=['nadw';'aabw';'aaiw';'medd'];

%S1,S2,T1,T2
wcore=[...
    34.88,35   , 2  , 4   ;...
    34.4 ,34.8 ,-2  , 0   ;...
    34.2 ,34.3,  2  , 4   ;...
    36   ,37  , 10  ,12   ]';
%DEVIATION (%) FROM THE CORE (CATCHMENT AREA)
devcore=[.5 .5 .5 .1];
colormap(jet(64));
cm=jet(64);
%wcolorscale=([5 10 15 20]);
wcolorscale=(2+[12 20 35 60]);

nw=size(wcore,2);

waterid=zeros(size(S));
wcolor=NaN*ones(size(S));
for iw=1:nw
    ds=devcore(iw)*(wcore(2,iw)-wcore(1,iw));
    dt=devcore(iw)*(wcore(4,iw)-wcore(3,iw));
    iwsd=find((S>(-ds+wcore(1,iw)))...
      &(S<(ds+wcore(2,iw)))...
      &(T>(-dt+wcore(3,iw)))...
      &(T<(dt+wcore(4,iw))));
    iws=find((S>wcore(1,iw))...
      &(S<wcore(2,iw))...
      &(T>wcore(3,iw))...
      &(T<wcore(4,iw)));
    waterid(iwsd)=(iw+100)*ones(size(iwsd));
    wcolor(iwsd)=(wcolorscale(iw)-5)*ones(size(iwsd));
    waterid(iws)=iw*ones(size(iws));
    wcolor(iws)=(wcolorscale(iw))*ones(size(iws));
end
if p_test
  pcolor(S,T,wcolor); caxis([1 64])
  axis([smin smax tmin tmax]);grid on
  xlabel('salinity');ylabel('temperature');title('water identification')
end

if p_graph
  figure(gcf+1)
  for iw=1:nw
    ds=devcore(iw)*(wcore(2,iw)-wcore(1,iw));
    dt=devcore(iw)*(wcore(4,iw)-wcore(3,iw));
    sqxd=[-ds+wcore(1,iw);ds+wcore(2,iw);ds+wcore(2,iw);-ds+wcore(1,iw)];
    sqyd=[-dt+wcore(3,iw);-dt+wcore(3,iw);dt+wcore(4,iw);dt+wcore(4,iw)];
    hdld=fill(sqxd,sqyd,cm(wcolorscale(iw)-5,:));hold on
    sqx=[wcore(1:2,iw);wcore(2:-1:1,iw)];
    sqy=[wcore(3,iw);wcore(3,iw);wcore(4,iw);wcore(4,iw)];
    hdl=fill(sqx,sqy,cm(wcolorscale(iw),:));hold on
    hdltxt=text(  wcore(1,iw), wcore(4,iw)+dt, wstr(iw,:),...
      'verticalalig','bottom');
  end
  hold off
  axis([smin smax tmin tmax]);grid on
  xlabel('salinity');ylabel('temperature');title('water identification')
  figure(gcf-1)
end
caxis([1 64])


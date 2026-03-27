function [laybsec,laysec]=laybound(Slat,Slon,lidep,larea,liprop,lprop,...
lprop2)
% KEY: computes properties at layer boundaries
% USAGE : [laybsec,laysec]=laybound(Slat,Slon,lidep,larea,liprop,lprop,...
%   lprop2)
%
% DESCRIPTION : 
%  the property average/sum/std. deviation and interface
%  length are computed at the lower boundary of each
%  layer, whether it is the isopycnal or the bottom
%
%  last layer is top to bottom - last interface is NOT bottom
%
%  NO TRIANGLE in layer interface integrations
%
% INPUT:
%  Slat,Slon: station positions
%   ip=pair indice; il=layer indice 
%  lidep(ip,il) : interface depth in meters
%  larea(ip,il) : area of integration in each bin
%  liprop(ip,il): property at layer interface
%  lprop(ip,il): integrated property in layer
%  lprop2(ip,il): integrated property^2 in layer
%
% OUTPUT:
%  ALL ARE (il)
%  1)INTERFACE (BOUNDARY) INFORMATION
%  laybsec.litotdist  total interface distance
%  laybsec.lisumprop  integral of property
%  laybsec.lisumprop2 integral of property^2
%  laybsec.liavgprop  average prop along interface
%  laybsec.listdprop  std. dev. of prop along interface
%  laybsec.lisumdCdz  integral of vertical derivatives
%  laybsec.liavgdCdz  average vertical derivative
%
%laysec.lavgwdth     avg. width of layer (depth)
%  laysec.lverarea     vertical area of layer
%  laysec.lsumprop     integral of property over the layer
%  laysec.lsumprop2    integral of prop^2 over the layer
%  laysec.lavgprop     average prop over the layer
%  laysec.lstdprop     std. dev. of prop over the layer
%
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , Jul 97
%
% SIDE EFFECTS :
%
% SEE ALSO : interlay, get_*
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER:
% CALLEE:
  
[Npair,Nlay]=size(lidep);
sdist=1000*sw_dist(Slat,Slon,'km');

%FILL THE MASK FOR ELIMINATING POINTS WHERE BOTTOM IS ABOVE THE
%UPPER INTERFACE OF THE LAYER (is-layer-bottom-interface)

islaybot=ones(Npair,Nlay-1);
giz=find(diff(lidep')'<0.01);
islaybot(giz)=zeros(size(giz));
islaybot=[ones(Npair,1),islaybot]; %surface boundary

litotdist=sum(islaybot.*(sdist*ones(1,Nlay)));

ginullint=find(~litotdist);
litotdist(ginullint)=1e20*ones(size(ginullint)); %avoid division by zero

%INTEGRALS FOR INTERFACES
lisumprop=sum((sdist*ones(1,Nlay)).*liprop.*islaybot);
lisumprop2=sum((sdist*ones(1,Nlay)).*(liprop.^2).*islaybot);
liavgprop=lisumprop./litotdist;
listdprop=sqrt(lisumprop2./litotdist-liavgprop.^2);

%INTEGRAL FOR LAYERS
lverarea=sum(larea);
ginulllay=find(~lverarea);
lverarea(ginulllay)=1e20*ones(size(ginulllay));

%VERTICAL DERIVATIVE ESTIMATION:
%1- FOR EACH PAIR TAKE THE AVERAGE PROPERTY IN THE LAYER
%2- FOR EACH PAIR TAKE THE DIFFERENCE BETWEEN 2 AVERAGES / dh
%3- GET THE AVERAGE OF THE DERIVATIVES OVER THE INTERFACE LENGTH

%1-
ginull=find(~larea);
gigood=find( larea);
lavgprop_p=larea;%just to allocate...
lavgprop_p(gigood)=lprop(gigood)./larea(gigood);
lavgprop_p(ginull)=NaN;
%2-
%dh=(larea(:,1:Nlay-2)+larea(:,2:Nlay-1))/2./(sdist*ones(1,Nlay-2));
limiddledep=.5*(lidep(:,1:Nlay-1)+lidep(:,2:Nlay));
dh = diff(limiddledep(:,1:Nlay-1)')';
dh(~dh)=NaN;

lidCdz_p=-diff(lavgprop_p(:,1:Nlay-1)')'./dh;
lidCdz_p(~islaybot(:,3:Nlay))=0;
%3-
%lisumdCdz=sum((sdist*ones(1,Nlay-2)).*lidCdz_p.*islaybot(:,2:Nlay-1));
%CHANGE NOV 98: loop over the layers to separate outcropping regions
for il=1:Nlay-2
  gip=find(~isnan(lidCdz_p(:,il)));
  if length(gip)<length(sdist)
    disp(sprintf(...
      ['Laybond WARNING: interface %i dCdZ computed only '...
      'on non-outcroping part'],il));
  end
  if length(gip)==0 
    if any(isnan(lprop))
      error('Laybond WARNING: first layer outcropped: no dCdZ')
    end
    lisumdCdz(il)=NaN;
  else
    lisumdCdz(il)=sum(sdist(gip).*lidCdz_p(gip,il).*islaybot(gip,il+1));
  end
end
liavgdCdz=lisumdCdz./litotdist(2:Nlay-1);
ginullint1=find(~litotdist(2:Nlay-1));
lisumdCdz(ginullint1)=0;
liavgdCdz(ginullint1)=0;

%NEED ANOTHER VERTICAL AREA FOR COMPUTING MEAN DEPTH AS THE
% TOTAL LENGTH HERE DOES NOT TAKE TRIANGLES INTO ACCOUNT
lverarea2=sum((sdist*ones(1,Nlay-1)).*islaybot(:,2:Nlay).* ...
  (lidep(:,2:Nlay)-lidep(:,1:Nlay-1)));
lverarea2(Nlay)=sum(sdist.*(lidep(:,Nlay)-lidep(:,1)));
lavgwdth = lverarea2./[litotdist(2:Nlay),litotdist(1)];

lsumprop=sum(lprop);
lsumprop2=sum(lprop2);
lavgprop=lsumprop./lverarea;
lstdprop=sqrt(lsumprop2./lverarea - lavgprop.^2);

litotdist(ginullint)=0;
lverarea(ginulllay)=0;
lisumprop(ginullint)=0;
lisumprop2(ginullint)=0;
liavgprop(ginullint)=0;
listdprop(ginullint)=0;
lavgwdth(ginulllay)=0;
lsumprop(ginulllay)=0;
lsumprop2(ginulllay)=0;
lavgprop(ginulllay)=0;
lstdprop(ginulllay)=0;

laybsec.litotdist=litotdist;
laybsec.lisumprop=lisumprop;
laybsec.lisumprop2=lisumprop2;
laybsec.liavgprop=liavgprop;
laybsec.listdprop=listdprop;
laybsec.lisumdCdz=lisumdCdz(:);
laybsec.liavgdCdz=liavgdCdz(:);

laysec.lavgwdth=lavgwdth;
laysec.lverarea=lverarea;
laysec.lsumprop=lsumprop;
laysec.lsumprop2=lsumprop2;
laysec.lavgprop=lavgprop;
laysec.lstdprop=lstdprop;


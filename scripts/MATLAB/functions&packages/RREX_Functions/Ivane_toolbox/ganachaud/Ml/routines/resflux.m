% change c8 and c10 to 1,1,1 and c9 to .8,.8,.8
s='RUN B';
% cp=[1,0.4,0.5]; cn=[0.6,0.8,1];
cp=[0,0,0]; cn=[0.9,0.9,0.9];
s1='Initial surface heat gain (W/m**2)';
s2='Initial P-E (mm/month)';
load flux.STDYMASSPG4
hf=flux(:,1); hf=reshape(hf,62,39)';
sf=flux(:,2); sf=reshape(sf,62,39)';
tx=flux(:,3); tx=reshape(tx,62,39)';
ty=flux(:,4); ty=reshape(ty,62,39)';

load topo.ts
I=find(topo==0);
tx(I)=NaN*ones(length(I),1);
ty(I)=NaN*ones(length(I),1);
hf(I)=NaN*ones(length(I),1);
sf(I)=NaN*ones(length(I),1);
ysec=365.25*86400.; fy=0.035/ysec*1.2;
Cp=4.18*10^7; fx=1000/Cp;
hf=hf/fx; sf=sf/fy/(-1.0);

[x,y]=meshgrid(29:1.5:120.5,-31:1.5:26);
load /data20/tlee/shavano/fluxic
tx0(I)=NaN*ones(length(I),1);
ty0(I)=NaN*ones(length(I),1);
hf0(I)=NaN*ones(length(I),1);
sf0(I)=NaN*ones(length(I),1);

dhf=(hf-hf0); dsf=(sf-sf0); dtx=(tx-tx0); dty=(ty-ty0);
d1=hf; d2=sf;

subplot(211);
[C,H]=extcontour(x,y,d1,[-200,0,200],'fill');  % for hf and sf
n=length(H);
for i=1:n,
 if get(H(i),'CData')<0,
   set(H(i),'Facecolor',cn);
 else
   set(H(i),'Facecolor',cp);
 end
end
axis([29,122,-31,27]);  hold on
vp=[10:10:200]; vn=-vp;
extcontour(x,y,d1,vp,'label',110,'-w');
extcontour(x,y,d1,vn,'label',110,'--w');
title(s1)
xlabel('Longitude'); ylabel('Latitude');
% text(110,38,s);

I=find(topo>0); topo(I)=ones(length(I),1);
c=contour(x,y,topo,[1,1]);
xb=c(1,:); yb=c(2,:); 
I=find(xb>29); xb=xb(I); yb=yb(I);
h=line(xb,yb); set(h,'linewidth',3);

pa=subplot(211);

subplot(212);
[CS,H]=extcontour(x,y,d2,[-200,0,200],'fill');
n=length(H);
for i=1:n,
 if get(H(i),'CData')<0,
   set(H(i),'Facecolor',cn);
 else
   set(H(i),'Facecolor',cp);
 end
end
axis([29,122,-31,27]);  hold on
vp=[20:20:200]; vn=-vp;
extcontour(x,y,d2,vp,'label',110,'-w');
axis([29,121,-31,26]);  hold on
extcontour(x,y,d2,vn,'label',110,'--w');
title(s2)
xlabel('Longitude'); ylabel('Latitude');
h=line(xb,yb); set(h,'linewidth',3);

pb=subplot(212);

set(pa,'position',[0.15,0.54,0.68,0.35])
set(pb,'position',[0.15,0.12,0.68,0.35])
set(gcf,'paperposition',[0.1,0.1,8.5,11])

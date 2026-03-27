%script to text the function getsigprop
% A. Ganachaud, Nov 1996

%one interpolation:
dep=[0 500 1000 2000]';
prop=dep;
botdep=1000;

sigdep=2000;

[sigprop] = getsigprop(dep,prop,botdep,sigdep)

%one surface data:
dep=[1 2 3]';
prop=10+dep;
botdep=2;

sigdep=4;

[sigprop] = getsigprop(dep,prop,botdep,sigdep)

plot(prop,-dep,'-',prop,-dep,'+')
hold on
plot(sigprop,-sigdep,'ro')
hold off

%REAL DATA
path(path,'/data4/ganacho/HYDROSYS')
secid='a36n'; secrelindice='4'; ylim=[-7000,0];isig=12;
datadir='/data1/ganacho/HDATA/';
getpdat

whitebg

load /data1/ganacho/LAYBOUND/natl/matlab.mat
eval(['sigsurf=SIGPR_' secrelindice ';' ])

%sigdep=sigsurf(isig,:)';
[sigvel] = getsigprop(Pres,gvel,Pdep,sigsurf');


gvelref=ones(size(gvel,1),1)*(sigvel(:,isig)')-gvel;

[cs, h] = extcontour(Plon,-Pres,gvelref,[-1000 0], 'fill');
cn = .9*[1 1 1];
for i = 1:length(h)
  if get(h(i), 'CData') < 0
    set(h(i), 'FaceColor', cn)
  else
    set(h(i), 'FaceColor', 'w')
  end
end
hold on
[cs, h] = extcontour(Plon,-Pres,gvelref,-200:10:200,'label',...
  'fontsize',6,'linewith',0.2);
plts=plot(Plon,-sigsurf(isig,:),'b:');
shade_topo(Slon,Botd,.5);
set(gcf,'papero','land')
setlargefig

i2s=30:60;
i2s=1:100
surf(Plon(i2s),-Pres,gvelref(:,i2s))
%set(gca,'xlim',[-50 -30])
set(gca,'ylim',[-6000 0])
set(gca,'zlim',[-100 100])
xlabel('longitude');ylabel('depth');zlabel('velocity');title(secid)
set(gcf,'papero','land')
setlargefig


% Jan 97

%GET NEUTRAL SURFACES FOR A36N
p_contourall=0

path(path,'/data4/ganacho/HYDROSYS')
secid='a36n'; secrelindice='4'; ylim=[-6000,0];isig=12;
%secid='a24n'; secrelindice='2'; ylim=[-7000,0];isig=12;
datadir='/data1/ganacho/HDATA/';
getpdat

glevels = [22 26.44 26.85 27.162 27.38 27.62 27.82 27.922 27.975 28.008, ...
    28.044 28.072 28.0986 28.112 28.1295 28.141 28.154 48];

% ALISON'S (LAYBOUND) RESULTS
load /data1/ganacho/LAYBOUND/natl/natl_pltlay.mat
eval(['sigsurf=SIGPR_' secrelindice ';' ])

%computing (130 sec for a36n)
if exist([datadir secid 'gamman.mat'])==2
  eval(['load ' datadir secid 'gamman.mat'])
else
  tic;[gamn,dgl,dgh] = gamman(psali,ptemp,Pres,Plon,Plat);toc
  eval(['save ' datadir secid 'gamman.mat gamn dgl dgh'])
end

if p_contourall
  f1;clf
  cl1=[20:1:30];
  extcontour(Plon, -Pres,gamn, cl1, 'label','fontsize',6,'linewidth',2);
  hold on
  cl2=[20.5:1:30];
  extcontour(Plon, -Pres,gamn, cl2, 'label','fontsize',6,'linewidth',1);
  cl3=26.1:0.1:30;
  ir=find(2*cl3==floor(2*cl3));
  cl3(ir)=[];
  extcontour(Plon, -Pres,gamn, cl3, 'linewidth',.1);
  cl4=[27.8:0.01:30];
  ir=find(10*cl4==floor(10*cl4));
  cl4(ir)=[];
  extcontour(Plon, -Pres,gamn, cl4, ':','label','fontsize',6,'linewidth',.1);

  grid on;set(gca,'ylim',ylim)
  title([secid ' neutral density']);
  xlabel('longitude');ylabel('pressure (db)')
  refresh
  xlim=get(gca,'xlim');
  % ALISON'S (LAYBOUND) RESULTS
  hold on;
  pl2=plot(Plon,-sigsurf,'b.',Plon,-sigsurf,'b-');
 
  set(gcf,'paperor','land')
  setlargefig
  if 0
    print -P3
    eval(['print -depsc ' secid '_ns.epsc'])
    eval(['!lpr -h -Pcolor15 ' secid '_ns.epsc'])
  end
end %if p_contourall


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% FIND THE DEPTH OF THE INTERFACES
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%WITH MCDOUGAL METHOD (QUADRATIC)
f2;clf
g_pltopo(Nstat, Slon,Pres, Maxd(:,Itemp), Botd);
hold on;
[sns,tns,pns,dsns,dtns,dpns]=neutral_surf(psali,ptemp,Pres,gamn,glevels);
pl1=plot(Plon,-pns,'.');

%WITH OUR METHOD (LINEAR + BOTTOM CARE)
pns1 = getsigpres(Pres,Pdep,Maxdp(:,Itemp),gamn,glevels);
hold on
pl2=plot(Plon,-pns1);

% ALISON'S (LAYBOUND) RESULTS
pl3=plot(Plon,-sigsurf,'x','markersize',2);
set(gca,'ylim',ylim)
%set(gca,'xlim',xlim)
title(['neutral surfaces for ' secid])
legend([pl2(1);pl1(1);pl3(1)],'gamma, linear',...
  'gamma, quadratic','sigmas, linear')
hold off
set(gcf,'paperor','land')
setlargefig

eval(['print -deps ' secid '_sigoverns.epc'])

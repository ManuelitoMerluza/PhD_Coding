function bxi_plotres(ninit,ntilde,dn,N,signstr,ttl,pm)
% KEY: 
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
% CALLEE:
nlinemax=100;
nplots=ceil(length(ntilde)/nlinemax);

for iplot=1:nplots
  gir=(1+(iplot-1)*nlinemax):min(iplot*nlinemax,length(ntilde));
  figure(iplot);clf;
  set(gcf,'position',[50 50 500 800],'paperorientation','port')
  rwnorm=full(sqrt(diag(N(gir,gir))));
  nn=length(gir);

  pl1=plot(ntilde(gir)./rwnorm,1:nn,'o','linewidth',1.5);hold on;
  pl3=plot(ninit(gir)./rwnorm,1:nn,'kd');zoom on
  pl1a=plot(([ntilde(gir)-dn(gir) ntilde(gir)+dn(gir)]./...
    [rwnorm rwnorm])',[1;1]*(1:nn),'-+');

  pl2=plot(sqrt(diag(N(gir,gir)))./rwnorm,1:nn,'+',...
    -sqrt(diag(N(gir,gir)))./rwnorm,1:nn,'+');

  set(gca,'pos',[.13 .11 .70 .82])
  set(gca,'xlim',[-10 10])
  grid on;ax=axis;title([ttl ' fig ' num2str(iplot)])
  xlabel('Residuals normalized by sqrt(diag(N))');ylabel('Constraint')

  hdl=text(ax(2)*ones(length(gir),1),1:nn,pm.eqname(gir),...
    'fontsize',6);

  signature(signstr);
  %legend([pl3(1);pl2(1);pl1],'init','A priori','n tilda',2);

  setlargefig; drawnow
end
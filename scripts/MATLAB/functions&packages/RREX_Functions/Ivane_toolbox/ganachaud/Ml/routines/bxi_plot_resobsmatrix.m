function bxi_plot_resobsmatrix(Tv,Tu,m,n,pm,ttl,signstr)
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
  %PLOT RESOLUTION AND OBSERVATION MATRIX
  figure;clf;set(gcf,'position',[35 50 600 700])
  for i=1:2:n
    plot(-10*Tv(:,i)+(i+1)/2*ones(n,1),'linewidth',.1);hold on
  end
  set(gca,'ydir','rev'); grid on
  ylabel(sprintf('Resolution matrix (*10)'))
  axis([0 n 0 n/2])
  title(ttl)
  setlargefig;drawnow
  signature(signstr)

  figure;clf;set(gcf,'position',[40 55 600 700])
  for i=1:m
    plot(Tu(:,i)+(i+1)*ones(m,1),'linewidth',.1);hold on
  end
  %set(gca,'ydir','rev'); 
  grid on
  tx=text((m+1)*ones(m,1),((1:m)'+1),pm.eqname(1:m),...
    'fontsize',6);
  ylabel(sprintf('Observation matrix'))
  title(ttl)
  setlargefig 
  signature(signstr)
 drawnow
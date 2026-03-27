% Get water mass transport between pairs 'gip2get' and layers 'waterl'
%A. Ganachaud, Jul 2000
disp('')
disp(sprintf('Water mass transport between layer %g and %g',...
  boxi.glevels(min(waterl)),boxi.glevels(max(waterl)+1)));
disp(sprintf('pair %i to %i', min(gip2get), max(gip2get)))

iprop
layshift=(iprop-1)*Nlay;
Awater=Amat(layshift+waterl,gip2get);
  Twater=sum(-gsecs.inboxdir(isb)*Awater*bhat(gip2get)+...
    sum(Gunsgn(layshift+waterl,gip2get),2))
  dTwater=sqrt(ones(1,length(waterl))*...
    Awater*P(gip2get,gip2get)*Awater'*ones(length(waterl),1))

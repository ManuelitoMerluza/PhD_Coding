%to plot cumulative transports. Equations are in memory.
for isec=1:2
  subplot(2,1,isec)
  plot(cumsum(Gunsgn(boxi.nlay,pm.gifcol(isec):pm.gilcol(isec))),'.-')
  grid on;
  set(gca,'xlim',[1 gsecs.npair(isec)])
  zoom on;title(gsecs.name{isec})
end
setlargefig
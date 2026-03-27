%do the plots for hydrotran_box
%set the lower bound for all axes
maxy=0;
for isa=1:Nsec
  maxy=min([maxy,-500*ceil(max(sum(Lays{isa}.lavgwdth(1:Nlay-1))/500))]);
end

ifig=0;
for iprop=1 %:Nconseq
  %PLOT FLUX
  ifig=ifig+1;figure(ifig);clf;set(gcf,'position',[17 50 700 900])
  windw=0;
  ylab='Pressure';
  for isb=1:Nsec
    if windw==6
      ifig=ifig+1;figure(ifig);clf
      set(gcf,'position',[17 50 700 900]);windw=0;
    end
    %Layer interface approx mean depth
    layintd=-[0;cumsum(Lays{isb}.lavgwdth(1:Nlay-1))'];
    
    %RELATIVE T
    windw=windw+1;
    ttl=sprintf('%s %s (Relative)', gsecs.name{isb},propnm{iprop});
    rxlab=sprintf('Total: %4.2g %s',Tr{isb}(Nlay,iprop),lunits{iprop});
    cpstair1(windw,Tr{isb}(1:Nlay-1,iprop),layintd,[],rxlab,ylab,...
      ttl,layids(2:Nlay-1),0,1,'n',[],0,maxy)
    
    %ABSOLUTE T 
    windw=windw+1;
    ttl=sprintf('%s %s (Absolute)', gsecs.name{isb},propnm{iprop});
    rxlab=sprintf('Total: %4.2g \\pm %4.2g %s',Ta{isb}(Nlay,iprop),...
      dTa{isb}(Nlay,iprop),lunits{iprop});
    cpstair1(windw,Ta{isb}(1:Nlay-1,iprop),layintd,[],rxlab,ylab,...
      ttl,layids(2:Nlay-1),0,1,'n',[],0,maxy,dTa{isb}(1:Nlay-1,iprop))
  end %isb
  drawnow
  
  ifig=ifig+1;figure(ifig);clf;set(gcf,'position',[17 50 700 900])

  %PLOT RESIDUALS AND VERTICAL TERMS
  layintd=-[0;cumsum(boxi.lavgwdth(1:Nlay-1))];
  
  %BEFORE INVERSION
  windw=1;
  ttl=sprintf('Initial %s residuals', propnm{iprop});
  rxlab=sprintf('Net: %4.2g %s',Resr(Nlay,iprop),lunits{iprop});
  cpstair1(windw,Resr(1:Nlay-1,iprop),layintd,[],rxlab,ylab,...
    ttl,layids(2:Nlay-1),0,1,'n',[],0,maxy)

  %AFTER
  windw=2;
  ttl=sprintf('%s residuals', propnm{iprop});
  rxlab=sprintf('Net: %3.2g \\pm %3.2g %s',Resa(Nlay,iprop),...
    Dres(Nlay,iprop),lunits{iprop});
  cpstair1(windw,Resa(1:Nlay-1,iprop),layintd,[],rxlab,ylab,...
    ttl,layids(2:Nlay-1),0,1,'n',[],0,maxy,Dres(1:Nlay-1,iprop))

  %VERTICAL TERMS
  windw=3;
  ttl=sprintf('%s W transport', propnm{iprop});
  rxlab=sprintf('%s',lunits{iprop});
  cpstair1(windw,Wtrans(:,iprop),layintd(2:Nlay),[],rxlab,ylab,...
    ttl,layids(3:Nlay-1),0,1,'n',[],0,maxy,Dwtrans(:,iprop))
  
end %iprop

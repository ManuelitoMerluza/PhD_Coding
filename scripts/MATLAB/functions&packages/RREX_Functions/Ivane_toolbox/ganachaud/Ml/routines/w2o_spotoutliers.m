%w2o_spotoutliers.m: part of readobsfile
%AUTOMATIC CHECK BY PRESSURE INTERVALS
disp('  w2o_spotoutliers.m ...')
disp('write down the outliers, use zoom if needed to get station number')

depthrange=[[ 0   200 400 600  1000 1500 2000 3000;...
              200 400 600 1000 1500 2000 3000 4000],...
	    [ 4000  5000 ;...
	      5000 20000]];
	  
for irange=1:size(depthrange,2)
  f3;clf
  gic=find((opres>=depthrange(1,irange))&(opres<depthrange(2,irange)));
  statno=1+fix(gic/nlev);
  for iprop=1:nvar
    eval(['prop=' opropnm{iprop} ';'])
    if nvar <4
      subplot(nvar,1,iprop)
    elseif nvar<8
      subplot(ceil(nvar/2),2,iprop)
    else 
      subplot(ceil(nvar/3),3,iprop)
    end
    plot(statno,prop(gic),'b.','markersize',10);hold on;grid on
    if iprop==1
      title(sprintf('depth from %i to %i db',depthrange(1,irange),...
	depthrange(2,irange)))
    end %iprop
    ylabel(opropnm{iprop})
    for isec=1:nsec
      gisec=find((statno>fstat(isec))&(statno<lstat(isec)));
      if ~isempty(gisec) & ~all(isnan(prop(gic(gisec))))
	mprop(isec)=mmean(prop(gic(gisec)));
	sprop(isec)=sstd(prop(gic(gisec)));
	gispot=find(abs(prop(gic(gisec))-mprop(isec))>(2*sprop(isec)));
	plot([fstat(isec);lstat(isec)],mprop(isec)*[1;1],'m-',...
	  [fstat(isec);lstat(isec)],(mprop(isec)+sprop(isec))*[1;1],'m--',...
	  [fstat(isec);lstat(isec)],(mprop(isec)-sprop(isec))*[1;1],'m--')
	plot(statno(gisec(gispot)),prop(gic(gisec(gispot))),'ro','linewidth',1)
      end
    end %isec
  end %iprop
  zoom
  ppause
end %ON IRANGE
  

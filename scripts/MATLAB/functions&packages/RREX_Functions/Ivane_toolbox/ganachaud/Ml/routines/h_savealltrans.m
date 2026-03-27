% Save transports in individual layers and at each pair
% A. Ganachaud Dec. 2001
if exist('p_combinesec')
  error('should clean p_combinesec before saving matrices')
end

abstrans=full(Gunsgnnet(:,gicol)...
    -inboxdirr*...
    Amatnet(:,gicol).*(ones(size(Amatnet,1),1)*bhat(gicol)')...
    );

gsec.name=gsecs.name{isa};
gsec.namesuf=gsecs.namesuf{isa};
gsec.EkmanT=gsecs.EkmanT(isa);
gsec.perEk=gsecs.perEk(isa);
gsec.npair=gsecs.npair(isa);
gsec.binit=gsecs.binit{isa};
gsec.bstd=gsecs.bstd{isa};
gsec.rl=gsecs.rl;
gsec.isa=isa;
gsec.gip2select=gsecs.gip2select{isa};
gsec.lidep=gsecs.lidep{isa};

secid=[gsecs.name{isa} gsecs.namesuf{isa}];
datadir=gsecs.datadir{isa};
hdrname = [secid '_pair.hdr.mat'];
eval(['load ' datadir hdrname ])
gsec.lon=Slon;
gsec.lat=Slat;
gsec.glevel=boxi.glevels;

str=sprintf('%sgtransmat_%s_%i.mat',OPdirtransmat,gsec.name,iprop);
unitp=lunits{iprop};

if ~exist(str)
  eval(['save ' str ' abstrans tekk Twbc gsec unitp'])
else
  disp([str ' ALREADY EXISTS'])
%  ppause
end
clear abstrans gsec
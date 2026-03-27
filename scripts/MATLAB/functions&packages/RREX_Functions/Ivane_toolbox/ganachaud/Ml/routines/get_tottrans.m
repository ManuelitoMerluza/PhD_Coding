%Get total transport over several sections
%caller: glbdiagnostic

amatott=sparse(1,length(bhat));
Tatot=0;
dTatott=[];
Trtott=0;
disp('summing...')
for isr=1:length(gisaname)
  %find isa_bhat and gicols
  disp(gisaname{isr})
  isa_bhat=0;
  while isa_bhat<=length(gsecs.name)
    isa_bhat=isa_bhat+1;
    if strcmp(gsecs.name{isa_bhat},gisaname{isr})
      break
    end
  end
  gicols=pm.gifcol(isa_bhat):pm.gilcol(isa_bhat);
  
  %find isa_transec
  isa_transec=0;
  while isa_transec<=length(gsecs.name)
    isa_transec=isa_transec+1;
    if strcmp(Transec(isa_transec).secname,gisaname{isr})
      break
    end
  end
  Tatot=Tatot+Transec(isa_transec).Tanet(iprop);
  dTatott=[dTatott,Transec(isa_transec).dTanet(iprop)];
  Trtot=Trtot+...
    Transec(isa_transec).Tr(size(Transec(isa_transec).Tr,1),iprop);
  amatott(gicols)=Amatnets_glb{isa_transec}(iprop,:);
end %for isr=1:length(gisaname)
%Trtot+amatott*Binit-Tatot
%Tatotb=amatott*bhat
Tatot
dTatot=sqrt(amatott*P*amatott')
sqrt(sum(dTatott.^2))
%Get total residuals over several boxes
%caller: glbdiagnostic

amatot=sparse(1,length(bhat));
resatot=0;
dresatott=[];
disp('summing...')
for ibr=1:length(gboxes)
  disp(gboxes{ibr})
  gicols=[];  
  %find box indice in lay2sum
  iba_lay=0;
  while iba_lay<=length(gsecs.name)
    iba_lay=iba_lay+1;
    if strcmp(lay2sum{iba_lay}.boxname,gboxes{ibr})
      break
    end
  end
  %find bhat section indices
  for isr=1:length(lay2sum{iba_lay}.secname)
    %find isa_bhat and gicols
    disp(lay2sum{iba_lay}.secname{isr})
    isa_bhat=0;
    while isa_bhat<=length(gsecs.name)
      isa_bhat=isa_bhat+1;
      if strcmp(gsecs.name{isa_bhat},lay2sum{iba_lay}.secname{isr})
	break
      end
    end
    gicols=[gicols,pm.gifcol(isa_bhat):pm.gilcol(isa_bhat)];
  end
  %ADD W, K and FW indices
  %find box indice in global run
  iba_bhat=0;
  while iba_bhat<=length(gsecs.name)
    iba_bhat=iba_bhat+1;
    if strcmp(boxname{iba_bhat},gboxes{ibr})
      break
    end
  end
  if ~isempty(pm.gifKzcol{iba_bhat})
    gikzcols=pm.gifKzcol{iba_bhat}:pm.gilKzcol{iba_bhat};
  else
    gikzcols=[];
  end  
  gicols=[gicols,pm.gifwcol(iba_bhat):pm.gilwcol(iba_bhat),...
      pm.gifw{iba_bhat},gikzcols];
  for iglay=1:length(lay2sum{iba_lay}.resa{iprop})
    amatot(gicols)=amatot(gicols)+lay2sum{iba_lay}.amat{iprop,iglay};
    resatot=resatot+lay2sum{iba_lay}.resa{iprop}(iglay);
    dresatott=[dresatott,lay2sum{iba_lay}.dresa{iprop}(iglay)];
  end
end
dresatot=sqrt(amatot*P*amatot');

disp(sprintf('%4s=%5.0f +/- %5.0f (%5.0f without correlations)',...
  propnm{iprop},resatot,dresatot,sqrt(sum(dresatott.^2))))
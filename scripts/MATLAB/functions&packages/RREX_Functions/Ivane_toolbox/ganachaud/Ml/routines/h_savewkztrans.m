%Save W and Kz transports 
wtran=Wtrans{ibox}(:,iprop);
dwtran=Dwtrans{ibox}(:,iprop);
gifw=gifwcol(ibox):gilwcol(ibox);
wstar=bhat(gifw);
dwstar=sqrt(diag(P(gifw,gifw)));
if any(strcmp(fieldnames(boxi.conseq),'Kzstd'))
  kztran=Kztrans{ibox}(:,iprop);
  dkztran=Dkztrans{ibox}(:,iprop);
  gikz=gifkzcol(ibox):gilkzcol(ibox);
  kzstar=bhat(gikz);
  dkzstar=sqrt(diag(P(gikz,gikz)));
else
  kztran=NaN;
  dkztran=NaN;
  kzstar=NaN;
  dkzstar=NaN;
end

str=sprintf('%sgwkz_%s_%i.mat',OPdirwkz,boxi.name,iprop);
eval(['save ' str ...
    ' wtran dwtran wstar dwstar kztran dkztran kzstar '...
    ' dkzstar boxi'])

clear gifw gikz
clear wtran dwtran wstar dwstar kztran dkztran kzstar dkzstar


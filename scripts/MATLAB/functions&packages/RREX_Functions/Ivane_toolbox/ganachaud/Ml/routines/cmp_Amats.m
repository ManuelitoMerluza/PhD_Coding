% Compare the new output of mkequats to Alison's
% follows mkequats run
clear 

load /data1/alison/gmodels/natl/Bnatl_k/Amatrix.mat
load /data1/alison/gmodels/natl/Bnatl_k/params.mat
Gunsgnold=sparse(Gunsgn);
Gold=G;
A=sparse(A);
clear Gunsgn

load
iprop=1;
ilay=1;
%Section 1
for iprop=1:7
  disp(propnm(iprop,:))
  switch iprop
    case{MASS,SALI,PHOS,SILI,PO38}
      scalec=1;
    case HEAT
      scalec=3955/1e6; %(cp)
    case OXYG
      scalec=44.7; %Why/10 
    otherwise
      error('not scaled !');
  end
  for ilay=1:Nlay
    disp(sprintf('Layer %i',ilay))
    gip=50:57;
    disp(sprintf('pair %02i to %02i',min(gip),max(gip)));
    disp('Amat')
    disp(sprintf('%-6.3g |',full(Amat(Nlay*(iprop-1)+ilay,gip))))
    disp(sprintf('%-6.3g |',-scalec*full(A(afrow(2)-1+Nconseq*(ilay-1)+iprop,...
      fcols(2)+gip-1))))
    subplot(2,1,1)
    plot(full(Amat(Nlay*(iprop-1)+ilay,:)));hold on;grid on
    plot(-full(scalec*A(afrow(2)-1+Nconseq*(ilay-1)+iprop,...
      [fcols(2):lcols(3),fcols(4):lwcol(2)])),'+');
    title(sprintf('Amat, prop %i lay %i  - = new, + = old',iprop,ilay))
    if 0&ilay ~= 18
      axis([1 215 -200 200]);
    end
    hold off
    
    disp('Gunsgn')
    disp(sprintf('%-6.3g |',full(Gunsgn(Nlay*(iprop-1)+ilay,gip))))
    disp(sprintf('%-6.3g |',full(scalec*Gunsgnold(afrow(1)-1+...
      Nconseq*(ilay-1)+iprop,fcols(2)+gip-1))))
    subplot(2,1,2) %Gunsgn is in pieces top put together
    plot(full(Gunsgn(Nlay*(iprop-1)+ilay,:)));hold on;grid on
    plot(full(scalec*Gunsgnold(afrow(1)-1+Nconseq*(ilay-1)+iprop,...
      [fcols(2):lcols(3)])),'+');
    plot(pm.gifcol(3):pm.ilwcol,full(scalec*Gunsgnold(afrow(2)-1 ...
      +Nconseq*(ilay-1)+iprop,fcols(4):lwcol(2))),'+');
    title(sprintf('Gunsgn, ttlnew=%g ttlold=%g',G(Nlay*(iprop-1)+ilay),...
      -scalec*Gold(afrow(2)-1+Nconseq*(ilay-1)+iprop)))
    %axis([1 215 -10 10]);
    hold off
    
    disp('G')
    disp(sprintf('%-6.3g | ',G(Nlay*(iprop-1)+ilay)))
    disp(sprintf('%-6.3g | ',-scalec*Gold(afrow(2)-1+Nconseq*(ilay-1)+iprop)))
    ppause
  end %ilay
end

%FLUX EQUATIONS
for isec=1:3
  for iprop=1:Nprop
  disp(propnm(iprop,:))
  switch iprop
    case{MASS,SALI,PHOS,SILI,PO38}
      scalec=1;
    case HEAT
      scalec=3955/1e6; %(cp)
    case OXYG
      scalec=44.7; %Why/10 
    otherwise
      error('not scaled !');
  end
     clf
    subplot(2,1,1)
    gi=find(Amat(pm.giffrow(isec)+iprop-1,:));
    plot(full(Amat(pm.giffrow(isec)+iprop-1,gi)));
    hold on;title(sprintf('Amat, sec %i, prop %i',isec,iprop))
    gi=find(A(ffrows(isec+1)+iprop-1,:));
    plot(full(-scalec*A(ffrows(isec+1)+iprop-1,gi)),'+'); %? Why is it negative
    subplot(2,1,2)
    gi=find(Gunsgn(pm.giffrow(isec)+iprop-1,:));
    plot(full(Gunsgn(pm.giffrow(isec)+iprop-1,gi)));
    hold on;title(sprintf('Gunsgn G= %g Gold= %g',...
      G(pm.giffrow(isec)+iprop-1), scalec*Gold(ffrows(isec+1)+iprop-1)))
    gi=find(Gunsgnold(ffrows(isec+1)+iprop-1,:));
    plot(full(scalec*Gunsgnold(ffrows(isec+1)+iprop-1,gi)),'+');
         
    ppause
  end
end

%Compare additional flux equations
clf;
plot(full(Amat(pm.gifafrow(1),:)));hold on;
plot(full(Amat(pm.giffrow(2),:)),'+');
clf;
plot(full(Gunsgn(pm.gifafrow(1),:)));hold on;
plot(full(Gunsgn(pm.giffrow(2),:)),'+');
G(pm.gifafrow(1))
G(pm.giffrow(2))

clf;
plot(full(Amat(pm.gifafrow(2),:)));hold on
plot(full(Amat(pm.giffrow(1),:)),'+');
plot(full(Amat(pm.giffrow(2),:)),'x');
clf;
plot(full(Gunsgn(pm.gifafrow(2),:)));hold on
plot(full(Gunsgn(pm.giffrow(1),:)),'+');
plot(full(Gunsgn(pm.giffrow(2),:)),'x');
G(pm.gifafrow(2))
G(pm.giffrow(1))+G(pm.giffrow(2))

clf; 
plot(full(Amat(pm.gifafrow(3),:)));hold on
plot(full(Amat(pm.giffrow(3),:)),'+');
clf;
plot(full(Gunsgn(pm.gifafrow(3),:)));hold on
plot(full(Gunsgn(pm.giffrow(3),:)),'+');
G(pm.gifafrow(3))
G(pm.giffrow(3))

% script bxi_showek 
% KEY: display Ekman transports and correction after inversion
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
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , Oct98
%
% SIDE EFFECTS :
%
% SEE ALSO :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER: boxinvert, hydrotrans
% CALLEE:
if ~exist('bhat')
  strl=['load bhat_' Modelid '_' invid '.mat'];% bhat P pm gsecs];
  disp(strl);
  eval(strl)
end


if any(strcmp(fieldnames(gsecs),'dEkstd'))
    gsecs.Ekcorrected=gsecs.EkmanT(:)+bhat(pm.giEkcol);
    gsecs.dEkcorrected=sqrt(diag(P(pm.giEkcol,pm.giEkcol)));
    disp('Ekman transport correction')
    for isb=1:length(gsecs.name)
      perccor=fix(100*bhat(pm.giEkcol(isb))/(.01+gsecs.EkmanT(isb)));
      disp(sprintf(...
	'%5s:%4i%% init:%6.2g final:%6.2g+/-%4.2g Corr:%5.2g',...
	gsecs.name{isb},perccor,gsecs.EkmanT(isb),gsecs.Ekcorrected(isb),...
	gsecs.dEkcorrected(isb),bhat(pm.giEkcol(isb))))
    end
  end
  
if any(strcmp(fieldnames(pm),'ifw'))
  boxi.fw=bhat(pm.ifw);
  boxi.dfw=sqrt(P(pm.ifw,pm.ifw));
  disp(sprintf('Freshwater %6.2g +/-%4.2g',boxi.fw,boxi.dfw))
end

if any(strcmp(fieldnames(pm),'ilKzcol'))
  gilk=input('Layers over which to average the mixing and W ?');
  gilkz=pm.ifKzcol:pm.ilKzcol;
  gilkz=gilkz(gilk);
  ninterf=length(gilkz);
  aavg=ones(ninterf,1)/ninterf;
  Kzavg=aavg'*bhat(gilkz);
  dKzavg=sqrt(aavg'*P(gilkz,gilkz)*aavg);
  disp(sprintf('average Kz: %6.2g +/-%4.2g',Kzavg,dKzavg))
  
  gilw=pm.ifwcol:pm.ilwcol;
  gilw=gilw(gilk);
  ninterf=length(gilw);
  aavg=(ones(ninterf,1)/ninterf).*diag(Amat(gilk,gilw));
  Wavg=aavg'*bhat(gilw);
  dWavg=sqrt(aavg'*P(gilw,gilw)*aavg);
  disp(sprintf('average W: %6.2g +/-%4.2g',Wavg,dWavg))
end
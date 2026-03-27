%function breaksolution
% KEY: split the solution to the different regions
% USAGE : right after boxinvert run
%
% DESCRIPTION : 
%  hydrotrans has problems when the equation contains different regions
%  with different layer sets. Breaksolution splits the global solution
%  (bhat, P) into regional solutions on which hydrotrans is ran for
%  diagnostic
%
% INPUT: The global solution
%        Equations of each region
%
% OUTPUT:
%        Solution for each region
%
%
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , Jan 98
%
% SIDE EFFECTS :
%
% SEE ALSO :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER:
% CALLEE:
disp('SPLIT EQUATION IN THE DIFFERENT REGIONS')

if ~exist('bhat')
  strl=['load bhat_' Modelid '_' invid '.mat'];% bhat P pm gsecs];
  disp(strl);
  eval(strl)
end
Pm=pm;
Gsecs=gsecs;
Bhat=bhat;
Pglobal=P;
Nbox=length(Pm.gifwcol);

for ibox=1:Nbox
  clear bhat P
  %Load equations and parameters of the current box
  if iscell(IPdir)
    ipdir=IPdir{ibox};
  else
    ipdir=IPdir;
  end
  disp(['Reassemble ' boxname{ibox} '_' modelid{ibox}])
  eval(['load ' ipdir boxname{ibox} '_' modelid{ibox} '_equn.mat'])
  P=zeros(size(Amat,2),size(Amat,2));
  gicolb=[];gicola=[];
  for isb=1:length(gsecs.name)
    for isa=1:length(Gsecs.name)
      if strcmp(gsecs.name{isb},Gsecs.name{isa})
	disp(['  Section ' gsecs.name{isb}])
	gicolb=[gicolb,pm.gifcol(isb):pm.gilcol(isb)];
	gicola=[gicola,Pm.gifcol(isa):Pm.gilcol(isa)];
      end %if strcmp(gsecs.name{isb},Gsecs.name{isa})
    end %for isa=1:length(Gsecs.name)
  end %for isb=1:length(gsecs.name)
  disp('  Recovering W* terms')
  gicolb=[gicolb,pm.ifwcol:pm.ilwcol];
  gicola=[gicola,Pm.gifwcol(ibox):Pm.gilwcol(ibox)];
  if any(strcmp(fieldnames(pm),'ifw'))
    disp('Recovering Freshwater term')
    gicolb=[gicolb,pm.ifw];
    gicola=[gicola,Pm.gifw{ibox}];
  end
  if any(strcmp(fieldnames(pm),'ifKzcol'))
    disp('Recovering Kz term')
    gicolb=[gicolb,pm.ifKzcol:pm.ilKzcol];
    gicola=[gicola,Pm.gifKzcol{ibox}:Pm.gilKzcol{ibox}];
  end
  bhat(gicolb)=Bhat(gicola);
  P(gicolb,gicolb)=Pglobal(gicola,gicola);
  bhat=bhat(:);
  pm.gicolglobal=gicola;
  pm.gicollocal=gicolb;
  if length(bhat)~=size(Amat,2) | length(bhat)^2 ~= prod(size(P))
    error('Terrible problem with the reconstructed bhat')
  end
  strs=['save bhat_' Modelid '_' invid '_' boxname{ibox} ...
      '.mat bhat P pm gsecs '];
  disp(strs);disp(' ')
  eval(strs)
end %ibox
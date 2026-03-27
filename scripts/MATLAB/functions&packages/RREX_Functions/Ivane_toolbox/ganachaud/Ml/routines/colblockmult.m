function [C1]=colblockmult(A,B,gsecs,pm);
% KEY: memory-saving matrix multiplication by dividing A in 2 columns
% USAGE :C=colblockmult(A,B)
%   Sparsify C 
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
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , Jan99
%
% SIDE EFFECTS :
%
% SEE ALSO :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER:
% CALLEE:
[m,n]=size(A);
m1=fix(m/2);
if n~=size(B,1)
  error('incompatible size for multiplication')
end
A2=A(m1+1:m,:);
A1=A(1:m1  ,:);
clear A
disp('colblockmult step 1')
C1=B'*A1';
clear A1;

%%%%%%%%%%%%%%%%%%%%%% Sparsify first half %%%%%%%%%%%%%%%%%%%%%%%
disp('sparsify step 1...')
covsec=cov_section(gsecs);
nsec=length(covsec);
nbox=length(pm.gifwcol);
mstart=1;
mstop=m1;
tic
for isec1=1:nsec
  disp(gsecs.name(isec1))
  if pm.gifcol(isec1) <= mstop & pm.gilcol(isec1)>=mstart
    gisec1=max(1,pm.gifcol(isec1)-(mstart-1)):...
      min(mstop,pm.gilcol(isec1)-(mstart-1));
    disp([gisec1(1),max(gisec1)])
    for isec2=1:nsec
      if ~covsec(isec1,isec2)
	gisec2=pm.gifcol(isec2):pm.gilcol(isec2);
	C1(gisec2,gisec1)=0;
      end
    end
  end
end
C1=sparse(C1);
save /tmp/C1.mat C1
clear C1
toc

%%%%%%%%%%%%%%%%%%%%% Sparsify second half %%%%%%%%%%%%%%%%%%%%%%%
disp('colblockmult step 2')
C2=B'*A2';
clear A2 B
disp('sparsify step 2...')
mstart=m1+1;
mstop=m;
tic
for isec1=1:nsec
  disp(gsecs.name(isec1))
  if pm.gifcol(isec1) <= mstop & pm.gilcol(isec1)>=mstart
    gisec1=max(1,pm.gifcol(isec1)-(mstart-1)):...
      min(mstop,pm.gilcol(isec1)-(mstart-1));
    disp([gisec1(1),max(gisec1)])
    for isec2=1:nsec
      if ~covsec(isec1,isec2)
	gisec2=pm.gifcol(isec2):pm.gilcol(isec2);
	C2(gisec2,gisec1)=0;
      end
    end
  end
end
C2=sparse(C2);
save /tmp/C2.mat
load /tmp/C1.mat
C1(:,m1+1:m)=C2;
clear C2;
toc
if 1
  spy(C1);
  set(gca,'xtick',pm.gifcol)
  set(gca,'ytick',pm.gifcol)
  set(gca,'yticklabel',gsecs.name)
end

if 0
  disp('eliminates all cross-box correlations')
  for ibox=1:nbox
  disp(sprintf('box %i',ibox))
  if isempty(pm.gilKzcol{ibox})
    maxbox=pm.gilwcol(ibox);
  else
    maxbox=pm.gilKzcol{ibox};
  end
  gibox1=pm.gifwcol(ibox):maxbox;
  girow=1:(mstop-mstart+1);
  gibox11=max(1,pm.gifwcol(ibox)-(mstart-1)):...
      min(mstop,maxbox-(mstart-1));
  girow(gibox11)=[];
  C2(gibox1,girow)=0;
end

  
C1=C1';
C2=C2';
for ic=1:100:size(C2,2)
  icmax=min(ic+99,size(C2,2));
  C1(:,m1+(ic:icmax))=C2(:,ic:icmax);
  C2(:,ic:icmax)=[];
end
for ic=1:size(P2,2)
  tic
  P1(:,m1+(ic))=P2(:,ic);
  P2(:,ic)=[];
  toc 
  ic
end
end

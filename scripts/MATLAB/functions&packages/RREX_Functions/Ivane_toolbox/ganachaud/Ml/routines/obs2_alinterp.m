function bprop=obs2_alinterp(oprop,opres,stdd,w1,w2,wl1,wl2);
% KEY: Aitken-Lagrange interpolation
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
% OUTPUT:
%
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , Dec 97
%
% SIDE EFFECTS :
%
% SEE ALSO : alinterp.f
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER:
% CALLEE:

if any(diff(opres)<=0)
  opres
  error('non monotonically increasing pressure !')
end
bprop=NaN*ones(size(stdd));
gn=find(isnan(oprop));
oprop(gn)=[];
opres(gn)=[];
no=length(oprop);

for iop=2:no
  id1=iop-1;
  id2=iop;
  %Interpolates the points between iop and iop-1
  gistd=find( (stdd>=opres(iop-1)) & (stdd<=opres(iop)) );
  if (opres(iop)<=wl1)  & ((opres(iop)-opres(iop-1))<=w1) |...
      (opres(iop)<=wl2) & ((opres(iop)-opres(iop-1))<=w2) |...
      opres(iop)>=wl2   & ((opres(iop)-opres(iop-1))<=1000) 
    %Find a third point
    if iop-2>0
      id3=iop-2;
    elseif iop+1<=no
      id3=iop+1;
    else
      id3=0;
    end
    %Do interpolation
    if id3
      di2=stdd(gistd)-opres(id2);
      di3=stdd(gistd)-opres(id3);
      d12=opres(id1)-opres(id2);
      d13=opres(id1)-opres(id3);
      di1=stdd(gistd)-opres(id1);
      d23=opres(id2)-opres(id3);
      bprop(gistd)=...
	oprop(id1)*(di2.*di3)/( d12*d13)+...
	oprop(id2)*(di1.*di3)/(-d12*d23)+...
	oprop(id3)*(di1.*di2)/( d13*d23);
      %Check if in a reasonable range (0% of the range)
      dv=abs(oprop(id2)-oprop(id1));
      if all(stdd(gistd)>=400)
	ndv=0;
      else
	ndv=0;
      end
      if any( (bprop(gistd)<(min(oprop(id1:id2))-ndv*dv)) |...
	  (bprop(gistd)>(max(oprop(id1:id2))+ndv*dv)))
	id3=0;
      end
    end %if id3
    if ~id3 %Linear Interpolation
      bprop(gistd)=oprop(id1)+ (stdd(gistd)-opres(id1))*...
	(oprop(id2)-oprop(id1))/(opres(id2)-opres(id1));
    end %if ~id3
    %plot(bprop,-stdd,'b+-',bprop(gistd),-stdd(gistd),'k*',oprop,-opres,'ro')
    %set(gca,'ylim',[-6000 0]);drawnow
  end %if (opres(iop)<wl1)
end %for iop=2:no
%ppause
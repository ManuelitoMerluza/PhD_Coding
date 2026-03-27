function [BT,BI]=baroclitrop(v,dz,vmask,p_method)
% KEY: Separates field V into a barotropic and baroclinic component
% USAGE : v(ndep,nlong), dz(ndep,1)
% 
% DESCRIPTION : 
%    p_method=1: BT is associated with bottom velocity
%    p_method=2: BT is associated with surface velocity
%    p_method=3: BT is associated with z-average velocity
%
% INPUT: 
%
%
% OUTPUT: BT= barotropic component
%         BI= baroclinic component
%
% AUTHOR : A.Ganachaud (ganacho@ifremer.fr) , Sept 00
%
% SIDE EFFECTS :
%
% SEE ALSO :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER:
% CALLEE:

switch p_method
  case 1 % BT defined at bottom
    for ji=1:size(v,2)
      jimaxd=max(find(v(:,ji)));
      if ~isempty(jimaxd)
	BT(ji)=v(jimaxd,ji);
      else
	BT(ji)=0;
      end
    end
    
  case 2 % BT defined at surface
    BT=v(1,:);
    
  case 3 % BT defined as top-2-bottom average
    depth1=integz(vmask,dz);
    depth1(~depth1)=Inf;
    BT=integz(v,dz)./depth1;

  otherwise
    error('method unknown')
end
BT=vmask.*(ones(size(dz))*BT);
BI=(v-BT);


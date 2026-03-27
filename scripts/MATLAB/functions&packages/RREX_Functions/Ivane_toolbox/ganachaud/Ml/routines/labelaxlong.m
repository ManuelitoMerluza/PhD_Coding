function labelaxlong(curax)
% KEY: 
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
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , Jan 98
%
% SIDE EFFECTS :
%
% SEE ALSO :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER:
% CALLEE:
curticks=get(gca,'xtick');
for itick=1:length(curticks)
  if curticks(itick) <= 180 & curticks(itick)>=0
    tstr{itick}=sprintf('%4gE',curticks(itick));
  elseif curticks(itick) > 180
    tstr{itick}=sprintf('%4gW',360-curticks(itick));
  elseif curticks(itick) <0
    tstr{itick}=sprintf('%4gW',-curticks(itick));
  end  
  if curticks(itick)==0
    tstr{itick}=sprintf('%4g',curticks(itick));
  end
end
set(curax,'xticklabel',tstr)







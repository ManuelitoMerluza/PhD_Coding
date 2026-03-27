function labelaxlat(curax)
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
if nargin==0
  curax=gca;
end
curticks=get(gca,'ytick');
for itick=1:length(curticks)
  if curticks(itick) < 0
    tstr{itick}=sprintf('%4gS',-curticks(itick));
  elseif curticks(itick) > 0
    tstr{itick}=sprintf('%4gN',curticks(itick));
  else
    tstr{itick}=sprintf('%4g',curticks(itick));
  end
end
set(curax,'yticklabel',tstr)







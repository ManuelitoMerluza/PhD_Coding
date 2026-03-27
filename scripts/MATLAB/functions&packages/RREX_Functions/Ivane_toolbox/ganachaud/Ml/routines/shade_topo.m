function shade_topo(xx,bottom,fill_color)
%key: shade the the topography 
%synopsis : shade_topo(xx,bottom,fill_color)
% 
%
%
%
%description : 
%
%
%
%
%uses :
%
%side effects :
%
%author : A.Ganachaud (ganacho@gulf.mit.edu) , Jul 96
%
%see also :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~isstr(fill_color) & length(fill_color==1)
  fill_color=fill_color*[1,1,1];
end
hold on;
ax=axis;
fill([ax(1) ax(1) xx' ax(2) ax(2)],...
  [ax(3) ax(4) -bottom' ax(4) ax(3)],fill_color)

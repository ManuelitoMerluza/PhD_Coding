function hdl1=errfill(x,y,dy,color)
%key: plot x,y, with error bar area filled
%synopsis : errfill(x,y,dy,color)
% 
% color = 'r', 'b' ...
%       or [ 0.1 0.2 0.4 ] (rgb)
%       or 0.9 in grey scale, 1 is white
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
%author : A.Ganachaud (ganacho@gulf.mit.edu) , June 95
%
%see also :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sz=size(x);
if sz(1)==1
  x=x';y=y';dx=dx';
end

xf=[x;flipud(x)];
yf=[y-dy;flipud(y+dy)];
if ~exist('color')
 color=[0.5 0.5 0.5];
end
if ~isstr(color)
  if length(color)==1
    color=color*[1 1 1];
  end
end

  
  
hdl=fill(xf,yf,color);
if nargout 
  hdl1=hdl;
end
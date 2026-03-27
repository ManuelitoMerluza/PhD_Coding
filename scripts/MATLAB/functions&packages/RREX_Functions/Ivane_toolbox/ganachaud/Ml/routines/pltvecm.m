function pltvecm(x,y,u,v,scale,xymax,s)
% function pltvecm(x,y,u,v,scale,xymax)
%
% Plots vectors in arrays (u,v) at locations (x,y) with 
% magnitude scale by 'sca'.
%
%                         Julio Candela VII/93.
%			ClH 8/93

xx = [0 1 .8 1 .8].';
yy = [0 0 .08 0 -.08].';
arrow = xx + yy.*sqrt(-1);

if nargin == 4,
	scale = 0.25; xymax=[0 1 0 1];%	scale = 0.25;
end

grid = x + y.*sqrt(-1); grid = grid(:);
u = u(:); v = v(:);
z = (u + v.*sqrt(-1)).';
a = scale * arrow * z + ones(5,1) * grid.';
if nargin < 7, s = 'y-'; end
plot(real(a), imag(a),s); 



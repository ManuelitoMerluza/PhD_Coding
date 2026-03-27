function r=rot4z(theta)
% r = rotz(theta)
%
% rotz produces a 4x4 rotation matrix representing
% a rotation by theta radians about the z axis.
%
%	Argument definitions:
%	
%	theta = rotation angle in radians
c = cos(theta);
s = sin(theta);
r = [c -s  0 0;
     s  c  0 0;
     0  0  1 0;
     0  0  0 1];

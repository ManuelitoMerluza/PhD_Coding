function test_lat(lat)
%key: check if latitude greater than +/-90
%synopsis :
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
%author : A.Ganachaud (ganacho@gulf.mit.edu) , June 95
%
%see also :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if any(abs(lat)>90)
  error('latitude too big. is it a longitude ?')
end
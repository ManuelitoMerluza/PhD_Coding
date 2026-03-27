function Ar = reverse(A)
%key: reverse the order of the columns of a matrix A
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
%side effects : if only 1 column, reverse the rows
%
%author : A.Ganachaud, Apr 95
%
%see also :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sz=size(A);
if sz(2)==1
  irev=sz(1):-1:1;
  Ar=A(irev,:);
else
  irev=sz(2):-1:1;
  Ar=A(:,irev);
end
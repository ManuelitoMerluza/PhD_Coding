function x=outlier(x,otl)
%key: find outliers from x, replace with NaN
%synopsis : x=outlier(x,otl)
% 
% otl=outlier
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

ib=find(x==otl);
x(ib)=NaN*ones(size(ib));
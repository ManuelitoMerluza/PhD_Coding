function printyn(printer)
%key: print or not the graph
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
s=input('print ? y/n <n> :','s');
if ~exist('printer')
  printer='P4';
end
if strcmp(s,'y')
  eval(['print -' printer])
end
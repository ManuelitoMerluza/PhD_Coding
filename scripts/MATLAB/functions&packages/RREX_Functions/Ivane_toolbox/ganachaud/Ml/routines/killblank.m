function str2 = killblank(str1)
%
%synopsis : str2 = killblank(str1)
 
 % returns a str2 string with the first non-blank characters
 % str1. returns str1 if it does'nt contain any blank

%description : 

%uses :

% side effects : str1 must be a line string vector

% author : A.Ganachaud, Feb 95

%see also :

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~isstr(str1) error('non-string argument !');end

isblank = find(str1==' ');
str1(isblank)=[];
str2=str1;
function c = isgf3(e)
% Tests to see if input is a valid gf3 code. Returns 1 if true, 0 if false.
%
% Description:ISGF3 tests to see if e is a valid gf3 code. Returns 1 if true, 0 if false.
%
% Syntax:
%Usage: c = isgf3(e)
%
%Input:
%e: string containing possible gf3 code.
%
%Output:
%c: boolean truth value: 1 if e is a valid gf3 code, 0 otherwise.
%
%Example:
%isgf3('DENS')
%
%ans =
%
%     1
%
% Documentation Date: Oct.17,2006 10:26:34
%
% Tags:
% {ODSTOOLS} {TAG}

c=0;
load gf3def.mat;
for i = (1:length(gf3LIST));
   z = strcmp(gf3LIST{i}.code,upper(e));
   if (z == 1)
      c=1;
   end
end
clear gf3LIST;


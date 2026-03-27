function r = zclip3(s)
% String modification routine
%
%Description:ZCLIP3(s) string modification routine  This is a utility function that would not normally
%            be called directly by a user.
%
% Syntax:
%
%Usage: r = zclip3(s)
%
%Input:
%s : a string
%
%Output:
%r : a deblanked version of the input string with the whitespace characters and the
%    single quotes removed. If empty, a single space is returned.
%
%Example:
%
%s =
%
%This is the preamble, 'this is the amble'
%
%» r = zclip3(s)
%
%r =
%
%Thisisthepreamble,thisistheamble
%
%
% Documentation Date: Oct.17,2006 15:43:51
%
% Tags:
% {ODSTOOLS} {TAG}

r = strrep(s,char(39),'');
r = strrep(r,char(32),'');
r = deblank(r);

if (isempty(r))
   r = ' ';
end



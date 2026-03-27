function r = zclip(s)
% Quote-Delimited Field Retriever
%
%Description:Quote-Delimited Field Retriever. This is a utility function that would not normally
%            be called directly by a user.
%
% Syntax:
%Usage: r = zclip(s)
%
%Input:
%s : string which contains a single-quote-delimited field.
%
%Output:
%r : the simple contents of that field.
%
%Example:
%s =
%
%This is the preamble, 'this is the amble'
%
%» r = zclip(s)
%
%r =
%
%this is the amble
%
% Documentation Date: Oct.17,2006 15:39:39
%
% Tags:
% {ODSTOOLS} {TAG}

r=[];
n = findstr(s,'''');
if length(n)>1
   r = s(n(1)+1:n(end)-1);
end

r = deblank(r);
if (isempty(r))
   r = ' ';
end



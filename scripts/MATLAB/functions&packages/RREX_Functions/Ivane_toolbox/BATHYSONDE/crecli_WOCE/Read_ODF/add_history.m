function A = add_history(A, str)
% Adds a process string to the latest history header of ODF structure A.
%
% Description: Adds a line to the most recent history header in a given ODF
% structured array. History.m is a lower level script which is called from other
% scripts to record their use in the ODF processing history. It could also be used by
% a user to directly write an entry to the history file, but in most cases use of
% COMMENT.m would be preferable.
%
% Syntax:
% Usage: A = add_history(A, str)
% Input:
%   A: The ODF structured array.
% str: The string to be added.
% Output:
%        A: The modified ODF structured array.
% Example:
%        A = add_history(A, 'Extra line of add_history added here.')
%
% Documentation Date: Oct.16,2006 14:09:39
%
% Tags:
% {ODSTOOLS} {TAG}
%
%
% Other Notes:
% add_new_history.m creates a new history header and adds the history record.
% add_history.m adds the history record to the existing history header.
%

e = length(A.History_Header);
if isfield(A.History_Header{e},'Process')
   f = length(A.History_Header{e}.Process);
else
   f=0;
end
A.History_Header{e}.Process{f+1,1}=char(str);

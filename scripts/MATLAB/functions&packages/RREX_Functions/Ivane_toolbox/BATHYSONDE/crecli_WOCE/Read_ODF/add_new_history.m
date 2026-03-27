function A = add_new_history(A, str)
% Adds a process string to a new history header of ODF structure A.
%
% Description: add_new_history(A,str) adds a process string to a new history
% header of ODF structure A.
%
% Syntax:
% Usage:A = add_new_history(A, str)
% Input:
% A: the ODF structured array.
% str: the process string to be added to the new history header.
% Output:
% A: the Modified ODF structured array.
% Example:
% A = add_new_history(A, 'Began new process')
%
% Documentation Date: Oct.16,2006 14:10:57
%
% Tags:
% {ODSTOOLS} {TAG}
%
%
%
% Other Notes:
%  add_new_history.m creates a new history header and adds the history record.
%  add_history.m adds the history record to the existing history header.

e = length(A.History_Header);
A.History_Header{e+1}.Creation_Date = {mdate(datevec(now))};
A.History_Header{e+1}.Process{1,1}=char(str);

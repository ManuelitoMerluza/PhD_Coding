function [dout, linecount] = readodfdata(cyc, dparams, qform, filename, hlines)
%Reads in data from the specified ASCII file.
%
% Description: readodfdata reads data from an ODF file using specified
% parameters.
%
% Syntax:
%Usage: [dout,linecount] = readodfdata(cyc, dparams, qform, filename, hlines)
%
%Input:
%cyc: the number of cycles/rows of data to read from the file.
%     If cyc <0, reads to end of file. N.B. - Do not set cyc<0
%     if the file contains non-blank trailer records (should not happen
%     for ODF files).
%     Note: The option of setting cyc < 0 is particular to this new
%           version of readodfdata.
%dparams: the number of data channels/parameters/columns to read from the file
%qform: the format string of the data in the file (should be set to
%       bypass any SYTM data).
%filename: the file from which the data is to be read.
%hlines: the number of rows of header information before the data actually begin
%
%Output:
%dout:      A double-precision Matlab matrix of x rows by dparams columns of data,
%             where x is the number of data cycles read.
%linecount: Number of data cycles read.
%
%Example:
%[dout,linecount] = readodfdata(-1, 3, '%f %f %f %f ''%*12c %*12c''', 'C:\matlab\bin\rdidata.odf', hlines);
%
% Documentation Date: Mar. 3, 2008
%
% Tags:
% {ODSTOOLS} {READER} {TAG}
%
%Other Notes:
% This function is a replacement for readodfdata.c/.dll and for
% the internal subfunction readodfdata of read_odf_new.m.
%
% In this version of readodfdata (which is backwards compatible
% with the subfunction readodfdata in read_odf_new.m), hlines is the total
% number of header lines at the start of the ODF file, including any
% blank lines between the "-- DATA ---" line and the start of the data.
% However, in readodfdata.c, hlines was only the number of blank lines
% between the "-- DATA --" line and the start of the data.
%

qform = strrep(qform,'%*25c','%*12c %*12c');

fid = fopen(filename,'rt');

% Can't use HeaderLines option of textscan for this case
for e=1:hlines
  fgetl(fid);
end

try
% No. of elements in AAA is based on conversion specifiers in qform.
% The Delimiter and MultipleDelimsAsOne options allow
% input records to span multiple lines.
    if (cyc>=0)
      AAA = textscan(fid, qform,cyc, ...
         'Delimiter','\n \t','MultipleDelimsAsOne',1);
    else
      AAA = textscan(fid, qform, ...
         'Delimiter','\n \t','MultipleDelimsAsOne',1);
    end
% No need to do reshape or transpose here
    dout = cell2mat(AAA);
catch
    error('READODFDATA: TEXTSCAN/CELL2MAT failed.');
end

fclose(fid);

[linecount, n] = size(dout);
if (linecount>0) && (n ~= dparams)
  disp(n);
  disp(linecount);
  disp(dparams);
  error('READODFDATA: Wrong number of columns read.');
end

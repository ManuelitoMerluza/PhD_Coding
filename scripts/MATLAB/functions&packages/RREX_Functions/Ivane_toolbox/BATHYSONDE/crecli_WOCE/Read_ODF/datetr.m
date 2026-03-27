function tdates = datetr(filename,qform2,hlines)
%Reads SYTM data from an ODF file.
%
%Description: DATETR reads SYTM data from the specified ODF data.
%
% Syntax:
%Usage: tdates = datetr(filename,qform2,hlines)
%
%Input:
%filename: The ODF file to be read.
%  qform2: Format used to read the SYTM data.
%  hlines: Number of header lines in the file.
%
%Output:
%tdates: SYTM data as decimal Julian day numbers.
%
% Documentation Date: Feb. 13, 2008
%
% Tags:
% {ODSTOOLS} {ODF} {READER} {TAG}
%
%Other notes:
%  This function acts as a replacement for code like:
%  tempdate = julian(readodfdate(cyc,qform2, filename, nlines));
%

qform3 = strrep(qform2,['''%23c'''],['''%11c %11c''']);
qform3 = strrep(qform3,['%25c'],['''%11c %11c''']);
qform3 = strrep(qform3,['''%*23c'''],['''%*11c %*11c''']);
qform3 = strrep(qform3,['%*25c'],['''%*11c %*11c''']);
try
    [dates,times] = textread(filename,qform3,'headerlines',hlines);
catch
    %uh oh. Multi line conflict. Hm. Okay. Assume one record over two lines.
    file = textread(filename,'%s','delimiter','\n','whitespace','');
    cfile = char(file);
    cfile = cfile(hlines+1:end,:);%just the data
    %okay. Find the SYTM strings
    dfile = double(cfile);
    [NNr,NNc] = find(dfile==39);%finds the quotes.
    SYTM_LINES = distinct(NNr);
    H = waitbar(0,'Reading Dates - Overcoming Multiline Conflict')
    lnq = length(SYTM_LINES);
%    datestrings(1:SYTM_LINES,1:25) = 0;
%    datestrings = char(datestrings);
    datestrings(1:lnq,1:25) = 0;
    datestrings = char(datestrings);
    for nq = 1:lnq;
        waitbar(nq/lnq,H);
        dateline = cfile(SYTM_LINES(nq),:);
        if ~strcmp(dateline(1),'''')
            dateline = strrep(dateline,''' ','''0');
            [junk,datestring] = strtok(dateline,'''');
        else
            datestring = dateline(1:25);
        end
        datestring = deblank(datestring);
        datestrings(nq,:)=(datestring(1:25));
        dates = datestrings(:,2:12);
        times = datestrings(:,14:24);
    end

    close(H);
end


%dates = fliplr(dates)


dates = cellstr(dates);
dates = strrep(dates,'-JAN-','-001-');
dates = strrep(dates,'-FEB-','-002-');
dates = strrep(dates,'-MAR-','-003-');
dates = strrep(dates,'-APR-','-004-');
dates = strrep(dates,'-MAY-','-005-');
dates = strrep(dates,'-JUN-','-006-');
dates = strrep(dates,'-JUL-','-007-');
dates = strrep(dates,'-AUG-','-008-');
dates = strrep(dates,'-SEP-','-009-');
dates = strrep(dates,'-OCT-','-010-');
dates = strrep(dates,'-NOV-','-011-');
dates = strrep(dates,'-DEC-','-012-');


dates = char(dates);
[R,C] = find(double(dates)==double(' '));
if ~isempty(R)
    dates(R,1:12) = [repmat('0',length(R),1),dates(R,1:11)];
end

[R,C] = find(double(times)==double(' '));
if ~isempty(R)
    times(R,1:11) = [times(R,2:11),repmat('0',length(R),1)];
end
chardates = (dates);
if size(chardates,2)<11
    chardates = [repmat('0',size(chardates,1),1),chardates];
end

days = str2num(chardates(:,1:2));
months = str2num(chardates(:,4:6));
years = str2num(chardates(:,8:11));
hours = str2num(times(:,1:2));
minutes = str2num(times(:,4:5));
seconds = str2num(times(:,7:11));
tdates = julian([years,months,days,hours,minutes,seconds]);


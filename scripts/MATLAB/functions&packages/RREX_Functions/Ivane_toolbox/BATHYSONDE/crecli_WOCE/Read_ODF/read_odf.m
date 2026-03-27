function S = read_odf(varargin)
%Reads in the specified ODF file. If none specified, a file select window appears to select one.
%
%Description: READ_ODF reads in the specified ODF file.
%             If none specified, a file select window appears to select one.
%
% Syntax:
%Usage:S = read_odf([filename])
%
%Input:
%filename: (optional) the ODF file to be read.
%
%Output:
%S : the structured ODF array
%
%Example:
%
%E = read_odf('MTR_97999_16_VM3556_5400.ODF')
%
%
%Other Notes: See 'processfiles' for batch processing information.

%

if length (varargin)==0
   [f, p] = uigetfile(['*.odf*; *.ODF*'], 'Select ODF File');
   if f==0
       return;
   end
   filename = [p,f];
else
   filename = char(varargin{1});
end


fid = fopen(filename, 'r');
l=1; a=0; b=0; c=0; d=0;

%In this for loop we read in the Header information into a cell array
%And find out which lines mark the beginning of which headers.

while feof(fid)==0
   line = fgetl(fid);
   S.header{l} = deblank(line);

   if findstr('ODF_HEADER', line) > 0
      odfhdline = l;
   end

   if findstr('CRUISE_HEADER', line) > 0
      crhdline = l;
   end

   if findstr('EVENT_HEADER', line) > 0
      evhdline = l;
   end

   if findstr('INSTRUMENT_HEADER', line) > 0
      inhdline = l;
   end

   if findstr('POLYNOMIAL_CAL_HEADER', line) > 0
      a=a+1;

      pchdline(a) = l;
   end

   if findstr('COMPASS_CAL_HEADER', line) > 0
      b=b+1;

      cchdline(b) = l;
   end

   if findstr('HISTORY_HEADER', line) > 0
      c=c+1;
      hshdline(c) = l;
   end

   if findstr('PARAMETER_HEADER', line) > 0
      d=d+1;

      prhdline(d) = l;
   end

   if findstr('RECORD_HEADER', line) > 0
      rchdline = l;
   end

   if ((findstr('-- DATA --', line) > 0) & isempty(findstr('PROCESS',line)))
      dataline = l;
      break;
   end

l=l+1;

end

%Here's where we read in the ODF header info.

odftemp = char(S.header{(odfhdline(1)+1)});
S.ODF_Header = struct;
S.ODF_Header.File_Spec = cellstr(zclip(odftemp));

%Here's where we read in the Cruise header info.

S.Cruise_Header = struct;
crutemp = char(S.header{(crhdline(1)+1)});
S.Cruise_Header.Country_Institute_Code = cellstr(zclip2(crutemp));
crutemp = char(S.header{(crhdline(1)+2)});
S.Cruise_Header.Cruise_Number = deblank(cellstr(zclip(crutemp)));
crutemp = char(S.header{(crhdline(1)+3)});
S.Cruise_Header.Organization = deblank(cellstr(zclip(crutemp)));
crutemp = char(S.header{(crhdline(1)+4)});
S.Cruise_Header.Chief_Scientist = deblank(cellstr(zclip(crutemp)));
crutemp = char(S.header{(crhdline(1)+5)});
S.Cruise_Header.Start_Date = deblank(cellstr(zclip(crutemp)));
crutemp = char(S.header{(crhdline(1)+6)});
S.Cruise_Header.End_Date = deblank(cellstr(zclip(crutemp)));
crutemp = char(S.header{(crhdline(1)+7)});
S.Cruise_Header.Platform = deblank(cellstr(zclip(crutemp)));
crutemp = char(S.header{(crhdline(1)+8)});
S.Cruise_Header.Cruise_Name = deblank(cellstr(zclip(crutemp)));
crutemp = char(S.header{(crhdline(1)+9)});
S.Cruise_Header.Cruise_Description = deblank(cellstr(zclip(crutemp)));

%Here's where we read in the Event header info.

S.Event_Header = struct;
evetemp = char(S.header{(evhdline(1)+1)});
S.Event_Header.Data_Type = deblank(cellstr(zclip(evetemp)));
evetemp = char(S.header{(evhdline(1)+2)});
S.Event_Header.Event_Number = deblank(cellstr(zclip(evetemp)));
evetemp = char(S.header{(evhdline(1)+3)});
S.Event_Header.Event_Qualifier1 = deblank(cellstr(zclip(evetemp)));
evetemp = char(S.header{(evhdline(1)+4)});
S.Event_Header.Event_Qualifier2 = deblank(cellstr(zclip(evetemp)));
evetemp = char(S.header{(evhdline(1)+5)});
S.Event_Header.Creation_Date = deblank(cellstr(zclip(evetemp)));
evetemp = char(S.header{(evhdline(1)+6)});
S.Event_Header.Orig_Creation_Date = deblank(cellstr(zclip(evetemp)));
evetemp = char(S.header{(evhdline(1)+7)});
S.Event_Header.Start_Date_Time = deblank(cellstr(zclip(evetemp)));
evetemp = char(S.header{(evhdline(1)+8)});
S.Event_Header.End_Date_Time = deblank(cellstr(zclip(evetemp)));
evetemp = char(S.header{(evhdline(1)+9)});
S.Event_Header.Initial_Latitude = (zsnip(evetemp));
evetemp = char(S.header{(evhdline(1)+10)});
S.Event_Header.Initial_Longitude = (zsnip(evetemp));
evetemp = char(S.header{(evhdline(1)+11)});
S.Event_Header.End_Latitude = (zsnip(evetemp));
evetemp = char(S.header{(evhdline(1)+12)});
S.Event_Header.End_Longitude = (zsnip(evetemp));
evetemp = char(S.header{(evhdline(1)+13)});
S.Event_Header.Min_Depth = (zsnip(evetemp));
evetemp = char(S.header{(evhdline(1)+14)});
S.Event_Header.Max_Depth = zsnip(evetemp);
evetemp = char(S.header{(evhdline(1)+15)});
S.Event_Header.Sampling_Interval = zsnip(evetemp);
evetemp = char(S.header{(evhdline(1)+16)});
S.Event_Header.Sounding = zsnip(evetemp);
evetemp = char(S.header{(evhdline(1)+17)});
S.Event_Header.Depth_Off_Bottom = zsnip(evetemp);

% There may be several lines of event comments.


lec = (18:(inhdline-evhdline-1));
S.Event_Header.Event_Comments = cell(length(lec),1);
nb = 0;

for i=(lec)
   nb = nb+1;
   evetemp = char(S.header{(evhdline(1)+i)});
        S.Event_Header.Event_Comments{nb} = deblank(cellstr(zclip(evetemp)));
end


%Here's where we read in the Instrument header info.

S.Instrument_Header = struct;
instemp = char(S.header{(inhdline(1)+1)});
S.Instrument_Header.Inst_Type = deblank(cellstr(zclip(instemp)));
instemp = char(S.header{(inhdline(1)+2)});
S.Instrument_Header.Model = deblank(cellstr(zclip(instemp)));
instemp = char(S.header{(inhdline(1)+3)});
S.Instrument_Header.Serial_Number = deblank(cellstr(zclip(instemp)));
instemp = char(S.header{(inhdline(1)+4)});
S.Instrument_Header.Description = deblank(cellstr(zclip(instemp)));

%Here's where we read in the Polynomial Calibration header info.

S.Polynomial_Cal_Header = cell(a,1);
for i=(1:a)

   plctemp = char(S.header{(pchdline(i)+1)});
   S.Polynomial_Cal_Header{i}.Parameter_Code = deblank(cellstr(zclip(plctemp)));
   plctemp = char(S.header{(pchdline(i)+2)});
   S.Polynomial_Cal_Header{i}.Calibration_Date = deblank(cellstr(zclip(plctemp)));
   plctemp = char(S.header{(pchdline(i)+3)});
   S.Polynomial_Cal_Header{i}.Application_Date = deblank(cellstr(zclip(plctemp)));
   plctemp = char(S.header{(pchdline(i)+4)});
   S.Polynomial_Cal_Header{i}.Number_Coefficients = zsnip(plctemp);

   % There may be more than one line of coefficients. The following code addresses that.
   % DFSK 09-DEC-1999.

   RRR = S.Polynomial_Cal_Header{i}.Number_Coefficients;
   mmm = 0;
   nnn = 0;
   while RRR>0;
      mmm=mmm+1;
      plctemp = char(S.header{(pchdline(i)+4+mmm)});
      qplc = zclip2(plctemp);
      while(~isempty(deblank(qplc)))
         nnn=nnn+1;
         RRR = RRR-1;
         [qplct, qplc] = strtok(qplc);
         S.Polynomial_Cal_Header{i}.Coefficients(nnn)=str2num(qplct);
      end
   end

end

%Here's where we read in the Compass Calibration header info.

S.Compass_Cal_Header = cell(b,1);

for i=(1:b)
   ccltemp = char(S.header{(cchdline(i)+1)});
   S.Compass_Cal_Header{i}.Parameter_Code = deblank(cellstr(zclip(ccltemp)));
   ccltemp = char(S.header{(cchdline(i)+2)});
   S.Compass_Cal_Header{i}.Calibration_Date = deblank(cellstr(zclip(ccltemp)));
   ccltemp = char(S.header{(cchdline(i)+3)});
   S.Compass_Cal_Header{i}.Application_Date = deblank(cellstr(zclip(ccltemp)));

   if (i < b)
        lines = (cchdline(i+1)-(cchdline(i)+4));
        end

   if (i == b)
      lines = (hshdline(1) -(cchdline(i)+4));
   end
   m=0;

   for j=(1:(lines/2))
      ccltemp = char(S.header{(cchdline(i)+j+3)});
      cclt = zclip2(ccltemp);
      for k=(1:4)
         [num, cclt] = strtok(cclt);
         m=m+1;
         S.Compass_Cal_Header{i}.Directions(m)= str2num(num);
      end
   end
   m=0;
   for j=(((lines/2)+1):lines)
      ccltemp = char(S.header{(cchdline(i)+j+3)});
      cclt = zclip2(ccltemp);
      for k=(1:4)
         [num, cclt] = strtok(cclt);
         m=m+1;
         S.Compass_Cal_Header{i}.Corrections(m) = str2num(num);
      end
   end


end

%Here's where we read in the History header info.

S.History_Header = cell(c,1);
for i = (1:c)
   histemp = char(S.header{(hshdline(i)+1)});
   S.History_Header{i}.Creation_Date = deblank(cellstr(zclip(histemp)));

   if (i < c)
      lines = hshdline(i+1) - (hshdline(i)+2);
   end

   if (i == c)
      lines = prhdline(1) - (hshdline(i)+2);
   end

   S.History_Header{i}.Process = cell(lines,1);

   if lines >= 2

        for j = (1:(lines-1))
        histemp = char(S.header{(hshdline(i)+1+j)});
        S.History_Header{i}.Process{j} = zclip(histemp);
      end

   end

        if lines >= 1

                histemp = char(S.header{(hshdline(i)+1+lines)});
                S.History_Header{i}.Process{lines} = zclip(histemp);
        end

end

%Here's where we read in the Parameter header info.
S.Parameter_Header = cell(d,1);

 for i = (1:d)
   nullsw=0;
   j=0;
   partemp = 'XXXXXX';
   while ((j<15) & (isempty(findstr(partemp, 'PARAMETER_HEADER')))& (isempty(findstr(partemp, 'RECORD_HEADER'))))
     j = j+1;

	  partemp = char(S.header{(prhdline(i)+j)});


   if (findstr('TYPE',partemp) > 0)
     S.Parameter_Header{i}.Type = deblank(cellstr(zclip(partemp)));
   end

   if (findstr('NAME',partemp) > 0)
     S.Parameter_Header{i}.Name = deblank(cellstr(zclip(partemp)));
   end

   if (findstr('UNITS',partemp) > 0)
     S.Parameter_Header{i}.Units = deblank(cellstr(zclip(partemp)));
   end

   if (findstr('PRINT_FIELD_WIDTH',partemp) > 0)
     S.Parameter_Header{i}.Print_Field_Width = (zsnip(partemp));
   end

   if (findstr('PRINT_DECIMAL_PLACES',partemp) > 0)
     S.Parameter_Header{i}.Print_Decimal_Places = (zsnip(partemp));
   end

   if (findstr('WMO_CODE',partemp) > 0)
      S.Parameter_Header{i}.WMO_Code = deblank(cellstr(zclip(partemp)));
      if (strcmp(' ',char(S.Parameter_Header{i}.WMO_Code)) | isempty(char(S.Parameter_Header{i}.WMO_Code)) )
         S.Parameter_Header{i}.WMO_Code = deblank(cellstr(zclip2(partemp)));
      end
   elseif (findstr('CODE',partemp) >0)
      S.Parameter_Header{i}.Code = deblank(cellstr(zclip(partemp)));
      if (strcmp(' ',char(S.Parameter_Header{i}.Code)) | isempty(char(S.Parameter_Header{i}.Code)) )
         S.Parameter_Header{i}.Code = deblank(cellstr(zclip2(partemp)));
      end
   end

   if (findstr('NULL_VALUE',partemp) > 0)
      S.Parameter_Header{i}.NULL_Value = deblank(cellstr(zclip(partemp)));
      if (strcmp(' ',char(S.Parameter_Header{i}.NULL_Value)) | isempty(char(S.Parameter_Header{i}.NULL_Value)) )
         S.Parameter_Header{i}.NULL_Value = deblank(cellstr(zclip2(partemp)));
      end
      nullsw=1;
   end


   if (findstr('ANGLE_OF_SECTION',partemp) > 0)
      S.Parameter_Header{i}.Angle_of_Section = (zsnip(partemp));
   end

   if (findstr('MAGNETIC_VARIATION',partemp) > 0)
      S.Parameter_Header{i}.Magnetic_Variation = (zsnip(partemp));
   end

   if (findstr('DEPTH',partemp) > 0)
      S.Parameter_Header{i}.Depth = (zsnip(partemp));
   end

   if (findstr('MINIMUM_VALUE',partemp) > 0)
      S.Parameter_Header{i}.Minimum_Value = deblank(cellstr(zclip2(partemp)));
   end

   if (findstr('MAXIMUM_VALUE',partemp) > 0)
      S.Parameter_Header{i}.Maximum_Value = deblank(cellstr(zclip2(partemp)));
   end

   if (findstr('NUMBER_VALID',partemp) > 0)
      S.Parameter_Header{i}.Number_Valid = (zsnip(partemp));
   end

   if (findstr('NUMBER_NULL',partemp) > 0)
      S.Parameter_Header{i}.Number_NULL = (zsnip2(partemp));
   end
  end
  hh = [];

  %a little patch to allow reading of NFLD odfs.
  %%%
  if isfield(S.Parameter_Header{i},'WMO_Code')
     if findstr(char(S.Parameter_Header{i}.Type),'SYTM');
        S.Parameter_Header{i}.WMO_Code = cellstr('SYTM');
     end
  end
  %%%

  if isfield(S.Parameter_Header{i},'WMO_Code')
     gf3code = char(S.Parameter_Header{i}.WMO_Code);
  else
     gf3code = char(S.Parameter_Header{i}.Code);
     gf3code = gf3code(1:4);
  end


  if isgf3(gf3code);
     hh = gf3defs((gf3code));
  else
     hh = gf3defs('UNKN');
  end

  if ~isfield(S.Parameter_Header{i}, 'Units')
     S.Parameter_Header{i}.Units = hh.units;
  end

  if ~isfield(S.Parameter_Header{i}, 'Print_Field_Width')
     S.Parameter_Header{i}.Print_Field_Width = hh.fieldwidth;
  end

  if ~isfield(S.Parameter_Header{i}, 'Print_Decimal_Places')
     S.Parameter_Header{i}.Print_Decimal_Places = hh.decimalplaces;
  end

  if ~isfield(S.Parameter_Header{i}, 'Code')
     S.Parameter_Header{i}.Code = S.Parameter_Header{i}.Name;
  end


  if nullsw==0
     S.Parameter_Header{i}.NULL_Value = -99.00;
  end


end

%Here's where we read in the Record header info.

S.Record_Header = struct;
S.Record_Header.Num_Cycle = NaN; % Sept 6, 2000. Just to make sure for checks later on.
for g = (1:5)

   rectemp = char(S.header{(rchdline(1)+ g)});

   if (findstr('CAL', rectemp)) > 0
      S.Record_Header.Num_Calibration = zsnip(rectemp);
   end

   if (findstr('SWING', rectemp)) > 0
      S.Record_Header.Num_Swing = zsnip(rectemp);
   end

   if (findstr('HIST', rectemp)) > 0
      S.Record_Header.Num_History = zsnip(rectemp);
   end

   if (findstr('CYC', rectemp)) > 0
      S.Record_Header.Num_Cycle = zsnip(rectemp);
   end

   if (findstr('PAR', rectemp)) > 0
      S.Record_Header.Num_Param = zsnip2(rectemp);
   end

   if (findstr('DATA', rectemp)) > 0
      break;
   end

end
%modify parameter names to gf3_Code format.
S = add_new_history(S,'GF3 Name Checking and Code Formatting');

S = gf3namechk(S);
S = add_history(S,'Name check performed');



timeext = 0;
timeind = [];

for i = (1:d)
   CHECK = char(S.Parameter_Header{i}.Code);
   if ((findstr('SYTM',CHECK) > 0))
      disp('Time index found.');
      if isempty(timeind),timeind = i;,else timeind = [timeind,i];,end;
      timeext = timeext+1;
   end

end
%check for blank lines.
blines = -1;
i=1;

while (blines == -1 & i < 100)
   line = fgetl(fid);

        if (size(deblank(line))~=0)
      blines = i-1;
   end
   i = i+1;

end

if isempty(deblank(line(1)))
   leadspace = [' '];
else
   leadspace = [];
end


status = fclose(fid);

disp('Header Input Completed');

tform = zeros(1,d);

if (timeext ~= 0)
   tform(timeind) = 1;
end

qform = num2str(tform);
qform = strrep(qform, '0', '%f');
qform = deblank(strrep(qform, '1', ['%*25c']));
qform = [' ',qform];

use_mexread=(exist('readodfdata')==3);

% If using MEX-file version of readodfdata, need to use filelength
if (use_mexread)
  qqq = filelength(filename);
  cyc = qqq-size(S.header,2)-blines;
  if (mod(cyc,S.Record_Header.Num_Cycle)==0 & cyc~=S.Record_Header.Num_Cycle)
    cyc = S.Record_Header.Num_Cycle;
  else
    S.Record_Header.Num_Cycle = cyc;
  end

else

% In new version of readodfdata, one can set no. of cycles = -1
% to read to end of file. (No need to use filelength.) - DC
  cyc =-1;
end

dparams = length(S.Parameter_Header) + (timeext * -1);

%Dec 10 1999 - READODFDATA.C was changed to count the number of valid lines of data, to allow accurate
%'trimming' of empty data that may have been returned due to blank lines at the end of the data file.

%Dec 20, 2005 - We'll use TEXTSCAN as an alternative in a more recent
%version of matlab on a UNIX platform. And make Everyone happy.

% MEX-file version of readodfdata has a different meaning for hlines
% than the new M-file version does.
if (use_mexread)
  hlines=blines;
else
  hlines = blines +size(S.header,2);
end

[dtempout, linecount] = readodfdata(cyc, dparams, qform, filename, hlines);

linecount = double(linecount);
dtempout = dtempout(1:linecount,:);

% Following line added by DC
S.Record_Header.Num_Cycle = linecount;

disp('Data Input Completed');

   for ii = (timeind)
   	tform(ii) = ii;
	end

	for ii = (timeind)
      	qform2 = num2str(tform);
       qform2 =[' ',qform2];
		qform2 = strrep(qform2, ' 0', '%*f ');
		qform2 = deblank(strrep(qform2, num2str(ii), [char(39), '%bbc', char(39)]));
		for jj = timeind(find(timeind~=ii))
   		qform2 = deblank(strrep(qform2, num2str(jj), [char(39), '%*bbc', char(39)]));
	   end
      qform2 = deblank(strrep(qform2, 'bb','23'));
      qform2 = [leadspace,qform2];

   %   tempdate = julian(readodfdate(cyc,qform2, filename, blines));

%   tempdate = datetr(filename,qform2,length(S.header));
% Above line replaced as follows - DC
   tempdate = datetr(filename,qform2,hlines);


   tempdate = tempdate(1:linecount,:);

	   eval(['S.Data.',char(S.Parameter_Header{ii}.Code),'=tempdate;']);
	end


	disp('Date Input Completed');




%modify parameter names to gf3_Code format.

S = gf3namechk(S);


tname = ['0'];
if isempty(timeind),timeind=-1;,end;
for y=(1:d)
   if (isempty(find(timeind==y)) | timeext == 0)
      rr = find(timeind<y & timeind > 0);
      tname = deblank(char(S.Parameter_Header{y}.Code));
      x = num2str(y-length(rr));
	      nullval = ((round(10000*str2num(char(S.Parameter_Header{y}.NULL_Value))))/10000);
   	   nullstr = num2str(nullval);
      	eval(['S.Data.',tname,'= dtempout(:,',x,');']);
      if ~isempty(nullval)

         %The 'find null and replace which used to look like this:
         %
         %eval(['S.Data.',tname,'(find((0.0001*(round(10000*(S.Data.',tname,')))) == nullval))=NaN;']   );
         %
         %Has been replaced with the following rather ingenious bit of code, employing the format specifiers
         %found in the parameter header instead of the ROUND function:

         eval(['S.Data.',tname,'(find((str2num(sprintf([''%0'',num2str(S.Parameter_Header{',num2str(y),...
               '}.Print_Field_Width),''.'',num2str(S.Parameter_Header{',num2str(y),...
               '}.Print_Decimal_Places),''f\n''],S.Data.',tname,')))==nullval))=NaN;']);

         %'Great things are not done by impulse,
         % but by a series of small things brought together.'
         %				- Vincent van Gogh
         %
         %DFSK November 29, 1999.

      end

   end
end
S.filename = filename;
format short ;

S = updateodf(S);



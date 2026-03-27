function A=updateodf(A)
% Updates all header information stored in an ODF structured array.
%
%Description: UPDATEODF goes through the ODF data and updates the ODF headers accordingly.
%             Fields that are updated:
%             Event_header      creation_date
%                               start_date_time
%                               end_date_time
%             Parameter_header  minimun_value
%                               maximum_value
%                               number_valid
%                               number_null
%                               depth
%             Record_header     num_history
%                               num_cycle
%                               num_param
%                               num_swing
%                               num_calibration
%
%             As of 2004-02-26, UPDATEODF will also wrap event comments to
%             80 columns or less.
%
% Syntax:
%Usage:A = updateodf(A)
%
%Input:
%A : the ODF structured array to be updated.
%
%Output:
%A : the updated ODF structured array.
%
%Example:
%
%A = updateodf(A)
%
%
% Documentation Date: Oct.17,2006 14:46:10
%
% Tags:
% {ODSTOOLS} {ODF} {TAG}
%
%Other Notes: UPDATEODF is called by write_odf and is not normally required by the user
%

%A.ODF_Header.File_Spec = cellstr(bfspec(A));
timecheck = 0;
prescheck = 0;
dephcheck = 0;
len = (NaN);

for i = (1:(length(A.Parameter_Header)))
	   if isfield(A.Parameter_Header{i},'WMO_Code')
    	  wmo = char(A.Parameter_Header{i}.WMO_Code);
	   else
   	  wmo = char(A.Parameter_Header{i}.Code);
	     wmo = wmo(1:4);
   	end

		wmo = upper(wmo);
        
      % added this so as not to be rounding Min/Max before final writing to odf file,
      % arbitrarily chose 25.10f - num2str default (i.e. when no format
      % provide) was 4 decimal places
      prntform = '%25.10f';   
      eval(['A.Parameter_Header{',num2str(i),'}.Minimum_Value=num2str(min(A.Data.',char(A.Parameter_Header{i}.Code),'), prntform);']);
      eval(['A.Parameter_Header{',num2str(i),'}.Maximum_Value=num2str(max(A.Data.',char(A.Parameter_Header{i}.Code),'), prntform);']);
      eval(['A.Parameter_Header{',num2str(i),'}.Number_Valid=sum(~isnan(A.Data.',char(A.Parameter_Header{i}.Code),'));']);
      eval(['A.Parameter_Header{',num2str(i),'}.Number_NULL=sum(isnan(A.Data.',char(A.Parameter_Header{i}.Code),'));']);
      eval(['len(',num2str(i),') = length(A.Data.',char(A.Parameter_Header{i}.Code),');']);
   	if strcmp(wmo,'PRES')==1
      	prescheck = 1;
   	end
   	if strcmp(wmo,'DEPH')==1
      	dephcheck = 1;
    end
    if isempty(deblank(char(A.Parameter_Header{i}.Units)))
        A.Parameter_Header{i}.Units = cellstr('none');
    end

end


A.Event_Header.Creation_Date = cellstr(mdate(datevec(now)));


if isfield(A.Data,'SYTM_01')
   	  A.Event_Header.Start_Date_Time = cellstr(mdate(gregorian(minnan(A.Data.SYTM_01))));
        A.Event_Header.End_Date_Time = cellstr(mdate(gregorian(maxnan(A.Data.SYTM_01))));
    else
      if isempty(A.Event_Header.Start_Date_Time)
   	    A.Event_Header.Start_Date_Time = cellstr('18-NOV-1858 00:00:00.00');
      end

      if isempty(A.Event_Header.End_Date_Time)
   	    A.Event_Header.End_Date_Time = cellstr('18-NOV-1858 00:00:00.00');
      end

    end

% if dephcheck==1
%    if ~isnan(min(A.Data.DEPH_01))
%      A.Event_Header.Min_Depth = min(A.Data.DEPH_01);
%      A.Event_Header.Max_Depth = max(A.Data.DEPH_01);
%    end
%
%
%
% elseif prescheck==1
%   	A.Event_Header.Min_Depth = sw_dpth(min(A.Data.PRES_01), A.Event_Header.Initial_Latitude);
%      A.Event_Header.Max_Depth = sw_dpth(max(A.Data.PRES_01), A.Event_Header.Initial_Latitude);
%
% end

for i = (1:(length(A.Parameter_Header)))
   if A.Parameter_Header{i}.Depth==-99
      A.Parameter_Header{i}.Depth = A.Event_Header.Max_Depth;
   end
end

%Check for same number of cycles in each parameter.

for i = (1:(length(A.Parameter_Header)))
   if len(i)~=len(1)
      error('Data categories are not all the same length.');
   end
end

A.Record_Header.Num_Param = length(A.Parameter_Header);
A.Record_Header.Num_History = length(A.History_Header);
A.Record_Header.Num_Swing = length(A.Compass_Cal_Header);
A.Record_Header.Num_Calibration = length(A.Polynomial_Cal_Header);

if ~isnan(len)
   A.Record_Header.Num_Cycle = len(1);
else
   A.Record_Header.Num_Cycle = 0;
end

%event comments modification
Txcom = [];
for n = 1:length(A.Event_Header.Event_Comments)
    Txcom = [Txcom;textwrap(cellstr(char(A.Event_Header.Event_Comments{n})),80)];
end


A.Event_Header.Event_Comments = Txcom;




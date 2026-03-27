function A=updateodf_headers(A)
% Updates all header information stored in an ODF structured array.
%
% Description:
% Updates all header information stored in an ODF structured array.
%
% Syntax:
%  A=updateodf(A)
% Where A is the ODF Structured Array.
%
% Documentation Date: Oct.17,2006 14:47:01
%
% Tags:
% {ODSTOOLS} {ODF} {TAG}
%
%
%

timecheck = 0;
prescheck = 0;
dephcheck = 0;

for i = (1:(length(A.Parameter_Header)))
	   if isfield(A.Parameter_Header{i},'WMO_Code')
    	  wmo = char(A.Parameter_Header{i}.WMO_Code);
	   else
   	  wmo = char(A.Parameter_Header{i}.Code);
	     wmo = wmo(1:4);
   	end

		wmo = upper(wmo);
   	if strcmp(wmo,'PRES')==1
      	prescheck = 1;
   	end
   	if strcmp(wmo,'DEPH')==1
      	dephcheck = 1;
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


A.Record_Header.Num_Param = length(A.Parameter_Header);
A.Record_Header.Num_History = length(A.History_Header);
A.Record_Header.Num_Swing = length(A.Compass_Cal_Header);
A.Record_Header.Num_Calibration = length(A.Polynomial_Cal_Header);


%event comments modification
Txcom = [];
for n = 1:length(A.Event_Header.Event_Comments)
    Txcom = [Txcom;textwrap(cellstr(char(A.Event_Header.Event_Comments{n})),80)];
end


A.Event_Header.Event_Comments = Txcom;




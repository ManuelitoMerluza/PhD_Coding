function   [y,m,d] = Ymd_Dnr(dnr)
% [year,month,day] = Ymd_Dnr(daynumber)
%	Converts a daynumber to conventional date
%
%	See also inverse function Day_Nr(year,month,day) .
%	Try:	[y,m,d] = ymd_dnr(day_nr([94,95;96,97],2,29))
%	Function Ymd_Dnr uses the Gregorian calendar throughout,
%	i.e. its application is questionable for daynumbers < -149462 .
%	16-bit signed int inputs range from 15-Apr-1902 to 17-Sep-2081 .
%	Gregorian year is 365.2425 days; tropical year is 365.2422 days.
%
%	Copyright (c) 1995 by P.T.Pilgram (Paul.T.Pilgram@mchp.siemens.de)
%	Use is granted as long as this copyright notice
%	appears in every copy, including modified copies.

%	The code is vectorised and contains neither FOR nor WHILE.
%#inbounds
%#realonly
  mbint(dnr)
  y =  dnr - 2982;
  mbint(y)
  y =   y  - floor(y/146097);		% 400 year correction
  y =   y  + floor(y/ 36524);		% 100 year correction
  y =   y  - floor(y/  1461);		%   4 year correction
  y = 2000 + floor(y/   365);		% 365 days are a normal year
  d = (1992-y)*365 + (fix(y/100) - fix(y*.25) - fix(y/400)) + (dnr + 423);
  mbint(d)
  y = y-(d<0);,  d = (365-d).*(d<0)+d;	% 00-Mar is really 29-Feb
  m = fix((d*5 + 461)/153);		% Month (magic formula!)
  mbint(m)
  nout = nargout;
  mbintscalar(nout)
  if  2<nout, d=fix((457-m*153)/5)+(d+1);, end	% Day in the month
  y = y+(12<m);,  m = m-(12<m)*12;	% Jan+Feb belonged to prev yr
% End of Ymd_Dnr	%  How about calling it:  rN_yaD

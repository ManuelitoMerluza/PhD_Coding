function  n = Day_Nr(year, month, day)
% daynumber = Day_Nr(year, month, day)
%	Computes the number of days relative to 01-Jan-1992 .
%
%	See also inverse function Ymd_Dnr(daynumber) .
%	Years 0 to 99 are mapped to 2000 to 2025 and 1926 to 1999,
%	all other years are taken as they are.
%	Function Day_Nr uses the Gregorian calendar throughout,
%	i.e. its application is questionable before 15-Oct-1582.
%	16-bit signed int results range from 15-Apr-1902 to 17-Sep-2081
%	Get weekday by rem(day_nr(y,m,d)+3,7)  0=Sun, 1=Mon, ... 6=Sat
%	(Add 7 if rem's result is negative.)
%
%	Today's daynumber:
%	c = clock;,    d = day_nr(c(1),c(2),c(3));
%
%	Copyright (c) 1995 by P.T.Pilgram (Paul.T.Pilgram@mchp.siemens.de)
%	Use is granted as long as this copyright notice
%	appears in every copy, including modified copies.

%	Function Day_Nr is vectorised (hence the funny code).
%#inbounds
%#realonly
  mbint(year )
  mbint(month)
  mbint(day  )
  a    = [118 87 424 393 363 332 302 271 240 210 179 149 NaN];
  mbvector(a)		% NaN ist kein int !
  year = year + (year< 26) *2000;
  year = year + (year<100) *1900;
  y    = year - (month<3);
  mbint(y)
  m    = month;
  r    = find( m<1 | 12<m );	% Errors
  mbintvector(r)
  m(r) = 13*ones(size(r));
  m(:) = a(m);
  n    = (y-1992)*365 + (floor(y*.25) - floor(y/100) + floor(y/400)) + (day-m);
% Inputs could be checked by converting back and comparing.

%% Test program:
% L = [31,0,31,30,31,30,31,31,30,31,30,31];
% t=0;
% for year=1992:2092
%   L(2)=28+(0==rem(year,4));
%   for month=1:12
%     for day=1:L(month)
%       v = day_nr(year,month,day);
%       if v ~= t
%	   warning = sprintf('day_nr(%d,%d,%d)=%d, but should be %d\n', ...
%		year,month,day, v, t)
%	   month=[];,  year=[];,  break
%       end
%       t=t+1;
%     end
%   end
% end

function [hours]=hms2h(h,m,s);
%Converts hours, minutes, and seconds to hours
%
% Source:  Rich Signell rsignell@usgs.gov
%
% Description:
%Converts hours, minutes, and seconds to hours
%
% Syntax:
%  Usage:  [hours]=hms2h(h,m,s);   or [hours]=hms2h(hhmmss);
%
% Documentation Date: Oct.17,2006 10:23:00
%
% Tags:
% {ODSTOOLS} {TAG}
%
%
%
%  Rich Signell rsignell@usgs.gov
%
if nargin== 1,
   hms=h;
   h=floor(hms/10000);
   ms=hms-h*10000;
   m=floor(ms/100);
   s=ms-m*100;
   hours=h+m/60+s/3600;
else
   hours=h+(m+s/60)/60;
end

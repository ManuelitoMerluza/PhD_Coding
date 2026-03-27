function [hour,min,sec]=s2hms_nr(secs)
% S2HMS converts seconds to integer hour,minute,seconds, without rounding
% off the number of seconds.
%
% Description:
% S2HMS converts seconds to integer hour,minute,seconds, without rounding
% off the number of seconds.
% 
% Syntax: 
% [hour,min,sec]=s2hms_nr(secs)
%
% Documentation Date: Oct.01,2007 14:00:57
% 
% Tags:
% {TAG} {TAG} {TAG}
% 
%
%Class: Third Party Toolbox: ADCPTOOL
sec=floor(secs);
hour=floor(sec/3600);
min=floor(rem(sec,3600)/60);
sec=(rem(secs,60));

function [ lon_cont, discont ]  = long_cont(lon)
% key: scans the longitude intervals of the lon table
%      shifts some points of 360 deg to make it continous
% synopsis :  [ lon_cont, discont ]  = scan_longitude(lon)
%    loncont will be the corrected longitude
%    discont, the index preceeding the discontinuity
%
% description : 
%  depending upon the situation ( from 359 to 0 or 180 to -180 )
%  the array long_cont is changed to have continous longitude.
%
% uses :
%
%  side effects :  
%
%  only 1 discontinuity accepted
%  the longitudes must be homogenous : 180 -> 181 -> -178 will bug !
%
%  author : A.Ganachaud, Feb 95
%
% see also : sublong.m long_cont.m

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sz = size(lon);
if sz(2) ~= 1
  lon = lon';
end
n  = length(lon);
ii = find(abs(lon(1:n-1) - lon(2:n)) > 180);
if ~isempty(ii)
   if length(ii) > 1 
      error('scan_longitude: 2 longitude discontinuities, be careful');
%      lon = [lon(1:ii(1));scan_longitude(lon(ii(1)+1:n)) ];
   end
   ind = ii(1);
   if (lon(ind+1) - lon(ind)) < -180		% ->
	if lon(ind) > 180			% 359 -> 1	
	   lon(1:ind)   = lon(1:ind)   - 360;
  	else					% 179 -> -179
	   lon(ind+1:n) = lon(ind+1:n) + 360;
	end
   else						% <-
	if lon(ind) < 0				% 179 <- -179
	   lon(1:ind)   = lon(1:ind)   + 360;
	else	 				% 359 <- 0
	   lon(ind+1:n) = lon(ind+1:n) - 360;
   	end
   end
else
  ind=[];
end
if sz(2) ~= 1
  lon = lon';
end
lon_cont = lon ;
discont  = ind;

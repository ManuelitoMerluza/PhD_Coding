function [lat,lon,station,time] = woce_sum(flname)
%function [lat,lon,station,time] = woce_sum(flname)
%
% reads in standard WOCE *.sum files (as designated in table 3.5 in the
% 'Requirements for WOCE Hydrograhic Programme Data Reporting'
% 
% Inputs:
%   flname: full name and path of *.sum file
%   
% Outputs: (vectors with matched entries for each station)
%   lat: latitude 
%   lon: longitude
%   station: station number
%   time: decimal year time (e.g. 1992.34982)
%   
%   If the Sum file contains multiple entries for each station the values
%   correspnding to the bottom of the cast are returned.  
%   
% Paul E. Robbins  copywrite 1995

fid = fopen(flname,'r');
if fid == -1
  disp(['File ',flname,' not found'])
  break
end

%read in four lines of header data
hdr1 = fgetl(fid);
hdr2 = fgetl(fid);
hdr3 = fgetl(fid);
hdr4 = fgetl(fid);

%use line 3 to figure out positions of desired columns
iexpo    = findstr(hdr3,'EXPOCODE');
isect    = findstr(hdr3,'SECT');
istation = findstr(hdr3,'STNNBR');
icast    = findstr(hdr3,'CASTNO');
idate    = findstr(hdr3,'DATE');
iutc     = findstr(hdr3,'TIME');
icode    = findstr(hdr3,' CODE')+1;
ilat     = findstr(hdr3,'LATITUDE');
ilon     = findstr(hdr3,'LONGITUDE');
inav     = findstr(hdr3,'NAV');

i = 0;

%  while 1
for j = 1:1000;
  ln = [];ln = fgetl(fid);
  if ~isstr(ln) | all(ln == ' ') | length(ln) < 10 break; end % check if EOF or blank line
  %pad the line to full length if not long enough
  if length(ln) < inav;  
    ln = [ln blanks(inav-length(ln))];
  end;
    
  sect(j,:) = ln(isect:isect+4);
  station(j) = str2num(ln(isect+5:istation+6));
  cast(j) = str2num(ln(istation+7: icast+6));
  
  % convert data and utc to a decimal year
  month= str2num(ln(idate:idate+1));
  day = str2num(ln(idate+2:idate+3));
  year = 1900+str2num(ln(idate+4:idate+5));
  hour = str2num(ln(iutc:iutc+1));
  if hour == []; hour = 0; end
  minutes  = str2num(ln(iutc+2:iutc+3));
  time(j) =  year + cal2dec(month,day,hour,minutes)/365.25;
  code(j,1:2) =ln(icode+3:icode+4);

   
%  if ~strcmp(junk,10)
   %  read in latitude
   latstr = ln(ilat:ilon-1);
   %find blanks and retain only index to first blank if multiple blanks
   blnks = find(latstr == ' '); 
   blnks([0 diff(blnks) == 1]) = []; blnks(blnks == 1) = [];
   if length(blnks) < 3 	%assume empty or courrpted
     lat(j) = nan;
   else
     latint = str2num(latstr(1:blnks(1)));
     latmin = str2num(latstr(blnks(1):blnks(2)));
     hemisphere = latstr(blnks(3)-1);
     if strcmp(hemisphere,'N')
       lat(j) = latint + latmin/60;
     elseif  strcmp(hemisphere,'S')
       lat(j) = -latint - latmin/60;
     else
       lat(j) = nan; 	%if can't determine hemisphere	consider bogus
     end
   end
    %  read in longitude
   lonstr = ln(ilon:inav-1);
   blnks = find(lonstr == ' ');
   blnks([0 diff(blnks) == 1]) = [];blnks(blnks == 1) = [];
   if length(blnks) < 3 	%assume empty or courrpted
     lon(j)= nan;
   else
     lonint = str2num(lonstr(1:blnks(1)));
     lonmin = str2num(lonstr(blnks(1):blnks(2)));
     hemisphere = lonstr(blnks(3)-1);   
     if strcmp(hemisphere,'E')
       lon(j) = lonint + lonmin/60;
     elseif strcmp(hemisphere,'W')
       lon(j) = -lonint - lonmin/60;    
     else
       lon(j)= nan;
     end
   end
end


fclose(fid);
% check for multiple entries per station
if any(diff(station) == 0) ;
  newstation = station;
  newstation(find(diff(newstation) == 0)) = [];
  newlat  = nan*newstation; newlon = newlat; newtime  = newlat;
  for i = 1:length(newstation);
    fs = find(newstation(i) == station);
    %check to see if any station entries are for bottom and use that time if
    %it exists
    
    found = 0;
    for j = 1:length(fs)
      if strcmp(code(fs(j),:),'BO')
	found = 1;
	newtime(i) = time(fs(j));
	newlat(i) = lat(fs(j));
	newlon(i) = lon(fs(j));
      end
    end
    if found == 0;  % if no bottom time found use start time
      for j = 1:length(fs)
	if strcmp(code(fs(j),:),'BE')
	  found = 1;
	  newtime(i) = time(fs(j));
	  newlat(i) = lat(fs(j));
	  newlon(i) = lon(fs(j));
	end
      end
    end
    %check to see if a lat and lon value is found
    if isnan(newlat(i)) | isnan(newlon(i));
      %use mean value of all non nan entries
      alllon  =lon(fs);
      alllat = lat(fs);
      newlon(i)  = mean(alllon(~isnan(alllon)));
      newlat(i)  = mean(alllat(~isnan(alllat)));
    end
    if isnan(newtime(i))
      alltime  = time(fs);      
      newtime(i) =  mean(alltime(~isnan(alltime)));
    end
    
 end   
 station = newstation;  
 lat = newlat;
 lon = newlon;
 time = newtime;
end









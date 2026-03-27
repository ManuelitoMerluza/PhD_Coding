function [p,t,s,o2] = woce_ctd(flname);
%function [p,t,s,o2] = woce_ctd(flname); 
%
%Reads in standard WOCE ctd *.wct ascii file specified by flname
%
%Output : (column vectors)
%  p : pressure 
%  t : (in situ) temperature
%  s : salinity 
%  ox: oxygen
%
% Paul E. Robbins copywrite 1995
fid = fopen(flname,'r');

if fid == -1
  disp(['File ',flname,' not found'])
  break
end

% read in 6 lines of header data
for l = 1:6
  line = fgetl(fid);
  disp(line);
end

% read in data block
dat = fscanf(fid,'%f',[6 inf]);

p = dat(1,:);
t = dat(2,:);
s = dat(3,:);
o2 = dat(4,:);
fclose(fid);

p = p(:); t = t(:); s = s(:); o2 = o2(:);
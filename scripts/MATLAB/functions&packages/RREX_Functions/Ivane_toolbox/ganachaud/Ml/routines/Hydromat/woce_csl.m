function [bot,varn,units,qualt1,qualt2] = woce_csl(flname,nvar)
%function [bot,prop_label,units,qwrd1,qwrd2] = woce_bot(flname,nvar)
%
% Reads in standard WOCE.CSL or WOCE.SEA ascii file 
%    Outputs
%       bot - array of data (each row is a bottle sample, columns are property)
%       prop_label - array of string labels specifying property 
%                    for each column of bot
%       units - array of string labels specifying units for each property
%       qwrd1 - data quality word #1 (analyst assesment)
%       qwrd2 - data quality word #2 (DQE assesment)
%       
%    Inputs
%       flname         - full path and name of *.HY2 or *.SEA file
%       nvar    total number of variables          
%
% Ganachaud 1997 from woce_bot             
%(Paul E Robbins copywrite 1995)


%set quality level to highest standard unless otherwise specified
if nargin == 1
  qlevel = 2;
end
fid = fopen(flname,'r');
if fid == -1
  disp(['File ',flname,' not found'])
  break
end

header = fgetl(fid);
propline = fgetl(fid);
%Find positions of quality words
props = reshape(propline(1:nvar*8),8,nvar)';
ok = ~all(props' == ' '); nvar2 = sum(ok);
varn = props(ok,3:8);

unitline = fgetl(fid);
units = reshape(unitline(1:nvar2*8),8,nvar2)';
units = units(:,2:8);

starline = fgetl(fid);

bot = fscanf(fid,'%f',[nvar2 inf]);

bot = bot(1:nvar2,:)'; 

disp(['Loaded ',num2str(size(bot,1)),' bottles of data with ',...
	num2str(nvar2),' variables  from ',flname])

allbad = all(isnan(bot));
if any(allbad)
  disp(' ');  disp(['Eliminating columns of data with no acceptable data...'])
  for j = find(allbad)
    disp(['  ',varn(j,:)])
  end
  bot = bot(:,~allbad);
  varn = varn(~allbad,:);
  units = units(~allbad,:);
end

fclose(fid);


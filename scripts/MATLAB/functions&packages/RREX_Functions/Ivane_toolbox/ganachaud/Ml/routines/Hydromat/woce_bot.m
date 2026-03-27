function [bot,varn,units,qualt1,qualt2] = woce_bot(flname,qlevel)
%function [bot,prop_label,units,qwrd1,qwrd2] = woce_bot(flname,quality_level)
%
% Reads in standard WOCE.HY2 or WOCE.SEA ascii file 
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
%       quality_level  - (optional) specifies which data quality flags to use
%                        data elements which are flagged are assigned to NAN
%                 2 - returns only the 'acceptable' measurements (defualt)
%                 3 - includes 'questionable' measurements
%                 4 - includes 'bad' measurements
%                 9 - returns all data as reported in file: no NAN's assigned
%                 
%Paul E Robbins copywrite 1995


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
qw = findstr(propline,'QUALT');
nvar = fix(qw(1)/8); 		%maximum possible bumber of variables
props = reshape(propline(1:nvar*8),8,nvar)';
ok = ~all(props' == ' '); nvar2 = sum(ok);
varn = props(ok,3:8);

unitline = fgetl(fid);
units = reshape(unitline(1:nvar2*8),8,nvar2)';
units = units(:,2:8);

starline = fgetl(fid);
qualflags = reshape(starline(1:nvar2*8),8,nvar2)';
qualflags = qualflags(:,8)== '*';
nqual = sum(qualflags);			% number of quality flags
nqw = length(qw);			% number of quality words, (1 or 2)

bot = fscanf(fid,'%f',[nvar2+nqw inf]);

qualt1 = bot(nvar2+1,:)';
q1str = reshape(int2str(qualt1),nqual,length(qualt1))';

if nqw == 2
  qualt2 = bot(nvar2+2,:)';
  q2str = reshape(int2str(qualt2),nqual,length(qualt2))';
else
  qualt2 = [];
end

bot = bot(1:nvar2,:)'; 

disp(['Loaded ',num2str(size(bot,1)),' bottles of data with ',...
	num2str(nvar2),' variables  from ',flname])
disp(['Checking quality data flags using quality word #',num2str(nqw)])
if nqw == 2
  q1str = q2str;
end

disp(['Assigning NAN''s where samples not drawn or missing data'])

if qlevel < 9
  j = 0;
  for col = find(qualflags)'
    j = j+1;
    bad = q1str(:,j) =='9' | q1str(:,j)=='5' | q1str(:,j)=='1' ;
             %	| q1str(:,j)=='8' | q1str(:,j)=='7';
    bot(bad,col) = nan*bot(bad,col);
    disp([blanks(5),varn(col,:),': ',num2str(sum(~bad)),' bottles of acceptable data, ',...
	    num2str(sum(bad)),' bottles assigned value of NaN'])
  end
end

if qlevel < 4
  disp(' ')
  disp(['Assigning NAN''s to bad measurements'])
  j = 0;
  for col = find(qualflags)'
    j = j+1;
    bad = q1str(:,j) =='4';
    bot(bad,col) = nan*bot(bad,col);
    disp([blanks(5),varn(col,:),': ',num2str(sum(~isnan(bot(:,col)))),...
	  ' bottles of acceptable data, ',...
    num2str(sum(bad)),' bottles assigned value of NaN'])
  end
end

if qlevel < 3
  disp(' ')
  disp(['Assigning NAN''s to questionable measurements'])
  j = 0;
  for col = find(qualflags)'
    j = j+1;
    bad = q1str(:,j) =='3';
    bot(bad,col) = nan*bot(bad,col);
    disp([blanks(5),varn(col,:),': ',num2str(sum(~isnan(bot(:,col)))),...
	    ' bottles of acceptable data, ',...
	    num2str(sum(bad)),' bottles assigned value of NaN'])
  end
end

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


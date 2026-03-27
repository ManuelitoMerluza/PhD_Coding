function [bot,varn,units,qualt1] = civa_bot(flname,qlevel)

% CIVA_BOT Reads in standard CIVA ascii file 
%
% Usage: [bot,prop_label,units,qwrd1] = civa_bot(flname,quality_level)
%
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
% Alex Ganachaud, July 1998
% From Paul E Robbins original whp_bot routine

%set quality level to highest standard unless otherwise specified
if nargin == 1
  qlevel = 2;
end

fid = fopen(flname,'r');
if fid == -1
  %try to find file in matlab_data directory
  fid = fopen([getenv('MATLAB_DATA'),flname],'r');
  if fid == -1
    fid = fopen([getenv('MATLAB_DATA'),'/bottle/woce/',flname],'r');
    if fid == -1;
       disp(['File ',flname,' not found'])
       break
    end
  end	
end

header = fgetl(fid);
header = fgetl(fid);
propline = fgetl(fid);
%Find positions of quality words
qw = findstr(propline,'lb');
nvar = fix(max(qw)/8)+1; 		% maximum possible number of variables
props = reshape(propline(1:nvar*8),8,nvar)';
ok = ~all(props' == ' '); nvar2 = sum(ok);
varn = props(ok,1:6);
gilb=find(all((varn==(ones(nvar2,1)*'lb    '))')');
%varn(gilb,:)=[];

unitline = fgetl(fid);
units = reshape(unitline(1:nvar2*8),8,nvar2)';
units = upper(units(:,1:7));

starline = fgetl(fid);
qualflags = reshape(starline(1:nvar2*8),8,nvar2)';
qualflags = qualflags(:,4)== '*';
nqual = sum(qualflags);			% number of quality flags

bot = fscanf(fid,'%f',[nvar2 inf]);

vcheck=fscanf(fid,'%s');
if length(bot)<4 | ~isempty( vcheck)
  disp('')
  disp('Problem reading bottle file... Maybe some chars in BTLNBR')
  disp(['look up for this string: ' vcheck])
  error('remove manually !')
end

%construct the quality flag 
nq=length(gilb);
qualt1=bot(gilb(nq),:)';
for ii=1:nq-1
  qualt1=qualt1+bot(gilb(nq-ii),:)'*10^ii;
end
nqw=0;
%qualt1 = bot(nvar2+1,:)';
%q1str = reshape(int2str(qualt1),nqual,length(qualt1))';

if nqw == 2
  qualt2 = bot(nvar2+2,:)';
  %q2str = reshape(int2str(qualt2),nqual,length(qualt2))';
else
  qualt2 = [];
end

%SUPRESS QUALITY FLAG FROM DATA
bot(gilb,:)=[];
nvar2=size(bot,1);
bot = bot'; 
props(gilb,:)=[];
varn(gilb,:)=[];
units(gilb,:)=[];
qualflags(gilb)=[];

disp(['Loaded ',num2str(size(bot,1)),' bottles of data with ',...
	num2str(nvar2),' variables  from ',flname])
disp(['Checking quality data flags using quality word #1'])

qflags = find(qualflags)';

nlines  = ceil(qflags/9);   %number of lines to break up variable report

fprintf(1,'VARIABLE: ')
for col = find(qualflags)'
 fprintf(1,'%s ',props(col,:))
end
fprintf(1,'\n')

fprintf(1,'MISSING: ')
nvq=sum(qualflags);
if qlevel < 9
  j = 0;
  for col = find(qualflags)'
    j = j+1;
%    bad =q1str(:,j) =='9' | q1str(:,j)=='5' | bot(:,col)==-9 | bot(:,col)==-99;
%    bad = q1str(:,j) =='9' | q1str(:,j)=='5' | q1str(:,j)=='1' 
             %	| q1str(:,j)=='8' | q1str(:,j)=='7';
    qtv=fix((qualt1-10^(nvq-j+1)*fix(qualt1/10^(nvq-j+1)))/10^(nvq-j));
    bad= qtv==9 | qtv==5 | bot(:,col)==-9 | bot(:,col)==-99;
    bot(bad,col) = nan*bot(bad,col);
    fprintf(1,' %5i ',sum(bad)) 
  end
end
fprintf(1,'\n')

fprintf(1,'BAD:     ')
if qlevel < 4
  j = 0;
  for col = find(qualflags)'
    j = j+1;
    qtv=fix((qualt1-10^(nvq-j+1)*fix(qualt1/10^(nvq-j+1)))/10^(nvq-j));
    bad = qtv==4;
    bot(bad,col) = nan*bot(bad,col);
    fprintf(1,' %5i ',sum(bad)) 
  end
end
fprintf(1,'\n')

fprintf(1,'QUESTNBL:')
if qlevel < 3
  j = 0;
  for col = find(qualflags)'
    j = j+1;
    qtv=fix((qualt1-10^(nvq-j+1)*fix(qualt1/10^(nvq-j+1)))/10^(nvq-j));
    bad = qtv==3;
    bot(bad,col) = nan*bot(bad,col);
    fprintf(1,' %5i ',sum(bad)) 
  end
end
fprintf(1,'\n')

fprintf(1,'REMAINNG:')
if qlevel < 3
  j = 0;
  for col = find(qualflags)'
    j = j+1;
    ok = sum(~isnan(bot(:,col)));
    fprintf(1,' %5i ',ok) 
  end
end
fprintf(1,'\n')

%Fill with NaN the remaining data:
ginan=find(bot==-9 | bot==-99 | bot==-999 | bot==-9999);
if ~isempty(ginan)
  bot(ginan)=NaN;
  disp('Warning: some data may be unflagged !')
  disp('Check the .sea/.hyd file before proceeding')
  disp('HIT KEYBOARD TO CONTINUE ...............')
  pause;
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

%convert T-90 to T-68 if needed
for j = 1:size(units,1)
  if any(findstr(units(j,:),'ITS-90'));
    disp(['  Converting temperature from ITS-90 to IPTS-68 for ',varn(j,:)])
      bot(:,j) = 1.00024*bot(:,j);
      units(j,:) = 'IPTS-68';
  end
end


fclose(fid);


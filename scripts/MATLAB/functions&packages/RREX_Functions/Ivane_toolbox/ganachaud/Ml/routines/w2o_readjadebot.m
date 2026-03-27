function [oslat,oslon,ostnnbr,Time,obotd,botdat,varname,varunits]=...
w2o_readjadebot(jadefile);
% Read Jade bottle format
disp('  readjade.m ...')

opropnm   ={'otemp','osali','ooxyg','ophos','osili','onita'};
opropunits={'cels', 'g/kg ','umol/kg','umol/kg','umol/kg','umol/kg'};
Maxobs=100;

fid=fopen(jadefile,'r');
lnn=fgetl(fid);

alldata=fscanf(fid,'%f',[23,Inf]);
fclose(fid);

varname=['STNNBR'
  'CASTNO'
  'CTDPRS'
  'CTDTMP'
  'SALNTY'
  'OXYGEN'
  'NITRAT'
  'PHSPHT'
  'SILCAT'
  'SAMPNO'];
botdat(:,1)=floor(alldata(1,:)/10)';
botdat(:,2)=rem(alldata(1,:),10)';
botdat(:,3)=alldata(8,:)';
botdat(:,4)=alldata(10,:)';
botdat(:,5)=alldata(13,:)';
botdat(:,6)=alldata(17,:)';
botdat(:,7)=alldata(19,:)';
botdat(:,8)=alldata(20,:)';
botdat(:,9)=alldata(21,:)';
botdat(:,10)=NaN*alldata(1,:)';
ginan=find(botdat==-9);
botdat(ginan)=NaN;

varunits=['       '
  '       '
  '  DBARS'
  '   DEGC'
  ' PSS-78'
  'UMOL/KG'
  'UMOL/KG'
  'UMOL/KG'
  'UMOL/KG'];

oslat=alldata(22,:)';
oslon=alldata(23,:)';
Time= 1989+cal2dec(alldata(3,:)',alldata(2,:)',...
  floor(alldata(4,:)'),100*rem(alldata(4,:)',1))/365.25;
obotd=alldata(7,:)';

%Put the station number alone in order to avoid repeats
  %1: find first indice of each station
  stat_fstdata=find([1;diff(botdat(:,1))]);
  ostnnbr=botdat(stat_fstdata,1);
  obotd=obotd(stat_fstdata);
  oslat=oslat(stat_fstdata);
  oslon=oslon(stat_fstdata);
  Time=Time(stat_fstdata);
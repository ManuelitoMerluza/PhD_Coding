function [oslat,oslon,ostnnbr,Time,obotd]=w2o_readcivahdr(civafile);
% Read CIVA bottle format
disp('  w2o_readcivahdr.m ...')


fid=fopen(civafile,'r');

lnn=fgetl(fid);
lnn=fgetl(fid);

alldata=fscanf(fid,'%f',[8,Inf]);
fclose(fid);

ostnnbr=floor(alldata(1,:)'/10);
Time= 1900 + alldata(4,:)' + cal2dec(alldata(3,:)',alldata(2,:)',...
  floor(alldata(5,:)'),100*rem(alldata(5,:)',1),alldata(4,:)')/365.25;
oslat=alldata(6,:)';
oslon=alldata(7,:)';
obotd=alldata(8,:)';

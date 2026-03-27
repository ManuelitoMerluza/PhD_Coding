function [botdat,varname,varunits]=p14s_bot(botfile)
% Read Bullister p14s bottle format

disp('  p14s_bot.m ...')

varname=  ['STNNBR';'CASTNO';'SAMPNO';'CTDPRS';'CTDTMP';'SALNTY';'OXYGEN';...
  'SILCAT';'PHSPHT';'NITRAT';'NITRIT';' THETA';'CTDSAL'];
varunits= ['       ';'       ';'       ';'   DBAR';'       ';'       ';'UMOL/KG';...
  'UMOL/KG';'UMOL/KG';'UMOL/KG';'UMOL/KG';'       ';'       '];
ist=1;
ism=2;
ipr=9;
isc=10;
isa=12;
ipt=14;
iox=16;
isi=18;
iph=20;
ina=22;
ini=24;

fbot=fopen(botfile,'r');
lnn1=fgetl(fbot);
lnn2=fgetl(fbot);
alldata=fscanf(fbot,'%f',[25,Inf]);
fclose(fbot);

alldata=alldata';
%MASK BAD DATA
%USING QUALITY FLAG
for ivar=[ism,isc,isa,iox,isi,iph,ina,ini]
  gibad=find(alldata(:,ivar+1)~=2);
  alldata(gibad,ivar+1)=NaN;
end
%MASK USING -9 FLAG
gibad=find(alldata==-9);
alldata(gibad)=NaN;

%ELIMINATE DATA WITH NO PRESSURE
gigood=find(~isnan(alldata(:,ipr)));
alldata=alldata(gigood,:);

disp('   not cast information. All set to one')
ndat=size(alldata,1);
casts=ones(ndat,1);
botdat=[alldata(:,ist), casts, ...
    alldata(:,[ism,ipr,ipt,isa,iox,isi,iph,ina,ini,ipt,isc])];

%CONVERT POT TEMP TO TEMP
botdat(:,5)=sw_temp(alldata(:,isc),alldata(:,ipt),alldata(:,ipr),0);


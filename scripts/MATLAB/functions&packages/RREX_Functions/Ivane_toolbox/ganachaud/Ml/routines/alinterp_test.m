%TEST FOR ALINTERP.F

x=1:10;
y=sin(x);
xd=1:.1:9;
w1=20;
w2=20;
wl1=0;
wl2=0;

x=[0 9.9 10];
y=[0 10 0]
xd=0:.1:10;
yd=alinterpg(y,x,xd,w1,w2,wl1,wl2);

clf;
%plot(-1:0.01:1,(-1:0.01:1).^2);hold on
plot(x,y,'bo');hold on;
plot(xd,yd,'r+')

[yd1,dyd1]=polintg(x,y,xd);
plot(xd,yd1,'gs')

%LOAD RAW BOTTLE DATA
  bottobsmaskfile='/data35/ganacho/A9/A9.observed_obsmask.mat';
  eval(['load ' bottobsmaskfile])
  %VARIABLES IN OBS FILE
  nstat=111;
  nvar=12;
  ndep=70;
  reclen=ndep*(nvar+1); %first in the pressure
  
  
  oallprops=NaN*ones(ndep,nstat,nvar);
  [fid,message]=fopen('/data35/ganacho/A9/A9.observed','r');
  for is=1:nstat
    [record,ct]=fread(fid,[reclen],'float32');
    if ct<reclen
      error('Not the right number of station/variables')
    end
    for iprop=1:nvar
      oallprops(:,is,iprop)=record((iprop-1)*ndep+1:(iprop*ndep));
    end %iprop
  end %is
  [record,ct]=fread(fid,[reclen],'float32')
  fclose(fid);
  
  %READ ALISON'S INTERPOLATED DATA
  %DIRECTORY, HEADER AND FILE
  bottdir='/data39/alison/phd/progs/obs2std/A9/';
  botthdr='A9_run1.hdr';
  botdat= 'A9_run3.std';
  Ndep=37;
  Nprop=7;
  reclen=Ndep*Nprop;
  allprops=NaN*ones(Ndep,nstat,Nprop);
  [fid,message]=fopen([ bottdir botdat],'r');
  for is=1:nstat
    [record,ct]=fread(fid,[reclen],'float32');
    if ct<reclen
      error('Not the right number of station/variables')
    end
    for iprop=1:Nprop
      allprops(:,is,iprop)=record((iprop-1)*Ndep+1:(iprop*Ndep));
    end %iprop
  end %is
  [record,ct]=fread(fid,[reclen],'float32')
  fclose(fid);
  nbhdr=[bottdir botthdr];
  [ship,stnnbr,slat,slon,botp,kt,xdep,nobs,maxd]=...
    read_stathdr(nbhdr,nstat);
    
%EFFECTIVE TEST
  load /data39/alison/phd/data/stdd.37

  iprop=6;
  for istat=31:50
  oprop=squeeze(oallprops(:,istat,iprop+1));
  opres=squeeze(oallprops(:,istat,1));
  giwet=find(opres>0&oprop~=-999);
  oprop=oprop(giwet);
  opres=opres(giwet);
  clf;
  pl0=plot(oprop,-opres,'bo-');hold on; zoom
  
  aprop=squeeze(allprops(1:maxd(istat),istat,iprop));
  apres=stdd(1:maxd(istat));
  pl1=plot(aprop,-apres,'m+');

  %axis([0 50 -3500 0])
  w1=250;
  w2=400;
  wl1=500;
  wl2=1200;
  [nprop]=alinterpg(oprop,opres,apres,w1,w2,wl1,wl2);
  gnan=find(nprop==-999);
  nprop(gnan)=NaN;
  pl2=plot(nprop,-apres,'kd-');
  ppause
  end
  
  




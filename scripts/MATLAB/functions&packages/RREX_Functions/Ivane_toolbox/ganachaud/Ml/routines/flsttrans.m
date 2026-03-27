%Have a look to the Florida Strait problem

datadir='/data1/ganacho/Hdata/';
secid='flst';
getsdat
dynh=10*dynh;

    %indice of the treatment done on the pair:
	% 1: pair indices that are just maintained (plane fit)
	% 2: pair indices whose velocity will be set to be constant under LCD
        % 3:  --------  set manually
	% 4:  --------  set by const. slope under LCD
	% 5:  --------  polynomial fit
method=5;
p_plt_botwedge=0;
slopmx=1;
p_pos2left=1;

%ISHDP: SHALLOW/DEEP STATION INDICE FOR EACH PAIR
  %(based on deepest observation, not actual depth)
  %initial order:   
  ishdp = [1:Nstat-1; 2:Nstat];
  %'iswitch':
    isw = find( diff(Botp) < 0 ); 
  %switch order if must:
    ishdp([1 2],isw) = ishdp([2 1],isw);
    signp      = p_pos2left * ones(Nstat-1,1); 
    signp(isw) = -1 *p_pos2left* ones(size(isw));

totemp=temp;
distg = 1e3*sw_dist(Slat,Slon,'km');
distt = cumsum(distg);
Npair = Nstat-1;
dst = 1e-3 * [0; distt];          	% linear distance between stations
dpt = 1e-3 * [distt - 0.5 * distg];	% linear distance between pairs  
for ipair=1:Npair
  iss   = ishdp(1,ipair);	%shallow station index 
  isd   = ishdp(2,ipair);	%deep    station index
  stemp = temp(:,iss);
  dtemp = temp(:,isd);
  ssali = sali(:,iss);
  dsali = sali(:,isd);
  sdynh = dynh(:,iss);
  ddynh = dynh(:,isd);
  ptemp = 0.5 * (stemp + dtemp); 
  psali = 0.5 * (ssali + dsali); 
  if ipair==4
    p_plt_botwedge=0;
  else
    p_plt_botwedge=0;
  end 					
  %extrapolate shal and pair temp in bottom triangle using g_botwedge
  [stemp,ptemp,dtemp] = g_botwedge(method, p_plt_botwedge, ipair, ...        
    Propnm(Itemp,:), Propunits(Itemp,:), Presctd, ...
    stemp, Maxd(iss,Itemp), dtemp, Maxd(isd,Itemp), ptemp, ...
    distg(ipair), slopmx);
  [ssali,psali,dsali] = g_botwedge(method, p_plt_botwedge, ipair, ...        
    Propnm(Isali,:), Propunits(Isali,:), Presctd, ...
    ssali, Maxd(iss,Isali), dsali, Maxd(isd,Isali), psali, ...
    distg(ipair), slopmx);
  idtrig = Maxd(iss,Itemp) : Maxd(isd,Itemp);
  swgp = sw_gpan(ssali(idtrig), stemp(idtrig), Pres(idtrig));
  sdynh(idtrig) = sdynh(Maxd(iss,Itemp)) - swgp(1) + swgp;
  totemp(:,iss)=stemp;

  idtrig = Maxd(iss,Itemp) : Maxd(isd,Itemp);
  swgp = sw_gpan(ssali(idtrig), stemp(idtrig), Pres(idtrig));
  sdynh(idtrig) = sdynh(Maxd(iss,Itemp)) - swgp(1) + swgp;
  % geostrophic velocity (cm/s):
  gvel(:,ipair) = 100*signp(ipair)* ...
    sw_gvel([sdynh,ddynh], Slat([iss isd]), Slon([iss isd]));
end%ipair

 
%GEOSTROPHIC VELOCITY
%SETS THE REFERENCE LEVEL TO THE LAST COMMON DEPTH IF IT WAS 
%UNDERNEATH
limitdep=Botp(ishdp(1,:));
gis_at_bot=find(1000>limitdep);
rlpres(gis_at_bot)=limitdep(gis_at_bot);
% R.L.VELOCITY
Pbotp=Botp(ishdp(2,:));
rlgv= getsigprop(Presctd,gvel,Pbotp,rlpres');
%rlgv= getsigprop(Presctd,gvel,Pbotp,Pbotp);
% RELATIVE VELOCITY IN CM/S
Ndep=length(Presctd);
grelvel=(gvel-ones(Ndep,1)*(rlgv')); %in cm/s


gidry=find(isnan(gvel));
Maxdp = Maxd(ishdp(2,:),:);
A0=mk_A0(1,MPres,Pres,Botp,Slat,Slon,ptemp,Maxd,Maxdp,Npair);
geotrans=A0.*grelvel/100/1e6;
giswet=find(~isnan(geotrans));
sum(sum(geotrans(giswet)))

if 0
f1;clf;
cinterval=0:1:40;
[c,h]=contour(dst,-Pres,totemp,cinterval);
axis([0 max(dst) -900 0])
h=clabel(c,h);
set(h,'fontsize',6)
hold on;plot(dst,-Pres(Maxd),'ko');
plot(dst, -Botp,'linewidth',1);

f2;clf;
cinterval=-200:10:200;
[c,h]=contour(dpt,-Pres,grelvel,cinterval);
axis([0 max(dst) -900 0])
h=clabel(c,h);
set(h,'fontsize',6)
hold on;plot(dst,-Pres(Maxd),'ko');
plot(dst, -Botp,'linewidth',1);
end
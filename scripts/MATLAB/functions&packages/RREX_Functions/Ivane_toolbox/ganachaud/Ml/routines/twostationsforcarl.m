popestran
ip=15;
ss=sali(:,ip:ip+1);
st=temp(:,ip:ip+1);
seta=Eta(ip:ip+1);
slat=Slat(ip:ip+1);
slon=Slon(ip:ip+1);
pres=Pres;

svs=-100*sw_gvel(9.8*seta',slat,slon);
dys=sw_gpan(ss,st,pres);
pvel=100*sw_gvel(dys,slat',slon');
pvela=ones(length(pres),1)*svs+pvel;
 
save forcarl.mat ss st seta slat slon pres pvela dbin

%TEST OF THE DENSITY ROUTINE FROOM STEVE
load forcarl
path('/data31/surje/matlab/',path)
for il=1:2
  for i=1:18
    d1(i,il)=1000+density(st(i,il),ss(i,il)/1000,i);
  end
end

truepres=sw_pres(pres,slat(1));
d2a=sw_dens(ss,st,pres);
d2b=sw_dens(ss,st,truepres);

clf;
plot(d1,-pres(1:18))
hold on;
plot(d2b,-truepres,'+')

%VELOCITY FROM MY CALCULATION
dynh=sw_gpan(ss,st,pres);
gvel1a=100*sw_gvel(dynh,slat',slon');
m=20;d=d2a;p=pres;

mr= 0.5*(d(2:m,:) + d(1:m-1,:) );
press_diff = diff(p);
top = d(1,:).*(pres(1)*[1 1]);
delta_ga   = (mr.*(press_diff*[1 1]));
intd=cumsum([top;delta_ga]);
gvel1b=100*10*diff(intd')'./mean(d')'/fcoriolis(mean(slat))/...
  1000/sw_dist(slat,slon,'km');

%SAME BUT CORRECTED FOR PRESSURE
m=20;d=d2a;p=truepres;

mr= 0.5*(d(2:m,:) + d(1:m-1,:) );
press_diff = diff(p);
top = d(1,:).*(pres(1)*[1 1]);
delta_ga   = (mr.*(press_diff*[1 1]));
intd=cumsum([top;delta_ga]);
gvel1c=100*10*diff(intd')'./mean(d')'/fcoriolis(mean(slat))/...
  1000/sw_dist(slat,slon,'km');


%VELOCITY FROM MODEL DENSITY  EQUATION
m=18;d=d1;p=pres;
mr= 0.5*(d(2:m,:) + d(1:m-1,:) );
press_diff = diff(p(1:m));
top = d(1,:).*(p(1)*[1 1]);
delta_ga   = (mr.*(press_diff*[1 1]));
intd=cumsum([top;delta_ga]);
gvel2=100*10*diff(intd')'./mean(d')'/fcoriolis(mean(slat))/...
  1000/sw_dist(slat,slon,'km');

%REFERENCE TO BOTTOM
gvel2=gvel2-gvel2(18);
gvel1a=gvel1a-gvel1a(18);
gvel1b=gvel1b-gvel1b(18);
gvel1c=gvel1c-gvel1c(18);

clf;
pl1=plot(gvel1a,-pres);hold on
pl2=plot(gvel1b,-pres,'+');
pl3=plot(gvel1c,-pres,'o');
pl4=plot(gvel2,-pres(1:18),'.');
legend([pl1;pl2;pl3;pl4],'SW routines','direct integration',...
  'conversion m->db','use model density equation')
grid on
setlargefig

%TRANSPORT
T1a=36000*sum(dbin(1:18).*gvel1a(1:18))/1e6/1e2
T1b=36000*sum(dbin(1:18).*gvel1b(1:18))/1e6/1e2
T1c=36000*sum(dbin(1:18).*gvel1c(1:18))/1e6/1e2
T2=36000*sum(dbin(1:18).*gvel2(1:18))/1e6/1e2

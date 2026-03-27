% Get 36N relative transport
%KEY:
% USAGE :
% 
%
%
%
% DESCRIPTION : 
%
%
% INPUT:  pair data and input paramater file
%
% OUTPUT: 
%                                 in each layer
% OUTPUT FROM mk_set_layprops
%
%      lipres{isb}(ip,il): layer interface pressure
%      rlpres{isb}(ip)   : reference level pressure
%      gvelrel{isb}(id,ip): relative velocity (M/S)
%      Lays{isb}.*      : layer properties
%      Laybs{isb}.*     : layer boundaries(interface) properties
%
%
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , Jul 97
%
% SIDE EFFECTS :
%
% SEE ALSO :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER:
% CALLEE: mkequats.m
clear
p_sub=1; %subsampled version

MASS=1; OXYG=4; 
HEAT=2; PHOS=5; NITA=7;
SALI=3; SILI=6; PO38=8;
propnm(MASS,:)='mass'; propnm(HEAT,:)='heat'; propnm(NITA,:)='nita';
propnm(SALI,:)='sali'; propnm(OXYG,:)='oxyg'; propnm(PO38,:)='po38';
propnm(PHOS,:)='phos'; propnm(SILI,:)='sili';

OPdir='/data1/ganacho/Boxmod/Natl/';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PARAMETERS ON EACH SECTION AND FLUX EQUATIONS

gsecs.name   ={'a36n'};  %NAME
if p_sub
  gsecs.namesuf={'sub_polyfit'};  %SUFFIX
  gsecs.npair=50;                 %TOTAL PAIRS
  boxi.modelid='JustTrelSub';                   %MODEL ID
else
  gsecs.namesuf={'polyfit'};  %SUFFIX
  gsecs.npair=100;                 %TOTAL PAIRS
  boxi.modelid='JustTrel';                   %MODEL ID
end
gsecs.datadir{1}='/data1/ganacho/Hdata/Geovelm/';%DATA DIRECTORY


%(WILL HAVE TO BE CHECKED FOR CONSISTENCY IF MERGED WITH OTHER BOX

%REFERENCE LEVEL
gsecs.rl.ns=[12];                 %LAYER INTERFACE ID

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PARAMETERS FOR THE BOX

boxi.name='natl_XVII';                %BOX NAME
boxi.harea=7.9e12;                    %HORIZONTAL AREA AT SURFACE
boxi.zonalcoast=0;                    %"ZONAL" COAST TOTAL DIST (m)
boxi.nlay=18;
%LAYER INTERFACES
% GAMMA
boxi.glevels=[22 26.44 26.85 27.162 27.38 27.62 27.82 27.922 27.975 28.008, ...
    28.044 28.072 28.0986 28.112 28.1295 28.141 28.154 48]';

%CONSERVATION EQUATIONS 
boxi.conseq.propid=MASS:PO38;

%   FOR EACH SECTION
%     COMPUTE INTERFACE POSITIONS
%     REFERENCE VELOCITY
%     FOR EACH PROPERTY
%       GET INTEGRALS IN EACH LAYER (DX*DY*C AND DX*DY*C*VREL)
%       GET AVERAGE LAYER PROPERTIES
%   GET AVG PROPERTIES FOR THE WHOLE BOX
Nsec=length(gsecs.name); %number of sections
Nlay=boxi.nlay;%number of layers
Nconseq=length(boxi.conseq.propid); %num. of cons. equations

mk_set_layprops

% RESULTING INTEGRALS FOR TRANSPORTS AND A MATRIX:
% lprop{isb,iprop}(ipair,ilay)   = rho * C * DX * DZ  
% lgvprop{isb,iprop}(ipair,ilay) = relvel * rho * C * DX * DZ 
% lunits{iprop} = units for lgvprop and lgvprop*b (if b in cm/s)
% lscale(iprop) = value by which was divided lgvprop to get right units

for iprop=1:Nconseq
  disp(sprintf('CALCULATING %s TRANSPORTS ...',upper(propnm(iprop,:))))
  %COMPUTE NET TRANSPORT FOR EACH SECTION/LAYER
  for isb=1:Nsec
    Tr{isb}(:,iprop)=sum(lgvprop{isb,iprop});
  end %isb
end %iprop
%%%%%%%% PLOTS
if any(strcmp(fieldnames(boxi),'glevels'))
  layids=boxi.glevels;
elseif any(strcmp(fieldnames(boxi),'sigint'))
  layids=boxi.sigint;
end
maxy=-6000;
ifig=0;
windw=0;totwind=6;
ifig=ifig+1;figure(ifig);set(gcf,'position',[17 50 700 900])
if p_sub
  ch=get(gcf,'children');
end
for iprop=1:Nconseq
  %PLOT FLUX
  ylab='Pressure';
  for isb=1:Nsec
    if windw==6
      ifig=ifig+1;figure(ifig); 
      set(gcf,'position',[17 50 700 900]);windw=0;
      if p_sub
	totwind=2;
	ch=get(gcf,'children');
      end
    end
    %Layer interface approx mean depth
    layintd=-[0;cumsum(Lays{isb}.lavgwdth(1:Nlay-1))'];
    
    %RELATIVE T
    windw=windw+1
    if p_sub
      axes(ch(1+totwind-windw))
      [xx,yy]=flstairs(Tr{isb}(1:Nlay-1,iprop),layintd);
      hold on;plot(xx,yy,'k-','linewidth',1)
    else
      ttl=sprintf('%s %s (Relative)', gsecs.name{isb},propnm(iprop,:));
      rxlab=sprintf('Total: %4.2g %s',Tr{isb}(Nlay,iprop),lunits{iprop});
      cpstair1(windw,Tr{isb}(1:Nlay-1,iprop),layintd,[],rxlab,ylab,...
	ttl,layids(2:Nlay-1),0,1,'n',[],0,maxy)
    end
  end %isb
  drawnow
 
end %iprop


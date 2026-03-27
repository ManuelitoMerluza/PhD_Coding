% script ctd2std
% KEY: read and interpolate the ctd data to standart depths
% USAGE : <input file>
%         ctd_treat
%         may be ran by hand
%
% DESCRIPTION : 
%   read ctd data, interpolates on standard depths.
%   fill the holes interactively
%
% INPUT: parameter file, station header file + ctd files
%
% OUTPUT: temp, sali, oxyg and dyn. height in Alex' format
%
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , Nov 97
%
% SIDE EFFECTS :
%
% SEE ALSO :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER:
% CALLEE: ctd_get, ctd_step3
%
% PARAMETERS: 
%     p_plot=0;
%   Header file from bottle data:
%     hdrfile='/data35/ganacho/A9/Obsdata/A9_obs.hdr.mat';
%   Ctd directory
%     ctddir='/data35/ganacho/A9/Woce/';
%   Prefix/suffix of ctd file
%     fctdp='06MT15-3S0';
%     fctds=['C001.ctd';'C002.ctd'];
%    ctd file <fctdp> Stnnbr <fctds> is sought, first with the first suffix
%    then with the second if not found
%
%   standart depth file
%      stddpfile='/data4/ganacho/Hydrosys/stdd.37'
%
%   Station subselection
%     gstatctd=[1:28,30,32:46,54:94,103:111];
%
%   Output files:
%     opdir='/data35/ganacho/A9/Stdddata/';
%   cnamesec='A9';
disp('ctd2std.m ...')
set(0,'defaultaxesfontsize',10) 

disp(['opening diary ' pwd '/ctdtreat.dry'])

if exist('ctdtreat.dry')==2
  unix('rm ctdtreat.dry');
end
diary(['ctdtreat.dry'])

%LOAD HEADER FILE FROM BOTTLE DATA
if exist('hdrfile')
  if 1
    eval(['load ' hdrfile])
  else %former code
    [oship,ostnnbr,oslat,oslon,obotd,okt,oxdep,onobs,omaxd]=...
      read_stathdr(hdrfile,cnstat);
    obotp=sw_pres(obotd,oslat);
  end
  if ~exist('gstatctd')
    gstatctd=1:onstat;
  end
  cship=oship(gstatctd);
  cstnnbr=ostnnbr(gstatctd);
  cslat=oslat(gstatctd);
  cslon=oslon(gstatctd);
  cbotp=obotp(gstatctd);
  ckt=okt(gstatctd);
  cxdep=oxdep(gstatctd);
  onobs=onobs(gstatctd);
  omaxd=omaxd(gstatctd);
  cnstat=length(gstatctd);
else
  disp('no header file: assuming information are in ctd file')
  cnstat=length(gstatctdfromorig);
end

%LOAD STANDART DEPTHS
%eval(['load ' stddpfile])
cpres=(0:50:8000)';
cndep=length(cpres);
stdlim=[0;(cpres(1:cndep-1)+cpres(2:cndep))/2;max(cpres)];

%READ CTD DATA
pottemp=NaN*ones(cndep,cnstat); %pot temp. converted to in situ before saving
sali=NaN*ones(cndep,cnstat);
oxyg=NaN*ones(cndep,cnstat);
dynh=NaN*ones(cndep,cnstat);
cpropnm={'temp','sali','oxyg','dynh'};
cpropunits={'Cels','g/kg','umol/kg','dyn m'};
if exist('phos1') %% for use with Wijffel's Data
  phos=NaN*ones(cndep,cnstat);
  sili=NaN*ones(cndep,cnstat);
  nita=NaN*ones(cndep,cnstat);
  cpropnm={'temp','sali','oxyg','phos','sili','nita','dynh'};
  cpropunits={'Cels','g/kg','umol/kg','umol/kg','umol/kg','umol/kg','dyn m'};
end  
disp('Check units !')
disp(cpropunits(:))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% 1) READ CTD AND PUT THEM ON STANDARD DEPTHS
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ctd_get
save ctdget.mat 

%load ctdget.mat 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% 2) FILL BLANK STATIONS AND MISSING DATA
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%ctd_fill previous version of version of ctd_step3


ctd_step3
disp('done')
disp('')
disp('Converting pot temperature to in situ after extrapolations')
temp=sw_temp(sali,pottemp,cpres,0);
%%%%%%%%%%%%%%%%%%%%%
disp('READY TO SAVE')
ppause
%%%%%%%%%%%%%%%%%%%%%
if p_gpan
  %REFER ALL DYNAMIC HEIGHTS TO THE SURFACE
  for is=1:cnstat
    dynh(:,is)=dynh(:,is)-dynh(1,is);
  end
else
  %COMPUTES DYNAMIC HEIGHT FROM THE GRIDDED T, S
  %(see comments at the top of ctd_fill)
  disp('recomputing dynamic height from gridded data ...')
  dynh=sw_gpan(sali,temp,cpres)/10;
  %Geopot. anomaly in [m^3 kg^-1 Pa == m^2 s^-2 == J kg^-1]
end
save ctdfill.mat
%load ctdfill.mat 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% SAVE DATA INTO ALEX' FORMAT
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~(exist(opdir)==7)
  disp('Creating output directory ...')
  disp(['mkdir ' opdir]);
  unix(['mkdir ' opdir]);
end

for iprop=1:cnprop
  cstatfiles{iprop}=[cnamesec '_stat_c' cpropnm{iprop} '.fbin'];
  cprecision{iprop}='float32';
  eval(['prop=' cpropnm{iprop} ';'])
  ovw=1; %overwrite existing file
  whydro(prop,[opdir cstatfiles{iprop}],cprecision{iprop},cmaxd,ovw);
end
nf_ctdh=[opdir cnamesec '_ctdstd.hdr.mat'];
disp(['SAVING INFO FILE '  nf_ctdh])
eval(['save ' nf_ctdh ' gstatctd cnamesec cstnnbr cnstat cstatfiles '...
    'cbotp cmaxd cprecision opdir cpres ctddir hdrfile fctdp fctds '...
    'cpropnm cpropunits cslat cslon cship ctd2std_rec'])
diary off

ss=input('remove ctdfill.mat ?','s');
if ss=='y'
  unix('rm ctdfill.mat');
end
ss=input('remove ctdget.mat ?','s');
if ss=='y'
  unix('rm  ctdget.mat');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PROPERTY PLOTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('PLOTTING PROPERTIES ... CTRL-C to stop')
gis2plot=1:cnstat;
%gis2plot=1:fix(cnstat/2);
%gis2plot=fix(cnstat/2):cnstat;
for iprop=1:cnprop
  figure(iprop);clf
  prop=rhydro([opdir cstatfiles{iprop}],cprecision{iprop},length(cpres), ...
    cnstat,cmaxd);
  eval([cpropnm{iprop} '=prop;'])
  maxy=min(8000,500*ceil(mmax(cbotp(:))/500));
  if (cpropnm{iprop}=='oxyg')&any(any(prop>100))
    pottemp=sw_ptmp(sali,temp,cpres,0);
    rho = sw_dens(sali,pottemp,0);
    prop=prop.*rho/1000/44.6369;
   punits='ml/l';
  else
    punits=cpropunits{iprop};
  end
  plt_prop(prop(:,gis2plot), cpropnm{iprop}, punits, ...
    Cruise, cpres, cmaxd(gis2plot), cbotp(gis2plot), ...
    cslat(gis2plot), cslon(gis2plot),maxy)
  land;setlargefig;drawnow
end

ss=input('print and close all ? ','s');
if ss=='y'
  dprint(1:cnprop)
end
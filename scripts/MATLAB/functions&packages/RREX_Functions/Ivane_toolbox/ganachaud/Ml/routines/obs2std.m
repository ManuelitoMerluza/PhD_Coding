%Script Obs2std.m
% KEY:   grid the observed bottle data to standard depths
% USAGE :put parameters in memory
%        run the program
% 
% DESCRIPTION : 
%   Three main steps:
%     1-vertical interpolation to patch holes within reasonable range
%     2-vertical extrapolation to the bottom. Interactive if doubts
%       vertical extrapolation to the top if in the mixed layer
%     3-patch interactively the remaining holes (horiz/vert/manual
%       extrapolations/interp. copy)
%
% INPUT:
%    The observed files (variables take in general prefix o
%    The standard depths ascii file
%
% OUTPUT:
%    The sdata interpolated to standard depths (prefix b as bottle)
%
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , Dec 97
%
% SIDE EFFECTS :
%
% SEE ALSO :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER:
% CALLEE: obs2_step1, obs2_step2,  obs2_step3
 
%PARAMETERS :
%Property to treat
%gip2treat=[4:6];
%Station subselection
%gis2get=[1:28,30,32:46,54:94,103:111];

%Standard depth file
%stddpfile='/data4/ganacho/Hydrosys/stdd.37';

%Input directory
%IPdir='/data35/ganacho/A9/Obsdata/';
%Input header file
%hdrobs='A9_obs.hdr.mat';

%Output directory
%OPdir='/data35/ganacho/A9/Stddata/';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  LOAD THE DATA
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%OBSERVED
eval(['load ' IPdir hdrobs])
if ~exist('gip2treat')
  gip2treat=1:onprop;
end;
if ~exist('gis2get')
  gis2get=1:onstat;
end

%DIARY
if exist('obs2std.dry')
  disp('removing old diary ...')
  unix('rm obs2std.dry');
end
disp(['Creating diary ' pwd '/obs2std.dry'])
diary obs2std.dry

%STANDARD DEPTHS
if exist('stddpfile')
  disp(['loading ' stddpfile])
  eval(['load ' stddpfile])
else
  disp(['Standard depths every 50 m'])
  stdd=(0:50:8000)';
  if 0& any(obotp>8000)
    maxstdp=500*ceil(max(obotp)/500);
    stdd=(0:50:maxstdp)';
  end
end
ppause
Ndep=length(stdd);

ompres=size(opres,1);
for iprop=gip2treat
  disp([IPdir ostatfiles{iprop}])
  prop = rhydro([IPdir ostatfiles{iprop}], oprecision{iprop}, ...
    ompres, onstat, omaxd);
  eval([opropnm{iprop} '=prop(:,gis2get);']);
end
isobs=isobs(:,gis2get);
opres=opres(:,gis2get);
obotp=obotp(gis2get);
okt=okt(gis2get);
omaxd=omaxd(gis2get);
onobs=onobs(gis2get);
oship=oship(gis2get);
oslat=oslat(gis2get);
oslon=oslon(gis2get);
ostnnbr=ostnnbr(gis2get);
oxdep=oxdep(gis2get);
onstat=length(gis2get);
if any(obotp==round(obotp))
  disp('Round bottom pressure found... make sure it is in db !')
  %disp(obotp')
  ppause
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  STEP1: VERTICAL INTERPOLATION
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(0,'defaultaxesfontsize',10) 

%1: Set the first observed pressure to zero if < 30db 
gip=find(opres(1,:)<30);
opres(1,gip)=0;
disp('VERTICAL INTERPOLATIONS ...')
obs2_step1
disp(['saving in ' pwd ' obs2_step1.mat ...'])

save obs2_step1.mat

%load obs2_step1.mat
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  STEP2: VERTICAL EXTRAPOLATION DOWN TO THE BOTTOM
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('EXTRAPOLATION AT THE BOTTOM')
obs2_step2
disp(['saving in ' pwd ' obs2_step2.mat ...'])
save obs2_step2.mat

%load obs2_step2.mat

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  STEP3: PATCH REMAINING HOLES
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('INTERACTIVE HOLE PATCHING')
obs2_step3
disp(['saving in ' pwd ' obs2_step3.mat ...'])
save obs2_step3.mat

%load obs2_step3.mat

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  STEP4: CHECK FOR ANOMALIES / ELIMINATE SOME POINTS
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
obs2_step4

gis=input('Which stations do you want to look again ? (RETURN if none)');
istagged=zeros(onstat,1);
if gis,istagged(gis)=1;,end
obs2_step4

%FILL THE ELIMINATED POINTS
obs2_step3

disp(['saving in ' pwd ' obs2_step4.mat ...'])
save obs2_step4.mat

%load obs2_step4.mat


disp('Double check for zero values...')
for ipropstd=1:bnprop
  eval(['bprop=' bpropnm{ipropstd} ';'])
  disp(bpropnm{ipropstd});
  gg=find(bprop<0);
  if ~isempty(gg)
    disp('Negative values detected !')
    disp([gg(:),bprop(gg(:))])
    s5=input('Accept/ set to Zero (a/z)','s');
    if s5=='a'
    else
      bprop(gg)=0;
    end
  end
  eval([bpropnm{ipropstd} '=bprop;'])
end

disp('done')

Pres=stdd;
bmaxd=bmaxd(:);
bslon=oslon(:);
bslat=oslat(:);
bbotp=obotp(:);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% SAVE STANDART DEPTH DATA ...
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('')
disp('SAVING DATA ...')
if ~(exist(OPdir)==7)
  disp('Creating output directory ...')
  disp(['mkdir ' OPdir]);
  unix(['mkdir ' OPdir]);
end
%DATA FILES
for iprop=1:bnprop
  bstatfiles{iprop}=[Secname '_stat_b' bpropnm{iprop} '.fbin'];
  bprecision{iprop}='float32';
  eval(['prop=' bpropnm{iprop} ';'])
  whydro(prop,[OPdir bstatfiles{iprop}],bprecision{iprop},bmaxd)
end

% HEADER FILE
OPhdr=[Secname '_botstd.hdr.mat'];
%convert the variable names with a b prefix as bottle
bnstat=onstat;
Treatment=[Treatment, ' \n Interpolated to standard depths, ' date];
bship=oship;
bstnnbr=ostnnbr;
bxdep=oxdep;
bkt=okt;
gipropobs=gip2treat; %property indice in the obs files (for isobs)
disp(['SAVING HEADER FILE'])
disp([OPdir OPhdr])
eval(['save ' OPdir OPhdr ' Treatment Remarks Cruise Secname '...
    'Secdate bnstat bslat bslon '...
    'bbotp Pres bnprop bmaxd '...
    'bpropnm bpropunits bstatfiles bprecision '...
    'bship bstnnbr bxdep bkt onobs isobs gipropobs opres']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% PLOT PROPERTIES ...
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('')
disp('PLOTTING PROPERTIES ... CTRL-C TO STOP NOW')
close all
set(0,'defaultaxesfontsize','default') 

diary off

gi2plot=1:bnstat;
%gi2plot=1:fix(bnstat/2);
%gi2plot=fix(bnstat/2):bnstat;
distg = 1e3*sw_dist(bslat(gi2plot),bslon(gi2plot),'km');
distt = cumsum(distg);
tdist = 1e-3 * [0; distt];          	% linear distance between stations
for ipropstd=1:bnprop
  figure(ipropstd);clf
  eval(['bprop=' bpropnm{ipropstd} ';'])
  if (strcmp(bpropnm{ipropstd},'oxyg')) & any(any(bprop>100)) 
    disp('approximate conversion to ml/l')
    bprop=bprop/44.6369;
    punits='ml/l';
  else
    punits=bpropunits{ipropstd};
  end
  if ~((strcmp(bpropnm{ipropstd},'oxyg')) & any(any(bprop>100)))
    plt_prop(bprop(:,gi2plot), bpropnm{ipropstd}, punits, ...
      Cruise, Pres, bmaxd(gi2plot), bbotp(gi2plot), ...
      bslat(gi2plot), bslon(gi2plot),min(8000,500*ceil(max(bbotp/500))))
    %SUPERIMPOSE OBSERVATIONS
    ipropobs=gipropobs(ipropstd);
    ch=get(gcf,'children');
    axes(ch(3));hold on;
    omask=ones(size(isobs));
    gimask=find(~bitget(isobs,ipropobs));
    %eval(['gimask=find(isnan(' opropnm{ipropobs} '));'])
    omask(gimask)=NaN;
    plot(tdist,-opres(:,gi2plot).*omask(:,gi2plot),'ko',...
      'markersize',2,'linewidth',.1);
    drawnow;land;setlargefig
  end
end
if input('print figures ? (y/n) ','s')=='y'
  for ipropstd=1:bnprop
   pg;close
 end
end

s='n';
s=input('remove temporary files obs2_step[1,2,3].mat (y/n)?','s');

if s=='y'
  unix('rm obs2_step[1,2,3].mat');
end

s1='n';
s1=input('remove obs2_step4.mat (y/n)?','s');

if s1=='y'
  unix('rm obs2_step4.mat');
end


%Script Obs2_step5.m
% last portion of obs2std.m
% created by Diana to use when running obs2_step3 and obs2_step4
% manually
% (It does not work to cut and paste from the screen because
% in that situation the input commands are not handled correctly)

%obs2_step4

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
    bprop=bprop/44.6369;
    punits='ml/l';
  else
    punits=bpropunits{ipropstd};
  end
  plt_prop(bprop(:,gi2plot), bpropnm{ipropstd}, punits, ...
    Cruise, Pres, bmaxd(gi2plot), bbotp(gi2plot), ...
    bslat(gi2plot), bslon(gi2plot),500*ceil(max(bbotp/500)))
  %SUPERIMPOSE OBSERVATIONS
  ipropobs=gipropobs(ipropstd);
  ch=get(gcf,'children');
  axes(ch(3));hold on;
  omask=ones(size(isobs));
  gimask=find(~bitget(isobs,ipropobs));
  omask(gimask)=NaN;
  plot(tdist,-opres(:,gi2plot).*omask(:,gi2plot),'ko',...
    'markersize',2,'linewidth',.1);
  drawnow;land;setlargefig
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


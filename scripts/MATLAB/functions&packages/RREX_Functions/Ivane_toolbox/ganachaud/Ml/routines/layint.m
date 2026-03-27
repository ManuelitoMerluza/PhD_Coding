%function layint
% KEY:
% USAGE :
% 
%
%
%
% DESCRIPTION : find the layers depths and integrates the properties
%  inside the layers.
%
% INPUT: Pair data from geovel output
%
% OUTPUT:Layer data
%
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , Apr 97
%
% SIDE EFFECTS :
%
% SEE ALSO :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER:
% CALLEE: gamman, getsigpres, getsigprop, integlay, SW routines
fen=0;
if fen
  secid='popavg_10_890_a36n_sbsp';
  %secid='pop_875_a36n';
  datadir='/data1/ganacho/SCMODEL/OUTPUT/';
  getpdat
  save -v4 popavg_10_890_a36n_sbsp.mat
else
  load popavg_10_890_a36n_sbsp.mat
end

secid='a36n'
datadir='/data1/ganacho/HDATA/';
getpdat

  %LEVELS OF NEUTRAL DENSITY LAYER INTERFACES:
  glevels = [22 26.44 26.85 27.162 27.38 27.62 27.82 27.922 27.975 28.008, ...
    28.044 28.072 28.0986 28.112 28.1295 28.141 28.154 48];

  %NAME FOR THIS LAYER SET
  layname='set1';
  
  %MULTIPLICATION BY RHO AT INTEGRATION (FOR EACH VARIABLE)
  multiply_by_rho=[1,1,0,1,1,,1];
  
  %REFERENCE LEVEL
  rl.ns=12;
  p_lcdref=1; %reference to last common depth
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PROGRAM STARTS
%
  
  %NEUTRAL DENSITY COMPUTATION FOR ALL POINTS
  disp('COMPUTING NEUTRAL DENSITY ...')
  tic;[pgamn,dgl,dgh] = gamman(psali,ptemp,Pres,Plon,Plat);toc
  disp('DONE')

  %FIND DEPTHS OF THE INTERFACES
  lipres = getsigpres(Pres,Pbotp,Maxdp(:,Itemp),pgamn,glevels);
  %lipres(ip,il) contains the interface il depth (dB), pair ip

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % REFERENCE THE VELOCITY
  %GET REFERENCE LEVEL
  if (~isempty(rl.ns))
    rlpres=lipres(:,rl.ns);
  elseif length(rl.pres)==1
    rlpres=rl.pres*ones(Npair,1);
  else
    rlpres{isb}=gsecs.rl.pres{isb};
  end
  % SETS THE REFERENCE LEVEL TO THE LAST COMMON DEPTH IF IT WAS 
  % UNDERNEATH
  ishdp = [1:Nstat-1; 2:Nstat];isw = find( diff(Botp) < 0 ); 
  ishdp([1 2],isw) = ishdp([2 1],isw);
  if p_lcdref
    limitdep=Botp(ishdp(1,:));
  else
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')
    disp('REFERENCING TO DEEPEST DEPTH !')
    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')
    limitdep=Botp(ishdp(2,:));
  end
  gis_at_bot=find(rlpres>limitdep);
  rlpres(gis_at_bot)=limitdep(gis_at_bot);
  % R.L.VELOCITY
  rlgv= getsigprop(Presctd,gvel,Pbotp,rlpres);
  % RELATIVE VELOCITY IN CM/S
  Ndep=size(Presctd,1);
  grelvel=0.01*(gvel-ones(Ndep,1)*(rlgv')); %in m/s
  clear ishdp limitdep gis_at_bot 
  %plot_vel(cumsum(Sdist{isb}),-Pres,100*grelvel{isb});
  %ppause
 
  %GET THE PROPERTIES AT THE INTERFACE
  litemp=getsigprop(Pres,ptemp,Pbotp,lipres);
  %litemp(ip,il) contains the temperature, at pair ip for interface il
  lisali=getsigprop(Pres,psali,Pbotp,lipres);
  ligvel=getsigprop(Pres,grelvel,Pbotp,lipres);
  
  %DENSITY
  prhoi = sw_dens(psali,ptemp,Pres);
  lirhoi=getsigprop(Pres,prhoi,Pbotp,lipres);
  
  %CONVERT PRESSURE INTO DEPTH FOR INTEGRATION
  [np,Nlay]=size(lipres);
  nd=length(Pres);
  Dep    =sw_dpth(Pres(:,1)*ones(1,np),ones(nd,1)*(Plat'));
  lidep  =sw_dpth(lipres,Plat*ones(1,Nlay));
  Botdep =sw_dpth(Botp,Slat);

  %CORRECT POSSIBLE LAYERS BELOW BOTTOM DUE TO NON LINEAR EFFECTS
  Pbotd=max([Botdep(1:Npair)';Botdep(2:Npair+1)'])';
  allpbot=Pbotd*ones(1,Nlay);
  gitocorrect=find(lidep > allpbot);
  deltad=lidep(gitocorrect)-allpbot(gitocorrect);
  if any(deltad>1)
    error('TOO LARGE CORRECTION TO LAYER BOTTOM DEPTHS')
  end
  lidep(gitocorrect)=allpbot(gitocorrect);

  %INTEGRATE EACH PROPERTY WITHIN THE LAYERS
  sdist=sw_dist(Slat,Slon,'km');
  
  %MASS
  lrhoi=integlay(lidep,lirhoi,Dep,prhoi,sdist,Botdep);
  lrhoigvel=integlay(lidep,lirhoi.*ligvel,Dep,prhoi.*grelvel,sdist,Botdep);
  
  %TEMPERATURE
  %GETS HEAT CAPACITY FOR HEAT FLUX
  pottemp=sw_ptmp(psali,ptemp,Presctd,0);
  htcp=sw_cp(psali,pottemp,0);
  pheat=prhoi.*pottemp.*htcp;
  lhtcp=sw_cp(lisali,litemp,lipres);
  liheat=lirhoi.*litemp.*lhtcp;
  
  lheat=integlay(lidep,liheat,Dep,pheat,sdist,Botdep);
  
  %INTEGRATE OTHER PROPERTIES
  varlist=[];
  for iprop=1:Nprop
    nprop= Propnm(iprop,:);
    disp(['INTEGRATING ' nprop ' ...'])
    eval(['pprop=p' nprop ';'])
    eval(['li' nprop '=getsigprop(Pres,pprop,Pbotp,lipres);'])
    if multiply_by_rho(iprop)
      eval(['l' nprop '=integlay(lidep,lrhoi.*li', nprop ,...
	  ',Dep,prhoi.*p' nprop ',sdist,Botdep);'])
    else
      eval(['l' nprop '=integlay(lidep,li', nprop ,...
	  ',Dep,p' nprop ',sdist,Botdep);'])
    end
    varlist=[varlist, ' li', nprop,' l', nprop];
  end %on iprop
  
  %SAVE RESULTS
  layfname=[datadir secid '_' layname '_lay.mat'];
  disp(['SAVING ' layfname ' ...'])
  eval(['save ' layfname ' glevels multiply_by_rho ligvel ', ...
      'lirhoi lrhoi liheat lheat '  varlist ' pgamn'])

%LAYER FILE CONTENTS
% Nlay: number of layers
% Ndep: number of depths
% Npair: number of pairs
%
% glevels(Nlay): layer interface (neutral) density
% multiply_by_rho(Nprop) MULTIPLICATION BY RHO AT INTEGRATION (1/0)
%
% lipres(Npair,Nlay): pressure of layer interface
% ligvel(Npair,Nlay): geost. velocity at interface (referenced at surface)
% liPROP(Npair,Nlay): PROPerty (temperature, salinity, ... ) value at
%                     layer interface
% lPROP(Npair,Nlay) :    PROPerty integrated across the layer
% lPROPgvel(Npair,Nlay) :PROPerty*gvel integrated across the layer (gvel in m/s)
%  PROP is, in the layer:
%  rhoi for density in situ
%  heat for rhoi*(in situ heat capacity)*temp
%  sali for (rhoi)*sali. Multiplication by rhoi is done if multiply_by_rho=1
%  ...
%
%  pgamn(Ndep,Npair): neutral density 
    
    
 
  %LINES USED FOR TEST
  if 0 
    gip=4%gip=93:100;
    gis=[gip,max(gip)+1];
    lidep=lidep(gip,:);
    Dep=Dep(:,gip);
    Botdep=Botdep(gis);
    lirhoi=lirhoi(gip,:);
    prhoi=prhoi(:,gip);
    sdist=sdist(gip);
    ip=1;
    plot(Dep,prhoi(:,ip),'+');grid on;set(gca,'xlim',[0 1500]);
    hold on; plot(lidep(ip,:),lirhoi(ip,:),'bx')
    %tic;lrhoi=integ_lay(lidep,lirhoi,Dep,prhoi,sdist,Botdep);toc
    load /data1/alison/gmodels/natl/Bnatl_k/Amatrix.mat 
    100*full(A(281:7:406,195:195+6))
    100*full(A(281:7:406,294-7+1:294))
  end
 
%%%%%%%% PLOTS
%10/05: TRIED TO DO THE EQUIVALENT OF MK_SET_LAYPROPS BUT GAVE UP
ifig=0;
larea=integlay(lidep,ones(Npair,Nlay),Dep,ones(Ndep,Npair),...
  sdist,Botdep);
[laybsec,laysec]=laybound(Slat,Slon,lidep,larea,ones(size(litemp)),...
  ones(size(ltemp)),ones(size(ltemp)));
propnm=['rhoi';'heat';Propnm(2:Nprop,:)];
lunits{1}='10^9 kg/s'
for iprop=1:Nprop+1
  eval(['Tr(:,iprop)=sum(l' propnm(iprop,:) 'gvel)' '''' '/1e9;'])
  %PLOT FLUX
  ifig=ifig+1;figure(ifig);clf;set(gcf,'position',[17 50 700 900])
  windw=0;
  ylab='Pressure';
  %for isb=1:Nsec
  if windw==6
    ifig=ifig+1;figure(ifig);clf
    set(gcf,'position',[17 50 700 900]);windw=0;
  end
  %Layer interface approx mean depth
  layintd=-[0;cumsum(laysec.lavgwdth(1:Nlay-1))'];
  
  %RELATIVE T
  windw=windw+1;
  ttl=sprintf('%s %s (Relative)', secid,propnm(iprop,:));
  rxlab=sprintf('Total: %4.2g %s',Tr(Nlay,iprop),lunits{iprop});
  cpstair1(windw,Tr(1:Nlay-1,iprop),layintd,[],rxlab,ylab,...
    ttl,glevels(2:Nlay-1),0,1,'n',[],0,6000)
  
  %ABSOLUTE T 
  windw=windw+1;
  ttl=sprintf('%s %s (Absolute)', gsecs.name(isb,:),propnm(iprop,:));
  rxlab=sprintf('Total: %4.2g \\pm %4.2g %s',Ta{isb}(Nlay,iprop),...
    dTa{isb}(Nlay,iprop),lunits{iprop});
  cpstair1(windw,Ta{isb}(1:Nlay-1,iprop),layintd,[],rxlab,ylab,...
    ttl,layids(2:Nlay-1),0,1,'n',[],0,maxy,dTa{isb}(1:Nlay-1,iprop))
end %isb
drawnow


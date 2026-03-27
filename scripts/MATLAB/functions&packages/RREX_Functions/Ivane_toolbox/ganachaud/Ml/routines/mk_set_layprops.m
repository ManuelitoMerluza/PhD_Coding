%function mk_set_layprops
% KEY:   set layer integrated properties
% USAGE :
% 
%
%
%
% DESCRIPTION : 
%
%
% INPUT: see variable defined in mkequats 
%        p_lcdref : default=1: takes reference level at last
%                   common depth (deepest station if zero)
%
% OUTPUT:
%
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , Jul 97
%
% SIDE EFFECTS :
%  When pairs are masked they are still taken into account in the
%  average property statistics.
%
%
% SEE ALSO :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER: mkequats
% CALLEE:
if ~exist('p_lcdref')
  p_lcdref=1;
end

ipropmax=max(boxi.conseq.propid);
lisumprop =zeros(Nlay,ipropmax); %cumulative sum of layer properties
lisumprop2=zeros(Nlay,ipropmax);
lsumprop  =zeros(Nlay,ipropmax);
lsumprop2 =zeros(Nlay,ipropmax);
lisumdCdz  =zeros(Nlay-2,ipropmax);

lisumpropr =zeros(Nlay,ipropmax); %cumulative sum of layer properties
lisumpropr2=zeros(Nlay,ipropmax);
lsumpropr  =zeros(Nlay,ipropmax);
lsumpropr2 =zeros(Nlay,ipropmax);
lisumdCrdz  =zeros(Nlay-2,ipropmax);
lsumverarea=zeros(Nlay,1);
lsumverarea2=zeros(Nlay,1);
lisumlength=zeros(Nlay,1);

for isb=1:Nsec

  %GET SECTION PAIR DATA
  secid=[gsecs.name{isb} gsecs.namesuf{isb}];
  datadir=gsecs.datadir{isb};
  getpdat
  if gsecs.npair(isb)~=Npair
    error('wrong parameter gsecs.npair')
  end
  if any(strcmp(fieldnames(gsecs),'gip2select')) &...
      length(gsecs.gip2select)>=isb & ~isempty(gsecs.gip2select{isb})
    disp(sprintf('Section %i: Select only the following pairs',isb))
    disp(gsecs.gip2select{isb})
    gip2select=gsecs.gip2select{isb};
    mk_select_pairs
  else %takes all pairs by default.
    if sum(gsecs.perEk(:,isb))~=1
      error('Sum(gsecs.perEk(:,isb))~=1')
    end
    gsecs.gip2select{isb}=1:Npair;
  end
  %POSSIBILITY TO MASK SOME PAIRS WITH ZEROSIF SEAMOUNT, etc.
  if any(strcmp(fieldnames(gsecs),'pair2mask'))&...
      length(gsecs.pair2mask)>=isb&...
      ~isempty(gsecs.pair2mask{isb})
    p_maskpairs=1;
    gsecs.bstd{isb}(gsecs.pair2mask{isb})=0;
    gsecs.binit{isb}(gsecs.pair2mask{isb})=0;
    disp('DELETING PAIRS ...')
    disp(gsecs.pair2mask{isb})
    if any(diff(gsecs.pair2mask{isb})==1)
      disp(['because statistics are not properly computed '...
	  'in the case of masked pairs, do not mask many consecutive'])
    end
  else
    p_maskpairs=0;
  end
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % GAMMA N
  tosave=0;
  if (~exist('gamn') | (length(gamn) < isb) ) & ...
      ~any(strcmp(fieldnames(boxi),'sigint')) & (...
      any(strcmp(fieldnames(boxi),'glevels')) | ...
      (~isempty(gsecs.rl.nsid) & ~isempty(gsecs.rl.nsid(isb))&...
      ~isnan(gsecs.rl.nsid(isb)))...
      );
    namegfile=[OPdir boxi.name '_' boxi.modelid '_gamn.mat'];
    if exist(namegfile)
      disp(['loading GAMMA file: ' namegfile])
      eval(['load ' namegfile])
      if length(gamn) < isb |...
	  ~strcmp(secnames{isb},gsecs.name{isb})|...
	  ~strcmp(secsuf{isb},gsecs.namesuf{isb})
	  %| ~exist('glayers') |...
	  %length(glayers)~=length(boxi.glevels) |...
	  %~all(glayers==boxi.glevels) |...
	tosave=1;
      else
	tosave=0;
      end 
    else
      tosave=1;
    end %if exist(namegfile)
  end
  if tosave
    disp('COMPUTING NEUTRAL DENSITY (takes a few minutes) ...')
    %Modification suggested by David Jackett to trick the gamman
    %computation when close to the PIT
    if strcmp(gsecs.name{isb},'J8992')
      plon1=[Plon(4);Plon(4);Plon(4);Plon(4:Npair)];
      plat1=[Plat(4);Plat(4);Plat(4);Plat(4:Npair)];
    else
      plon1=Plon;
      plat1=Plat;
    end
    tic;[pgamn,dgl,dgh] = gamman(psali,ptemp,Presctd,plon1,plat1);toc
    if any(any(dgl==-99))|any(any(dgh==-99))|any(any(pgamn==-99))
      error('Problem in the neutral surface computation')
    end
    disp('DONE')
    %REMOVE STATIC INSTABILITY
    [gamn{isb},gamnlog{isb}]=rem_instab(pgamn);
  end %if tosave
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % LAYER INTERFACES
  if any(strcmp(fieldnames(boxi),'glevels')) %NEUTRAL SURFACE
    if length(boxi.glevels)~=Nlay
      error('length(boxi.glevels)~=Nlay')
    end
    %FIND DEPTHS OF THE INTERFACES
    lipres{isb}=getsigpres(Presctd,Pbotp,Maxdp(:,Itemp),gamn{isb},boxi.glevels);
    %lipres(ip,il) contains the interface il depth (dB), pair ip
  elseif any(strcmp(fieldnames(boxi),'sigint'))
    if length(boxi.sigint)~=Nlay
      error('length(boxi.sigint)~=Nlay')
    end
    lipres{isb}=find_sig_interface(boxi.sigint,boxi.sigipref,boxi.pref,...
      ptemp,psali,Presctd,Maxdp(:,Itemp),Pbotp,gsecs);
    tosave=0;
  %10/2001: added option of pressure layers for diagnostics
  elseif any(strcmp(fieldnames(boxi),'plevels'))
    if isstr(boxi.plevels)
      disp(['getting pressure layers from ' boxi.plevels])
      eval(['load ' boxi.plevels])
      eval(['stdp1=' ...
	  boxi.plevels(1:strfind(boxi.plevels,'.')-1) ';'])
      boxi.plevels=stdp1;
    end
    lipres{isb}(1:Npair,1:Nlay)=ones(Npair,1)*boxi.plevels(:)';
    %PUT BOTTOM WHERE BELOW
    if length(boxi.plevels)~=Nlay
      error('length(boxi.plevels)~=Nlay')
    end
    allpbot=Pbotp*ones(1,Nlay);
    gitocorrect=find(lipres{isb} > allpbot);
    lipres{isb}(gitocorrect)=allpbot(gitocorrect);
  else
    error('interfaces not defined')
  end
  if exist('p_plt_interface') & p_plt_interface
    mk_plt_interface(lipres,Slat,Slon,Presctd,Botp,gsecs,boxi,isb);
  end
  if exist('p_plotallgamma') & p_plotallgamma & exist('gamn')
    figure;cinterv=[23:.5:27,27:.1:28,28:.01:30];
    [c,h]=contour(cumsum(sw_dist(Slat,Slon,'km')),-Presctd,gamn{isb},cinterv);
    clabel(c,h);title(gsecs.name{isb});
    set(gca,'ylim',[-500*ceil(max(Botp)/500) 0]);
    hold on;plot(cumsum(sw_dist(Slat,Slon,'km')),-Pbotp);land;setlargefig
    if input('print ? (y/n) ','s')=='y',print,end
  end
 
  %CONVERT PRESSURE->DEPTH
  Ndep{isb}=length(Presctd);
  Dep{isb}   =sw_dpth(Presctd(:,1)*ones(1,Npair),ones(Ndep{isb},1)*(Plat'));

  lidep{isb}=sw_dpth(lipres{isb},Plat*ones(1,Nlay));
  Botdep{isb}=sw_dpth(Botp,Slat);
  %CORRECT POSSIBLE LAYERS BELOW BOTTOM DUE TO NON LINEAR EFFECTS
  Pbotd=max([Botdep{isb}(1:Npair)';Botdep{isb}(2:Npair+1)'])';
  allpbot=Pbotd*ones(1,Nlay);
  gitocorrect=find(lidep{isb} > allpbot);
  deltad=lidep{isb}(gitocorrect)-allpbot(gitocorrect);
  if any(deltad>1)
    error('TOO LARGE CORRECTION TO LAYER BOTTOM DEPTHS')
  end
  lidep{isb}(gitocorrect)=allpbot(gitocorrect);
  Sdist{isb}=sw_dist(Slat,Slon,'km');

  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % REFERENCE THE VELOCITY
  %GET REFERENCE LEVEL
  if (any(strcmp(fieldnames(boxi),'sigint')) +...
      any(strcmp(fieldnames(boxi),'glevels'))+...
      any(strcmp(fieldnames(boxi),'plevels')))>=2
    error('Choose only one of sigint, glevels, plevels')
  end
  if any(strcmp(fieldnames(boxi),'sigint'))
    disp(sprintf('  Referencing velocities to interface %i (%f)',...
      gsecs.rl.ns(isb),boxi.sigint(gsecs.rl.ns(isb))))
    rlpres{isb}=lipres{isb}(:,gsecs.rl.ns(isb));
  elseif (~isempty(gsecs.rl.ns))&(~isempty(gsecs.rl.ns(isb)))&...
      ~isnan(gsecs.rl.ns(isb))
    disp(sprintf('  Referencing velocities to interface %i (%f)',...
      gsecs.rl.ns(isb),boxi.glevels(gsecs.rl.ns(isb))))
    rlpres{isb}=lipres{isb}(:,gsecs.rl.ns(isb));
    %clf;plot(-rlpres{isb});ppause
  elseif (~isempty(gsecs.rl.nsid))&(~isempty(gsecs.rl.nsid(isb)))&...
      (~isnan(gsecs.rl.nsid(isb)))&(gsecs.rl.nsid(isb)>0)
    disp(sprintf('  Referencing velocities to gamma surface %g',...
      gsecs.rl.nsid(isb)))
    %Reference to the given sigma interface
    if ~exist('gamn') 
      error('gamn has not been loaded or computed yet')
    end
    rlpres{isb}=getsigpres(Presctd,Pbotp,Maxdp(:,Itemp),...
      gamn{isb},gsecs.rl.nsid(isb));
    %disp(rlpres{isb})
  elseif length(gsecs.rl.pres{isb})==1
    disp(sprintf('  Referencing velocities to %i db',gsecs.rl.pres{isb}))
    rlpres{isb}=gsecs.rl.pres{isb}*ones(Npair,1);
  else
    disp('  Referencing velocities specified pressures')
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
  gis_at_bot=find(rlpres{isb}>limitdep);
  rlpres{isb}(gis_at_bot)=limitdep(gis_at_bot);
  % R.L.VELOCITY
  rlgv= getsigprop(Presctd,gvel,Pbotp,rlpres{isb});
  % RELATIVE VELOCITY IN CM/S
  grelvel{isb}=0.01*(gvel-ones(Ndep{isb},1)*(rlgv')); %in m/s
  if p_maskpairs
    grelvel{isb}(:,gsecs.pair2mask{isb})=0;
  end
  clear ishdp limitdep gis_at_bot 
  if exist('p_plt_refvel')&p_plt_refvel
    figure;
    plt_prop(100*grelvel{isb}, 'vel', 'cm/s', Cruise, Presctd, ...
      Maxd(:,1), Botp, Slat, Slon,500*ceil(max(Botp)/500))
    land;setlargefig;printyn
  end
  %plot_vel(cumsum(Sdist{isb}),-Pres,100*grelvel{isb});
  %ppause
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % INTEGRATIONS IN LAYERS
  %GET AREA IN EACH CELL
  larea{isb}=integlay(lidep{isb},ones(Npair,Nlay),Dep{isb},ones(Ndep{isb},Npair),...
    Sdist{isb},Botdep{isb});

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % INTEGRATION OF DENSITY
  prhoi = sw_dens(psali,ptemp,Presctd);
  lirhoi=getsigprop(Presctd,prhoi,Pbotp,lipres{isb});
  lrhoi =integlay(lidep{isb},lirhoi,Dep{isb},prhoi,Sdist{isb},Botdep{isb});
  lrhoi2=integlay(lidep{isb},lirhoi.^2,Dep{isb},prhoi.^2,Sdist{isb},Botdep{isb});
  lscale(MASS)=1e9;
  lunits{MASS}='\times 10^9 kg/s';
  lprop{isb,MASS} =lrhoi/lscale(MASS)/100; %b is in cm/s

  % TRANSPORT
  ligvrhoi=getsigprop(Presctd,prhoi.*grelvel{isb},Pbotp,lipres{isb});
  lgvrhoi=integlay(lidep{isb},ligvrhoi,Dep{isb},prhoi.*grelvel{isb},...
    Sdist{isb},Botdep{isb});
  lgvprop{isb,MASS} =lgvrhoi/lscale(MASS);
  
  % LAYER PROPERTIES (LAYBOUND)
  [laybs,lays]=laybound(Slat,Slon,lidep{isb},larea{isb},lirhoi,lrhoi,lrhoi2);
  Laybs{isb,MASS}=laybs;
  Lays{isb,MASS}=lays;
  % ADD INTEGRALS TO GET MEAN/STD OVER THE BOX
  lsumpropr(:,MASS)=lsumpropr(:,MASS)+lays.lsumprop';
  lsumpropr2(:,MASS)=lsumpropr2(:,MASS)+lays.lsumprop2';
  lisumpropr(:,MASS)=lisumpropr(:,MASS)+laybs.lisumprop';
  lisumpropr2(:,MASS)=lisumpropr2(:,MASS)+laybs.lisumprop2';
  lisumdCrdz(:,MASS)=lisumdCrdz(:,MASS)+laybs.lisumdCdz;
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % INTEGRATION OF HEAT
  %GET CP ACCORDING TO BACON(1996)
  pottemp=sw_ptmp(psali,ptemp,Presctd,0);
  phtcp=sw_cp(psali,pottemp,0);
  pheat=prhoi.*phtcp.*pottemp;
  liheat=getsigprop(Presctd,pheat,Pbotp,lipres{isb});
  lheat=integlay(lidep{isb},liheat,Dep{isb},pheat,Sdist{isb},Botdep{isb});
  lheat2=integlay(lidep{isb},liheat.^2,Dep{isb},pheat.^2,Sdist{isb},Botdep{isb});
  lscale(HEAT)=1e15;
  lunits{HEAT}='PW';
  lprop{isb,HEAT}=lheat/lscale(HEAT)/100;
  % HEAT TRANSPORT
  ligvheat=getsigprop(Presctd,pheat.*grelvel{isb},Pbotp,lipres{isb});
  lgvheat=integlay(lidep{isb},ligvheat,Dep{isb},pheat.*grelvel{isb},...
    Sdist{isb},Botdep{isb});
  lgvprop{isb,HEAT}=lgvheat/lscale(HEAT);
  % LAYER PROPERTIES (LAYBOUND)
  [laybs,lays]=laybound(Slat,Slon,lidep{isb},larea{isb},liheat,lheat,lheat2);
  Lays{isb,HEAT}=lays;
  Laybs{isb,HEAT}=laybs;
  % ADD INTEGRALS TO GET MEAN/STD OVER THE BOX
  lsumpropr(:,HEAT)=lsumpropr(:,HEAT)+lays.lsumprop';
  lsumpropr2(:,HEAT)=lsumpropr2(:,HEAT)+lays.lsumprop2';
  lisumpropr(:,HEAT)=lisumpropr(:,HEAT)+laybs.lisumprop';
  lisumpropr2(:,HEAT)=lisumpropr2(:,HEAT)+laybs.lisumprop2';
   %REDO THE CALCULATION WITH IN SITU TEMPERATURE FOR THE DIFFUSION
   % (GILL, p.70)
   ptemp1=prhoi.*phtcp.*ptemp;
   litemp1=getsigprop(Presctd,ptemp1,Pbotp,lipres{isb});
   ltemp1=integlay(lidep{isb},litemp1,Dep{isb},ptemp1,Sdist{isb},Botdep{isb});
   ltemp12=integlay(lidep{isb},litemp1.^2,Dep{isb},ptemp1.^2,Sdist{isb},Botdep{isb});
   [laybs,lays]=laybound(Slat,Slon,lidep{isb},larea{isb},litemp1,ltemp1,ltemp12);
  lisumdCrdz(:,HEAT)=lisumdCrdz(:,HEAT)+laybs.lisumdCdz;
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % INTEGRATION OF OTHER PROPERTIES
  %for iprop=HEAT:Nconseq
  for iprop=boxi.conseq.propid(MASS:Nconseq)
    disp(['INTEGRATING ' propnm{iprop}])
    switch iprop
      case{MASS}
        %FAKE LOOP TO GET POT DENSITY AVERAGES ONLY
        pprop=sw_pden(psali,ptemp,Presctd,0);
      case{HEAT}
        %FAKE LOOP TO GET POT TEMPERATURE AVERAGES ONLY
        pprop=pottemp;
      case{SALI}
        eval(['pprop=p' propnm{iprop} ';'])
	lscale(SALI)=1000*1e6; %g/s ->10^6 kg/s 
        lunits{SALI}='\times 10^6 kg/s';
      case{PHOS,SILI,NITA}
        eval(['pprop=p' propnm{iprop} ';'])
	lscale(iprop)=1e9; %umol/s -> kmol/s 
	lunits{iprop}='kmol/s';
      case OXYG
         if all(poxyg(find(~isnan(poxyg)))<100)
	  disp('Oxygen conversion ml/l to umol/kg (Pickard & Emery, 1990)')
	  poxygumolkg=ox_units(poxyg,psali,pottemp);
	else
	  poxygumolkg=poxyg;
	end
        %paou=sw_oxst(psali,pottemp)-poxygumolkg; %AOU
	%undersaturated everywhere. AOU can mess-up the calculation
	%8/99: There is no point in using AOU because oxygen is
	%9/99: Yes ! use it, otherwise large mass residuals in tristan 
	ppoxyg=poxygumolkg;
	pprop=poxygumolkg;
	lscale(iprop)=1e9; %umol/s -> kmol/s 
	lunits{iprop}='kmol/s';
      case PO
	%pprop=115*pphos+ppoxyg; %(for deep layers (<4deg), Minster&Boulahdid)
	%pprop=140*pphos+ppoxyg; %Original Redfield
	pprop=170*pphos+ppoxyg; %Anderson and Sarmiento (GCB 1994)
	lscale(iprop)=1e9; %umol/s -> kmol/s 
	lunits{iprop}='kmol/s';
      case NO
	pprop=9.1*pnita+ppoxyg;             %Minster&Boulahid, 1982
	lscale(iprop)=1e9; %umol/s -> kmol/s 
	lunits{iprop}='kmol/s';
	%plt_prop(pprop, propnm{iprop}, 'umol/kg', ...
	%  Cruise, Pres, Maxd, Botp, Slat, Slon);
      case Nstar
        pprop=(pnita-16*pphos+2.9); %from Deutsh et al.2000
	lscale(iprop)=1e9; %umol/s -> kmol/s 
	lunits{iprop}='kmol/s';
      otherwise
        error('not programed')
    end %switch
    if (iprop~=HEAT) & (iprop~=MASS)
      ppropr=prhoi.*pprop;
      liprop_=getsigprop(Presctd,ppropr,Pbotp,lipres{isb});
      lprop_=integlay(lidep{isb},liprop_,Dep{isb},ppropr,Sdist{isb},Botdep{isb});
      lprop2=integlay(lidep{isb},liprop_.^2,Dep{isb},ppropr.^2,Sdist{isb},Botdep{isb});
      lprop{isb,iprop} =lprop_/lscale(iprop)/100;
      % TRANSPORT
      ligvprop=getsigprop(Presctd,ppropr.*grelvel{isb},Pbotp,lipres{isb});
      lgvprop_=integlay(lidep{isb},ligvprop,Dep{isb},ppropr.*grelvel{isb},...
	Sdist{isb},Botdep{isb});
      lgvprop{isb,iprop} =lgvprop_/lscale(iprop);
      
      % LAYER PROPERTIES (LAYBOUND)
      [laybs,lays]=laybound(Slat,Slon,lidep{isb},larea{isb},liprop_,lprop_,lprop2);
      Lays{isb,iprop}=lays;
      Laybs{isb,iprop}=laybs;
      % ADD INTEGRALS TO GET MEAN/STD OVER THE BOX
      lsumpropr(:,iprop)=lsumpropr(:,iprop)+lays.lsumprop';
      lsumpropr2(:,iprop)=lsumpropr2(:,iprop)+lays.lsumprop2';
      lisumpropr(:,iprop)=lisumpropr(:,iprop)+laybs.lisumprop';
      lisumpropr2(:,iprop)=lisumpropr2(:,iprop)+laybs.lisumprop2';
      lisumdCrdz(:,iprop)=lisumdCrdz(:,iprop)+laybs.lisumdCdz;
    end %if iprop ~=HEAT
    
    %%%% LAYBOUND ON PROPERTIES %%%% ADDED 04/8/98
    % to get averages of properties in neutral surfaces (not of
    % rho*property)
    liprop_=getsigprop(Presctd,pprop,Pbotp,lipres{isb});
    lprop_=integlay(lidep{isb},liprop_,Dep{isb},pprop,Sdist{isb},Botdep{isb});
    lprop2=integlay(lidep{isb},liprop_.^2,Dep{isb},pprop.^2,Sdist{isb},Botdep{isb});
    [laybs,lays]=laybound(Slat,Slon,lidep{isb},larea{isb},liprop_,lprop_,lprop2);
    Layprops{isb,iprop}=lays;
    Laypropbs{isb,iprop}=laybs;
    lsumprop(:,iprop)=lsumprop(:,iprop)+lays.lsumprop';
    lsumprop2(:,iprop)=lsumprop2(:,iprop)+lays.lsumprop2';
    lisumprop(:,iprop)=lisumprop(:,iprop)+laybs.lisumprop';
    lisumprop2(:,iprop)=lisumprop2(:,iprop)+laybs.lisumprop2';
    lisumdCdz(:,iprop)=lisumdCdz(:,iprop)+laybs.lisumdCdz;
    clear liprop_ lprop_ lprop2 laybs lays
    
    %MASK PAIRS IF NEEDED
    if p_maskpairs
      lprop{isb,iprop}(gsecs.pair2mask{isb},:)=0;
    end
    %MASK P3 LAST LAYER AS IT MAKES NUMERICAL PROBLEM (in a trench)
    if strcmp(gsecs.name{isb}(1:2),'P3') & Nlay>19
      mask_P3_lay20;
    end
  end %iprop
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %TOTAL INTERFACE LENGTH / LAYER AREA
  lisumlength=lisumlength+Laybs{isb,1}.litotdist';
  lsumverarea=lsumverarea+Lays{isb,1}.lverarea';
  %TOTAL AREA FOR LAYER (FOR AVG WIDTH COMPUTATION)
  lsumverarea2(1:Nlay-1)=lsumverarea2(1:Nlay-1)+...
    sum(1000*(Sdist{isb}*ones(1,Nlay-1)).*...
    (lidep{isb}(:,2:Nlay)-lidep{isb}(:,1:Nlay-1)))';
  lsumverarea2(Nlay)=lsumverarea2(Nlay)+sum(1000*Sdist{isb}.*...
    (lidep{isb}(:,Nlay)-lidep{isb}(:,1)));
end %on isb

if tosave
  disp(['SAVING GAMN : ' namegfile])
  glayers=boxi.glevels;secnames=gsecs.name;secsuf=gsecs.namesuf;
  eval(['save ' namegfile ' gamn glayers secnames secsuf'])
  clear gamn
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% COMPUTES BOX AVERAGE LAYER PROPERTIES units: (rho*property)
laynull=~lsumverarea;
lsumverarea(laynull)=Inf;
layinull=~lisumlength;
lisumlength(layinull)=Inf;
boxi.lavg=lsumpropr./(lsumverarea*ones(1,ipropmax));
boxi.lstd=sqrt(lsumpropr2./(lsumverarea*ones(1,ipropmax))-boxi.lavg.^2);
boxi.lrms=sqrt(lsumpropr2./(lsumverarea*ones(1,ipropmax)));
boxi.liavg=lisumpropr./(lisumlength*ones(1,ipropmax));
boxi.listd=sqrt(lisumpropr2./(lisumlength*ones(1,ipropmax))-boxi.liavg.^2);
boxi.lirms=sqrt(lisumpropr2./(lisumlength*ones(1,ipropmax)));
boxi.lavgwdth=lsumverarea2./([lisumlength(2:Nlay);lisumlength(1)]);
boxi.lverarea=lsumverarea;
boxi.liavgdCrdz=lisumdCrdz./(lisumlength(2:Nlay-1)*ones(1,ipropmax));

% PROPERTY AVERAGES
boxi.lavgprop=lsumprop./(lsumverarea*ones(1,ipropmax));
boxi.lstdprop=sqrt(lsumprop2./(lsumverarea*ones(1,ipropmax))-boxi.lavgprop.^2);
boxi.lrmsprop=sqrt(lsumprop2./(lsumverarea*ones(1,ipropmax)));
boxi.liavgprop=lisumprop./(lisumlength*ones(1,ipropmax));
boxi.listdprop=sqrt(lisumprop2./(lisumlength*ones(1,ipropmax))-boxi.liavgprop.^2);
boxi.lirmsprop=sqrt(lisumprop2./(lisumlength*ones(1,ipropmax)));
boxi.liavgdCdz=lisumdCdz./(lisumlength(2:Nlay-1)*ones(1,ipropmax));
lsumverarea(laynull)=0;
lisumlength(layinull)=0;

% DISPLAY BOX AVERAGED PROPERTIES
if exist('p_displayprops') & p_displayprops==1
  disp_layavg(boxi,propnm,Propunits)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% COMPUTES LAYER INTERFACE AREA APPROXIMATING WITH TRAPEZE
if length(boxi.harea)==1
  if boxi.zonalcoast & boxi.zonalcoast<=1000
    disp('Warning: Zonal coast in m ?')
    ppause
  end
  ydist=2*boxi.harea(1)/(lisumlength(1)+boxi.zonalcoast);  
  boxi.harea(2:Nlay)=ydist*(boxi.zonalcoast+lisumlength(2:Nlay))/2;
end

%Clear variables from loop
clear pgamn dgh dgl liprop_ lprop_ lprop2 ligvprop lgvprop_ laybs lays
clear lsumpropr lsumpropr2 lisumpropr lisumpropr2 lisumdCrdz 
clear lsumprop lsumprop2 lisumprop lisumprop2 lisumdCdz
clear poxygumolkg pottemp phtcp pheat liheat lheat lheat2 ligvheat lgvheat 
clear prhoi lirhoi lrhoi2 ligvrhoi lgvrhoi
clear gis_at_bot ishdp isw
%Clear section data
clear ptemp psali poxyg pphos psili pdynh gvel svel pprop ppropr
clear Slon Slat Botp Cast Cruise Gis_select IPhdr Secdate
clear Idynh Ioxyg Iphos Isali Isctd Isili Itemp
clear Kt MPres Maxd Maxdp Nobs Nstat Pairfiles Pbotp Plat Plon Precision
clear Pres Presctd  Propunits Ptreat Remarks Secname Ship
clear Treatment Vcont Velfile Velprec Velunit Xdep hdrname
clear datadir secid


if exist('p_displayprops') & p_displayprops==1
  disp('AVERAGE PROPERTIES')
  for iprop=boxi.conseq.propid
    disp(' ')
    if iprop==1
      disp('pot density')
    else
      disp(upper(propnm{iprop}))
    end
    for isb=1:Nsec
      disp(sprintf('%s\t\t%f',gsecs.name{isb},...
	Layprops{isb,iprop}.lavgprop(Nlay)))
    end
    disp(sprintf('BOX\t\t%f',boxi.lavgprop(Nlay,iprop)))
  end
  disp('FIRST LAYER SALINITY')  
  for isb=1:Nsec
    disp(sprintf('%s\t\t%f',gsecs.name{isb},...
      Layprops{isb,SALI}.lavgprop(1)))
  end
end
gsecs.lidep=lidep;
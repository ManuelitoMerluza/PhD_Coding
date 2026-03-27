%function 
% KEY:
% USAGE :
% 
%
%
%
% DESCRIPTION : 
%
%
% INPUT: IPdir boxname modelid (parameters)
%    <boxname>_equn.mat : contains equation matrix and parameters
%    <boxname>_bhat.mat : contains solution bhat, P from inversion
% 
%
% OUTPUT: (section isb, layer ilay, property iprop)
%  Tr{isb}(ilay,iprop) : relative transport (including Ekman)
%  Ta{isb}(ilay,iprop) : absolute transport from inversion
%  dTa{isb}(ilay,iprop): uncertainty (1std. dev)
%
%  Wtrans(ilayint,iprop): vertical transport through interface ilayint
%  ilayint=1:Nlay-2
%  Dwtrans(ilayint,iprop): uncertainty
%
%  Kztrans{ibox}%  diffusive transport
%  Dkztrans{ibox}%  diffusive transport uncertainty
%
%  Resr(ilay,iprop): residuals in the box before inversion
%  Resa(ilay,iprop): residuals after inversion
%  Dres(ilay,iprop): uncertainty on residuals
%
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , Jul 97
%
% SIDE EFFECTS :
%
% SEE ALSO : mkequats
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER:
% CALLEE:
clear Wtrans Dwtrans boxsec Kztrans Dkztrans
clear Tbi Tr cTr Ta cTa dTa tekk Resr Resa Dres Dresr 
if ~exist('p_res_units')
  p_res_units=0; %convert residual units in mol/m2/yr
end
if ~exist('p_calculate_Ekman')
  p_calculate_Ekman=0; 
end

if ~exist('bhat')
  str=['load ' IPdir 'bhat_' Modelid '_' invid '.mat'];
  disp(str)
  eval(str)
  if 0
    IPdir='/data1/ganacho/Boxmod/Natl/';
    boxname='natl_XVII';
    modelid='Alison';
    IPdir='/data1/ganacho/Boxmod/Natl/';
    Modelid='NewNatl';
    invid='GM1.0';
  end
else
end
str=[  'load ' IPdir Modelid '_equn.mat '];
disp(str)
eval(str)

if ~exist('boxsec')
  boxsec=ones(1,length(gsecs.name));
  gisb=1:length(gsecs.name);
  %boxsec=[1 1 1 2]; %Which section belogs to which box
  %gisb  =[1 2 3 2]; %relative indice in the box
end
%(For Ekman transport calculation)

Nconseq=size(boxi.liavg,2);
Nlay=boxi.nlay;
Nsec=length(gsecs.name);
if any(strcmp(fieldnames(pm),'gifwcol')) %contains multiple boxes
  gifwcol=pm.gifwcol;
  gilwcol=pm.gilwcol;
  multbox=1;
  if exist('p_compw')& ~p_compw
    error('indices will be wrong if multibox and different layers')
  end
else
  gifwcol=pm.ifwcol;
  gilwcol=pm.ilwcol;
  pm.ibfrow=1;
  multbox=0;
end
if any(strcmp(fieldnames(pm),'gifKzcol')) %contains multiple boxes
  gifkzcol=pm.gifKzcol;
  gilkzcol=pm.gilKzcol;
elseif any(strcmp(fieldnames(pm),'ifKzcol'))
  gifkzcol=pm.ifKzcol;
  gilkzcol=pm.ilKzcol;
end

Nbox=length(gifwcol);

for iprop=1:Nconseq
  disp(sprintf('CALCULATING %s TRANSPORTS ...',upper(propnm{iprop})))
  
  %COMPUTE NET TRANSPORT FOR EACH SECTION/LAYER
  for isa=1:Nsec
    girow=pm.ibfrow(boxsec(isa))-1+[(iprop-1)*Nlay+1:iprop*Nlay];
    gicol=pm.gifcol(isa):pm.gilcol(isa);
    if exist('p_combinesec')&~isempty(p_combinesec{isa})&...
	any(p_combinesec{isa})
      for isa2=p_combinesec{isa}
	if isa2==isa
	  error('self combination : p_combinesec(isa)==isa !')
	end
	disp(['COMBINING ' gsecs.name{isa} ' WITH ' ...
	    gsecs.name{isa2}])
	gicol=[gicol,pm.gifcol(isa2):pm.gilcol(isa2)];
	if multbox
	  gsecs.Ekt{boxsec(isa)}(:,gisb(isa),iprop)=...
	    gsecs.Ekt{boxsec(isa)}(:,gisb(isa),iprop)+...
	    gsecs.Ekt{boxsec(isa2)}(:,gisb(isa2),...
	    iprop);
	else
	  gsecs.Ekt(:,gisb(isa),iprop)=gsecs.Ekt(:,gisb(isa),iprop)+...
	    gsecs.Ekt(:,gisb(isa2),iprop);
	end
      end %for isa2=p_combinesec{isa}
      if isempty(findstr(gsecs.name{isa},'+'))
	gsecs.name{isa}=[gsecs.name{isa} '+'];
      end
    end
    if multbox
      tekk=gsecs.Ekt{boxsec(isa)}(:,gisb(isa),iprop);
      inboxdirr=gsecs.inboxdir{boxsec(isa)}(gisb(isa));
    else
      tekk=gsecs.Ekt(:,gisb(isa),iprop);
      inboxdirr=gsecs.inboxdir(gisb(isa));
    end
    %Re-CREATE ORIGINAL A MATRIX FOR NET TRANSPORT COMPUTATION IF ANOMALY
    %WERE USED IN CONSERVATION EQUATIONS.
    if any(strcmp(fieldnames(boxi.conseq),'anom'))&...
	length(boxi.conseq.anom)>=iprop &...
	boxi.conseq.anom(iprop)~=0 & iprop~=1
      if iprop ==2
	disp('NET TRANSPORTS ARE ABSOLUTE (NOT ANOMALEOUS)')
      end
      C0=boxi.lavg(:,iprop)*1e9/1000/lscale(iprop);
      Amatnet=Amat(girow,:)+C0*ones(1,size(Amat,2)).*Amat(1:Nlay,:);
      Gunsgnnet=Gunsgn(girow,:)+C0*ones(1,size(Amat,2)).*Gunsgn(1:Nlay,:);
      if exist('p_t2bsalianom') & p_t2bsalianom & ...
	  strcmp(propnm{iprop},'sali')
	disp('KEEP TOP-TO-BOTTOM ANOMALY FOR SALT')
	C0=ones(Nlay,1)*boxi.lavg(Nlay,iprop)*1e9/1000/lscale(iprop);
	Amatnet=Amatnet-...
	  C0*ones(1,size(Amat,2)).*Amat(1:Nlay,:);
	Gunsgnnet=Gunsgnnet-...
	  C0*ones(1,size(Amat,2)).*Gunsgn(1:Nlay,:);
	tekk=tekk-C0.*gsecs.Ekt(:,gisb(isa),1);
	if any(strcmp(fieldnames(gsecs),'wbc'))&...
	    (length(gsecs.wbc)>=isa) &...
	    ~isempty(gsecs.wbc{isa})
	  Wbccor([1,boxi.nlay])=-C0([1,boxi.nlay])*gsecs.wbc{isa}(1);
	  %!! C0 is used again below, for baroclinic contrib.
	  Wbccor=Wbccor(:);
	else
	  Wbccor=0;
	end
      end
    else
      Amatnet=Amat(girow,:);
      Gunsgnnet=Gunsgn(girow,:);
      Wbccor=0;
    end    
    if exist('p_save_Amat')&p_save_Amat %save Amat rows for
      Amatnets{isa}(iprop,:)=-inboxdirr*...
	full(Amatnet(length(girow),gicol));
    end
    %ADD IN WESTERN BOUNDARY CURRENT IF NECESSARY IN THE FIRST LAYER
    %ALL IN FIRST LAYER
    if any(strcmp(fieldnames(gsecs),'wbc'))&(length(gsecs.wbc)>=isa) &...
	~isempty(gsecs.wbc{isa})
      disp(['adding bcurrent across section ' gsecs.name{isa}])
      Twbc([1,boxi.nlay])=gsecs.wbc{isa}(iprop);
      Twbc=Twbc(:)+Wbccor;
      %Wbc correction if salinity anomaly transport
    else
      Twbc=0;
    end
    if ~exist('p_pltstream')|p_pltstream==0
      Tr{isa}(:,iprop)=sum(Gunsgnnet(:,gicol),2)+tekk+...
	-inboxdirr*Amatnet(:,gicol)*Binit(gicol)+Twbc;
      Ta{isa}(:,iprop)=sum(Gunsgnnet(:,gicol),2)+tekk+...
	-inboxdirr*Amatnet(:,gicol)*bhat(gicol)+Twbc;
      if exist('p_savealltrans')&p_savealltrans
	h_savealltrans
      end
      dTa{isa}(:,iprop)=...
	full(sqrt(diag(Amatnet(:,gicol)*P(gicol,gicol)*Amatnet(:,gicol)')));
      %Cumulative transports from West or North
      disp('Does not include Ekman transport for Cumulative transport')
      np=gsecs.npair(isa)-any(strcmp(fieldnames(pm),'giEkcol'));
      cTr{isa,iprop}=cumsum(Gunsgnnet(:,gicol(1:np)),2)+...
	-inboxdirr*cumsum(Amatnet(:,gicol(1:np)).*(ones(Nlay,1)*...
	Binit(gicol(1:np))'),2);
      cTa{isa,iprop}=cumsum(Gunsgnnet(:,gicol(1:np)),2)+...
	-inboxdirr*cumsum(Amatnet(:,gicol(1:np)).*(ones(Nlay,1)*...
	bhat(gicol(1:np))'),2);
      %Get barotropic and baroclinic transports versus horiz.
      %Barotropic (net T X thetabar) is last layer; BI is sum
      %1:Nlay-1
      if iprop > 1
	ddivd=Lays{isa,1}.lavgprop; ddivd(~ddivd)=Inf;
	vzonal=Ta{isa}(:,1)./ddivd';
	vertlayratio=Lays{isa,iprop}.lverarea(1:Nlay-1)'/...
	    Lays{isa,iprop}.lverarea(Nlay);
	vzonal=vzonal-[vzonal(Nlay)*vertlayratio;0];
	rhoTzonal=Lays{isa,iprop}.lavgprop';
	-[Lays{isa,iprop}.lavgprop(Nlay)*ones(Nlay-1,1);0];
	if iprop==2
	  Tbi{isa}(:,iprop)=rhoTzonal.*vzonal*lscale(1)/lscale(2);
	else
	  Tbi{isa}(:,iprop)=rhoTzonal.*vzonal; %kmol/s
	end
	if exist('p_t2bsalianom') & p_t2bsalianom & ...
	    strcmp(propnm{iprop},'sali')
	  %in that case removes barotropic component as it is
	  % zero by definition. BI is OK.
	  Tbi{isa}(Nlay,iprop)=0;
	end
      end
    else
      %Aug 98:
      disp('Get cumulative transports from bottom (Streamfunction)')
      cccc=sum(Gunsgnnet(:,gicol),2)+tekk+...
	-inboxdirr*Amatnet(:,gicol)*bhat(gicol);
      ctest=flipud(cumsum(flipud(cccc(1:Nlay-1)),1));
      
      %define "cumulator" matrix
      cmat=triu(ones(Nlay,Nlay));
      cmat(1:Nlay-1,Nlay)=0; %remove last layer (top to bottom)
      Tr{isa}(:,iprop)=cmat*( sum(Gunsgnnet(:,gicol),2)+tekk+...
	-inboxdirr*Amatnet(:,gicol)*Binit(gicol) )+Twbc;
      Ta{isa}(:,iprop)=cmat*(sum(Gunsgnnet(:,gicol),2)+tekk+...
	-inboxdirr*Amatnet(:,gicol)*bhat(gicol)  )+Twbc;
      %plot(Ta{isa}(:,iprop)-[ctest;cccc(Nlay)]);ppause
      if any((Ta{isa}(:,iprop)-[ctest;cccc(Nlay)]-Twbc)>1e-6)
	error('(Ta{isa}(:,iprop)-[ctest;cccc(Nlay)]-Twbc)>1e-6')
      end
      dTa{isa}(:,iprop)=...
	full(sqrt(diag(...
	cmat*Amatnet(:,gicol)*P(gicol,gicol)*Amatnet(:,gicol)'*cmat')));
    end %if ~exist('pltstream')|pltstream==0
  end %isa
  
  %VERTICAL TRANSPORTS (Only if original equations!)
  if ~exist('p_compw') | p_compw
  for ibox=1:Nbox
    for ilayint=1:Nlay-2
      girow=pm.ibfrow(ibox)-1+[(iprop-1)*Nlay+1:iprop*Nlay];
%      iwkzrow=1+girow(ilayint);
      iwkzrow=1+ilayint;
      iwcol=gifwcol(ibox)+ilayint-1;
      Wtrans{ibox}(ilayint,iprop)=full(Amatnet(iwkzrow,iwcol)*bhat(iwcol));
      Dwtrans{ibox}(ilayint,iprop)=sqrt(full(...
	Amatnet(iwkzrow,iwcol)*P(iwcol,iwcol)*Amatnet(iwkzrow,iwcol)'));
      if any(strcmp(fieldnames(boxi.conseq),'Kzstd'))
	ikzcol=gifkzcol(ibox)+ilayint-1;
	Kztrans{ibox}(ilayint,iprop)=full(Amatnet(iwkzrow,ikzcol)*bhat(ikzcol));
	Dkztrans{ibox}(ilayint,iprop)=sqrt(full(...
	  Amatnet(iwkzrow,ikzcol)*P(ikzcol,ikzcol)*Amatnet(iwkzrow,ikzcol)'));
      end
    end %ilayint
    if iwcol~=gilwcol(ibox) |...
      (any(strcmp(fieldnames(boxi.conseq),'Kzstd')) & ikzcol~=gilkzcol(ibox))
      error('PROBLEM WITH W or Kz INDICES')
    end
    if exist('p_savewkztrans') & p_savewkztrans
      h_savewkztrans
    end
    
    %RESIDUALS FOR CONSERVATION EQUATION
    if any(boxi.conseq.freshw)&strcmp(propnm{iprop},'mass')
      disp('INCLUDING FRESHWATER IN RESIDUAL COMPUTATION')
      fw2subs([1 Nlay])=boxi.conseq.freshw;fw2subs=fw2subs(:);
    else
      fw2subs=0;
    end
    if any(strcmp(fieldnames(boxi.conseq),'rhs'))
      disp(['Substracting initial rhs to ' boxi.name])
      thisrhs=boxi.conseq.rhs(:,iprop);
    else
      thisrhs=0;
    end
    Resr{ibox}(:,iprop)=G(girow)+Ekman(girow)-fw2subs+...
      Amat(girow,:)*Binit-thisrhs;
    Dresr{ibox}(:,iprop)=1./(Rwght(girow)+~Rwght(girow));
    Dresr{ibox}(~Rwght(girow))=NaN;
    Resa{ibox}(:,iprop)=G(girow)+Ekman(girow)-fw2subs+...
      Amat(girow,:)*bhat-thisrhs;
    Dres{ibox}(:,iprop)=sqrt(full(diag(Amat(girow,:)*P*Amat(girow,:)')));
    if p_res_units & (boxi.harea(1) ~= 0)
    switch propnm{iprop}
      case {'oxyg','phos','sili','nita'}
        disp(['Scaling ' propnm{iprop} ' residual by average layer area'])
	scalefac0=1./boxi.harea(1:Nlay-1)';
	scalefac0(isinf(scalefac0))=0;
	%kmol/s -> mol/m2/yr
	scalefac=1e9/1e6*365*24*3600*[scalefac0;1./boxi.harea(1)];
	resunit{iprop}='mol yr^{-1}m^{-2}';
	if strcmp(propnm{iprop},'oxyg')
	  resname{iprop}='OUR';
	elseif strcmp(propnm{iprop},'heat')
	  resname{iprop}='Heat flux';
	  resunit{iprop}='W m^{-2}';
	  scalefac=1e15*[scalefac0;1./boxi.harea(1)];
	else
	  resname{iprop}=[propnm{iprop} ' utilization'];
	end
	
	Resa{ibox}(:,iprop)=-scalefac.*Resa{ibox}(:,iprop);
	Resr{ibox}(:,iprop)=-scalefac.*Resr{ibox}(:,iprop);
	Dres{ibox}(:,iprop)= scalefac.*Dres{ibox}(:,iprop);
      otherwise
	  resname{iprop}=[propnm{iprop} ' residuals'];
	  resunit{iprop}=lunits{iprop};
    end %switch propnm{iprop}
    else 
      resname{iprop}=[propnm{iprop} ' residuals'];
      resunit{iprop}=lunits{iprop};
    end %p_res_units
  end %ibox
  else %if p_compw
    Wtrans=NaN;Dwtrans=NaN;
    Kztrans=NaN;Dkztrans=NaN;
    Resr=NaN;Dresr=NaN;
    Resa=NaN;Dres=NaN;
  end %if p_compw
end %iprop

%FRESHWATER FLUX
if any(strcmp(fieldnames(boxi.conseq),'freshwstd'))
  if ~exist('p_compw') | p_compw
    freshwater=boxi.conseq.freshw+bhat(pm.ifw);
    dfreshwater=sqrt(P(pm.ifw,pm.ifw));
    disp(sprintf('Adjusted Freswater flux (positive=P): %6.2g +/- %6.2g Sv',...
      freshwater,dfreshwater))
  else
    freshwater=NaN;
    dfreshwater=NaN;
  end
end

%%%%%%%% COMPUTE POSITIVE /NEGATIVE TRANSPORTS FOR EACH SECTION
% CRITERIA FOR WATER MASS TRANSPORT SELECTION
pltwmass=0
if pltwmass
  
  tmin=-5   %POTENTIAL TEMPERATURE
  tmax=1.15
  smin=0
  smax=50
  
  %RESIDUAL WATER MASS
  aresb=[];
  Resrel=0;
  Resb1=0;
  gicolb=[];
  
  for isa=1:Nsec
    %GET SECTION PAIR DATA
    secid=[gsecs.name{isa} gsecs.namesuf{isa}];
    datadir=gsecs.datadir{isa};
    getpdat
    %COMPUTE MATRIX WITH AREAS
    p_trig=1; %USE TRIANGLES AT BOTTOM
    Dep=sw_dpth(Presctd,Slat(1)); %more accurate with depth
    Botdep=sw_dpth(Botp,Slat);    %up to (0.6Sv difference)
    A0=mk_A0(p_trig,MPres,Dep,Botdep,Slat,Slon,ptemp,Maxd,...
      Maxdp,Npair);
    %ABSOLUTE VELOCITY IN M/S
    gicol=pm.gifcol(isa):(pm.gifcol(isa)+gsecs.npair(isa)-1 ...
      -any(strcmp(fieldnames(pm),'giEkcol')));
    gicolb=[gicolb,gicol];
    bhatsec=bhat(gicol);
    Va=grelvel{isa}+ones(MPres(1),1)*bhatsec'/100;
    %DENSITY AND POTENTIAL TEMPERATURE
    prhoi=sw_dens(psali,ptemp,Presctd);
    tpot=sw_ptmp(psali,ptemp,Presctd,0);
    
    %FIND LINEAR COMBINATION COEFF FOR bhat: apos/aneg
    apos=zeros(size(bhatsec'));
    aneg=zeros(size(bhatsec'));
    Trelpos=0;
    Trelneg=0;
    Tbpos1=0;
    ares=zeros(size(bhatsec'));
    for id=1:MPres(1)
      gipos=find((Va(id,:)>0) & (tpot(id,:)>tmin) & (tpot(id,:)<tmax) &...
	(psali(id,:)>smin) & (psali(id,:)<smax));
      if ~isempty(gipos)
	arhop=A0(id,gipos).*prhoi(id,gipos);
	Trelpos=Trelpos+sum(arhop.*grelvel{isa}(id,gipos));
	apos(gipos)=apos(gipos)+arhop;
	Tbpos1=Tbpos1+arhop*bhatsec(gipos)/100; %FOR TEST
      end
      gineg=find((Va(id,:)<0) & (tpot(id,:)>tmin) & (tpot(id,:)<tmax) &...
	(psali(id,:)>smin) & (psali(id,:)<smax));
      if ~isempty(gineg)
	arhon=A0(id,gineg).*prhoi(id,gineg);
	Trelneg=Trelneg+sum(arhon.*grelvel{isa}(id,gineg));
	aneg(gineg)=aneg(gineg)+arhon;
      end
      
      %FIND RESIDUAL OF A WATER MASS
      gires=find((tpot(id,:)>tmin) & (tpot(id,:)<tmax) &...
	(psali(id,:)>smin) & (psali(id,:)<smax));
      if ~isempty(gires)
	ares_=A0(id,gires).*prhoi(id,gires);
	Resrel=Resrel-gsecs.inboxdir(isa)*sum(ares_.*grelvel{isa}(id,gires));
	ares(gires)=ares(gires)-gsecs.inboxdir(isa)*ares_;
	Resb1=Resb1-gsecs.inboxdir(isa)*ares_*bhatsec(gires)/100;
      end
    end %id
    aresb=[aresb,ares];
    
    %TOTAL TRANPORT:
    Tpos{isa}=Trelpos+apos*bhatsec/100;
    Dtpos{isa}=sqrt(full(apos*P(gicol,gicol)*apos'))/100;
    Tneg{isa}=Trelneg+aneg*bhatsec/100;
    Dtneg{isa}=sqrt(full(aneg*P(gicol,gicol)*aneg'))/100;
  end %isa
  %Check if agrees with total transport
  for isa=1:Nsec
    disp((Tpos{isa}+Tneg{isa})/1e9+gsecs.EkmanT(isa))
  end
  
  %GET TOTAL RESIDUAL WATER MASS
  Restot=Resrel+aresb*bhat(gicolb)/100;
  Drestot=sqrt(full(aresb*P(gicolb,gicolb)*aresb'))/100;
end %pltwmass=0


%%%%%%%% HERE ADDITIONAL FLUX EQUATION TRANSPORTS
%Calculate Ekman transport based on the flux equations
%Ekman transport recomputation (if used)
if any(strcmp(fieldnames(gsecs),'dEkstd'))
  %bxi_showek
elseif p_calculate_Ekman
  disp('***************************************************')
  disp('Net flux estimation without Ekman nor Rhs:')
  disp('Same sign as Ekman flux in principle')
  %looks up mass flux equations
  for iflx=1:length(pm.eqname)
    if findstr(pm.eqname{iflx},'aflxmassnet') 
      flx=Amat(iflx,:)*bhat+G(iflx);
      dflx=sqrt(Amat(iflx,:)*P*Amat(iflx,:)');
      disp(sprintf('%s: %4.2g +/- %4.2g', pm.eqname{iflx},flx,dflx))
    end
  end
end %if p_calculate_Ekman

%%%%%%%% PLOTS
if any(strcmp(fieldnames(boxi),'glevels'))
  layids=boxi.glevels;
elseif any(strcmp(fieldnames(boxi),'sigint'))
  layids=boxi.sigint;
elseif any(strcmp(fieldnames(boxi),'plevels'))
  layids=boxi.plevels;
end

if p_plots
  hydrotrans_plot
end


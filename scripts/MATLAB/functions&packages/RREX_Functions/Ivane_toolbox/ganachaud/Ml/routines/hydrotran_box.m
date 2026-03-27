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
if ~exist('maxy')
  maxy=-7000;
end
 

Nconseq=size(boxi.liavg,2);
Nlay=boxi.nlay;
Nsec=size(gsecs.name,1);

for iprop=1:Nconseq
  disp(sprintf('CALCULATING %s TRANSPORTS ...',upper(propnm{iprop})))
  
  girow=(iprop-1)*Nlay+1:iprop*Nlay;
  %COMPUTE NET TRANSPORT FOR EACH SECTION/LAYER
  for isb=1:Nsec
    gicol=pm.gifcol(isb):pm.gilcol(isb);
    Tr{isb}(:,iprop)=sum(Gunsgn(girow,gicol),2)+gsecs.Ekt(:,isb,iprop);
    Ta{isb}(:,iprop)=Tr{isb}(:,iprop)+...
      -gsecs.inboxdir(isb)*Amat(girow,gicol)*bhat(gicol);
    dTa{isb}(:,iprop)=...
      full(sqrt(diag(Amat(girow,gicol)*P(gicol,gicol)*Amat(girow,gicol)')));
  end %isb
  
  %VERTICAL TRANSPORTS
  for ilayint=1:Nlay-2
    iwrow=1+girow(ilayint);
    iwcol=pm.ifwcol+ilayint-1;
    Wtrans(ilayint,iprop)=full(Amat(iwrow,iwcol)*bhat(iwcol));
    Dwtrans(ilayint,iprop)=sqrt(full(...
      Amat(iwrow,iwcol)*P(iwcol,iwcol)*Amat(iwrow,iwcol)'));
  end %ilayint
  if iwcol~=pm.ilwcol
    error('PROBLEM WITH W INDICES')
  end
  
  %RESIDUALS FOR CONSERVATION EQUATION
  if exist('Freshw') & any(Freshw)
    error('RESIDUALS NOT PROGRAMMED WITH FRESHWATER')
  end
  Resr(:,iprop)=G(girow)+Ekman(girow);
  Resa(:,iprop)=Amat(girow,:)*bhat+Resr(:,iprop);
  Dres(:,iprop)=sqrt(full(diag(Amat(girow,:)*P*Amat(girow,:)')));
  
end %iprop

%%%%%%%% COMPUTE POSITIVE /NEGATIVE TRANSPORTS FOR EACH SECTION
% CRITERIA FOR WATER MASS TRANSPORT SELECTION
pltwmass=0
if pltwmass
  
  tmin=5   %POTENTIAL TEMPERATURE
  tmax=10
  smin=35
  smax=35.5
  
  %RESIDUAL WATER MASS
  aresb=[];
  Resrel=0;
  Resb1=0;
  gicolb=[];
  
  for isb=1:Nsec
    %GET SECTION PAIR DATA
    secid=[gsecs.name{isb} gsecs.namesuf{isb}];
    datadir=gsecs.datadir{isb};
    getpdat
    %COMPUTE MATRIX WITH AREAS
    p_trig=1; %USE TRIANGLES AT BOTTOM
    Dep=sw_dpth(Presctd,Slat(1)); %more accurate with depth
    Botdep=sw_dpth(Botp,Slat);    %up to (0.6Sv difference)
    A0=mk_A0(p_trig,MPres,Dep,Botdep,Slat,Slon,ptemp,Maxd,...
      Maxdp,Npair);
    %ABSOLUTE VELOCITY IN M/S
    gicol=pm.gifcol(isb):pm.gilcol(isb);
    gicolb=[gicolb,gicol];
    bhatsec=bhat(gicol);
    Va=grelvel{isb}+ones(MPres(1),1)*bhatsec'/100;
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
	Trelpos=Trelpos+sum(arhop.*grelvel{isb}(id,gipos));
	apos(gipos)=apos(gipos)+arhop;
	Tbpos1=Tbpos1+arhop*bhatsec(gipos)/100; %FOR TEST
      end
      gineg=find((Va(id,:)<0) & (tpot(id,:)>tmin) & (tpot(id,:)<tmax) &...
	(psali(id,:)>smin) & (psali(id,:)<smax));
      if ~isempty(gineg)
	arhon=A0(id,gineg).*prhoi(id,gineg);
	Trelneg=Trelneg+sum(arhon.*grelvel{isb}(id,gineg));
	aneg(gineg)=aneg(gineg)+arhon;
      end
      
      %FIND RESIDUAL OF A WATER MASS
      gires=find((tpot(id,:)>tmin) & (tpot(id,:)<tmax) &...
	(psali(id,:)>smin) & (psali(id,:)<smax));
      if ~isempty(gires)
	ares_=A0(id,gires).*prhoi(id,gires);
	Resrel=Resrel-gsecs.inboxdir(isb)*sum(ares_.*grelvel{isb}(id,gires));
	ares(gires)=ares(gires)-gsecs.inboxdir(isb)*ares_;
	Resb1=Resb1-gsecs.inboxdir(isb)*ares_*bhatsec(gires)/100;
      end
    end %id
    aresb=[aresb,ares];
    
    %TOTAL TRANPORT:
    Tpos{isb}=Trelpos+apos*bhatsec/100;
    Dtpos{isb}=sqrt(full(apos*P(gicol,gicol)*apos'))/100;
    Tneg{isb}=Trelneg+aneg*bhatsec/100;
    Dtneg{isb}=sqrt(full(aneg*P(gicol,gicol)*aneg'))/100;
  end %isb
  %Check if agrees with total transport
  for isb=1:Nsec
    disp((Tpos{isb}+Tneg{isb})/1e9+gsecs.EkmanT(isb))
  end
  
  %GET TOTAL RESIDUAL WATER MASS
  Restot=Resrel+aresb*bhat(gicolb)/100;
  Drestot=sqrt(full(aresb*P(gicolb,gicolb)*aresb'))/100;
end

%%%%%%%% HERE ADDITIONAL FLUX EQUATION TRANSPORTS

%%%%%%%% PLOTS
if any(strcmp(fieldnames(boxi),'glevels'))
  layids=boxi.glevels;
elseif any(strcmp(fieldnames(boxi),'sigint'))
  layids=boxi.sigint;
end

hydrotran_box_plot


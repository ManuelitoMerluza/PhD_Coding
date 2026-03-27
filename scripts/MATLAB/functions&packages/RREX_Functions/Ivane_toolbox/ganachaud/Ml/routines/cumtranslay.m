%scrippt cumtranslay 
% KEY: get the cumulative water mass transport from section end 
%with uncertainty 
%See run_global.m. Need to have in memory bhat and Amat
% USAGE :
%
% DESCRIPTION : 
%
% INPUT: 
%
% OUTPUT:
%
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu)
% March 99
%
% SIDE EFFECTS :
%
% SEE ALSO :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER:
% CALLEE:
    disp(['Layer transports section ' gsecs.name{isa}])
    if p_pltstream
      error('cumtranslay not compatible with p_pltstream')
    end
    if ~exist('xax')
      xax='lon';
    end
    switch gsecs.name{isa}
      %PROGRAM LAYER SEPARATION
      case {'A2','A5','A6','a24n_flst','a24n_flst+','A7'}
        if p_cstbnd
	  gilseparation=[7,14];xax='lon';
	else
	  gilseparation=[5,7,15];
	end
        gilseparation=[7]
      case {'A8','A9','A10','A11'}
        if p_cstbnd
	  gilseparation=[6,11];xax='lon';
	else
	  gilseparation=[4,5,12];
	end
      case {'P6','P21','P21W','P21W+','P21E'}
        if p_cstbnd
	  gilseparation=[10,16];xax='lon';
	else
	  gilseparation=[3,8,12,16];%Water mass 26-27.35-27.95-28.125
	end
      case {'P3','P1'} %Water mass acc. to Table 3.5 26-27.35-27.95-28.125
        if p_cstbnd
	  gilseparation=[10,16];xax='lon';
	else
	  gilseparation=[3,8,12,17];
	end
      case {'I5','I3+','I3','I2','I2W','I2W+','I2+','I4'}
        if exist('p_indianpaper')&p_indianpaper
	  %forces separation at 27.96
	  gilseparation=7;%9
	else
	  if p_cstbnd
	    gilseparation=[6,9];xax='lon';
	  else
	    gilseparation=[7,9,10];
	  end
	end
      case {'I10','J8992'}
        if exist('p_indianpaper')&p_indianpaper
	  %forces separation at 27.96
	  gilseparation=7;%9
	else
	  if p_cstbnd
	    gilseparation=[6,9]; xax='lat';
	  else
	    gilseparation=[7,9,10];
	  end
	end
      case {'A21','A12','I6','I9S','P12','P14S'}
        if p_cstbnd
	  gilseparation=[6,9];xax='lat';
	else
	  gilseparation=[3,5,14];
	end
      otherwise 
	error('section not programed')
    end
    nplots=length(gilseparation)+1;
    
    %%%%%%%%%%%%%%%%%%%%%%%
    % LOOP OVER PROPERTIES
    %%%%%%%%%%%%%%%%%%%%%%%
    clear Tgb dTgb Tgr
      
    for iprop=giprop
      if all(boxsec(isa))
	girow=pm.ibfrow(boxsec(isa))-1+[(iprop-1)*Nlay+1:iprop*Nlay];
      else
	error('not programmed for many boxes')
      end
      %Re-CREATE ORIGINAL A MATRIX FOR NET TRANSPORT COMPUTATION IF ANOMALY
      %WERE USED IN CONSERVATION EQUATIONS.
      if any(strcmp(fieldnames(boxi.conseq),'anom'))&...
	  length(boxi.conseq.anom)>=iprop &...
	  boxi.conseq.anom(iprop)~=0 & iprop~=1
	disp('NET TRANSPORTS ARE ABSOLUTE (NOT ANOMALEOUS)')
	C0=boxi.lavg(:,iprop)*1e9/1000/lscale(iprop);
	Amatnet=Amat(girow,:)+C0*ones(1,size(Amat,2)).*Amat(1:Nlay,:);
	Gunsgnnet=Gunsgn(girow,:)+C0*ones(1,size(Amat,2)).*Gunsgn(1:Nlay,:);
      else
	Amatnet=Amat(girow,:);
	Gunsgnnet=Gunsgn(girow,:);
      end    
      
      %LOOP OVER THE DIFFERENT SETS OF LAYERS TO SUM
      gisec=isa;
      if exist('p_combinesec')
	if p_combinesec{isa}
	  disp(['combining ' gsecs.name{isa} ' with '...
	      gsecs.name{p_combinesec{isa}}])
	  if isempty(findstr(gsecs.name{isa},'+'))
	    gsecs.name{isa}=[gsecs.name{isa} '+'];
	  end
	  gisec=[isa,p_combinesec{isa}];
	  if (gsecs.inboxdir(gisb(isa))*...
	      gsecs.inboxdir(gisb(p_combinesec{isa})))==-1
	    error('section combined but not oriented same')
	  end
	end
      end
      for il=1:nplots
	Ag=[];
	npairs=0;
	Gicol=[];
	Tekk=[];
	Xabs=[];
	Splon=[];
	Splat=[];
	for isb=gisec
	  secid=[gsecs.name{isb} gsecs.namesuf{isb}];
	  datadir=gsecs.datadir{isb};
	  hdrname = [secid '_pair.hdr.mat'];
	  istr=findstr(hdrname,'+');
	  hdrname(istr)=[];
	  str=['load ' datadir hdrname ];
	  disp(str);eval(str)
	  
	  %disp([(1:boxi.nlay)' Ta{isb}(:,1)  dTa{isb}(:,1)])
	  if strcmp(xax,'lon')
	    xabs=Plon;
	    xlab=[gsecs.name{isb} ' Longitude'];
	  elseif strcmp(xax,'lat')
	    xabs=Plat;
	    xlab=[gsecs.name{isb} ' Latitude'];
	  elseif strcmp(xax,'dist')
	    xabs=cumsum([sw_dist(Slat,Slon,'km')]);
	    %pxabs=(xabs(1:gsecs.npair(isb)-1)+xabs(2:gsecs.npair(isb)))/2;
	    xlab=[gsecs.name{isb} ' distance (km)'];
	  end
	  Xabs=[Xabs;xabs];
	  Splon=[Splon;Plon];
	  Splat=[Splat;Plat];
	  if il==1
	    gil=(1:gilseparation(1)-1)';
	    Gustr{il}=[gsecs.name{isb} ', surface'];
	    Glstr{il}=sprintf('\\Gamma =%1.5g',boxi.glevels(max(gil)+1));
	  elseif il==nplots
	    gil=(gilseparation(nplots-1):(boxi.nlay-1))';
	    Gustr{il}=sprintf('\\Gamma =%1.5g',boxi.glevels(min(gil)));
	    Glstr{il}='bottom';
	  else
	    gil=(gilseparation(il-1):(gilseparation(il)-1))';
	    Gustr{il}=sprintf('\\Gamma =%1.5g',boxi.glevels(min(gil)));
	    Glstr{il}=sprintf('\\Gamma =%1.5g',boxi.glevels(max(gil)+1));
	  end   
	  gicol=pm.gifcol(isb):pm.gilcol(isb)-1;
	  Gicol=[Gicol,gicol];
	  tekk=gsecs.Ekt(:,gisb(isb),iprop);
	  inboxdirr=gsecs.inboxdir(gisb(isb));
	  %Layer summation
	  Ag=[Ag,sum(-inboxdirr*Amatnet(gil,gicol),1)];
	end%loop on isb
	%CUMULATOR FROM WEST/NORD
	%Cumulative tranport from b
	npairs=length(Gicol);
	Cumpairs=tril(ones(npairs,npairs));
	Ag=diag(Ag);%Make it diagonal
	Tgb{iprop}(:,il)=Cumpairs*Ag*bhat(Gicol);
	dTgb{iprop}(:,il)=sqrt(diag(Cumpairs*Ag*P(Gicol,Gicol)*Ag'*Cumpairs'));
	%Cumulative transport Relative 
%	Tgr{iprop}(:,il)=cumsum(full(sum(Gunsgn(girow(gil),Gicol),1)'));
	Tgr{iprop}(:,il)=cumsum(full(sum(Gunsgnnet(gil,Gicol),1)'));
      
	%Checktest
	a=ones(1,length(gil));
	Trtest=a*(sum(Gunsgnnet(gil,Gicol),2));
	Tatest=Trtest...
	  -a*inboxdirr*Amatnet(gil,Gicol)*bhat(Gicol);
	disp([Tatest, Tgb{iprop}(npairs,il)+Tgr{iprop}(npairs,il), Tatest-Tgb{iprop}(npairs,il)-Tgr{iprop}(npairs,il)])
	dTatest=full(sqrt(a*Amatnet(gil,Gicol)*...
	  P(Gicol,Gicol)*Amatnet(gil,Gicol)'*a'));
	if 0 %consitency size
	  disp(iprop)
	  Trtest,Tgr{iprop}(length(Gicol),il)
	  Tatest,Tgb{iprop}(length(Gicol),il)+Tgr{iprop}(length(Gicol),il)
	  ppause
	end
      end %loop over n layers
      
      %PLOTS
      if p_plots
	figure(isa);clf
	for il=1:nplots
	  subplot(nplots,1,il)
	  pl1=fill([Xabs;reverse(Xabs)],[dTgb{iprop}(:,il);-reverse(dTgb{iprop}(:,il))],...
	    .85*[1 1 1 ]);
	  set(pl1,'EdgeColor',.85*[1 1 1]);hold on;grid on
	  pl2=plot(Xabs,Tgb{iprop}(:,il)+Tgr{iprop}(:,il),'k-','linewidth',1.5);
	  pl3=plot(Xabs,Tgr{iprop}(:,il),'k--');
	  pl4=plot(Xabs,Tgb{iprop}(:,il),'k.','markersize',6);
	  set(gca,'xlim',[min(Xabs) max(Xabs)])
	  title(sprintf('%s to %s', Gustr{il}, Glstr{il}))
	  if strcmp(xax,'lat')
	    set(gca,'xdir','reverse')
	    labelaxlat
	  elseif strcmp(xax,'lon')
	    labelaxlong(gca)
	  end
	  ylabel([propnm{iprop} ' ' lunits{iprop}])
	  if il~=nplots
	    set(gca,'xticklabel','')
	  end
	end %loop over nplots
	
	setlargefig;ppause
      end%if p_plots
    end%for iprop
    
    %Save: Xabs Tgb+Tgr dTgb Gustr Glstr
    %In a global variable
    %cTransec
    
    %SAVE SECTION ONLY IF NOT HERE
    disp(['Section ' gsecs.name{isa}])
    if ~exist('cTransec')
      p_update=1;
      isa_global=0;
    else
      p_update=1;
      for isb=1:length(cTransec)
	if strcmp(cTransec(isb).secname,gsecs.name{isa})
	  p_update=0;
	  disp('already there')
	end
      end
    end %~exist('cTransec')
    if p_update
      %disp(gsecs.name{isa});ppause;
      isa_global=isa_global+1;
      cTransec(isa_global).secname=gsecs.name{isa};
      cTransec(isa_global).box=boxname1{ibox1};
      cTransec(isa_global).nlay=size(Tgb{iprop},2);
      cTransec(isa_global).xax=xax;
      cTransec(isa_global).xabs=Xabs;
      cTransec(isa_global).splon=Splon;length(Splon)
      cTransec(isa_global).splat=Splat;
      for iprop=giprop
	cTransec(isa_global).Tgr{iprop}=Tgr{iprop};
	cTransec(isa_global).Tga{iprop}=Tgb{iprop}+Tgr{iprop};
	cTransec(isa_global).dTba{iprop}=dTgb{iprop};
      end
      cTransec(isa_global).Gustr=Gustr;
      cTransec(isa_global).Glstr=Glstr;
      cTransec(isa_global).Tunits=lunits;
      cTransec(isa_global).Tscale=lscale;
      disp('west-cumulative recorded')
    end
    
  

%scrippt cumtranslay 
% KEY: get the cumulative water mass transport from section end 
%with uncertainty 
%See run_global.m. Need to have in memory bhat and Amat
% USAGE :
% 
%
%
%
% DESCRIPTION : 
%
%
% INPUT: 
%
%
% OUTPUT:
%
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , March 99
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
    secid=[gsecs.name{isa} gsecs.namesuf{isa}];
    datadir=gsecs.datadir{isa};
    hdrname = [secid '_pair.hdr.mat'];
    istr=findstr(hdrname,'+');
    hdrname(istr)=[];
    str=['load ' datadir hdrname ];
    disp(str);eval(str)
    
    if strcmp(xax,'lon')
      xabs=Slon;pxabs=Plon;
      xlab=[gsecs.name{isa} ' Longitude'];
    elseif strcmp(xax,'lat')
      xabs=Slat;pxabs=Plat;
      xlab=[gsecs.name{isa} ' Latitude'];
    elseif strcmp(xax,'dist')
      xabs=cumsum([0;sw_dist(Slat,Slon,'km')]);
      pxabs=(xabs(1:gsecs.npair(isa)-1)+xabs(2:gsecs.npair(isa)))/2;
      xlab=[gsecs.name{isa} ' distance (km)'];
    end

    disp([(1:boxi.nlay)' Ta{isa}(:,1)  dTa{isa}(:,1)])
    switch gsecs.name{isa}
      %PROGRAM LAYER SEPARATION
      case {'A2','A5','A6','a24n_flst','A7'}
        if p_cstbnd
	  gilseparation=[7,14]
	else
	  gilseparation=[5,7,15];
	end
      case {'A8','A9','A10','A11'}
        if p_cstbnd
	  gilseparation=[6,11]
	else
	  gilseparation=[4,5,12];
	end
      case {'P6','P21','P21W','P21E'}
        if p_cstbnd
	  gilseparation=[10,16];
	else
	  gilseparation=[3,8,12,16];%Water mass 26-27.35-27.95-28.125
	end
      case {'P3','P1'} %Water mass acc. to Table 3.5 26-27.35-27.95-28.125
        if p_cstbnd
	  gilseparation=[10,16];
	else
	  gilseparation=[3,8,12,17];
	end
      case {'I5','I3+','I3','I2','I2W','I2+','I10','I4','J8992'}
        if exist('p_indianpaper')&p_indianpaper
	  %forces separation at 27.96
	  gilseparation=7;%9
	else
	  if p_cstbnd
	    gilseparation=[6,9];
	  else
	    gilseparation=[7,9,10];
	  end
	end
      case {'A21','A12','I6','I9S','P12','P14S'}
        if p_cstbnd
	  gilseparation=[6,9];
	else
	  gilseparation=[3,5,14];
	end
      otherwise 
	error('section not programed')
    end
    nplots=length(gilseparation)+1; 
    girow=pm.ibfrow(boxsec(isa))-1+[(iprop-1)*Nlay+1:iprop*Nlay];
    gicol=pm.gifcol(isa):pm.gilcol(isa);
    tekk=gsecs.Ekt(:,gisb(isa),iprop);
    inboxdirr=gsecs.inboxdir(gisb(isa));
    clear Tgb dTgb Tgr
    
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
    for il=1:nplots
      if il==1
	gil=(1:gilseparation(1)-1)';
	Gustr{il}=[gsecs.name{isa} ', surface'];
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
      %CUMULATOR FROM WEST/NORD
      npairs=length(gicol);
      Cumpairs=tril(ones(npairs,npairs));
      %Layer summation
      Ag=sum(-inboxdirr*Amatnet(gil,gicol),1);
      %Make it diagonal
      Ag=diag(Ag);
      %Cumulative tranport from b
      Tgb(:,il)=Cumpairs*Ag*bhat(gicol);
      dTgb(:,il)=sqrt(diag(Cumpairs*Ag*P(gicol,gicol)*Ag'*Cumpairs'));
      
      %Cumulative transport Relative 
      Tgr(:,il)=cumsum(full(sum(Gunsgn(girow(gil),gicol),1)'));
      
      %Checktest
      a=ones(1,length(gil));
      Trtest=a*(sum(Gunsgn(girow(gil),gicol),2));
      Tatest=Trtest...
	-a*inboxdirr*Amatnet(gil,gicol)*bhat(gicol);
      dTatest=full(sqrt(a*Amatnet(gil,gicol)*...
	P(gicol,gicol)*Amatnet(gil,gicol)'*a'));
    end %loop over nplots
     
    %PLOTS
    figure(isa)
    for il=1:nplots
      subplot(nplots,1,il)
      pl1=fill([xabs;reverse(xabs)],[dTgb(:,il);-reverse(dTgb(:,il))],...
	.85*[1 1 1 ]);
      set(pl1,'EdgeColor',.85*[1 1 1]);hold on;grid on
      pl2=plot(xabs,Tgb(:,il)+Tgr(:,il),'k-','linewidth',1.5);
      pl3=plot(xabs,Tgr(:,il),'k--');
      pl4=plot(xabs,Tgb(:,il),'k.','markersize',6);
      set(gca,'xlim',[min(xabs) max(xabs)])
      title(sprintf('%s to %s', Gustr{il}, Glstr{il}))
      if strcmp(xax,'lat')
	set(gca,'xdir','reverse')
	labelaxlat
      elseif strcmp(xax,'lon')
	labelaxlong(gca)
      end
      ylabel('Sv')
      if il~=nplots
	set(gca,'xticklabel','')
      end
    end %loop over nplots

    setlargefig;
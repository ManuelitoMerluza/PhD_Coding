%hydrotrans_plot: part of hydrotrans.m
%set the lower bound for all axes
if ~exist('p_resonly') %option to plot only residuals
  p_resonly=0;
end
if ~exist('p_posterplot') %option to plot all absoute results
  p_posterplot=0; %1-> small plots , 2-> big plots
end
if ~exist('p_bw')
  p_bw=0;
end
maxy=0;
for isa=1:Nsec
  maxy=min([maxy,-500*ceil(max(cumsum(Lays{isa}.lavgwdth(1:Nlay-1))/500))]);
end

if ~exist('ifig')
  ifig=0;
end
if ~exist('gprop2plot')
  disp('Plotting all properties')
  gprop2plot=1:Nconseq;
end
for iprop=gprop2plot
  if strcmp(propnm{iprop},'oxyg')&~p_res_units
    %convert units to 10^3 kmol/sec
    disp('Converting Oxygen to 10^3 kmol/sec')
    tscale=1e3;
    lunits{iprop}='10^3kmol/s';
    resunits{iprop}='10^3kmol/s';
  else
    tscale=1;
  end
 
  %PLOT FLUX
  if ~p_resonly | ~exist('windw') | windw==6 | windw==0
    windw=0;
    ifig=ifig+1;figure(ifig);clf;set(gcf,'position',[17 20 600 750])
  end
  
  %ylab='Pressure';
  ylab=[];
  if ~p_resonly
    for isa=1:Nsec
      if ~p_posterplot | ~exist('section_plotted') |...
	  (exist('section_plotted')&...
	  all(strcmp(section_plotted,gsecs.name{isa})==0))
	%section not already plotted in another box
	if windw==6
	  ifig=ifig+1;figure(ifig);clf
	  set(gcf,'position',[17 20 600 750]);windw=0;
	end
	%Layer interface approx mean depth
	layintd=-[0;cumsum(Lays{isa}.lavgwdth(1:Nlay-1))'];
	layintdall{isa}=layintd;

	if ~p_posterplot
	  if ~p_bw
	    c=[1 0 0];
	  else
	    c=[0 0 0];
	  end
	  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	  %RELATIVE T ~p_posterplot
	  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	  windw=windw+1;
	  if p_pltstream
	    ttl=sprintf('%s %s streamf R', gsecs.name{isa},propnm{iprop});
	  else
	    ttl=sprintf('%s %s (Relative)', gsecs.name{isa},propnm{iprop});
	  end
	  rxlab=sprintf('Total: %4.2g %s',Tr{isa}(Nlay,iprop)/tscale,lunits{iprop});
	  laylabels=layids(2:Nlay-1);
	  cpstair1(windw,Tr{isa}(1:Nlay-1,iprop)/tscale,layintd,[],rxlab,ylab,...
	    ttl,laylabels,0,1,'n',[],0,maxy,[],p_posterplot)
	  if p_pltstream
	    ttl=sprintf('%s %s streamf A', gsecs.name{isa},propnm{iprop});
	  else
	    ttl=sprintf('%s %s (Absolute)', gsecs.name{isa},propnm{iprop});
	  end
	  rxlab=sprintf('Total: %5.3g \\pm %4.2g %s',Ta{isa}(Nlay,iprop)/tscale,...
	    dTa{isa}(Nlay,iprop)/tscale,lunits{iprop});
	else %if ~p_posterplot
	  if ~exist('isabsolute')
	    isabsolute=1;
	  elseif iprop==max(gprop2plot)
	    isabsolute=isabsolute+1;
	  end
	  %section_plotted{isabsolute}=gsecs.name{isa};
	  if ~p_bw
	    set(gcf,'defaultaxesXcolor','r')
	    set(gcf,'defaultaxesYcolor','r')
	    set(gcf,'defaulttextcolor','r')
	    c=[1 0 0];
	  else
	    set(gcf,'defaultaxesXcolor','k')
	    set(gcf,'defaultaxesYcolor','k')
	    set(gcf,'defaulttextcolor','k')
	    c=[0 0 0];
	  end
	  if p_posterplot==1
	    laylabels=[];
	  else
	    laylabels=layids(2:Nlay-1);
	  end
	  if p_pltstream
	    ttl=sprintf('%s streamf', gsecs.name{isa});
	  else
	    ttl=sprintf('%s flux', gsecs.name{isa});
	  end  
	  if p_posterplot==1
	    rxlab=sprintf('Net:%5.3g\\pm%4.2g',Ta{isa}(Nlay,iprop)/tscale,...
	      dTa{isa}(Nlay,iprop)/tscale);
	  else
	    rxlab=sprintf('%4.3g\\pm%4.2g%s',Ta{isa}(Nlay,iprop)/tscale,...
	      dTa{isa}(Nlay,iprop)/tscale,lunits{iprop});
	  end
	end %if ~p_posterplot
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%ABSOLUTE  T 
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	if exist('figwsections')&...
	    any(strcmp(gsecs.name{isa},figwsections.secs))
	  curfig=gcf;
	  figure(figwsections.ifig)
	  disp(sprintf('putting %s in fig %i, OK ? ',gsecs.name{isa},...
	    figwsections.ifig))
	  %ppause
	  sindex=find(strcmp(gsecs.name{isa},figwsections.secs));
	  windw=figwsections.window(sindex);
	  ttl=figwsections.ttl{sindex};
	  xaxS=figwsections.xax;
	  cpstair1(windw,Ta{isa}(1:Nlay-1,iprop)/tscale,layintd,xaxS,rxlab,ylab,...
	    ttl,laylabels,0,1,c,[],0,maxy,dTa{isa}(1:Nlay-1,iprop)/tscale,3)
	  figure(curfig);
	else
	  windw=windw+1;
	  cpstair1(windw,Ta{isa}(1:Nlay-1,iprop)/tscale,layintd,[],rxlab,ylab,...
	    ttl,laylabels,0,1,c,[],0,maxy,dTa{isa}(1:Nlay-1,iprop)/tscale,p_posterplot)
	end
	      end %~(p_posterplot&exist('section_plotted')&
    end %isa
    drawnow
  end %if p_resonly

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %PLOT RESIDUALS AND DIA-NEUTRAL TERMS
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
  layintd=-[0;cumsum(boxi.lavgwdth(1:Nlay-1))];
  %select the non zero layers
  glay=find(~isnan(layintd));
  layintd=layintd(glay);
  glay=glay(1:length(glay)-1);nglay=length(glay);
   
  %BEFORE INVERSION
  maxy=-500*ceil(max((-layintd)/500));

  for ibox=1:Nbox
    if p_res_units
      tscaler=1;
    else
      tscaler=tscale;
    end
    if ~p_posterplot
      ifig=ifig+1;figure(ifig);clf;set(gcf,'position',[17 20 600 750])
      windw=1;
      if any(strcmp(fieldnames(boxi.conseq),'anom'))&...
	  boxi.conseq.anom(iprop)==1
	ttl=sprintf('%s Init Anom %s ',boxi.name, resname{iprop});
      else
	ttl=sprintf('%s Initial %s ',boxi.name, resname{iprop});
      end
      rxlab=sprintf('Net: %4.2g %s',Resr{ibox}(Nlay,iprop)/tscaler,lunits{iprop});
      cpstair1(windw,Resr{ibox}(glay,iprop)/tscaler,layintd,[],rxlab,ylab,...
	ttl,layids(glay(2:nglay)),0,1,'n',[],0,maxy,...
	Dresr{ibox}(glay,iprop)/tscaler,p_posterplot)
      laylabels=layids(glay(2:nglay));
      %AFTER
      windw=2;
    else %if ~p_posterplot
      if ~p_resonly
	%windw=6;
	windw=4;
      else
	windw=windw+1;
      end
      if ~p_bw
	set(gcf,'defaultaxesXcolor','b')
	set(gcf,'defaultaxesYcolor','b')
	set(gcf,'defaulttextcolor','b')
	c=[0 0 1];
      else
	c=[0 0 0];
      end
      if p_posterplot==1
	laylabels=[];  %do not put the layer labels
      else
	laylabels=layids(glay(2:nglay));
      end
    end
    if ~p_posterplot
      if any(strcmp(fieldnames(boxi.conseq),'anom'))&...
	  boxi.conseq.anom(iprop)==1
	ttl=sprintf('%s anom', resname{iprop});
      else
	ttl=sprintf('%s', resname{iprop});
      end	
      rxlab=sprintf('Net: %3.2g \\pm %3.2g %s',Resa{ibox}(Nlay,iprop)/tscaler,...
	Dres{ibox}(Nlay,iprop)/tscaler,resunit{iprop});
    else
      if p_resonly & iprop==1
	ttl=sprintf('%s residuals',boxi.name);
      else
	if any(strcmp(fieldnames(boxi.conseq),'anom'))&...
	    boxi.conseq.anom(iprop)==1
	  ttl=sprintf('%s Anom', resname{iprop});
	else
	  ttl=sprintf('%s', resname{iprop});
	end
      end
      if p_posterplot==1
	rxlab=sprintf('%3.2g \\pm %3.2g',Resa{ibox}(Nlay,iprop)/tscaler,...
	  Dres{ibox}(Nlay,iprop)/tscaler);
      else
	rxlab=sprintf('%3.2g\\pm%3.2g%s',Resa{ibox}(Nlay,iprop)/tscaler,...
	  Dres{ibox}(Nlay,iprop)/tscaler,resunit{iprop});
      end
    end
    if exist('figwres')&...
	any(strcmp(boxi.name,figwres.boxes))
      curfig=gcf;
      figure(figwres.ifig)
      disp(sprintf('putting %s in fig %i, OK ? ',boxi.name,...
	figwres.ifig))
      %ppause
      sindex=find(strcmp(boxi.name,figwres.boxes));
      windw=figwres.window(sindex);
      if any(strcmp(fieldnames(figwres),'ttl'))
	ttl=figwres.ttl{sindex};
	xaxR=figwres.xax;
      end
      cpstair1(windw,Resa{ibox}(glay,iprop)/tscaler,layintd,xaxR,rxlab,ylab,...
	ttl,laylabels,0,1,c,[],0,maxy,Dres{ibox}(glay,iprop)/tscaler,3);
      figure(curfig);
    else
      cpstair1(windw,Resa{ibox}(glay,iprop)/tscaler,layintd,[],rxlab,ylab,...
	ttl,laylabels,0,1,c,[],0,maxy,Dres{ibox}(glay,iprop)/tscaler,p_posterplot)
    end
    if ~p_resonly
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %DIA-NEUTRAL TERMS
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      ttlW=sprintf('%s W^* transport', propnm{iprop});
      rxlabW=sprintf('%s',lunits{iprop});
      ttlKz=sprintf('%s \\kappa_z transport', propnm{iprop});
      rxlabKz=sprintf('%s',lunits{iprop});
      if ~p_posterplot
	windwW=3;
	if any(Wtrans{ibox}(:,iprop)/tscale)
	  ttlW=sprintf('W^* flux', propnm{iprop});
	  cpstair1(windwW,Wtrans{ibox}(:,iprop)/tscale,layintd,[],rxlabW,ylab,...
	    ttlW,laylabels,0,1,c,[],0,maxy,Dwtrans{ibox}(:,iprop)/tscale,p_posterplot)
	end
	if any(strcmp(fieldnames(boxi.conseq),'Kzstd'))
	  windwKz=4;
	  if iprop==1
	    %PLOT W* and Kz themselves
	    windw=5;
	    rxlab='cm s^{-1}';
	    ttl='W^*';
	    gibhat=pm.ifwcol:pm.ilwcol;
	    cpstair1(windw,bhat(gibhat),layintd,[],rxlab,ylab,...
	      ttl,laylabels,0,1,c,[],0,maxy,sqrt(diag(P(gibhat,gibhat))), ...
	      p_posterplot)
	    windw=6;
	    rxlab='cm^2 s^{-1}';
	    ttl='\kappa_z';
	    gibhat=pm.ifKzcol:pm.ilKzcol;
	    cpstair1(windw,bhat(gibhat),layintd,[],rxlab,ylab,...
	      ttl,laylabels,0,1,c,[],0,maxy,sqrt(diag(P(gibhat,gibhat))), ...
	      p_posterplot)
	  end %if iprop==1
	else %if any(strcmp(fieldnames(boxi.conseq),'Kzstd'))
	  windwKz=0;
	end %if any(strcmp(fieldnames(boxi.conseq),'Kzstd'))
      else %if ~p_posterplot
	if any(strcmp(fieldnames(boxi.conseq),'Kzstd')) &...
	    any(boxi.conseq.Kzstd>1e-6)
	  windwKz=5;
	  if windw>=5
	    disp(' put Kz instead of last section')
	  end
	else
	  windwKz=0;
	end
	set(gca,'YTickLabel','')
	if ~p_bw
	  set(gcf,'defaultaxesXcolor','g')
	  set(gcf,'defaultaxesYcolor','g')
	  set(gcf,'defaulttextcolor','g')
	  c=[0 1 0];
	else
	  c=[0 0 0];
	end
	if any(Wtrans{ibox}(:,iprop)/tscale)
	  windwW=6;%windw+1;
	  if windw>=6
	    disp('put W instead of last section')
	  end
	  ttlW=sprintf('W^* flux', propnm{iprop});
	  %rxlabW=[];
	  xaxW=[];
	  xaxKz=[];
	  if exist('figwwk')
	    curfig=gcf;
	    for iff=1:length(figwwk)
	      sindex=find(strcmp(boxi.name,figwwk(iff).boxes));
	      windwW=figwwk(iff).window(sindex,1);
	      windwKz=figwwk(iff).window(sindex,2);
	      p_posterplot=3;
	      if ~isempty(sindex)
		figure(figwwk(iff).ifig)
		disp(sprintf('W %s in fig %i, OK ? ',boxi.name,...
		  figwwk(iff).ifig))
		if any(strcmp(fieldnames(figwwk(iff)),'ttlW'))
		  ttlW=figwwk(iff).ttlW{sindex};
		  %ttlKz=figwwk(iff).ttlKz{sindex};
		end
		if any(strcmp(fieldnames(figwwk(iff)),'xaxW'))
		  xaxW=figwwk(iff).xaxW;
		  xaxKz=figwwk(iff).xaxKz;
		end
		break
	      end
	    end
	  end	  
	  if ~isempty(windwW)
	    cpstair1(windwW,Wtrans{ibox}(:,iprop)/tscale,layintd,xaxW,rxlabW,ylab,...
	      ttlW,laylabels,0,1,c,[],0,maxy,Dwtrans{ibox}(:,iprop)/tscale,p_posterplot)
	    if p_wstarandwtran
	      cpstair2(gca,bhat(pm.ifwcol:pm.ilwcol),layintd,...
		'w* (\times 10^{-6}ms^{-1})',figwwk(iff).wslim)
	    end
	  end
	end
	if windwKz
	  if iprop~=1
	    cpstair1(windwKz,Kztrans{ibox}(:,iprop)/tscale,layintd,[],rxlabKz,ylab,...
	      ttlKz,laylabels,0,1,c,[],0,maxy,Dkztrans{ibox}(:,iprop)/tscale,p_posterplot)
	  else %PLOT Kz, not transport,  mass
	    rxlab='\kappa_z (cm^2 s^{-1})';
	    ttl='';
	    gibhat=pm.ifKzcol:pm.ilKzcol;
	    cpstair1(windwKz,bhat(gibhat),layintd,xaxKz,rxlab,ylab,...
	      ttl,laylabels,0,1,c,[],0,maxy,sqrt(diag(P(gibhat,gibhat))), ...
	      p_posterplot)
	  end
	  if p_posterplot==3
	    figure(curfig);p_posterplot=2;
	  end
	end %windwKz
      end %if ~p_posterplot
    end %if ~p_resonly
  end %ibox
  
end %iprop

if exist('p_plotcumtrans')&p_plotcumtrans
  for iprop=1:gprop2plot
    for isa=1:Nsec
      figure
      plot(cTr{isa,iprop}');
      text(gsecs.npair(isa)*ones(Nlay,1),...
	full(cTr{isa,iprop}(:,gsecs.npair(isa))),...
	reshape(sprintf('%02i',1:Nlay),2,Nlay)',...
	'fontsize',8)
      setlargefig;
      title(['Layer cumulative ' propnm{iprop} ' ' gsecs.name{isa}])
    end
  end
end
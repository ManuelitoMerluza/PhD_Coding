% ctd_get.m: part of program ctd_treat
%change 01-05-98: do not compute dynamic height anymore
%because small gaps in the data create large spikes in the
%velocity. Dyn h is computed after interpolation/extrapolation
%of temp and salt (parameter p_gpan)
p_gpan=0;

disp('')
disp('  ctd_get.m ...')
disp('temperature data is converted to potential temperature')
disp('for interpolations. Reconverted to in situ in the end')
disp(' ')
disp(' missing data in the first 60db are copied all the way up')
disp(' missing data in the last 100db are copied all the way down')

if exist('wijffelsfile')
  disp('Using Wijffels format for stations')
  disp(wijffelstats)
  eval(['load ' wijffelsfile])
end
if exist('talleyfmtfile')
  disp('Talley CTD format')
  [cslat1,cslon1,cndep,Cpres,Ctemp,Csali,Coxyg]=...
    read_talley_ctd([ctddir talleyfmtfile]);
  fctdp=NaN;fctds=NaN;
  subplot(2,1,1);plot(cslon-cslon1(gstatctdfromorig));title('long. differences');
  subplot(2,1,2);plot(cslat-cslat1(gstatctdfromorig));title('lat. differences');
  ppause
end
if exist('fieuxfmtfile')
  disp('Fieux CTD format')
  [cslat1,cslon1,cmaxd1,Cpres,Ctemp,Csali,Coxyg, ctime, ...
      ccast, cdownup, cstat,cbotd1]=...
    read_fieux_ctd([ctddir fieuxfmtfile]);
  fctdp=NaN;fctds=NaN;
  if exist('hdrfile') %compare station position with header file from woce2obs
    subplot(2,1,1);plot(cslon-cslon1(gstatctdfromorig));title('long. differences');
    subplot(2,1,2);plot(cslat-cslat1(gstatctdfromorig));title('lat. differences');
    ppause
  else
    %take all the data from this ctd file
    cship=ones(size(gstatctdfromorig));
    cstnnbr=cstat(gstatctdfromorig);
    cslat=cslat1(gstatctdfromorig);
    oslat=cslat;
    cslon=cslon1(gstatctdfromorig);
    oslon=cslon;
    cbotp=sw_pres(cbotd1(gstatctdfromorig),cslat);
    ckt=zeros(size(gstatctdfromorig));
    cxdep=zeros(size(gstatctdfromorig));
    onobs=zeros(size(gstatctdfromorig));
    omaxd=cmaxd1(gstatctdfromorig);
  end
end

for is=1:cnstat
  statnbr=cstnnbr(is);
  disp(sprintf('----------GETTING STATION %i ---------',statnbr))

  if ~exist('talleyfmtfile') & ~exist('fieuxfmtfile') &...
       (~exist('wijffelsfile')| is > length(wijffelstats))
     %Look up the CTD files
    ipref=1;isuf=1;
    while 1
      fname=sprintf('%s%s%03i%s',ctddir,deblank(fctdp(ipref,:)),statnbr,...
	deblank(fctds(isuf,:)));
      fname2=sprintf('%s%s%03i%s.Z',ctddir,deblank(fctdp(ipref,:)),statnbr,...
	deblank(fctds(isuf,:)));
      if exist(fname)~=2 &  exist(fname2)~=2 
	if isuf<size(fctds,1)
	  isuf=isuf+1;
	elseif ipref<size(fctdp,1)
	  ipref=ipref+1;
	  isuf=1;
	else
	  disp(' ');disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')
	  disp([fname ' not found'])
	  disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');disp(' ')
	  menu([fname ' not found'],'Hit me to continue');
	  break
	end
      elseif exist(fname2)==2
	disp('uncompressing')
	unix(['uncompress ' fname2]);
	break
      else
	break
      end
    end %while 1
  end %~exist('talleyfmtfile')

  if exist('talleyfmtfile') | exist('fieuxfmtfile') | ...
    (exist('wijffelsfile')& is <= length(wijffelstats)) | exist(fname)==2
    if exist('orstom') & (orstom==1)
      [ctdstnnbr,ctdbotp,propnmctd,propunitsctd,...
	  pctd,tctd,sctd,o2ctd]=...
	ctd_readorstom(fname);
      if ctdstnnbr~=cstnnbr(is)
	ctdstnnbr,cstnnbr(is)
	error('station id do not correspond !')
      end
    elseif exist('p14s')&p14s
      [pctd,tctd,sctd,o2ctd]=ctd_readp14s(fname);
    elseif exist('i9s')&i9s
      [pctd,tctd,sctd,o2ctd]=ctd_readi9s(fname);
    elseif exist('kolterman')&kolterman
      [pctd,tctd,sctd,o2ctd]=ctd_readkolterman(fname,cstnnbr(is));
    elseif exist('talleyfmtfile')| exist('fieuxfmtfile') 
      pctd=Cpres{gstatctdfromorig(is)};
      tctd=Ctemp{gstatctdfromorig(is)};
      sctd=Csali{gstatctdfromorig(is)};
      o2ctd=Coxyg{gstatctdfromorig(is)};
    elseif exist('wijffelsfile') & is <= length(wijffelstats)
      pctd=gwdep{is};
      tctd=gwtemp{is};
      sctd=gwsali{is};
      o2ctd=gwoxyg{is};
      if exist('phos1')  %%% from find_t_relation_p4_fromstd.m
	phctd=phos1(find(~isnan(phos1(:,is))),is);
	sictd=sili1(find(~isnan(sili1(:,is))),is);
	nactd=nita1(find(~isnan(nita1(:,is))),is);
      end
    else
      [pctd,tctd,sctd,o2ctd]=whp_ctd(fname);
      ginan=find(isnan(pctd));
      pctd(ginan)=[];
      tctd(ginan)=[];
      sctd(ginan)=[];
      o2ctd(ginan)=[];
    end
    dp=pctd(length(pctd))-pctd(length(pctd)-1);
    if any(diff(pctd)<0)
      disp('CTD pressure not increasing')
      plot(pctd,'-+');zoomrb
      gir=input('Remove which points ?');
      pctd(gir)=[];
      tctd(gir)=[];
      sctd(gir)=[];
      o2ctd(gir)=[];
      if exist('phos1')
	phctd(gir)=[];
	sictd(gir)=[];
	nactd(gir)=[];
      end
    end
    %Copy the first 60 db data if necessary
    if pctd(1)~=0 & pctd(1)<=60
      pp=0:1:(pctd(1)-1);
      ss=sctd(1)*ones(length(pp),1); 
      tt=tctd(1)*ones(length(pp),1);
      tt=sw_temp(ss,tt,pp(:),pctd(1)); %fill with equal pot tempp
      tctd=[tt;tctd];
      pctd=[pp(:);pctd];
      sctd=[ss;sctd];
      o2ctd=[o2ctd(1)*ones(length(pp),1);o2ctd];
      if exist('phos1')
	phctd=[phctd(1)*ones(length(pp),1);phctd];
	sictd=[sictd(1)*ones(length(pp),1);sictd];
	nactd=[nactd(1)*ones(length(pp),1);nactd];
      end
    end
    %Copy the last 100 db data if necessary
    mp=max(pctd);
    if (cbotp(is)-mp)<100 & (cbotp(is)-mp)>0
      pp=mp+1:1:cbotp(is);
      npc=length(pctd);
      ss=sctd(npc)*ones(length(pp),1);
      tt=tctd(npc)*ones(length(pp),1);
      tt=sw_temp(ss,tt,pp(:),pctd(npc));
      tctd =[tctd; tt];
      pctd =[pctd; pp(:)];
      sctd =[sctd; ss];
      o2ctd=[o2ctd;o2ctd(npc)*ones(length(pp),1)];
      if exist('phos1')
	phctd=[phctd;phctd(npc)*ones(length(pp),1)];
	sictd=[sictd;sictd(npc)*ones(length(pp),1)];
	nactd=[nactd;nactd(npc)*ones(length(pp),1)];
      end
    end
    
    %Computes Dynamic Height
    if p_gpan
      gid=find(~isnan(sctd+tctd));
      gpan=sw_gpan(sctd(gid),tctd(gid),pctd(gid));
      %Geopot. anomaly in [m^3 kg^-1 Pa == m^2 s^-2 == J kg^-1]
      pgpan=pctd(gid);
    end
    
    %06/98 Replace in situ with potential as it was an extrapolation 
    % problem temperature will be reconverted in the end
    thetactd=sw_ptmp(sctd,tctd,pctd,0);
    clear tctd
    
    %Interpolates to standard depths by averaging around the
    %standard depth point
    %1-find the indices in the integration interval
    for iint=1:length(cpres)
      gi2int0=find(pctd>stdlim(iint) & pctd<=stdlim(iint+1));
      %
      %TEMPERATURE
      %
      gi2int=gi2int0(find(~isnan(thetactd(gi2int0))));
      if ~isempty(gi2int)
	if length(gi2int)>1
	  if (stdlim(iint+1)-pctd(max(gi2int)))<=dp
	    %simple average if the interval is correctly covered
	    dh=pctd(max(gi2int))-pctd(min(gi2int));
	    pottemp(iint,is)=trapz(pctd(gi2int),thetactd(gi2int))/dh;
	  else
	    if (stdlim(iint+1)-max(pctd(gi2int)))>100
	      disp(' pottemp extrapolation within integration interval')
	      disp(sprintf(' interval: %i %i',stdlim(iint),stdlim(iint+1)))
	      disp(sprintf('  last measurement at %i',max(pctd(gi2int))))
	    end
	    %extrapolate in the interval
	    pctd1=[max(pctd(gi2int)):dp:stdlim(iint+1)];
	    thetactd1=extrapole_ls(pctd(gi2int),thetactd(gi2int),pctd1);
	    pctd2=[pctd(gi2int);pctd1(:)];
	    thetactd2=[thetactd(gi2int);thetactd1];
	    dh=max(pctd2)-min(pctd2);
	    pottemp(iint,is)=trapz(pctd2,thetactd2)/dh;
	  end %if (stdlim(iint+1)
	end %if length(gi2int)>1
      end %if ~isempty(gi2int)
      %
      % SALINITY
      %
      gi2int=gi2int0(find(~isnan(sctd(gi2int0))));
      if ~isempty(gi2int)
	if length(gi2int)>1
	  if (stdlim(iint+1)-pctd(max(gi2int)))<=dp
	    %simple average if the interval is correctly covered
	    dh=pctd(max(gi2int))-pctd(min(gi2int));
	    sali(iint,is)=trapz(pctd(gi2int),sctd(gi2int))/dh;
	  else
	    %extrapolate in the interval
	    pctd1=[max(pctd(gi2int)):dp:stdlim(iint+1)];
	    sctd1=extrapole_ls(pctd(gi2int),sctd(gi2int),pctd1);
	    pctd2=[pctd(gi2int);pctd1(:)];
	    sctd2=[sctd(gi2int);sctd1];
	    dh=max(pctd2)-min(pctd2);
	    sali(iint,is)=trapz(pctd2,sctd2)/dh;
	  end %if (stdlim(iint+1)
	end %if length(gi2int)>1
      end %if ~isempty(gi2int)
      %
      % DYNAMIC HEIGHT
      %
      if p_gpan
	gi2int1=find(pgpan>stdlim(iint) & pgpan<stdlim(iint+1));
	gi2int=gi2int1(find(~isnan(gpan(gi2int1))));
	dh=pgpan(max(gi2int))-pgpan(min(gi2int));
	if ~isempty(gi2int)
	  if length(gi2int)>1
	    if (stdlim(iint+1)-pgpan(max(gi2int)))<=dp
	      %simple average if the interval is correctly covered
	      dh=pgpan(max(gi2int))-pgpan(min(gi2int));
	      dynh(iint,is)=trapz(pgpan(gi2int),gpan(gi2int))/dh/10;
	    else
	      %extrapolate in the interval
	      pgpan1=[max(pgpan(gi2int)):dp:stdlim(iint+1)];
	      gpan1=extrapole_ls(pgpan(gi2int),gpan(gi2int),pgpan1);
	      pgpan2=[pgpan(gi2int);pgpan1(:)];
	      gpan2=[gpan(gi2int);gpan1];
	      dh=max(pgpan2)-min(pgpan2);
	      dynh(iint,is)=trapz(pgpan2,gpan2)/dh/10;
	    end %if (stdlim(iint+1)
	  end %if length(gi2int)>1
	end %if ~isempty(gi2int)
      end %if p_gpan
      %
      %OXYGEN
      %
      gi2int=gi2int0(find(~isnan(o2ctd(gi2int0))));
      dh=pctd(max(gi2int))-pctd(min(gi2int));
      if ~isempty(gi2int)
	if length(gi2int)>1
	  if (stdlim(iint+1)-pctd(max(gi2int)))<=dp
	    %simple average if the interval is correctly covered
	    dh=pctd(max(gi2int))-pctd(min(gi2int));
	    oxyg(iint,is)=trapz(pctd(gi2int),o2ctd(gi2int))/dh;
	  else
	    if (stdlim(iint+1)-max(pctd(gi2int)))>100
	      disp(' oxyg extrapolation within integration interval')
	      disp(sprintf(' interval: %i %i',stdlim(iint),stdlim(iint+1)))
	      disp(sprintf('  last measurement at %i',max(pctd(gi2int))))
	    end
	    %extrapolate in the interval
	    pctd1=[max(pctd(gi2int)):dp:stdlim(iint+1)];
	    o2ctd1=extrapole_ls(pctd(gi2int),o2ctd(gi2int),pctd1);
	    pctd2=[pctd(gi2int);pctd1(:)];
	    o2ctd2=[o2ctd(gi2int);o2ctd1];
	    dh=max(pctd2)-min(pctd2);
	    oxyg(iint,is)=trapz(pctd2,o2ctd2)/dh;
	  end %if (stdlim(iint+1)
	end %if length(gi2int)>1
      end %if ~isempty(gi2int)
    
      % PHOSPHATE (for use with Wijffel's data)
      %
      if exist('phos1')
	gi2int=gi2int0(find(~isnan(phctd(gi2int0))));
	if ~isempty(gi2int)
	  if length(gi2int)>1
	    if (stdlim(iint+1)-pctd(max(gi2int)))<=dp
	      %simple average if the interval is correctly covered
	      dh=pctd(max(gi2int))-pctd(min(gi2int));
	      phos(iint,is)=trapz(pctd(gi2int),phctd(gi2int))/dh;
	    else
	      %extrapolate in the interval
	      pctd1=[max(pctd(gi2int)):dp:stdlim(iint+1)];
	      phctd1=extrapole_ls(pctd(gi2int),phctd(gi2int),pctd1);
	      pctd2=[pctd(gi2int);pctd1(:)];
	      phctd2=[phctd(gi2int);phctd1];
	      dh=max(pctd2)-min(pctd2);
	      phos(iint,is)=trapz(pctd2,phctd2)/dh;
	    end %if (stdlim(iint+1)
	  end %if length(gi2int)>1
	end %if ~isempty(gi2int)
      end %if exist('phos1')
      %
      % SILICA (for use with Wijffel's data)
      %
      if exist('sili1')
	gi2int=gi2int0(find(~isnan(sictd(gi2int0))));
	if ~isempty(gi2int)
	  if length(gi2int)>1
	    if (stdlim(iint+1)-pctd(max(gi2int)))<=dp
	      %simple average if the interval is correctly covered
	      dh=pctd(max(gi2int))-pctd(min(gi2int));
	      sili(iint,is)=trapz(pctd(gi2int),sictd(gi2int))/dh;
	    else
	      %extrapolate in the interval
	      pctd1=[max(pctd(gi2int)):dp:stdlim(iint+1)];
	      sictd1=extrapole_ls(pctd(gi2int),sictd(gi2int),pctd1);
	      pctd2=[pctd(gi2int);pctd1(:)];
	      sictd2=[sictd(gi2int);sictd1];
	      dh=max(pctd2)-min(pctd2);
	      sili(iint,is)=trapz(pctd2,sictd2)/dh;
	    end %if (stdlim(iint+1)
	  end %if length(gi2int)>1
	end %if ~isempty(gi2int)
      end %if exist('sili1')
      %
      % NITRATE (for use with Wijffel's data)
      % 
      if exist('nita1')
	gi2int=gi2int0(find(~isnan(nactd(gi2int0))));
	if ~isempty(gi2int)
	  if length(gi2int)>1
	    if (stdlim(iint+1)-pctd(max(gi2int)))<=dp
	      %simple average if the interval is correctly covered
	      dh=pctd(max(gi2int))-pctd(min(gi2int));
	      nita(iint,is)=trapz(pctd(gi2int),nactd(gi2int))/dh;
	    else
	      %extrapolate in the interval
	      pctd1=[max(pctd(gi2int)):dp:stdlim(iint+1)];
	      nactd1=extrapole_ls(pctd(gi2int),nactd(gi2int),pctd1);
	      pctd2=[pctd(gi2int);pctd1(:)];
	      nactd2=[nactd(gi2int);nactd1];
	      dh=max(pctd2)-min(pctd2);
	      nita(iint,is)=trapz(pctd2,nactd2)/dh;
	    end %if (stdlim(iint+1)
	  end %if length(gi2int)>1
	end %if ~isempty(gi2int)
      end %if exist('nita1')
    end %for iint
      % 
    
    if p_plot
      clf
      mp=1000*ceil(max(pctd/1000));
      subplot(1,4,1)
      plot(thetactd,-pctd,'b-',pottemp(:,is),-cpres,'ro-');set(gca,'ylim',[-mp 0])
      title(sprintf('CTD station %i (%i)',is,statnbr));xlabel('pottemp')
      subplot(1,4,2)
      plot(sctd,-pctd,'b-',sali(:,is),-cpres,'ro-');set(gca,'ylim',[-mp 0])
      xlabel('sali')
      subplot(1,4,3)
      plot(o2ctd,-pctd,'b-',oxyg(:,is),-cpres,'ro-');set(gca,'ylim',[-mp 0])
      xlabel('oxyg (umol/kg)')
      if p_gpan
	subplot(1,4,4)
	plot(gpan/10,-pgpan,'b-',dynh(:,is),-cpres,'ro-');set(gca,'ylim',[-mp 0])
	xlabel('dynh (m^2/s^2)')
      end
      %ppause
      drawnow
    end %if p_plot
    if is==-1 %for debug purposes
      stop
    end
    if p_gpan
      pgpan_=pgpan;
      gpan_=gpan;
    end
    thetactd_=thetactd;
    sctd_=sctd;
  end %exist(fname)==2

end %for is

%obs2_step4: part of obs2std

disp('')
disp('  obs2_step4.m ...')

disp('looking for anomalies over 10-station groups:')
disp('  data farther than 2 std. deviation of the 10 neighboring')
disp('  stations are displayed (Red losanges)')
disp('PLEASE ELIMINATE SUSPICIOUS POINTS')
disp('Enter proceed (y) if data removal is finished for the station')
disp('              (n) if not (to remove more points)')

for is=1:onstat
  if ~exist('istagged')
    disp(is)
  end
  for ipropstd=1:bnprop
    ipropobs=gip2treat(ipropstd);
    eval(['oprop=' opropnm{ipropobs} ';'])
    eval(['bprop=' bpropnm{ipropstd} ';'])
    if ~exist('istagged')|isempty(istagged)
      is1=max(1,is-5);
      is2=min(onstat,is1+10);
      gimiss=[];
      id0=min(find(stdd>200));
      for id=1:bmaxd(is)
	ii1=max(1,id-1);
	ii2=min(bmaxd(is),ii1+2);
	giss=is1:is2;
	giss(giss==is)=[];
	bpp=bprop([ii1:ii2],giss);
	gisgood=find(~isnan(bpp));
	pav=mean(bpp(gisgood));
	pst=std(bpp(gisgood));
	if stdd(id)>500 & stdd(id <2000)
	  npst=2; %twice std. dev near the thermocline
	else
	  npst=3.5; %3.5 otherwise
	end
	if abs(bprop(id,is)-pav)>npst*pst
	  gimiss=[gimiss,id];
	end
      end %id
    else
      gimiss=[];
    end
    
    if ~isempty(gimiss)| (exist('istagged')&istagged(is))
      s1='n';
      while s1~='y'
	clf;
	nb=is-1;
	nf=min(is+1,onstat);
	pl11=plot(bprop(gidb,is),-stdd(gidb),'b');hold on
	if nb ~= 0
	  plot(bprop(1:bmaxd(nb),nb),-stdd(1:bmaxd(nb)),'g-+')
	  plot(oprop(1:omaxd(nb),nb),-opres(1:omaxd(nb),nb),'go')
	end
	if nf ~= onstat
	  plot(bprop(1:bmaxd(nf),nf),-stdd(1:bmaxd(nf)),'m-+')
	  plot(oprop(1:omaxd(nf),nf),-opres(1:omaxd(nf),nf),'mo')
	end
	pl1=plot(bprop(1:bmaxd(is),is),-stdd(1:bmaxd(is)),'b-+','linewidth',2);
	pl2=plot(bprop(gimiss,is),-stdd(gimiss),'rd','markersize',14,...
	  'linewidth',1.5);
	plot(oprop(1:omaxd(is),is),-opres(1:omaxd(is),is),'bo',...
	  'linewidth',1.5,'markersize',10)
	title(sprintf(...
	  '%s o=obs +=std blue=st%i, g=st%i m=st%i',...
	  bpropnm{ipropstd},is,nb,nf))
	set(gca,'ytick',-stdd(bmaxd(is):-1:1));grid on
	ax=axis;
	plot(ax(1:2),[-stdd(bmaxd(is)) -stdd(bmaxd(is))],'c-.');
	obs2_remove
	if ~isempty(gimiss)
	  delete(pl1);
	  plot(bprop(1:bmaxd(is),is),-stdd(1:bmaxd(is)),'b-+','linewidth',2)
	  disp(sprintf('st %i %s',is,bpropnm{ipropstd}));
	  s1=input('proceed ? (y/n)','s');
	else
	  s1='y';
	end
      end %while s1~='y'
    end %if ~isempty(gimiss)
    eval([bpropnm{ipropstd} '=bprop;'])
  end %ipropobs
end %is

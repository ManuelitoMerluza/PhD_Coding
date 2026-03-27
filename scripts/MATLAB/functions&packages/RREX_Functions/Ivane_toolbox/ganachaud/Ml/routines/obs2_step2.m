%obs2_step2.m : part of obs2std

disp('  obs2_step2 ...')

disp('Automatic extrapolation to the bottom:')
disp(sprintf('%i db down to %idb, %idb below',...
  w1,wl1,w2,wl2))
disp('will prompt if more than 100db are extrapolated')
disp('missing data in the first 50 db std levels are set ')
disp(' equal to the first obs if <50db')

for is=1:onstat
  for ipropstd=1:bnprop
    ipropobs=gip2treat(ipropstd);
    eval(['oprop=' opropnm{ipropobs} ';'])
    eval(['bprop=' bpropnm{ipropstd} ';'])
    ilastobs=max(find(~isnan(bprop(:,is))));
    if ~isempty(ilastobs)
      gimiss=( (ilastobs+1):bmaxd(is) )';
    else
      gimiss=[];
    end
    giobs=find(~isnan(oprop(1:omaxd(is),is)));
    nlast1=length(giobs);
    nlast2=nlast1-1;
    %TEST IF THE TWO LAST OBSERVATIONS ARE NOT TOO CLOSE
    if nlast1>1 & ~isempty(gimiss)
      while (opres(giobs(nlast1),is)<500 & ...
	  diff(opres(giobs(nlast2:nlast1),is))>20) & ...
	  (opres(giobs(nlast1),is)>=500 & ...
	  diff(opres(giobs(nlast2:nlast1),is))>50)
	if nlast2~=1
	  nlast2=nlast2-1;
	else
	  disp('CLOSE DEPTHS FOR EXTRAPOLATION ...')
	  break;
	end
      end %while (opres  )
      %ELIMINATES THE POINTS IN gimiss THAT ARE ABOVE THE OBSERVATION nlast1
      %to avoid extrapolating upwards
      gimiss(find(stdd(gimiss)<opres(giobs(nlast1),is)))=[];
      %EXTRAPOLATES IF CLOSE ENOUGH TO THE BOTTOM
      if ((obotp(is)<wl1) & (obotp(is)-opres(giobs(nlast1),is))<w1 )...
	  | ( abs(obotp(is)-opres(giobs(nlast1),is)) <w2)
	slp=(oprop(giobs(nlast1),is)-oprop(giobs(nlast2),is))/...
	  (opres(giobs(nlast1),is)-opres(giobs(nlast2),is));
	bprop(gimiss,is)=oprop(giobs(nlast1),is)+...
	  slp*(stdd(gimiss)-opres(giobs(nlast1),is));
	if ~strcmp(killblank(bpropnm{ipropstd}),'temp')&any(bprop(gimiss,is)<0)
	  disp('Negative value found and set to zero !')
	  giz=find(bprop(gimiss,is)<0);
	  bprop(gimiss(giz),is)=0;
	end
	%PROMPTIF MORE THAN 100 DB EXTRAPOLATION
	if abs(stdd(max(gimiss))-stdd(min(gimiss))) > 100
	  f1;clf;
	  set(gcf,'defaultaxesfontsize',6)
	  plot(oprop(1:omaxd(is),is),-opres(1:omaxd(is),is),'bo');hold on
	  plot(bprop(1:bmaxd(is),is),-stdd(1:bmaxd(is)),'b+-')
	  plot(bprop(gimiss,is),-stdd(gimiss),'k*');
	  if is>1
	    plot(oprop(1:omaxd(is-1),is-1),-opres(1:omaxd(is-1),is-1),'go')
	  end
	  if is<onstat
	    plot(oprop(1:omaxd(is+1),is+1),-opres(1:omaxd(is+1),is+1),'mo')
	  end
	  hold off;
	  %set(gca,'ytick',-stdd(bmaxd(is):-1:1))
	  title(sprintf(...
	    '%s station %i (+ = std, o = obs) green=prev., mage=next',...
	    bpropnm{ipropstd},is))
	  s=input(sprintf('st %i %s ACCEPT ? (y/n)',is,bpropnm{ipropstd}),'s');
	  if ~isempty(s) &(lower(s(1))=='n')
	    bprop(gimiss,is)=NaN;
	  end
	end %if abs(stdd(max(gimiss)-))
      end % 	if ((obotp(is  )))
    end %if nlast1>1
    %
    % COPY THE FIRST VALUE IN THE MIXED-LAYER IF NECESSARY
    %
    gimiss=isnan(bprop(:,is));
    giobs1=min(find(~isnan(oprop(1:omaxd(is),is))));
    gisurf=find(stdd(gimiss)<=50);
    if ~isempty(gisurf) & opres(giobs1,is)<=50
      %disp(sprintf(...
      %	'Copying the first obs. above 50db to the surface St%i %s',...
      %  is,bpropnm{ipropstd}))
      bprop(gisurf,is)=oprop(giobs1,is);
    end
    eval([bpropnm{ipropstd} '=bprop;'])
  end %ipropobs
end %is
close
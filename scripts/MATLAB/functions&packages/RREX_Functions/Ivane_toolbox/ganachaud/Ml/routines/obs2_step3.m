%obs2_step3.m: part of obs2std code
%Parameters:
  %p_isopyc: allows option of horizontal in/extrapolation along isopycnals.
  %hdrctd: header file from ctd2std data.  used only if p_isopyc is active.


disp('  obs2_step3.m ...')
if ~exist('obs2std_rec')
  obs2std_rec=cell(onstat,bnprop); % 7/1/99 Records Gimiss Values in Cell Variable
end

%Read CTD data for isopycnal inter/extrapolation
if ~exist('p_isopyc')
  p_isopyc=0;
end
if p_isopyc==1
  eval(['load ' hdrctd])
  temp=rhydro([OPdir cstatfiles{1}],...
   cprecision{1},length(cpres),cnstat,cmaxd);
  sali=rhydro([OPdir cstatfiles{2}],...
   cprecision{2},length(cpres),cnstat,cmaxd);
  isopyc=sw_dens(sali,temp,cpres);
  if any(diff(isopyc)<=0)
    error('WARNING, SOME VALUES OF DENSITY ARE NOT MONOTONIC')
  end
  clear temp
  clear sali
end  
for is=1:onstat
  for ipropstd=1:bnprop
    ipropobs=gip2treat(ipropstd);
    eval(['oprop=' opropnm{ipropobs} ';'])
    eval(['bprop=' bpropnm{ipropstd} ';'])
    gidb=1:bmaxd(is);
    gimiss=find(isnan(bprop(gidb,is)));
    nb=max(1,is-1);
    while nb>1
      if all(isnan(bprop(1:bmaxd(is),nb)))
	nb=nb-1;
      else
	break
      end
    end
    nf=min(onstat,is+1);
    while nf<onstat
      if all(isnan(bprop(1:bmaxd(is),nf)))
	nf=nf+1;
      else
	break
      end
    end   
    tried_autoh=0;
    tried_autov=0;
    while ~isempty(gimiss)
      %Selects the first group of consecutive missing data
      if length(gimiss)~=bmaxd(is)
	if length(gimiss)>1
	  giz=find(diff(gimiss)~=1);
	  if ~isempty(giz)
	    gimiss=gimiss(1:min(giz));
	  end
	end
      end
      s1='z';
      while s1~='a'
	%automatic horizontal interpolation within 200db from the surface
	%automatic horizontal extrapolation within 100db from the bottom
	if (~tried_autoh & obotp(is)>600 & stdd(max(gimiss))<=200 )
	  s1='h'; 
	  f_auto=1;
	  disp('Automatic horizontal interpolation in the first 200db')
	  tried_autoh=1;
	elseif (~tried_autov & obotp(is)>600 & ...
	    abs(obotp(is)-stdd(min(gimiss)))<100 )
	  s1='v';
	  f_auto=1;
	  disp('Automatic vertical   extrapolation in the last 100db')
	  tried_autov=1;
	else
	  f_auto=0;
	  clf;
	  plot(bprop(gidb,is),-stdd(gidb),'b');hold on
	  if nb ~= 0
	    plot(bprop(1:bmaxd(nb),nb),-stdd(1:bmaxd(nb)),'g-+')
	    plot(oprop(1:omaxd(nb),nb),-opres(1:omaxd(nb),nb),'go')
	  end
	  if nf ~= onstat
	    plot(bprop(1:bmaxd(nf),nf),-stdd(1:bmaxd(nf)),'m-+')
	    plot(oprop(1:omaxd(nf),nf),-opres(1:omaxd(nf),nf),'mo')
	  end
	  plot(bprop(gidb,is),-stdd(gidb),'b-+','linewidth',2)
	  plot(oprop(1:omaxd(is),is),-opres(1:omaxd(is),is),'bo')
	  title(sprintf(...
	    '%s o=obs +=std blue=st%i, g=st%i m=st%i',...
	    bpropnm{ipropstd},is,nb,nf))
	  set(gca,'ytick',-stdd(bmaxd(is):-1:1));grid on
	  ax=axis;
	  plot(ax(1:2),[-stdd(bmaxd(is)) -stdd(bmaxd(is))],'c-.')
	  %ch=get(gca,'chil');
	  %set(ch,'color','k');
	  zoom
	  disp(sprintf('st %i %s',is,bpropnm{ipropstd}));
	  diary off
	  disp('INPUT FILLING METHOD')
	  disp('a = accept')
	  disp('v = vertical interpolation')
	  disp('k = vertical Aitken-Lagrange')
	  disp('h = horizontal in/extrapolation along isobars')
	  disp('i = isopycnal horizontal in/extrapolation')
	  disp('n = copy Next station')
	  disp('p = copy Previous station')
	  disp('c = copy to the top/bottom')
	  disp('f = show next station (fwd) (F to decrement)')
	  disp('b = show previous station (bwd) (B to increment)')
	  disp('r = remove some data')
	  diary on
	end %stdd(gimiss(max(gimiss)))<=200
	cont=1;
	while cont
	  if ~f_auto
	    s1=input('m = manual filling ','s');
	  end
	  cont=0;
	  switch s1
	    case 'c'
	      if gimiss(1)~=1
		bprop(gimiss,is)=bprop(gimiss(1)-1,is);
	      elseif max(gimiss)<bmaxd(is)
		bprop(gimiss,is)=bprop(max(gimiss)+1,is);
	      end
	    case 'v'
	      obs2_vert
	    case 'h'
	      obs2_horiz
	    case 'i'
	      obs2_isopyc
	    case 'k'
	      obs2_al
	    case 'n'
	      bprop(gimiss,is)=bprop(gimiss,nf);
	    case 'p'
	      bprop(gimiss,is)=bprop(gimiss,nb);
	    case 'f'
	      nf=min(onstat,nf+1);
	    case 'F'
	      nf=max(1,nf-1);
	    case 'b'
	      nb=max(1,nb-1);
	    case 'B'
	      nb=min(onstat,nb+1);
	    case 'm'
	      disp('MANUAL INPUT FOR THE FOLLOWING DEPTHS:')
	      disp(stdd(gimiss))
	      while 1
		zval=input('ENTER VALUES: ');
		if length(zval)==length(gimiss)
		  if size(zval,1)==1
		    zval=zval';
		  end
		  bprop(gimiss,is)=zval;
		  break
		else
		  disp('NOT THE RIGHT NUMBER OF VALUES !')
		end
	      end
	    case 'r'
	      obs2_remove
	    case 'a'
	      if any(bprop(:,is)<0)
		disp('Negative values detected !')
		s5=input('Accept/ No / set to Zero (a/n/z)','s');
		if s5=='a'
		elseif s5=='z'
		  gg=find(bprop(:,is)<0);
		  bprop(gg,is)=0;
		else
		  gg=find(bprop(:,is)<0);
		  bprop(gg,is)=NaN;
		end
	      end
	      obs2std_rec{is,ipropstd}=[obs2std_rec{is,ipropstd}(:);gimiss];
	      if ~isempty(obs2std_rec{is,ipropstd})
		obs2std_rec{is,ipropstd}=sort(obs2std_rec{is,ipropstd});
		df=diff(obs2std_rec{is,ipropstd});
		obs2std_rec{is,ipropstd}(find(df==0))=[];
	      end
	    otherwise
	      cont=1;
	  end %switch s1
	end  %while cont
	if f_auto
	  s1='a'; 
	end
      end %while s1~='a'
      gimiss=find(isnan(bprop(gidb,is)));
    end %while ~isempty(gimiss)
    eval([bpropnm{ipropstd} '=bprop;'])
  end %ipropobs
end %is

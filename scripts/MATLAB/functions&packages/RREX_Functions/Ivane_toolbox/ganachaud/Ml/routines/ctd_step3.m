%ctd_step3.m: part of ctdstd code

disp('  ctd_step3.m ...')

% 6/18/99 Parameters and Commands for Oxygen Bottle Data
if ~exist('p_ooxyg')    %Parameter from ctd2std_input
  p_ooxyg=0;
end
%       Read Oxygen Bottle Data from ostatfiles
if exist('IPdir')       
  if IPdir=='Obsdata/'   %from ctd2std_input 
    ompres=size(opres,1);
    ooxyg = rhydro([IPdir ostatfiles{3}], oprecision{3}, ...
      ompres, onstat, omaxd);
  end
end
if ~exist('ctd2std_rec')
  ctd2std_rec=cell(cnstat,length(cpropnm)); % 6/29/99 Records Gimiss Values in Cell Variable
end
if all(all(isnan(oxyg))) & length(cpropnm)==4
  disp('No Oxygen data !')
  ppause
  cpropnm=cpropnm([1:2,4]);
  cpropunits=cpropunits([1:2,4]);
end
cnprop=length(cpropnm);
for is=1:cnstat
  cmaxd(is)=max(find(cpres<=cbotp(is)));
end
s1='w'; %dummy s1
for is=1:cnstat
  p_done=0;
  for iprop=1:cnprop
    if iprop==1
      prop=pottemp;
    else
      eval(['prop=' cpropnm{iprop} ';'])
    end
    if cpropnm{iprop}=='oxyg'
      if any(prop(:,is)>1000)
	prop(find(prop(:,is)>1000),is)=NaN;
      end
    end
    gidb=1:cmaxd(is);
    gimiss=find(isnan(prop(gidb,is)));
    nb=max(1,is-1);
    while nb>=1
      if all(isnan(prop(1:cmaxd(is),nb)))
	nb=nb-1;
      else
	break
      end
    end
    nf=min(cnstat,is+1);
    while nf<cnstat
      if all(isnan(prop(1:cmaxd(is),nf)))
	nf=nf+1;
      else
	break
      end
    end   
    s2='w'; %ooxyg dummy s
    while ~isempty(gimiss) | (p_ooxyg==1 & cpropnm{iprop}=='oxyg' & s2~='a')
      %Automatic vertical extrapolation within 100db of the last 
      %standart depth or within 50db of the surface
      %Selects the first group of consecutive missing data
      if ~isempty(gimiss) & (length(gimiss)~=cmaxd(is))
	if length(gimiss)>1
	  giz=find(diff(gimiss)~=1);
	  if ~isempty(giz)
	    gimiss=gimiss(1:min(giz));
	  end
	end
      end
      if ~isempty(gimiss) & (all(cpres(cmaxd(is))-(cpres(gimiss))<=100)) & ...
	  (cpres(cmaxd(is))>500)
	if s1~='s'
	  s1='v';
	  aut_flag='y';
	  disp('Automatic vertical extrapolation in the 100db near-bottom')
	else
	  s1='z';
	  aut_flag='n';
	end
      elseif ~isempty(gimiss) & (all(cpres(gimiss)<=50)&(iprop~=cnprop)) ...
	  & (~all(isnan(prop(:,is))))
	if s1~='s'
	  s1='v';
	  aut_flag='y';
	  disp('Automatic vertical extrapolation in the 50db near-surface')
	else
	  s1='z';
	  aut_flag='n';
	end
      elseif ~isempty(gimiss) & ((iprop==cnprop) & (max(gimiss)==cmaxd(is)))
	%Automatic dynamic height recomputation from T and S to the bottom
	if s1~='s'
	  s1='v';
	  aut_flag='y';
	else
	  s1='z';
	  aut_flag='n';
	end
      else
	s1='z';
	aut_flag='n';
      end %if all(cpres(cmaxd(is))-(cpres(gimiss))<=100)
      if 0 & ((~all((cpres(cmaxd(is))-(cpres(gimiss)))<=100) | ...
       ~(cpres(cmaxd(is))>500)) & (~all(cpres(gimiss)<=50) | ...
       iprop==cnprop) & (iprop~=cnprop | max(gimiss)~=cmaxd(is)) | ...
       (p_ooxyg==1 & cpropnm{iprop}=='oxyg'))   
	f1;clf
	pl3=plot(prop(:,max(1,is-1)),-cpres,'g-+',...
	  prop(:,min(cnstat,is+1)),-cpres,'m-+');hold on
	pl2=plot(prop(:,is),-cpres,'b+-','linewidth',2);
	set(gca,'ylim',[-cbotp(is) 0],'ytick',-cpres(cmaxd(is):-1:1));
	xx=get(gca,'xlim');
	plot(xx,[-cpres(cmaxd(is)) -cpres(cmaxd(is))],'c-.')
	title(sprintf(...
	  'blue=st%i (%i), g=st%i m=st%i',...
	  is,cstnnbr(is),max(1,is-1),min(cnstat,is+1)));grid on
	if ~isempty(gimiss) & iprop~=3
          xlabel(['MISSING ' cpropnm{iprop} ' DATA']);
        elseif ~isempty(gimiss)
          xlabel(['MISSING ' cpropnm{iprop}...
           ' DATA, SHOWING OXYGEN BOTTLE DATA']); 
        else 
          xlabel(['SHOWING OXYGEN BOTTLE DATA'])
        end
        ylabel('lower bound=bottom');zoom on;ax=gca;
	%axes(ax);
      end
      while s1~='a'
	if aut_flag ~='y' | (p_ooxyg==1 & cpropnm{iprop}=='oxyg')
	  %Remove first dynamic height point if data gap
	  if (iprop==cnprop) & (min(gimiss)>1) & (max(gimiss)< ...
	   cmaxd(is)) & ~p_done
	    prop(max(gimiss)+1,is)=NaN;
	    gimiss=[gimiss;max(gimiss)+1];
	    p_done=1;
	  end
	  clf;
	  plot(prop(gidb,is),-cpres(gidb),'b');hold on
	  if nb >=1
	    plot(prop(1:cmaxd(nb),nb),-cpres(1:cmaxd(nb)),'g-+')
	  end
	  if nf <= cnstat
	    plot(prop(1:cmaxd(nf),nf),-cpres(1:cmaxd(nf)),'m-+')
	  end
	  plot(prop(gidb,is),-cpres(gidb),'b-+','linewidth',2)
          if (cpropnm{iprop}=='oxyg') & (p_ooxyg==1)
            disp('PLOTTING OXYGEN BOTTLE DATA')
            if cstnnbr(is)~=ostnnbr(gstatctd(is))
	      error('MISMATCH OF BOTTLE/CTD STATION NUMBERS')
	    end
            plot(ooxyg(:,gstatctd(is)),-opres(:,gstatctd(is)),'bo',...
	      'markersize',8)
          end
	  title(sprintf(...
	    '%s o=obs +=std blue=st%i, g=st%i m=st%i',...
	    cpropnm{iprop},is,nb,nf))
	  %title(sprintf(...
	    %'%s o=obs +=std blue=st%i', ...
	    %cpropnm{iprop},is))
	  set(gca,'ytick',-cpres(cmaxd(is):-1:1));grid on
	  ax=axis;
	  plot(ax(1:2),[-cpres(cmaxd(is)) -cpres(cmaxd(is))],'c-.')
	  %ch=get(gca,'chil');
	  %set(ch,'color','k');
	  zoom on
	  disp(sprintf('st %i %s',is,cpropnm{iprop}));
          if ~isempty(gimiss)
	    disp(sprintf('missing between %i and %i',...
	     cpres(min(gimiss)),cpres(max(gimiss))))
          end
	  disp('INPUT FILLING METHOD')
	  disp('a = accept')
	  disp('v = vertical interpolation / dyn. h computation')
	  disp('k = vertical Aitken-Lagrange')
	  disp('h = horizontal in/extrapolation')
	  disp('n = copy Next station')
	  disp('p = copy Previous station')
	  disp('c = copy to the top/bottom')
	  disp('f = show next station (fwd) (F to decrement)')
	  disp('b = show previous station (bwd) (B to increment)')
	  disp('r = remove some data')
	  disp('g = interpolation using graphical input data')
	end % if aut_flag~='y'
	cont=1;
	while cont
	  if aut_flag~='y'
	    s1=input('m = manual filling ','s');
	  end
	  cont=0;
	  if isempty(gimiss) & (s1=='v' | s1=='k' | s1=='h' | s1=='n' ...
	   | s1=='p' | s1=='c' | s1=='m')
	    disp('NO MISSING DATA, CANNOT EXECUTE COMMAND')
	    cont=1;
	  elseif isempty(gimiss) & (s1~='a' & s1~='f' & s1~='F' ...
	   & s1~='b' & s1~='B' & s1~='r' & s1~='g')
	    disp('INVALID ENTRY')
	    cont=1;
	  else
	    switch s1
	    case 'c'
	      if iprop~=cnprop 
		if gimiss(1)~=1
		  prop(gimiss,is)=prop(gimiss(1)-1,is);
		elseif max(gimiss)<cmaxd(is)
		  prop(gimiss,is)=prop(max(gimiss)+1,is);
		end
	      end
	    case 'v'
	      p_interp=0;
	      if min(gimiss)>1 & max(gimiss)< cmaxd(is)
		%interpolation
		id1=gimiss(1)-1;
		id2=max(gimiss)+1;
		p_interp=1;
	      elseif min(gimiss-2)>0
		%extrapolation from above
		id1=gimiss(1)-1;
		id2=gimiss(1)-2;
	      elseif (max(gimiss)+2)<=cmaxd(is)
		%extrapolation from below
		id1=max(gimiss)+1;
		id2=max(gimiss)+2;
	      elseif all(isnan(prop(:,is)))
		if iprop==cnprop
		  id1=1;
		  prop(id1,is)=0;
		end
	      else
		error('case unknown to the program !')
	      end
	      if ~p_interp & (iprop==cnprop & max(gimiss)==cmaxd(is))
		disp('recomputing dynamic height near the bottom')
		gid=id1:max(gimiss);
		tinsitu=sw_temp(sali(gid,is),pottemp(gid,is),cpres(gid),0);
		bgpan=sw_gpan(sali(gid,is),tinsitu,cpres(gid));
		prop(gid,is)=prop(id1,is)+...
		  (bgpan-bgpan(1))/10;
		aut_flag='n';
		break
	      else
		%Fill if not dynh
		if ~(isnan(prop(id2,is))&aut_flag=='y')
		  prop(gimiss,is)=prop(id1,is)+...
		    (prop(id1,is)-prop(id2,is))/...
		    (cpres(id1)-cpres(id2))*...
		    (cpres(gimiss)-cpres(id1));
		else %case where auto extrapolation fails
		  s1='s'; %skip auto extrapolation
		  aut_flag='n';
		end
		break
	      end %if (iprop==cnprop) 
	    case 'h'
	      d1=sw_dist(oslat([nb,is]),oslon([nb,is]),'km');
	      d2=sw_dist(oslat([nf,is]),oslon([nf,is]),'km');
	      if (iprop~=cnprop)|(length(gimiss)==cmaxd(is))
		prop(gimiss,is)=prop(gimiss,nb)+...
		  d1*(prop(gimiss,nf)-prop(gimiss,nb))/(d1+d2);
		%prop(gimiss,is)=0.5*(prop(gimiss,nb)+prop(gimiss,nf));
		break
	      else
		if max(gimiss)==cmaxd(is)
		  if min(gimiss)==1
		    prop(gimiss,is)=prop(gimiss,nb)+...
		      d1*(prop(gimiss,nf)-prop(gimiss,nb))/(d1+d2);
		  else
		    id1=gimiss(1)-1;
		    prop(gimiss,is)=prop(id1,is)+...
		      (prop(gimiss,nb)-prop(id1,nb))+...
		      d1*( (prop(gimiss,nf)-prop(id1,nf)) -...
		      (prop(gimiss,nb)-prop(id1,nb)) )...
		      /(d1+d2);
		  end
		  break
		else
		  disp('CANNOT DO THAT WITH DYN HEIGHT')
		end
	      end
	    case 'k'
	      disp('Aitken-Lagrange not available with CTD ...')
	      disp('!')
	    case 'n'
	      if (iprop~=cnprop)|(length(gimiss)==cmaxd(is))
		prop(gimiss,is)=prop(gimiss,nf);
		break
	      else %iprop=dyn.h
		if max(gimiss)==cmaxd(is)
		  if min(gimiss)==1
		    prop(gimiss,is)=prop(gimiss,nf);
		  else
		    prop(gimiss,is)=prop(gimiss(1)-1,is)+...
		      prop(gimiss,nf)-prop(gimiss(1)-1,nf);
		  end
		  break
		else
		  disp('CANNOT DO THAT WITH DYN HEIGHT')
		end
	      end
	    case 'p'
	      if (iprop~=cnprop)|(length(gimiss)==cmaxd(is))
		prop(gimiss,is)=prop(gimiss,nb);
		break
	      else
		if max(gimiss)==cmaxd(is)
		  if min(gimiss)==1
		    prop(gimiss,is)=prop(gimiss,nb);
		  else
		    prop(gimiss,is)=prop(gimiss(1)-1,is)+...
		      prop(gimiss,nb)-prop(gimiss(1)-1,nb);
		  end
		  break
		else
		  disp('CANNOT DO THAT WITH DYN HEIGHT')
		end
	      end
	    case 'f'
	      nf=min(cnstat,nf+1);
	    case 'F'
	      nf=max(1,nf-1);
	    case 'b'
	      nb=max(1,nb-1);
	    case 'B'
	      nb=min(cnstat,nb+1);
	    case 'm'
	      disp('MANUAL INPUT FOR THE FOLLOWING DEPTHS:')
	      disp(cpres(gimiss))
	      while 1
		zval=input('ENTER VALUES: ');
		if length(zval)==length(gimiss)
		  if size(zval,1)==1
		    zval=zval';
		  end
		  prop(gimiss,is)=zval;
		  break
		else
		  disp('NOT THE RIGHT NUMBER OF VALUES !')
		end
	      end
	    case 'r'
	      ctd_remove
	    case 'g'
	      disp('Click on input points in graph window')
	      disp('Hit RETURN after last point')
	      disp('KEEPING CURSOR INSIDE GRAPH WINDOW')
	      [gix,giy]=ginput;
	      %testing for identical pressure coordinates
	      ipc=0;
	      for ii1=1:length(giy)
		if length(find(abs(giy-giy(ii1))<10))>1
		  disp('ALL POINTS MUST BE > 10db apart')
		  disp('Please Hit "g" to Try Again')
		  ipc=1;
		  break
		end 
	      end
	      if ipc==1
		break
	      end
	      giy=-giy;
	      [giy,igiy]=sort(giy);
	      gix=gix(igiy);
	      if isempty(gimiss)
		disp('Removing data Between Endpoints')
		gimiss=find((cpres>min(giy)-50) & (cpres<max(giy)+50));
		prop(gimiss,is)=NaN;
	      elseif (min(giy)<(cpres(min(gimiss))-40)) | ...
	        (max(giy)>(cpres(max(gimiss))+40))
	        disp('Points must be within range of missing data')
		disp('Please hit "g" and Try Again')
		break
	      end
	      if (min(gimiss)>1) & (max(gimiss)<cmaxd(is))
		gix=[prop(min(gimiss)-1,is);gix;prop(max(gimiss)+1,is)];
		giy=[cpres(min(gimiss)-1);giy;cpres(max(gimiss)+1)];
	      elseif min(gimiss)>1
		gix=[prop(min(gimiss)-1,is);gix];
		giy=[cpres(min(gimiss)-1);giy];
	      elseif max(gimiss)<cmaxd(is)
		gix=[gix;prop(max(gimiss)+1,is)];
		giy=[giy;cpres(max(gimiss)+1)];
	      else 
		disp('NO BOUNDARIES, CANNOT EXECUTE COMMAND')
		break
	      end
	      prop(gimiss,is)=interp1(giy,gix,cpres(gimiss));
	      break
	    case 'a'
              if isempty(gimiss) & p_ooxyg==1 & cpropnm{iprop}=='oxyg'
                s2='a';
              end
	      if iprop~=1 & any(prop(:,is)<0)
		disp('Negative values detected !')
		s5=input('Accept/ No / set to Zero (a/n/z)','s');
		if s5=='a'
		elseif s5=='z'
		  gg=find(prop(:,is)<0);
		  prop(gg,is)=0;
		else
		  gg=find(prop(:,is)<0);
		  prop(gg,is)=NaN;
		end
	      end
	    otherwise
	      disp('INVALID ENTRY')
	      cont=1;
	    end %switch s1
	  end %if isempty(gimiss) & (s1=='v' | s1=='k' ...)
	end  %while cont
	if aut_flag=='y'&s1~='s'
	  s1='a'; %to stop the loop
	end
      end %while s1~='a'
      ctd2std_rec{is,iprop}=[ctd2std_rec{is,iprop}(:);gimiss];
      if ~isempty(ctd2std_rec{is,iprop})
	ctd2std_rec{is,iprop}=sort(ctd2std_rec{is,iprop});
	df=diff(ctd2std_rec{is,iprop});
	ctd2std_rec{is,iprop}(find(df==0))=[];
      end
      gimiss=find(isnan(prop(gidb,is)));
    end %while ~isempty(gimiss) | (p_ooxyg==1 & cpropnm{iprop}=='oxyg' ... 
      %% & s2~='a')
    if iprop==1
      pottemp=prop;
    else
      eval([cpropnm{iprop} '=prop;'])
    end
  end %ipropobs
end %is
cmaxd=cmaxd(:);
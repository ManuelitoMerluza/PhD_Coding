%rwb_step2: part of w2o_readwocebot
disp('    rwb_step2.m ...')

  %1)
  disp('Set the pressure the same if the depth interval is less than 10 db')
  for is=1:onstat
    gieq=find(abs(diff(opres(:,is)))<10);
    for it=1:length(gieq);
      opres(gieq(it)+1,is)=opres(gieq(it),is);
    end
  end 
  %2)eliminate repeat pressures

  gis2see=find(any(abs(diff(opres))==0));
  for is=gis2see
    gid0=1:onobs(is);
    gid=gid0;
    gide=find(abs(diff(opres(:,is)))==0);
    if gide %REPLACE THE DATA WITH THE SELECTED DATA
      if p_debug
	disp(sprintf('SAME DEPTH STATION %i',is))
	disp(sprintf('i ct sample  \tpres\tctdt\tsali\toxyg\tphos\tsili\tnita'))
	for id=gid
	  disp(sprintf(...
	    '%02i %i %05i\t%4.0f\t%4.1f\t%5.2f\t%3.0f\t%4.1f\t%5.2f\t%3.2f',...
	    id,castno(id,is),sampno(id,is),opres(id,is),otemp(id,is),osali(id,is),...
	    ooxyg(id,is),ophos(id,is),osili(id,is),onita(id,is)))
	end %id
      end %if p_debug
      gid(gide)=[];
      gidn=1:length(gid);
      gnan=NaN*ones(nlev-length(gid),1);
      for iprop=1:nvar
	eval(['oprop=' opropnm{iprop} '(:,is);'])
	%RETAINS LAST OBSERVATION
	gidset=[gide(diff(gide)~=1); max(gide)]+1;
	%GRABS ALL AVAILABLE OBSERVATIONS FOR THIS DEPTH
	for id1=1:length(gidset);
	  id=gidset(id1);
	  %FIND AND COPY AVAILABLE OBSERVATIONS AT THIS DEPTH
	  if isnan(oprop(id))
	    gisameP=find(abs(opres(:,is)-opres(id,is))==0);
	    id2copy=gisameP(min(find(~isnan(oprop(gisameP)))));
	    if ~isempty(id2copy)
	      oprop(id)=oprop(id2copy);
	      if p_debug
		disp(sprintf(...
		  'STATION %i (%i), RETAINED SAMPLE %i, GRABBED %s FROM %i',...
		  is,ostnnbr(is),sampno(id,is),opropnm{iprop},sampno(id2copy,is)))
	      end
	    end
	  end
	end %isnan
	oprop=[oprop(gid);gnan];
	eval([opropnm{iprop} '(:,is)=oprop;'])
      end %iprop
      opres(:,is)=[opres(gid,is);gnan];
      castno(:,is)=[castno(gid,is);gnan];
      sampno(:,is)=[sampno(gid,is);gnan];
      btlnbr(:,is)=[btlnbr(gid,is);gnan];
      Gidselectedpres{is}=gid0(gid);
      gid=gidn;
      onobs(is)=length(gid);
      if p_debug
	disp(sprintf('i ct sample  \tpres\tctdt\tsali\toxyg\tphos\tsili\tnita'))
	for id=gid
	  disp(sprintf(...
	    '%02i %i %5i\t%4.0f\t%4.1f\t%5.2f\t%3.0f\t%4.1f\t%5.2f\t%3.2f',...
	    id,castno(id,is),sampno(id,is),opres(id,is),otemp(id,is),osali(id,is),...
	    ooxyg(id,is),ophos(id,is),osili(id,is),onita(id,is)))
	end %id
	ppause
      end %if p_debug
    end %gide
  end %is

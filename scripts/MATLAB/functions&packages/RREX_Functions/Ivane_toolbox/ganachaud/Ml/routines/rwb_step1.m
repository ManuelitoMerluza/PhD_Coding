%rwb_step1: part of w2o_read_wocebot.m

%     2b) asks how to order the depths if more than one cast at a station
%         -i.e.,rosette dropped twice-. Just need to reorder if necessary at this
%         point. 
%         The purpose is to order the bottles to have monotically varying
%         depths, increasing or decreasing. Outliers that occur in the
%         first 1 or two 2nd cast bottles will be removed afterwards.
%         Repeat pressures will be removed too
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('    rwb_step1.m ...')
  zzz=diff(castno);
  zzz(isnan(zzz))=0;
  gis2see=find(any(zzz));
  %CASTS THAT HAVE TWO ROSETTES MUCH BE CHECKED FOR BAD DATA
  for is=gis2see
    gid0=1:onobs(is);
    gid=gid0;
    disp(sprintf('MORE THAN ONE CASTS AT STATION %i (%i)',is,ostnnbr(is)));
    if is<=length(Gidselectedcast)
      disp('STATION ALREADY TREATED')
      if ~isempty(Gidselectedcast{is})
	gid=Gidselectedcast{is};
	gidn=1:length(gid);
	gnan=NaN*ones(nlev-length(gid),1);
	opres(:,is)=[opres(gid,is);gnan];
	castno(:,is)=[castno(gid,is);gnan];
	sampno(:,is)=[sampno(gid,is);gnan];
	btlnbr(:,is)=[btlnbr(gid,is);gnan];
	for iprop=1:nvar
	  eval([propnm(iprop,:) '(:,is)=['propnm(iprop,:) '(gid,is);gnan];'])
	end %iprop
	gid=gidn;
	onobs(is)=length(gid);
      end
    else
      while 1
	disp(sprintf('id cast\tpres\tctdt\tsali\toxyg\tphos\tsili\tnita\tniti'))
	for id=gid
	  if exist('oniti')
	    disp(sprintf(...
	      '%02i %i\t%4.0f\t%4.1f\t%5.2f\t%3.0f\t%4.1f\t%5.2f\t%3.2f\t%1.3f',...
	      id,castno(id,is),opres(id,is),otemp(id,is),osali(id,is),...
	      ooxyg(id,is),ophos(id,is),osili(id,is),onita(id,is),oniti(id,is)))
	  else
	    disp(sprintf(...
	      '%02i %i\t%4.0f\t%4.1f\t%5.2f\t%3.0f\t%4.1f\t%5.2f\t%3.2f',...
	      id,castno(id,is),opres(id,is),otemp(id,is),osali(id,is),...
	      ooxyg(id,is),ophos(id,is),osili(id,is),onita(id,is)))
	  end
	end %id
	gid=input(...
	  'ENTER 0 if accept, or DESIRED IDs (e.g. 1:5,[1:4,5:7],...) ');
	if gid %REPLACE THE DATA WITH THE SELECTED DATA
	  gidn=1:length(gid);
	  gnan=NaN*ones(nlev-length(gid),1);
	  opres(:,is)=[opres(gid,is);gnan];
	  castno(:,is)=[castno(gid,is);gnan];
	  sampno(:,is)=[sampno(gid,is);gnan];
	  btlnbr(:,is)=[btlnbr(gid,is);gnan];
	  for iprop=1:nvar
	    eval([propnm(iprop,:) '(:,is)=['propnm(iprop,:) '(gid,is);gnan];'])
	  end %iprop
	  Gidselectedcast{is}=gid0(gid);
	  gid=gidn;
	  onobs(is)=length(gid);
	else
	  break
	end %~gid
      end %while 1
    end %is
  end %if is<=

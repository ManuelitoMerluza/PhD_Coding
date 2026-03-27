%script rwb_selectprop: part of w2o_readwocebot
disp('')
disp('Selecting the properties now ...')
ppause
disp('  rwb_selectprop.m ...')

  onstat=length(gisel);

  f_firstpass=1;f_warned=0;
  for ipropwoce=1:size(varname,1)
    unit=' ';iprop=0;
    switch varname(ipropwoce,:)
      case 'STNNBR' %FIND OUT WHICH INDICE GOES WITH WHICH STATION
        stnnbrs=botdat(:,ipropwoce);
	stat_fstdata=find([1;diff(stnnbrs)]);
	wnobs=diff([stat_fstdata;length(stnnbrs)+1]);
	if onstat~=length(oslon)
	  disp('.sum and .hyd files do not have the same length !')
	  disp('PLEASE SELECT THE STATIONS TO MAKE THEM THE SAME LENGTH')
	end
	nlev=10*ceil(max(wnobs)/10);
        if ipropwoce~=1
	  error('STNNBR is not the first, code does not work')
	end
	propstr='ssstnnbrs'; %THIS ASSIGNEMENT IS JUST FOR CONSISTENCY BELOW
      case 'CASTNO'
        propstr='castno';
      case 'SAMPNO'
        propstr='sampno';	
      case 'BTLNBR'
        propstr='btlnbr';
      case 'CTDPRS'
        propstr='opres';
      case 'CTDTMP'
        iprop=1;
	propstr='  otemp';
      case 'SALNTY'
        iprop=2;
	propstr='  osali';
      case 'OXYGEN'
        iprop=3;
	propstr='  ooxyg';
      case {'PHSPHT','PO4   '}
        iprop=4;
	propstr='  ophos';
      case {'SILCAT', 'SIO2  '}
        iprop=5;
	propstr='  osili';
      case {'NITRAT','NO3   ','O2+NO3'} %For NO2+NO3
        %Nitrate + Nitrite if already summed go to onita (good appropx)
        iprop=6;
	propstr='  onita';
      case 'NITRIT'
        iprop=7;
	propstr='  oniti';
	iprop_=iprop;
      case 'TCARBN'
        iprop=8;
	propstr='otcarbn';
	iprop_=iprop;
      case '  PCO2'
        iprop=iprop_+1;
	propstr='  opco2';
	iprop_=iprop;
      case '  FC02'
        iprop=iprop_+1;
	propstr='  ofco2';
	iprop_=iprop;
      case 'ALKALI'
        iprop=iprop_+1;
	propstr='oalkali';
	iprop_=iprop;
%      case 'CFC113'
%        iprop=9;
%	propstr='ocfc113';
%      case '  CCL4'
%        iprop=10;
%	propstr='  occl4';
%      case 'CFC-11'
%        iprop=11;
%	propstr=' ocfc11';
%      case 'CFC-12'
%        iprop=12;
%	propstr=' ocfc12';
      case {' THETA','THETA ','CTDSAL','CTDOXY','CTDRAW','OXYTMP','REVPRS','REVTMP', ...
	    'TRITUM','HELIUM','DELC14','C14ERR', ...
	    'CFC113','  CCL4','CFC-11','CFC-12','MONIUM',...
	    'DELHE3','  PCO2','CO2TMP','TRITER','HELIER','DELHER',...
	    '    PH','  NEON','NEONER'}
%     case {' THETA','CTDSAL','CTDOXY','CTDRAW','OXYTMP','REVPRS',...
%	'MONIUM','REVTMP'}
        iprop=-1;
      otherwise
	error([varname(ipropwoce,:) ' unknown variable'])
    end %switch
      
    if iprop ==-1
      disp([varname(ipropwoce,:) ' NOT RETAINED'])
    else
      oprop=NaN*ones(nlev,onstat);
      for isn=1:onstat %isn = indice in the new selection(gisel)
	isw2get=ostnnbr(isn); %isw2get = indice in the woce data
	isw=find(stnnbrs(stat_fstdata)==isw2get);
	if isempty(isw) 
	  if ((f_firstpass)+(~f_warned))
	    onobs(isn)=0;
	    disp(sprintf(...
	      ['  no bottle data for station %i (%i), filling with NaNs '...
		'instead'],gisel(isn),isw2get))
	  end
	  oprop(1:nlev,isn)=NaN*ones(nlev,1);
	  f_warned=1;
	elseif ostnnbr(isn)==stnnbrs(stat_fstdata(isw))
	  oprop(1:wnobs(isw),isn)=...
	    botdat(stat_fstdata(isw):stat_fstdata(isw)+wnobs(isw)-1,ipropwoce);
	  if f_firstpass
	    onobs(isn)=wnobs(isw);
	  end
	else
	  disp('ERROR-PROBLEM IN THIS PROGRAM')
	  disp([ostnnbr(isn),stnnbrs(stat_fstdata(isw))])
	  error('Problem with station IDs not corresponding')
	end %if ostnnbr(isn)==stnnbrs(isw)
      end %is
      eval([propstr '=oprop;']);
      if iprop
	opropnm{iprop}=propstr;
	disp(sprintf('Variable %i is %s (%s) (%s)',iprop,opropnm{iprop},...
	  varname(ipropwoce,:),varunits(ipropwoce,:)))
	opropunits{iprop}=killblank(varunits(ipropwoce,:));
      end
    end %iprop ==-1
    f_firstpass=0;
  end%ipropwoce
  if any(~onobs)
    disp('Please double check for the missing stations')
    ppause
  end
  if ~exist('btlnbr')
    btlnbr=-9*ones(size(opres));
  end
  if ~exist('sampno')
    sampno=-9*ones(size(opres));
  end
  gip=find(opres<0);
  if ~isempty(gip)
    disp('Negative pressure found and set to zero !')
    disp('Double check if the data make sense ...')
    disp(opres(gip))
    opres(gip)=0;
    ppause
  end
  for iprop=1:length(opropnm)
    if isempty(opropnm{iprop})
      disp('Warning: empty property name')
      if iprop==4
	disp('assigning phosphate to variable 4 and NaNs for the phosphate')
	opropnm{iprop}='  ophos';
	ophos=NaN*ones(size(opres));
      end
      ppause
    end
  end
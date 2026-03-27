% script g_pairset
% KEY: set the properities at the pairs, optionally plots, save the files
% USAGE :
%
% DESCRIPTION : 
%
% INPUT: 
%        Isctd       [ = 1 -> data on ctd depths]
%        p_cmp2stat  [!= 0 -> pltprop]
%        p_plots     [!= 0 -> pltprop]
%        Ptreat      [ = 1,2,3,4,5 -> see g_hotpair]
% OUTPUT:
% VARIABLES: 
     % Botp(Nstat)        :bottom depths for stations
     % Isctd(Nprop)       :1 if this data is on the ctd Pressure intervals
     % Itemp,Isali,Idynh, :integer, indice of each property, NaN if not avail
     % Maxdp(NPair,pprop) :index of deepest measurement for pair
     % Nprop              :# of properties available (temp, sali, ...)
     % Nstat              :# of stations
     % Plat Plon(Npair)   :locations of pairs
     % Pres(MPres(iprop)) :depth (db)
     % Propnm             :name of each property
     % Secname            :subsection name 
     % Slat Slon(Nstat)   :locations of stations
     % dpt                :linear distance between pairs
     % dst                :linear distance between stations
     % pname              :Propnm{iprop}
     % pprop              :property values at pairs
     % pres               :depth (db) (frm ctd if Isctd, otherwise frm hydro)
     % prop(Nprop)        :property values
     % punit              :Propunits{iprop}
%
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , Nov 95
%
% UPDATES: Jan 96, D. Spiegel
%  Renamed shald to sdynh, deepd to ddynh for consistency with pdynh
%
%  Feb 97, A. Ganachaud
%    The calc of shal prop  and pair prop in g_botwedge is based on the method
%    defined in Ptreat, that was set before for each pair
% 					
%  slopmx is passed to g_botwedge for case cstvel.
%  Maxdp  is passed to whydro instead of Maxd.
%
% SIDE EFFECTS :
%
% SEE ALSO :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER: geovel
% CALLEE: rhydro, check_val, g_botwedge, whydro, pltprop
%

  disp('------------------------------------------------------')
  disp(' CALCULATING THE PAIR PROPERTIES ' )

  % PAIR POSITIONS
  % Slon is supposed continuous (no 360 jumps)
  Plat = 0.5 * (Slat(1:Nstat-1) + Slat(2:Nstat));
  Plon = 0.5 * (Slon(1:Nstat-1) + Slon(2:Nstat)); 
  if any(abs(diff(Plon)) > 100) 
    error('longitude deviation too large')
  end
  % BOTTOM DEPTH ( DEEPEST STATION FOR EACH PAIR )
  Pbotp=Botp(ishdp(2,:));
  
  %LOOP ON EACH PROPERTY (TEMP, SALT, ...)
  for iprop = 1:Nprop
    if isempty(Propnm{iprop})
      Propnm{iprop}='NODATA';
    end
    pname = Propnm{iprop};    %property name
    punit = Propunits{iprop}; %property unit
    disp(' ')
    disp(['treating ' pname ' ...'])
    
    %READ THE STATION PROPERTIES IF NOT HERE
    p_skipall=0;
    if ~exist([pname 's']) %prop already in memory and subselected
      if ~exist([pname])
	if isempty(Statfiles{iprop})
	  MPres(iprop)=MPres(iprop-1);
	  prop=NaN*ones(MPres(iprop),Nstatold);
	  p_skipall=1;
	  Pairfiles{iprop}=[prefix,'_',Propnm{iprop},'.fbin'];
	  Precision{iprop}=Precision{iprop-1};
	else
	  prop=rhydro([IPdir Statfiles{iprop}],Precision{iprop},MPres(iprop), ...
	    Nstatold,Maxdold(:,iprop));
	end
      else
	eval(['prop=' pname ';']);
      end
      %SELECT THE DESIRED SUBSET OF STATIONS:
      prop=prop(:,Gis2do);
    else
      eval(['prop=' pname 's;' ]);
    end
    
    if (iprop==Ioxyg)&any(any(prop>100)) 
      check_val(prop/44.6369,pname) %consistency check is in ml/l      
    else
      check_val(prop,pname)       %check consistency
    end    
    if Isctd(iprop)
      pres=Presctd;
    else
      pres=Pres;
    end
      
    %VARIABLE 'PROP' IS SUCCESSIVELY TEMPERATURE, SALINITY, ... AT STATIONS
    %VARIABLE 'PPROP' AT PAIR
    pprop=NaN*ones(size(prop,1),Npair);
    
    if ~p_skipall 
      %create a variable that will contain all the extrapolated values
      prop2plot=prop;
      
      %LOOP ON THE PAIRS
      for ipair = 1:Npair
	iss=ishdp(1,ipair); %shallow station indice
	sprop=prop(:,iss);
	isd=ishdp(2,ipair); %deep station indice
	dprop=prop(:,isd);
	if Ptreat(ipair)>=100 %horizontal extrapolation
	  [sprop,dummyflag]=g_horiz_extrap(prop,ishdp,ipair,Slat, Slon);
	  imaxdt=max(find(~isnan(sprop)));
	  itreat=Ptreat(ipair)-100;
	else
	  sprop=prop(:,iss);
	  imaxdt=Maxd(iss,iprop);
	  itreat=Ptreat(ipair);
	end
	pprop_p = 0.5 * (sprop+dprop); %pprop_p is a vector for current pair
	
	%EXTRAPOLATION AT THE BOTTOM
	[sprop,pprop_p,deprop] = g_botwedge(itreat, 0, ipair,pname,punit,pres, ...
	  sprop,imaxdt,dprop,Maxd(isd,iprop), pprop_p, distg(ipair),slopmx);
	
	if iprop>1 & any(pprop_p<0)
	  disp('Negative values found and set to zero')
	  gid=find(pprop_p<0);
	  pprop_p(gid)=0;
	  gid=find(sprop<0);
	  sprop(gid)=0;
	end
	pprop(:,ipair)=pprop_p;
	prop2plot(:,iss)=sprop;
      end %on ipair
    end %if ~p_skipall  
    
    %SAVE THE PAIR PROPERTIES
    if p_saveOP
      whydro(pprop,[OPdir Pairfiles{iprop}],Precision{iprop},Maxdp,ovw)
    else
      eval(['p' pname '=pprop;'])
    end
    
    %PLOT THE EXTRAPOLATED PROPERTY
    if p_plots & iprop==1
      %find the deepest station depth for each station
      for is=1:Nstat
	botp2plot(is)=max(Botp(max(1,is-1):min(Nstat,is+1)));
	maxd2plot(is)=max(Maxd(max(1,is-1):min(Nstat,is+1),1));
      end
      disp(['plotting extrapolated ' pname ' ... '])
      figure; clf; 
      maxy=500*ceil(mmax(Botp)/500);
      
      if (iprop==Ioxyg)&any(any(prop>100)) 
	prop2plot=prop2plot/44.6369;
	punits='ml/l';
      else
	punits=Propunits{iprop};
      end
      plt_prop(prop2plot, Propnm{iprop}, punits, ...
	Cruise, pres, maxd2plot(:),botp2plot(:) , Slat, Slon,maxy)
      land;setlargefig
      ch=get(gcf,'child');
      axes(ch(1))
      pl=plot([0;cumsum(sw_dist(Slat,Slon,'km'))],-Botp,'r');
      zoom on;
      disp('Check the slope regions (use zoom)')
      ppause
    end
    if 0
      figure(15);clf
      for id=min(Maxd(:,iprop)):max(Maxd(:,iprop));
	plot([0;distt],prop2plot(id,:),'b-+');hold on;
	plot([0;distt],prop(id,:),'ro')
	disp(pres(id))
	ppause
      end
    end
    
  end %iprop


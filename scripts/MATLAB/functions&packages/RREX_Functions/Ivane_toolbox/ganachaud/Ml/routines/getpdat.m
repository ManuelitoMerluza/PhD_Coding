% script getpdat.m
% KEY:  read the pair data for a given section. 'datadir' 'secid'
% USAGE : getpdat
% 
%
%
% DESCRIPTION : 
%
%
% INPUT: secid: name of the section (string)
%        datadir: name of the data directory
%
% OUTPUTs:
% 1)from the Header file
%   INPUT STATION HEADER FILE VARIABLES:
%     Botp         (Nstat) : bottom pressure
%      NAME WAS CAHNGED FROM Botd TO AVOID CONFUSION PRESSURE/DEPTH
%     Cast         (Nstat) : mysterious variable (probably the original
%                            station number
%     Cruise               : name of the cruise
%     Isctd        (Nprop) : 1 if this data is on the ctd Pressure intervals
%     Itemp,Isali,Idynh,   : integer, index of each property, NaN if not avail
%     Kt           (Nstat) : record number (not useful at the moment)
%     M            (Nstat) : original station indice
%     MPres        (Nprop) : # of "standard" depth
%     Maxd   (Nstat,Nprop) : index of deepest measurement
%     Nobs         (Nstat) : # of observations  
%     Nprop                : # of properties available (temp, sali, ...)
%     Nstat                : # of stations
%     Precision            : format for the binary files (cf mk_hydrofile.m)
%     Pres   (MPres(iprop)): depth (db)
%     Presctd(MPres(iprop)): depth (db) for ctd data
%     Propfiles            : names of the binary files (.fbin) containing property values
%     Propnm               : name of each property
%     Propunits            : units -
%     Remarks              : -
%     Secdate              : date of the section
%     Ship         (Nstat) : ship Id 
%     Slat Slon    (Nstat) : locations
%     Treatment            : done on the data
%     Xdep         (Nstat) : depths to the deepest measurement for each station
%   OUTPUT PAIR HEADER FILE VARIABLES (all of the above plus the following):
%     Maxdp                : Max depth for the deeper station of the pair
%     Npair                : # of pairs
%     Pairfiles            : names of the binary files (.fbin) containing property values
%     Pbotp(Npair)         : bottom pressure (db) at this pair (deepest station depth)
%      NAME WAS CAHNGED FROM Pdep TO AVOID CONFUSION PRESSURE/DEPTH
%     Plat Plon    (Npair) : pair latitudes, longitudes     
%     Ptreat               : treatment done at this pair
%     Secname              : subsection name 
%     Velfile              : name of binary file containing velocities (ref. to surface)
%     Velprec              : precision (to read Velfile)
%
% 2)actual data;
%     gvel(idep,ipair)     : geostrophic velocity
%     temp(idep,ipair)     : temperature field
%     sali, oxyg, phos, sili, dynh ...   same as temp, other properties
%
%%%%%%%%
%
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , Nov 96
%
% SIDE EFFECTS :
%
% SEE ALSO :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER:
% CALLEE: rhydro

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %LOAD THE PAIR DATA
    % 1 - HEADER FILE:
    hdrname = [secid '_pair.hdr.mat'];
    eval(['load ' datadir hdrname ])
    disp(' reading header file : ')
    disp([datadir hdrname])
    if exist('Botd')
      Botp=Botd;
      disp('***************************')
      disp('Botd changed into Botp')
      disp('***************************')
      clear Botd
    end
    if exist('Pdep')
      Pbotp=Pdep;
      disp('***************************')
      disp('Pdep changed into Pbotp')
      disp('***************************')
      clear Pdep
    end
    
    
    % 2 - DATA FILE:
    disp('READING DATA FILES ...')
    for iprop=1:Nprop
      if iscell(Pairfiles)
	pf= Pairfiles{iprop};
	pr=Precision{iprop};
	prp=Propnm{iprop};
      else
	pf=Pairfiles(iprop,:);
	pr=Precision(iprop,:);
	prp=Propnm(iprop,:);
      end
      disp([datadir pf])
      prop = rhydro([datadir pf], pr, ...
	MPres(iprop), Npair, Maxdp(:,1));
      eval(['p' prp '=prop;']);
    end
    disp('each property now takes prefix p for pair')
    disp('ptemp, psali, ...')
    
   
    % 3 - VELOCITY FILE:
    disp([datadir Velfile])
    gvel = rhydro([datadir Velfile], Velprec, ...
      MPres(iprop), Npair, Maxdp(:,iprop));

    % 4 - FILL WITH NaN IF NO DATA
    isnodata=find(strcmp('NODATA',Propnm(:)) );
    for iprop=isnodata
      if iprop==Iphos
	Propnm{Iphos}='pphos';
	pphos=NaN*ones(size(prop));
      end
    end
    clear prop NODATA

    % 5 - CHECK THAT THERE IS NO COINCIDENT MAXDEP+1/BOTTOM DEP
    %do this because the coincidence misleads mk_set_layprops
    nmax=length(Presctd);
    resave=0;
    for ipair=1:Npair
      if Maxdp(ipair)~=nmax & Pbotp(ipair)==Presctd(Maxdp(ipair)+1)
	Pbotp(ipair)=Pbotp(ipair)-1;
	disp(sprintf('Bottom dep shifted 1db pair %i for consistency',ipair))
	if Botp(ipair)==Presctd(Maxdp(ipair)+1)
	  Botp(ipair)=Botp(ipair)-1;
	end
	if Botp(ipair+1)==Presctd(Maxdp(ipair)+1)
	  Botp(ipair+1)=Botp(ipair+1)-1;
	end
	resave=1;
      end
    end
    if resave
      disp([' re-write header file : ' datadir hdrname])
      eval(['save ' datadir hdrname  ...
	  ' IPhdr Treatment Remarks Cruise Secname ' ...
	  'Npair Plat Plon Velfile Velunit Velprec Ptreat Pbotp ' ...
	  'Secdate MPres Nstat Slat Slon ' ...
	  'Botp Pres Presctd Maxd Maxdp Nprop Isctd svel ' ...
	  'Itemp Isali Ioxyg Iphos Isili Idynh Propnm ' ...
	  'Propunits Pairfiles Precision ' ...
	  'Gis_select Ship Stnnbr Xdep Kt Nobs slopmx'])
    end
    clear nmax ipair hdrname
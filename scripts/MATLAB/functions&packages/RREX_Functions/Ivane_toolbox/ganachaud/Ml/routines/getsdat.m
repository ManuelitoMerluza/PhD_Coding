% script getsdat.m
% KEY:  read the station data for a given section. 'datadir' 'secid'
% USAGE : getsdat
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
%   INPUT STATION HEADER FILE VARIABLES: (NaN or empty if not available)
%     Botp         (Nstat) : bottom pressure
%     Cast         (Nstat) : mysterious variable
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
%     Propfiles            : names of the binary files (.fbin) containing 
%                            property values
%     Propnm               : name of each property
%     Propunits            : units -
%     Remarks              : -
%     Secdate              : date of the section
%     Ship         (Nstat) : ship Id 
%     Slat Slon    (Nstat) : locations
%     Treatment            : done on the data
%     Xdep         (Nstat) : depths to the deepest measurement for each station
%     Secname              : subsection name 
%  
%   OPTIONAL
%     Eta          (Nstat) : sea surface height
%
% 2)actual data;
%     dynh(idep,ipair)     : geostrophic velocity
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
    % 1 - HEADER FILE:
    hdrname = [secid '_stat.hdr.mat'];
    eval(['load ' datadir hdrname ])
    disp(' reading header file : ')
    disp([datadir hdrname])
    
    if exist('Botd')
      disp('Botd variable replaced with Botp !!!')
      Botp=Botd;
      clear Botd
    end
    
    % 2 - DATA FILE:
    disp('READING DATA FILES ...')
    for iprop=1:Nprop
      if iscell(Statfiles)
	sf= Statfiles{iprop};
	pr=Precision{iprop};
	prp=Propnm{iprop};
      else
	sf=Statfiles(iprop,:);
	pr=Precision(iprop,:);
	prp=Propnm(iprop,:);
      end
      disp([datadir sf])
      if isempty(sf)
	prop=NaN*ones(Maxd(:,iprop),Nstat);
      else
	prop = rhydro([datadir sf], pr, ...
	  MPres(iprop), Nstat, Maxd(:,iprop));
	eval([prp '=prop;']);
      end
    end
    clear prop sf pr prp iprop



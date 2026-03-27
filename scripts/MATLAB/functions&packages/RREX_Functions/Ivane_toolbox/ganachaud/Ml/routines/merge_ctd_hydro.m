%script merge_ctd_hydro
%KEY:
% KEY :  merge ctd data with the hydrographic data
% USAGE :
% 
%
%
%
% DESCRIPTION : 
%         Takes ctd header + bottle header
%         creates a new header referring to the data files
%         from ctd of hydro
%
% INPUT:  parameters
%         <ctd data from ctd_treat.m> (not read)
%         ctd header from ctd_treat
%         bottle data from obs2std
%         bottle header from obs2std
%
% OUTPUT: stations + header data in Alex' format
%
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , Nov 97
%
% SIDE EFFECTS :
%
% SEE ALSO :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER:
% CALLEE:
%
% PARAMETERS
%
  %OUTPUT DIRECTORY
%  OPdir='/data35/ganacho/A9/Stddata/';

  %STATION SUBSELECTION (OPTIONAL) FROM BOTTLE DATA
  %gstatbott=[1:28,30,32:46,54:94,103:111];
  
  %CTD INFO
%  ctdhdr=[OPdir 'A9_ctdstd.mat'];
%  gictdvar=[1 2 3 4];
%  gistatcvar=[1 2 3 7];
  
  %Bottle info
%  bottdir=OPdir;
%  botthdr='A9_botstd.hdr.mat';
  %properties to take from std bottle info
%  gibotvar=[1 2 3];
  %where to put them in the stat file
%  gistatbvar=[4 5 6];
%  Itemp=1; Isali=2; Ioxyg=3;Iphos=4;Isili=5;Inita=6;Idynh=7;
  
%DIARY
if exist('merge.dry')
  disp('removing old diary ...')
  unix('rm merge.dry');
end
disp(['Creating diary ' pwd '/merge.dry'])
diary merge.dry

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% CTD data selection
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if exist('ctdhdr')
  disp('')
  disp('CTD DATA')
  disp(['loading header file ' ctdhdr])
  eval(['load ' ctdhdr])
  %cstnnbr=Stnnbr; %for later controls
  %cmaxd=Maxd;
  disp('Taking the following properties from CTD:')
  for ip=1:length(gictdvar)
    Isctd(gistatcvar(ip))=1;
    Statfiles{gistatcvar(ip)}=cstatfiles{gictdvar(ip)};
    Precision{gistatcvar(ip)}=cprecision{gictdvar(ip)};
    Propnm{gistatcvar(ip)}=cpropnm{gictdvar(ip)};
    if ~exist('cpropunits')
      switch Propnm{gistatcvar(ip)}
        case 'temp'
	  Propunits{gistatcvar(ip)}='Cels';
	case 'sali'
	  Propunits{gistatcvar(ip)}='g/kg';
	case 'oxyg'
	  Propunits{gistatcvar(ip)}='UMOL/KG';
	case 'dynh'
	  Propunits{gistatcvar(ip)}='m^2/s^2';
	otherwise
	  disp(['Unit not set for ' Propnm{gistatcvar(ip)}])
      end %switch
    else 
      Propunits{gistatcvar(ip)}=cpropunits{gictdvar(ip)};
    end %if ~exist('cpropunits')
    disp([Propnm{gistatcvar(ip)},'(' Propunits{gistatcvar(ip)} ')'])
  end %for
  Presctd=cpres;
  MPres(gistatcvar)=length(Presctd)*ones(length(gistatcvar),1);
  Maxd(:,gistatcvar)=cmaxd(:)*ones(1,length(gistatcvar),1);
else
  Presctd=[];
end %if exist('ctdhdr')

  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% BOTTLES data selection
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if exist('botdat')
  error('this part of the code is obsolete')
  %READ RAW BOTTLE DATA HEADER (CONTAINS BASIC INFO-Slat/Slon,Botd
  %AND THE PROPERTY NAMES
  eval(['load ' bottobsmaskfile])
  if ~exist('givar_in_stdbot')
    givar_in_stdbot=1:nvar;
  end
  %LOAD ALISON'S FORMAT
  get_alison_stddata
else
  if ~isempty(botthdr)
    %LOAD WITH ALEX' FORMAT
    disp('')
    disp('Bottle data')
    disp(' reading header file : ')
    disp([bottdir botthdr])
    eval(['load ' bottdir botthdr ])
    if ~exist('gstatbott')
      gstatbott=1:bnstat;
    end
    Nstat=length(gstatbott);
    Slat=bslat(gstatbott); Slat=Slat(:);
    Slon=bslon(gstatbott); Slon=Slon(:);
    Botp=bbotp(gstatbott); Botp=Botp(:);
    bmaxd=bmaxd(gstatbott);bmaxd=bmaxd(:);
    Ship=bship(gstatbott); Ship=Ship(:);
    Stnnbr=bstnnbr(gstatbott);Stnnbr=Stnnbr(:);
    Xdep=bxdep(gstatbott);  Xdep=Xdep(:);
    Kt=bkt(gstatbott);      Kt=Kt(:);
    onobs=onobs(gstatbott);   onobs=onobs(:);
    isobs=isobs(:,gstatbott);
    opres=opres(:,gstatbott);
    
    disp('Taking the following properties from bottle data:')
    for ip=1:length(gibotvar)
      Isctd(gistatbvar(ip))=0;
      Propnm{gistatbvar(ip)}=bpropnm{gibotvar(ip)};
      Propunits{gistatbvar(ip)}=bpropunits{gibotvar(ip)}; 
      Statfiles{gistatbvar(ip)}=bstatfiles{gibotvar(ip)}; 
      Precision{gistatbvar(ip)}=bprecision{gibotvar(ip)}; 
      disp([Propnm{gistatbvar(ip)},'(' Propunits{gistatbvar(ip)} ')'])
      if exist('ctdhdr')& any(gistatcvar==gistatbvar(ip))
	error('Data copied from CTD and Bottle !')
      end
    end
    %Checking consistency with CTD data
    if exist('ctdhdr')
      if (length(Stnnbr)~=length(cstnnbr))|...
	  any(Stnnbr~=cstnnbr)
	Stnnbr,cstnnbr
	error('the stations are not the same !')
      end
    end
    
    MPres(gistatbvar)=length(Pres)*ones(length(gistatbvar),1);
    Maxd(:,gistatbvar)=bmaxd*ones(1,length(gistatbvar),1);
    
  else %botdat is empty. No bottle data
    disp('no bottle data')
    Nstat=cnstat;
    Slat=cslat; Slat=Slat(:);
    Slon=cslon; Slon=Slon(:);
    Botp=cbotp; Botp=Botp(:);
    Ship=cship; Ship=Ship(:);
    Stnnbr=cstnnbr;Stnnbr=Stnnbr(:);
    Xdep=[];  Xdep=Xdep(:);
    Kt=[];      Kt=Kt(:);
    onobs=[]; 
    isobs=[];
    opres=[];
    Pres=cpres;
  end
  
end %if exist('botdat')
Nprop=length(Propnm);
if any(Slon<-180)
  Slon=360+Slon;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%SAVING HEADER FILE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
OPhdr=[Secname '_stat.hdr.mat'];
disp(['Saving header file for the merged data: ' OPdir OPhdr ])
eval(['save ' OPdir OPhdr ' Treatment Remarks Cruise Secname '...
    'Secdate MPres Nstat Slat Slon '...
    'Botp Pres Presctd Maxd Nprop  '...
    'Isctd Itemp Isali Ioxyg Iphos Isili Inita Idynh '...
    'Propnm Propunits Statfiles Precision '...
    'Ship Stnnbr Xdep Kt onobs']);

disp('DATA MERGED !')
disp('')
diary off

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PROPERTY PLOTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('plotting now (CTRL-C to stop)')

if ~exist('p_xax')
  p_xax='lon'; %x axis
end

plotallprops;
if 0
for iprop=1:Nprop
  figure(iprop)
  prop=rhydro([OPdir Statfiles{iprop}],Precision{iprop},MPres(iprop), ...
    Nstat,Maxd(:,iprop));
  eval([Propnm{iprop} '=prop;']);
  maxy=500*ceil(mmax(Botp)/500);
  if (iprop==Ioxyg)&any(any(prop>100)) 
    pottemp=sw_ptmp(sali,temp,cpres,0);
    rho = sw_dens(sali,pottemp,0);
    prop=prop.*rho/1000/44.6369;
     punits='ml/l';
  else
    punits=Propunits{iprop};
  end
  if Isctd(iprop)
    pres=Presctd;
  else
    pres=Pres;
  end
  plt_prop(prop, Propnm{iprop}, punits, ...
    Cruise, pres, Maxd(:,iprop), Botp, Slat, Slon,maxy)
  land;setlargefig
end
end %if 0













%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if 0
  %THE FOLLOWING CONCERNS THE FORMER SYSTEM ONLY
% BOTTLE DATA
  %ORIGINAL DATA OBSERVATION MASK
  bottobsmaskfile='/data35/ganacho/A9/A9.observed_obsmask.mat';
  bottdir='/data39/alison/phd/progs/obs2std/A9/';
  botthdr='A9_run1.hdr';
  
  %IF THE PARAMETER botdat EXISTS, THE PROGRAM WILL TAKE 
  %ALISON'S FORMAT AS INPUT
  %NECESSARY PARAMETERS FOR ALISON'S FORMAT
    %VARIABLES PRESENT IN THE STD FILE (INDICED W/ RES. TO
    %THE VARIBLES PRESENT IN THE DATA OBSERVATION MASK (OPTIONAL)
    %givar_in_stdbot=1:7;
    %DATA FILE NAME
    botdat= 'A9_run3.std';
    %NUMBER OF STATIONS, OF VARIABLES IN THE STD OUTPUT FILE
    %OTHERWISE THOSE ARE ALREADY IN THE HEADER FILE
    nstat=111;
    %VARIABLES
    nvar=7;
    ndep=37;
    Propnm={'temp','sali','oxyg',...
      'phos',...
      'sili',...
      'nita',...
      'niti'};
    Propunits={'Cels','g/kg','?',...
      'umol/kg',...
      'umol/kg',...
      'umol/kg',...
      'umol/kg'};
    %CRUISE INFO
    Secname='A9';
    Cruise='A9, METEOR cruise 15, leg 3, Siedler';
    Secdate='Feb 10, 1991 to March 3, 1991';
    Remarks=[];
    Treatment='merge_ctd_hydro OP';
end %if 0
if 0 %FORMER CODE
  %CHANGE THE VARIABLE NAMES
  %MAKE SURE THAT THE BOTTLE DATA ARE COMPATIBLE WITH CTD
  if Nstat ~= length(stnnbr)
    error('Not the same number of stations !')
  end
  if any(Stnnbr-stnnbr)
    error('Stations not corresponding !')
  end
  if ndep~=length(std)
    error('not the same standart depths !')
  end
  %Bottom pressure from CTD header
  if exist('botdat') 
    %SAVE THE BOTTLE DATA (Not T-S-O)
    for iprop=4:Nprop-1
      ovw=1;
      eval(['prop=' Propnm{iprop} ';'])
      whydro(prop,[OPdir Statfiles{iprop}],Precision{iprop},Maxd,ovw)
    end
  else
    disp('Bottle data already in the right format')
  end
  disp('CTD data already in the right format')
  disp('Just passing the name')
  MPres=ones(Nprop,1)*Ndep;
  Maxd=Maxd*ones(1,Nprop);
  Pres=Presctd;
%else
  %IF NO CTD, SAVE T, S AND O2 FROM THE BOTTLE DATA
  Botp=botp;
  Stnnbr=stnnbr;
  Presctd=NaN;
  Idynh=NaN;
  for iprop=1:3
    ovw=1;
    eval(['prop=' Propnm{iprop} ';'])
    whydro(prop,[OPdir Statfiles{iprop}],Precision{iprop},Maxd,ovw)
  end

end % if 0


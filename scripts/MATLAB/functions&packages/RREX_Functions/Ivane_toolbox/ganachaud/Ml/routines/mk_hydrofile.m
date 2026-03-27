%function mk_hydrofile
%key: makes the HYDRO-format files (input to geovel.m)
%  from the Alison's format, output from mergech
%  this program is provisory, as later on all the data may be
%  on the same format.
%
%SYNOPSYS: the parameters are at the beginning of the program
%  for the time being
% 
%INPUT:
%  -the ASCII header file 
%    ex: /data9/alison/phd/progs/mergech/endev129.hdr_ascii
%  -the .mat output from mergech
%  -a file with the standart depths
%  -a file with the standart depths for ctd data (which is the same
%          but could change)
%  
%  -the name of the output header file
%  -the name of the output directory
%  
%  -name, date of the section and a whole bunch of informations
%   see section "PARAMETERS"
%
%OUTPUT: (in the output directory)
%  -a header file containing as many informations as possible
%  -a fortran binary data file for each property.
%     each data file name is given in the header file
%     
% Content of the header file 
%
%    % Cruise            :name of the section
     % Secdate            :date of the section
     % Treatment          :effectued on the data
     % Remarks            :-
     % Nstat              :# of stations
     % Slat Slon(Nstat)   :station locations
     % Botd(Nstat)        :bottom depths
     % Nprop              :# of properties available (temp, sali, ...)
     % Propnm             :name of each property
     % Ofname             :name of the header file itself
     % Datadir            :original directory for the data
     %                     wrong if the data have been moved
     % Propfiles          :name of the binary file containing the property values
     % Propunits          :units -
     % Precision          :format for the binary file
     % Itemp,Isali,Idynh, :integer, indice of each property, NaN if not available 
     % Isctd(Nprop)       :1 if this data is on the ctd Pressure intervals
     % Vcont(Nprop)       :suggested contour intervals for plots
     % MPres(Nprop)       :# of "standard" depth
     % Maxd(Nstat,Nprop)  :index of deepest measurement
     % Pres(MPres(iprop)) :depth (db)
     % Presctd(MPres(iprop)):depth, for ctd data
     % M  (Nstat)         :original station indice
     % Ship(Nstat)        :ship Id 
     % Cast (Nstat)       :misterious variable
     % Xdep (Nstat)       :depths to the deepst measurement for each station
     % Kt    (Nstat)      :record number (not usefull at the moment)
     % Nobs  (Nstat)      :# of observations  
%
% each of the property can have different number of standart depths
% we separate the properties into 2 categories : ctd/not ctd
% Isctd tells if the property is ctd or not.
% If it is then the depths are given by Presctd, and Mpres(indice of this
% property will be length(Presctd).
%
% This allows one to handle some more finely sampled CTD data and some
% bottle data at the same time.
%
%
%side effects :
%
%author : A.Ganachaud (ganacho@gulf.mit.edu) , Oct 95
%
%see also : geovel
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER: general purpose
% CALLEE: rhdr, whydro

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%PARAMETERS

% plot contours of each variable
 plt=0;

%header file name
 hdrname='/data9/alison/phd/progs/mergech/endev129.hdr_ascii';
%input .mat data file name
 ifname='endev129_mrg';

%standart depths file name for bottle data
stdfile='std.37';

%standart depths file name for temp/sali/dynh data (ctd or not)
stdfilectd='std.37';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%output directory
  Datadir='/data4/ganacho/HYDROSYS/EN129/';

prefix='EN129_SM_'; %SM like Stations from Mergech

%output header file name
  Ofname=[prefix 'hdr'];

%name of the section
  Cruise='ENDEVOR129';
  
%date of the section
  Secdate=485;

Remarks=['properties are MPres x Nstat'];

Treatment='O/P from mergech';

%properties contained in the data file:

%properties indices: define the existence or not of the property, NaN if not
 Nprop=6;
 
 Itemp=1;
 Isali=2;
 Ioxyg=3;
 Iphos=4;
 Isili=5;
 Idynh=6;

Isctd=[1 1 0 0 0 1]; 
Propnm=['temp';'sali';'oxyg';'phos';'sili';'dynh'];
Propunits=['cels';'g/Kg';'ml/l';'um/K';'um/K';'dy m'];


% name of the binary files for each property

Propfiles=[ [ prefix 'temp.fbin']; ...
            [ prefix 'sali.fbin']; ...
	    [ prefix 'oxyg.fbin']; ...
	    [ prefix 'phos.fbin']; ...
	    [ prefix 'sili.fbin']; ...
	    [ prefix 'dynh.fbin'] ];

%precision to which the properties are written
Precision=['float32';'float32';'float32';'float32';...
  'float32';'float32'];

%suggested contour interval to plot the data
Vcont=zeros(20,Nprop);
Vcont(:,Itemp)=[-3 -2 -1 0 1 2 3 4 5 7.5 10 12.5 15 17.5 20 22.5 25 27.5 30 32.5]';
Vcont(:,Isali)=[ 33.2:.2:37]';
Vcont(:,Ioxyg)=[0:0.5:9.5]';
Vcont(:,Iphos)=[0:0.25:4.75]';
Vcont(:,Isili)=[0:10:190]';
Vcont(:,Idynh)=[0.5:0.5:10]';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%           PROGRAM
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%read information from header file
[M,Ship,Cast,Slat,Slon,Botd,Xdep,Kt,Nobs,Maxd]=rhdr(hdrname);
Nstat=length(M);
Maxdctd=Maxd;
Maxd=Maxd*ones(1,Nprop);

%plot positions
if plt
  figure(1);
  plot(Slon,Slat,'+',Slon,Slat,'-');grid on;
  title('hit keyboard to continue ...') 
  disp('hit keyboard to continue ...') 
  pause
end

%%%%%%LOADING THE ASCII Depths FILE
disp(['loading standart depth from file ' stdfile])
eval(['load ' stdfile]);
Pres=std;
mpres=length(Pres);
MPres=mpres*ones(Nprop,1);

disp(['loading ctd depth from file ' stdfilectd])
eval(['load ' stdfilectd]);
disp('Check the following statment concerning ctd pressures')
Presctd=std;
MPresctd=length(Presctd);

disp('oxygen data not taken from ctd')

disp('Maxdctd=Maxd for the time being. will have to be changed')
if ~isnan(Idynh)
  MPres([Itemp Isali Idynh])=MPresctd*ones(3,1);
  Maxd(:,[Itemp Isali Idynh])=Maxdctd*ones(1,3);
else
  MPres([Itemp Isali])=MPresctd*ones(2,1);
  Maxd(:,[Itemp Isali])=Maxdctd*ones(1,2);
end  

%%%%%%LOADING THE MATLAB DATA FROM MERGCH
disp(['loading data from file ' ifname])
eval(['load ' ifname])
%contains arrays named STA<station number>, 
%  Number of depth*Number of properties
%  we now separate them into variables whose names follow

for iprop=1:Nprop
  for istat=1:Nstat
    eval(['prop(:,istat)=STA' int2str(istat) '(:,iprop);'])
  end
  %%eval([Propnm(iprop,:) '=prop;'])
  disp(['catching ' Propnm(iprop,:)])
  if plt
    for is=1:Nstat
      iground=(Maxd(is,iprop)+1:MPres(iprop))';
      prop(iground,is)=NaN*ones(size(iground));
    end
    figure(iprop);clf
    extcontour(Slat,-Pres,prop,Vcont(:,iprop),'label');
    set(gca,'Ylim',[-max(Pres) 0]);grid on
    title([Cruise,' ' Propnm(iprop,:) ' (' Propunits(iprop,:) ')' ])
    drawnow
    for is=1:Nstat %ground back to zero for saving
      iground=(Maxd(is,iprop)+1:MPres(iprop))';
      prop(iground,is)=zeros(size(iground));
    end
  end

  %creates the binary files that will contain the properties
  fnm=[ Datadir Propfiles(iprop,:)];
  whydro(prop,fnm,Precision(iprop,:),Maxd(:,iprop))
  
end


disp(['saving header file : '])
disp([Datadir Ofname]);

if exist(Ofname)==2
  im=menu(['overwrite ' Ofname ' ? '],'YES','NO');
end

eval(['save ' Datadir Ofname, ...
    ' Cruise Secdate MPres Nstat Slat Slon ' ...
    'Botd Pres Presctd Maxd Nprop Isctd Vcont ' ...
    'Itemp Isali Ioxyg Iphos Isili Idynh Propnm Propunits Precision Propfiles ' ...
    'Treatment Remarks M Ship Cast Xdep Kt Nobs '])

clear
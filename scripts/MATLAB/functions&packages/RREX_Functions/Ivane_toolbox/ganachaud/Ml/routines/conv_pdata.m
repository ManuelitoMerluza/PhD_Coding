%function conv_pdata(stddf,IPdir,OPdir,datafile,npair,reclen,ndep,nstat,...
%  Itemp,Isali,Ioxyg,Iphos,Isili,Propnm,Propunits,...
%  namesec,firstpair,lastpair,firststat,laststat,cruises,secdate)       
% KEY:  read the output of geovel, convert it into the hydrosys format
% USAGE : conv_pdata
% 
%
%
% DESCRIPTION : 
%
%
% INPUT:
%
% OUTPUT:
%
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , Nov 96
%
% SIDE EFFECTS :
%
% SEE ALSO :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER:
% CALLEE:

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%READ STANDART DEPTHS
eval(['load ' stddf])
disp(['loading ' stddf])
stddepth=stdd;

%PAIR HEADER FILE
hdrfile =[datafile '_pair.hdr'];;

%PAIR DATA FILE
pdatafile=[datafile '_pair.dat'];

%STATION HEADER FILE
stathdrfile=[datafile '.hdr'];

%READ PAIR DATA
[stat1c,stat2c,kgvc,maxgvc,distgc,gbot1c,gbot2c,velc,...
  tempc,salic,oxygc,phosc,silic]=read_pairdata(...
  hdrfile,npair,pdatafile,ndep,reclen);

%READ STATION HEADER FILE
[ishipc,icastc,xlatc,xlonc,botpc,ktc,xdepc,nobsc,maxdc]=...
  read_stathdr(stathdrfile,nstat);

if size(tempc,1)~=length(stddepth)
  error('The number of standard pressures is not the one expected')
end

Nprop=size(Propnm,1);
%RETRIEVES EACH SECTION SEPARATELY
for isec=1:size(namesec,1)
    disp(['EXTRACTING ' namesec(isec,:)])
    
    %pairs selected: 
    eval(sprintf('p2get=p2get%i;',isec))
    
    stat1=1-min([stat1c(p2get);stat2c(p2get)])+stat1c(p2get);
    stat2=1-min([stat1c(p2get);stat2c(p2get)])+stat2c(p2get);
    %modif Jan 97: min(stat1c(p2get)) instead of stat1c(p2get(1)) because
    %it can be in reverse order
    % ! stat1 and stat2 are the original station numbers
    kgv=kgvc(p2get);
    maxgv=maxgvc(p2get);
    distg=distgc(p2get);
    gbot1=gbot1c(p2get);gbot2=gbot2c(p2get);
    gvel=velc(:,p2get);
    temp=tempc(:,p2get);
    sali=salic(:,p2get);
    oxyg=oxygc(:,p2get);
    phos=phosc(:,p2get);   
    sili=silic(:,p2get);
    
    %stations selected: 
    eval(sprintf('s2get=s2get%i;',isec))
     
    Ship=ishipc(s2get);
    Cast=icastc(s2get);
    Slat=xlatc(s2get);
    Slon=xlonc(s2get);
    Botp=botpc(s2get);
    Kt=ktc(s2get);
    Xdep=xdepc(s2get);
    Nobs=nobsc(s2get);
    Maxd=maxdc(s2get)*ones(1,Nprop);
    
    Npair=length(stat1);
    Slon=scan_longitude(Slon);
    Plon= .5*(Slon(1:Npair)+Slon(2:Npair+1));
    Plat= .5*(Slat(1:Npair)+Slat(2:Npair+1));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % CREATES THE REMAINING INFORMATIVE FIELDS FOR HYDROSYS 
    
    IPhdr=stathdrfile;
    Cruise=cruises(isec,:);
    Treatment=['conversion from geovel.f O/P file ' datafile];
    Remarks=' ';
    Secname=namesec(isec,:);
    Velfile=[deblank(namesec(isec,:)) '_pair_gvel.fbin'];
    Velunit='cm/s';
    Velprec='float32';
    Ptreat=4*ones(Npair,1);
    Nstat=length(Slon);
    Pres=stddepth;
    Presctd=Pres;
    %FIND THE DEEPEST STATION DEPTH FOR EACH PAIR
    %SEE GEOVEL.M FOR DETAIL
      ishdp = [1:Nstat-1; 2:Nstat];
      isw = find( diff(Botp) < 0 );
      ishdp([1 2],isw) = ishdp([2 1],isw);
    Pdep=Botp(ishdp(2,:));
    Secdate=secdate(isec,:);
    MPres=ones(Nprop,1)*length(stddepth);
    Maxdp = Maxd(ishdp(2,:),:);
    Isctd=[1 1 0 0 0];
    Vcont=[];
    Pairfiles=setstr([ones(Nprop,1)*...
	[namesec(isec,:) '_pair_'] Propnm ...
	ones(Nprop,1)*'.fbin']);
    Precision=setstr(ones(Nprop,1)*['float32']);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %SAVE THE PAIR DATA
    % 1 - HEADER FILE:
    OPhdr = [namesec(isec,:) '_pair.hdr.mat'];
    eval(['save ' OPdir OPhdr  ...
	' Treatment Remarks Cruise Secname ' ...
	'Npair Plat Plon Velfile Velunit Velprec Ptreat Pdep ' ...
	'Secdate MPres Nstat Slat Slon ' ...
	'Botp Pres Presctd Maxd Maxdp Nprop Isctd Vcont ' ...
	'Itemp Isali Ioxyg Iphos Isili Propnm ' ...
	'Propunits Pairfiles Precision ' ...
	' Ship Cast Xdep Kt Nobs '])
    disp(' write header file : ')
    disp([OPdir OPhdr])
    % 2 - DATA FILE:
    for iprop=1:Nprop
      eval(['pprop= ' Propnm(iprop,:) ';']);
      ovw=1; %overwrite
      whydro(pprop,[OPdir Pairfiles(iprop,:)],Precision(iprop,:),Maxdp,ovw);
    end
    % 3 - VELOCITY FILE:
    whydro(gvel,[OPdir Velfile],Velprec,Maxdp(:,Itemp),ovw)
  end %for isec
  
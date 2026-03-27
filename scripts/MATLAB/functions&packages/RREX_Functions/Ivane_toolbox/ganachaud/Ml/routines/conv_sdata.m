%conv_sdata
%(stddf,IPdir,OPdir,datafile,reclen,ndep,nstat,...
%  Itemp,Isali,Ioxyg,Iphos,Isili,Propnm,Propunits,...
%  namesec,cruises,secdate)       
% KEY:  read the output of mergech, convert it into the hydrosys format
% USAGE : conv_sdata
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
% UPDATE : A. G. Feb 97: treat dynamic height as one variable
%
% SEE ALSO :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER:
% CALLEE: read_statdata

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%READ STANDART DEPTHS
eval(['load ' stddf])
disp(['loading ' stddf])
stddepth=stdd;

%STAT DATA FILE
sdatafile=[datafile '.std'];

%STATION HEADER FILE
stathdrfile=[datafile '.hdr'];

%READ STATION HEADER FILE
[ishipc,icastc,xlatc,xlonc,botpc,ktc,xdepc,nobsc,maxdc]=...
  read_stathdr(stathdrfile,nstat);

%READ STAT DATA
[dynhc,tempc,salic,oxygc,phosc,silic,nitac]=read_statdata(...
 nstat,sdatafile,ndep,reclen,p_dynh,nvar);

if size(tempc,1)~=length(stddepth)
  error('The number of standard pressures is not the one expected')
end

Nprop=size(Propnm,1);
%RETRIEVES EACH SECTION SEPARATELY
for isec=1:size(namesec,1)
    disp(['EXTRACTING ' namesec(isec,:)])

    %stations selected: 
    eval(sprintf('s2get=s2get%i;',isec))
     
    if p_dynh
      dynh=dynhc(:,s2get);
    else
      dynh=[];
    end
    temp=tempc(:,s2get);
    sali=salic(:,s2get);
    oxyg=oxygc(:,s2get);
    phos=phosc(:,s2get);   
    sili=silic(:,s2get);
    nita=nitac(:,s2get);
    
    Ship=ishipc(s2get);
    Cast=icastc(s2get);
    Slat=xlatc(s2get);
    Slon=xlonc(s2get);
    Botp=botpc(s2get);
    Kt=ktc(s2get);
    Xdep=xdepc(s2get);
    Nobs=nobsc(s2get);
    Maxd=maxdc(s2get)*ones(1,Nprop);
    
    Slon=scan_longitude(Slon);
   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % CREATES THE REMAINING INFORMATIVE FIELDS FOR HYDROSYS 
    
    IShdr=stathdrfile;
    Cruise=cruises(isec,:);
    Treatment=['conversion from mergech.f O/P file ' datafile ' ' date];
    Remarks=' ';
    Secname=namesec(isec,:);
    %Dynhfile=[deblank(namesec(isec,:)) '_stat_dynh.fbin'];
    %Dynhunit='##';
    %Dynhprec='float32';
    Nstat=length(Slon);
    Pres=stddepth;
    Presctd=Pres;
    Secdate=secdate(isec,:);
    MPres=ones(Nprop,1)*length(stddepth);
    Isctd=[1 1 , zeros(1,nvar-2)];
    if p_dynh
      Isctd=[Isctd,1];
    end
    Vcont=[];
    Statfiles=setstr([ones(Nprop,1)*...
	[namesec(isec,:) '_stat_'] Propnm ...
	ones(Nprop,1)*'.fbin']);
    Precision=setstr(ones(Nprop,1)*['float32']);

    if strcmp(Secname,'a24n')
      disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')
      disp('Correcting silica a24n stations 10 ...')
      disp('Correcting phosphate a24n stations 10 ...')
      disp('Correcting nitrate a24n stations 10 and 62 ...')
      disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')
      sili(22:24,10)=sili(21,10)+(sili(25,10)-sili(21,10))/...
	(Pres(25)-Pres(21))*(Pres(22:24)-Pres(21));
      phos(22:24,10)=phos(21,10)+(phos(25,10)-phos(21,10))/...
	(Pres(25)-Pres(21))*(Pres(22:24)-Pres(21));
      nita(22:24,10)=nita(21,10)+(nita(25,10)-nita(21,10))/...
	(Pres(25)-Pres(21))*(Pres(22:24)-Pres(21));
      nita(34:35,62)=[1;1]*nita(33,62);%here we had two zeros
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %SAVE THE STAT DATA
    % 1 - HEADER FILE:
    OPhdr = [namesec(isec,:) '_stat.hdr.mat'];
    eval(['save ' OPdir OPhdr  ...
	' Treatment Remarks Cruise Secname ' ...
	'Secdate MPres Nstat Slat Slon ' ...
	'Botp Pres Presctd Maxd Nprop Isctd Vcont ' ...
	'Itemp Isali Ioxyg Iphos Isili Inita Idynh Propnm ' ...
	'Propunits Statfiles Precision ' ...
	' Ship Cast Xdep Kt Nobs '])
    disp(' write header file : ')
    disp([OPdir OPhdr])
    % 2 - DATA FILE:
    for iprop=1:Nprop
      eval(['pprop= ' Propnm(iprop,:) ';']);
      ovw=1; %overwrite
      whydro(pprop,[OPdir Statfiles(iprop,:)],Precision(iprop,:),Maxd,ovw);
    end
    % 3 - DYNAMIC HEIGHT FILE:
    %whydro(dynh,[OPdir Dynhfile],Dynhprec,Maxd(:,Itemp),ovw)
  end %for isec

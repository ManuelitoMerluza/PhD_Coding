%save_statop.m: save the station output (used in popescus.m) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
%SAVE THE STAT DATA

    %1 - HEADER FILE:
    OPhdr = [namesec '_stat.hdr.mat'];
    eval(['save ' OPdir OPhdr  ...
	' Treatment Remarks Cruise Secname ' ...
	'Secdate MPres Nstat Slat Slon ' ...
	'Botd Pres Maxd Nprop Isctd Vcont ' ...
	'Itemp Isali Ioxyg Iphos Isili Idynh Iuvel Ivvel Propnm ' ...
	'Propunits Statfiles Precision ' ...
	'Cast Eta'])
    disp(' write header file : ')
    disp([OPdir OPhdr])
    % 2 - DATA FILE:
    for iprop=1:Nprop
      eval(['sprop= ' Propnm(iprop,:) ';']);
      ovw=1; %overwrite
      whydro(sprop,[OPdir Statfiles(iprop,:)],Precision(iprop,:),Maxd,ovw);
      if p_plt
	clf;
	g_pltopo(Nstat,Slon,Pres,Maxd(:,1),Botd)
	hold on
	extcontour(Slon,-Pres,sprop,'label','fontsize',6);
	hold off
	title([ Propnm(iprop,:)  ', section ' namesec])
	set(gcf,'papero','land')
	setlargefig
	%printyn('P3')
	%print -P3
	drawnow
	
      end
    end %for iprop=1:Nprop

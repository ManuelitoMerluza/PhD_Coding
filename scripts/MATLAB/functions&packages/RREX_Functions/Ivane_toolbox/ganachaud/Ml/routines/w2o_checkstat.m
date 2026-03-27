% PLOT A STATION PROFILE
% MUST BE RAN AFTER readobsfiles

% MUST PROVIDE gis, station numbers, >1 / < onstat
disp('  w2o_checkstat.m ...')
disp(' USE ZOOM IF NEEDED')

for is=gis
  f4;clf
  set(gcf,'defaultaxesfontsize',10)
  carryon=1;
  while carryon
    clf
    subplot(1,nvar,1)
      if is>1
	plot(otemp(:,is-1),-opres(:,is-1),'g-s');hold on
      end
      if is<onstat
	plot(otemp(:,is+1),-opres(:,is+1),'m->');hold on
      end
      plot(otemp(:,is),-opres(:,is),'b-o')
    grid on; title(sprintf('temp %i',is))
    ylabel('blue=stat green=prev magenta=next ')
    zoom
    
    for iprop=2:nvar 
      eval(['prop=' opropnm{iprop} ';'])
      if strcmp(opropnm{iprop},'otcarbn') | strcmp(opropnm{iprop},'oalkali')
	prop=prop-2000;
	disp('substracted 2000 for alkalinity/tcarbn display')
      end
      subplot(1,nvar,iprop)
      if is>1
	plot(prop(:,is-1),-opres(:,is-1),'g-s');hold on
      end
      if is<onstat
	plot(prop(:,is+1),-opres(:,is+1),'m->');hold on
      end
      plot(prop(:,is),-opres(:,is),'b-o')
      gilab=[1,5:5:onobs(is)]'; 
      if max(gilab)~=onobs(is)
	gilab=[gilab;onobs(is)];
      end
      hdl=text(prop(gilab,is),-opres(gilab,is),num2str(gilab),...
	'VerticalAlignment','bot','fontsize',10);
      grid on; title(sprintf('%s %i',opropnm{iprop},is))
    end %iprop
    
    str=input('fwd = f, bacwd = b, stop/next = s ','s');
    if str=='b'
      is=max(2,is-1);
    elseif str=='s'
      carryon=0;
    else
      is=min(is+1,onstat-1);
    end
  end %while carryon
end %is

    if 0 %former code
      plot(ooxyg(:,is-1),-opres(:,is-1),'g-<',...
	ooxyg(:,is+1),-opres(:,is+1),'b->',...
	ooxyg(:,is),-opres(:,is),'r-o')
      grid on; title(sprintf('oxyg %i',is))
      ylabel('red=stat green=prev blue=next ')
      
      subplot(1,nvar,2)
      plot(ophos(:,is-1),-opres(:,is-1),'g-<',...
	ophos(:,is+1),-opres(:,is+1),'b->',...
	ophos(:,is),-opres(:,is),'r-o')
      grid on; title(sprintf('phos %i',is))
      
      subplot(1,nvar,3)
      plot(osili(:,is-1),-opres(:,is-1),'g-<',...
	osili(:,is+1),-opres(:,is+1),'b->',...
	osili(:,is),-opres(:,is),'r-o')
      grid on; title(sprintf('sili %i',is))
      
      subplot(1,nvar,4)
      plot(onita(:,is-1),-opres(:,is-1),'g-<',...
	onita(:,is+1),-opres(:,is+1),'b->',...
	onita(:,is),-opres(:,is),'r-o')
      grid on; title(sprintf('nita %i',is))
    end %if 0

function [Gis2do,subsecname]=g_choose_stat(Lati,Long,Presctd,Maxd,Botd,Secname,Gis2do)
%key: plots a graphic to choose a subset of stations
%synopsis :
%  [Gis2do,secname]=g_choose_stat(Lati,Long,Presctd,Maxd,Botd,Secname)
%  Maxd(istat,iprop)= indice of maximum depth			
%  Botd(istat)=bottom depth
%
%  Gis2do=selected stations that define asubsection
%  if Gis2do is an input, the program just displays the section and leaves
%
%  subsecname=name of that subsection
%
%description : 
%
%
%
%
%uses :
%
%side effects : use 3 figure windows because of the zoom function
%
%author : A.Ganachaud (ganacho@gulf.mit.edu) , Oct 95
%
%see also : geovel.m
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global staymen exmen %those flags are global variables because
                     %uicontrol executes its statments in the main program

Nstat=length(Lati);

fst=1;
exmen=0; %'exit menu'
p_jd=(nargin==7); %'just display' if Gis2do is input

while ~exmen
  close all;
  if fst & ~p_jd %first passage
    Gis2do=1:Nstat;fst=0;
  end
  Lati=Lati(Gis2do);Long=Long(Gis2do);
  Maxd=Maxd(Gis2do,:);
  Botd=Botd(Gis2do);
  Nstat=length(Lati);ns=Nstat;
  distg =distance(Lati(1:ns-1),Long(1:ns-1),Lati(2:ns),Long(2:ns));
  iwrn=find(distg<2e4); %warning if too close stations
  distt = cumsum(distg);
  Npair = Nstat-1;
  ds = 1e-3 * [0; distt];          	% linear distance between stations
  dp = 1e-3 * [distt - 0.5 * distg];	% linear distance between pairs

figure(1)
  set(gcf,'position',[3   504   567   364]); clf
  plot(Long,Lati,'o',Long,Lati,'-')
  set(gca,'FontSize',8)
  grid on;xlabel('Longitude');ylabel('Latitude');
  %axis equal
  title([Secname ' - Use mouse for zoom'])
  
  %put the station number every 10 stations
  istt=[1 5*(1:fix(Nstat/5))]'; 
  if istt(length(istt))~=Nstat
    istt=[istt;Nstat];
  end
  tx=[];
  for ii=1:length(istt)
    tx=[tx;sprintf('%3i',istt(ii))];
  end  
  text(Long(istt),Lati(istt),tx,'fontsize',8)
  
  zoomrb
   
figure(2)
 set(gcf,'position',[3   256   676   242]);clf
 xd=0.51:Nstat-1;
 plot(distg/1e3,'o');grid on;
 set(gca,'FontSize',8)
 title('Distance between stations - use mouse for zoom')
 xlabel('pair number');ylabel('km - stars are < 20 km')
 hold on;plot(iwrn,distg(iwrn)/1e3,'r*')
 ca1=gca;
 set(gca,'Xlim',[1 ns])
 zoomrb

figure(3)
 set(gcf,'position',[ 3    10   674   240]);clf
 d1=-500*ceil(max(Botd)/500); %min(-Presctd)
 td=[0;cumsum(distg)];
 fill(([1;ns;(ns:-1:1)']), ...
   [d1;d1;-Botd(ns:-1:1)],[.9, .9, .9]);hold on;
 set(gca,'FontSize',8)
 xx=[];yy=[];
 for is = 1:ns
   yy=[yy;(1:Maxd(is,1))'];
   xx=[xx;is*ones(Maxd(is,1),1)];
 end
 plot(xx,-Presctd(yy),'.');
 title('Topography and stations - use mouse to zoom')
 axis([1 ns d1 0])
 xlabel('station number');ylabel('Depth (db)')
 zoomrb

 figure(2)
 figure(1)
 if 0
   suptitle('SELECT THE DESIRED STATIONS')
   
   hpop1 = uicontrol('style', 'radiobutton', 'Position', [0 330 100 30], ...
     'string', 'ACCEPT','tag','hpop1',...
     'ForeGroundColor', 'k',...
     'call', 'hpop1=findobj(gcf,''tag'',''hpop1''); exmen=get(hpop1,''value'');');
   hpop2 = uicontrol('style', 'radiobutton', 'Position', [0 300 100 30], ...
     'string', 'CHANGE','tag','hpop2', ...
     'ForeGroundColor', 'k',...
     'call','hpop2=findobj(gcf,''tag'',''hpop2'');staymen=get(hpop2,''value'');');
   %this curious 'tag' allows to use the menu inside a function
    
   exmen=0;staymen=0;
   while (exmen == 0)&(staymen==0)
     drawnow
   end
 else
   exmen=(input('Accept ? (y/n)', 's')=='y');
   staymen=~exmen;
 end
 if staymen
    Gis2do=input('Station indices ex: [1:10,13:14] : ');
 else
   if ~p_jd
     subsecname=input('Name for this section ? ','s');
   else
     subsecname=[];
   end
 end
 
end %on loop "while ~"exmen"

if 0
delete(hpop1,hpop2);
  figure(4);

set(gcf,'position',[500 800 150 140],'menubar','none','NumberTitle','off');
hpop1 = uicontrol('style', 'pushbutton', 'Position', [0 35 150 30], ...
      'string', 'PRINT FIGURE 1','tag','hpop1',...
      'ForeGroundColor', 'k',...
      'call', 'figure(1);print;figure(4)');
hpop2 = uicontrol('style', 'pushbutton', 'Position', [0 70 150 30], ...
      'string', 'PRINT FIGURE 2','tag','hpop1',...
      'ForeGroundColor', 'k',...
      'call', 'figure(2);print;figure(4)');
hpop3 = uicontrol('style', 'pushbutton', 'Position', [0 105 150 30], ...
      'string', 'PRINT FIGURE 3','tag','hpop1',...
      'ForeGroundColor', 'k',...
      'call', 'figure(3);print;figure(4)');
hpop4 = uicontrol('style', 'pushbutton', 'Position', [0 0 150 30], ...
      'string', 'CONTINUE','tag','hpop4',...
      'ForeGroundColor', 'k',...
      'call',...
      'hpop4=findobj(gcf,''tag'',''hpop4'');exmen=get(hpop4,''value'');');
exmen=0;
while (exmen == 0)
  drawnow
end
end %if 0
s=input('print figures ? (y/n) ', 's');
if s=='y'
  pg;close;pg;close;pg;close;
else
  close all  
end
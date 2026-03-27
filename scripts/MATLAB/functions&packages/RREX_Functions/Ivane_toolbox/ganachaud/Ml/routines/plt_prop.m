function plt_prop(prop, pname, punits, ...
    cruise, pres, maxd, botd, Slat, Slon, maxy, p_lab,gi2p,p_xax,p_keepscale)
% KEY: plot the topography and contour of the property (matlab 5)
% USAGE : plt_prop(prop, pname, punits, ...
%    cruise, pres, maxd, botd, Slat, Slon, maxy, p_lab,gi2p,p_xax)
%
% DESCRIPTION : 
%
% INPUT:
%   gi2p:        (for labeling) pair that are plotted here
%   p_xax='dist': distance on horiz axis (default)
%   p_xax='lon' : longitude -
%   p_xax='lat' : latitude
%
% OUTPUT:
%
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , Mar 97
%          based on plot_sprop.m by 
%          D. Spiegel (diana@plume.mit.edu) , Dec 95
%          A. Ganachaud Jul 97, extension to plot either station
%          or pair properties
%
% SIDE EFFECTS :
%
% SEE ALSO :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER: geovel or disp_sprop
% CALLEE: 
p_colorfill=1

  cla
  if ~exist('p_lab')
    p_lab=1;
  end
  if ~exist('p_xax')
    p_xax='dist';
  end
  if ~exist('gi2p')|isempty(gi2p)
    gi2p=1:length(Slon);
  elseif length(gi2p)==(length(Slon)-1)
    gi2p=[gi2p,max(gi2p)+1];
  elseif length(gi2p)~=length(Slon)
    error('problem in gi2p')
  end
  if ~exist('p_keepscale')
      p_keepscale=0;
  end
   Nstat=length(botd);
   cla
   np=length(pres);
   distg = 1e3*sw_dist(Slat,Slon,'km');
   distg(distg==0)=0.001;
   distt = cumsum(distg);
   tdist = 1e-3 * [0; distt];          	% linear distance between stations
   dpt = 1e-3 * (0.5*distg(1) + [1; cumsum(0.5*...
     (distg(1:Nstat-2)+distg(2:Nstat-1)))]);	
      % linear distance between pairs  

   ns = Nstat;
   d1 = min(-pres);
       
   global mi mx mxc mic
   
   if ~p_keepscale | isempty(mi)
       disp('defining scales based on min and max')
       mi = min(mmin(prop));
       mx = max(mmax(prop));
       mxc = max(50, 20*floor(mx/20));
       mic = min(-50, 20*ceil(mi/20));
   end

   [M,N]=size(prop);
   if N==Nstat
     isstat=1; %station properties
     hdist=tdist;
     statpairstr='Stat';
   elseif N==Nstat-1
     isstat=0; %pair properties
     hdist=dpt;
     statpairstr='Pair';
   else
     error('wrong property dimension')
   end

   switch p_xax
     case 'dist'
       haxx=tdist;
       xlab='Linear distance (km)';
       p_rev=0;
     case 'lon'
       haxx=Slon;
       p_rev=0;
       if N==Nstat
	 hdist=Slon;
       else
	 Slon=scan_longitude(Slon);
	 hdist=.5*(Slon(1:N)+Slon(2:N+1));
       end
       xlab='Longitude';
     case 'lat'
       haxx=Slat;
       p_rev=1;
       if N==Nstat
	 hdist=Slat;
       else
	 Slon=scan_longitude(Slon);
	 hdist=.5*(Slat(1:N)+Slat(2:N+1));
       end
       xlab='Latitude';
     otherwise
       error('problem')
     end
     %Sort haxx for fill plots
     if any(diff(haxx)<0)
       [haxx,gis]=sort(haxx);
       Slon=Slon(gis);
       Slat=Slat(gis);
       botd=botd(gis);
       gi2p=gi2p(gis);
       [hdist,gisp]=sort(hdist);
       tdist=NaN;
       maxd=maxd(gisp);
       prop=prop(:,gisp);
     end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % SET THE CONTOUR INTERVALS
   if strcmp(pname,'temp')|strcmp(pname,'theta')
     %vc1=-5:5:40;
     vc1=[14:2:40];
     if mminm(prop)<=5
       vc2=[-6:1:9]; %-0.5,0.5:0.5:3.5,4.5:0.5:
     else
       vc2=[-5:1:40];
     end
     vc2=[-6:1:13]; %-0.5,0.5:0.5:3.5,4.5:0.5:
     %vc2(vc2/5==round(vc2/5))=[];
     %vc3=-5:0.2:5;
     %vc3(vc3==round(vc3))=[];
     caxx=[1 30];
   elseif strcmp(pname,'vel')
     vc2=[1:1:9];           
     vc1=[0:10:(10+mmaxm(abs(prop)))];          
     vc1=[-reverse(vc1(2:length(vc1))),vc1];
     vc2=[-reverse(vc2),vc2];
     mxv=mmaxm(abs(prop));
     miv=mminm(abs(prop));
   elseif strcmp(pname,'sali')
     %vc1=30:1:40;
     vc1=[30,40];
     %vc2=[30:0.1:40];
     vc2=[30:0.2:40];
     %vc2((vc2)==round(vc2))=[];
     %vc3=30:0.02:35.1;
     %vc3(abs((10*vc3)-round(10*vc3))<1e-6)=[];
     caxx=[34 36];
   elseif strcmp(pname,'oxyg')
     if ~strcmp(punits,'ml/l')
       error('oxygen has to be in ml/l for plotting')
     else
       vc1=1:1:20;
       vc2=[1:.5:20];
       inot=find((vc2)==fix(vc2));
       vc2(inot)=[];
       vc3=5:0.25:20;
       vc3(2*vc3==round(2*vc3))=[];
     end
   elseif strcmp(pname,'pden')
     vc1=20:1:30;
     vc2=[27:0.1:30];
     inot=find((vc2)==fix(vc2));
     vc2(inot)=[];
     vc3=27.8:0.01:30;
     inot=find((10*vc3)==fix(10*vc3));
     vc3(inot)=[];
   elseif strcmp(pname,'psr')
     vc1=[];
     vc2=[0.03:0.03:0.15,0.2:0.05:0.5];
     %vc2(vc2/0.5==fix(vc2/0.5))=[];
     caxx=([0.08 0.3]);
   elseif strcmp(pname,'phos')
     vc1=0:0.5:10;
     vc2=[0:0.1:10];
     vc2(2*vc2==fix(2*vc2))=[];
     %vc3=1:0.1:10;
     %vc3((5*vc3==round(5*vc3)) | (2*vc3==round(2*vc3)))=[];
   elseif strcmp(pname,'sili')
     vc1=0:10:200;
     vc2=[5:10:200];
     vc3=0:2:10;
     vc3(vc3/5==round(vc3/5))=[];
   elseif strcmp(pname,'nita')
     vc1=0:5:50;
     vc2=[15:2.5:50];
     vc2((vc2/5)==fix(vc2/5))=[];
   elseif strcmp(pname,'no3')
     vc1=5:50;
     vc2=[0.02,0.05,0.1,0.25:0.25:5];
     %vc1=[0.25:0.25:5];
     caxx=([0.05 1.5]);
   elseif strcmp(pname,'no2')
     %vc1=0:0.5:50;
     %vc2=[0:0.02:0.5];
     %vc2((vc2/.5)==fix(vc2/.5))=[];
     vc2=[0.02,0.05,0.1,0.15,0.25:0.25:5];
     vc1=[5:10];
     caxx=([0.05 2]);
   elseif strcmp(pname,'nh4')
     vc1=[];
     vc2=[0.02,0.05:0.05:0.2];
     %vc2((vc2/.05)==fix(vc2/.05))=[];
     caxx=([0.05 .18]);
   elseif strcmp(pname,'chla')
     vc1=[];
     vc2=[0.05:0.05:0.5];
     %vc2(vc2/0.5==fix(vc2/0.5))=[];
     caxx=([0.05 .5]);
   elseif strcmp(pname,'chla10')
     vc1=[];
     vc2=[0:5:100]
       %vc1=[0.1,10];
     %vc2=[0.01,0.02:0.02:0.1];
     %vc2(vc2/0.5==fix(vc2/0.5))=[];
     caxx=([2 25]);
   elseif strcmp(pname,'pheo')
     vc1=[];
     vc2=[0.02,0.05:0.05:0.5];
     %vc2(vc2/0.5==fix(vc2/0.5))=[];
     caxx=([0.02 .3]);
   elseif strcmp(pname,'po38')
     vc1=0:25:1000;
     vc2=[430:10:440,460:10:470,480:490,510:520];
   elseif strcmp(pname,'dynh')
     vc1=0:0.5:20;
     vc2=[0.25:0.5:20];
   elseif strcmp(pname,'tcarbn') | strcmp(pname,'alkali') 
     vc1=1800:20:2500;
     vc2=[2240:5:2500];
     inot=find((vc2/20)==fix(vc2/20));
     vc2(inot)=[];
   elseif strcmp(pname,'bfrq') 
     vc1=1e-4*[-0.2:0.2:10];
     vc2=1e-4*[-0.2:.05:.2];
     inot=find((vc2/10)==fix(vc2/4));
     vc2(inot)=[];
     vc3=1e-4*[-0.2:.01:.04];
     vc3(vc3/5==round(vc3/5))=[];
  else
     error(['do not know which contour to take for ' pname])
   end  

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % FILL NEGATIVE VALUES
   if ~isempty(find(prop(isnan(prop))<0));
     % Fill negative contours
     [cs, h,cf] = contourf(hdist, -pres, prop, [-1000 0]);
     cn = .9*[1 1 1];
     for i = 1:length(h)
       if get(h(i), 'CData') < 0
	 set(h(i), 'FaceColor', cn,'linestyle','none')
       else
	 set(h(i), 'FaceColor', 'w','linestyle','none')
       end
     end
     hold on;drawnow
   end
   
   set(gca, 'Ylim', [ d1, 0])   
    
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Plot contours
   if 1|strcmp(pname,'vel')
     lst1='-';
     lwd1=.5;
     lst2='-';
     lwd2=.1;
   else
     lst1='-';
     lwd1=1.5;
     lst2='-.';
     lwd2=.5;
   end
   if p_colorfill
       %caxis=[mminm(prop) mmaxm(prop)];
       ccontours=sort([vc1,vc2]);
       ccontours=ccontours(find(ccontours>=caxx(1)));
       ccontours=ccontours(find(ccontours<=caxx(2)));
       contourf(hdist, -pres, prop,ccontours);
       caxis(caxx);
       shading flat;hold on
   end %if p_colorfill

   if any((vc1>mminm(prop))&(vc1<mmaxm(prop)))
     [cs, h1] = contour(hdist, -pres, prop,vc1,'k');
     set(h1,'linestyle',lst1,'linewidth',lwd1)
     H=clabel(cs,h1);
     set(H,'fontsize', 8);drawnow
   end
   
   if any((vc2>mminm(prop))&(vc2<mmaxm(prop)))
     hold on
     [cs1, h2] = contour(hdist, -pres, prop,vc2,'k');
     set(h2,'linestyle',lst2,'linewidth',lwd2)
     H1=clabel(cs1,h2);
     set(H1,'fontsize', 8);drawnow
   else
     error('CONTOUR INTERVALS INADAPTED')
   end
   
   if exist('vc3')
     if any((vc3>mminm(prop))&(vc3<mmaxm(prop)))
       hold on
       [cs1, h1] = contour(hdist, -pres, prop,vc3,'g--');
       set(h1,'linewidth',.1)
       %H1=clabel(cs1,h1);
       %set(H1,'fontsize', 8);drawnow
     else
       %error('CONTOUR INTERVALS INADAPTED')
     end
   end

   if exist('maxy')&~isempty(maxy)
     set(gca,'ylim',[-abs(maxy),0])
   else
     ax=axis;
     maxy=ax(3);
   end
   gca1=gca;
    
   %Plot bottom topography
   %if p_lab
   %  plot(haxx, -pres(maxd), '.');
   %end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Print ylabel, Yticklabels
   % set yticks at the standard depths
   % and put only some labels
   set(gca,'Xlim', [min(haxx) max(haxx)]);
   set(gca,'TickDir','out')
   if p_rev
     set(gca,'xdir','reverse')
   end
   if p_lab %& strcmp(p_xax,'dist')
       %Put a second axes at the top
       ax2=axes('position',get(gca1,'Position'),...
           'xaxislocation','top','yaxislocation','right',...
           'color','none','xcolor','k','ycolor','k',...
           'TickDir','out','TickLength',.5*[0.01 0.025],...
           'Xlim', [haxx(1) haxx(ns)],'Xtick',haxx,...
           'ylim',[-abs(maxy),0],'Ytick', flipud(-pres),...
           'XTickLabel','','YTickLabel','');
       if p_rev
           set(gca,'xdir','reverse')
       end
       nstatick=1;
       if 0 %put station number every nstatick station
           str=sprintf('%3i',(1:length(haxx)));
           str=reshape(str,3,length(haxx))';
           for il=2:length(haxx)
               if (il/nstatick)~=round(il/nstatick)
                   str(il,:)='   ';
               end
           end
           set(gca,'XTickLabel',str,'FontSize',6)
       else
           str=sprintf('%3i',gi2p);
           str=reshape(str,3,length(haxx))';
           for il=2:length(haxx)
               if (gi2p(il)/nstatick)~=round(gi2p(il)/nstatick)
                   str(il,:)='   ';
               end
           end
           set(gca,'XTickLabel',str,'FontSize',6)
       end
       %ylabel('standard depths')
       %iynlab=find(pres~=250*round(pres/250));
       %ylab = [];
       %for ii = 1:max(find(pres<=maxy))
       %  ylab = str2mat(ylab, sprintf('%5i', pres(ii)));
       %end
       %ylab = ylab(2:length(ylab), :);
       %for ii = 1:length(iynlab)
       %  ylab(iynlab(ii), :) = '     ';
       %end
       %set(ax2, 'Yticklabel', flipud(ylab))
       %ylabel('Standard Depth')
       hold on;

       % To improve visual effect of contours
       % extend bottom values of prop down to depth 37
       if 0
           for istat = 1:ns-1
               for idepth = Maxd(istat, 1):37
                   prop(idepth, istat) = prop(Maxd(istat, 1), istat);
               end
           end
       end
   end %p_lab

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %Print xlabel, title
   axes(gca1);set(gca1,'box','on')
   xlabel(xlab);
   title(sprintf('%s - contours from %4.1f to %3.1f %s ', ...
     pname, mi, mx, punits))
   tp=get(get(gca,'title'),'position');
   yl=get(gca,'ylim');dy=abs(diff(yl));
   set(get(gca,'title'),'position',[tp(1),tp(2)*2,tp(3)])
   hfill1=fill([min(haxx); max(haxx); haxx(ns:-1:1)], ...
     [-abs(maxy); -abs(maxy);  -botd(ns:-1:1)], .9*[1 1 1]);
   hfill2=fill([min(haxx); max(haxx); haxx(ns:-1:1)], ...
     [-abs(maxy); -abs(maxy);  -botd(ns:-1:1)], .9*[1 1 1]);
   hfill3=fill([min(haxx); max(haxx); haxx(ns:-1:1)], ...
     [-abs(maxy); -abs(maxy);  -botd(ns:-1:1)], .9*[1 1 1]);
   hfill=fill([min(haxx); max(haxx); haxx(ns:-1:1)], ...
     [-abs(maxy); -abs(maxy);  -botd(ns:-1:1)], .9*[1 1 1]);
   hold on;
   
   if p_lab &0
     % Label and Timestamp plot
     axes('position',[0 0 1 1])
     axis off
     Label = sprintf('Cruise: %s   %s Property: %s   \n',cruise,...
       statpairstr,pname);
     text(.2,.03,Label)
     Time = sprintf('    %i/%i/%i -  %i:%i:%i',fix(clock));
     text(.9,.025,date,'fontsize',6)
   end

   %if exist('ax2')
   %  axes(ax2);
   %end
   axes(gca1)
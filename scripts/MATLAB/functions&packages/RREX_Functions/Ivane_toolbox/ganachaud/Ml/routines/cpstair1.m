function cpstair1(win,x,y,xax,xlab,ylab,tit,lab,mkm,tx,c,fname,force,...
			ylmin,dx,p_posterplot)
% KEY: do a stair plot of x,y (horizontal stairs)
% USAGE :
% 
% DESCRIPTION : 
%
%
% INPUT: win     window number
%        x,y     field to plot
%        xax     x axis, optional
%        xlab    xlabel
%        ylab    ylabel
%        tit     title
%        lab     label for each layer interface (excluding 1st and last)
%        mkm     1 for .eps file
%        tx      1 if put label for each layer interface 
%        c       color, 'n' for black and white
%        fname   post-script file name (eps)
%        force   1-> if does the post-script after the plot
%                0-> does it only if win==6
%        ylmin   y axis lower limit
%        dx      x uncertainty(optional)
%        p_posterplot: special configuration for the posterplot
%                =1: do small plots
%                =2: do large plots
%                =3: do publication plots (3*3)
%
% OUTPUT:
%
% AUTHOR :  A. Macdonald 
% UPDATES : A.Ganachaud (ganacho@gulf.mit.edu) , Aug 96
%
% SIDE EFFECTS :
%
% SEE ALSO :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER: general purpose / trans_plot.m
% CALLEE:
if ~exist('dx')
  dx=[];
end
curfig=gcf;
set(curfig,'PaperUnits','normalized')
set(curfig,'PaperOrientation','portrait')
if exist('p_posterplot')&p_posterplot
  w=0.2;
  ax=0.25;
  axx=0.65;
  ay=0.1;
  dy=0.31;
  if p_posterplot==1
    labelfontsize=8;
    set(curfig,'PaperPosition',1.7/4.1*[.3+0.03,.3+0.08,0.94,0.88])
    h=0.18;
  elseif p_posterplot==2
    h=0.22;
    labelfontsize=10;
    set(curfig,'PaperPosition',[0.03,0.08,0.94,0.88])
  elseif p_posterplot==3
    h=0.22;
    labelfontsize=10;
    set(curfig,'PaperPosition',[0.05,0.08,0.94,0.88])
    nwindows=9;
    w=0.2;
    ax=0.05;
    axx=0.35;
    axxx=0.65;
    ay=0.1;
    dy=0.31;
  end  
else
  p_posterplot=0;
  labelfontsize=8;
  set(curfig,'PaperPosition',[0.03,0.08,0.94,0.88])
  w=0.2;
  h=0.22;
  ax=0.25;
  axx=0.65;
  ay=0.1;
  dy=0.31;
end

if p_posterplot==3 %3*3 plot
  if (win == 1)
    px=ax;
    py=ay+2*dy;
  elseif (win == 2)
    px=axx;
    py=ay+2*dy;
  elseif (win == 3)
    px=axxx;
    py=ay+2*dy;
  elseif (win == 4)
    px=ax;
    py=ay+dy;
  elseif (win == 5)
    px=axx;
    py=ay+dy;
  elseif (win == 6)
    px=axxx;
    py=ay+dy;
  elseif (win == 7)
    px=ax;
    py=ay;
  elseif (win == 8)
    px=axx;
    py=ay;
  elseif (win == 9)
    px=axxx;
    py=ay;
  else
    error('invalid window number (win)')
  end
else %p_posterplot~=3; 3*2 plot 
  if (win == 1)
    px=ax;
    py=ay+2*dy;
  elseif (win == 2)
    px=axx;
    py=ay+2*dy;
  elseif (win == 3)
    px=ax;
    py=ay+dy;
  elseif (win == 4)
    px=axx;
    py=ay+dy;
  elseif (win == 5)
    px=ax;
    py=ay;
  elseif (win == 6)
    px=axx;
    py=ay;
  else
    error('invalid window number (win)')
  end
end
  
%	disp('win px py')
%	disp([win,px,py,w,h])
y=abs(y);
ylmin=abs(ylmin);

[m,n]=size(x);
lim=2*(m-1);

[xx,yy]=flstairs(x,y);
if ~isempty(dx)
  [xu,yu]=flstairs(dx,y);
else
  xu=[];yu=[];
end
subplot('position',[px,py,w,h])
xxu=[xu;-xu];
yyu=[yu;yu];

if ( c ~= 'n') & isempty(dx)
  hdl=fill(xx,yy,c); axx=axis;
  set(hdl,'EdgeColor',c);
  hold on;plot(xxu,yyu,'linecolor',c);
else
  if isempty('c')|c=='n'
    c=get(gcf,'defaultlinecolor');
  end
  plot(xx,yy,'color',c); axx=axis;
  hold on;
  hdl=fill(xxu,yyu,min(1,.7+c));
  set(hdl,'EdgeColor',c,'LineWidth',.1);
  plot(xx,yy,'color',c);
  set(hdl,'LineStyle','none')
end
hold off
curax=gca;

if ( length(xax) > 0 )    % set the specified axes ticks
  set(curax,'XLim',[min(xax) max(xax)])
  %set(curax,'XTick',xax)
  def_xax=get(curax,'XTick');
else           % change the default axis ticks if they're not very good
  def_xax=get(curax,'XTick');
  def_xax=fixaxes(def_xax,5);
  %set(curax,'XTick',def_xax)
end
set(curax,'YLim',[ 0 ylmin])
set(curax,'YTick',[0:1000:ylmin])
set(curax,'Ydir','rev')

% I used c before, because it looks good in colour
%set(curax,'ycolor','w')
%set(curax,'xcolor','w')
%	set(curax,'ycolor','k')
%	set(curax,'xcolor','k')
set(curax,'FontSize',labelfontsize,'FontWeight','light','ydir','reverse');
%	set(get(gca,'Title'),'Color','y')
set(get(gca,'Title'),'FontSize',labelfontsize)
%	set(get(gca,'Xlabel'),'Color','y')
set(get(gca,'Xlabel'),'FontSize',labelfontsize)
%	set(get(gca,'Ylabel'),'Color','y')
set(get(gca,'Ylabel'),'FontSize',labelfontsize)
if ~isempty(tit)&strcmp(tit(1:3),'OUR')
  title(tit,'fontsize',ceil(labelfontsize*1.2),'interpreter','tex');
else
  title(tit,'fontsize',ceil(labelfontsize*1.2),'interpreter','tex');
end
xlabel(xlab,'fontsize',ceil(labelfontsize*1.2))
ylabel(ylab);
grid on

%       This doesn't seem to work unless xax is set
x_coords=axx(1:2); %get(curax,'Xlim');%before uncertainty plot

% update to fix text positioning 
% changed by Alex, Aug96 to avoid stairs going out from the graph
xxmax=find(def_xax <= x_coords(2));
if(isempty(xxmax))
  %set(curax,'xlim',[x_coords(1) x_coords(2)])
  %xtxpos=x_coords(2);
else
  %set(curax,'xlim',[x_coords(1) def_xax(max(xxmax))])
  %xtxpos=def_xax(max(xxmax));
end
xtxpos=x_coords(2);

if 0	% experiment A.Ganachaud 05/04/95 : results: no improvement
  yprev=160;% previous text position
  for i=1:m-1
    if ( tx ~= 0 )
      % if ( abs(y(i) - y(i+1)) < 100 )
      % if(abs(y(i) - y(i-1)
      %	yp=y(i)-100;
      % else
      % yp=y(i+1);
      % end
      % h=text(xtxpos,yp,num2str(lab(i)));
      % set(h,'FontSize',6,'FontWeight','light');
      
      %	disp([i,yprev,y(i+1) yprev-y(i+1)])
      if ( yprev - y(i+1) >= 160 )
	yp=y(i+1);
      else
	yp=yprev-160;
	disp(['Moving ',num2str(lab(i))])
      end
      h=text(xtxpos,yp,num2str(lab(i)), ...
	'FontSize',4,'FontWeight','light');
      % set(h,'FontSize',4,'FontWeight','light');
      yprev=yp;
    end
  end
else
  if ~isempty(lab)
    yprev=160;% 			previous text position
    yp=zeros(m-1,1);
    xp=zeros(m-1,1);
    labstr=[];drawnow
    aaxx=get(gca,'xlim');
    xtxpos=aaxx(2);
    for i=1:m-1
      if ( tx ~= 0 )
	if ( yprev - y(i+1) <= 160 )
	  yp(i)=y(i+1);
	else
	  yp(i)=yprev-160;
	  %disp(['Moving ',num2str(lab(i))])
	end
	xp(i)=xtxpos;
	labstr=str2mat(labstr,num2str(lab(i)));
	yprev=yp(i);
      end
    end
    labstr=labstr(2:m,:);
    if m>1 %labstr has been created
      text(xp,yp,labstr, ...
	'FontSize',labelfontsize*.6,'FontWeight','light');
    end
  end %if ~isempty(lab)
end

set(curax,'FontSize',labelfontsize,'FontWeight','light')

if (win == 1 )
  hx=axis;
  hypos= hx(4);
  hxpos= hx(1)-(hx(2)-hx(1));
  % h=text(hxpos,hypos,datetime);
  % set(h,'FontSize',labelfontsize,'FontName','Palatino','FontAngle','italic')
end

if (  win ==  6 | force == 1)
  if ( mkm ~= 0 )
    if ( c == 'n' )
      g=['print ',fname,' -deps'];
    else
      g=['print ',fname,' -depsc'];
    end
    disp(['plotting: ',g])
    eval(g)
  end
end

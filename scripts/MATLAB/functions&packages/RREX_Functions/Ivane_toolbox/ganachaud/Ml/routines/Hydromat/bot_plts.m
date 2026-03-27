function  bot_plts(bot,varn, units)
%function  bot_plts(bottle_dat,variable_names, units)
%
% Opens a GUI control panel for constructing property-property plots from
% bottle data.  User can control property assigned to the x-axis, y-axis as
% well as color-axis.  User can also limit range of every variable.
%
%  INPUTS
%     bottle_dat - array of bottle data: each column is a property and each
%                  row is one suite of bottle measurements
%     variable_names  - (opt) a string array of the property labels for
%                   each column of bottle_dat
%     units - (opt) a string array of labels specifying the units for each
%                    variable name
%                    
%this can be slow depending on X-server and may still have some bugs....
%   
%   Paul E Robbins, copywrite 1995.
dontuse = str2mat('CASTNO','SAMPNO','BTLNBR','CTDRAW');  

if nargin < 2
  varn = '1';
  for v = 1:size(bot,2);
    varn = str2mat(varn,num2str(v));
  end
end
if nargin < 3
  units = blanks(size(bot,2))';
end

%get rid of columns specifed not to be used
for i = 1:size(dontuse,1);
  for j = 1:size(bot,2);
    if strcmp(varn(j,:),dontuse(i,:))
      bot(:,j) = [];
      varn(j,:) = [];
      units(j,:) = [];
      break
    end
  end
end
    
clear uselim numcolors
numcolors = 10;
xedge = 10; x1 = xedge;
yedge = 28;
width = 30;
avwidth = 7; % actually 6.8886 +/- 0.4887
height = 26;
maxlen = size(varn,2);
twidth = 1.2*maxlen*avwidth*1.5;

mwwidth = 5*(twidth + width + 2*xedge);
mwheight = (size(varn,1)+5)*yedge;

x2 = 2*x1+width+twidth;
x3 = 3*x1+2*(width+twidth);
x4 = 4*x1+3*(width+twidth);
x5 = 5*x1+4*(width+twidth);

rect = [10 10 mwwidth mwheight];
fig = figure('Position',rect,'number','off','name',' Plot Control ');
set(gca,'Position',[0 0 1 1]); axis off;

t = text(x1,mwheight-yedge*4,'X-AXIS','units','pixels');
t = text(x2,mwheight-yedge*4,'Y-AXIS','units','pixels');
t = text(x3,mwheight-yedge*4,'COLOR','units','pixels');
t = text(x4,mwheight-yedge*4,'LIMIT RANGE','units','pixels');
t = text(x5,mwheight-yedge*4,'MINIM','units','pixels');
t = text(x5+60,mwheight-yedge*4,'MAXIM','units','pixels');


clear h1 h2 h3 h4 h5 h6 h7 uselim
global IX IY ii h1 h2 h3 h4 h5 h6 h7 uselim ID IQ IC numcolors
for ii = 1:size(varn,1)
    h1(ii) = uicontrol('position',[x1  (ii-.5)*yedge width+twidth height]);
    set(h1(ii),'callback',['global IX h1 ii; IX=',int2str(ii),...
	    ';set(h1(1:length(h1)~=',int2str(ii),'),''value'',0);' ]);
    set(h1(ii),'string',['  ', varn(ii,:)],'HorizontalAlignment','left');
    set(h1(ii),'style','radio');
    
    h2(ii) = uicontrol('position',[x2  (ii-.5)*yedge width+twidth height]);
    set(h2(ii),'callback',['global IY h2 ii;IY=',int2str(ii),...
	    ';set(h2(1:length(h2)~=',int2str(ii),'),''value'',0);' ]);
    set(h2(ii),'string',['  ', varn(ii,:)],'HorizontalAlignment','left');
    set(h2(ii),'style','radio');
    
    h3(ii) = uicontrol('position',[x3  (ii-.5)*yedge width+twidth height]);
    set(h3(ii),'callback',['global IC h3 ii; IC=',int2str(ii),...
	    ';set(h3(1:length(h3)~=',int2str(ii),'),''value'',0);' ]);
    set(h3(ii),'string',['  ', varn(ii,:)],'HorizontalAlignment','left');
    set(h3(ii),'style','radio');

    h5(ii) = uicontrol('position',[x4  (ii-.5)*yedge width+twidth height]);
    uselim(ii) = 0;
    set(h5(ii),'callback',['global uselim ii; uselim(',int2str(ii),')=~uselim(',...
	    int2str(ii),');']);
    set(h5(ii),'string',['  ', varn(ii,:)],'HorizontalAlignment','left');
    set(h5(ii),'style','check')
  
    h6(ii) = uicontrol('position',[x5  (ii-.5)*yedge 60 height]);  
    set(h6(ii),'style','edit','visible','off')
    set(h6(ii),'string',num2str(min(bot(~isnan(bot(:,ii)),ii))));
    
    h7(ii) = uicontrol('position',[x5+70  (ii-.5)*yedge 60 height]);  
    set(h7(ii),'style','edit','visible','off')
    set(h7(ii),'string',num2str(max(bot(~isnan(bot(:,ii)),ii))));
end

h10 = uicontrol('position',[x1 mwheight-yedge*1.5 width+twidth height]);
set(h10,'string','QUIT','HorizontalAlignment','center','callback',...
    ['global IQ; IQ=1;']);

h11 = uicontrol('position',[x1 mwheight-yedge*2.5 width+twidth height]);
set(h11,'string','DRAW','HorizontalAlignment','center','callback',...
    ['global ID; ID=1;']);

h12 = uicontrol('position',[x2 mwheight-yedge*1.5 width+twidth height]);
set(h12,'string','PRINT','HorizontalAlignment','center','callback',...
    ['figure(2);print']);

h13 = uicontrol('position',[x2 mwheight-yedge*2.5 width+twidth height]);
set(h13,'string','FPRINT','HorizontalAlignment','center','callback',...
    ['figure(2);fprint;']);

global h20 h21
h20 = uicontrol('position',[x3 mwheight-yedge*2.5 width+twidth height]);
set(h20,'style','text','string',num2str(numcolors))

h21= uicontrol('position',[x4,mwheight-yedge*2.5 2*width+twidth height]);
set(h21,'style','slider','min',2,'max',20,'value',numcolors)
set(h21,'callback',['global h20 h21 numcolors;numcolors=round(get(h21,''value''));',...
	'set(h20,''string'',num2str(numcolors));'])

t = text(x3,mwheight-yedge*1.2,'NUMBER OF COLORS','units','pixels');

IQ = 0; ID = 0; 
IX = 0; IY = 0; IC = 0;

while IQ ==0

  
  while  IQ == 0 & ID == 0 | IY == 0 | IX == 0
    drawnow;
    if any(uselim)
      set(h6(uselim),'visible','on'); set(h7(uselim),'visible','on');
    end
    if any(~uselim)
      set(h6(~uselim),'visible','off');set(h7(~uselim),'visible','off');
    end
  end
  
  ID = 0; 
  if any(uselim)
    fs = 0*ones(size(bot(:,1)));
    for ul = find(uselim)
      fs = (bot(:,ul) >=  str2num(get(h6(ul),'string'))... 
	  & bot(:,ul) <= str2num(get(h7(ul),'string'))) | fs;

    end      
  else
    fs = ones(size(bot(:,1)));
  end
  if IQ ~=1
    figure(2);  clf
    if IC ==0;
      plot(bot(fs,IX),bot(fs,IY),'x','markersize',6)
    else
      caxis = hsv(numcolors); ticklabels = [];
      vc = bot(fs,IC);
      v1 = min(vc(~isnan(vc)));
      v2 = max(vc(~isnan(vc)));      
      vs = (v2-v1)/(numcolors);
      
      
      for c = 0:numcolors-1
	fc = bot(:,IC) >= v1+c*vs & bot(:,IC) < v1+(c+1)*vs;
	h = plot(bot(fs&fc,IX),bot(fs&fc,IY),'.',....
	    'color',caxis(c+1,:),'markersize',14);
	hold on
	ticklabels = str2mat(ticklabels,num2str(v1+(c+1)*vs));
      end
      hold off
      ticklabels = ticklabels(2:numcolors+1,:);
      
      colormap(hsv(numcolors))
      hc= colorbar('horiz');
      set(hc,'xtick',[1/2/(numcolors-1):1/(numcolors-1):1-1/2/numcolors])
      set(hc,'xticklabels',ticklabels)
      set(get(hc,'xlabel'),'string',[varn(IC,:),' (',units(IC,:),')'])
    end
    ylabel([varn(IY,:),' (',units(IY,:),')'])
    xlabel([varn(IX,:),' (',units(IX,:),')'])
  end
end
close; close
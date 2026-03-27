function leg=legende(ltext,linetype,sztxt,ly,lx)
%key: write a legend on the current graphic (gca)
%synopsis : leg=legende(ltext,linetype,sztxt,ly,lx)
%
% leg:    objects handles of the legend
% ltext    = string - the legend
% linetype (optional) = '-' '.' ':' etc; default is '-'
% sztxt    (optional) = text size;	 default is 10
% lx, ly   (optional) = location of the legend; default is defined 
%	further by 'aspect ratio'
% WARNING:  any optional parameter has to be precised if one wants
%	to set an argument that comes after
%	legende(ltext,linetype,lx) is not possible, one has
%	 to set sztxt before setting lx
% 
%description : 
%
%
%
%
%uses :
%
%side effects : see the Warning
%		if several attempts are made to ajust some parameter
%		using the default "ly", one should do
%		"clear global Mylastfigure" between two attempts
%
%author : A.Ganachaud, Apr 95
%
%see also :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% aspect ratio:
ab=	0.75;	% line begin
aw=	0.04;	% line width
ah=	0.93;	% default first line height
adh=	0.06;	% default delta y between two legends

legp=zeros(2,1);

global Mylastfigure Mylastytext
if Mylastfigure
  if Mylastfigure == gca 	%we are in the same figure than before
    ah=Mylastytext-adh;		%y position of the text shifts down by adh
  end
end

Mylastfigure=gca;

ax=get(gca,'Xlim');
xmin=ax(1);
dx=ax(2)-ax(1);
ay=get(gca,'Ylim');
ymin=ay(1);
dy=ay(2)-ay(1);

if ~exist('sztext')
  sztxt=10;
end

if ~exist('linetype')
  linetype='-';
end

if ~exist('ly')		%defaut ly set
  ly=ah*dy+ymin;
  Mylastytext=ah;
else
  Mylastytext=(ly-ymin)./dy;
end

if ~exist('lx')		%defaut lx set
  lx=ab*dx+xmin;
end

line_x=[lx:aw*dx./2:lx+aw*dx];
line_y=[ly,ly,ly];
hold on
legp(1)=plot(line_x,line_y,linetype);
hold off

legp(2)=text(line_x(3)+0.01*dx,line_y(3),ltext,'FontSize',sztxt,'fontName','Times', ...
	 'VerticalAlignment','middle');
       
if nargout==1
  leg=legp;
end
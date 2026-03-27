function hout=signature(str)
% SIGNATURE  Puts a text at position POSIT
%
%	signatrue('text') adds text to the position under the  the figure
%	below all subplots.
%	THERE is a default string specified right below.
%
% NOTE: second argument is passed on for consistency with previous
% usage of this routine, see signtex.m.old, it's irrelevant.
% 
% Drea Thomas 6/15/95 drea@mathworks.com
% Modified a bit by Michael Chechelnitsky on 03/01/97
% SET DEFAULT STRING
if nargin<1;name='';
time = clock;
cstr = num2str(time(5));
if length(cstr)==1, cstr = ['0' cstr]; end  % Add '0' for minutes
d = date;
if 0, d = [d ', ' num2str(time(4)) ':' cstr]; end

logodflt = 'MIT-WHOI Joint Program';          % "Logo" default
logodflt = '';          % "Logo" default

str = [name '  ' logodflt d];
end

% Warning: If the figure or axis units are non-default, this
% will break.

% Parameters used to position the supertitle.

% Amount of the figure window devoted to subplots
plotregion = .92;

% Y position of title in normalized coordinates
titleypos  = .02;
% X position of title in normalized coordinates
positionX  = .95;

% Fontsize for supertitle
fs = get(gcf,'defaultaxesfontsize')-3;

% Fudge factor to adjust y spacing between subplots
fudge=1;

haold = gca;
figunits = get(gcf,'units');

% Get the (approximate) difference between full height (plot + title
% + xlabel) and bounding rectangle.

	if (~strcmp(figunits,'pixels')),
		set(gcf,'units','pixels');
		pos = get(gcf,'position');
		set(gcf,'units',figunits);
	else,
		pos = get(gcf,'position');
	end
	ff = (fs-4)*1.27*5/pos(4)*fudge;

        % The 5 here reflects about 3 characters of height below
        % an axis and 2 above. 1.27 is pixels per point.

% Determine the bounding rectange for all the plots

% h = findobj('Type','axes');   
h = findobj(gcf,'Type','axes');  % Change suggested by Stacy J. Hills

max_y=0;
min_y=1;

oldtitle =0;
for i=1:length(h),
	if (~strcmp(get(h(i),'Tag'),'suptitle')),
		pos=get(h(i),'pos');
		if (pos(2) < min_y), min_y=pos(2)-ff/5*3;end;
		if (pos(4)+pos(2) > max_y), max_y=pos(4)+pos(2)+ff/5*2;end;
	else,
		oldtitle = h(i);
	end
end

if max_y > plotregion,
	scale = (plotregion-min_y)/(max_y-min_y);
	for i=1:length(h),
		pos = get(h(i),'position');
		pos(2) = (pos(2)-min_y)*scale+min_y;
		pos(4) = pos(4)*scale-(1-scale)*ff/5*3;
		set(h(i),'position',pos);
	end
end

np = get(gcf,'nextplot');
set(gcf,'nextplot','add');

if ~exist('deleteoldtitle'),deleteoldtitle=0;end
if (oldtitle) & deleteoldtitle,

	delete(oldtitle);
end
ha=axes('pos',[0 1 1 1],'visible','off','Tag','suptitle');
ht=text(positionX,titleypos-1,str);set(ht,'horizontalalignment','right','fontsize',fs);

set(gcf,'nextplot',np);
axes(haold);
if nargout,
	hout=ht;
end




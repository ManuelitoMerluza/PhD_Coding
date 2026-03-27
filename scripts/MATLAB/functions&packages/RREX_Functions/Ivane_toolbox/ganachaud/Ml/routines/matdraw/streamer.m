function handle = streamer(fig,TitleString)
%  STREAMER  Titles for an entire figure.
% 	     STREAMER('text') adds text at the top of the current figure,
% 	     going across subplots.
%        STREAMER(fig,'text') adds it to the specified figure.
% 
% 	     See also XLABEL, YLABEL, ZLABEL, TEXT, TITLE.
%
%	Keith Rogers 11/30/93

% Copyright (c) by Keith Rogers 1995

% 
% Mods:
%	11/94 adapted to 4.2
%   06/95 clean up, added alternate figure option.

if(nargin<2)
	TitleString = fig;
	fig = gcf;
end
ax = gca;
sibs = get(fig, 'Children');
for i = 1:max(size(sibs))
	if(strcmp(get(sibs(i),'Type'),'axes'))
		sibpos = get(sibs(i),'Position');
		if(strcmp(get(sibs(i),'Tag'),'Streamer'))
				StreamerHand = sibs(i);
		end
	end
end
if (StreamerHand == [])
	figure(fig);
	StreamerHand = axes('position',[.1 .9 .8 .05],...
						'Box','off',...
						'Visible','off',...
						'Tag','Streamer');
	set(get(gca,'Title'),'Visible','On');
else
	axes(StreamerHand);
end
title(TitleString);
axes(ax);


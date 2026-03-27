function [files,pathname]=load_fic(dialog,mask,pathname)


if nargin < 3
  pathname='./';
end

if nargin < 2
  mask='*';
end


if nargin < 1
  dialog='Chargement d''un fichier';
end

files=[];
ff=dir([pathname,mask]);

for ix=1:length(ff)
  files=strvcat(files,ff(ix).name);
end

files=sortrows(files);

figpos=[360 444 300 400];
h=figure('Name',dialog,...
         'NumberTitle','off',...
         'MenuBar','none',...
         'Position',figpos);

hreplabel=uicontrol('Style','Text',...
             'String','Repertoire ',...
	     'FontSize',12, ...
	     'BackgroundColor',get(gcf,'Color'), ...
             'HorizontalAlignment','left', ...
             'Position',[20 370 100 20]);

hrep=uicontrol('Style','Edit',...
             'String',pathname,...
	     'FontSize',12, ...
             'HorizontalAlignment','left', ...
             'Position',[20 340 230 20]);

hl=uicontrol('Style','ListBox',...
             'String',files,...
	     'FontSize',12, ...
             'Position',[20 60 260 250],...
             'Min',0, 'Max',1 );

hbok=uicontrol('Style','PushButton',...
	        'FontSize',12, ...
                'String','Ok',...
                 'Position',[20 20 60 22],...
                'CallBack','uiresume');

hbcanc=uicontrol('Style','Pushbutton',...
	         'FontSize',12, ...
                 'String','Annuler',...
                 'Position',[220 20 60 22],...
                 'CallBack','uiresume');


set(gcf,'Units','normalized');
set(get(gcf,'Children'),'Units','normalized');

uiwait;

h=get(gcf,'CurrentObject');
action=get(h,'String')

if strcmp(action,'Ok')
  str=get(hl,'String')
  val=get(hl,'Value')
  files=str(val,:)
else
  files=0;
  pathname=0;
end

close(gcf);


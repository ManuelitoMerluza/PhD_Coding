function [files,pathname]=uimgetfile(dialog,mask,pathname)


if nargin < 3
  pathname='service/';
end

if nargin < 2
  mask='*.sav';
end


if nargin < 1
 dialog='Selection de fichier';
end

files=[];
ff=dir([pathname,mask]);

for ix=1:length(ff)
  files=strvcat(files,ff(ix).name);
end

files=sortrows(files);


figpos=[360 444 240 420];
h=figure('Name',dialog,...
         'NumberTitle','off',...
         'MenuBar','none',...
         'Position',figpos);

hl=uicontrol('Style','ListBox',...
             'String',files,...
             'Position',[20 60 200 330],...
             'Max',length(files));

hbok=uicontrol('Style','PushButton',...
                'String','Ok',...
                'CallBack','uiresume');

hbcanc=uicontrol('Style','Pushbutton',...
                 'String','Cancel',...
                 'Position',[100 20 60 20],...
                 'CallBack','uiresume');


set(gcf,'Units','normalized');
set(get(gcf,'Children'),'Units','normalized');

uiwait;

h=get(gcf,'CurrentObject');
action=get(h,'String');

if strcmp(action,'Ok')
  str=get(hl,'String');
  val=get(hl,'Value');
  files=str(val,:);
else
  files=0;
  pathname=0;
end

close(gcf);



function [files,pathname]=uigetfile(dialog,mask,pathname);

% Selection de fichier :
%   Catalogue   : mask = *.cat
%   calibres    : mask = *_cli.nc
%   sauvegarde  : mask = *.sav
%   Netcdf      : mask = *.nc

files=[];
ff=dir([pathname,mask]);

for ix=1:length(ff)
  files=strvcat(files,ff(ix).name);
end

files=sortrows(files);


%figpos=[360 544 240 420];
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
                 'String','Annuler',...
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
  files=deblank(str(val,:));
else
  files=[];
end

close(gcf);



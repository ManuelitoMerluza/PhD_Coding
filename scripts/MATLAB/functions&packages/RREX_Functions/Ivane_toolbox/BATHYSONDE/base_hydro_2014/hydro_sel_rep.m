function [files_nc, nbfic_nc] = hydro_sel_rep(pathname)

global_rep;

global dialog_camp
global zones_select


if nargin < 1
  pathname = rep_MLT_NC;
end

dialog = 'Choix des zones de l''ocean';

reperts='';
ff = dir(pathname);

for ix=1:length(ff)

   if (~(strcmp(ff(ix).name, '.')) && ~(strcmp(ff(ix).name, '..')) && ff(ix).isdir)
             reperts = strvcat(reperts,[rep_MLT_NC  ff(ix).name]);
   end
end
 
[nbdir,a] = size(reperts);

reperts=sortrows(reperts);
dialog_camp = 'Choix des repertoires';

% pour l'affichage, on ecrit le repertoire
% en relatif

reperts_petit = '';

for j = 1:nbdir
   a = strfind(deblank(reperts(j,:)),'/');
   reperts_petit = char(reperts_petit,deblank(reperts(j,a(end)+1:end)));
end

 

figpos=[360 444 240 420];
h=figure('Name',dialog,...
         'NumberTitle','off',...
         'MenuBar','none',...
         'Position',figpos);

hl=uicontrol('Style','ListBox',...
             'String',reperts_petit,...
             'Position',[20 60 200 330],...
             'Max',length(reperts_petit));

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
      zones1_select = str(val,:);
      zones_select = [];
      for ii = 1:size(zones1_select)
          zones_select = char(zones_select,[rep_MLT_NC deblank(zones1_select(ii,:)) '/']);
      end
      [files_nc, nbfic_nc] = hydro_sel_camp;
else
      reperts = 0;
      pathname= 0;
end

close(gcf);



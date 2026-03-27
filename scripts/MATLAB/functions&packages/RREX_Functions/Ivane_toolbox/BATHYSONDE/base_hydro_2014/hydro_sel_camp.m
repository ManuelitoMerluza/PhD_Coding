function [files_nc, nbfic_nc] = hydro_sel_camp;

% --------------------------------------
% selection des fichiers Netcdf dans les 
% repertoires campagne deja selectionnes
% --------------------------------------


global dialog_camp;
global zones_select;


if nargin < 1
    dialog_camp = 'Choix des campagnes';
end

files        = '';
files_affich = '';

for ii = 1:size(zones_select)
  ff = dir(deblank(zones_select(ii,:)));

  for ix=1:length(ff)

      if (~(strcmp(ff(ix).name, '.')) && ~(strcmp(ff(ix).name, '..')) && ff(ix).isdir)
              files = strvcat(files,[deblank(zones_select(ii,:)) ff(ix).name]);
      end;
  end;

end;


[nbdir,~] = size(files);

files        = sortrows(files);
% on n'affiche pas le nom complet du repertoire
for jj = 1:nbdir
    islash = strfind(files(jj,:),'/');
    files_affich = strvcat(files_affich, deblank(files(jj,islash(end)+1:end)));
end
    

figpos=[700 444 240 420];
h=figure('Name',dialog_camp,...
         'NumberTitle','off',...
         'MenuBar','none',...
         'Position',figpos);

hl=uicontrol('Style','ListBox',...
             'String',files_affich,...
             'Position',[20 60 200 330],...
             'Max',length(files_affich));

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
  val=get(hl,'Value');
  dir_select = files(val,:);

  files_nc = '';
  suff = 'DEPH.nc';
  mask = sprintf('%s%s', '*_', suff);
  for jj = 1:size(dir_select)
      if strfind(dir_select(jj,:),'NOUVELLES')
          suff = '*.nc';
          mask  = sprintf('%s',  suff);
      end
      filtre = sprintf('%s%1c%s', deblank(dir_select(jj,:)), '/',   mask);
      ff=dir(filtre);
     
     for ix=1:length(ff)
         if ~ff(ix).isdir
  	        files_nc=strvcat(files_nc,[deblank(dir_select(jj,:)) '/' ff(ix).name]);
         end
     end
  end

files_nc      = sortrows(files_nc);
[nbfic_nc, ~] = size(files_nc);
 
  
else
  files=0;
  dir_select=0;
end

close(gcf);


function [files_nc, nbfic_nc] = hydro_sel_rep_ba(pathname)

global_rep;

global dialog_camp zones_select;


if nargin < 1
  pathname = rep_MLT_NC;
end

reperts=[];
dialog = 'Donnees superficielles ou profondes';

irep = 0;
irep_max = 4;

while(irep~= irep_max);
   irep = menu('BASES ANNUELLES', ...
                    'Couches Superficielles', ...
                    'Donnees profondes', ...
                    'Aide', ...
                    'Fin');

  close all;

  switch irep

    case 1
    reperts = [rep_MLT_NC 'COUCHES_SUPERFICIELLES'];
    reperts_petit = 'COUCHES_SUPERFICIELLES';
    irep = 4;

    case 2
    reperts = [rep_MLT_NC 'DONNEES_PROFONDES'];
    reperts_petit = 'DONNEES_PROFONDES';
    irep = 4;
 
    case 3
    aide_hydro(7)
    irep = 0;

  end
end


 zones_select = [reperts '/']

 [files_nc, nbfic_nc] = hydro_sel_camp;





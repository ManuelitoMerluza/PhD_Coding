%----------------------------
%  Projet Archivage HYDRO 
%  --------------------------
%
%  Creation : Novembre 2005 / C. Lagadec
%----------------------------------------
                                         

function inventaire_liste_S(invs_nocamp, invs_ficnc, invs_navire, ...
                            invs_station_number, invs_indsta, invs_lat, ...
                            invs_long, invs_date, invs_juld, invs_maxdepth,invs_bottom,nbcamp)

global nocletri;

blanc2 = '  ';

% creation du repertoire 'wk_resu'
% --------------------------------
 
rep_resu     = './wk_resu';
if ~exist(rep_resu,'dir'),
  [dirok,mess1,mess2] = mkdir(rep_resu);
end;

% tri suivant l'un des criteres
% -----------------------------

switch nocletri

  case 1
% tri par defaut (en fonction du nom du fichier Multistation)

       ficres=[rep_resu '/inventaire_hydro_S.lst'];
        messcreat = 'Inventaire de la base Hydrologie ';

  case 2
% tri par Longitude

  critere_tri = [invs_long invs_juld];
  [critere_tri,indtri]  = sortrows(critere_tri);
  invs_date           = invs_date(indtri,:);
  invs_lat            = invs_lat(indtri); 
  invs_long           = invs_long(indtri);
  ficres=[rep_resu '/inventaire_long_S.lst'];
  messcreat = 'Inventaire Hydro trie par Longitude et Date';

  case 3
% tri par Latitude 

  critere_tri = [invs_lat invs_juld];
  [critere_tri,indtri]  = sortrows(critere_tri);
  invs_date          = invs_date(indtri,:);
  invs_long          = invs_long(indtri);
  invs_lat           = invs_lat(indtri);
  ficres=[rep_resu '/inventaire_lat_S.lst'];
  messcreat = 'Inventaire Hydro trie par Latitude et Date';

  case 4
% tri par Date

  [invs_date,indtri]  = sortrows(invs_date);
  invs_lat            = invs_lat(indtri);
  invs_long           = invs_long(indtri);
  ficres=[rep_resu '/inventaire_date_S.lst'];
  messcreat = 'Inventaire Hydro trie par Date';

end



if nocletri > 1

% tri des zones (sauf si nocletri = 1, tri par defaut)

  	invs_nocamp         = invs_nocamp(indtri);
 	invs_navire         = invs_navire(indtri,:);
  	invs_ficnc          = invs_ficnc(indtri,:);
  	invs_station_number = invs_station_number(indtri);
 	invs_indsta         = invs_indsta(indtri);
  	invs_bottom         = invs_bottom(indtri);
  	invs_maxdepth       = invs_maxdepth(indtri);
end




if  exist(ficres,'file')
    eval(['!\rm ' ficres]);
end


messnom = ['Creation en cours du fichier ', ficres ' sous le repertoire ' , rep_resu];
msgbox(messnom,messcreat);

f_res=fopen(ficres,'w'); 



% ecriture des entetes
% --------------------

fprintf(f_res,['\n              Inventaire des campagnes Hydrologie \n']);
date_courante=date;
fprintf(f_res, '              realise le ');
fprintf(f_res, date_courante);

[nb_stat,zz]=size(invs_lat);

fprintf(f_res, ' \n \n                  Nombre de campagnes :  ');
fprintf(f_res, num2str(nbcamp));

fprintf(f_res, ' \n \n                  Nombre de stations :  ');
fprintf(f_res, num2str(nb_stat));


fprintf (f_res, '\n \nNo Camp  Fic nc                  Navire        No Stat  Ind   Date     Heure     Lat     Long   Depth   Sonde  \n');

for is=1:nb_stat

  dat_list = [invs_date(is,1:4) '/' invs_date(is,5:6) '/' invs_date(is,7:8) ' ' invs_date(is,9:10) ':' invs_date(is,11:12)];
    
    c_stat = sprintf('%4i',  invs_nocamp(is));
    c_lat  = sprintf('%6.2f',invs_lat(is));
    c_lon  = sprintf('%7.2f',invs_long(is));
    c_sta  = sprintf('%3i',  invs_station_number(is));
    c_ista = sprintf('%3i',  invs_indsta(is));
    c_bot  = sprintf('%6.1f',invs_bottom(is));
    c_deph = sprintf('%4i',  invs_maxdepth(is));


% ecriture des valeurs

    tab=[c_stat  blanc2 invs_ficnc(is,:) blanc2 invs_navire(is,:) blanc2 c_sta blanc2 c_ista blanc2 dat_list blanc2 c_lat blanc2 c_lon blanc2 c_deph blanc2 c_bot];

    fprintf(f_res,' \n %3s %3s %20s %3s %16s %3s %3s %3s %3s %3s %16s %3s  %6s %3s %7s %3S %3s %4s %3s %6s \n ', tab);

end

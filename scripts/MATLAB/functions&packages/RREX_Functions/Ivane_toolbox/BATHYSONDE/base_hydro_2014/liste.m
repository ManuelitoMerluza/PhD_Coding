%----------------------------------------------------------------------
%  Projet ATLANTIQUR NORD
%  ----------------------
%  Version: 1.0
%  ------------
%  Creation : Fevrier 2003 / C. Lagadec
%                                            
%----------------------------------------------------------------------
%  Ouverture du fichier Extraction/liste_profils.lst contenant 
%  qques details sur la liste des stations retenus %----------------------------------------------------------------------

%=====================================================


global_rep;

parameters;

%=========================================================
% ecriture dans un fichier liste sous rep_MLT_NC/wk_resu
%=========================================================

ficres=[rep_resu '/liste_profils.lst'];

if  exist(ficres,'file')
    eval(['!\rm ' ficres]);
end;

messcreat = 'Liste des donnees selectionnees';
messnom = ['Creation en cours du fichier liste_profils.lst ',  ' sous le repertoire ' , rep_resu];
msgbox(messnom,messcreat);

blanc2 = '  ';
blanc5 = '     ';

f_res=fopen(ficres,'w'); 

fprintf(f_res,['\n              Donnees retenues pour les criteres demandes \n']);

siglat_min = 'N';
siglat_max = 'N';
siglon_min = 'W';
siglon_max = 'W';

if lat_extract_min < 0 
     siglat_min = 'S';
end;
if lat_extract_max < 0 
     siglat_max = 'S';
end;
if lon_extract_min > 0 
     siglon_min = 'E';
end;
if lon_extract_max > 0 
     siglon_max = 'E';
end;

tab=[' Latitudes comprises entre ' siglat_min num2str(abs(lat_extract_min)) ' et ' siglat_max num2str(abs(lat_extract_max))];
fprintf(f_res,'\n %1s %7s %1s %7s \n',tab);
tab=[' Longitudes comprises entre ' siglon_min num2str(abs(lon_extract_min)) ' et ' siglon_max num2str(abs(lon_extract_max))];
fprintf(f_res,'\n %1s %8s %1s %8s \n',tab);


if  isempty(mois_extract)
	tab = ['Dates de campagnes comprises entre le ' num2str(dates_extract(3)) '/' num2str(dates_extract(2))  '/' num2str(dates_extract(1)) ' et le ' num2str(dates_extract(6)) '/' num2str(dates_extract(5)) '/' num2str(dates_extract(4))];
        fprintf(f_res,' \n \n %7s %4s %1s %2s %1s %2s %3s %7s %1s %2s %1s %2s \n',tab);
     else
        tab = ['Mois d''extraction  ' num2str(mois_extract(:))']
end;

if ~isempty(imm_extract_min) & ~isempty(imm_extract_max)
     fprintf(f_res,['\n \n Immersion : entre ' num2str(imm_extract_min) ' et ' num2str(imm_extract_max) ' metres \n']);
end;

fprintf (f_res, '\n \n       Campagne      Date debut  Heure       Lat      Long   Stat  Prof.  Val max DEPH      \n');

for k=1:nb_stat_extract
    dat_list = [datedeb_sta(k,1:4) '/' datedeb_sta(k,5:6) '/' datedeb_sta(k,7:8) ' ' datedeb_sta(k,9:10) ':' datedeb_sta(k,11:12) ':' datedeb_sta(k,13:14)];

    c_k   = sprintf('%3i',k);
    c_lat = sprintf('%7.3f',latdeb_sta(k));
    c_lon = sprintf('%8.3f',londeb_sta(k));
    c_sta = sprintf('%3i',station_number_sta(k));
    c_son = sprintf('%6.1f',sondes_sta(k));
    c_pref = sprintf('%4i',prefmax_sta(k));
   


    tab=[c_k blanc2 camp_sta(k,:) blanc2 dat_list blanc2 c_lat blanc2 c_lon blanc2 c_sta blanc2 c_son blanc2 c_pref ];
    fprintf(f_res,' \n %3s %3s %16s %3s %19s %3s %7s %3s %8s %3s %3s %3s  %6s %3s %4s \n ', tab);

end;


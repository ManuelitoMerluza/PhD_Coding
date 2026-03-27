%----------------------------------------------------------------------
%  Base Hydrologie 
%  ---------------
%
%  Creation : Septembre 2005 / C. Lagadec
%                                            
%------------------------------------
%  Creation d'une liste des campagnes
%------------------------------------

function inventaire_liste_C(data_type, data_processing, fic_nc, camp, statd, statf, ...
                               nbstat, pi, ...
                               pi_org, navire, start_date, stop_date, ...
                               north_lat, south_lat, west_long, east_long, indic_Ox)

global_rep;


%=========================================================
% ecriture dans un fichier liste sous rep_MLT_NC/wk_resu
%=========================================================

ficres=[rep_resu '/inventaire_hydro_C.lst'];

if  exist(ficres,'file')
    eval(['!\rm ' ficres]);
end;

messcreat = 'Inventaire de la base Hydrologie';
messnom = ['Creation en cours du fichier inventaire_hydro_C.lst ',  ' sous le repertoire ' , rep_resu];
msgbox(messnom,messcreat);

blanc2 = '  ';
tiret  = '-';

[nb_camp, ~] = size(camp);



f_res=fopen(ficres,'w'); 

fprintf(f_res,'\n              Inventaire des campagnes Hydrologie \n');

date_courante=date;
fprintf(f_res, '              realise le ');
fprintf(f_res, date_courante);

fprintf(f_res, ' \n \n                  Nombre de campagnes :  ');
fprintf(f_res, num2str(nb_camp));

fprintf (f_res, '\n \n       Fichier                 Navire           Campagne      Type donnees  Date debut Date fin     Limites N/S        Limites W/E       Stat D-F  Nbst  Chef mission   Organisme       Ox   Origine \n');
          


for k=1:nb_camp 

% transformation de la date

    dat_list_deb = [start_date(k,1:4) '/' start_date(k,5:6) '/' start_date(k,7:8)];
    dat_list_fin = [stop_date(k,1:4) '/' stop_date(k,5:6) '/' stop_date(k,7:8)];

% recuperation du nom du fichier (sans les repertoires)

    islash = find(fic_nc(k,:)=='/');
    nomfic_nc (1:24) = ' ';
    il = length(deblank(fic_nc(k,:))) - islash(end); 
    nomfic_nc (1:il) = fic_nc(k,islash(end)+1:length(deblank(fic_nc(k,:))));


% transformation du type de donnees (XCTD, CTD ou CTD + B)

    data_type_list = data_type(k,1:4);
    ibot = strfind(data_type(k,:), 'bottle');
    if ~isempty(ibot)
          data_type_list(length(data_type_list)+1:length(data_type_list)+3) = '+ B';
       else
          data_type_list(length(data_type_list)+1:length(data_type_list)+3) = '   ';
    end


% ajout de blancs en fin de data_processing

 if   strcmp(data_processing(k,1:1),'L')
% LPO/IFREMER (11 car.)
                    data_processing(k,12:16) = ' ';
         elseif strcmp(data_processing(k,1:1),'H');
% HB2 (3 car.)
                    data_processing(k,4:16) = ' '; 
         elseif strcmp(data_processing(k,1:1),'C');
% CCHDO (5 car.)
                    data_processing(k,6:16) = ' ';
          elseif strcmp(data_processing(k,1:1),'S');
% SCRIPPS ... (15 car.)
                    data_processing(k,1:16) = 'SCRIPPSCTDGroup ';
 end
 
    c_k      = sprintf('%3i',k);
    c_latn   = sprintf('%7.3f',north_lat(k));
    c_lats   = sprintf('%7.3f',south_lat(k));
    c_lonw   = sprintf('%8.3f',west_long(k));
    c_lone   = sprintf('%8.3f',east_long(k));
    c_statd  = sprintf('%3i',statd(k));
    c_statf  = sprintf('%3i',statf(k));
    c_nbstat = sprintf('%3i',nbstat(k));

    i1 = length(deblank(pi_org(k,:)));
    zone1 (1:16) = ' ';
    zone1 (1:i1) = pi_org(k,1:i1);

    i2 = length(deblank(data_processing(k,:)));
    zone2 (1:16) = ' ';
    zone2 (1:i2) = data_processing(k,1:i2);

% correction rapide pour les campagnes du SCRIPPS qui
% n'etaient pas listees : zone Navire contenant des
% caracteres non blancs !
 
    if  strcmp(data_processing(k,1:5),'SCRIP')  
              navire(k,1:16) = ' ';
    end

 
    tab = [c_k blanc2 nomfic_nc(1:24)  navire(k,1:16)  blanc2 camp(k,1:16) blanc2   data_type_list(1:7) blanc2 dat_list_deb blanc2 dat_list_fin blanc2 c_latn blanc2 c_lats blanc2 c_lonw blanc2 c_lone blanc2 c_statd tiret c_statf blanc2 c_nbstat blanc2 pi(k,1:16)  zone1(1:16) blanc2  indic_Ox(k,1:2) blanc2 zone2(1:16)];

    fprintf(f_res,' \n %3s %2s %24s %16s %2s %16s %2s %7s %2s %10s %2s %10s %2s %7s %2s %7s %2s %8s %2s %8s %2s %3s %1s %3s %2s %3s %2s %16s %2s %16s %2s %2s %16s  \n \n', tab);

 
end;

fclose(f_res);


%------------------------------------------------------------------------------
%  Projet ATLANTIQUE NORD
%  ----------------------
%  Version: 1.0
%  ------------
%  Creation :Fevrier 2003 /  C.Lagadec
%                                            
%------------------------------------------------------------------------------
%  Visualisation des positions des stations de toute la base
%
%  rep_COMPLET       : liste complete des repertoires de la base
%  fic_MLT_COMPLET   : liste complete des fichiers de la base
%  nbfic_MLT_COMPLET : nombre de fichiers
%  latdeb_complet    : tableau des latitudes  (debut)
%  londeb_complet    : tableau des longitudes (debut)
%------------------------------------------------------------------------------


function visual_tout(rep_COMPLET, fic_MLT_COMPLET, nbfic_MLT_COMPLET, ...
                     latdeb_complet, londeb_complet); 

parameters;

global_rep; 


if  nbfic_MLT_COMPLET > 0


%=============================================
% Trace de la carte des positions des stations
%=============================================

    lon_extract_min = min(londeb_complet)-5.;
    lon_extract_max = max(londeb_complet)+5.;
    lat_extract_min = min(latdeb_complet)-2.;
    lat_extract_max = max(latdeb_complet)+1.;

    if lon_extract_min < -180.
           lon_extract_min = -180;
    end
    if lon_extract_max  > 180.
           lon_extract_max = 180;
    end
    if lat_extract_min < -90.
           lat_extract_min = -90;
    end
    if lat_extract_max > 89.95
           lat_extract_max = 89.95;
    end
%    lat_extract_max = 88.5;
     figure;
     m_proj('mercator','lon',[lon_extract_min lon_extract_max],'lat',[lat_extract_min lat_extract_max]);
     hold on;
%     m_coast('linewidth',2,'color',[1 0 0]);
%     m_coast('patch',[0.60  0.50  0.40],'edgecolor','none');
     m_gshhs_i('patch',[0.60  0.50  0.40],'edgecolor','none');
     m_grid('box','fancy','color',[0 0 0],'linestyle','-.');
     [x,y]=m_ll2xy(londeb_complet,latdeb_complet);

     plot(x,y,'g.');

     xlabel('LONGITUDE');
     ylabel('LATITUDE');

  else
     h=warndlg('Aucun fichier selectionne dans la base','Attention');
     waitfor(h)

 end

% on n'affiche pas le nom complet des repertoires
% dans le total de la selection
   rep_petit = [];
   [a,b] = size(rep_COMPLET);
   for i = 1:a
        b= findstr(deblank(rep_COMPLET(i,:)),'/');
        rep_petit = strvcat(rep_petit,deblank(rep_COMPLET(i,b(end)+1:end)));
   end

   messfich = 'Fichiers concernes';
   messlist = str2mat(' Nombre de fichiers Multistation Netcdf pris en compte : ',num2str(nbfic_MLT_COMPLET),' Nombre de stations : ',num2str(length(latdeb_complet)));
   msgbox(messlist, messfich);



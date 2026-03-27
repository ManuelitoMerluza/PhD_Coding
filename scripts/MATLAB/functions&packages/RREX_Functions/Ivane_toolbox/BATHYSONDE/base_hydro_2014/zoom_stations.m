%------------------------------------------------------------------------------
%  zoom_stations
%  ----------------------
%  Version: 1.0
%  ------------
%  
%  
% Creation : T.Loaëc Avril 2007                                          
%------------------------------------------------------------------------------
%  Sélectionne les latitudes et longitudes des stations comprises dans les limites données
%  arguments:limite_longitude,limite_latitude,tableau_longitude,tableau_latitude
%  resultats:longitude_stations,latitude_stations
%------------------------------------------------------------------------------


function [lon_station,lat_station] = zoom(lim_lon,lim_lat,tab_lon,tab_lat);

lon_station=[];
lat_station=[];
[l,w]=size(tab_lon);
if l>w

    for i=1:length(tab_lon)

 	if (tab_lon(i)>min(lim_lon))&(tab_lon(i)<max(lim_lon))&(tab_lat(i)<max(lim_lat))&(tab_lat(i)>min(lim_lat))

		lon_station=[lon_station;tab_lon(i)];
		lat_station=[lat_station;tab_lat(i)];

 	end
    end
else
    for i=1:length(tab_lon)

 	if (tab_lon(i)>min(lim_lon))&(tab_lon(i)<max(lim_lon))&(tab_lat(i)<max(lim_lat))&(tab_lat(i)>min(lim_lat))

		lon_station=[lon_station;tab_lon(:,i)];
		lat_station=[lat_station;tab_lat(:,i)];

 	end
    end

end

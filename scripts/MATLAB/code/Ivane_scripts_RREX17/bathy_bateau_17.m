function[bathy_ship,X,Y]=bathy_bateau_17(section)

%key: echo_sounder bathymetry of the RREX2017 cruise
%synopsis : bathy_bateau.m
%
%description : 
% fonction that read the bathymetry of each hydrological section recorded 
% by the echo-sounder along the ship track of the RREX2017 cruise
%
%uses: 
% En entree: section = 'ride', 'south', 'north', 'ovide'
% En sortie bathy_ship : la bathymetrie mesuree par le bateau
% X = latitude (°N) pour la section ride (Y=longitude)
% X = longitude (°E) pour les sections sud, nord, ovide (Y=latitude)
%
%author(s) : I. Salaun Jan 2019 from T. Petit Sept 2018
%
load('bathy_2017/Bathy_Sonde.mat')

switch section
    case 'ride'       
        bathy_ship = [bathy(149228:166673);bathy(173518:174569);bathy(174948:176547);bathy(177317:181046);bathy(181776:219865);bathy(220723:245000);max(bathy);max(bathy)]'; 
        X = [lat(149228:166673);lat(173518:174569);lat(174948:176547);lat(177317:181046);lat(181776:219865);lat(220723:245000);lat(245000);lat(149228)]';
        Y = [lon(149228:166673);lon(173518:174569);lon(174948:176547);lon(177317:181046);lon(181776:219865);lon(220723:245000);lon(245000);lon(149228)]';
        
    case 'north' 
        bathy_ship = [bathy(128075:147363);max(bathy);max(bathy)]'; 
        X = [lon(128075:147363);lon(147363);lon(128075)]';
        Y = [lat(128075:147363);lat(147363);lat(128075)]';
        
    case 'ovide'   
        bathy_ship = [bathy(61528:86251);flip(bathy(94397:116330));max(bathy);max(bathy)]'; 
        X = [lon(61528:86251);flip(lon(94397:116330));lon(94397);lon(61528)]';
        Y = [lat(61528:86251);flip(lat(94397:116330));lat(94397);lat(61528)]';
        
    case 'south'
        bathy_ship = [bathy(25277:56006);max(bathy);max(bathy)]'; 
        X = [lon(25277:56006);lon(56006);lon(25277)]';
        Y = [lat(25277:56006);lat(56006);lat(25277)]';
end

end
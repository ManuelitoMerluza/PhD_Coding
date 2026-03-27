function[bathy_ship,X,Y]=bathy_bateau(section)

%key: echo_sounder bathymetry of the RREX2015 cruise
%synopsis : bathy_bateau.m
%
%description : 
% fonction that read the bathymetry of each hydrological section recorded 
% by the echo-sounder along the ship track of the RREX2015 cruise
%
%uses: 
% En entree: section = 'ride', 'south', 'north', 'ovide'
% En sortie bathy_ship : la bathymetrie mesuree par le bateau
% X = latitude (°N) pour la section ride (Y=longitude)
% X = longitude (°E) pour les sections sud, nord, ovide (Y=latitude)
%
%author(s) : T. Petit (tillys.petit@ifremer.fr) Sept 2018
%
%References:
%  Petit, T., Mercier, H. and Thierry T. (2018), First direct estimates of 
%  volume and water mass transports across the Reykjanes Ridge. Journal of
%  Geophysical Research: ocean, doi:10.1029/2018JC013999


if strcmp(section,'north');  section = 'nord'; end
if strcmp(section,'south'); section = 'sud'; end

switch section
    case 'ride'
        load('bathy/bathy_rr15_sec_26.mat')
        bathy1 = bth_sec';
        lat1 = lat_sec';
        lon1 = lon_sec';
        load('bathy/bathy_rr15_sec_27.mat')
        bathy2 = [bathy1 bth_sec];
        lat2 = [lat1 lat_sec];
        lon2 = [lon1 lon_sec];
        load('bathy/bathy_rr15_sec_29.mat')
        bathy3 = [bathy2 bth_sec'];
        lat3 = [ lat2 lat_sec'];
        lon3 = [ lon2 lon_sec'];
        %load('/home1/homedir5/perso/petitt/bth_sectt/matlab/These/mat/BFZ_HM/Vabs_96_101.mat','X_bathy','Y_bathy','bathy_ship');
        %bth_sec = bathy_ship(394:end-1); lon_sec = X_bathy(394:end-1); lat_sec = Y_bathy(394:end-1);
        %bth_sec = bth_sec(:); lon_sec = lon_sec(:); lat_sec = lat_sec(:);
        %bathy4 = [bathy3 bth_sec'];
        %lat4 = [ lat3 lat_sec'];
        %lon4 = [ lon3 lon_sec'];
        clear X_bathy Y_bathy bathy_ship
        load('bathy/bathy_rr15_sec_32.mat')
        bathy5 = [ bathy3 bth_sec];
        lat5 = [ lat3 lat_sec];
        lon5 = [ lon3 lon_sec];
        load('bathy/bathy_rr15_sec_35.mat')
        bathy_ship = [bathy5 bth_sec(1:724) bth_sec(764:end) 4350 4350]; 
        lat_ship = [lat5 lat_sec(1:724) lat_sec(764:end) 49 63.3498]; 
        lon_ship = [lon5 lon_sec(1:724) lon_sec(764:end) -35.0790 lon5(1)]; 
        X=lat_ship;
        Y = lon_ship;
        
    case 'nord' 
        load('bathy/bathy_rr15_sec_22.mat')
        bathy1 = bth_sec';
        lon1 = lon_sec';
        lat1 = lat_sec';
        load('bathy/bathy_rr15_sec_23.mat')
        bathy_ship = [bathy1 bth_sec' 3000 3000];
        lon_ship = [lon1 lon_sec' -33.0008723 -20.9687344];
        lat_ship = [lat1 lat_sec' 63.0016 lat1(1)];
        X=lon_ship;
        Y = lat_ship;
        
    case 'ovide'
        load('bathy/bathy_rr15_sec_10.mat')
        bathy1 = bth_sec';
        lon1 = lon_sec';
        lat1 = lat_sec';
        load('bathy/bathy_rr15_sec_12.mat')
        bathy2 = [bathy1 bth_sec'];
        lon2 = [lon1 lon_sec'];
        lat2 = [lat1 lat_sec'];
        load('bathy/bathy_rr15_sec_13.mat')
        bathy3 = [bathy2 bth_sec'];
        lon3 = [ lon2 lon_sec'];
        lat3 = [ lat2 lat_sec'];
        load('bathy/bathy_rr15_sec_14.mat')
        bathy4 = [ bathy3 bth_sec'];
        lon4 = [ lon3  lon_sec'];
        lat4 = [ lat3  lat_sec'];
        load('bathy/bathy_rr15_sec_16.mat')
        bathy5 = [bathy4 bth_sec'];
        lon5 = [ lon4 lon_sec'];
        lat5 = [ lat4 lat_sec'];
        load('bathy/bathy_rr15_sec_18.mat')
        bathy6 = [ bathy5 bth_sec'];
        lon6 = [ lon5 lon_sec'];
        lat6 = [ lat5 lat_sec'];
        load('bathy/bathy_rr15_sec_20.mat')
        bathy_ship = [bathy6 bth_sec' 4000 4000]; 
        lon_ship = [lon6 lon_sec' -27.344605 -37]; 
        lat_ship = [lat6 lat_sec' 56.9349 53]; 
        X=lon_ship;
        Y = lat_ship;
        
    case 'sud'
        load('bathy/bathy_rr15_sec_02.mat')
        bathy1 = bth_sec';
        lon1 = lon_sec';
        lat1 = lat_sec';
        load('bathy/bathy_rr15_sec_04.mat')
        bathy2 = [ bathy1 bth_sec'];
        lon2 = [ lon1 lon_sec'];
        lat2 = [ lat1 lat_sec'];
        load('bathy/bathy_rr15_sec_08.mat')
        bathy_ship = [bathy2 bth_sec' 3200 3200]; 
        lon_ship = [lon2 lon_sec' -38.1535354 -31.3356278]; 
        lat_ship = [lat2 lat_sec' 56.7679 lat2(1)];
        X=lon_ship;
        Y = lat_ship;
end

end
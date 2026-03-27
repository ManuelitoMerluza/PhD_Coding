%A.GANACHAUD Feb 97
%TEST FOR THE GEOVEL.M program against the geovel.f results

%first matlab window, load results from geovel.f

datadir='/data1/ganacho/HDATA/';
secid='flst';
getpdat
temp(1:15,1:7)
-gvel(1:15,1:7)

%second matlab window
path(path,'/data4/ganacho/HYDROSYS')
datadir='/data1/ganacho/HDATA/GEOVELM/';
secid='flst';
getpdat
temp(1:15,1:7)
gvel(1:15,1:7)


fname='/data37/king/ANAL_92/NMC_3-149';
nskip=0;
[xlon,xlat,Taux]=read_gridded(fname,nskip);
nskip=1;
[ylon,ylat,Tauy]=read_gridded(fname,nskip);
xlon=[(xlon(1:20)+360);xlon(21:length(xlon))];

gilat=[1:4:length(xlat)];
gilon=[1:4:length(xlon)];

[X,Y]=meshgrid(xlon(gilon),xlat(gilat));
quiver(X,Y,-Taux(gilon,gilat)',-Tauy(gilon,gilat)',5);title(fname)
grid on
axis([min(xlon(gilon)),max(xlon(gilon)),min(xlat(gilat)),max(ylat(gilat))])
land;setlargefig;

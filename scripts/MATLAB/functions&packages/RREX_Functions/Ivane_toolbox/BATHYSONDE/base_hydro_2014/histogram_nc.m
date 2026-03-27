 
 figure
 nb_stat = length(pressmax)
 barres = [0:200:max(pressmax)]
 hist(pressmax,barres)
 xlabel('Pression max')
 ylabel('Nombre stations')
 title('Fichier H21998P2-dep.nc 402 stations')

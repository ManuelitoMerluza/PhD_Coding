function recupStations()

% ------------------------------------------------------
% fonction recupStations - C. Lagadec - Nov. 98
%
% recuperation des elements d'un nom de fichier
% IDENTCAMP STAT1 STATN DIRECTION
% les stations peuvent ne pas appartenir a la meme campagne
% => les longueurs des noms de fichiers sont differentes.
% ------------------------------------------------------
%
% modif C.Lagadec decembre 2014
% suite à decision LPO, le nom du fichier Hydro
% peut (doit ?) contenir le numero de cast
% le décodage est donc modifie
% nouvelle convention :
% IDENTCAMP DIRECTION STAT (4 car) '_' CAST(3 car)_cli.nc (ou _clc.nc) 

globalVarEtiquni;

l1 = length(deblank(NOM_FILES(1,:)));
l2 = length(deblank(NOM_FILES(NBFILES,:)));

itiret=strfind(NOM_FILES(1,1:l1),'_');
% identificateur campagne peut contenir un ou des tirets(_)
if length(itiret) > 1
     CAST=NOM_FILES(1,itiret(end-1)+1:itiret(end)-1);
     % le numero de station est quelquefois sur 5 car au lieu de 4
     if strcmp(NOM_FILES(1,itiret(end-1)-5),'d') | strcmp(NOM_FILES(1,itiret(end-1)-5),'a')
        STAT1 = str2num(NOM_FILES(1,itiret(end-1)-4 : itiret(end-1) -1));
        DIRECTION = NOM_FILES(1,itiret(end-1)-5);
        STATN = str2num(NOM_FILES(NBFILES,itiret(end-1)-4 : itiret(end-1) -1));
        IDENTCAMP = NOM_FILES(1,1:itiret(end-1)-6);
     else
        STAT1 = str2num(NOM_FILES(1,itiret(end-1)-5 : itiret(end-1) -1)); 
        DIRECTION = NOM_FILES(1,itiret(end-1)-6);
        STATN = str2num(NOM_FILES(NBFILES,itiret(end-1)-5 : itiret(end-1) -1));
        IDENTCAMP = NOM_FILES(1,1:itiret(end-1) -7);
     end
        
else
     IDENTCAMP = NOM_FILES(1,1:l1-11);
     STAT1 = str2num(NOM_FILES(1,l1-9:l1-7));

     STATN = str2num(NOM_FILES(NBFILES,l2-9:l2-7));
     DIRECTION = NOM_FILES(1,l2-10:l2-10);
     CAST = '001';
end
SUFF  = NOM_FILES(1,l1-6:l1);


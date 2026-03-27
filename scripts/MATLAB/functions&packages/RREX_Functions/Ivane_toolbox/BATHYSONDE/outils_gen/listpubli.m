%************************************************************************************
% creation d'un fichier listing des mesures pour integration dans rapport
% de donnees 
% (En entree on utilise les fichiers _cli ou _clc netcdf)
% 26/02/13 P.Branellec
% Apres correction du programme creclc par CK, on utilise les fichiers _clc.nc
% entete en francais ou anglais
%
% Sous word : mettre police new courrier taille 7, pour que les sauts de page
%             soient bien places.
%             mise en page : marge gauche 2.0 cm, marge droite 1.5 cm
%************************************************************************************
%
% 16/01/14 Modifié par C.Lagadec
%
% paramétrisation de l'identificateur campagne, 
%                du type de fichier (cli ou clc)
%                de la langue
%                des stations debut et fin
%************************************************************************************

clear all;
close all;


identcamp = input('Identificateur Campagne ? ','s');
typefic   = input('Type de fichier ? (cli ou clc) ', 's');
fic_sor   = ['resu/' identcamp '.imp'];
fid_fics  = fopen(fic_sor,'w');
 
%
% initialisation
%
pr1 = 10:10:40;
pr1 = pr1';
pr2 = 50:50:6500;
pr2 = pr2';
% concatenation verticale
tpr = [pr1;pr2];
Mat = nan(134,5);
%
% lecture des mesures sonde
%
stdeb=input('Station debut ? ');
stfin=input('Station fin ? ');

sta = (stdeb : stfin);

for i_sta = sta(1,:)

%
% lecture fichier sonde
%
cstat=sprintf('%03d',i_sta);
ficuni = [identcamp 'd' cstat '_' typefic '.nc'];

% test si le ficheir existe
if exist(ficuni,'file')
%
% recuperation des infos de l'entete
%
csta = int2str(i_sta);
date = ncread(ficuni,'STATION_DATE_BEGIN');
date =date';
camp = ncreadatt(ficuni,'/','CRUISE_NAME');
xj = date(7:8);
xm = date(5:6);
xa = date(1:4);
xh = date(9:10);
xmn = date(11:12);
nav = ncreadatt(ficuni,'/','SHIP_NAME');
sond = ncread(ficuni,'BATHYMETRY_BEGIN');
orga = ncreadatt(ficuni,'/','PI_ORGANISM');
%
% lecture mesures
%
xp = ncread(ficuni,'PRES');
pmax = max(xp);
xt = ncread(ficuni,'TEMP');
xs = ncread(ficuni,'PSAL');
xo = ncread(ficuni,'OXYK');
xsi = ncread(ficuni,'SIG0');
%
% calcul latitude en minutes decimales
%
lat = ncread(ficuni,'LATITUDE_BEGIN');
  if lat > 0
      xlat = 'N';
  else
      xlat = 'S';
  end
%
lat = abs(lat);
lat1 = fix(lat);
latm = (lat-lat1)/100*6000;
%
lon = ncread(ficuni,'LONGITUDE_BEGIN');
  if lon > 0
      xlon = 'E';
  else
      xlon = 'W';
  end
%
lon = abs(lon);
lon1 = fix(lon);
lonm = (lon-lon1)/100*6000;
%
% entete
%
 
% entete listing sortie 
%
        if i_sta ~= sta(1,1)
             fprintf(fid_fics,'   \r\n\f');
             fprintf(fid_fics,'   \r\n\f');
        end
        fprintf(fid_fics,'                            \n');
        fprintf(fid_fics,'  ---------------------------------------------------------------------\n');
        fprintf(fid_fics,'  | Station    : %3d            Campagne  : %s                  |\n',i_sta,camp);
        fprintf(fid_fics,'  |                                                                   |\n');
        fprintf(fid_fics,'  | Date       : %2s/%2s/%2s %2sh%2s     Navire    : %s   |\n',xj,xm,xa,xh,xmn,nav);
        fprintf(fid_fics,'  |                                                                   |\n');
        fprintf(fid_fics,'  | Profondeur : %4.4d m         Organisme : %s             |\n',sond,orga);
        fprintf(fid_fics,'  |                                                                   |\n');
        fprintf(fid_fics,'  | Position   : %s  %2.2d %5.2f                                          |\n',xlat,lat1,latm);
        fprintf(fid_fics,'  |              %s %3.3d %5.2f                                          |\n',xlon,lon1,lonm);
        fprintf(fid_fics,'  ---------------------------------------------------------------------\n');
        fprintf(fid_fics,'                   \n');
%
        if pmax < 3000
          fprintf(fid_fics,'   PRESSION   TEMPERA-   SALINITE   OXYGENE      TEMP.\n');
          fprintf(fid_fics,'                TURE                DISSOUS     POTENT.\n');
          fprintf(fid_fics,'     dbar     deg.cels.    psu      umol/kg    deg.cels.\n');
        else
          fprintf(fid_fics,'   PRESSION   TEMPERA-   SALINITE   OXYGENE      TEMP.       PRESSION   TEMPERA-   SALINITE   OXYGENE      TEMP.\n');
          fprintf(fid_fics,'                TURE                DISSOUS     POTENT.                   TURE                DISSOUS     POTENT.\n');
          fprintf(fid_fics,'     dbar     deg.cels.    psu      umol/kg    deg.cels.       dbar    deg.cels.     psu      umol/kg    deg.cels.\n');
        end

%
% remplissage matrice
%
j = 0;
ind = 0;
val=size(xp);
  for k = 1:val(1)
%    if k == 1
    if k == 2
      Mat(j+1,1:5) =[xp(k) xt(k) xs(k) xo(k) xsi(k)];
      j = j+1;
      ind = ind + 1;
    end
    if k > 1 && k < val(1)
      if xp(k) == tpr(ind)
        Mat(j+1,1:5) =[xp(k) xt(k) xs(k) xo(k) xsi(k)];
        j=j+1;
        ind = ind + 1;
      end
    end
    if k == val(1)
      Mat(j+1,1:5) =[xp(k) xt(k) xs(k) xo(k) xsi(k)];
      j=j+1;
      ind = ind + 1;
    end
  end
%
% ecriture
%
lgn = 0;
  for jj = 1:65
    if jj <= ind && ind <= 65
      fprintf(fid_fics,'    %6.1f     %6.3f     %6.3f     %5.1f      %6.3f\n',Mat(jj,1:5));
      lgn = lgn + 1;
    end
    if ind > 65 && (jj+65) <= ind
      fprintf(fid_fics,'    %6.1f     %6.3f     %6.3f     %5.1f      %6.3f        %6.1f     %6.3f     %6.3f     %5.1f      %6.3f\n',Mat(jj,1:5),Mat(jj+65,1:5));
      lgn = lgn + 1;
    end
    if ind > 65 && (jj+65) > ind
      fprintf(fid_fics,'    %6.1f     %6.3f     %6.3f     %5.1f      %6.3f\n',Mat(jj,1:5));
      lgn = lgn + 1;
    end
    if jj > ind && lgn <= 65
      fprintf(fid_fics,'          \n');
      lgn = lgn + 1;
    end      
  end
 else
    message = ['Fichier inexistant ' ficuni] 
end 

end
%
fclose(fid_fics);    
       





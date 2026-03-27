% ------------------------------------------------------------------
% function [stat_dec, stat_ident_c, stat_ident_x, camp_name, ...
%           TS, date,...
%           heure, lat, lon, nparam, nmes, fond, pmin, pmax, ...
%           param, data] = import_CCHDO(nom_fic);
%
% ------------------------------------------------------------------
% Decode les fichiers netcdf du site Web CCHO 
% series de campagne : AR07E ...
%
% Entree : Nom du fichier a decoder
%
%
% Sortie : 
%
% 
% stat_dec     = 1 si des valeurs aberrantes ont ete trouvees
%              = 0 sinon
% stat_ident_c = identificateur de station, (string*3 - entier < 1000)
% stat_ident_x = identificateur de station, (numerique)
% camp_name    = nom de la campagne (16 characteres max.)
% nav_name     = nom du navire (16 characteres max)
% TS           = type de sonde (6 characteres max.)
% date         = jjmmyyyy (8 characteres)
% heure        = [hh mm] (tableau de 2 entiers)
% lat          = latitude (en degres decimaux + -> N, - -> S)
% lon          = longitude (en degres decimaux + -> E, - -> W)
% npar_fic     = nombre de parametres (entier < 100)
% nmes         = nombre de mesures dans le fichier (entier < 10000)
% fond         = profondeur (entier < 9999)
% pmin         = pression minimale mesuree (entier < 10000)
% pmax         = pression maximale mesuree (entier < 10000)
% param        = tableau de npar_fic lignes contenant le code des
%                parametres contenus dans le fichier
% data         = tableau (nmes x npar_fic) des donnees
%
%
% ------------------------------------------------------------------------------
%  version:
%  --------
%  1.01                                               01/10/2001   F.Gaillard
%  	d'apres import_kiel1
%  1.02                                               Octobre 2005 C. Lagadec
%       d'apres import-shom2
% ------------------------------------------------------------------------------

function  [stat_dec,  stat_ident_c, stat_ident_x, camp_name, ...
           TS, date,...
           heure, lat, lon, nparam, nmes, fond, pmin, pmax,...
           param, data] = import_CCHDO(nom_fic);


stat_dec = 0;
valerr = 1.e+36;

pres  = [];
sal78 = [];
tmp90 = [];
oxk   = [];
pres  = [];
   
pres_QC  = [];
sal78_QC = [];
tmp90_QC = [];
oxk_QC   = [];

%
% ==========================
%    Decode file name  
% ==========================

f_cdf = netcdf(nom_fic,'read');


% ========================================
%   Read in the global attributes
% ========================================

   expocod = f_cdf.EXPOCODE(:);
   
   ifin = findstr(expocod,'\0');
   iblanc = 16 - ifin + 1;
   camp_name (1:16) = [expocod(1:ifin-1) blanks(iblanc)];

   lat   = f_cdf{'latitude'}(:);
   lon   = f_cdf{'longitude'}(:);
   fond  = f_cdf.BOTTOM_DEPTH_METERS(:);

   data_type    = f_cdf.DATA_TYPE(:);
   ifin = findstr(data_type,'\0');
   if strcmp(data_type(1:8),'WOCE CTD')
        TS(1:6) = 'W CTD ';
     else
        TS(1:6) = data_type(1:6);
   end

   woce_date = f_cdf{'woce_date'}(:);
   woce_date = num2str(woce_date);
   iw = findstr(woce_date,' ');
   woce_date(iw) = '0';
   date = [woce_date(7:8) woce_date(5:6) woce_date(1:4)];

   woce_heure = f_cdf{'woce_time'}(:);
   woce_heure = num2str(woce_heure);
   if  (length(woce_heure) == 3)
          heure = ['0' woce_heure(1:3)];
       elseif  (length(woce_heure) == 2)
          heure = ['00' woce_heure(1:2)];
      elseif  (length(woce_heure) == 1)
          heure = ['000' woce_heure(1:1)];
       else      
          heure = woce_heure;
   end;

% numero interne de station (peut etre different du numero
% de station dans le nom de fichier (pour AR07WH et AR07WE)
% ---------------------------------------------------------
    sta = f_cdf.STATION_NUMBER(:);
    jj = findstr(sta,'\');
    stat_ident_c = sprintf('%3s',sta(1:jj-1));
    jj = findstr(stat_ident_c,' ');
    stat_ident_c(jj) = '0';
% test special AR12_91A 
    if strcmp(stat_ident_c(1:3),'11v') 
           stat_ident_c(1:3) = '000';
    end 
% test special AR12_91B 
    if strcmp(stat_ident_c(1:3),'12v') 
           stat_ident_c(1:3) = '000';
    end 
    stat_ident_x = str2num(stat_ident_c)


% test particulier pour AR07WE : plusieurs stations avec le meme numero
% mais 'cast' different
% cast = 1 : station 100 ...
% cast = 2 : station 200 ...

   if  strcmp(nom_fic(1:7),'ar07w_e')
         stat_ident_c = nom_fic(11:13);
         if  strcmp(stat_ident_c(1:1),'0')
             stat_ident_c(1:1) = '1';
         end
   end


% modif C.Lagadec le 29 mai 2008
% test particulier pour AR04_h (AR04EW96) : plusieurs stations avec le meme numero
% mais un numero de 'cast' different : le numero de cast est ajoute au numero de station
% dans le nom de fichier
% station 30, cast 3 : station 330
% station 120, cast 1 : station 220

   if  strcmp(nom_fic(1:6),'ar04_h')
         stat_ident_c = nom_fic(10:12);
         sta = str2num(stat_ident_c);
         cast = nom_fic(18:18);
         sta = sta + str2num(cast)*100;
         stat_ident_c = num2str(sta);

% cas particuliers pour 5 fichiers qui avaient le meme numero de station apres calcul 
% on fait commencer le numero par 9 
         if strcmp(nom_fic(10:18),'103_00003') |  strcmp(nom_fic(10:18),'109_00003') | strcmp(nom_fic(10:18),'122_00003') | strcmp(nom_fic(10:18),'123_00002') | strcmp(nom_fic(10:18),'124_00001')  
                 stat_ident_c(1:1) ='9';  
         end
   end

% modif C.Lagadec (22/9/08) : enlever test special A12_99
% modif C.Lagadec le 27 juin 2008
% Test particulier pour A12_99 : plusieurs stations au meme numero
% mais cast different : 

%  if  strcmp(nom_fic(1:9),'a12_1999a') 
%         stat_ident_c = nom_fic(13:15);
%         sta = str2num(stat_ident_c);
%         cast = nom_fic(20:21);
%         sta = sta + str2num(cast)*100;
%         stat_ident_c = num2str(sta);
% end

% ==========================================
%    Lecture donnees et des flags de qualite 
% ==========================================

   pres_1  = f_cdf{'pressure'}(:);
   sal78_1 = f_cdf{'salinity'}(:);
   tmp90_1 = f_cdf{'temperature'}(:);
   oxk_1   = f_cdf{'oxygen'}(:);
   pres_1  = round(pres_1 + 0.5);
   

   pres_QC_1  = f_cdf{'pressure_QC'}(:);
   sal78_QC_1 = f_cdf{'salinity_QC'}(:);
   tmp90_QC_1 = f_cdf{'temperature_QC'}(:);
   oxk_QC_1   = f_cdf{'oxygen_QC'}(:);

% modif pas tres "catholique" (C. Lagadec 8/7/08) à cause des valeurs decimales 
% de pression dans certaines campagnes CCHDO
% apres l'arrondi, on supprime les niveaux en double

   ik = 0;

   for jj = 1:length(pres_1) - 1

      if  (pres_1(jj) < pres_1(jj+1))
          ik = ik+1;
          pres(ik)  = pres_1(jj);
          sal78(ik) = sal78_1(jj);
          tmp90(ik) = tmp90_1(jj);
          oxk(ik)   = oxk_1(jj);
 
          pres_QC(ik)  = pres_QC_1(jj);
          sal78_QC(ik) = sal78_QC_1(jj);
          tmp90_QC(ik) = tmp90_QC_1(jj);
          oxk_QC(ik)   = oxk_QC_1(jj);
      end
   end
% ecriture dernier niveau
   ik = ik+1;
   pres(ik)  = pres_1(end);
   sal78(ik) = sal78_1(end);
   tmp90(ik) = tmp90_1(end);
   oxk(ik)   = oxk_1(end);
 
   pres_QC(ik)  = pres_QC_1(end);
   sal78_QC(ik) = sal78_QC_1(end);
   tmp90_QC(ik) = tmp90_QC_1(end);
   oxk_QC(ik)   = oxk_QC_1(end);     


% fin modif pas "catholique" du 8/7/8

   nostat= stat_ident_c
   nparam = 4;
   itmp =[]; isal = []; ioxk = [];
   itmp = find(tmp90_QC == 1 | tmp90_QC == 4 | tmp90_QC == 5 | tmp90_QC == 8 | tmp90_QC == 9);

   itmp2 = find(tmp90_QC == 1 | tmp90_QC == 4 | tmp90_QC == 5 | tmp90_QC == 8);
   if ~isempty(itmp2)
          nberrtmp = length(itmp)
   end
   tmp90(itmp) = valerr;

% modif 17/9/08 C.Lagadec : 
% trouve certains fichiers CCHDO avec des flags à 2 (bon) et des valeurs de salinité à 0.004
% => ajout du test de salinite < 15


   isal = find(sal78_QC == 1 | sal78_QC == 4 | sal78_QC == 5 | sal78_QC == 8 | sal78_QC == 9 | sal78 < 15)
   sal78(isal) = valerr;
 
   isal2 = find(sal78_QC == 1 | sal78_QC == 4 | sal78_QC == 5 | sal78_QC == 8);
   if ~isempty(isal2)
          nberrsal = length(isal)
   end

% modif 23/9/08 C.Lagadec : 
% trouve certains fichiers CCHDO avec des flags à 2 (bon) et des valeurs d'oxygene à 0
% => ajout du test d'oxygene = 0


   ioxk = find(oxk_QC == 1 | oxk_QC == 4  | oxk_QC == 5 | oxk_QC == 8 | oxk_QC == 9 | oxk == -999 | oxk == 0);
   oxk(ioxk) = valerr;

   ioxk2 = find(oxk_QC == 1 | oxk_QC == 4  | oxk_QC == 5 | oxk_QC == 8);
   if ~isempty(ioxk2)
          nberroxk = length(ioxk)
   end

%   if  (length(ioxk) == length(oxk_QC))
%      nparam = 3;
%  end
  
   flag_pres(length(pres)) = 0;
   for ii = 1:length(pres)
       if (tmp90(ii) == valerr | sal78(ii) == valerr)
            flag_pres(ii) = 1;
       end
   end

   ibon = find(flag_pres == 0);
   pres_bon = pres(ibon)';
   tmp90_bon = tmp90(ibon)'; 
   sal78_bon = sal78(ibon)'; 
   oxk_bon = oxk(ibon)';
  
 
% ==========================
%    Close nc file  
% ==========================

f_cdf= close(f_cdf);


%  Fill data table
%  ---------------

pmin = min(pres_bon);
pmax = max(pres_bon);
nmes = length(pres_bon);

if   (nparam == 4)   
     data = [pres_bon tmp90_bon sal78_bon oxk_bon];
     param = strvcat('prs ', 'tmp ', 'sal ','oxk ');
  else
     data = [pres_bon tmp90_bon sal78_bon]; 
     param = strvcat('prs ', 'tmp ', 'sal ');
end;

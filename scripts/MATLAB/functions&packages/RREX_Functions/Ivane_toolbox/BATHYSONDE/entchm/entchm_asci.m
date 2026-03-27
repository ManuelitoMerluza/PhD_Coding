
%--------------------------------------------------------
%
%     ENTCHM_ASCI  Auteur : C. Lagadec (janvier 2004)
%
% Introduction des donnees de chimie 
% dans les fichiers binaires au format bathysonde
% les donnees sont entrees dans les fichiers .cli
% qui servent a creer les .clc 
% (exceptionnellement dans les . clc)
%
%---------------------------------------------------------
% en entree : 1) fichier .ach (ASCII) contenant les donnees
%                de chimie en provenance du LPO
%        - salc, tmpc, salc ... param physiques rapportees aux 
%                               niveaux de la chimie
%        - sals, oxys, tmps ... parametres chimiques mesures en mer
%        - si0s, immc ...       parametres chimiques calcules
%
%             2) fichier des codes parametres (ficodf)
% 
%             3) fichier catalogue contenant les fichiers binaires
%                (cli ou clc)
%
%             4) fichiers binaires (cli ou clc)
%
% en sortie : fichiers cli ou clc mis a jour
%
%------------------------------------------------------------------------------------
%
% les donnees peuvent etre ou non triees sur la pression chimie (prsc),
% ENTCHM_ASCI les trie systematiquement
%
% les numeros de station doivent etre identiques 
% (dans le fichier .ach et dans le catalogue des fichiers .cli ou .clc)
%
% les renseignements sur les parametres sont pris dans l'etiquette 
% du fichier .ach (unite, responsable des donnees, organisme du responsable, 
%                  precision), 
% le libelle du code est pris dans le fichier des codes
%
% -----------------------------------------------------------------------------------





globalVarEtiquni;

global COD;


valerr_clc  = -9999;

messecr = 'Problème d''écriture du paramètre '; 

% zones du fichier Matlab cree pour l'introduction
% des autres donnees chimiques
% ------------------------------------------------
nostat_ach = [];
nobout_ach = [];
prs_ach    = [];

% ouverture du fichier ASCII (.ach) contenant 
% les valeurs de  Chimie
% -----------------------------------------

NOMFIC_ACH = input('... Nom du fichier Chimie .ach (ne pas taper .ach) ?   ','s');
NOMFIC_ACH = [NOMFIC_ACH '.ach'];
fach = fopen(NOMFIC_ACH,'r');



% lecture du fichier catalogue contenant 
% les noms des fichiers .cli ou .clc
% --------------------------------------

NOMFIC_CAT = input('... Nom du fichier Catalogue .cat (ne taper ni service, ni .cat) ?   ','s');
NOMFIC_CAT = ['service/' NOMFIC_CAT '.cat']
load_cat;


% lecture du fichier des codes
% ----------------------------

COD.nomfic = 'service/ficodf';
[messerr] = lfcod;


% -----------------------
% lecture du fichier .ach
% -----------------------

% lecture de la 1ere ligne contenant
% le nombre de stations, 
% le nombre maxi de bouteilles et
% le nombre de parametres chimiques

tline = fgetl(fach);
nbstat_ach   = str2num(tline(18:20));
nbmax_bout   = str2num(tline(22:23));
nbparam_chim = str2num(tline(25:26));


% -------------------------------------------------
% comparaison du nombre de stations du fichier .ach
% et du nombre de fichiers du catalogue
% -------------------------------------------------


% test utile ???????????????????????????????????????????????????,,,,,,,,,,
if  nbstat_ach ~= NBFILES

           h = warndlg(['Le nombre de stations du fichier Chimie est different du nombre de fichiers dans le catalogue ',' ach : ', num2str(nbstat_ach), '.. cli : ', NBFILES], 'Arret !!!');
           waitfor(h);
           return
end

% boucle sur les param chimiques
% et lecture des zones suivantes :
% code, unites, responsable des mesures, organisme du responsable,
% precision, format d'ecriture

for i = 1:nbparam_chim
   tline = fgetl(fach);

   tab_code(i,:)     = tline(1:4);
   tab_unit(i,:)     = tline(6:17);
   tab_resp(i,:)     = tline(19:34);
   tab_resporg(i,:)  = tline(36:51);
   tab_precc         = tline(53:60);
   if tab_precc  == ' '
          tab_prec(i)       = 0; 
       else
          tab_prec(i)       = str2num(tab_precc);
   end;
   tab_format(i,:)   = ['%' tline(62:66)];
   nbcar_form(i)     = str2num(tab_format(i,3:3));

end;



% lecture des donnees totales dans le fichier .ach
% (en utilisant le format lu dans les zones parametres)
% -----------------------------------------------------


istat = 0;
blanc1 = ' ';
while ~feof(fach)
  istat = istat+1;
  tline = fgetl(fach);
  ideb  = 7;

  nostat(istat) = str2num(tline(1:3));
  nobout(istat) = str2num(tline(5:6));

   for iparam = 1:nbparam_chim
     tab_param_car    = tline(ideb+1:ideb+nbcar_form(iparam));
     tab_param_flag   = tline(ideb+nbcar_form(iparam) + 2:ideb+nbcar_form(iparam) + 2);
     if  (strcmp(tab_param_car,blanc1)) | (strcmp(tab_param_flag,blanc1))
           tab_param(istat,iparam) = valerr_clc;
           tab_flag(istat,iparam)  = 'm';
       else
           tab_param(istat,iparam) = sscanf(tab_param_car,tab_format(iparam,:));
           tab_flag(istat,iparam) = tab_param_flag;
     end
     ideb = ideb + nbcar_form(iparam) + 3;

   end      % fin de la boucle sur nbparam_chim

end  % fin du while ~feof(fach)

fclose(fach);


% ------------------------------
% traitement station par station
% tri sur la pression
% ------------------------------

ix = 0;                % indice de tous les niveaux d'une meme station
is = 0;                % indice du 1er niveau d'une station
iclc = 0;

while ix(end) < istat
   is    = ix(end) + 1;
   stat1 = nostat(is);
   iclc  = iclc + 1;
   ix    = find(nostat == stat1);
 
% tous les param. et tous les flags pour une station donnee
   tab_param_stat = tab_param(ix,:);
   tab_flag_stat  = tab_flag(ix,:);
   nostat_stat    = nostat(ix);
   nobout_stat    = nobout(ix);

% tri sur la pression (pour une station donnee)
   [tab_param_tri, iprs] = sort(tab_param_stat(:,1));

% pour fichier Matlab (servant a entrer les donnees de chimie (IUEM, Vigo ...)
   nostat_ach = [nostat_ach nostat_stat(iprs)];
   nobout_ach = [nobout_ach nobout_stat(iprs)];
   prs_ach    = [prs_ach;tab_param_tri];

%  for ip = 1:nbparam_chim
%     TABCHIM(:,ip)  = tab_param_stat(iprs,ip);
%     FLAGCHIM(:,ip) = tab_flag_stat(iprs,ip);
%   end 

   TABCHIM  = tab_param_stat(iprs,:);
   FLAGCHIM = tab_flag_stat(iprs,:);
 

   FLAGCHIM = char(FLAGCHIM);
   ii = find(NOM_FILES(iclc,:)=='_');
   nostat_clc = str2num(NOM_FILES(iclc,ii-3:ii-1));
  
   if      nostat_clc == stat1
 
% ouverture du fichier cli (ou clc)
% et lecture de l'etiquette
     
           fic_clc   = netcdf.open  (NOM_FILES(iclc,:),'WRITE');
           lcetis (fic_clc,NOM_FILES(iclc,:));
 
 
           for j = 1:ETIQ.nparc


% remplissage des zones de l'etiquette .cli (ou .clc) 
% a partir de l'etiquette du fichier .ach
% du fichier des codes ??????????????????????????????????????????????,
% precision, unite, responsable mesures, organisme responsable

%               tab_prec(j);
%               tab_unit(j,:);
%               tab_resp(j,:);
%               tab_resporg(j,:);

               iretour = '';
               ecchms(NOM_FILES(iclc,:),fic_clc,tab_code(j,:),COD.nompar(ncod,:),COD.respnom(ncod,:),COD.resporg(ncod,:),COD.unipar(ncod,:),COD.valmin(ncod),COD.valmax(ncod),fillval,TABCHIM(:,j), FLAGCHIM(:,j)',iexist)

               if  ~(isempty(iretour)) 
                      h = warndlg ([messecr, tab_code(j,:)],'Erreur');
                      waitfor(h);
               end;
           end;

           clear TABCHIM  FLAGCHIM ;

           netcdf.close(fic_clc);

        else

           h = warndlg(['Pas de correspondance dans les numeros de station',' ach : ', num2str(stat1), '.. cli : ', num2str(nostat_clc)], 'Attention !');
           waitfor(h);

     end  % fin du test d'egalite entre nostat_clc et stat1

end;   % fin du while ix(end) < istat


% -----------------------------------------------
% sauvegarde d'un fichier Matlab contenant 
% les numeros de station et de bouteille
% nom du fichier : 'identificateur campagne'.mat

  nomficmat = [NOM_FILES(1,1:ii-5) '.mat'];

  command = sprintf('%s%s%s', 'save ', nomficmat, ' -mat nostat_ach nobout_ach prs_ach');
  eval(command);

  clear all;




%function creat_clc ();

% variables globales etiquette unistation
globalVarEtiquni;

% variables globales fichier options par defaut
globalVarDef;

% variables globales des repertoires
globalRepDef; 

% variables pour la fenetre de suivi du traitement
global ficuni_petit ficclc_petit ;

messecr = 'Probleme d''ecriture du parametre '; 

buttliss = '';
iretliss = [];

% ouverture du fichier des messages d'erreur
% ------------------------------------------

ferr = [DIRRESU 'creclc.err'];
f_err = fopen(ferr, 'w');

% initialisations
% ---------------

nbfic_bon       = 0;
nbfic_non_crees = 0;

icalibr=input('Calibration validée ? (O/N) ','s');
icalibr=upper(icalibr);
if strcmp(icalibr,'O')
    datamode_clc= 'calculated';
else
    datamode_clc='not calibrated';
end
 
% --------------------------------------------------
% debut de la boucle sur tous les fichiers existants
% --------------------------------------------------

for i = 1:NBFILES 
      
   ficuni_petit =  NOM_FILES(i,:); 
   l1 = length(IDENTCAMP);
   
   ficuni_sansident=ficuni_petit(l1+1:end);
   ficuni = [REPLECT ficuni_petit];

   fic_cli= netcdf.open(ficuni,'NOWRITE');
   lcetis(ficuni);


% lecture de tous les parametres physiques du fichier .cli
% --------------------------------------------------------
 
   tvalcli    = [];
   tabflagcli = [];
   
   for j = 1:ETIQ.nparp
       [tvalcli(j,:),fillvalue,~,~,~,~,~,tabflagcli(j,:)] = lcpars (ETIQ.codes_paramp (j,:), ficuni);
   
       iflag4 = find(tabflagcli(j,:) == 3 | tabflagcli(j,:) == 4 | tabflagcli(j,:) == 6 | tabflagcli(j,:) == 7);
       tabflagcli(j,iflag4) = 8;
       tvalcli(j,iflag4)    = NaN;
       
       iflag9 = find(tabflagcli(j,:) == 9);
       tabflagcli(j,iflag9) = 8;
       tvalcli(j,iflag9)    = NaN;

   end
% les pressions doivent être des valeurs entières (cas des campagnes issues du CCHDO)
  tvalcli(1,:) = round(tvalcli(1,:));

   
   
   netcdf.close(fic_cli);

% =====================================================

   ifin = find(P_INT==(tvalcli(1,ETIQ.nval)));
   if  isempty(ifin) 
         ifin = length(P_INT);
   end
   tvaliss = nan*ones (ETIQ.nparp-1,ifin);

% extrapolation (surface) et interpolation (milieu)
% -------------------------------------------------

       [messint, messext, tvalint, tabflagint] = intextpol_clc(tvalcli, tabflagcli, f_err, ficuni_petit);

       if   ~isempty(messint) || ~isempty(messext)
           
           nbfic_non_crees = nbfic_non_crees + 1;
           lf = length(ficuni_petit);
           fic_non_crees(nbfic_non_crees,1:lf) = [ficuni_petit(1:lf-4) 'c.nc'];

       end

% lissage - resultat du lissage dans tvaliss
% ------------------------------------------

 for il = 1:ETIQ.nparp-1,
   isok = find(isfinite(tvalint(il,:)));
   % test si aucune bonne valeur : pas de lissage
   if isok > 0
   switch  TYPLISS_DEF(il,1:1)  
      case 'L',
 % retournement des tableaux avant appel lanczos
 % utiliser lanczos de boite a outils matlab
        tval_lanc=tvalint';
        tvaliss (il,isok) = lanczos(tval_lanc(isok,il),P2_DEF(il),P1_DEF(il));

      case 'C',
        a = 1;
        b= ones(P1_DEF(il),1)/P1_DEF(il);
        tvaliss (il,isok) = filtfilt(b,a,tvalint(il,isok));

      case 'B',
% filtre Butterworth avec filtfilt 
         [b,a]  = butter(P2_DEF(il),1/P1_DEF(il));
         tvaliss(il,isok) = filtfilt(b, a, tvalint (il,isok));
      case ' '
         tvaliss(il,:)  = tvalint (il,:);     
   end; % fin du switch
   
  else
   tvaliss(il,:)  = tvalint (il,:);  
   end % fin du test sur le nb de bonnes valeurs (pas de lissage)
   
   isnok = find(~isfinite(tvaliss(il,:)));
   tvaliss(il,isnok)= fillvalue;

 % fin de la boucle sur les calculs de lissage  
 end;
 
% ==================================================================

% Traitement special pour les 2 premieres stations (i<3)

% affichage des valeurs lissees 
% ------------------------------
 
   for il = 1:ETIQ.nparp-1,
      if   (TYPLISS_DEF(il,1:1)~= ' ' && i<3)
         messliss = sprintf('%s%d%s%s','Fichier numero ',i,' - Param ',ETIQ.codes_paramp (il+1,:));
         buttliss = questdlg('Visualisation des donnees lissees ? ' , ...
			  messliss, 'Oui', 'Non', 'Non');

         if strcmp(buttliss, 'Oui')
             [imin,imax] = niv_visu_liss;
             verif_liss(tvalint,tvaliss,il,imin,imax);
         end;
      end
   end

% si l'utilisateur veut modifier les parametres de lissage => arret de creation
% -----------------------------------------------------------------------------

 if  i<3 && ~isempty(buttliss)
     buttmod = questdlg('Modification des parametres de lissage ? ' , ...
			  'Message', 'Oui', 'Non', 'Non');
     if strcmp(buttmod, 'Oui') && strcmp(buttliss, 'Oui') && i< 3
          iretliss = 1;
          h = warndlg('Vous pouvez modifier vos parametres de lissage. ','Pas de creation des fichiers clc');
          waitfor(h);
          break;
     end;
end; 
  
%==================================================================

% decimation (interpolation par interp1 methode lineaire)
% -------------------------------------------------------

   nfinal = length(P_FINAL);
   t = find(P_FINAL>P_INT(1,ifin));

   if (~isempty(t)),
       ifinal = t(1) - 1;
       tvalfinal = zeros (ETIQ.nparp-1,ifinal);
    else
       tvalfinal = zeros (ETIQ.nparp-1,nfinal);
       ifinal = nfinal;
   end;

   if PASDECIM_DEF ~= PASINT_DEF
        for il = 1:ETIQ.nparp-1,
           tvalfinal(il,1:ifinal) = interp1(P_INT(1:ifin),tvaliss(il,1:ifin),P_FINAL(1:ifinal));
        end;
    else 
       for il = 1:ETIQ.nparp-1,
           tvalfinal(il,:) = tvaliss(il,:);
        end;
   end;
  
    
% possibilite de modification de l'identificateur campagne
% --------------------------------------------------------
  
     if  nbfic_bon == 0
        button = questdlg(['Voulez-vous modifier l''identificateur campagne ' IDENTCAMP], ...
			  'Message', 'Oui', 'Non', 'Non');

	            if strcmp(button, 'Oui') 
                    modif_ident; 
                end
     end  	
   
   ficclc_petit = [IDENTCAMP ficuni_sansident];
   ficclc_petit(end-3) = 'c'
   ficclc = [REPECR ficclc_petit];

   if  exist(ficclc,'file') 
        button = questdlg(['Le fichier ' ficclc_petit ' existe deja. Voulez-vous l''ecraser ?'], ...
			  'Attention !!', 'Oui', 'Non', 'Non');
	    if strcmp(button, 'Non') 
            modif_ident;
            ficclc_petit = [IDENTCAMP ficuni_sansident];
            ficclc_petit(end-3) = 'c'
            ficclc = [REPECR ficclc_petit];
          else
            command=['!\rm ' ficclc ];
            eval(command);
        end
   end
 
   fic_clc = netcdf.create(ficclc,'NC_CLOBBER');    

% ==================
% Creation des clc
% ==================
    
    attribut_liss = ''; 
    
    for j = 2:ETIQ.nparp
        
% decodage type de lissage et param.
 
      if  TYPLISS_DEF(j-1,1:1) ~= ' '  
           attribut_liss = char(attribut_liss,[TYPLISS_DEF(j-1,:) '(' num2str(P1_DEF(j-1)) ',' num2str(P2_DEF(j-1)) ')']);
      else
           attribut_liss = char(attribut_liss,'none');
      end;
    end
    
    fic_cli = netcdf.open(ficuni,'NC_NOWRITE');               

% ecriture des attributs globaux, definition des variables
% et des dimensions par rapport au fichier cli
    ETIQ.nvalclc   = ifinal;
    ETIQ.interv = PASDECIM_DEF;
    ecetis(fic_cli, fic_clc,attribut_liss,datamode_clc);

% ecriture des variables (sauf parametres PRES,TEMP,COND,PSAL,OXYL,OXYK ET FLAGS ASSOCIES)
    [ndims, nvars, natts, dimm] = netcdf.inq(fic_cli);
    
    for i_var=1:nvars
       
        [varname, xtype, varDimIDs, varAtts] = netcdf.inqVar(fic_cli,i_var-1);
        
        ii=strcmp(varname,{'PRES','PRES_QC','TEMP','TEMP_QC','PSAL','PSAL_QC', ...
                                     'COND','COND_QC','OXYL','OXYL_QC','OXYK','OXYK_QC', ...
                                     'STATION_PARAMETER'});
        iibon=find(ii==1);        
        if isempty(iibon)
            tabvar = netcdf.getVar(fic_cli,netcdf.inqVarID(fic_cli,varname));
            netcdf.putVar(fic_clc,netcdf.inqVarID(fic_clc,varname),tabvar);
        end
    end
    
    
% =============================================================
% Ecriture des parametres physiques dans le fichier clc
% -------------------------------------------------------------

% Ecriture du parametre pression et des flags qualite (PRES et PRES_QC)
% le flag de PRES est toujours a  1, quelque soit le cas

  netcdf.putVar(fic_clc,netcdf.inqVarID(fic_clc,'PRES'),P_FINAL(1:ifinal));

  clear tabflagpres
  tabflagpres(1:ifinal)=1;
  netcdf.putVar(fic_clc,netcdf.inqVarID(fic_clc,'PRES_QC'),tabflagpres(1:ifinal));
  
% Ecriture des autres parametres (sauf PRES) et des flags associes
% ----------------------------------------------------------------

   for j = 2:ETIQ.nparp,
      
      netcdf.putVar(fic_clc,netcdf.inqVarID(fic_clc,ETIQ.codes_paramp (j,:)),tvalfinal(j-1,1:ifinal));
      
      codvar_qc = [ETIQ.codes_paramp(j,:) '_QC']; 
      netcdf.putVar(fic_clc,netcdf.inqVarID(fic_clc,codvar_qc),tabflagint(j-1,1:ifinal));     

   end
   
   [a,b]=size(ETIQ.codes_paramp);
   netcdf.putVar(fic_clc,netcdf.inqVarID(fic_clc,'STATION_PARAMETER'),[0 0],[b a],ETIQ.codes_paramp');
     
   netcdf.close(fic_cli); 
   netcdf.close(fic_clc);
   

   nbfic_bon = nbfic_bon + 1;
   lf = length(ficclc_petit);
   ficclc_petitbon(nbfic_bon,1:lf) = ficclc_petit(1:lf);

 

% -------------------------------------------------------------------
% fin de la boucle sur tous les fichiers existants (I de 1 a NBFILES)
% -------------------------------------------------------------------

end;

% =====================================================================

% Creation du fichier catalogue 
% -----------------------------

if  nbfic_bon > 0
       nomcat_petit  = ['service/' IDENTCAMP ETIQ.direction '-clc.cat'];
       nomcat = [DIRSERV IDENTCAMP ETIQ.direction '-clc.cat'];
       fcat = fopen(nomcat,'w'); 
       
       nb = sprintf('%3.0f',nbfic_bon);
       nb = strrep(nb,' ','0');
       fprintf(fcat,'%s\n',nb);

       for kk = 1:nbfic_bon
         fprintf (fcat,'%s\n',ficclc_petitbon(kk,:));
       end
end

     if  nbfic_non_crees > 0
          messfin = 'Voir le contenu du fichier resu/creclc.err';
          if nbfic_non_crees > 20
            warndlg(char([fic_non_crees(1,:),' a ',fic_non_crees(nbfic_non_crees,:)], messfin), 'CRECLC : Fichiers non crees');
        else
            warndlg(char(fic_non_crees, messfin), 'CRECLC : Fichiers non crees');
          end
     end;


     if  nbfic_bon > 0
         messfin =  'CRECLC : Traitement termine' ;
         if  nbfic_bon > 20
               messcat = char( 'Generation des fichiers ', ficclc_petitbon(1,:),' a ', ficclc_petitbon (nbfic_bon,:), ' et du fichier Catalogue associe ', nomcat_petit, ' effectuee');
           else
               messcat = char( 'Generation des fichiers ', ficclc_petitbon, ' et du fichier Catalogue associe ', nomcat_petit, ' effectuee'); 
         end
            msgbox(messcat,messfin);
     end;

clear current;


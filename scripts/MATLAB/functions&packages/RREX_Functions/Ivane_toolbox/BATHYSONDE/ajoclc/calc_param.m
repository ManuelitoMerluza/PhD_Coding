function iretour = calc_param(parecr,COD)

% --------------------------------------------
%
%  Fonction calc_param - C.Lagadec - Dec. 98
%
%  Calcul d'un parametre dans les fichiers .clc
%
%    en entree :
%      - param : code du parametre a calculer
%
%      - pref_snn et parsnn ne servent que dans le cas du calcul d'un sigma
%        different de ceux existants.
%
% --------------------------------------------
% 
% Juillet 2010 (C.L.) : remplacement de hdynam initial par hdynam
%                reecrit par Fabienne Gaillard
%  xpr passe en argument et devient AJO.decaldynh
%  le test de la pression de reference se fait sur iref et plus sur le contenu 
%  du message d'erreur
% 
% -------------------------------------------

globalVarEtiquni;
globalRepDef;
globalajo;
globalVarDef;
global COD ;

global  hsuivi_par hsuivi_fic hsuivi_err;
global param_suivi ficclc_petit messerr_suivi; 

messhdy = 'Pression de reference inconnue dans le tableau des pressions';

iretour = '';

sprintf('%s%s','Calcul du parametre : ',parecr)

% valeur erreur (Fillvalue)
fillval = -9999; 

%initialisation de 2 tableaux issus du calcul de gamma
% -----------------------------------------------------
dg_lo_tot = NaN*ones(6500, NBFILES); 
dg_hi_tot = NaN*ones(6500, NBFILES); 


for i = 1:NBFILES
   ficclc_petit =  deblank(NOM_FILES(i,:));

   set(hsuivi_par,'String',param_suivi);
   set(hsuivi_fic,'String',ficclc_petit);

   ficclc = [REPLECT ficclc_petit];

   fic_clc   = netcdf.open  (ficclc,'WRITE');
   lcetis (ficclc);

%  .... Lecture des 3 parametres necessaires aux calculs (PRES,TEMP,PSAL)
   [tprs,~,~,~,prec_prs,~,~,tflag_pres] = lcpars ('PRES',ficclc);
   [ttmp,~,~,~,prec_tmp,~,~,tflag_temp] = lcpars ('TEMP',ficclc);
   [tsal,~,~,~,prec_sal,~,~,tflag_psal] = lcpars ('PSAL',ficclc);

      i9 = find(tflag_pres==9);
      tprs(i9) = NaN;
      i9 = find(tflag_temp==9);
      ttmp(i9) = NaN;
      i9 = find(tflag_psal==9);
      tsal(i9) = NaN;
      
      tparcalc = [];
  
% ===================================================
% Partie Calculs
% ===================================================


% Temperature potentielle  (tet) -> tetai
% -----------------------------

switch parecr
    case 'TPOT'
         pref = 0;
         tparcalc   = tetai (tprs,ttmp,tsal,pref);
         tflagcalc  = max(tflag_temp,tflag_psal);



% Immersion                (imm) ->  depth
% -----------------------------

    case 'IMMR'
         tparcalc  = depth (tprs,ETIQ.lat_deb); 
         tflagcalc = tflag_pres;

 

% Coordonnee z  (negatif)  (zzz) -> prsenz
% -----------------------------

    case 'ZCOO'

%   lecture du param 'sig' 
   
        [tsig,~,~,~,~,~,~,tflag_sigi] = lcpars ('SIGI',ficclc);
        tparcalc  = prsenz(tprs, tsig, ETIQ.lat_deb);
        tflagcalc = max(tflag_pres,tflag_sigi);
   
% Coordonnee z  (positif)   (dep) -> prsenz
% -----------------------------

    case 'DEPH'

%   lecture du param 'sig' 
        [tsig,~,~,~,~,~,~,tflag_sigi] = lcpars ('SIGI',ficclc);
        tparcalc  = prsenz(tprs, tsig, ETIQ.lat_deb);
        tparcalc = abs(tparcalc);
        tflagcalc = max(tflag_pres,tflag_sigi);

%  Vitesse du son (Methode 'Chen') (vsc) -> soundspeed
% -------------------------------


    case 'VSON'
%         la temperature est une T90 (obligatoire)

        tparcalc   = soundspeed90(tsal,ttmp,tprs,'chen');
        tflagcalc  = max(tflag_temp,tflag_psal);


%  Vitesse du son (Methode 'del grosso') (SSDG) -> soundspeed
% -----------------------------


    case 'SSDG'
%         la temperature est une T90 (obligatoire)

        tparcalc = soundspeed90(tsal,ttmp,tprs,'del grosso');
        tflagcalc  = max(tflag_temp,tflag_psal);


%  Anomalie de densite      (sig) -> swstat90
% -----------------------------

    case 'SIGI'
%         la temperature est une T90 (obligatoire)
        [~,tparcalc] = swstat90(tsal,ttmp,tprs); 
        tflagcalc  = max(tflag_temp,tflag_psal);
        



%  Frequence de Brunt-Vaisala au carre  (bv2) -> fbruva
%  -----------------------------------

    case 'BRV2'
   
% test sur le nombre de valeurs pour le calcul de bv2 :
% si nombre de niveaux < 80 : pas de calcul
         a=length(tprs);
         if a < 80 
              tparcalc(1:a) = NaN;
           else
             [tparcalc,~,~] = fbruva(tsal, ttmp, tprs,  ETIQ.lat_deb, AJO.decalbrv2);
             
             inan = find(~isfinite(tparcalc));
             tparcalc(inan)= NaN;
         end;
         tflagcalc  = max(tflag_temp,tflag_psal);
         


%  Frequence de Brunt-Vaisala   (FBRV) -> fbruva
%  ---------------------------

    case 'FBRV'
         
         [~,~, tparcalc] = fbruva(tsal, ttmp, tprs,  ETIQ.lat_deb, AJO.decalfbrv);
         inan = find(~isfinite(tparcalc));
         tparcalc(inan)= NaN;
         tflagcalc  = max(tflag_temp,tflag_psal);
  
         


% Hauteur Dynamique         (DYNH) -> hdynam
% ------------------------------

    case 'DYNH'
   
%  lecture du parametre SIGI 

        tsal35 = [];
        ttmp0  = [];
        
        [tsig,~,~,~,~,~,~,tflag_sigi]  = lcpars('SIGI',ficclc);
        tsal35 (1,1:length(tprs)) = 35.0;
        ttmp0  (1,1:length(tprs)) = 0.;
        [~, tsi35] = swstat90(tsal35,ttmp0,tprs);

        [tparcalc, ~, dist] = hdynam (tprs, tsig, tsi35, AJO.decaldynh);
        tflagcalc  = max(tflag_pres,tflag_sigi);

 
         if  dist < 0
                 iretour = 1;
                 messerr_suivi = char(messerr_suivi,[parecr,'   : Calcul impossible '],messhdy,' ');
                 set(hsuivi_err,'String',messerr_suivi);
                 h = warndlg(messhdy,[parecr,'   : Calcul impossible ']);
                 waitfor(h);
                 return;
        end;


% Vorticite potentielle         (VORPOT) -> vorpot
% ------------------------------
        
    case 'VORP'

%  lecture de bv2 
        
        [tbv2,~,~,~,~,~,~,tflag_brv2]  = lcpars('BRV2',ficclc);
        i9=find(tflag_brv2==9);
        tbv2(i9)=NaN;
        tparcalc  = vorpot (tbv2, ETIQ.lat_deb);
        tflagcalc = tflag_brv2;



% Gamma      (GAMM) -> gamma_n
% ------------------------------
        
    case 'GAMM'
% pour le calcul de Gamma, on a une temprature en T68
% on considre que dans tous les fichiers clc, on a une T90,
% donc multiplication de la T90 par 1.00024 pour obtenir une T68

% modif mai 2004 - C. Lagadec (cas de Cither2)
% pas de calcul de gamma 
%   - si la presion max est superieure a 6000 dbar
%   - si la latitude est superieure a 60 degres Nord
% remplissage des tableaux avec NaN pour le fichier gamma_err.mat
% et avec la valeur erreur de la chaine HYDRO pour le param gam

              if   (tprs(end) > 6000  || ETIQ.lat_deb > 60)

                  tparcalc(1:length(tprs)) = valerr;
                  dg_lo_tot(:,i) = NaN;
                  dg_hi_tot(:,i) = NaN;

               else

                  ttmp68 = ttmp * 1.00024;
                  tprs = tprs';
                  tsal = tsal';
                  ttmp68 = ttmp68';

                  [tparcalc,dg_lo,dg_hi] = gamma_n(tsal,ttmp68,tprs,ETIQ.lon_deb,ETIQ.lat_deb);
                   dg_lo_tot(1:length(dg_lo),i) = dg_lo(1:length(dg_lo));
                   dg_hi_tot(1:length(dg_hi),i) = dg_hi(1:length(dg_hi));
              end
              tflagcalc=max(tflag_psal,tflag_temp);



% Sigma pression i              (si+0 ou 1 ....) -> tetai et swstat90
% ------------------------------


    case 'SI15'
        
         pref = 1500.;
         ttetai = tetai (tprs,ttmp,tsal,pref);
         [~,tparcalc] = swstat90(tsal,ttetai,pref*ones(size(tprs)));
         tflagcalc=max(tflag_psal,tflag_temp);
end

   if    strcmp(parecr(1:3),'SIG') && ~strcmp(parecr(4:4),'I')
         pref = str2double(parecr(4:4))*1000.;

         ttetai = tetai (tprs,ttmp,tsal,pref);
         [~,tparcalc] = swstat90(tsal,ttetai,pref*ones(size(tprs)));

         tparcalc  = tparcalc';
         tflagcalc = max(tflag_psal,tflag_temp);

% fin de la boucle sur les calculs
% --------------------------------
   end;

% ========================================================

% Partie Lissage et ecriture

% ========================================================

   isok = find(isfinite(tparcalc));
   tvaliss = NaN*ones(size(tparcalc));

% lissage 
% -------
 
   switch     TYP_LISS(1:1)
       case 'L' 
           tvaliss  = lanczos(tparcalc,P2_LISS,P1_LISS);
           tvaliss = tvaliss';
 
       case 'C'
           a=1;
           b = ones(P1_LISS,1)/P1_LISS;
           tvaliss(isok)  = filtfilt(b,a,tparcalc(isok));
           
       case 'B'
% filtre Butterworth avec filtfilt 
           [b,a]  = butter(P2_LISS,1/P1_LISS);
           tvaliss(isok) = filtfilt(double(b), double(a), tparcalc(isok));
           
       case ' '
           tvaliss(1:size(tparcalc)) = NaN;
           tvaliss(isok)  = tparcalc(isok);
           
  end;


% --------------------------------------------------------
% ecriture du parametre calcule dans le fichier Unistation
% --------------------------------------------------------

% le param existe-t-il dans le fichier Netcdf ? si oui : iexist = 1

       iexist = 0;
       
       noparnc = strfind(reshape(ETIQ.codes_paramp',1,4*ETIQ.nparp),parecr);
       noparnc = ceil(noparnc/4);
       
       if  ~isempty(noparnc)
           iexist = 1;
       end;
  
% decodage de la partie Lissage pour ajout d'un attribut
% recherche des infos sur le parametre dans la structure COD
% ----------------------------------------------------------
       attribut_liss = 'none';
       attribut_meth = 'none';
       attribut_prec = fillval;
       
       

       ncod = strfind(reshape(COD.codpar',1,4*COD.npar),parecr);
       ncod = ceil(ncod/4);
       
       if isempty(ncod)
           messerr_suivi = [parecr,' : Parametre inexistant dans le fichier des Codes. Pas d ecriture dans le fichier clc'];
           set(hsuivi_err,'String',messerr_suivi);
           mess_err = sprintf('%s%s\n%s',parecr,' : Parametre inexistant dans le fichier des Codes.','Pas d ecriture du param ds ficher clc')
           iretour = 1;
           h1=warndlg (mess_err,'Attention !');
           waitfor(h1);
           return
       else
           if  TYP_LISS (1:1) ~= ' ' 
              attribut_liss = [TYP_LISS '(' num2str(P1_LISS) ',' num2str(P2_LISS) ')'];
           end;

% decodage de la partie algorithme pour ajou d'un attribut
% (pour param BRV2, FBVR (decalage) et DYNH (niveau de ref)
% ---------------------------------------------------------------

         switch parecr
               case 'BRV2'
                    attribut_meth = ['Dec:' num2str(AJO.decalbrv2)];
               case 'FBRV'
                    attribut_meth = ['Dec:' num2str(AJO.decalfbrv)];
               case 'DYNH'
                    attribut_meth = ['Ref:' num2str(AJO.decaldynh)];         
               case 'VSON'
                    attribut_meth =  'CHEN';
               case 'SSGR'
                    attribut_meth =  'GROSSO';
         end;
 
% fevrier 2014 . CL
% ajout de l'attribut precision pour les parametres physiques calcules
% TPOT : idem TEMP
% SIGI : calcul avec TEMP
% SIG0 à SIG6 et SI15 : calcul avec TPOT   
    
         if strcmp(parecr,'TPOT')
                 attribut_prec = prec_tmp;
         elseif strcmp(parecr,'SIGI')
                 Smax=tsal(end);
                 Tmax=ttmp(end);
                 Pmax=tprs(end);
                 tsigmax=tvaliss(end);
                 attribut_prec=calc_prec_sig(prec_tmp,prec_sal,Smax,Tmax,Pmax,tsigmax);
         elseif strcmp(parecr(1:3),'SIG') || strcmp(parecr(1:4),'SI15')
                 Smax=tsal(end);
                 [ttpot,~,~,~,prec_tpot,~,~,~] = lcpars ('TPOT',ficclc);
                 tsigmax=tvaliss(end);
                 Tpmax=ttpot(end);
                 Pmax=tprs(end);
                 attribut_prec=calc_prec_sig(prec_tpot,prec_sal,Smax,Tpmax,Pmax,tsigmax);
         end
 
              nomparamecr = deblank(COD.nompar(ncod,:));
              codflag = [parecr '_QC'];              
              nomflag = [deblank(COD.nompar(ncod,:)) ' quality flag'];
              
              isnok = find(~isfinite(tvaliss));
              tvaliss(isnok) = fillval;
              tflagcalc(isnok) = 9;
              ecpars(ficclc,fic_clc,parecr,nomparamecr,COD.unipar(ncod,:),attribut_prec,attribut_liss,attribut_meth, ...
                  COD.valmin(ncod),COD.valmax(ncod),fillval,tvaliss, ...
                  codflag,nomflag,tflagcalc,iexist);
     
     end
       
  netcdf.close (fic_clc);



% fin de la boucle sur les fichiers (I de 1 a NBFILES)
% ----------------------------------------------------

end


% **************************************************************
% stockage des elements concernant le parametre calcule
% uniquement si aucun pb de calcul ou d'ecriture
% (c'est-a-dire si iretour est vide)
% (pour sauvegarde eventuelle dans le
% fichier des parametres calcules .ajo)
% -----------------------------------------------------


      ECR.nbpar = ECR.nbpar + 1;
      ECR.param(ECR.nbpar,:)   = parecr;
      ECR.decal(ECR.nbpar)     = 0;
      
      if  strcmp(parecr ,'BRV2') 
          ECR.decal(ECR.nbpar)     = AJO.decalbrv2;
      end
      if  strcmp(parecr , 'FBRV') 
          ECR.decal(ECR.nbpar)     = AJO.decalfbrv;
      end
      if  strcmp(parecr , 'DYNH')
            ECR.decal(ECR.nbpar)   = AJO.decaldynh;
      end;
      ECR.typliss(ECR.nbpar,:)     = TYP_LISS(1:1);
      ECR.p1liss(ECR.nbpar)        = P1_LISS;
      ECR.p2liss(ECR.nbpar)        = P2_LISS;


 



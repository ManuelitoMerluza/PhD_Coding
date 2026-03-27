function verif_station()

globalVarEtiquni;                      

globalRepDef;

globalajo;

camp = '';
           
% lecture de tous les fichiers de la liste pour recuperation des parametres
% -------------------------------------------------------------------------

 for i = 1:NBFILES 
  
    ficuni = deblank([REPLECT NOM_FILES(i,:)])
    n = length(ficuni);
    suff = ficuni(n-6:n);

    if   suff ~= ficuni(n-6:n),
           mess_suff = sprintf('%s\n%s%s%s','Le suffixe n''est pas le meme dans tous les fichiers.  ',suff,'  ', NOM_FILES(i,:));
	   h = warndlg(mess_suff,'Aucun traitement possible');
           waitfor(h);
           break;
    end;

% lecture de la pression et du nom des codes parametre

%     lcetis(ficuni);
      a=ncinfo(ficuni);
      dimlength  = {a.Dimensions.Length};
      [~,ldim]=size(dimlength);
      ETIQ.nval  = dimlength{7};
      ETIQ.nparp = dimlength{6};
 %test si chimie
      if ldim > 8
          ETIQ.nparc = dimlength{9};
       else
          ETIQ.nparc = 0;
     end
 
      if ETIQ.nparc > 0
           ETIQ.codes_paramc  = ncread(ficuni,'STATION_PARAMETER_CHIM')';
      end

      ETIQ.codes_paramp  = ncread(ficuni,'STATION_PARAMETER')';

      [tprs,fillvalue,LABPARP_TOT,units,~,valmin,valmax,codflag]   = lcpars ('PRES', ficuni);
     
     for jj= 2:ETIQ.nparp
         long_name=ncreadatt(ficuni,ETIQ.codes_paramp(jj,:),'long_name');
         LABPARP_TOT = strvcat(LABPARP_TOT,long_name);
     end
     
     if  i == 1
          CODPARP_TOT  = ETIQ.codes_paramp;
          NPARP_TOT = ETIQ.nparp;
          PRESENCP_TOT(1:NPARP_TOT) = ' ';
          PRESENCP_TOT = char(PRESENCP_TOT)';
          if ETIQ.nparc > 0
                    CODPARC_TOT  = ETIQ.codes_paramc;
                    NPARC_TOT = ETIQ.nparc;
                    PRESENCC_TOT(1:NPARC_TOT) = ' ';
                    PRESENCC_TOT = char(PRESENCC_TOT)';
          end;
     end;


% codes physiques
% ---------------

    if  strcmp(CODPARP_TOT,ETIQ.codes_paramp)
          for kk = 1:ETIQ.nparp
            ll = strmatch(ETIQ.codes_paramp(kk,:),CODPARP_TOT,'exact');
            if isempty(ll)
                 CODPARP_TOT  = [CODPARP_TOT;ETIQ.codes_paramp(kk,:)];
                 PRESENCP_TOT = [PRESENCP_TOT;'*'];
                 NPARP_TOT    = NPARP_TOT + 1;
            end
          end
    
    end;
 
 
    if  i == 1
       PMINTOT = tprs(1);
       PMAXTOT = tprs (ETIQ.nval);
       camp          = ncreadatt(ficuni,'/','CRUISE_NAME');
     else
       PMINTOT = min(tprs(1),PMINTOT);
       PMAXTOT = max(tprs (ETIQ.nval),PMAXTOT);
       if ~strcmp(camp,ncreadatt(ficuni,'/','CRUISE_NAME'))
           camp          = strvcat(camp,ncreadatt(ficuni,'/','CRUISE_NAME'));
       end
    end;

 end;

clear ll kk ;

clear ficuni n;


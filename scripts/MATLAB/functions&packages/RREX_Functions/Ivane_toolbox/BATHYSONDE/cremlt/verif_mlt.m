function verif_mlt(paramref)

globalVarEtiquni;
globalRepDef;
globalVMLT;

tabpar = '';

for i = 1:NBFILES
    ficuni   = deblank([REPLECT NOM_FILES(i,:)]);
 % test si le param choisi figure dans tous les fichiers
   for jj=1:size(ETIQ.codes_paramp,1)
       if strcmp(paramref,ETIQ.codes_paramp(jj,:))
          tabpar = ncread(ficuni,paramref);
       end
   end
    if isempty(tabpar)
        warndlg(['Le parametre choisi n''existe pas dans le fichier ' ficuni],'Arret du traitement');
        return
    end
    
    if  i == 1
            VMINTOT = min(tabpar);
            VMAXTOT = max(tabpar);
      else
      	    VMINTOT = min(min(tabpar),VMINTOT);
       		VMAXTOT = max(max(tabpar),VMAXTOT);
    end;

end


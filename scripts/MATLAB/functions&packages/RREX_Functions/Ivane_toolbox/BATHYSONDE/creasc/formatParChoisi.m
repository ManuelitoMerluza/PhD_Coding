function formatParChoisi()

% Cette fonction permet de remplir la variable CHOIX.format. 

globalVarEtiquni;
global COD CHOIX;
globalRepDef;


ficent=[REPLECT NOM_FILES(1,:)];

 if  CHOIX.nbparp > 0
         nbp = CHOIX.nbparp;
         CHOIX.cod = CHOIX.codp;
         [messerr] = lfcod_phys;
         if ~isempty(messerr)
           return
         end
 else
         nbp = CHOIX.nbparc;
         CHOIX.cod = CHOIX.codc; 
         [messerr] = lfcod_chim;
         if ~isempty(messerr)
           return
         end
 end

  for i=1:nbp
 
    % recherche du format dans le fichier des codes
 	for j=1:COD.npar
		if strcmp(CHOIX.cod(i,:),COD.codpar(j,:))
		    CHOIX.format(i,:) = COD.forpar(j,:);
        end;
 	end;

    % recherche du nom du parametre et de ses unites dans le fichier Unistation
    
       CHOIX.name  = strvcat(CHOIX.name,ncreadatt(ficent,CHOIX.cod(i,:),'long_name'));
       CHOIX.units = strvcat(CHOIX.units,ncreadatt(ficent,CHOIX.cod(i,:),'units'));

  end;


 

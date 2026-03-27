function creat_asci_standard(option)

globalVarEtiquni;
global CHOIX;
globalVarDef;
globalRepDef;

valerr_ascii = -9.999;
ind_flag=input('Ecriture des flags dans les fichiers ASCII ? (O/N) ','s');
ind_flag=upper(ind_flag);

nbparam = CHOIX.nbparp + CHOIX.nbparc;

for i = 1:NBFILES 

   ficuni = [REPLECT NOM_FILES(i,:)];
   l=length(deblank(NOM_FILES(i,:)));
   
% creation de fichier echange : suffixe 'ecp' ou 'ecc'
% ---------------------------------------------------

	if option == 'unique'

	   if  CHOIX.nbparc==0
		   ficsortie = [NOM_FILES(i,1:l-7) '.ecp'];
       else
		   ficsortie = [NOM_FILES(i,1:l-7) '.ecc'];
 	   end;
       
        hbar = waitbar(0,['Creation du fichier ',ficsortie]);

       ficsortie = [REPECR  ficsortie];
       fid = fopen(ficsortie,'w');

	elseif option == 'double'

% creation de fichiers ASCII : suffixes 'desc' et 'asc'
% -----------------------------------------------------

	   ficsortiedesc =  [NOM_FILES(i,1:l-7) '.desc'];
	   ficsortieasc  =  [NOM_FILES(i,1:l-7) '.asc'];
       
       hbar = waitbar(0,['Creation des fichiers ',ficsortiedesc, ' et ',ficsortieasc]); 
       
       ficsortiedesc = [REPECR ficsortiedesc];
       ficsortieasc  = [REPECR ficsortieasc];
       
	   fid = fopen(ficsortiedesc,'w');
	   fidasc = fopen(ficsortieasc,'w');
	end;

     fic_uni = netcdf.open(ficuni,'NOWRITE');
     lcetis(ficuni);
     
     [tprs,fillvalue,long_name,units,~,valmin,valmax,codflag]   = lcpars ('PRES', ficuni);

nostation = sprintf('%3.3i',ETIQ.station_number);
nomcamp   = ETIQ.cruise;
nombateau = ETIQ.navire;
typesonde = ETIQ.probe_type;
comment1 ='*No station,nom campagne,nom navire,type sonde';
comment2 ='*(i3,2(1x,a16),1x,a6)';
fprintf(fid,'%s %s %s %s\n%s\n%s\n',nostation,nomcamp,nombateau,typesonde,comment1,comment2);  

fond = ETIQ.sonde_deb;
pmin = tprs(1);
pmax = tprs(end);
date = ETIQ.station_date_begin';
NVAL = ETIQ.nval;
lat  = num2str(ETIQ.lat_deb);
lon  = num2str(ETIQ.lon_deb);
comment3 = '*Date,heure,lat.,lon.,nb parametres,nb mesures,fond,pmin,pmax';
comment4 =  '*(a8,1x,i2,i2,1x,a11,1x,a11,1x,i2,4(1x,i4))';
fprintf(fid,'%s %s %s %s %d %d %d %d %d \n%s\n%s\n',date(1:8),date(9:12),lat,lon,nbparam,NVAL,fond,pmin,pmax,comment3,comment4);

% il n'y a pas de flags à 8, sauf pour les param physiques des fichiers clc
if strcmp(ind_flag,'O')
    if  CHOIX.nbparc > 0
        comment5='*Quality flag : 1: good, 3: doubtful, 4:bad, 9: No data';
    else
        if  strcmp(CHOIX.typfic,'cli.nc')
            comment5 = '*Quality flag : 1: good, 4: bad, 9: No data' ;  
        else
            comment5 = '*Quality flag : 1: good, 8: interpolated, 9: No data';
        end
    end
    fprintf(fid,'%s\n',comment5);
end

for j=1:nbparam
	fprintf(fid,'%s%s%s\n',CHOIX.name(j,:),' ',CHOIX.units(j,:));
 end;

%==========================================================================

if option=='double'
        fclose(fid);
	    fid = fidasc;
end;



% ecriture des donnees   
% --------------------

% lecture des parametres physiques 
cflag    = '';
tabparam = [];

for j=1:CHOIX.nbparp
    [tab1,fillvalue,long_name,units,~,valmin,valmax,codflag]   = lcpars ( CHOIX.codp(j,:), ficuni);
    i9=find(codflag==9);
    tab1(i9)=valerr_ascii;
    if strcmp(ind_flag,'N')
        i4=find(codflag==4);
        tab1(i4) = valerr_ascii;
    end
    tabparam(:,j) = tab1';
    cflag(:,j)=num2str(codflag); 
end;     

% lecture des param chimiques
for j=1:CHOIX.nbparc
       paramc = CHOIX.codc(j,:);
       [tabchim,flagchim,long_name,units,~,resp_param,org_resp,~,valid_min, valid_max] = lcchms(paramc, ficuni); 
       i9=find(flagchim==9);
       tabchim(i9) = valerr_ascii; 
       if strcmp(ind_flag,'N')
           i4=find(flagchim==4);
           tabchim(i4) = valerr_ascii;
       end
	   tabparam(1:ETIQ.nbottles,j) = tabchim;	
	   cflag(1:ETIQ.nbottles,j) = num2str(flagchim);
end;

if CHOIX.nbparp > 0
	
 % choix d'echantillonnage pour la pression minimum  
 m = 1;

 if CHOIX.pmintot < pmax
    while tabparam(m,1) < CHOIX.pmintot
 	m = m+1;
    end;
 end; 



for j=m:CHOIX.echant:NVAL

 %-------------------------------------------------------------%
 %on sort du for si la pression maximum choisie est  depassee  %
 %-------------------------------------------------------------%

 	if tabparam(j,1)>CHOIX.pmaxtot
 		break;
 	end;

  for k = 1:nbparam
      if strcmp(ind_flag,'N') 
         formatpc=[' %' CHOIX.format(k,:)];
         fprintf(fid,formatpc,tabparam(j,k));
      else
        formatpc = [' %' CHOIX.format(k,:),' %c'];
        fprintf(fid,formatpc,tabparam(j,k),cflag(j,k));
      end
  end
    formatpc = '\n';
  fprintf(fid,formatpc);
end; 


elseif CHOIX.nbparp == 0  

for j=1:ETIQ.nbottles
 for k=1:nbparam
     if strcmp(ind_flag,'N')
         formatpc=[' %' CHOIX.format(k,:)];
         fprintf(fid,formatpc,tabparam(j,k))
     else
     formatpc = [' %' CHOIX.format(k,:),' %c'];
	 fprintf(fid,formatpc,tabparam(j,k),cflag(j,k));
     end
 end; 
     formatpc = '\n';
    fprintf(fid,formatpc);
end

end; 

 
 clear tabparam;
 close(hbar);
 fclose(fid);
 netcdf.close(fic_uni);

 end;

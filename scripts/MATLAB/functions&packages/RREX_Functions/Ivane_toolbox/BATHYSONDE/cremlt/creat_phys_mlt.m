function creat_phys_mlt 


%----------------------------------------
%						       	
% creation d'un fichier Multistation      
% modifie par C. Lagadec en aout 2002
%
% preparation des variables   
% 							
%----------------------------------------

globalVarEtiquni ;
globalVMLT ;
globalRepDef;
globalVarASCI;

fillval = -9999;

MLT.pi_name(1:NBFILES,1:16)        = ' ';
MLT.ship_name(1:NBFILES,1:30)      = ' ';
MLT.pi_organism(1:NBFILES,1:16)    = ' ';
MLT.inst_reference(1:NBFILES,1:64) = ' ';
MLT.ship_wmo_id(1:NBFILES,1:16)    = ' ';
MLT.cruise_name(1:NBFILES,1:16)    = ' ';
MLT.data_processing(1:NBFILES,1:16)= ' ';
MLT.data_mode                      = '';
MLT.precision                      = NaN*ones(NBFILES,NB_PARAMP_CHOISI);

NOM_FIC_DEF =sprintf('%s%s%s%s',IDENTCAMP,'_',CODE_REF(1:4),'.nc');  
MLT.parameters = [CODE_REF;CODES_PARAMP_CHOISI];
nbparam_choisi = NB_PARAMP_CHOISI + 1;
button = questdlg(['Le nom du fichier multistation que vous voulez creer sera par defaut ' NOM_FIC_DEF ' .Desirez-vous le modifier ?'], ...
		   'Message','Oui','Non','Non');

if strcmp(button, 'Oui')
	nom_fic_mlt;
else
	MLT.nomfic = NOM_FIC_DEF;
end ;


MLT.latmax  = -999.;
MLT.latmin  =  999.;
MLT.lonmax  = -999.;
MLT.lonmin  =  999.;


% initialisation tableau 3D des donnees 
% (station - parametres - niveaux)
% -------------------------------------

data_profiles=NaN* ones(NBFILES, nbparam_choisi, NB_NIV); 

% on regarde dans le 1er fichier clc s'il existe une zone 
% COMMENT_CALIB (pour introduction dans MLT

COMMENT_CLC ='';
ficuni      = deblank([REPLECT NOM_FILES(1,:)]);

% recherche des variables globales
a         = ncinfo(ficuni);
nameAtt   = {a.Attributes.Name};
[~,nbAtt] = size(nameAtt);

for gg=1:nbAtt
   if strcmp(nameAtt{gg},'COMMENT_CALIB')
      COMMENT_CLC = ncreadatt(ficuni,'/','COMMENT_CALIB');
end
end


% recuperation des lat et long min et max pour la constitution de la GRILLE
% -------------------------------------------------------------------------

MLT.ficclc = '';
for ista = 1:NBFILES

	ficuni = deblank([REPLECT NOM_FILES(ista,:)])
	fic_uni= netcdf.open(ficuni,'NOWRITE');
	lcetis(ficuni);

	MLT.latmax  = max(MLT.latmax, ETIQ.lat_deb);
	MLT.latmin  = min(MLT.latmin, ETIQ.lat_deb);
	MLT.lonmax  = max(MLT.lonmax, ETIQ.lon_deb);
	MLT.lonmin  = min(MLT.lonmin, ETIQ.lon_deb);

% lecture de tous les parametres physiques 
% choisis par l'utilisateur : la lecture des parametres physiques
% se fait dans la boucle d'interpolation
% ------------------------------------------------------

	MLT.lat_begin(ista) = ETIQ.lat_deb;
	MLT.lon_begin(ista) = ETIQ.lon_deb;
    if  ETIQ.lat_fin == 0
	    MLT.lat_end(ista) = -9999;
          else
	    MLT.lat_end(ista) = ETIQ.lat_fin;
    end  

    if  ETIQ.lon_fin == 0
	    MLT.lon_end(ista) = -9999;
          else
	    MLT.lon_end(ista) = ETIQ.lon_fin;
    end
    lpi=length(ETIQ.pi);
    if lpi>16
         lpi=16;
    end
    lorg= length(ETIQ.orgresp);
    if lorg > 16
          lorg=16;
    end

    MLT.pi_name(ista,1:lpi)                           = ETIQ.pi(1:lpi);
    MLT.pi_organism(ista,1:lorg)                      = ETIQ.orgresp(1:lorg);
    MLT.ship_name(ista,1:length(ETIQ.navire))         = ETIQ.navire;   
    MLT.direction (ista,:)                            = ETIQ.direction;
    MLT.cruise_name(ista,1:length(ETIQ.cruise))       = ETIQ.cruise;
    MLT.ship_wmo_id(ista,1:length(ETIQ.ship_wmo_id))  = ETIQ.ship_wmo_id;

    inst = [deblank(ETIQ.probe_type) ' - ' num2str((ETIQ.probe_number))];
    MLT.inst_reference(ista,1:length(inst))     = inst;

    MLT.ficclc = strvcat(MLT.ficclc,NOM_FILES(ista,:));

    MLT.data_processing(ista,1:length(ETIQ.dataprocessing))    = ETIQ.dataprocessing;
               
    MLT.dat_begin (ista,:)   = ETIQ.station_date_begin;
    MLT.dat_end (ista,:)     = ETIQ.station_date_end;
    MLT.juld_begin(ista)     = ETIQ.juld_begin;  
    MLT.juld_end(ista)       = ETIQ.juld_end; 
    MLT.station_number(ista) = ETIQ.station_number;
    MLT.cast(ista)           = ETIQ.cast;
    MLT.nbottles(ista)       = ETIQ.nbottles;
    MLT.data_mode(length(MLT.data_mode)+1:length(MLT.data_mode)+3)     = ETIQ.data_mode(1:3);

% sonde station : on prend la valeur 'Sonde fin de profil' 
%                 si vide ou egale a zero, on prend
%                 'Sonde debut de profil' 
 
	    MLT.sonde(ista) = ETIQ.sonde_deb ;
        if   ~isempty(ETIQ.sonde_deb)
              if  ETIQ.sonde_deb > 0
                    MLT.sonde(ista) = ETIQ.sonde_deb ;
              end
        end
 
        [tabprs,fillvalue,longname,units,~,vmin, vmax,~] = lcpars ('PRES', ficuni);
	    MLT.prmax(ista) = tabprs(end);
        MLT.NVAL=length(tabprs);
        
        tabpar = zeros(nbparam_choisi,MLT.NVAL);
        [tabref,fillvalue,longname,units,~,vmin,vmax,~] = lcpars (CODE_REF, ficuni);
        
% - Tri des donnees et suppression des valeurs identiques
%   pour le vecteur Param. de reference (tabref)
% - Suppression des valeurs identiques
% ------------------------------------------------------


         [tabreft,indic_reft] = sort(tabref);


         diffref  = diff(tabreft);
         ind_diff = find(diffref==0);

         if ~isempty(ind_diff),
            tabreft(ind_diff)=[];
         end

% interpolation sur la GRILLE finale
% ----------------------------------
   
	for n = 1:nbparam_choisi
        
        [tabpar(n,:),tfillv(n),longname,units,precision,tvmin(n), tvmax(n),~] = lcpars (MLT.parameters(n,:), ficuni);
               if n == 1
                   tlongname = longname;
                   tunits    = units;
                else
                   tlongname=char(tlongname, longname);
                   tunits   = char(tunits,units);
               end
                MLT.precision(ista,n) = precision;

                tabpart = tabpar(n,indic_reft);
                if ~isempty(ind_diff),
                    tabpart(ind_diff)=[];
                end;

% remplacement de la valeur Fillvalue  par NaN 
                a=[];
                a=find(tabpart==tfillv(n));
               
                tabpart(a) = NaN;

% suppression des NaN avant l'interpolation : 
% au niveau des clc, NaN presents dans brv2 et vrp a cause du decalage de 25 dbar
                
                a=find(isfinite(tabpart));
                if ~isempty(a)
		            tabint(1:NB_NIV) = interp1(tabreft(a), tabpart(a),GRILLE(1:NB_NIV));
                end 
   
%remise des NaN apres interpolation 
                b=find(~isfinite(tabpart));
                tabint(b) = NaN;               
                data_profiles(ista, n, 1:NB_NIV) = tabint(1:NB_NIV);

	end ;

 
	netcdf.close(fic_uni) ;

% stockage de la valeur max du parametre de reference (par profil): 
% le param de ref est toujours le 1er param ecrit dans le fichier Multistation
% ----------------------------------------------------------------------------

    a = find(isfinite(data_profiles(ista, 1, :))) ;  
    MLT.parrefmax(ista) = data_profiles(ista,1,a(end));
                     
end;

MLT.parametre_ref  = deblank(CODE_REF);

MLT.nbniv  = length(GRILLE);
MLT.nbprof = NBFILES;

ficmlt_nc = [MLT.nomfic(1:length(MLT.nomfic)-2) 'nc'];

msg_error1  = nc_ARGO_mlt_header(ficmlt_nc);

% definition des variables (nb_param_choisi)
% Boucle sur le nombre de parametres choisis.
% MLT.parameters contient egalement les donnees du parametre de reference
% -----------------------------------------------------------------------

fmlt = netcdf.open(ficmlt_nc, 'NC_WRITE');
netcdf.reDef(fmlt);

for i = 1 : nbparam_choisi

% lecture des dimensions 
     dimnprof = netcdf.inqDimID(fmlt,'N_PROF') ;
     dimnlev = netcdf.inqDimID(fmlt,'N_LEVELS');
 
     creat_newvar(fmlt,MLT.parameters(i,:),'NC_FLOAT',[dimnlev,dimnprof],'long_name',deblank(tlongname(i,:)),'units',deblank(tunits(i,:)),'Valid_min',tvmin(i),'Valid_max',tvmax(i),'_FillValue',single(tfillv(i)));
     creat_newvar(fmlt,[MLT.parameters(i,:) '_PREC'],'NC_FLOAT',dimnprof,'long_name',[deblank(tlongname(i,:)) ' precision'],'_FillValue',single(tfillv(i)));
end

% definition du parametre de reference (vecteur)
creat_newvar(fmlt,'PARAM_REF','NC_FLOAT',[dimnlev],'long_name',deblank(tlongname(1,:)),'units',deblank(tunits(1,:)),'Valid_min',tvmin(1),'Valid_max',tvmax(1),'_FillValue',single(tfillv(1)));

netcdf.endDef(fmlt);

% ecriture du parametre de reference
ncwrite(ficmlt_nc,'PARAM_REF',GRILLE');

for i = 1 : nbparam_choisi

% ecriture des valeurs des parametres 

      GRILLE_param(:,:) = data_profiles(:,i,:); 
      ncwrite(ficmlt_nc,MLT.parameters(i,:),GRILLE_param(:,:)');
      isnok = find(~isfinite(MLT.precision(:,i)));
      MLT.precision(isnok,i) = single(fillval);
      ncwrite(ficmlt_nc,[MLT.parameters(i,:) '_PREC'],MLT.precision(:,i));
end

netcdf.close(fmlt);
%clear all;

display ('   Bravo !! Fichier Multistation cree !!!!!')

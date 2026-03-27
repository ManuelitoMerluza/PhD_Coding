

%-------------------------------------------------------------------------------
%c
%c  hyd_lec_mlt    - Extraction des profils concernant une zone et une
%		     couche dans une liste de fichiers mlt.nc
%c
%-------------------------------------------------------------------------------
%  version:
%  --------
%  1.01                                               27/03/2001 F.Gaillard
%  1.02                                               18/03/2002 F.Gaillard
%  1.03                                               18/07/2005 T.Loaec
%	prise en compte du QC (flag de signalement de double
%       dans les fichiers H2V2)
%-------------------------------------------------------------------------------

function  hyd_lec_mlt(~, nbfic_mlt, fic_MLT_NC, latdeb_don_ok, londeb_don_ok, ztop, zbot)


parameters;


% initialisations
% ---------------

tab_param_tot = ['DEPH';'PRES';'TEMP';'PSAL';'TPOT';'SIGI';'SIG0';'SIG1';'SI15'; ...
             'SSDG';'SIG2';'SIG3';'SIG4';'SIG5';'SIG6';'BRV2';'VORP';'GAMM';'DYNH';'OXYL';'OXYK'];
[nb_param_tot,~] = size(tab_param_tot);

camp_sta           = '';
datedeb_sta        = '';
datefin_sta        = '';
latdeb_sta         = [];
londeb_sta         = [];
latfin_sta         = [];
lonfin_sta         = [];
juldeb_sta         = [];
julfin_sta         = [];
pi_sta             = '';
pi_org_sta         = '';
codwmo_sta         = '';
navire_sta         = '';
direction_sta      = '';
inst_reference_sta = '';
sondes_sta         = [];
pmax_sta           = [];
prefmax_sta        = [];
station_number_sta = [];
flag_dbl_sta       = [];

% initialisation des tableau : PARAM_sta = ''
% initialisation des indicateurs : ilower(PARAM) = ''
for jj = 1:nb_param_tot
   command1 = sprintf('%s%s', tab_param_tot(jj,:) ,'_sta = [];');
   eval(command1);

   command2 = sprintf('%s%s%s', 'i', lower(tab_param_tot(jj,:)) ,' = [];'); 
   eval(command2);
end

prec_var_sta = [];

ref_date = '19500101000000'; 
     
% transformation dates limites d'extraction en dates julien
% quand pas extraction par mois
% ---------------------------------------------------------

if  isempty(mois_extract)
	jul_extract_min = jul_0h(dates_extract(1),dates_extract(2),dates_extract(3));
	jul_extract_max = jul_0h(dates_extract(4),dates_extract(5),dates_extract(6));


	jul_ref_date    = jul_0h(str2double(ref_date(1:4)), ...
                          	 str2double(ref_date(5:6)), ...
                         	 str2double(ref_date(7:8)));	
	jul_extract_min = jul_extract_min - jul_ref_date;
	jul_extract_max = jul_extract_max - jul_ref_date;
end
  


%  =================================================
%     Boucle sur les fichiers Multistation Netcdf
%  =================================================


for ific = 1:nbfic_mlt


% recuperation des elements dans le fichier Multistation Netcdf
% -------------------------------------------------------------

   nomfic = deblank(fic_MLT_NC(ific,:));
%   if strfind(nomfic,'DEPH')
    if strfind(nomfic,'.nc')
   nc = netcdf.open(nomfic,'NOWRITE');

   ref_date_don     = ncreadatt(nomfic,'/','Reference_date_time');
   if ~strcmp(ref_date,ref_date_don)
        fprintf(['Date de reference invalide  ',  ref_date_don, ' ',nomfic]);
        break
   end
  
      project              = ncreadatt(nomfic,'/','Project_name');
      
      % lors de la recréation des MLT NETCDF (2014 - CDD M.Hamon)
      % a cause de l'absence de clc correspondants,
      % certains fichiers ont été transcodés à partir des anciens MLT
      % (programme transform_mlt)
      % dimensions non identiques :
      % PI_NAME : de 64 car a 16
      % PI_ORGANISM : de 32 car à 16
      % SHIP_NAME : de 16 car à 30
      
      pi                   = ncread(nomfic,'PI_NAME')';
      [s1,~] = size(pi);
      clear pi_don
      pi_don(1:s1,1:16) = pi(1:s1,1:16);
           
      pi_org               = ncread(nomfic,'PI_ORGANISM')';
      [s1,~] = size(pi_org);
      clear pi_org_don
      pi_org_don(1:s1,1:16) = pi_org(1:s1,1:16);
      
      codwmo_don           = ncread(nomfic,'SHIP_WMO_ID')';
      navire               = ncread(nomfic,'SHIP_NAME')';
      [s1,s2] = size(navire);
      clear navire_don
      navire_don(1:s1,1:30) = ' ';
      if s2==16
          navire_don(1:s1,1:16) = navire;
      else
          navire_don = navire;
      end
      
      camp_don             = ncread(nomfic,'CRUISE_NAME')';
      direction_don        = ncread(nomfic,'DIRECTION')';
      inst_reference_don   = ncread(nomfic,'INST_REFERENCE')';
      datedeb_don          = ncread(nomfic,'STATION_DATE_BEGIN')';
      mois_don             = str2double(datedeb_don(:,5:6));         
      datefin_don          = ncread(nomfic,'STATION_DATE_END')';
      juld_begin_don       = ncread(nomfic,'JULD_BEGIN');
      juld_end_don         = ncread(nomfic,'JULD_END');
      latdeb_don           = ncread(nomfic,'LATITUDE_BEGIN');
      londeb_don           = ncread(nomfic,'LONGITUDE_BEGIN');
      latfin_don           = ncread(nomfic,'LATITUDE_END');
      lonfin_don           = ncread(nomfic,'LONGITUDE_END');
      sondes_don           = ncread(nomfic,'BOTTOM_DEPTH');
      pmax_don             = ncread(nomfic,'MAX_PRESSURE');
      prefmax_don          = ncread(nomfic,'MAX_VALUE_PARAM_REF');
      station_number_don   = ncread(nomfic,'STATION_NUMBER');
      station_param_don    = ncread(nomfic,'STATION_PARAMETER');

      [~,nb_param_don]     = size(station_param_don);
      [nb_stat,~]          = size(station_number_don);
      flag_dbl_don = [];
      if  strcmp(project(1:2),'H2')
               flag_dbl_don         = ncread(nomfic,'FLAG_DBL');
      else
               flag_dbl_don(1:nb_stat) = 0;
               flag_dbl_don = flag_dbl_don';

      end

      prec_var_don       = [];
      prec_var_ok        = [];

% quand le fichier DEPH n'existe pas, on prend celui en PRES
% cas de NOUVELLES_CAMPAGNES pour seminaire Mathieu Hamon (17/10/14)

      if strfind(nomfic,'PRES')
           tab_deph           = ncread(nomfic,'PRES');
           prec_var_don(:,1)  = ncread(nomfic,'PRES_PREC');
         else
           tab_deph           = ncread(nomfic,'DEPH');
           prec_var_don(:,1)  = ncread(nomfic,'DEPH_PREC');
      end

      [nb_par_extract,~] = size(param_extract);


% en general, les parametres existent dans les fichiers Netcdf
% (OXYK, OXYL, SIG4, SIG5 peuvent etre absents dans certains profils) 

% recherche si le param est selectionne, puis s'il existe dans le fichier lu
       
      for i = 2:nb_par_extract

           if   strcmp(param_extract(i,:),'PSAL')
              tab_psal   = ncread(nomfic,'PSAL');
              prec_var_don(:,i) = ncread(nomfic,'PSAL_PREC');
              ipsal = 1;
          elseif   strcmp(param_extract(i,:),'TEMP')
              tab_temp   = ncread(nomfic,'TEMP'); 
              prec_var_don(:,i) = ncread(nomfic,'TEMP_PREC');
              itemp = 1;
          elseif   strcmp(param_extract(i,:),'PRES')
              prec_var_don(:,i) = ncread(nomfic,'PRES_PREC');
              tab_pres   = ncread(nomfic,'PRES');
              ipres = 1; 
          elseif  strcmp(param_extract(i,:),'TPOT')
                          itpot = 1;
                          tab_tpot (1:size(tab_deph),1:nb_stat) = -9999;
                          prec_var_don(1:nb_stat,i) = 0; 
                          
                          nopar  = strfind(reshape(station_param_don,1,4*nb_param_don),param_extract(i,:));
                          if ~isempty(nopar)
                             tab_tpot   = ncread(nomfic,'TPOT');
                             prec_var_don(:,i) = ncread(nomfic,'TPOT_PREC');
                          end

           elseif   strcmp(param_extract(i,:),'OXYL')
                          ioxyl = 1;
                          tab_oxyl (1:size(tab_deph),1:nb_stat) = -9999;
                          prec_var_don(1:nb_stat,i) = 0; 
                          nopar  = strfind(reshape(station_param_don,1,4*nb_param_don),param_extract(i,:));
                          if ~isempty(nopar)
                             tab_oxyl   = ncread(nomfic,'OXYL');
                             prec_var_don(:,i) = ncread(nomfic,'OXYL_PREC');
                          end
       
           elseif   strcmp(param_extract(i,:),'OXYK')
                          ioxyk = 1;
                          tab_oxyk (1:size(tab_deph),1:nb_stat) = -9999;
                          prec_var_don(1:nb_stat,i) = 0; 
                          nopar  = strfind(reshape(station_param_don,1,4*nb_param_don),param_extract(i,:));
                          if ~isempty(nopar)
                             tab_oxyk   = ncread(nomfic,'OXYK');
                             prec_var_don(:,i) = ncread(nomfic,'OXYK_PREC');
                          end

           elseif   strcmp(param_extract(i,:),'SIGI')
                          isigi = 1;
                          tab_sigi (1:size(tab_deph),1:nb_stat) = -9999;
                          prec_var_don(1:nb_stat,i) = 0; 
                          nopar  = strfind(reshape(station_param_don,1,4*nb_param_don),param_extract(i,:));
                          if ~isempty(nopar)
                             tab_sigi   = ncread(nomfic,'SIGI');
                             prec_var_don(:,i) = ncread(nomfic,'SIGI_PREC');
                          end

           elseif   strcmp(param_extract(i,:),'BRV2')
                          ibrv2 = 1; 
                          tab_brv2 (1:size(tab_deph),1:nb_stat) = -9999;
                          prec_var_don(1:nb_stat,i) = 0; 
                          nopar  = strfind(reshape(station_param_don,1,4*nb_param_don),param_extract(i,:));
                          if ~isempty(nopar)
                             tab_brv2   = ncread(nomfic,'BRV2');
                             prec_var_don(:,i) = ncread(nomfic,'BRV2_PREC');
                          end
           elseif   strcmp(param_extract(i,:),'VORP')
                          ivorp = 1;                         
                          tab_vorp (1:size(tab_deph),1:nb_stat) = -9999;
                          prec_var_don(1:nb_stat,i) = 0; 
                          nopar  = strfind(reshape(station_param_don,1,4*nb_param_don),param_extract(i,:));
                          if ~isempty(nopar)
                             tab_vorp   = ncread(nomfic,'VORP');
                             prec_var_don(:,i) = ncread(nomfic,'VORP_PREC');
                          end
           elseif   strcmp(param_extract(i,:),'SSDG')
                          issdg = 1;
                          tab_ssdg (1:size(tab_deph),1:nb_stat) = -9999;
                          prec_var_don(1:nb_stat,i) = 0; 
                          nopar  = strfind(reshape(station_param_don,1,4*nb_param_don),param_extract(i,:));
                          if ~isempty(nopar)
                             tab_ssdg   = ncread(nomfic,'SSDG');
                             prec_var_don(:,i) = ncread(nomfic,'SSDG_PREC');
                          end

           elseif   strcmp(param_extract(i,:),'SIG0')
                          isig0 = 1; 
                          tab_sig0 (1:size(tab_deph),1:nb_stat) = -9999;
                          prec_var_don(1:nb_stat,i) = 0; 
                          nopar  = strfind(reshape(station_param_don,1,4*nb_param_don),param_extract(i,:));
                          if ~isempty(nopar)
                             tab_sig0   = ncread(nomfic,'SIG0');
                             prec_var_don(:,i) = ncread(nomfic,'SIG0_PREC');
                          end

           elseif   strcmp(param_extract(i,:),'SIG1')
                          isig1 = 1;
                          tab_sig1 (1:size(tab_deph),1:nb_stat) = -9999;
                          prec_var_don(1:nb_stat,i) = 0; 
                          nopar  = strfind(reshape(station_param_don,1,4*nb_param_don),param_extract(i,:));
                          if ~isempty(nopar)
                             tab_sig1   = ncread(nomfic,'SIG1');
                             prec_var_don(:,i) = ncread(nomfic,'SIG1_PREC');
                          end
        
           elseif   strcmp(param_extract(i,:),'SI15') 
                          isi15 = 1;
                          tab_si15 (1:size(tab_deph),1:nb_stat) = -9999;
                          prec_var_don(1:nb_stat,i) = 0; 
                          nopar  = strfind(reshape(station_param_don,1,4*nb_param_don),param_extract(i,:));
                          if ~isempty(nopar)
                             tab_si15   = ncread(nomfic,'SI15');
                             prec_var_don(:,i) = ncread(nomfic,'SI15_PREC');
                          end
  
           elseif   strcmp(param_extract(i,:),'SIG2') 
                          isig2 = 1;
                          
                          tab_sig2 (1:size(tab_deph),1:nb_stat) = -9999;
                          prec_var_don(1:nb_stat,i) = 0; 
                          nopar  = strfind(reshape(station_param_don,1,4*nb_param_don),param_extract(i,:));
                          if ~isempty(nopar)
                             tab_sig2   = ncread(nomfic,'SIG2');
                             prec_var_don(:,i) = ncread(nomfic,'SIG2_PREC');
                          end
   
           elseif   strcmp(param_extract(i,:),'SIG3')  
                          isig3 = 1;
                          tab_sig3 = [];
                          tab_sig3 (1:size(tab_deph),1:nb_stat) = -9999;
                          prec_var_don(1:nb_stat,i) = 0; 
                          nopar  = strfind(reshape(station_param_don,1,4*nb_param_don),param_extract(i,:));
                          if ~isempty(nopar)
                             tab_sig3   = ncread(nomfic,'SIG3');
                             prec_var_don(:,i) = ncread(nomfic,'SIG3_PREC');
                          end
      
           elseif   strcmp(param_extract(i,:),'SIG4') 
                          isig4 = 1;
                          tab_sig4 = [];
                          tab_sig4 (1:size(tab_deph),1:nb_stat) = -9999;
                          prec_var_don(1:nb_stat,i) = 0; 
                          nopar  = strfind(reshape(station_param_don,1,4*nb_param_don),param_extract(i,:));
                          if ~isempty(nopar)
                             tab_sig4   = ncread(nomfic,'SIG4');
                             prec_var_don(:,i) = ncread(nomfic,'SIG4_PREC');
                          end

           elseif   strcmp(param_extract(i,:),'SIG5')
                          isig5 = 1; 
                          tab_sig5 = [];
                          tab_sig5 (1:size(tab_deph),1:nb_stat) = -9999;
                          prec_var_don(1:nb_stat,i) = 0; 
                          nopar  = strfind(reshape(station_param_don,1,4*nb_param_don),param_extract(i,:));
                          if ~isempty(nopar)
                             tab_sig5   = ncread(nomfic,'SIG5');
                             prec_var_don(:,i) = ncread(nomfic,'SIG5_PREC');
                          end

            elseif   strcmp(param_extract(i,:),'SIG6')
                          isig6 = 1; 
                          tab_sig6 = [];
                          tab_sig6 (1:size(tab_deph),1:nb_stat) = -9999;
                          prec_var_don(1:nb_stat,i) = 0; 
                          nopar  = strfind(reshape(station_param_don,1,4*nb_param_don),param_extract(i,:));
                          if ~isempty(nopar)
                             tab_sig6   = ncread(nomfic,'SIG6');
                             prec_var_don(:,i) = ncread(nomfic,'SIG6_PREC');
                          end
 
           elseif   strcmp(param_extract(i,:),'DYNH')
                          idynh = 1; 
                          tab_dynh = [];
                          tab_dynh (1:size(tab_deph),1:nb_stat) = -9999;
                          prec_var_don(1:nb_stat,i) = 0; 
                          nopar  = strfind(reshape(station_param_don,1,4*nb_param_don),param_extract(i,:));
                          if ~isempty(nopar)
                             tab_dynh   = ncread(nomfic,'DYNH');
                             prec_var_don(:,i) = ncread(nomfic,'DYNH_PREC');
                          end 
             
           elseif   strcmp(param_extract(i,:),'GAMM') 
                          igamm = 1; 
                          tab_gamm = [];
                          tab_gamm (1:size(tab_deph),1:nb_stat) = -9999;
                          prec_var_don(1:nb_stat,i) = 0; 
                          nopar  = strfind(reshape(station_param_don,1,4*nb_param_don),param_extract(i,:));
                          if ~isempty(nopar)
                             tab_gamm   = ncread(nomfic,'GAMM');
                             prec_var_don(:,i) = ncread(nomfic,'GAMM_PREC');
                          end
 
            end;
      end;
   
      fprintf([' \n \n Lecture de ' nomfic]);
      fprintf([' \n  ' num2str(length(latdeb_don)) ' stations existantes']);
       
    
   netcdf.close(nc);


% Repere les donnees absentes 
% indic = i code du param       - ex : itpot
% tab_param = tab_code du param - ex : tab_tpot
% ---------------------------
for jj = 2:nb_par_extract

  indic = ['i' lower(param_extract(jj,:))];
  tab_param = eval(['tab_' lower(param_extract(jj,:))]);
  if  ~isempty(eval(indic))
      isnotnok = find(tab_param < -9998);
      tab_param(isnotnok) = NaN*ones(size(isnotnok));
  end 
end 

      
 
% ---------------------------------------
% Repere les stations a prendre en compte
% ---------------------------------------
%  par rapport aux positions (nz_ok1) et aux dates
%   isok_lat = bonnes latitudes
%   isok_lon = bonnes longitudes
%   isok_pos = bonnes positions
%   isok_dat = bonnes dates

 
   isok_lat = find(latdeb_don>=latdeb_don_ok(1)&latdeb_don<=latdeb_don_ok(2));
   isok_lon = find(londeb_don>=londeb_don_ok(1)&londeb_don<=londeb_don_ok(2));
   isok_pos = intersect(isok_lat,isok_lon);

  
   if  ~isempty(mois_extract)
          isok_dat = find(mois_don>=mois_extract(1)& mois_don<=mois_extract(end));
      else
          isok_dat = find(juld_begin_don>=jul_extract_min ...
                  &juld_begin_don<=jul_extract_max);
   end;

   isok_all = intersect(isok_pos,isok_dat);

   if isempty(isok_all)
      fprintf('\n Pas de station repondant aux criteres (lat-lon, date)');
   else
     
%     data_processing_ok = data_processing_don(isok_all,:);   
      latdeb_ok         = latdeb_don(isok_all);
      londeb_ok         = londeb_don(isok_all);
      latfin_ok         = latfin_don(isok_all);
      lonfin_ok         = lonfin_don(isok_all);
      juldeb_ok         = juld_begin_don(isok_all);
      julfin_ok         = juld_end_don(isok_all);
      camp_ok           = camp_don(isok_all,:);
      datedeb_ok        = datedeb_don(isok_all,:);
      datefin_ok        = datefin_don(isok_all,:);
      pi_ok             = pi_don(isok_all,1:16);
      pi_org_ok         = pi_org_don(isok_all,1:16);
      flag_dbl_ok       = flag_dbl_don(isok_all);
       
      codwmo_ok         = codwmo_don(isok_all,:);
      navire_ok         = navire_don(isok_all,:);
      direction_ok      = direction_don(isok_all);
      inst_reference_ok = inst_reference_don(isok_all,:);
      sondes_ok         = sondes_don(isok_all);
      pmax_ok           = pmax_don(isok_all);
      prefmax_ok        = prefmax_don(isok_all);
      station_number_ok = station_number_don(isok_all);
      
      prec_var_ok = prec_var_don(isok_all,:);

      [nst_ok] = length(latdeb_ok);

% Conserve la partie utile des tableaux:
%  ------------------------------------
   [nz,~] = size(tab_deph);

   for jj = 1:nb_param_tot
        command = sprintf('%s%s%s%s%s%s%s','tab_', lower(tab_param_tot(jj,:)), '_ok =  nan*ones(',num2str(nz),',',num2str(nst_ok),');');
        eval(command);
   end

   nz_max = 0;
   i_liste = [];
   
   for i_sta = 1:nst_ok
      tab_deph_i = abs(tab_deph(:,isok_all(i_sta)));
      isout = find(tab_deph_i < -9000);
      if ~isempty(isout)
         tab_deph_i(isout) = nan*ones(size(isout));
      end

      if ~isempty(itpot)
          tab_tpot_i = tab_tpot(:,isok_all(i_sta));
          if ~isempty(isout)
             tab_tpot_i(isout) = nan*ones(size(isout));
          end
      end

      if ~isempty(ipsal)
          tab_psal_i = tab_psal(:,isok_all(i_sta));
          if ~isempty(isout)
             tab_psal_i(isout) = nan*ones(size(isout));
          end
      end

      if ~isempty(ipres)
          tab_pres_i = tab_pres(:,isok_all(i_sta));
          if ~isempty(isout)
             tab_pres_i(isout) = nan*ones(size(isout));
          end
      end

      if ~isempty(itemp)
          tab_temp_i  = tab_temp (:,isok_all(i_sta));
          if ~isempty(isout)
             tab_temp_i(isout) = nan*ones(size(isout));
          end
      end

      if ~isempty(ibrv2)
          tab_brv2_i  = tab_brv2 (:,isok_all(i_sta));
          if ~isempty(isout)
             tab_brv2_i(isout) = nan*ones(size(isout));
          end
      end

      if ~isempty(ivorp)
          tab_vorp_i = tab_vorp(:,isok_all(i_sta));
          if ~isempty(isout)
             tab_vorp_i(isout) = nan*ones(size(isout));
          end
      end

      if ~isempty(isigi)
          tab_sigi_i = tab_sigi(:,isok_all(i_sta));
          if ~isempty(isout)
             tab_sigi_i(isout) = nan*ones(size(isout));
          end
      end

      if ~isempty(isig0)
          tab_sig0_i = tab_sig0(:,isok_all(i_sta));
          if ~isempty(isout)
             tab_sig0_i(isout) = nan*ones(size(isout));
          end
      end

      if ~isempty(isig1)
          tab_sig1_i = tab_sig1(:,isok_all(i_sta));
          if ~isempty(isout)
             tab_sig1_i(isout) = nan*ones(size(isout));
          end
      end

      if ~isempty(isi15)
          tab_si15_i = tab_si15(:,isok_all(i_sta));
          if ~isempty(isout)
             tab_si15_i(isout) = nan*ones(size(isout));
          end
      end
      if ~isempty(isig2)
          tab_sig2_i = tab_sig2(:,isok_all(i_sta)); 
          if ~isempty(isout)
             tab_sig2_i(isout) = nan*ones(size(isout));
          end
      end

      if ~isempty(isig3)
          tab_sig3_i = tab_sig3(:,isok_all(i_sta));
          if ~isempty(isout)
             tab_sig3_i(isout) = nan*ones(size(isout));
          end
      end

      if ~isempty(isig4)
          tab_sig4_i = tab_sig4(:,isok_all(i_sta));
          if ~isempty(isout)
             tab_sig4_i(isout) = nan*ones(size(isout));
          end
      end

      if ~isempty(isig5)
          tab_sig5_i = tab_sig5(:,isok_all(i_sta));
          if ~isempty(isout)
             tab_sig5_i(isout) = nan*ones(size(isout));
          end
      end

      if ~isempty(isig6)
          tab_sig6_i = tab_sig6(:,isok_all(i_sta));
          if ~isempty(isout)
             tab_sig6_i(isout) = nan*ones(size(isout));
          end
      end

      if ~isempty(idynh)
          tab_dynh_i = tab_dynh(:,isok_all(i_sta));
          if ~isempty(isout)
             tab_dynh_i(isout) = nan*ones(size(isout));
          end
      end

      if ~isempty(issdg)
          tab_ssdg_i = tab_ssdg(:,isok_all(i_sta));
          if ~isempty(isout)
             tab_ssdg_i(isout) = nan*ones(size(isout));
          end
      end

      if ~isempty(ioxyl)
          tab_oxyl_i = tab_oxyl(:,isok_all(i_sta));
          if ~isempty(isout)
             tab_oxyl_i(isout) = nan*ones(size(isout));
          end
      end
 

      if ~isempty(ioxyk)
          tab_oxyk_i = tab_oxyk(:,isok_all(i_sta));
          if ~isempty(isout)
             tab_oxyk_i(isout) = nan*ones(size(isout));
          end

      end;

      if ~isempty(igamm)
          tab_gamm_i = tab_gamm(:,isok_all(i_sta));
          if ~isempty(isout)
             tab_gamm_i(isout) = nan*ones(size(isout));
          end

      end;

      isok_z0 = find(isfinite(tab_deph_i));
      nz_ok0 = length(isok_z0);
      ifin = max(find(tab_deph_i(isok_z0)<=zbot));
      ifin = min([ifin, nz_ok0]);
      ideb = min(find(tab_deph_i(isok_z0)>=ztop));
      ideb = max([ideb, 1]);
      isok_z = isok_z0(ideb:ifin);
      nz_ok = length(isok_z);

            tab_deph_ok(1:nz_ok,i_sta) = tab_deph_i(isok_z);
            if ~isempty(itpot) 
               tab_tpot_ok(1:nz_ok,i_sta) = tab_tpot_i(isok_z);
            end

            if ~isempty(ipsal)
               tab_psal_ok(1:nz_ok,i_sta) = tab_psal_i(isok_z);
            end

            if ~isempty(ipres)
               tab_pres_ok(1:nz_ok,i_sta) = tab_pres_i(isok_z);
            end

            if ~isempty(issdg)
               tab_ssdg_ok(1:nz_ok,i_sta) = tab_ssdg_i(isok_z);
            end

            if ~isempty(itemp)
              tab_temp_ok(1:nz_ok,i_sta) = tab_temp_i(isok_z);
            end

            if ~isempty(ibrv2)
               tab_brv2_ok(1:nz_ok,i_sta)  = tab_brv2_i(isok_z);
            end

            if ~isempty(ivorp)
               tab_vorp_ok(1:nz_ok,i_sta) = tab_vorp_i(isok_z);
            end

            if ~isempty(idynh)
               tab_dynh_ok(1:nz_ok,i_sta) = tab_dynh_i(isok_z);
            end

            if ~isempty(isigi)
               tab_sigi_ok(1:nz_ok,i_sta) = tab_sigi_i(isok_z);
            end

            if ~isempty(isig0)
               tab_sig0_ok(1:nz_ok,i_sta) = tab_sig0_i(isok_z);
            end

            if ~isempty(isig1)
               tab_sig1_ok(1:nz_ok,i_sta) = tab_sig1_i(isok_z);
            end

            if ~isempty(isi15)
               tab_si15_ok(1:nz_ok,i_sta) = tab_si15_i(isok_z);
            end

            if ~isempty(isig2)
              tab_sig2_ok(1:nz_ok,i_sta) = tab_sig2_i(isok_z);
            end

            if ~isempty(isig3)
               tab_sig3_ok(1:nz_ok,i_sta) = tab_sig3_i(isok_z);
            end

            if ~isempty(isig4)
               tab_sig4_ok(1:nz_ok,i_sta) = tab_sig4_i(isok_z);
            end

            if ~isempty(isig5)
               tab_sig5_ok(1:nz_ok,i_sta) = tab_sig5_i(isok_z);
            end
            
            if ~isempty(isig6)
               tab_sig6_ok(1:nz_ok,i_sta) = tab_sig6_i(isok_z);
            end

            if ~isempty(ioxyl)
               tab_oxyl_ok(1:nz_ok,i_sta) = tab_oxyl_i(isok_z);
            end

            if ~isempty(ioxyk)
               tab_oxyk_ok(1:nz_ok,i_sta) = tab_oxyk_i(isok_z);
            end

            if ~isempty(igamm)
               tab_gamm_ok(1:nz_ok,i_sta) = tab_gamm_i(isok_z);
            end
 
            nz_max = max([nz_max, nz_ok]);
            i_liste = [i_liste; i_sta];


   end         % end de for i_sta = 1:nst_ok

   tab_deph_ok = tab_deph_ok(1:nz_max,:);

   if ~isempty(itpot)
       tab_tpot_ok = tab_tpot_ok(1:nz_max,:);
   end

   if ~isempty(ipsal)
       tab_psal_ok = tab_psal_ok(1:nz_max,:);
   end

   if ~isempty(ipres)
       tab_pres_ok = tab_pres_ok(1:nz_max,:);
   end

   if ~isempty(issdg)
       tab_ssdg_ok = tab_ssdg_ok(1:nz_max,:);
   end

   if ~isempty(itemp)
       tab_temp_ok  = tab_temp_ok(1:nz_max,:);
   end

   if ~isempty(ibrv2)
       tab_brv2_ok  = tab_brv2_ok(1:nz_max,:);
   end

   if ~isempty(ivorp)
       tab_vorp_ok = tab_vorp_ok(1:nz_max,:);
   end

   if ~isempty(idynh)
       tab_dynh_ok = tab_dynh_ok(1:nz_max,:);
   end

   if ~isempty(isigi)
       tab_sigi_ok = tab_sigi_ok(1:nz_max,:);
   end

   if ~isempty(isig0)
       tab_sig0_ok = tab_sig0_ok(1:nz_max,:);
   end

   if ~isempty(isig1)
       tab_sig1_ok = tab_sig1_ok(1:nz_max,:);
   end

   if ~isempty(isi15)
       tab_si15_ok = tab_si15_ok(1:nz_max,:);
   end

   if ~isempty(isig2)
       tab_sig2_ok = tab_sig2_ok(1:nz_max,:);
   end

   if ~isempty(isig3)
    	tab_sig3_ok = tab_sig3_ok(1:nz_max,:);
   end

   if ~isempty(isig4)
    	tab_sig4_ok = tab_sig4_ok(1:nz_max,:);
   end

   if ~isempty(isig5)
    	tab_sig5_ok = tab_sig5_ok(1:nz_max,:);
   end

   if ~isempty(isig6)
    	tab_sig6_ok = tab_sig6_ok(1:nz_max,:);
   end

   if ~isempty(ioxyl)
   	tab_oxyl_ok = tab_oxyl_ok(1:nz_max,:);
   end

   if ~isempty(ioxyk)
   	tab_oxyk_ok = tab_oxyk_ok(1:nz_max,:);
   end;

   if ~isempty(igamm)
   	tab_gamm_ok = tab_gamm_ok(1:nz_max,:);
   end;

   fprintf([' \n  ' num2str(length(i_liste)) ' stations selectionnees  \n']);

   latdeb_sta         = [latdeb_sta; latdeb_ok(i_liste)];
   londeb_sta         = [londeb_sta; londeb_ok(i_liste)];
   latfin_sta         = [latfin_sta; latfin_ok(i_liste)];
   lonfin_sta         = [lonfin_sta; lonfin_ok(i_liste)];
   camp_sta           = [camp_sta;camp_ok(i_liste,:)];
   datedeb_sta        = [datedeb_sta;datedeb_ok(i_liste,:)]; 
   datefin_sta        = [datefin_sta;datefin_ok(i_liste,:)]; 

   juldeb_sta         = [juldeb_sta;juldeb_ok(i_liste)];
   julfin_sta         = [julfin_sta;julfin_ok(i_liste)];
   
   pi_sta             = [pi_sta;pi_ok(i_liste,:)];
   pi_org_sta         = [pi_org_sta;pi_org_ok(i_liste,:)];
   codwmo_sta         = [codwmo_sta;codwmo_ok(i_liste,:)];
   navire_sta         = [navire_sta;navire_ok(i_liste,:)];
   direction_sta      = [direction_sta,direction_ok(i_liste)]; 
   inst_reference_sta = [inst_reference_sta;inst_reference_ok(i_liste,:)];
   sondes_sta         = [sondes_sta;sondes_ok(i_liste)];
   pmax_sta           = [pmax_sta;pmax_ok(i_liste)];
   prefmax_sta        = [prefmax_sta;prefmax_ok(i_liste)];
   station_number_sta = [station_number_sta;station_number_ok(i_liste)];
   flag_dbl_sta       = [flag_dbl_sta; flag_dbl_ok(i_liste)];
   prec_var_sta       = [prec_var_sta;prec_var_ok(i_liste,:)];

   
   [nz_i, nst_i] = size(DEPH_sta);

   if nz_max > nz_i

      bid = nan*ones(nz_max-nz_i,nst_i);
      DEPH_sta = [DEPH_sta; bid];

      if ~isempty(itpot)
      	TPOT_sta = [TPOT_sta; bid];
      end

      if ~isempty(ipsal)
      	PSAL_sta = [PSAL_sta; bid];
      end

      if ~isempty(itemp)
      	TEMP_sta  = [TEMP_sta; bid];
      end

      if ~isempty(ibrv2)
      	BRV2_sta  = [BRV2_sta; bid];
      end

      if ~isempty(ivorp)
      	VORP_sta  = [VORP_sta; bid];
      end

      if ~isempty(issdg)
      	SSDG_sta = [SSDG_sta; bid];
      end

      if ~isempty(isigi)
      	SIGI_sta = [SIGI_sta; bid];
      end

      if ~isempty(isig0)
      	SIG0_sta = [SIG0_sta; bid];
      end

      if ~isempty(isig1)
      	SIG1_sta = [SIG1_sta; bid];
      end

      if ~isempty(isi15)
      	SI15_sta = [SI15_sta; bid];
      end

      if ~isempty(isig2)
      	SIG2_sta = [SIG2_sta; bid];
      end

      if ~isempty(isig3)
      	SIG3_sta = [SIG3_sta; bid];
      end

      if ~isempty(isig4)
     	SIG4_sta = [SIG4_sta; bid];
      end

      if ~isempty(isig5)
     	SIG5_sta = [SIG5_sta; bid];
      end

      if ~isempty(isig6)
     	SIG6_sta = [SIG6_sta; bid];
      end

      if ~isempty(idynh)
      	DYNH_sta = [DYNH_sta; bid];
      end

      if ~isempty(ipres)
      	PRES_sta = [PRES_sta; bid];
      end

      if ~isempty(ioxyl)
     	OXYL_sta = [OXYL_sta; bid];
      end

      if ~isempty(ioxyk)
      	OXYK_sta = [OXYK_sta; bid];
      end;

      if ~isempty(igamm)
      	GAMM_sta = [GAMM_sta; bid];
      end;

   else

      bid = nan*ones(nz_i-nz_max,nst_ok);
      tab_deph_ok = [tab_deph_ok; bid];

      if ~isempty(itpot)
      	    tab_tpot_ok = [tab_tpot_ok; bid];
      end

      if ~isempty(ipsal)
      	    tab_psal_ok = [tab_psal_ok; bid];
      end

      if ~isempty(itemp)
      	    tab_temp_ok  = [tab_temp_ok; bid];
      end

      if ~isempty(ibrv2)
      	    tab_brv2_ok  = [tab_brv2_ok; bid];
      end

      if ~isempty(ivorp)
	    tab_vorp_ok  = [tab_vorp_ok; bid];
      end

      if ~isempty(issdg)
	    tab_ssdg_ok = [tab_ssdg_ok; bid];
      end;

      if ~isempty(isigi)
	    tab_sigi_ok = [tab_sigi_ok; bid];
      end;

      if ~isempty(isig0)
	    tab_sig0_ok = [tab_sig0_ok; bid];
      end

      if ~isempty(isig1)
	    tab_sig1_ok = [tab_sig1_ok; bid];
      end

      if ~isempty(isi15)
	    tab_si15_ok = [tab_si15_ok; bid];
      end
      if ~isempty(isig2)
	    tab_sig2_ok = [tab_sig2_ok; bid];
      end

      if ~isempty(isig3)
	    tab_sig3_ok = [tab_sig3_ok; bid];
      end

      if ~isempty(isig4)
	    tab_sig4_ok = [tab_sig4_ok; bid];
      end

      if ~isempty(isig5)
	    tab_sig5_ok = [tab_sig5_ok; bid];
      end
 
      if ~isempty(isig6)
	    tab_sig6_ok = [tab_sig6_ok; bid];
      end

      if ~isempty(idynh)
      	    tab_dynh_ok = [tab_dynh_ok; bid];
      end

      if ~isempty(ipres)
      	    tab_pres_ok = [tab_pres_ok; bid];
      end

      if ~isempty(ioxyl)
      	    tab_oxyl_ok = [tab_oxyl_ok; bid];
      end

      if ~isempty(ioxyk)
      	    tab_oxyk_ok = [tab_oxyk_ok; bid];
      end;

      if ~isempty(igamm)
      	    tab_gamm_ok = [tab_gamm_ok; bid];
      end;

   end              % end de    if nz_max > nz_i

   DEPH_sta = [DEPH_sta, tab_deph_ok(:,i_liste)];

   if ~isempty(itpot)
   	TPOT_sta = [TPOT_sta, tab_tpot_ok(:,i_liste)];
   end

   if ~isempty(ipsal)
   	PSAL_sta = [PSAL_sta, tab_psal_ok(:,i_liste)];
   end

   if ~isempty(itemp)
   	TEMP_sta  = [TEMP_sta,  tab_temp_ok(:,i_liste)];
   end

   if ~isempty(ibrv2)
   	BRV2_sta  = [BRV2_sta,  tab_brv2_ok(:,i_liste)];
   end

   if ~isempty(ivorp)
   	VORP_sta  = [VORP_sta,  tab_vorp_ok(:,i_liste)];
   end

   if ~isempty(issdg)
   	SSDG_sta = [SSDG_sta, tab_ssdg_ok(:,i_liste)];
   end

   if ~isempty(isigi)
   	SIGI_sta = [SIGI_sta, tab_sigi_ok(:,i_liste)];
   end

   if ~isempty(isig0)
   	SIG0_sta = [SIG0_sta, tab_sig0_ok(:,i_liste)];
   end

   if ~isempty(isig1)
 	SIG1_sta = [SIG1_sta, tab_sig1_ok(:,i_liste)];
   end

   if ~isempty(isig2)
   	SIG2_sta = [SIG2_sta, tab_sig2_ok(:,i_liste)];
   end

   if ~isempty(isig3)
   	SIG3_sta = [SIG3_sta, tab_sig3_ok(:,i_liste)];
   end

   if ~isempty(isig4)
   	SIG4_sta = [SIG4_sta, tab_sig4_ok(:,i_liste)];
   end

   if ~isempty(isig5)
   	SIG5_sta = [SIG5_sta, tab_sig5_ok(:,i_liste)];
   end

   if ~isempty(isig6)
   	SIG6_sta = [SIG6_sta, tab_sig6_ok(:,i_liste)];
   end
   
   if ~isempty(isi15)
   	SI15_sta = [SI15_sta, tab_si15_ok(:,i_liste)];
   end

   if ~isempty(idynh)
   	DYNH_sta = [DYNH_sta, tab_dynh_ok(:,i_liste)];
   end

   if ~isempty(ipres)
   	PRES_sta = [PRES_sta, tab_pres_ok(:,i_liste)];
   end

   if ~isempty(ioxyl)
   	OXYL_sta = [OXYL_sta, tab_oxyl_ok(:,i_liste)];
   end

   if ~isempty(ioxyk)
   	OXYK_sta = [OXYK_sta, tab_oxyk_ok(:,i_liste)];
   end;
 
   end	%	   if isempty(isok_all)
   end
end 	%	for ific = 1:nbfic_mlt

% attention ....

 %DEPH_sta = DEPH_sta;
[nb_niv_extract, nb_stat_extract] = size(DEPH_sta);
fprintf(['\n\n Nombre de fichiers Campagne traites : ' num2str(nbfic_mlt) '\n']);
fprintf(['\n Nombre total de stations selectionnees : ' num2str(nb_stat_extract) '\n']);
fprintf(['\n Nombre de niveaux maxi : ' num2str(nb_niv_extract) '\n\n']);

mess_select = 'Resultat';
mess_tot = char('Nombre de fichiers Campagne traites : ', num2str(nbfic_mlt), 'Nombre total de stations', ... 
' selectionnees : ',num2str(nb_stat_extract),'Nombre de niveaux maxi : ', num2str(nb_niv_extract));

msgbox(mess_tot,mess_select);


% ---------------------------------------------------------
%
%   HYDRO_CREAT_NETCDF 
%
% ecriture d'un fichier Multistations au format Netcdf ARGO
% (adapte aux besoins du LPO) a partir d'une extraction dans la base
% de donnees Atlantique Nord
% 
% creation : fevrier 2003 - C. Lagadec
% 
% ---------------------------------------------------------

global_rep;

parameters;

global ficmlt_nc rep_ecr project;

messcreat1 = 'Creation du fichier Netcdf ... en cours';
messcreat2 = 'Creation du fichier Netcdf ... terminee';

rep_defaut = [pwd '/'];

choix_repcre_ficmltnc(rep_defaut);

ficmlt_nc   = [rep_ecr  ficmlt_nc];

% Boucle sur le nombre de parametres choisis.
% param_extract contient egalement le parametre de reference
% -----------------------------------------------------------

messnom = ['Creation en cours du fichier Multistation Netcdf '  ficmlt_nc];
msgbox(messnom,messcreat1);

% ------------------------------------------------------------------
% Ajout Octobre 2008 (C.Lagadec) : decimation possible 
% si oui, lissage obligatoire. On demande le type de lissage 
% et on impose les parametres de lissage par rapport a la decimation
% ------------------------------------------------------------------


rep_decim=input('Decimation ? (O/N) ','s');

if rep_decim =='O'
    
    pas_decim = input('Pas de la decimation ?','s');
    npas_decim=str2double(pas_decim);

    type_lissage = input('Butterworth (1) , Creneau (2) ?','s');

% lissage obligatoire : creneau ou butterworth
% --------------------------------------------

        if  strcmp(type_lissage,'2')
% lissage creneau
          a = 1; 
          b = ones(npas_decim/2,1)/(npas_decim/2);
        else

% filtre Butterworth avec filtfilt
          [b,a]  = butter(1,1/(2*npas_decim));
        end

    [bid, nb_stat_extract] = size(DEPH_sta); 
    isok=find(isfinite(DEPH_sta));
    bb=max(max(DEPH_sta(isok)));

    grille_decim = (0:npas_decim:bb);
    nb_niv_extract = length(grille_decim);

    hydro_creat_netcdf_header(ficmlt_nc, project); 

% ecriture du param DEPH_decim
% ---------------------------- 
    DEPH_decim = NaN*ones(nb_niv_extract,nb_stat_extract);

    for i_sta = 1:nb_stat_extract
      isok = find(isfinite(DEPH_sta(:,i_sta)));
      imax_sta   = max(DEPH_sta(isok(end),i_sta));
      grille_sta = (0:npas_decim:imax_sta);
      DEPH_decim(1:length(grille_sta),i_sta) = grille_sta;
    end

    err_var = prec_var_sta(:,1);

    msg_error2  =  hydro_creat_netcdf_param (ficmlt_nc, DEPH_decim', ...
                                     'DEPH', err_var); 
% ----------------------------------------------------------------   
    for i_par = 2:nb_par_extract

        param_sta    = eval([param_extract(i_par,:) '_sta']);

        param_decim = NaN*ones(nb_niv_extract,nb_stat_extract);
        [nb_niv_orig,z] = size(DEPH_sta);
        param_liss  = NaN*ones(nb_niv_orig,nb_stat_extract);

        for i_sta = 1:nb_stat_extract
          isok = find(isfinite(DEPH_sta(:,i_sta)));
          max_grille=DEPH_sta(isok(end),i_sta);
          aa = length(isok);

% lissage sur la grille reguliere avant decimation
% -----------------------------------------------
          param_liss (1:aa,i_sta) = filtfilt(b,a,param_sta(1:aa,i_sta));
 
%          param_liss (aa+1:nb_niv_orig,i_sta) = NaN;

          bb= (0:npas_decim:max_grille);
          cc= length(bb);

          param_decim (1:cc,i_sta)= interp1(DEPH_sta(1:aa,i_sta),param_liss(1:aa,i_sta),grille_decim(1:cc));

          if  (strcmp(param_extract(i_par,:),'PSAL') && (i_sta == 1)) 
              figure
              hold on
              plot(param_liss(:,1),-DEPH_sta(:,1),'g',param_sta(:,1),-DEPH_sta(:,1),'r')
              title('PSAL station 1 - lissage BTW 1/2n')
              plot(param_decim(:,1),-grille_decim,'b.')
              print('-djpeg99','psal_stat1_B2n.jpg')
              hold off
         end 
         if  (strcmp(param_extract(i_par,:),'PSAL') && (i_sta == 2)) 
              figure
              hold on
              plot(param_liss(:,2),-DEPH_sta(:,2),'g',param_sta(:,2),-DEPH_sta(:,2),'r')
              plot(param_decim(:,2),-grille_decim,'b.')
              title('PSAL station 2 - lissage BTW 1/2n')
              print('-djpeg99','psal_stat2_B2n.jpg')
              hold off
          end 
      end

          err_var = prec_var_sta(:,i_par);
 
          msg_error2  =  hydro_creat_netcdf_param (ficmlt_nc, param_decim', ...
                                     param_extract(i_par,:), err_var); 
    
  end

     else
	

% boucle sur le nombre de parametres choisi pour l'extraction (pas de decimation)
% -------------------------------------------------------------------------------

[nb_niv_extract, nb_stat_extract] = size(DEPH_sta); 

hydro_creat_netcdf_header(ficmlt_nc, project);

    for i = 1 : nb_par_extract
          param_sta    = eval([param_extract(i,:) '_sta'])';
          err_var = prec_var_sta(:,i);
          msg_error2  =  hydro_creat_netcdf_param (ficmlt_nc, param_sta, ...
                                     param_extract(i,:), err_var);
 

    end
end

messnom = ['Le fichier Multistation Netcdf ', ficmlt_nc, ' a ete cree sous le repertoire ' , rep_ecr];
msgbox(messnom,messcreat2);

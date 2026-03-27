%-----------------------------------------------------------------------------------
%  Projet BASE_HYDRO
%  -----------------
%  Version: 1.0
%  ------------
%  Creation : Janvier 2005 /  C.Lagadec               
%----------------------------------------------------------------------------
%  Verification des parametres choisis par l'utilisateur
%----------------------------------------------------------------------------
%
%  Le resultat du choix de l'utilisateur donne les parametres suivants :
%
%  1 - dates_extract : first_day,first_month,first_year,last_day,last_month,last_year
%  2 - zone geographique traitee : 
%	 lat_extract_min,lat_extract_max,lon_extract_min,lon_extract_max
%  3 - immersion d'extraction : imm_extract
%  4 - parametres a ecrire    : param_extract
%----------------------------------------------------------------------------


% Intitule de la fonction
%------------------------

function verif_choix_param(messok);

mess1 = 'Latitude mini superieure a latitude maxi';
mess2 = 'Longitude mini superieure a longitude maxi';
mess3 = 'Limites exterieures aux limites Archivage';
mess4 = 'Date de fin inferieure a date de debut';

	parameters;

% verif immersion
% ---------------
	if isempty(imm_extract_min),
           imm_extract_min = 0;
        end;
	if isempty(imm_extract_max),
           imm_extract_max = 7000;
        end;

% verif latitudes et longitudes extremes
% --------------------------------------

	if (lat_extract_min>=lat_extract_max),
	  messok = mess1;
          return
	elseif(lon_extract_min>=lon_extract_max), 
	  messok = mess2;
          return
	elseif  (lat_extract_min<-80)|(lat_extract_max>90)|(lon_extract_min<-110)|(lon_extract_max>50),
	  messok = mess3;
          return
        end

% verif si extraction par mois ou par dates limites
% -------------------------------------------------

        if ~isempty(mois_extract)
               mois_extract= str2num(mois_extract);
        end;
	if isempty(first_day),
               first_day = str2num(list_day(1,:));
        end;
	if isempty(first_month),
               first_month = str2num(list_month(1,:));
         end;
	if isempty(last_day),
           last_day = str2num(list_day(end,:));
        end;
	if isempty(last_month),
           last_month = str2num(list_month(end,:));
        end;
	if isempty(first_year),
           first_year = str2num(list_year(1,:));
        end;
	if isempty(last_year),
           last_year = str2num(list_year(end,:));
        end;

        if  isempty(mois_extract)
	  dates_extract=[first_year first_month first_day last_year last_month last_day];
          jul_extract_min=jul_0h(first_year,first_month,first_day);
	  jul_extract_max=jul_0h(last_year,last_month,last_day);	
	  if (jul_extract_min > jul_extract_max) ,
	      messok = mess4;
              return
          end
	end;



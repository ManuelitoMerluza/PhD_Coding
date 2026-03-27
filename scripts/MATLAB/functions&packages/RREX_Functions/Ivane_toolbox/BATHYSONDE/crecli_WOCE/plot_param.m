close all;clear all;

section=input('Nom de la section : ','s');

if strncmp(section,'AR21',4)
    fcat = fopen('liste_fic');
    nfic = fgetl(fcat);
    nfic = str2double(nfic);
   
    for i=1:nfic
        fic_CCHDO=fgetl(fcat)
        if strcmp(section,'AR21_93')
            cstat=fic_CCHDO(12:14);
        else
            cstat=fic_CCHDO(8:10);
        end
        
        %Récupération des données des fichiers CCHDO
        if exist(fic_CCHDO,'file')
            if strcmp(section,'AR21_91')
                prs_CCHDO=ncread(fic_CCHDO,'pressure');
                sal_CCHDO=ncread(fic_CCHDO,'salinity');
                tmp_CCHDO=ncread(fic_CCHDO,'temperature');
                oxy_CCHDO=ncread(fic_CCHDO,'oxygen'); 
            else
                prs_CCHDO=ncread(fic_CCHDO,'pressure');
                sal_CCHDO=ncread(fic_CCHDO,'salinity');
                tmp_CCHDO=ncread(fic_CCHDO,'temperature');
            end
            
            %Récupération des données des fichiers cli
            fic=[section 'd' cstat '_cli.nc'];
                if strcmp(section,'AR21_91')
                    prs=ncread(fic,'PRES');
                    sal=ncread(fic,'PSAL');
                    tmp=ncread(fic,'TEMP');
                    oxy=ncread(fic,'OXYK');
                else
                    prs=ncread(fic,'PRES');
                    sal=ncread(fic,'PSAL');
                    tmp=ncread(fic,'TEMP');
                end
                
                %PLOT
                figname=[section 'd' cstat];
                figure('Name',figname,'NumberTitle','off');
        
                if strcmp(section,'AR21_91')
                    %Plot de la salinité
                    subplot(2,2,1);
                    hp=plot(sal_CCHDO,-prs_CCHDO,'b'); hold on;
                    hp=plot(sal,-prs,'--r'); hold on;
                    ylabel('Pressure [dbars]');
                    xlabel('Salinity [psu]');
        
                    %Plot de la température
                    subplot(2,2,2);
                    hp=plot(tmp_CCHDO,-prs_CCHDO,'b'); hold on;
                    hp=plot(tmp,-prs,'--r'); hold on;
                    ylabel('Pressure [dbars]');
                    xlabel('Temperature [°C]');
        
                    %Plot de l'oxygène
                    subplot(2,1,2);
                    hp=plot(oxy_CCHDO,-prs_CCHDO,'b'); hold on;
                    hp=plot(oxy,-prs,'--r'); hold on;
                    ylabel('Pressure [dbars]');
                    xlabel('Oxygen [umol/kg]');
                else
                    %Plot de la salinité
                    subplot(2,2,1);
                    hp=plot(sal_CCHDO,-prs_CCHDO,'b'); hold on;
                    hp=plot(sal,-prs,'--r'); hold on;
                    ylabel('Pressure [dbars]');
                    xlabel('Salinity [psu]');
        
                    %Plot de la température
                    subplot(2,2,2);
                    hp=plot(tmp_CCHDO,-prs_CCHDO,'b'); hold on;
                    hp=plot(tmp,-prs,'--r'); hold on;
                    ylabel('Pressure [dbars]');
                    xlabel('Temperature [°C]');
                end
        else
            message=['Fichier inexistant : ' fic_CCHDO]
        end
    end
else
    
    expocode=input('Début du nom des fichiers issu de la base CCHDO : ','s');
    station_debut=input('Numéro de la première station : ');
    station_fin=input('Numéro de la dernière station : ');
    cast=input('Numéro du cast : ','s');

    for i=station_debut:station_fin
        %Récupération des fichiers CCHDO
        %Cas particuliers
        if strcmp(section,'A20_03')
            cstat_CCHDO=sprintf('%3.3i',i);
            fic_CCHDO=[cstat_CCHDO '01_ctd.nc'];
        else
            if strcmp(section,'AR25_99')
                cstat_CCHDO=sprintf('%3.3i',i);
            elseif strcmp(section,'AR09_93B')
                cstat_CCHDO= sprintf('%2.2i',i);
            else
                cstat_CCHDO=sprintf('%5.5i',i);
            end
            fic_CCHDO=[expocode '_' cstat_CCHDO '_0000' cast '_ctd.nc'];
        end
        
        if strcmp(section,'A13_5_10') 
            fic_CCHDO(length(fic_CCHDO)-5:length(fic_CCHDO)-3)='hy1';
        end
        
        if strcmp(section,'AR01_98')
            fic_CCHDO(length(fic_CCHDO)-5:length(fic_CCHDO)-3)='ct1';
        end
        
        %Récupération des données des fichiers issus de CCHDO
        if exist(fic_CCHDO,'file')
        
            % le code des paramètres est different pour la campagne A13_5_10 et
            % pour les campagnes AR07W
            if strcmp(section,'A13_5_10')
                prs_CCHDO=ncread(fic_CCHDO,'Pressure');
                sal_CCHDO=ncread(fic_CCHDO,'Salinity');
                tmp_CCHDO=ncread(fic_CCHDO,'Temperature');
                oxy_CCHDO=ncread(fic_CCHDO,'Oxygen_CTD');
            elseif strncmp(section,'AR07W',5)
                prs_CCHDO=ncread(fic_CCHDO,'pressure');
                sal_CCHDO=ncread(fic_CCHDO,'salinity');
                tmp_CCHDO=ncread(fic_CCHDO,'CTDTMP');
                oxy_CCHDO=ncread(fic_CCHDO,'oxygen');
            else
                prs_CCHDO=ncread(fic_CCHDO,'pressure');
                sal_CCHDO=ncread(fic_CCHDO,'salinity');
                tmp_CCHDO=ncread(fic_CCHDO,'temperature');
                oxy_CCHDO=ncread(fic_CCHDO,'oxygen');    
            end
            
            %Récupération des données des fichiers cli
            cstat=sprintf('%3.3i',i);
            fic=[section 'd' cstat '_cli.nc'];
            prs=ncread(fic,'PRES');
            sal=ncread(fic,'PSAL');
            tmp=ncread(fic,'TEMP');
            oxy=ncread(fic,'OXYK');
        
            %PLOT
            figname=[section 'd' cstat];
            figure('Name',figname,'NumberTitle','off');
        
            %Plot de la salinité
            subplot(2,2,1);
            hp=plot(sal_CCHDO,-prs_CCHDO,'b'); hold on;
            hp=plot(sal,-prs,'--r'); hold on;
            ylabel('Pressure [dbars]');
            xlabel('Salinity [psu]');
        
            %Plot de la température
            subplot(2,2,2);
            hp=plot(tmp_CCHDO,-prs_CCHDO,'b'); hold on;
            hp=plot(tmp,-prs,'--r'); hold on;
            ylabel('Pressure [dbars]');
            xlabel('Temperature [°C]');
        
            %Plot de l'oxygène
            subplot(2,1,2);
            hp=plot(oxy_CCHDO,-prs_CCHDO,'b'); hold on;
            hp=plot(oxy,-prs,'--r'); hold on;
            ylabel('Pressure [dbars]');
            xlabel('Oxygen [umol/kg]');
    
        else
            message=['Fichier inexistant : ' fic_CCHDO]
        end
    end
end

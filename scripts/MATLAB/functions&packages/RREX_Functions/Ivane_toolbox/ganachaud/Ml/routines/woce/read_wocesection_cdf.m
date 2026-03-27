function [Stat,Sdate,Slat,Slon,Pres,Temp,Sali,Oxyg]=...
    read_wocesection_cdf(secdir,secname,gis)
%READ WOCE FORMAT NETCDF CTD STATION FILES TO MAKE A SECTION
%ALEXANDRE GANACHAUD IRD SEPT 2006
%gis=stations to integrate in the section
%secdir= directory
%secdir='e:/WOCEData/P21_CTD/';
%secname='p21e'  _00004_00001_ctd.nc';gis=4:160;

%TO DO: REPRENDRE UNE ROUTINE D ECRITURE DE DONNEES HYDROINV POUR COMPLETER
%ECRIRE QQCHOSE DE SIMILAIRE SOUS NETCDF
%FAIRE DES PLOTS
%FAIRE LES CALCULS DE GEOSTROPHIE

il=0;clear Pres Temp Sali Oxyg
for istat=gis
    fname=sprintf('%s%s_%05d_00001_ctd.nc',secdir,secname,istat);
    [statlabel,sdate,slat,slon,pres,temp,sali,oxyg]=...
        read_wocectd_cdf(fname);
    if isempty(statlabel)
        fname=sprintf('%s%s_%05d_00002_ctd.nc',secdir,secname,istat);
        [statlabel,sdate,slat,slon,pres,temp,sali,oxyg]=...
            read_wocectd_cdf(fname);
    end
    if isempty(statlabel)
        disp(sprintf('no station %d',istat))
        pause
    else
        il=il+1;
        Stat(il)=istat;
        %Slabel(:,il)=statlabel;
        Date(il)=sdate;
        Slat(il)=slat;
        Slon(il)=slon;
        [att_val, att_name_list] = attnc(fname)
        disp(attnc(fname,'global','EXPOCODE'));
        disp(attnc(fname,'global','Conventions'));
        disp(attnc(fname,'global','WOCE_VERSION'));
        Secname = attnc(fname,'global','WOCE_ID');
        disp(Secname)
        disp(attnc(fname,'global','DATA_TYPE'));
        Stnnbr(istat) = sscanf(attnc(fname,'global','STATION_NUMBER'),'%d');
        Cast(istat) = sscanf(attnc(fname,'global','CAST_NUMBER'),'%d');
        Botp(istat) = ...
            sw_pres(attnc(fname,'global','BOTTOM_DEPTH_METERS'),Slat(istat));
        if il==1
            Pres=pres;
        else
            ndep1=length(Pres);
            ndep2=length(pres);
            if ndep2>ndep1
                %CHECK PRESSURE COMPATIBILITY
                if any(pres(1:ndep1)~=Pres)
                    %FIND WHERE pres STARTS
                    ipstart=find(pres(1)==Pres);
                    if ~isempty(ipstart)
                        pres=[Pres(1:ipstart-1);pres];
                        ndep2=length(pres);
                        temp=[NaN*ones(ipstart-1,1);temp];
                        sali=[NaN*ones(ipstart-1,1);sali];
                        oxyg=[NaN*ones(ipstart-1,1);oxyg];
                    end
                    if any(pres(1:ndep1)~=Pres)
                        [Pres,pres(1:ndep1)]
                        error('pressure incompatibility')
                    end
                end
                %NEW PRESSURE VECTOR
                Pres=pres;
                %add NaNs below previous stations
                Temp=[Temp;NaN*ones(ndep2-ndep1,il-1)];
                Sali=[Sali;NaN*ones(ndep2-ndep1,il-1)];
                Oxyg=[Oxyg;NaN*ones(ndep2-ndep1,il-1)];
            else %ndep1<=ndep2
                %CHECK PRESSURE COMPATIBILITY
                if any(pres~=Pres(1:ndep2))
                    %FIND WHERE pres STARTS
                    ipstart=find(pres(1)==Pres);
                    if ~isempty(ipstart)
                        pres=[Pres(1:ipstart-1);pres];
                        ndep2=length(pres);
                        temp=[NaN*ones(ipstart-1,1);temp];
                        sali=[NaN*ones(ipstart-1,1);sali];
                        oxyg=[NaN*ones(ipstart-1,1);oxyg];
                    end
                    if any(pres~=Pres(1:ndep2))
                        [Pres(1:ndep2),pres]
                        error('pressure incompatibility')
                    end
                end
                %add NaNs below LAST DEPTH
                temp=[temp;NaN*ones(ndep1-ndep2,1)];
                sali=[sali;NaN*ones(ndep1-ndep2,1)];
                oxyg=[oxyg;NaN*ones(ndep1-ndep2,1)];
            end
        end %if il==1
        Temp(:,il)=temp;
        Sali(:,il)=sali;
        Oxyg(:,il)=oxyg;
    end %if isempty(statlabel)
end %istat


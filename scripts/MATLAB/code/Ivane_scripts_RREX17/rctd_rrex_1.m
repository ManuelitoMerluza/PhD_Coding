function [d,varargout]=rctd_rrex_1(numero,fctd,varargin)

%key: Lecture des paramètres des fichiers hydro de RREX2017
%synopsis : rctd_rrex_1.m
%
%description : 
% fonction permettant la lecture des paramètres des fichiers hydro de rrex
% numero liste des stations
%
%uses: 
% varargin définit les parametres à lire par exemple ,'TPOT', 'PSAL')
% d est la profondeur
% varargout sont les paramètres
%
%author(s) : H. Mercier (herle.mercier@ifremer.fr) Sept 2018
%
%References:
%  Petit, T., Mercier, H. and Thierry T. (2018), First direct estimates of 
%  volume and water mass transports across the Reykjanes Ridge. Journal of
%  Geophysical Research: ocean, doi:10.1029/2018JC013999

nsta=size(numero,1);
nvar=max(nargin,1)-2; % soustraire le nombre d'arguments avant varargin


% lecture de la profondeur et des numeros de station
DEPH=ncload(fctd,'DEPH');
STATION_NUMBER=ncload(fctd,'STATION_NUMBER');

% traitement des valeurs erreur
DEPH(DEPH == -9999) = NaN;


% dimensions des tableaux ctd
nstama=size(DEPH,1);nz=size(DEPH,2);


% lecture des variables et affectation dans le tableau de sortie
for i=1:nvar
    
    if strcmp(varargin{i},'STATION_NUMBER') || strcmp(varargin{i},'MAX_PRESSURE')
        
        %var=ncload('/home/lpo5/HYDROCEAN/MLT_NC/LPO/RREX/RREX17/rr17_PRES.nc',varargin{i});
        var=ncload('../../DATA/HYDRO/RREX2017/ctd/nc/rr17_PRES.nc',varargin{i});
        var(var==-9999) = NaN;

        interm=[];
        
        for j=1:nsta
            interm = [interm var(STATION_NUMBER==numero(j))'];
        end
        
        varargout{i}=interm;
        
    else

        %var=ncload('/home/lpo5/HYDROCEAN/MLT_NC/LPO/RREX/RREX17/rr17_PRES.nc',varargin{i});
        var=ncload('../../DATA/HYDRO/RREX2017/ctd/nc/rr17_PRES.nc',varargin{i});
        var(var==-9999) = NaN;

        interm=[];
            
            for j=1:nsta
                interm = [interm var(STATION_NUMBER==numero(j),:)'];
            end
            
        varargout{i}=interm;
    
    end

end

        d=[];
        for j=1:nsta
            d=[d squeeze(DEPH(STATION_NUMBER==numero(j),:))'];
        end

end
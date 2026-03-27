function [d,varargout]=rctd_rrex_1(numero,fctd,varargin)

% fonction permettant la lecture des paramètres des fichiers hydro de rrex
% numero liste des stations
% varargin définit les parametres à lire par exemple ,'TPOT', 'PSAL')
% d est la profondeur
% varargout sont les paramètres

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
        
        var=ncload('/export/home1/cruise/RREX/nc/rr15_PRES.nc',varargin{i});
        var(var==-9999) = NaN;

        interm=[];
        
        for j=1:nsta
            interm = [interm var(STATION_NUMBER==numero(j))'];
        end
        
        varargout{i}=interm;
        
    else
    
        var=ncload('/export/home1/cruise/RREX/nc/rr15_PRES.nc',varargin{i});
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
%-------------------------------------------------------------------------------
%
% prsofzts        - Computes pressure from depth, temperature and salinity
%               with iteration to integrate density
%              - Computes also sound speed from Z, T, S 
%
%  function [tabC,tabP,Sigma] = prsofzts(tabZ, tabT, tabS, ylat, ssp_alg)
%
%-------------------------------------------------------------------------------
% Version:
% -------
%  1.01 Création (d'après atl_creat)          06/03/99 F. Gaillard
%  1.02 Modification:                         23/01/03 V. Thierry
%       remplacement de swstate par swstat90         
%  1.03 Modification:                         08/06/04 F. Gaillard
%       remplacement de soundspeed par soundspeed90         
% 1.04 Modification                         22/02/2007 F. Gaillard
%    permet le traitement de matrices 
%    Les profils doivent être rangés sur les colonnes de la matrice
%-------------------------------------------------------------------------------
%
%
%     description :
%     -----------
%     Computes pressure from depth, temperature and salinity
%     with iteration to integrate density
%     Computes also sound speed from Z, T, S 
%                                                  
%     input : 
%     ------   
%        tabZ   : Matrix of depth (in meters) [i,j] - i = depth, j = profile number
%        tabT   : vector of temperature (in degrees C)
%        tabS   : vector of salinity (in PSU)
%        ylat   : latitude of point (in decimal degrees)
%        ssp_alg: sound speed algorith (according to soundspeed
%                 routine syntax) - 
%                 = 'none': no sound speed calculation
%  
%     output : 
%     ------   
%        tabC     : vector of souns speed (in m/s)
%        tabP     : vector of presure (in db)
%        Sigma    : vector of density anomaly (in kg/m**3)
%
%     internal calls to subroutines : 
%     -----------------------------  
%     zenprs, swstat90, soundspeed, 
%-------------------------------------------------------------------------------

function [tabC,tabP,Sigma] = prsofzts(tabZ, tabT, tabS, ylat, ssp_alg)

%
% Constants:
%  ----------------------------------------------------------------
   max_iter = 4;        %  Max number of iteration for converging to pressure
   min_eps  = 1.0e-2;   %  Accuracy required on pressure
%  ----------------------------------------------------------------


%  Pressure calculation:
%   --------------------
   tabP = abs(tabZ);
   niter = 0;
   eps  = 10;

   while eps>min_eps & niter<max_iter
         niter = niter + 1;
         [xbid, Sigma] = swstat90(tabS, tabT, tabP);
         Pold  = tabP;
         tabP  = zenprs(tabZ, Sigma, ylat);
         eps   = max(std(tabP-Pold,1));
   end

%  Soundspeed calculation:
%  -----------------------
   if ~isempty(ssp_alg)
       tabC = soundspeed90(tabS, tabT, tabP, ssp_alg);
   else
       tabC = [];
   end

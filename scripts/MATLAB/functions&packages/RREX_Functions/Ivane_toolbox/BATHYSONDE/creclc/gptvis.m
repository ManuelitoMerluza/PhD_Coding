%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% gptvis        - Calcul du gradient potentiel de vitesse du son
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  appel:   function [dCp] = gptvis(Sal, Temp, Pres, xlat)
%  -----  
%
% Remarque: le tableau doit etre echantillonne regulierement en Pression
% --------  fonctionne pour des vecteurs, pas des matrices
% 	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [dCp] = gptvis(Sal, Temp, Pres, xlat)


g0 = gravit(xlat);
dp = Pres(2) - Pres(1);
nz = length(Pres);

%  Calcule la densite in situ (pour conversion dp-dz):
%  -------------------------------------------------
[alpha, Sig] = swstate (Sal, Temp, Pres);
invdz = -1.e-04*g0*(1000 + Sig)/(2*dp);

%  Calcule la celerite in situ:
%  --------------------------
CmoySS = soundspeed( Sal, Temp, Pres, 'state');

%  Deplace la particule d'un niveau vers le haut et vers le bas:
%  ------------------------------------------------------------
Psup = Pres - dp;
Pinf = Pres + dp;
Tsup = zeros(nz,1);
Tinf = zeros(nz,1);
for iz = 1:nz
   Tsup(iz) =  tetai(Pres(iz), Temp(iz), Sal(iz), Psup(iz));
   Tinf(iz) =  tetai(Pres(iz), Temp(iz), Sal(iz), Pinf(iz));
end

Csup = soundspeed( Sal, Tsup, Psup, 'state');
Cinf = soundspeed( Sal, Tinf, Pinf, 'state');

%  Calcule dCp/dz:
%  --------------
dCp = zeros(1:nz,1);
dCp(2:nz-1) = (Csup(2:nz-1) - CmoySS(1:nz-2)  + CmoySS(3:nz) - Cinf(2:nz-1))...
               .*invdz(2:nz-1);
dCp(1)  = dCp(2);
dCp(nz) = dCp(nz-1);

end

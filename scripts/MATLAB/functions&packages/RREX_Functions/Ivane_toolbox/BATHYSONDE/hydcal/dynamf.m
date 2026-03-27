%------------------------------------------------------------------------------
%
% dynamf        - calculates vertical modes of an arbitrary N**2 profile
%                 with free surface 
%
%                !!! Attention: Utiliser des N**2 non nuls pour le moment !!!
%                !!! Attention: verifier condition surface libre !!!
%
%  call: function [rossby, fmod] = dynamf(bv2, zz, ylat, nmod)
%
%------------------------------------------------------------------------------
%
% Version:
% -------
%  1.01 Création (d'après dynam, chaine hydro)  	21/08/96  F. Gaillard
%  1.02 Modification 					22/09/98  V. Thierry
%       Calcul des modes f directement
%  1.03 Modification 					22/02/01  A. GANACHAUD
%       f02agf (NAG) remplace par eig (matlab)
%
%  Method :
%  ------
%  Applying the change of variable: g = fz/bv2
%  converts the problem to a matrix eigenvalue problem:
%                                  -[fz/bv2]z    = ev*f
%  subject to the boundary conditions:  fz(-d) = 0
%                                                                    fz(0) = 0
%   where   p(x,y,z,t) = a(x,y,t)*f(z) et f(z) = gz(z)/ev
%    f   is the stream function vertical mode
%    g   is the mode for vertical displacement
%    ev  is the eigenvalue
%    bv2 is the buoyancy frequency squared
%
%
%** approximates second partial with respect to z by drawing a
%   parabola through three points and taking its curvature as the
%   second partial at the center point.
%
%** approximates the first partial with respect to z (which appears
%   in the boundary condition) as a simple finite difference:
%   fz = (f(2)-f(1)) / (f(2)-f(1))
%   
%** Dans les tranches ou N**2 est nulle, le mode sera lineaire de i-1 a j
%       g(k) = a(k)*g(j) + b(k)*g(i-1)
%       where       a(k) = (z(k)-z(i-1))/(z(j)-z(i-1))
%                   b(k) = (z(j)-z(k))/(z(j)-z(i-1))
%   on peut eliminer g(k), i<= k <= j-1
%   donc
%           -l(i-1)*g(i-2) + d(i-1)*g(i-1) - u(i)*g(i) = ev*g(i-1)
%   la derniere equation avant le premier niveau n = 0 devient:
%     -l(i-1)*g(i-2)+[d(i-1)u(i)*b(i)]*g(i-1)-u(i)*a(i)*g(i)=ev*g(i-1)
%   et de meme pour la j-eme equation
%
%  donnees en entree:
%  -----------------
%     bv2  : Brunt-Vaisala frequency squared
%     zz   : vertical profile, first point is assumed to be z = 0 (surface)
%    ylat  : latitude en degres decimaux
%    nmod  : nombre de modes a calculer
%     iop  := 0 impose  fz(0)=0
%    
%
%  sorties:
%  -------
%  rossby   : rayon de deformation de rossby des modes ,
%             calcule a partir de la valeur propre ev:
%             rossby(i) = 1/(f0*sqrt(ev(i)))  (different si ylat=0)
%    fmod   : modes pour la fonction courant

%
%------------------------------------------------------------------------------
                                              
function [rossby, fmod] = dynamf(bv2, zz, ylat, nmod)

%
%  Constantes:
bvmin   = 1.0e-12;

grav    = gravit(ylat);
fcor    = pi*sin(pi*ylat/180.0)/(6*3600);

%  S'assure que les tableaux sont verticaux:
[n,m] = size(bv2);
if m>n,
   bv2 = bv2';
   zz  = zz';
   nz = m
else
   nz = n
end;

%  repere les niveaux ou N**2 est nulle:
%  ------------------------------------
bvnul = find(bv2<bvmin)
nzeros = length(bvnul)
if nzeros>0
%   fprint (1, '  Valeurs nulles de N**2 rencontrees attention \n');
   itrou = 1;
   i     = 1;
   while i<nzeros+1
      ideb(itrou) = bvnul(i) - 1;
      if i == nzeros
         ifin(itrou) = bvnul(i) + 1;
      else
         if bvnul(i+1)==bvnul(i) + 1
            i = i + 1;
         else
            ifin(itrou) = bvnul(i) + 1;
            itrou = itrou + 1;
         end
      end
   end
else
   ntrou = 0;
end

%  Cas general flag mis a 1:
%  ------------------------
iflag        = ones(nz,1);
if nzeros>0,
   iflag(bvnul) = zeros(size(bvnul));
end
iflag(1)     = 0;
iflag(nz)    = 0;
isok         = find(iflag);
size(isok)

%  ==========================================
%     Rempli les matrices tridiagonales:
%  ==========================================
%    tridiag(i,1)   = diagonale inferieure
%    tridiag(i,2)   = diagonale principale
%    tridiag(i,3)   = diagonale superieure

tridiag = nan*ones(nz,3);
dz1     = zz(2:nz) - zz(1:nz-1);
dz3     = [0; 0.5*(dz1(2:nz-1)+dz1(1:nz-2))];

bvinv   = -ones(size(isok))./(bv2(isok)+bv2(isok-1));
bvinv = [bvinv; -1/(bv2(nz)+bv2(nz-1))];

%  calcule les diagonales quand N**2 est non nulle (et hors des bornes)
%  -------------------------------------------------------------------
%   approximates second partial with respect to z by drawing a
%   parabola through three points and taking its curvature as the
%   second partial at the center point.
tab1 =  dz1(isok-1 ).*dz3(isok);
%tab2 = -dz1(isok-1).*dz1(isok);
tab3 =  dz1(isok).*dz3(isok);
tridiag(isok,1) = 2*bvinv(1:size(isok))./tab1;
tridiag(isok,2) = -2*bvinv(1:size(isok))./tab1-2*bvinv(2:size(isok)+1)./tab3;
tridiag(isok,3) = 2*bvinv(2:size(isok)+1)./tab3;


%  !!!!!!!!!!!!!!!!!!!!   Partie a verifier - debut !!!!!!!!!!!!!!!!!!!!!!!!!!!

%  calcule les diagonales aux limites de N*2 nulle   
%  -----------------------------------------------
%  transforme l'equation ideb:
if nzeros>0,
   deltaz = zz(ifin) - zz(ideb);
   tridiag(ideb,1) = tridiag(ideb,1) ...
                  - tridiag(ideb,3).*(zz(ifin) - zz(ideb+1))./deltaz;
   tridiag(ideb,3) = tridiag(ideb,3).*(zz(ideb+1) - zz(ideb))./deltaz;

%  transforme l'equation ifin:
   tridiag(ifin,1) = tridiag(ifin,1) ...
                  - tridiag(ifin,3).*(zz(ifin-1) - zz(ideb-1))./deltaz;
   tridiag(ideb,3) = tridiag(ifin,3).*(zz(ifin) - zz(ifin-1))./deltaz;
end

%  !!!!!!!!!!!!!!!!!!!!   Partie a verifier - fin !!!!!!!!!!!!!!!!!!!!!!!!!!!!

%
%  =======================================================
%      Calcul des valeurs propres et vecteurs propres
%  =======================================================

%  Methode bestiale: Fournit la matrice complete:

nzok  = length(isok)+2;
A_mat = zeros(nzok,nzok);

%  Niveaux internes:
%  ----------------
for i = 2:nzok-1
   A_mat(i,i-1) = tridiag(isok(i-1),1);
   A_mat(i,i)   = tridiag(isok(i-1),2);
   A_mat(i,i+1) = tridiag(isok(i-1),3);
end

%  Condition limite au fond:
%  ------------------------
%   fz = 0 ==> f(nz)=f(nz+1), niveau nz+1=niveau fictif
   A_mat(nzok,nzok) = -2*bvinv(nzok-1)/(dz1(nzok-1)*dz1(nzok-1));
   A_mat(nzok,nzok-1) = 2*bvinv(nzok-1)/(dz1(nzok-1)*dz1(nzok-1));


%  Condition limite en surface:
%  ---------------------------
% f(1)=f(0), niveau 0=niveau fictif
A_mat(1,1) = -2*bvinv(1)/(dz1(1)*dz1(1));
A_mat(1,2) =  2*bvinv(1)/(dz1(1)*dz1(1));


if 0
  [RR, RI, VR, VI, niter, ifail] = f02agf(A_mat);
  [EV,II] = sort(RR); %real part of eigenvalues
else
  %CHANGE A. GANACHAUD 02/01
   [VVV,DDD] = eig(A_mat);
   [EV,II]=sort(real(diag(DDD)));
   VR=real(VVV);
   VI=imag(VVV);
end
Isel = II(1:nmod);
Esel = EV(1:nmod);
ifail
clear A_mat




%  Extrait les modes de deplacement vertical:
%  -----------------------------------------

fmod = [VR(:,Isel)] ;
 z0   = [zz(1); zz(isok); zz(nz)];
end

%  Repasse sur la grille complete:
%  ------------------------------
if nzeros>0,
   bid = interp1(z0,fmod,zz);
   fmod = bid;
end
clear bid VR

%  Calcule les rayons de Rossby:
%  ---------------------------

if (abs(ylat)<1)
  rep='o';
else
  rep='n';
end
%rep=input('sommes nous a l equateur? o/n','s');
if rep=='o' | ylat==0
	beta=2.27e-11;
	rossby=sqrt((1/beta)*ones(nmod,1)./sqrt(Esel));
else
	rossby = (1/fcor)*ones(nmod,1)./sqrt(Esel);
end




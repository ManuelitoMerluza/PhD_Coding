function [g,dg_lo,dg_hi] = gamma_n(s,t,p,along,alat)

%%%	GAMMA_N:	Label hydrographic data with neutral density
%%%
%%%	USAGE:		[g,dg_lo,dg_hi] = gamma_n(s,t,p,along,alat)
%%%
%%%	DESCRIPTION:	Label a section of hydrographic data at a specified
%%%			location with neutral density
%%%
%%%	PRECISION:	Double
%%%
%%%	INPUT:		s       matrix of salinity (each column being a cast)
%%%			t       matrix of in-situ temperatures 
%%%			p	matrix of pressures
%%%			along	vector of longitudes (0,360)
%%%			alat	vector of latitudes (-90,90)
%%%
%%%			NOTE:	missing values must be denoted by NaN's
%%%
%%%	OUTPUT:		g	matrix of gamma_n values
%%%			dg_lo   matrix of gamma_n lower error estimates
%%%			dg_hi   matrix of gamma_n upper error estimates
%%%
%%%			NOTE:	NaN denotes missing input data
%%%				-99.0 denotes algorithm failed
%%%				-99.1 denotes input data is outside the valid
%%%				      range of the present equation of state
%%%
%%%	UNITS:		salinity	psu (IPSS-78)
%%%			temperature	degrees C (IPTS-68)
%%%			pressure	db
%%%			gamma_n		kg m-3
%%%
%%%
%%%	AUTHOR:		David Jackett
%%%
%%%	CREATED:	October, 1994
%%%
%%%	REVISION:	2.1		16/2/95
%%%



%%%
%%%		check # arguments and initialize
%%%

if nargin ~= 5
  error('ERROR in gamma_n.m: invalid input arguments')
end

[nz,nx] = size(s);

g = nan*zeros(nz,nx);
dg_lo = nan*zeros(nz,nx);
dg_hi = nan*zeros(nz,nx);
index = nan*zeros(nz,nx);

if nz == 1
  np = ~isnan(s+t+p);
else
  np = sum(~isnan(s+t+p));
end

for ix = 1:nx
  index(1:np(ix),ix) = find(~isnan(s(:,ix)+t(:,ix)+p(:,ix)));
end


%%%
%%%		save appropriate array
%%%

savearray = [];
for ix = 1:nx
  indx = index(1:np(ix),ix);
  savearray = [savearray; ...
	       along(ix) alat(ix) np(ix); ...
	       s(indx,ix) t(indx,ix) p(indx,ix)];
end

save glabel_matlab.in savearray -ascii


%%%
%%%		run external code
%%%
%
% 17/06/2003 : Modif. C. Kermabon.
%	       Selon que l'on soit sur une machine solaris ou une machine
% linux, l'executable a appeler n'est pas le meme.
%
% La ligne : command = ['!glabel_matlab >& /dev/null']
% est remplacee par les 3 suivantes.
%
neutre_ext = getenv('NEUTRE_EXT');
cde_neutre_ext = ['glabel_matlab' neutre_ext];
command = sprintf('!%s >& /dev/null',cde_neutre_ext);

eval(command);

load glabel_matlab.out;

!\rm glabel_matlab.in glabel_matlab.out


%%%
%%%		assemble gamma_n labels
%%%

start = 1;
for ix = 1:nx
  n = np(ix);
  indx = index(1:n,ix);
  finish = start+n-1;
  g(indx,ix) = glabel_matlab(start:finish,1);
  dg_lo(indx,ix) = glabel_matlab(start:finish,2);
  dg_hi(indx,ix) = glabel_matlab(start:finish,3);
  start = finish+1;
end

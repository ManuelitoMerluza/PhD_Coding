function [gvel,s_dynh,d_dynh]=g_gvel(plat,distg,sign,Pres,idepref, ...
                                     s_t_d,d_t_d,s_sali,d_sali)
%key: computes the geostrophic velocities relative to the depth(s) idepref
%synopsis : [gvel,s_dynh,d_dynh]=g_gvel(plat,distg,sign,Pres,idepref, ...
%                                     s_t_d,d_t_d,s_sali,d_sali)
% INPUT:
%   Npair is the number of pairs (implicit)
%   Ndep is the number of Press (implicit)
%   plat(1:Npair) : middle latitude for each pair of station
%   distg(1:Npair): distance (m) between stations
%   sign(1:Npair): sign convention: +1 if shallow comes before deep
%             station in original order.
%   Pres(1:Ndep): Press (db) at any station 
%   idepref(1:Npair): Pres indice for the reference level
%   s_t_d, d_t_d(1:Ndep,1:Npair)  ( m^2/s^2 or deg. celsius)
%   s_sali,d_sali(1:Ndep,1:Npair) (g/Kg)
%     if ctd data, these arrays are the dynamic heigths,
%        s_ for 'shallow' station, d_ for deep station
%        s_sali,d_sali are not necessary.
%     else
%        s_t_d, d_t_d are the temperature fields
%        thus s_sali,d_sali are necessary and the dynamic heigths
%        are computed.
%   
% OUTPUT:
%   gvel(1:Ndep,1:Npair): geostrophic velocity relative to Pres(idepref)
%       in cm/s
%   
%   THESE ARGUMENTS ARE NOT AUTHORIZED IF DYN. HEIGHT IS INPUT 
%   s_dynh,d_dynh: dynamic height, zero at the surface, m^2 / s^2
%   zero is at the surface. sign is positive toward the bottom.
%   
%description : 
%
% from geovel2.m, C. Wunsch
%
%
%uses :
%
%side effects : sign has to be clarified
%
%author : A.Ganachaud (ganacho@gulf.mit.edu) , Oct 95
%
%see also : geovel.m
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sz=size(s_t_d);
ndep=sz(1);
npair=sz(2);

if nargin==9 %not ctd data, computes dyn. hgt
  %s_t_d = shallow station temperature
  %d_t_d = deep    station temperature
  s_dynh=NaN*ones(ndep,npair);
  d_dynh=NaN*ones(ndep,npair);
  for ip=1:npair
    idm=Maxd(ip);
    [dh,s_delta]=dynht2(Pres(1:idm), ...
      s_t_d(1:idm,ip),s_sali(1:idm,ip),0);
    s_dynh(1:idm,ip)=-dh;
    [dh,d_delta]=dynht2(Pres(1:idm), ...
      d_t_d(1:idm,ip),d_sali(1:idm,ip),0);
    d_dynh(1:idm,ip)=-dh;
  end
elseif nargin==7
  s_dynh=s_t_d;
  d_dynh=d_t_d;
  if nargout==2
    error('2 output arguments not compatible with dyn. hght input')
  end
else
  error('not correct number of input arguments, check !!')
end

omega=7.27e-5;d2g=pi/180;
denm1=sign.*(2*omega*sin(d2g*plat).*distg).^(-1);
denm1=ones(ndep,1)*denm1';
gvel=100*(d_dynh - s_dynh).*denm1;

for ip=1:npair
  gvel(:,ip)=gvel(:,ip)-gvel(idepref(ip),ip); 
end
function  [zl_inv, Ul_inv, Vl_inv, Verr_inv, LatSta, LonSta, zfond]=rladcp_rrex(~,numero)

% lecture des données ladcp
lzmax=0;
zlmax=[];
nsta= size(numero,1);

for ii=1:nsta,

  fname=['../../DATA/HYDRO/RREX2017/ladcp/l2_s0_b16/' num2str(numero(ii),'%3.3i') '/' num2str(numero(ii),'%3.3i') '.mat'];
  load (fname);
  
  zl=dr.z;
  lz=length(zl);
  if lz>lzmax, lzmax=lz; zlmax=zl; end;
  
end

Ul_inv=nan*ones(lzmax,nsta);
Vl_inv=nan*ones(lzmax,nsta);
Verr_inv=nan*ones(lzmax,nsta);
zfond=nan*ones(nsta,1);
LatSta=nan*ones(nsta,1);
LonSta=nan*ones(nsta,1);

for ii=1:nsta,

  fname=[rep_data 'RR15_' num2str(numero(ii),'%3.3i') '.mat'];
  load (fname);
  
  zl=dr.z;
  lz=length(zl);
  Ul=dr.u;
  Vl=dr.v;
  Verr=dr.uerr;
  
%   Uld=dr.u_do*100;
%   Vld=dr.v_do*100;
%     
%   Ulm=dr.u_up*100;
%   Vlm=dr.v_up*100;

  Ul_inv(1:lz,ii)=Ul;
  Vl_inv(1:lz,ii)=Vl;
  Verr_inv(1:lz,ii)=Verr;
  
  zfond(ii)=-values.maxdepth;
  LatSta(ii)=values.lat;
  LonSta(ii)=values.lon;
    
end


zl_inv=-zlmax;
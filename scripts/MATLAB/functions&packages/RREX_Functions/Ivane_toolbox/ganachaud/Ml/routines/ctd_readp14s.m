function [pctd,tctd,sctd,o2ctd]=ctd_readp14s(fname);
% KEY:
% USAGE :
% 
%
%
%
% DESCRIPTION : 
%
%
% INPUT:
%
% OUTPUT:
%
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , Dec 97
%
% SIDE EFFECTS :
%
% SEE ALSO :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER:
% CALLEE:
  fictd=fopen(fname,'r');
  lnn1=fgetl(fictd);
  lnn2=fgetl(fictd);
  alldata=fscanf(fictd,'%f',[Inf]);
  fclose(fictd);
  if length(alldata)/12 ~= fix(length(alldata)/12)
    error(['Problem in ' fname])
  end
  alldata=reshape(alldata,12,length(alldata)/12)';
  ipr=1;
  itc=2;
  isc=4;
  iox=8;

  o2ctd=alldata(:,iox);
  pctd=alldata(:,ipr);
  tctd=alldata(:,itc);
  sctd=alldata(:,isc);

%The 4-digit WOCE quality flag represents CTDPRS, CTDTMP, CTDSAL, CTDOXY
%as specified in the WOCE Operations Manual (May, 1994).
  nvq=4;
  qualt1=alldata(:,12);
  j=1;
  qtv=fix((qualt1-10^(nvq-j+1)*fix(qualt1/10^(nvq-j+1)))/10^(nvq-j));
  pctd(qtv~=2)=NaN;
  j=2;
  qtv=fix((qualt1-10^(nvq-j+1)*fix(qualt1/10^(nvq-j+1)))/10^(nvq-j));
  tctd(qtv~=2)=NaN;
  j=3;
  qtv=fix((qualt1-10^(nvq-j+1)*fix(qualt1/10^(nvq-j+1)))/10^(nvq-j));
  sctd(qtv~=2)=NaN;
  j=4;
  qtv=fix((qualt1-10^(nvq-j+1)*fix(qualt1/10^(nvq-j+1)))/10^(nvq-j));
  o2ctd(qtv~=2)=NaN;
  
  
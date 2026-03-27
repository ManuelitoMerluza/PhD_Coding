function y=harmonickernel(lon1,lat1,lon2,lat2,N);
% KEY: averaging kernel of spherical harmonics, approximated
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
%
% OUTPUT:
%
% AUTHOR : A.Ganachaud (ganacho@ifremer.fr) Oct 2001
%
% SIDE EFFECTS : this is not exact
%
% SEE ALSO : Wunsch and Stammer, 1995
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER:
% CALLEE: plgndr
lat1=lat1-90; %co-latitude
lat2=lat2-90;

%THE FOLLOWING IS ONLY
%Ne marche pas pour latitudes changeantes ??
%cosij=cos(lat1*pi/180)*cos(lat2(:)*pi/180)+...
%  sin(lat1*pi/180)*sin(lat2(:)*pi/180).*...
%  cos((lon2(:)-lon1)*pi/180);
%y=0;
%for nN=1:N
%  y=y+(2*nN+1)*plgndr(nN,0,cosij);
% nN,plot(y,'o');ppause
%end
%y=y/y(1);

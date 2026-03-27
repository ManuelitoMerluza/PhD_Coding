function ttx1=put_sigmasurf(Plon,tpost,sigsurf,clr,ftsz)
% KEY: overlay the sigma surfaces numbers on the plot, with layer number
% USAGE :
% 
%
%
%
% DESCRIPTION : 
%
%
% INPUT: tpost: horizontal position of the number
%
% OUTPUT:
%
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , Nov 96
%
% SIDE EFFECTS :
%
% SEE ALSO :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER:
% CALLEE:
if nargin < 5
  ftsz=8;
end


for i=1:length(tpost)
  tpos=tpost(i);
  ig=find(~isnan(sigsurf(:,tpos)));
  ng=length(ig);
  txtd=.5*(-sigsurf(ig(1:(ng-1)),tpos)-sigsurf(ig(2:ng),tpos));
  ttx1=text(Plon(tpos)*ones(ng-1,1),txtd,...
    reshape(sprintf('%2i',ig(1:ng-1)),2,ng-1)',...
    'fontsize',ftsz,'vertic','middle','color',clr);
end

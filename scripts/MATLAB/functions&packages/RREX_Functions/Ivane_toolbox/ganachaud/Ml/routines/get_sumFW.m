%script get_sumFW 
% KEY: get sums of freshwater fluxes over several boxes
% USAGE :
% 
%
%
%
% DESCRIPTION : 
%
%
% INPUT: giboxFW: box names to sum over
%
%
% OUTPUT:
%
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , Apr99
%
% SIDE EFFECTS :
%
% SEE ALSO :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER:
% CALLEE:

disp('summing over boxes')
Gilfw=[];Aavgfw=[];
for ibox=giboxFW
  disp(boxname{ibox})
  Gilfw=[Gilfw,pm.gifw{ibox}];
  Aavgfw=[Aavgfw, 1];
end
Fwavg=Aavgfw*bhat(Gilfw);
dFwavg=sqrt(Aavgfw*P(Gilfw,Gilfw)*Aavgfw');
disp(sprintf('FW : %6.2g +/-%4.2g',Fwavg,dFwavg))

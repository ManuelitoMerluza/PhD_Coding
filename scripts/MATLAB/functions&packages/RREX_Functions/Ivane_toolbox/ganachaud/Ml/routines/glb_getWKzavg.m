%script glb_getWKzavg 
% KEY: get averages of W and Kz on global scales
% USAGE :
% 
%
%
%
% DESCRIPTION : 
%
%
% INPUT: wavg2get{ibox}: layer interfaces over which to average
%
%
% OUTPUT: WavgT/dWavgT = top layer vertical transport
%         Wavg /dWavg  = weighted average dianeutral velocities
%         Kzavg/dKzavg = weighted average dianeutral diffusion
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
Gilw=[];Aavg=[];Gilw1=[];
Aavgweighted=[];
Gilkz=[];
for ibox=1:length(wavg2get)
  if ~isempty(wavg2get{ibox})
    disp(boxname{ibox})
    gilw=pm.gifwcol(ibox):pm.gilwcol(ibox);
    gilw=gilw(wavg2get{ibox});
    gilkz=pm.gifKzcol{ibox}:pm.gilKzcol{ibox};
    gilkz=gilkz(wavg2get{ibox});
    girows=pm.ibfrow(ibox)+wavg2get{ibox};
    ninterf=length(wavg2get{ibox});
    nn=length(Aavgweighted)+1;
    nn1=nn+length(gilw)-1;
    %Aavg(nn:nn1)=(ones(ninterf,1)/ninterf).*diag(Amat(girows,gilw));
    Aavg=[Aavg,diag(Amat(girows(1),gilw(1)))];
    Aavgweighted(nn:nn1)=diag(Amat(girows,gilw));
    Gilw1=[Gilw1;gilw(1)];
    Gilw(nn:nn1)=gilw;
    Gilkz(nn:nn1)=gilkz;
  end
end
Aavg1=ones(1,nn1)/nn1;
WavgT=Aavg*bhat(Gilw1);
dWavgT=sqrt(Aavg*P(Gilw1,Gilw1)*Aavg');

Aavgweighted=Aavgweighted/sum(Aavgweighted);
Wavg=Aavgweighted*bhat(Gilw);
dWavg=sqrt(Aavgweighted*P(Gilw,Gilw)*Aavgweighted');
Kzavg=Aavgweighted*bhat(Gilkz);
dKzavg=sqrt(Aavgweighted*P(Gilkz,Gilkz)*Aavgweighted');
%Wavg=Aavg1*bhat(Gilw);
%dWavg=sqrt(Aavg1*P(Gilw,Gilw)*Aavg1');
Kzavg1=Aavg1*bhat(Gilkz);
dKzavg1=sqrt(Aavg1*P(Gilkz,Gilkz)*Aavg1');
if 1
  disp(sprintf('total top WT: %6.2g +/-%4.2g',WavgT,dWavgT))
  disp(sprintf('average   W : %6.2g +/-%4.2g',Wavg*1e4,dWavg*1e4))
  disp(sprintf('average   Kz: %6.2g +/-%4.2g',Kzavg,dKzavg))
  disp(sprintf('(non-whgt Kz: %6.2g +/-%4.2g)',Kzavg1,dKzavg1))
end 

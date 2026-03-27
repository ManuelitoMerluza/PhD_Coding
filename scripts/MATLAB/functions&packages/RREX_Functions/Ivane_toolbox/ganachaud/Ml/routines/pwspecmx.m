function pwspecmx(yhat_1,delt)
%Power spectrum from a fft matrix (columns are fft's)
%A.Ganachaud (orig. C.Wunsch/spectru3.m)
yhat_1=yhat_1/(N/sqrt(2));
%normalization is such that amplitude of a unit sine wave =1/2 in ft.
%%that's why root 2 is there. if want unit amplitude in power, divide
%%by 2 instead of root 2.
%%this differs from our normal fortran convention.
%not corrected for taper energy loss.
window=ones(M,1);
periody=yhat_1.*conj(yhat_1);   %%multiplies by conjugate. mixing + and
    %% minusfrequencies.  use with real data only.
specty=conv(window,periody);
%divide values by width of the averaging interval to get spectral density
% in units of cycles/delta t
specty=specty/(M/(delt*N));
%now decimate
s=M:M:N/2;
s1=length(s);
spectry=specty(s);
%discarding 1/2 the spectrum by symmetry. keeping only first 1/2.
   
%set up frequency  scale
freq(1,1)=(M-1)/2*(1/(N*delt));
freq(2:s1,1)=freq(1)+(M/(N*delt))*[1:s1-1]';
for ii=2:s1
  period(ii,1)=1/freq(ii,1);
end
if M==1
  period(1,1)=inf;
   else
     period(1,1)=1/freq(1,1);
end


%%compute approximate 95% confidence interval:
[lower,upper]=confid(.05, 2*M);


%spectru2.m spectrum using Daniell window and cosine taper.
%by C. Wunsch, 1987.
%%modified May and July 1995
%using fft.
%%same as spectru3.m except only plotting is suppressed
% M is window width--Daniell. delt must also be specified.
%%function [spectry,freq, lower,upper]=spectru2(yy,M,delt)
function [spectry,freq,lower,upper]=spectru2(yy,M,delt);

yy=yy(:);
%generate a taper window
  L=length(yy);
  L10=L/10;
  wind=ones(L,1);
  wind(1:L10,1)=1-cos([1:L10]'*pi/(2*L10));
  wind(L:-1:L-L10+1,1)=wind(1:L10,1);
  y_1=yy.*wind;
avgy=mean(y_1)
y_1=y_1-avgy;
yhat_1=fft(y_1);
N=length(yhat_1);
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


k9=length(spectry);num=[0:k9-1]';
format short e
spower=cumsum(spectry);
disp('    NUMBER     FREQ.         PERIOD      POWERY      CUMUL.POWERY')
[num,freq,period,spectry,spower]
disp('note to convert to power, use delfreq, not freq(1)')
disp('power computed will be the meansquare.')
disp('makes a unit sine wave have  power 1/2 NOT 1')
disp('differs from our fortran convention bybeing 1/2 not 1')
disp('to correct approximately for taper energy loss multiply by 1.182')
 format short;

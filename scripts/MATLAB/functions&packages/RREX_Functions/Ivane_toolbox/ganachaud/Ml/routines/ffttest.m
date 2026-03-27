%function ffttest 
% KEY: check and plot the normalization for spectrum and Fourier Transform
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
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , Nov 95
%
% SIDE EFFECTS :
%
% SEE ALSO :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER:
% CALLEE: spectru3.m, confid.m chisquat.m chiaux.m from Carl
%sampling period
dt=0.1;


N=2048;
t=dt*(0:N-1);

ds=1/(N*dt);
fre=ds*(0:N-1);
inte=1:N/2;
A=2*dt;

%fourier transform of a hypothetical white autocovariance 
acvy=zeros(N,1);acvy(1)=9;
plot(t(inte),real(acvy(inte)),'o')
pwr=A*fft(acvy);
plot(fre(inte),pwr(inte))
%the integral now (should be acvy(1))
ds*sum(pwr(inte))

%Now Carl's routine

Fmax=1/2/dt
y=sin(2*pi*0.5*t);
plot(t,y)


% spectrum
M=1;

[spect,s,lo,up]=spectru3(y,M,dt);

plot(s,spect)
%integral of the delta function - should be 0.5
max(spect)*ds

zoomrb
%perfect white noise
figure(2)
dt=0.1;
N=2048;M=1;
t=dt*(0:N-1);
ds=1/(N*dt);
acvy=zeros(N,1);
acvy(1:50)=ones(50,1);
acvy(51:100)=-ones(50,1);
[spect,s,lo,up]=spectru3(acvy,M,dt);
plot(s,spect)
ds*sum(spect)
dt*sum(acvy.^2)

y=randn(N,1);
yhat=A*fft(y);



rms(spect)

function x=rednoise(N,sig,rho)
wt=sig*randn(N,1);
x(1)=wt(1);
for ii=2:N
  x(ii)=rho*x(ii-1)+wt(ii);
end
if 0
  clf
  dt=1/12; %data in months/freq in cy/yr
  [spectry,freq, lower,upper]=spectru3(x,3,1/12);
  %analytical model
  fN=1/dt/2;f=1/(N*dt):1/(N*dt):fN;
  S=sig^2./(1-2*rho*cos(f/fN)+rho^2);
  semilogy(f,S,'r')
  hold on;
  semilogy(freq,50*spectry)
end
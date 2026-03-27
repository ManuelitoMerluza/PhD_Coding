%Alex, March 2nd 1998
%tests on the tapered least square uncertainties:
E=[5 5 0 ; 0 0 10];
x = [.5 0 -.5]';
sig_n=10;
alpha=1;
Noc=1000;
n=sig_n*randn(size(E,1),Noc);

Y0=E*x;
M=size(E,1);
N=size(E,2);
Rnn=sig_n^2*eye([M,M]);
Rxx=alpha^2*eye([N,N]);

Y=Y0*ones(1,Noc)+n;

for ioc=1:size(n,2)
  x_tilde(:,ioc)=Rxx*E'*((E*Rxx*E'+Rnn)\Y(:,ioc));
end
P=Rxx-Rxx*E'*((E*Rxx*E'+Rnn)\E)*Rxx;
dx=sqrt(diag(P));

%Uncertainty from Tapered, no null-space
Pnonull=sig_n^2*inv(E'*E+Rxx)*E'*E*inv(E'*E+Rxx)';
dxnonull=sqrt(diag(Pnonull));

%Uncertainty from the nullspace:
Pnull=alpha^2*inv(E'*E+Rxx)*Rxx*inv(E'*E+Rxx)

%Total uncertainty
Pnull+Pnonull

for i=1:N
  subplot(N,1,i)
  cla
  plot([0 Noc],[x(i) x(i)],'b',[0 Noc],[x(i) x(i)]-dx(i),'b',...
    [0 Noc],[x(i) x(i)]+dx(i),'b');hold on;
  plot(x_tilde(i,:),'ro')
end

[U,S,V]=svd(E);
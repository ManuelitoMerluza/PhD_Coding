%Least squares with null space uncertainty

E=[10 1];
y=10;
R=[1 0; 0 1];
W=1;



E1=E*R^.5;
for i=1:size(E,2)
  S(i,i)=1/sqrt(E(:,i)'*E(:,i));
end
xtilda=S*R^.5*E'*((E*R'^.5*S*R^.5*E'+W)\y)
n=y-E*xtilda
K1=inv(inv(R)*inv(S)+E'*inv(W)*E);
P =K1*(R^-.5*S^-1*S'^-1*R'^-.5+E'*inv(W)*E)*K1'

I=eye(size(E,2));
Ep=E1*S'^.5;
Ppp=(I-Ep'*inv(Ep*Ep'+W)*Ep)*S^-1*(I-Ep'*inv(Ep*Ep'+W)*Ep)'+...
  Ep'*inv(Ep*Ep'+W)*W*Ep*inv(Ep*Ep'+W)';
P2=R'^.5*S'^.5*Ppp*S^.5*R^.5

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Gauss-Markov
  N=1;
  n=0;
  y=2+n;
  
%original 4 stations
  R=eye(3);
  E=[2 2 2];
  %Avg temperature: [5 5 5]
  Et =4e12/1e13*[2*5 2*5 2*5];  %in 1e13 W
  Gut=4e12/1e13*[6*6 -4*4 -4*4];
  x=[1 .5 -.5]';
  
%skip one station
  R=eye(2);
  E=[2 4];
  %Avg temperature: [5 5]
  Et =4e12/1e13*[2*5 4*5];  %in 1e13 W
  Gut=4e12/1e13*[6*6 -8*4 ];
  x=[1 0]';

%Gulf-Stream situation
  N=2;
  n=0;
  y=15;
  R=diag([40 1].^2);
  E=[.25 10];
  
%scaling  
  for i=1:size(E,2)
    S(i,i)=(E(:,i)'*E(:,i))^(-.5);
  end
  avglength=mean(diag(S^-1));
  Rnew=avglength*R*S;
  R=Rnew;
  
%inversion
  K=R*E'*inv(E*R*E'+N);
  xtilda=K*y
  P=R-K*E*R;
  dx=sqrt(diag(P))
  ntilda=y-E*xtilda
  Pnn=E*P*E';
  dn=sqrt(diag(Pnn))
  

Gt=sum(Gut);
%Heat
H=Et*xtilda+Gt
dH=sqrt(diag(Et*P*Et'))
Ht=Et*x+Gt
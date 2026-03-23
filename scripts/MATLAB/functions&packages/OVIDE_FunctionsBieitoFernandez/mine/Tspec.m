function SK=Tspec(spc,a,b,c)

if nargin==4
    Xi=a;
    KB=b;
    K=c;
elseif nargin==3
   Xi=a(1);
    KB=a(2);
    K=b;
end
 
if spc=='K'    
    %Roget 2
    %q=3.9;
    q=5.26;
    k=1.44e-7;
    phi=KB/sqrt(2*q);
    y=K/phi;
    f=y.*exp(-sqrt(3)*y); %Kraichnan
    SK=Xi/(2*k*KB)*sqrt(2*q)*f;
elseif spc=='B'
    %Roget 2
    q=3.9;
    k=1.44e-7;
    phi=KB/sqrt(2*q);
    y=K/phi;
    f=y.*(exp(-y.^2/2)-y.*sqrt(pi()/2).*(1-erf(y/sqrt(2)))); %Batchelor
    SK=Xi/(2*k*KB)*sqrt(2*q)*f;
end
SK = SK;
end

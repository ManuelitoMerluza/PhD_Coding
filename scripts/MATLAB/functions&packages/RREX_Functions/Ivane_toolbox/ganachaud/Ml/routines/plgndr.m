function y = plgndr(l,m,x)
% associated Legendre polynomial Pl,m(x), 0 <= m <= l; -1<= x <=1
%synopsis : y = plgndr(l,m,x)
 
 % Cf Mtlab function LEGENDRE Associated Legendre functions

%description : 
 
 % Cf Numerical recipes, p247, plgndr.f

%uses :

% side effects : maybe not the fastest algorithme

% author : A.Ganachaud, Mar 95

%see also :

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (m<0)|(m>l)|any(abs(x)>1) error('bad arguments in plgndr'); end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% computess pmm
 pmm=ones(size(x));
 if m>0		
   somx2 = sqrt((1-x).*(1+x));
   fact=1;
   for i=1:m
     pmm=-fact*pmm.*somx2;
     fact=fact+2;
   end
 end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 if l == m
   y=pmm;
 else			
   pmmp1=(2.*m+1)*x.*pmm;	% computes pm,m+1
   if l == m+1
	y=pmmp1;
   else				% computes pm,l l>m+1
	for ll=m+2:l
	   pll=((2*ll-1)*x.*pmmp1-(ll+m-1)*pmm)/(ll-m);
	   pmm=pmmp1;
	   pmmp1=pll;
	end
	y=pll;
   end
 end

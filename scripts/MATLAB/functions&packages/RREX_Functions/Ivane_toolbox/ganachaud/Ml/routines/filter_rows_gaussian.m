function yf=filter_rows_gaussian(x,y,r)
% KEY: apply a gaussian smoothing to y rows. X is distance, 
%   r the smoothing radius Weight: exp(-.5*(x-x(i)).^2/r^2)
%   If NaN's are present, filter on the segments in between the NaN's
%   
% USAGE : yf=filter_rows_gaussian(x,y,r)
% 
% INPUT: 
%  x: distance between points (vector)
%  y: matrix of which to smooth the rows
%  r: radius of smoothing (number)
%
% OUTPUT:
%  yf: smoothed y matrix
%
% DESCRIPTION
%  
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , Jan 98
%
% SIDE EFFECTS :
%
% SEE ALSO :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER: general purpose
% CALLEE:

[m,n]=size(y);
x=x(:);
yf=NaN*ones(size(y));

for irow=1:m
  gig=~isnan(y(irow,:));
  gistart=1+find(diff(gig)==1);
  if gig(1)==1,gistart=[1 gistart];end
  gistop=   find(diff(gig)==-1);
  if gig(n)==1,gistop=[gistop n];end
  for isegment=1:length(gistart)
    gis=gistart(isegment):gistop(isegment);
    x1=x(gis);
    y1=y(irow,gis);
    yf1=NaN*ones(size(y1));
    for i=1:length(gis)
      gineighbors=find(abs(x1-x1(i))<(4*r));
      weights=exp(-.5*(x1(gineighbors)-x1(i)).^2/r^2);
      yf1(i)=sum( weights'.*y1(gineighbors))...
	/sum(weights);
    end
    yf(irow,gis)=yf1;
  end %for isegment=gistart;
end

if 0
  gig=~isnan(y(irow,:));
  for i=1:n
    gineighbors=find(abs(x-x(i))<(4*r));
    weights=exp(-.5*(x(gineighbors)-x(i)).^2/r^2);
    yff(:,i)=sum( (ones(m,1)*weights').*y(:,gineighbors),2)...
      /sum(weights);
  end
end

if 0
  %test
  x0=-100:100;
  ts=1;
  r=1;
  weights=exp(-.5*(x0).^2/r^2);
  [H,f]=freqz(weights,1,1024,1/ts);
  subplot(2,1,1)
  plot(x0,weights)
  set(gca,'xlim',[-50,50])
  xlabel('lag')
  ylabel('non-normalized weight')
  legend('r=10')
  subplot(2,1,2)
  plot(f,ts*abs(H))
  set(gca,'xlim',[0 0.1])
  xlabel('wavenumber')
  ylabel('response')
  suptitle('Gaussian filter')
  setlargefig
  
end
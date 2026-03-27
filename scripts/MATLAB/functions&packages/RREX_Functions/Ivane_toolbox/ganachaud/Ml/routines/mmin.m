function [yy,ii]=mmin(xy)
y=[];
z=[];
yy=[];
ii=[];
m=size(xy);

for j=1:m(2)

  z=xy(:,j);  ig=find(~isnan(z)>0);  [y,i]=min(z(ig)); yy=[yy y];ii=[ii,i];end 


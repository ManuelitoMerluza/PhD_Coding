function [yy]=sstd(xy)
y=[];
z=[];
yy=[];

m=size(xy);

for j=1:m(2)

  z=xy(:,j);  ig=find(~isnan(z)>0);  y=std(z(ig)); yy=[yy y]; end 


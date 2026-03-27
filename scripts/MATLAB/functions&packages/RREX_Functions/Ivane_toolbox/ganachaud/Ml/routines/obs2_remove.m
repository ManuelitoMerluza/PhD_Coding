%Graphic removal of data
diary off
disp('Select data to remove with mouse (one click above, one click below)')
disp('Click twice at the same point to proceed without modif')
diary on
[x,y]=ginput(2);
y=-y;
if y(1)>y(2)
  yyy=y(1);
  y(1)=y(2);
  y(2)=yyy;
end
gimiss=find(stdd>y(1)&stdd<y(2));
if ~isempty(gimiss)
  bprop(gimiss,is)=NaN;
  disp(sprintf('Data eliminated between %i and %i',10*fix(y(1)/10),10*fix(y(2)/10)))
end




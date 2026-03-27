function plot_vel(xx,yy,vel)
% KEY: plots the velocity with shadded negative values
% USAGE : plot_vel(xx,yy,vel)
% 
%
%
%
% DESCRIPTION : might take a long time
%
%
% INPUT:
%
% OUTPUT:
%
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , Jul 96
%
% SIDE EFFECTS :
%
% SEE ALSO :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER:
% CALLEE:

[cs, h, cf] = contourf(xx,yy,vel, [-1000 0]);
cn = .9*[1 1 1];
for i = 1:length(h)
  if get(h(i), 'CData') < 0
    set(h(i), 'FaceColor', cn)
  else
    set(h(i), 'FaceColor', 'w')
  end
end

vcont4=[0.5];         
vcont3=[1:1:10];       
vcont2=[1:1:10];           
vcont1=[0:10:(10+mmaxm(abs(vel)))];          
   vcont1=[-reverse(vcont1(2:length(vcont1))),vcont1];
   vcont2=[-reverse(vcont2),vcont2];
   vcont3=[-reverse(vcont3),vcont3];
   vcont4=[-reverse(vcont4),vcont4];
   
mxv=mmaxm(abs(vel));
miv=mminm(abs(vel));

hold on;
if mxv>10 | miv <0
  [c1,h1]=contour(xx,yy,vel,vcont1);
  h1l=clabel(c1,h1);
  for i=1:length(h1)
    set(h1(i),'linewidth',1);
  end
  for i=1:length(h1l)
    set(h1l(i),'fontsize',8)
  end
  drawnow
else
  [c2,h2]=contour(xx,yy,vel,vcont2,'-');
  h2l=clabel(c2,h2);  
  for i=1:length(h2)
    set(h2(i),'linewidth',.5);
  end
  for i=1:length(h2l)
    set(h2l(i),'fontsize', 8);
  end
  drawnow
end

if 0
[c3,h3]=extcontour(xx,yy,vel,vcont3,'-',...
  'label','fontsize', 8);
for i=1:length(h3)
  set(h3(i),'linewidth',.5);
end
drawnow
end

if 0
  [c4,h4]=extcontour(xx,yy,vel,vcont4,':',...
    'label','fontsize', 8);
  for i=1:length(h4)
    set(h4(i),'linewidth',1);
  end
  drawnow
end

hold off
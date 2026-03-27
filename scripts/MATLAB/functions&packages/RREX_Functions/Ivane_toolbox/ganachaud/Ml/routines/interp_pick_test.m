% test for interp_pick.m

x=0:5;
y=0:6;
[X,Y]=meshgrid(x,y);

%CHECK ON X
Z=1*X+0*Y;    
xi=[0.5 4 4.6];
yi=3;
[XI,YI]=meshgrid(xi,yi);

mask=ones(length(yi),length(xi));
zi=interp_pick(x,y,Z,xi,yi,mask);
mesh(x,y,Z);hold on
hold on;
plot3(XI,YI,zi,'+');xlabel('x');ylabel('y');zlabel('z');
hold off
grid on;view(0,0)

%CHECK ON Y
Z=Y;    
xi=[3];
yi=[0.5 4 4.6];
[XI,YI]=meshgrid(xi,yi);

mask=ones(length(yi),length(xi));
zi=interp_pick(x,y,Z,xi,yi,mask);
mesh(x,y,Z);hold on
hold on;
plot3(XI,YI,zi,'+');xlabel('x');ylabel('y');zlabel('z');
hold off
grid on;view(90,0)

%CHECK ON BOTH
Z=X+Y;
xi=sort(5*rand(20,1));
yi=sort(6*rand(20,1));
[XI,YI]=meshgrid(xi,yi);
mask=ones(length(yi),length(xi));
zi=interp_pick(x,y,Z,xi,yi,mask);
mesh(x,y,Z);hold on
hold on;
plot3(XI,YI,zi,'+');xlabel('x');ylabel('y');zlabel('z');
hold off
grid on;
view(-45,-45)



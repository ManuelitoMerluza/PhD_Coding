%  readlev.m
%  Purpose: reads Levitus annual temp and sali data
%  Chris Holloway, 8/11/99
%  inputs include IPdir, reads annual Levitus data files. 
%  outputs: ltemp, lsali, llon, llat, and ldep (Matlab variables for entire
%  globe for annual temp. and sali., along with corresponding Lat., Lon.,
%  and depth). 
%  CALLER: neutarea.m (or anything that defines IPdir)
%% Parameters: 
%% p_surf_contour: Plots contour of surface temps
%% IPdir: Input Directory, usually defined before calling program

%% Plots contour of surface temps:
p_surf_contour=1;

%% Input Directory (usually already defined by a CALLER program)
%% (This is where temp00.bin and sal00.bin are located.)
% IPdir= ;


fidt=fopen(sprintf('%stemp00.bin',IPdir));
fids=fopen(sprintf('%ssal00.bin',IPdir));
esize=[360,180]; 
ltemp=ones(360,180,33);
lsali=ones(360,180,33);
for k=1:33
  ltemp(:,:,k)=ffread(fidt,esize,'float32');
  lsali(:,:,k)=ffread(fids,esize,'float32');
end
llon=[0.5:359.5];
llat=[-89.5:89.5];
%% Depth in meters:
ldep=[0:10:30,50:25:150,200:50:300,400:100:1500,1750,2000:500:5500]; 


if p_surf_contour
  [cs,h]=contour(llon,llat,ltemp(:,:,1)',[-99.999,-99.999]); %% continents
  hold on;
  [cs2,h2]=contour(llon,llat,ltemp(:,:,1)',[-2:1:30]);
  clabel(cs2,h2,[0,10,20,28]);
  title('Levitus Surface Temps')
  xlabel('Longitude')
  ylabel('Latitude')
end

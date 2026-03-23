function [T1i,T2i,dx, dz,bottomi] = RREXInterpolation(T1,x1,pres1,bottom1,T2,x2,pres2,bottom2,tit)

% This function is used for interpolating 1 variable of both RREX
% cruises using a common grid

% INPUT
%        T1:      Variable for RREX2015 (Temperature, Salinity, Oxygen...) [M x N] 
%        T2:      Variable for RREX2017 (must be the same variable as T1)  [M x N]  
%        x:       Spatial Coordinate (latitude or longitude) [N] 
%        pres:    Pressure [M x N] 
%        bottom:  Depth of the bottom [N]
%        tit:     Title of the Figure

% OUTPUT
%        T1i:      Interpolated Variable for RREX2015  [Z x X] 
%        T2i:      Interpolated Variable for RREX2017  [Z x X]  
%        dx:       New Horizontal Cordinate [X] 
%        dz:       New Pressure Cordinate [Z] 
%        bottomi:  Interpolated Depth of the Bottom [X]

%% Preparing the variables for interpolation

% Finds the x coordinate that starts and ends the new dx variable
aux1=min([min(x1),min(x2)]); aux2=max([max(x1),max(x2)]);

% Makes a latitudinal vector with a step of 0.1deg
dx=round(aux1,1):0.1:round(aux2,1);

% The same for the z axis (pressure)
aux3=[max(max(pres1)),max(max(pres2))];

% Makes a depth vector with a step of 1 dbar
dz=0:1:aux3;

%% Make the water mass index a vector

NACW=NACW(:); SAW=SAW(:); SAIW=SAIW(:);
IW=IW(:); SPMW=SPMW(:); LSW=LSW(:); 
ISW=ISW(:); LDW=LDW(:); ISOW=ISOW(:);

%% Calculates the density backround for the T-S diagram

% Transform the matrices into a column vector
s=S(:); t=T(:); o=oxy(:); d=dens(:);

% This is for creating the density backround
xdim=2000 ; ydim=2000; % Size of temperature (x) and salinity (y) coordinates
sigma_sca=zeros(ydim,xdim); % Creating variable for density
thetai=linspace(min(t)-2,max(t)+2,xdim); % Temperature coordinates
si=linspace(min(s)-1,max(s)+1,ydim); % Salinity coordinates
for j=1:ydim
    for i=1:xdim
        sigma_sca(j,i)=eos80_legacy_sigma(si(i),thetai(j),0); % Creates density contours
    end
end
% Densities used in Figure 4 of Petit et al 2018
density_levels=[27, 27.52, 27.71, 27.8, 28];

%% Make the plot with Water Masses as colors

x=figure(); set(gcf, 'Position',  [100, 100, 800, 700])
h1 = scatter(s(NACW), t(NACW), 5, 'blue', 'filled');
hold on
h2 = scatter(s(SAW), t(SAW), 5, 'filled','MarkerFaceColor', [0.50196, 0, 0.12549]);
h3 = scatter(s(SAIW), t(SAIW), 5, 'cyan', 'filled');
h4 = scatter(s(IW), t(IW), 5, 'filled','MarkerFaceColor', [0.75 0.75 0.75]);
h5 = scatter(s(SPMW), t(SPMW), 5, 'green', 'filled');
h6 = scatter(s(LSW), t(LSW), 5, 'yellow', 'filled');
h7 = scatter(s(ISW), t(ISW), 5, 'filled', 'MarkerFaceColor', [1 0.5 0]);
h8 = scatter(s(LDW), t(LDW), 5, 'filled','MarkerFaceColor', [0.5 0 0.5]);
h9 = scatter(s(ISOW), t(ISOW), 5, 'red', 'filled');
xlim([34.5 35.3]); ylim([1 11])
[c,h]=contour(si,thetai,sigma_sca,density_levels,'--k');
clabel(c, h,'FontSize', 11, 'FontWeight', 'bold','LabelSpacing', 120, 'Color', 'k');
xlabel('Salinity','FontSize',13)
ylabel('Potential Temperature','FontSize',13)
title(tit,'FontSize',16)
grid on
hold off
legend([h1, h2, h3, h4, h5, h6, h7, h8, h9], ...
       {'NACW', 'SAW', 'SAIW', 'IW', 'SPMW', 'LSW', 'ISW', 'LDW', 'ISOW'}, ...
       'Location', 'southeast', 'NumColumns', 2, ...
       'FontSize', 10, 'FontWeight', 'bold');

end
function x = RREXWaterMasses(T,S,dens,oxy,tit)
% This function is used for plotting the water mass concentration in a
% T-S diagram

% I have to re-comment because i overwrotte this function by accident :p

% INPUT
%        T1:     
%        T2:     
%        x:      
%        pres:   
%        bottom: 
%        tit:    

%%

NACW=dens<27.52 & S>34.94;

SAW=dens<27.52 & S<34.94;

SAIW=dens>27.52 & dens<27.71 & S<34.94;

IW=dens>27.52 & dens<27.71 & S>34.94 & oxy < 272;

SPMW=dens>27.52 & dens<27.71 & S>34.94 & oxy > 272;

LSW=dens>27.71 & dens<27.8 & S<34.94;

ISW=dens>27.71 & dens<27.8 & S>34.94;

LDW=dens>27.8 & S<34.94;

ISOW=dens>27.8 & S>34.94;

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
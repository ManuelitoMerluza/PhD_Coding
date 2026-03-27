%close all; 
clear all;


section='ride';




%%% lecture des données
load(['/home4/homedir4/perso/isalaun/Matlab/matlab_output_RREX17/hydro_data/dens_sw_vs_gsw_',section,],'SA','CT','rho_gsw_exact','rho_sw', 'ga_sw');
load(['/home4/homedir4/perso/isalaun/Matlab/matlab_output_RREX17/vitesse_abs/OS38_section_',section,],'v_abs', 'z_abs','lat_abs','lon_abs');


%% ========================================================================
[bathy_ship,X_bathy,Y_bathy]=bathy_bateau_17(section);
bathy_ship = bathy_ship.*1e-3;

if strcmp(section,'south')||strcmp(section,'ride')||strcmp(section,'ovide');

if strcmp(section,'south')||strcmp(section,'ovide');
    ind_bad=find(bathy_ship(2:end-1)<1);
elseif strcmp(section,'ride'); 
    ind_bad=find(bathy_ship(2:end-1)<0.1);
end  
 
for i=1:length(ind_bad)
    j=length(ind_bad)+1-i;
    bathy_ship(ind_bad(j)+1)=[];
    X_bathy(ind_bad(j)+1)=[];
    Y_bathy(ind_bad(j)+1)=[];
end    

if strcmp(section,'south')||strcmp(section,'ovide');
    ind_bad=find(3.2<bathy_ship(2:end-3));
elseif strcmp(section,'ride'); 
    ind_bad=find(4.5<bathy_ship(2:end-3));
end   

for i=1:length(ind_bad)
    j=length(ind_bad)+1-i;
    bathy_ship(ind_bad(j)+1)=[];
    X_bathy(ind_bad(j)+1)=[];
    Y_bathy(ind_bad(j)+1)=[];
end

end


if strcmp(section,'ovide') || strcmp(section,'south') || strcmp(section,'north');
     xlab='longitude (°E)'; X1=lon_abs;
elseif strcmp(section,'ride');
     xlab='Latitude (°N)'; X1=lat_abs;
end
 
%%
r = rho_sw-rho_gsw_exact;

%%
 
zat=z_abs;
v=v_abs;
%[c,h]=contour(X_bathy(:),z_abs(1:4339).*1e-3,rho_sw-1000,[27.52 27.71 27.8],'-k','LineWidth',1);


figure;
set(gcf,'PaperType','A4','PaperOrientation','landscape','PaperUnits','centimeters','PaperPosition',[1,1,24,18],'Posi',[185 0 1200 800]);
%load mapcolor2; 
addpath('/home4/homedir4/perso/isalaun/Matlab/toolbox/my_colormap');
load vmap0
vcol=-.2:.02:.2;

%[c,h]=contourf(X1,zat.*1e-3,v,vcol);
%hold on; 
%[c,h]=contour(X1,zat.*1e-3,rho_sw(:,1:end-1)-1000,[27.52 27.71 27.8],'-k','LineWidth',1);
[c,h]=contour(X1,zat.*1e-3,rho_gsw_exact(:,1:end-1)-1000);

set(gca,'ydir','reverse')
xlabel(xlab); ylabel('Depth (km)');
limcol=[vcol(1) vcol(end)]; caxis(limcol); colormap(vmap); colorbar;
colormap(vmap); colorbar;
hold on; 
hold on; fill(X_bathy(:),bathy_ship,[0.5 0.5 0.5]);

if strcmp(section,'ovide');
    ylim([0 3.2]);
    xlim([-37 -27]);
elseif strcmp(section,'south');
    ylim([0 3.2]);
    xlim([-38.5 -31]);
elseif strcmp(section,'north');
    ylim([0 3]);
    xlim([-34 -20]);
elseif strcmp(section,'ride');
    ylim([0 4.35]); 
    xlim([48 64]);
end

%title(titre,'FontSize',12);
cbar = colorbar; 
cbar.Label.String = 'm/s'




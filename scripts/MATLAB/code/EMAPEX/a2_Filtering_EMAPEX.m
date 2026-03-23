% This is the script I'll use to filter out bad data from the EMAPEX floats
% that extracted previuosly and plot some figures to evaluate the data

% I'll use the data report as a reference for teh periods where floats
% worked correctly

% We load paths and colorbars
addpath(genpath('C:/Users/mitg1n25/Desktop/PhD/Year 1 - 2026'))
%addpath(genpath('D:/Respaldo PC/iop/materia/Magister/Semestre 2/PRODIGY/m_map/'))
set(0, 'DefaultAxesFontSize', 12);
set(0, 'DefaultAxesTitleFontSizeMultiplier', 1.15)

b={'4969' '4971' '7802' '7806' '7807' '7808'};
bmax=[771 240 40000 40000 160 196];
flag=[1 2 2 1 0 2]; % This means which sensor worked correctly (if 0 means both worked)

%% Save filtered floats

for i=1:length(bmax)

load(['EMAPEX_float',b{i},'.mat'])

if flag(i)==1                 % All the data of the 2nd chi sensor is BAD
    clear chi2 eps2 KT2
    chi=chi1; eps=eps1; KT=KT1;
elseif flag(i)==2                 % All the data of the 1st chi sensor is BAD
    clear chi1 eps1 KT1
    chi=chi2; eps=eps2; KT=KT2;
else
    chi=(chi1+chi2)*0.5 ; eps=(eps1+eps2)*0.5; KT=(KT1+KT2)*0.5;
end


% Delimit the last good value and filter out 
Nmax=find(dropnumber<bmax(i));

chi=chi(:,Nmax); eps=eps(:,Nmax); KT=KT(:,Nmax);
z=z(:,Nmax); Tz=Tz(:,Nmax); N2=N2(:,Nmax); 
time=time(Nmax); lat=lat(Nmax); lon=lon(Nmax); dropnumber=dropnumber(Nmax);

% Sort the matrices by depth
[z,sorted]=sort(z,1,"descend",'MissingPlacement','last');
[~,aux]=size(sorted);
for k=1:aux
    chi(:,k)=chi(sorted(:,k),k); eps(:,k)=eps(sorted(:,k),k); KT(:,k)=KT(sorted(:,k),k);
    Tz(:,k)=Tz(sorted(:,k),k); N2(:,k)=N2(sorted(:,k),k);
end

% Create the names of the variables that will contain the float number
name.dropnumber= sprintf('dropnumber_%s', b{i});
name.z= sprintf('z_%s', b{i});
name.lat= sprintf('lat_%s', b{i});
name.lon= sprintf('lon_%s', b{i});
name.time= sprintf('time_%s', b{i});
name.Tz= sprintf('Tz_%s', b{i});
name.N2= sprintf('N2_%s', b{i});
name.chi= sprintf('chi_%s', b{i});
name.eps= sprintf('eps_%s', b{i});
name.KT= sprintf('KT_%s', b{i});
namecell=struct2cell(name);

% Create a struct with the variables
OUTPUT.(namecell{1}) = dropnumber;
OUTPUT.(namecell{2}) = z;
OUTPUT.(namecell{3}) = lat;
OUTPUT.(namecell{4}) = lon;
OUTPUT.(namecell{5}) = time;
OUTPUT.(namecell{6}) = Tz;
OUTPUT.(namecell{7}) = N2;
OUTPUT.(namecell{8}) = chi;
OUTPUT.(namecell{9}) = eps;
OUTPUT.(namecell{10}) = KT;

% Save the filtered data
save(['EMAPEX_float',b{i},'_filtered.mat'], '-struct' , 'OUTPUT')
end

%% See the figures
% 
% load(['EMAPEX_float',b{2},'.mat'])
% 
% clear chi1 eps1 KT1
% chi=chi2; eps=eps2; KT=KT2;
% 
% % Delimit the last good value and filter out 
% Nmax=find(dropnumber<bmax(2));
% 
% chi=chi(:,Nmax); eps=eps(:,Nmax); KT=KT(:,Nmax);
% z=z(:,Nmax); Tz=Tz(:,Nmax); N2=N2(:,Nmax); 
% time=time(Nmax); lat=lat(Nmax); lon=lon(Nmax); dropnumber=dropnumber(Nmax);
% 
% 
% lim=[1e-11 1e-5];
% figure('Position',[20, 20, 1200, 900])
%     [aux,~]=size(chi);
%     time2d=repmat(time,aux,1);
%     pcolor(time2d,z,chi);shading flat;
%     set(gca,'ColorScale','log');
%     colorbar; clim(lim); colormap(slanCM('plasma'));
%     ylim([-1200 0]); % set(gca,'YDir','reverse'); 
%     xlabel('time')
%     title('\chi [K^2/s]');
% 
% 
% %%
% % Sort the matrices by depth
% [z_sorted,sorted]=sort(z,1,"descend",'MissingPlacement','last');
% [~,aux]=size(sorted);
% for k=1:aux
%     chi(:,k)=chi(sorted(:,k),k); eps(:,k)=eps(sorted(:,k),k); KT(:,k)=KT(sorted(:,k),k);
%     Tz(:,k)=Tz(sorted(:,k),k); N2(:,k)=N2(sorted(:,k),k);
% end
% 
% 
% % Plot again to see if it worked correctly
% lim=[1e-11 1e-5];
% figure('Position',[20, 20, 1200, 900])
%     [aux,~]=size(chi);
%     time2d=repmat(time,aux,1);
%     pcolor(time2d,z_sorted,chi);shading flat;
%     set(gca,'ColorScale','log');
%     colorbar; clim(lim); colormap(slanCM('plasma'));
%     ylim([-1200 0]); % set(gca,'YDir','reverse'); 
%     xlabel('time')
%     title('\chi [K^2/s]');
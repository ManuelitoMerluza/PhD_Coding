% This is the script I'll use to separate data from the hydrographic data
% from EMAPEX floats

% I intend to separate up and downcast and also sort the profile so all
% have ascending pressures in the first dimension


% We load paths and colorbars
addpath(genpath('C:/Users/mitg1n25/Desktop/PhD/Year 1 - 2026'))
%addpath(genpath('D:/Respaldo PC/iop/materia/Magister/Semestre 2/PRODIGY/m_map/'))
set(0, 'DefaultAxesFontSize', 12);
set(0, 'DefaultAxesTitleFontSizeMultiplier', 1.15)

b={'4969' '4971' '7802' '7806' '7807' '7808'};
bmax=[343 119 261 228 79 97];

%% Save filtered floats

for i=1:length(b)

    load(['EMAPEX_float',b{i},'_Hydrography.mat']);

    u=0.5*(u1+u2); v=0.5*(v1+v2); % Average both velocities
    
    even=NaN(1,length(time));
    for j=1:length(time) % Separate up and downcast
        [~, ma]=max(P(:,j)); [~, mi]=min(P(:,j)); 
        m=ma-mi; % I could just use odd and even numbers because there are some consecutive upcasts
            if m>0 % downcast
                even(j)=1;
            else % upcast
                even(j)=0;
            end
    end
    even=logical(even); % assing a logic for down (1) and upcast (0) data
    cast=1:length(time);
    downcast=cast(even); upcast=cast(~even);

    z=gsw_z_from_p(P,lat); % Compute depth
    % Sort the matrices by depth
    [z,sorted]=sort(z,1,"descend",'MissingPlacement','last');
    [~,aux]=size(sorted);
    for k=1:aux
        P(:,k)=P(sorted(:,k),k); S(:,k)=S(sorted(:,k),k); T(:,k)=T(sorted(:,k),k);
        v(:,k)=v(sorted(:,k),k); u(:,k)=u(sorted(:,k),k); W(:,k)=W(sorted(:,k),k);
    end

    even=logical(even); % assing a logic for down (1) and upcast (0) data
    u_down=u(:,even); u_up=u(:,~even);
    v_down=v(:,even); v_up=v(:,~even);
    T_down=T(:,even); T_up=T(:,~even);
    S_down=u(:,even); S_up=S(:,~even);
    P_down=P(:,even); P_up=P(:,~even);
    z_down=z(:,even); z_up=z(:,~even);
    W_down=W(:,even); W_up=W(:,~even);
    lat_down=lat(even); lat_up=lat(~even);
    lon_down=lon(even); lon_up=lon(~even);
    time_down=time(even); time_up=time(~even);

    % Defines the length so it coincides with micro float time series
    u_micro=u_up(:,1:bmax(i)); v_micro=v_up(:,1:bmax(i));
    T_micro=T_up(:,1:bmax(i)); S_micro=S_up(:,1:bmax(i));
    P_micro=P_up(:,1:bmax(i)); z_micro=z_up(:,1:bmax(i));
    W_micro=W_up(:,1:bmax(i));
    lat_micro=lat_up(1:bmax(i));
    lon_micro=lon_up(1:bmax(i));
    time_micro=time_up(1:bmax(i));


% Create the names of the variables that will contain the float number
name.z= sprintf('z_%s', b{i});
name.lat= sprintf('lat_%s', b{i});
name.lon= sprintf('lon_%s', b{i});
name.time= sprintf('time_%s', b{i});
name.T= sprintf('T_%s', b{i});
name.S= sprintf('S_%s', b{i});
name.P= sprintf('P_%s', b{i});
name.u= sprintf('u_%s', b{i});
name.v= sprintf('v_%s', b{i});
name.W= sprintf('W_%s', b{i});
name.upcast= sprintf('upcast_%s', b{i});
name.downcast= sprintf('downcast_%s', b{i});
namecell=struct2cell(name);

% Create a struct with the variables
OUTPUT.(namecell{1}) = z;
OUTPUT.(namecell{2}) = lat;
OUTPUT.(namecell{3}) = lon;
OUTPUT.(namecell{4}) = time;
OUTPUT.(namecell{5}) = T;
OUTPUT.(namecell{6}) = S;
OUTPUT.(namecell{7}) = P;
OUTPUT.(namecell{8}) = u;
OUTPUT.(namecell{9}) = v;
OUTPUT.(namecell{10}) = W;
OUTPUT.(namecell{11}) = upcast;
OUTPUT.(namecell{12}) = downcast;

% Save the filtered data
save(['EMAPEX_float',b{i},'_Hydrography_filtered.mat'], '-struct' , 'OUTPUT')
clear OUTPUT name namecell

% Repeat the same but for micro
name.z= sprintf('z_micro_%s', b{i});
name.lat= sprintf('lat_micro_%s', b{i});
name.lon= sprintf('lon_micro_%s', b{i});
name.time= sprintf('time_micro_%s', b{i});
name.T= sprintf('T_micro_%s', b{i});
name.S= sprintf('S_micro_%s', b{i});
name.P= sprintf('P_micro_%s', b{i});
name.u= sprintf('u_micro_%s', b{i});
name.v= sprintf('v_micro_%s', b{i});
name.W= sprintf('W_micro_%s', b{i});
namecell=struct2cell(name);

OUTPUT.(namecell{1}) = z_micro;
OUTPUT.(namecell{2}) = lat_micro;
OUTPUT.(namecell{3}) = lon_micro;
OUTPUT.(namecell{4}) = time_micro;
OUTPUT.(namecell{5}) = T_micro;
OUTPUT.(namecell{6}) = S_micro;
OUTPUT.(namecell{7}) = P_micro;
OUTPUT.(namecell{8}) = u_micro;
OUTPUT.(namecell{9}) = v_micro;
OUTPUT.(namecell{10}) = W_micro;

save(['EMAPEX_float',b{i},'_Hydrography_filtered_micro.mat'], '-struct' , 'OUTPUT')
clear OUTPUT name namecell

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
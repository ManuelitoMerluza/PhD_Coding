% author(s): I. Salaun 10/2018 from H. Mercier & T. Petit (RREX2015)
% Modified by: Manuel Torres 04/2026
% description : 
% Computation of geostrophic velocities across each hydrographic section of 
% the RREX2017 cruise (with or without bottom triangles, bottom triangles can be extrapolated by 4 different methods: planfit, 
% polyfit, cstslope, horizontale extrap (ie Ganachaud A., 1999)) and a reference depth (at surface or at 1200-m depth). 
% Derived from the thermal wind equation by using the dynamical height.
%
% see also : vit_SADCP_2017.m vit_geo_abs_2017.m 

%% Adds the path
addpath(genpath('C:/Users/mitg1n25/Desktop/PhD/PhD_Coding'))

% Defines the indices that will determine method and how data is stored
save_vgeo = 0; % Save geostrophic velocities
save_figure = 0; % Save figures
section = 'ride'; % Choise of transects: 'north', 'ovide','south' , 'ride'
ref = 'vect'; % Reference level type
extrap='other'; % Method for extrapolating in the bottom triangles 'other', 'horiz'
methode = 'polyfit'; %'pfit' (fit a plane), 'polyfit' (fit a polynomial), 'cstslope' (constant slope), 'horiz' (horizontal extrapolation)

%% Defines the transect to work on

if strcmp(section,'north')
    xref='lo'; % latitude or longitude in degrees N/E
    STA = [44:55 57]; STA=STA(:); nsta=size(STA,1); npair=nsta-1;
    titre_fig = 'vitesses_geo_rrex17_north';
elseif strcmp(section,'ovide')
    xref='lo';
    STA = [18:20 22:24 27:28 43:-1:41 38:-1:31];STA=STA(:); nsta=size(STA,1); npair=nsta-1;
    titre_fig = 'vitesses_geo_rrex17_ovide';
elseif strcmp(section,'south')
    xref='lo';
    STA = [1:8 11:17]; STA=STA(:); nsta=size(STA,1); npair=nsta-1;
    titre_fig = 'vitesses_geo_rrex17_south';
elseif strcmp(section,'ride')
    xref='lat';
    STA = [56:69 76:125]; STA=STA(:); nsta=size(STA,1); npair=nsta-1;
    titre_fig = 'vitesses_geo_rrex17_ride';
end

%% Loads Hydrographic data
fctd = 'C:/Users/mitg1n25/Desktop/PhD/PhD_Coding/data/RREX/Ivane_Hydro2017/ctd/nc/rr17_PRES.nc';

% Loads all the variables from the .nc file
S = ncread(fctd,'PSAL'); S = S(:,2:end); S = S(:,STA); % We don't consider station 1
T = ncread(fctd,'TPOT'); T = T(:,2:end); T = T(:,STA);
P = ncread(fctd,'PRES'); P = P(:,2:end); P = P(:,STA);
% Dynamic height from hydrography
H = ncread(fctd,'DYNH'); H = H(:,2:end); H = H(:,STA);

% Station positions
lat = ncread(fctd,'LATITUDE'); lat = lat(2:end); lat = lat(STA);
lg = ncread(fctd,'LONGITUDE'); lg = lg(2:end); lg = lg(STA);

Time = ncread(fctd,'JULD_BEGIN'); Time = Time(2:end); Time = Time(STA);
Time = datevec(double(Time));

%% Calculates dynamic height
ga = sw_gpan(S,T,P);

% Maximum pressure determination between stations
n = size(P,1); % n of pressure levels
m = size(P,2); % n of stations
for i = 1:m
    M = P(:,i); % extract p column for station i
    ind_keep = find(~isnan(M)); % finds good data
    pmae(i) = ind_keep(end)-1;  % 2nd to last valid pressure measurement
end

% Station pair matching
ipair = 1:m-1;
% ip = difference des prof des stations 2 a 2 (pente positive/negative) 
ip=find(diff(pmae)>=0); % Pairs where left station is deeper or equal
im=find(diff(pmae)<0); % Pairs where right station is deeper

% For pairs where left is deeper: use left's depth as shallowest common
ishdp(ip,1)=pmae(ip)+1; ishdp(ip,2)=pmae(ip+1)+1;
% For pairs where right is deeper: use right's depth as shallowest common
ishdp(im,1)=pmae(im+1)+1; ishdp(im,2)=pmae(im)+1;
% tableau des indices de stations sh (iss) et dp (isd) pour chaque pair
iss(ip) = ip; % Shallow station = left when left is deeper
iss(im) = im+1; % Shallow station = right when right is deeper
isd(ip) = ip+1; % Deep station = right when left is deeper
isd(im) = im; % Deep station = left when right is deeper

% dynamic height of the pair
sgpan = ga(:,iss); % Specific volume anomaly at shallower station
dgpan = ga(:,isd); % Specific volume anomaly at deeper station
pgpan = 0.5 * (sgpan + dgpan); % Average for the pair
%% Geostrophic velocity calculation

% reference level
switch ref
    case 'CDL'
        vect = inf(1,m-1); %deep common level
    case 'vect'
        vect = 1200; % Fixed reference at 1200 m
end

% vgeo_hm = Function that calculates geostrophic velocity from dynamic height
% Inputs:
% P	Pressure matrix (depth levels × stations)
% H	Dynamic height matrix (already computed)
% lat	Latitude of each station
% lg	Longitude of each station
% xref	'lat' or 'lon' - which coordinate to use for distance
% vect	Reference depth (1200m or deepest common)
% pmae	Index of deepest valid measurement per station
% Outputs:
% us	Geostrophic velocity (reference removed)
% xu	X-coordinate for plotting (latitude or longitude)
% refc	Reference level indices
% reffond	Bottom indices
% dpair	Distance between stations (km)

[us,xu,refc,reffond,dpair]=vgeo_hm(P,H,lat,lg,xref,vect,pmae); 
dpair = dpair'; clear us xu reffond;
sgpan_1 = sgpan; dgpan_1 = dgpan; % Saves data for later

% Bottom triangle extrapolation setup
Slat = lat ; Slon = lg;
% Difference in maximum depth between adjacent stations
var = diff(pmae); % var(i)>0 then station i is deeper than station i+1

% Creates variables for interpolation
d_interp_p=NaN*ones(size(sgpan,1),length(dpair));

% g_botwedge_test = Function that extrapolates specific volume anomaly into the bottom triangle
% Parameter	    Value	            Meaning
% methode	  'polyfit'	            Fitting method (polynomial fit)
% ipair(i)	   Station pair index	Which pair to process
% 'gpan'	   Variable type	    Specific volume anomaly
% 'm^2/s^2'	   Units	            For consistency
% P(:,i)	   Pressure	            Swapped pressure matrix
% sgpan(:,i)   Left station	        Specific volume anomaly
% ishdp(i,1)   Left depth index	    Deepest common level
% dgpan(:,i)   Right station	    Specific volume anomaly
% ishdp(i,2)   Right depth index	Deepest common level
% pgpan(:,i)   Average	            For the pair
% dpair(:,i)   Distance	            Between stations (km)
% 200	       Max slope	        Limits extrapolation slope

if strcmp(extrap,'other')
    for i=1:m-1    
        if var(i)>=0 % If left station is deeper
            P(:,[i i+1]) = P(:,[i+1 i]); % Swaps columns so that the shallower station is first
            [sgpan(:,i),dgpan(:,i)] = g_botwedge_test(methode, ipair(i),'gpan','m^2/s^2' , P(:,i), ...
                sgpan(:,i), ishdp(i,1), dgpan(:,i), ishdp(i,2), pgpan(:,i), dpair(:,i), 200);   
            P(:,[i i+1]) = P(:,[i+1 i]); % Swap backs
        elseif var(i)<0 % If right station is deeper
            [sgpan(:,i),dgpan(:,i)] = g_botwedge_test(methode, ipair(i), 'gpan','m^2/s^2' , P(:,i), ...
                sgpan(:,i), ishdp(i,1), dgpan(:,i), ishdp(i,2), pgpan(:,i), dpair(:,i), 200); 
        end
    end
    dgpan_2 = dgpan; dgpan = dgpan_1; % Saves the modified version

% The same process but for another extrapolation method
elseif strcmp(extrap,'horiz')
    for i=1:m-1    
        if var(i)>=0
            [sgpan(:,i),pgpan(:,i),dgpan(:,i)] = g_botwedge('polyfit', 0, ipair(i), 'gpan','m^2/s^2' , P(:,i+1), ...
                sgpan(:,i), ishdp(i,1), dgpan(:,i), ishdp(i,2), pgpan(:,i), dpair(:,i), 200);    
        elseif var(i)<0 
            [sgpan(:,i),pgpan(:,i),dgpan(:,i)] = g_botwedge('polyfit', 0, ipair(i), 'gpan','m^2/s^2' , P(:,i), ...
                sgpan(:,i), ishdp(i,1), dgpan(:,i), ishdp(i,2), pgpan(:,i), dpair(:,i), 200); 
        end
    end
end 

% Reference level index selection
% reffondd selects the shallower station's maximum depth as the reference for that pair.
switch ref
    case 'vect' 
        if ~isempty(ip)
            reffondd(ip)=pmae(ip);
        end 
        if ~isempty(im)
            reffondd(im)=pmae(im+1);
        end
        vect = reffondd;
        for i = 1:m-1
            irefc(i) = find(P(:,i)==vect(i)); % Index in pressure array where reference depth is located
        end             
end

% Coriolis calculation
latpair=(lat(1:m-1)+lat(2:m))/2;
f=2*7.29e-5*sin(latpair/180*pi);

% Geostrophic calculation
for i=1:m-1
  if isempty(irefc)
      irefc=max(find(P<=reffondd(i))); % finds the deepest pressure <= to the reference
  end
  if var(i)>=0 % if left station is deeper
      href = [sgpan(irefc(i),i) dgpan(irefc(i),i)]; % Dyn Height at reference level
      htot = [sgpan(:,i) dgpan(:,i)]; % Full profile
  else
      href = [dgpan(irefc(i),i) sgpan(irefc(i),i)];
      htot = [dgpan(:,i) sgpan(:,i)];
  end
  Hf=htot-ones(n,1)*href; % DH relative to the reference level
  dH=(diff(Hf'))'; % Difference between two stations
  ud(:,i)=dH/(f(i)*dpair(i)); % Geostrophic Velocity!
end

%% Horizontal extrapolation method (if selected)

if strcmp(extrap,'horiz') 

    issd = [iss ; isd]; issd_inv = issd(:,end:-1:1); % Indices for extrapolation (normal and reversed)
    The1 = T; She1 = S; The2 = T; She2 = S;
    for i =1:m-1
        % Extrapolates temperature and salinity using Ganachaud's method
        % South to North
        [stemp1(:,i),sflagt,isdeep]=g_horiz_extrap(T,issd_inv,i,Slat, Slon); 
        [ssal1(:,i),sflagt,isdeep]=g_horiz_extrap(S,issd_inv,i,Slat, Slon);
        iss_inv = iss(end:-1:1);
        The1(:,iss_inv(i)) = stemp1(:,i); % Stores extrapolated values
        She1(:,iss_inv(i)) = ssal1(:,i);
        % North to south
        [stemp2(:,i),sflagt,isdeep]=g_horiz_extrap(T,issd,i,Slat, Slon); 
        [ssal2(:,i),sflagt,isdeep]=g_horiz_extrap(S,issd,i,Slat, Slon);
        The2(:,iss(i)) = stemp2(:,i);
        She2(:,iss(i)) = ssal2(:,i);
    end

% Choose deepest extrapolation between the two directions
    for i=1:m
        if sum(isnan(The1(:,i))) > sum(isnan(The2(:,i))) % Takes the one that reaches deeper
            The(:,i) = The2(:,i);
            She(:,i) = She2(:,i);
        else
            The(:,i) = The1(:,i);
            She(:,i) = She1(:,i);
        end
    end

    % on recalcul la prof max pour avec triangle en extrap horizontale
    for i = 1:m
        ind_keep = find(isnan(The(:,i))==0);
        pmae_T2(i) = ind_keep(end);
    end

    % Calculates specific volume anomaly
    sga2 = sw_gpan(She,The,repmat([1:size(P,1)]',1,m)); % inutile car calcul sur Hdyn direct
    sga2 = -sga2./10;
    % Compures geostrophic velocity
    [uh1,xu,refc,reffond,dpair2]=vgeo_hm(repmat([0:4532]',1,m),sga2,lat,lg,xref,vect',pmae_T2); 

end      
      
%% Removes the reference velocity V = V(z) - V(1200)

vect2 = repmat(1200,1,m-1); % Reference depth array
% Finds deepest valid velocity index for each station pair
for i=1:m-1
    if strcmp(extrap,'horiz')
        Mh = uh1(:,i);
        indh = find(~isnan(Mh));
        pmae_H(i) = indh(end);
    elseif strcmp(extrap,'other')
        Md = ud(:,i);
        indd = find(~isnan(Md));
        pmae_D(i) = indd(end);
    end
end

% Adjust reference depth. If P<1200 in a stations uses maximum depth
if strcmp(extrap,'horiz')
    ireftouchfondh = find(pmae_H-vect2<0);
    vect2(ireftouchfondh)=pmae_H(ireftouchfondh);
elseif strcmp(extrap,'other')
    ireftouchfondd = find(pmae_D-vect2<0);  
    vect2(ireftouchfondd)=pmae_D(ireftouchfondd); 
end

% Subtract velocity at reference depth from the entire profile
for i=1:m-1
    if strcmp(extrap,'horiz')
        uh(:,i) = uh1(:,i) - uh1(vect2(i),i);
    elseif strcmp(extrap,'other')
        ud(:,i) = ud(:,i) - ud(vect2(i),i);
    end
end

%% Geostrophic velocity plot

% Midpoint of latitude and longitude
lgmoy = (lg(1:length(lg)-1) + lg(2:length(lg))) ./2; 
latmoy = (lat(1:length(lat)-1) + lat(2:length(lat))) ./2;
if strcmp(section,'ride') % Determines xaxis depending on the transect
    Xmoy = latmoy;
else 
    Xmoy = lgmoy;
end

% Converts P from decibars to meters
P = repmat([1:size(P,1)]',1,m-1);
P = sw_dpth(P(:,1:m-1),latmoy');

% White fill for the actual bathymetry of the vessel (RREX) = fill function
% bathymetry in metres
[bathy_ship,X,Y]=bathy_bateau(section); %si on veut mettre bathy RREX15..

%load(['/home/lpo5/RREX17/SCIENCE/Tillys/TP/Bathy_Sonde/Bathy_RREX17/bathy_rr17_nord.mat']);
%bth_sec = bth_sec.*1e-3;

% Plots the velocity profile

if strcmp(extrap,'other')
    U = ud;
elseif strcmp(extrap,'horiz')
    U = uh;
end    
vm=load('bwr.txt'); 
vcol=[-0.3:0.01:0.3];
ncol=length(vcol)-1;
ncol2=ncol/2;
npas=floor(64/ncol2);
vm2=vm(1:npas:npas*ncol2,:);
vm2=[vm2;flipud(vm(end:-npas:end-npas*ncol2+1,:))];
switch section 
    case {'ovide','north','south'}
        figure
        [c,h]=contourf(repmat(Xmoy',size(P,1),1),-P,U,[-0.3:0.01:0.3]);
        colormap(vm2);
        colorbar  
        caxis([-0.3 0.3])
        switch section
            case 'nord'
                set(gca,'ylim',[-3000 0])
                set(gca,'xlim',[-33.0008723 -20.9687344])
            case 'ovide'
                set(gca,'ylim',[-3117.20995 0])
                set(gca,'xlim',[-37.04 -27.33761])
            case 'sud'
                set(gca,'ylim',[-3200 0])
                set(gca,'xlim',[-38 -31.3])
            end
            ylabel('Depth (m)')
            xlabel('Longitude (°W)')
            % On les numÃ©rote
            xlab = num2str(STA,'%g');
            for ii=1:length(latmoy)
                testa(ii)=text(Xmoy(ii),0,xlab(ii,:),'Horizo','center','Color','k','Vertical','bottom');
            end
        set(testa,'FontName','Arial Narrow','FontSize',6,'FontAngle','italic','FontWeight','b');
    case 'ride'
        figure
        ax1 = gca;
        hold on
        [c,h]=contourf(repmat(Xmoy',size(S,1),1),-P,U,[-0.3:0.01:0.3]);
        xlabel('latitude (°N)')
        ylabel('Depth (m)')
        set(gca,'ylim',[-4350 0])
        set(gca,'xlim',[50.34861 63.3498])
        hold on
        colormap(vm2);
        caxis([-0.3 0.3])
        colorbar
        % On les numÃ©rote
        xlab = num2str(STA,'%g');
        for ii=1:length(latmoy)
            testa(ii)=text(latmoy(ii),0,xlab(ii,:),'Horizo','center','Color','k','Vertical','bottom');
        end
        set(testa,'FontName','Arial Narrow','FontSize',6,'FontAngle','italic','FontWeight','b');
end

if save_vgeo == 1
    saveas(gcf, ['C:/Users/mitg1n25/Desktop/PhD/PhD_Coding/docs/figures/Ivane_RREX_output/vgeo2017',titre_fig,'.png'])
end
%% ========================================================================
%%% Sauvegarde des vitesses geostrophiques pour chaque pair de station
    
if save_vgeo == 1

    rept = 'C:/Users/mitg1n25/Desktop/PhD/PhD_Coding/data/RREX/Ivane_output_RREX17/';
    for i=1:npair
        % generation du nom du fichier de sortie
        fic_vgeo = ['vitesse_geo/vgeo_' section '_' methode '_' num2str(STA(i),'%3.3d') '_' num2str(STA(i+1),'%3.3d')]; 
        display(['Traitement du fichier ' fic_vgeo]);
        dpair_geo=dpair(i); vgeo=ud(:,i);
        zl=P(:,find(max([pmae(i);pmae(i+1)])));
        zl = zl(:); lat_geo = latmoy(i); lon_geo = lgmoy(i);
        ref_up_bott_triangle = ishdp(i,1);                            
        save([rept fic_vgeo '.mat'],'dpair_geo','vgeo', 'zl', 'refc','lat_geo','lon_geo','ref_up_bott_triangle');
    end
end

%% ========================================================================

% for ip=1:npair
%     figure;
%     subplot(2,2,1);
%     plot(sgpan_1(reffondd(ip)-1:end,ip),-P(reffondd(ip)-1:end,ip),'r'); 
%     hold on; plot(sgpan(reffondd(ip)-1:end,ip),-P(reffondd(ip)-1:end,ip),'--b'); 
%     legend('sgpan ini','sgpan interp');
% 
%     subplot(2,2,3);
%     plot(dgpan_1(reffondd(ip)-1:end,ip),-P(reffondd(ip)-1:end,ip),'r');
%     hold on; plot(dgpan_2(reffondd(ip)-1:end,ip),-P(reffondd(ip)-1:end,ip),'--b');        
%     legend('dgpan ini','dgpan interp');
% 
%     subplot(2,2,4);
%     plot(dgpan_2(reffondd(ip)-1:end,ip)-dgpan_1(reffondd(ip)-1:end,ip),-P(reffondd(ip)-1:end,ip),'b');
%     legend('dgpan interp - dgpan ini','Location','southwest');
% 
%     subplot(2,2,2);
%     plot(sgpan_1(reffondd(ip)-1:end,ip)-dgpan_1(reffondd(ip)-1:end,ip),-P(reffondd(ip)-1:end,ip),'r');
%     hold on; plot(sgpan(reffondd(ip)-1:end,ip)-dgpan_1(reffondd(ip)-1:end,ip),-P(reffondd(ip)-1:end,ip),'--b');
%     legend('sgpan ini - dgpan ini','sgpan interp - dgpan ini','Location','southwest');

%     saveas(gcf, ['../figures/prof_vSADCP_vgeo_RREX17/bottom_tr_vgeo_' methode '_zoom_pair' num2str(STA(ip)) '_RREX17.png'])
%     
% %     zl=P(:,find(max([pmae(ip);pmae(ip+1)])));
% %     z_ref = ishdp(ip,1);  
% %     
% % figure;
% % hold on;
% % plot(ud(1:z_ref,ip),-zl(1:z_ref),'r','LineWidth',1)
% % plot(ud(z_ref:end,ip),-zl(z_ref:end),'b','LineWidth',1)
% 
% close all
 % end


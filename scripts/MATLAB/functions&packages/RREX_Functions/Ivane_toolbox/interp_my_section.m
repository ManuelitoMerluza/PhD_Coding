function var_grid_depth = interp_my_section(Lon,D,var,Lon_grid,D_grid,aspect_ratio)

%% Initialize
n_D=size(D_grid,1);
n_Lon=size(Lon_grid,1);
var_grid_depth=NaN(n_D,n_Lon);

%% rapport d'aspect
Lon=Lon.*aspect_ratio;
Lon_grid=Lon_grid.*aspect_ratio;

%% Interpolation 
J=~isnan(Lon) & ~isnan(var) &  ~isnan(D) ;
FTheta_grid_depth=scatteredInterpolant(Lon(J), D(J), var(J),'linear','none'); % add 'none' if no extrapolation wanted


for il=1:n_Lon
    
    for ip=1:n_D
        
        var_grid_depth(ip,il)=FTheta_grid_depth(Lon_grid(il),D_grid(ip));
        
    end
    
end

if D_grid(1) < 5 
var_grid_depth(1,:) = var_grid_depth(2,:);
end

end
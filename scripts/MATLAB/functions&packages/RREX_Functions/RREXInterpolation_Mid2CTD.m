function [T1i] = RREXInterpolation_Mid2CTD(T1,x1,pres1,x2,pres2,section)

% This function is used for interpolating mid station variables (like
% geostrophic velocity) into the original CTD positions

% INPUT
%        T1:        Variable for RREX (Velocity or Transport) [M1 x N1] 
%        x1:        Spatial Coordinate (latitude or longitude) [N1] 
%        pres1:     Pressure [M1] 
%        x2,pres2:  Grid points for interpolation [X], [X, Z]

% OUTPUT
%        T1i:      Interpolated Variable for RREX  [Z x X] 


if strcmp(section,'ride')

    %% Preparing the variables for interpolation

    [dx, aux]=sort(x1); T1=T1(:,aux); dz=pres1;
    [X,Z]=ndgrid(dx,dz); % Original grid

    dxf=sort(x2); dzf=nanmean(pres2,2);
    [Xf,Zf]=ndgrid(dxf,dzf); % Grid for interpolation

    %% Interpolation

    F = griddedInterpolant(X,Z,T1','nearest','makima');

    T1i=F(Xf,Zf);
    T1i=fliplr(T1i');

else
    dx=x2; dz=nanmean(pres2,2);

    % Makes a 2D latitude for the interpolation
    [M1,N1]=size(T1); x1_2D=repmat(x1',M1,1);
    z1_2D=repmat(pres1,1,N1);

    % Convert everything to vectors
    x1_vec = x1_2D(:);
    pres1_vec = z1_2D(:);
    T1_vec = T1(:);

    % Remove any NaN if present
    valid_idx = ~isnan(T1_vec) & ~isnan(x1_vec) & ~isnan(pres1_vec);
    x1_vec = x1_vec(valid_idx);
    pres1_vec = pres1_vec(valid_idx);
    T1_vec = T1_vec(valid_idx);

    %% Interpolation

    % Create interpolant
    F1 = scatteredInterpolant(x1_vec, pres1_vec, T1_vec, 'nearest');

    % Target grid
    [dX, dZ] = meshgrid(dx,dz);

    % Interpolate
    T1i = F1(dX, dZ);

end

end
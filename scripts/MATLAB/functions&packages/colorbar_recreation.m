img = imread('colorbar.png');

% Extract a vertical strip from the colorbar area
% Adjust these coordinates based on your image; % Sample strip from colorbar

% Average colors vertically to get smooth colormap
colorbar_colors = squeeze(mean(img, 2)); % Average vertically
colorbar_colors = flipud(double(colorbar_colors)) / 255; % Convert to 0-1 range

% Create colormap from extracted colors
extracted_cmap = colorbar_colors;

% Apply to your plot
figure;
contourf(peaks(100));
colormap(extracted_cmap);
caxis([-4500, 500]); % Your color limits
colorbar;

%% Save the colorbar

matlab
% Create colormap package
colormap_data.cmap = extracted_cmap;  % The colormap
colormap_data.clim = caxis;      % Associated data range
colormap_data.name = 'DepthMap';
colormap_data.date = datetime('now');

% Save
save('colormap_RREX.mat', '-struct', 'colormap_data');

% Load and apply
loaded = load('colormap_RREX.mat');
colormap(loaded.cmap);
caxis([-4500 500]);  % Restore the data range too
colorbar
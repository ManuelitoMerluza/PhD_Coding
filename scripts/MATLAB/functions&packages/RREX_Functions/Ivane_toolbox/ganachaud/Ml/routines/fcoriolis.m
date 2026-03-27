function fc=fcoriolis( lat )
% coriolis factor f calculation, lat in degree

% fc0 = 2 .* 2 .* pi ./ 24 ./ 3600;
fc0 = 1.454441043328608e-04;

fc = fc0 .* sin(lat.*pi./180);
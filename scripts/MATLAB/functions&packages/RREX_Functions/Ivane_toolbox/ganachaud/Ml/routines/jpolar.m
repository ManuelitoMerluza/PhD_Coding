function hpol = jpolar(Theta, ...
					   Rho, ...
					   LineStyle, ...
					   LineWidth, ...
					   symRange, ...
					   symSize, ...
					   colorTable, ...
					   symColor, ...
					   rticks, ...
					   tickPos, ...
					   labelTicks, ...
					   tickLabel, ...
					   spokes, ...
					   labelSpokes, ...
					   angleDir, ...
					   axisPos)
%JPOLAR	Polar coordinate plotting routine providing control over all
%aspects of the polar plot, including symbol size and color encoding.
%
%Note: JPOLAR is an modified and extended version of POLARHG, so much
%thanks to John L. Galenski III for getting JPOLAR 90% there.
%
%Usage: plotHandle = jpolar(Theta,
%			   Rho,
%			   LineStyle,
%			   LineWidth,
%			   symRange,
%			   symSize,
%			   colorTable,
%			   symColor,
%			   rticks,
%			   tickPos,
%			   labelTicks,
%			   tickLabel,
%			   spokes,
%			   labelSpokes,
%			   angleDir,
%			   axisPos)
%
%Parameters:
%  Theta	Polar angle data (column vector; radians).
%
%  Rho		Polar magnitude data (column vector). This data is not
%		normalized to zero (i.e., Rho = Rho - min(Rho)) as is done
%		in POLARHG; the user can do this before calling JPOLAR if
%		desired; Rho values <0 are acceptable and handled as expected
%		in polar plotting (i.e., -Rho is 180degrees from +Rho).
%
%  LineStyle	String, 'o', '.', etc (see PLOT for the complete list).
%
%  symRange	Vector containing the range of symbol sizes to encode (e.g.,
%		[ minSize maxSize ]); set minSize == maxSize to force all
%		symbols to be the same size.
%
%  symSize	Column vector of data values to be used for mapping symbol
%		sizes; symSize data is scaled to the symbol size range.
%
%  colorTable	Column vector of RGB values created from scratch or via
%		Matlab's predefined color table routines (see COLOR).
%
%  symColor	Column vector of data values to be used for mapping symbol
%		colors; data is scaled to discrete values on the interval
%		[1,NumOfColors] and then used as indices into the color table.
%
%  rticks	Integer, the number of polar magnitude ticks (circles) drawn on
%		the polar axis.
%
%  tickPos	Row vector of polar magnitude tick positions (expressed in terms
%		of the Rho data). If tickPos ~= [], then radial ticks are placed
%		at the positions specified and the value 'rticks' is ignored; if
%		tickPos == [], then radial ticks will be generated automatically
%		at increments of max(Rho)/rticks. Important: If tick positions
%		are specified, this implementation uses max(tickPos) as the axis
%		limits (e.g., axis(max(tickPos)*[-1.0 1.0 -1.0 1.0])); therefore,
%		max(tickPos) should be approximately >= max(abs(Rho)) unless you
%		want data be clipped.
%
%  labelTicks	String, 'yes' or 'no', depending on whether you want radial ticks
%		to be labeled.
%
%  tickLabel	Column vector of strings to be used for labeling radial tick marks;
%		the number of labels should be >= rticks or, in the case of specific
%		tick positions, >= length(tickPos); if not, JPOLAR will generate
%		labels if length(tickLabel) is insufficient.  This parameter is
%		best created by the STR2MAT routine since matlab requires all
%		strings in a matrix to have the same length. For example, in the
%		case of non-numeric tick labels:
%			tickLabel = str2mat('One', 'Two', 'Three');
%		Or, in the case of numeric data:
%			tickLabel = str2mat('10', '20', '30');
%
%  spokes	Integer, the number of spokes (>0) to draw on the polar axis;
%		JPOLAR draws spokes at [0,max(abs(Rho)] at angle increments of
%		2pi/spokes; for example, spokes == 3 will cause spokes to be drawn
%		at 0, 120, and 240 degrees (POLARHG draws spokes at angle increments
%		of pi/spokes and draws them from RhoMax to RhoMax through the origin,
%		actually creating 2*spokes).
%
%  labelSpokes	String, 'yes' or 'no', depending on whether you want axis spokes
%		to be labeled.
%
%  angleDir	String, specifies whether the polar angle is clockwise ('cw') or
%		counterclockwise ('ccw').
%
%  axisPos	String, specifies the position of the 0th polar degree: 'right',
%		'left', 'up', and 'down'. 
%
%Requirements:	size(Theta) == size(Rho) == size(symSize) == size(symColor)
%
%Example call:
%  t = (0:.01:2*pi)';
%  r = sin(2*t).*cos(2*t);
%  symColor = abs(randn(length(t),1));
%  symSize = abs(randn(length(t),1)) .* abs(randn(length(t),1));
%  jpolar(t,r,'.',2,[10 80],symSize,hot(20),symColor,1,[],'yes',[],3,'yes','cw','up');
%
%Author: Jay Kummer (kummer@its.mcw.edu), Software Guy, Medical College of WI.

%%Written for E. A. DeYoe, K. Williams, A. Rosen
%%
%% Work to do & wish list:
%%	1. Better parameter checking.
%%	2. Graphical interface for modifying these parameters.
%%	3. Spokes are labeled in degrees, by default; user should be able to control
%%	   this (like tickLabel).
%%	4. Polar surface or mesh plot from raw data (Theta,Rho,Amplitude) would be cool.
%%	5. If symbol sizes are encoded, there should be a legend drawn (on the left
%%	   side of the plot) that shows the raw data values corresponding to the min
%%	   and maximum size symbol.

if nargin ~= 16
	fprintf('!! Wrong argument count: See HELP JPOLAR !!\n');
	return;
end

% Check parameters
if isstr(Theta)
	error('Theta must be numeric.');
end
if isstr(Rho)
	error('Rho must be numeric.');
end
if isstr(symRange)
	error('symRange must be numeric.');
end
if isstr(symSize)
	error('symSize must be numeric.');
end
if isstr(colorTable)
	error('colorTable must be numeric.');
end
if isstr(symColor)
	error('symColor must be numeric.');
end
if isstr(LineWidth)
	error('LineWidth must be numeric.');
end

if rticks < 0
	rticks = 0;
end

if spokes < 0
	spokes = 0;
end

if LineWidth < 1
	fprintf('Setting default line width (1).\n');
	LineWidth = 1;
end

[ numColors, rgb ] = size(colorTable);
if rgb ~= 3
	error('Ill-formed RGB values in color table.');
end
if numColors == 0
	error('Must specify at least one color for plotting.');
end
fprintf('Color table contains %d colors.\n', numColors);

% Get vector sizes
[ Trows Tcols ] = size(Theta);
[ Rrows Rcols ] = size(Rho);
[ Crows Ccols ] = size(symColor);
[ Srows Scols ] = size(symSize);

if any(Trows ~= Rrows | Trows ~= Srows | Trows ~= Crows)
	error('Theta, Rho, symColor and symSize must be the same size.');
end

rows = Trows;
fprintf('Plotting %d rows of data.\n', rows);

hold on;

% get hold state
cax = newplot;
next = lower(get(cax,'NextPlot'));

% get x-axis text color so grid is in same color
tc = get(cax,'xcolor');

% Hold on to current Text defaults, reset them to the
% Axes' font attributes so tick marks use them.
fAngle  = get(cax, 'DefaultTextFontAngle');
fName   = get(cax, 'DefaultTextFontName');
fSize   = get(cax, 'DefaultTextFontSize');
fWeight = get(cax, 'DefaultTextFontWeight');
set(cax, 'DefaultTextFontAngle',  get(cax, 'FontAngle'), ...
	'DefaultTextFontName',   get(cax, 'FontName'), ...
	'DefaultTextFontSize',   get(cax, 'FontSize'), ...
	'DefaultTextFontWeight', get(cax, 'FontWeight') )

% Get data bounds
rmax = max(abs(Rho));

if [] == tickPos
	rhoLimit = rmax;
else
	rhoLimit = max(tickPos);
end

if [] ~= tickLabel
	[ labelCount tmp ] = size(tickLabel);
else
	labelCount = 0;
end

% Set up the axis attributes
axis(rhoLimit*[-1.0 1.0 -1.0 1.0]);
axis('equal');
axis('off');

% Plot circular grid
% define a circle
th = 0:pi/50:2*pi;
xunit = cos(th);
yunit = sin(th);

% Now really force points on x/y axes to lie on them exactly
inds = [1:(length(th)-1)/4:length(th)];
xunits(inds(2:2:4)) = zeros(2,1);
yunits(inds(1:2:5)) = zeros(3,1);

if [] == tickPos % No tick positions are specified, generate them if desired.
	fprintf('No fixed tick positions specified.\n');
	if rticks > 0
		fprintf('Drawing %d radial tick marks...\n', rticks);
		rinc = rhoLimit/rticks;
		j = 1;
		for i=rinc:rinc:rhoLimit
			plot(xunit*i,yunit*i,'-','color',tc,'linewidth',1);
			if strcmp(labelTicks,'yes')
				if j <= labelCount % Then use the one the use specified
					fprintf('Labeling tick with user-provided label (%s)...\n', tickLabel(j,:));
					text(0,i+rinc/20,['  ' tickLabel(j,:)],'verticalalignment','bottom' );
				else % Generate one automagically
					fprintf('Generating a tick label...\n');
					text(0,i+rinc/20,['  ' num2str(i)],'verticalalignment','bottom' );
				end
			end
			j = j+1;
		end
	end
else % Tick positions are specified
	fprintf('Fixed tick positions specified.\n');
	[ pCount tmp ] = size(tickPos);
	fprintf('Drawing %d radial tick marks...\n', pCount);
	for i=1:pCount
		plot(xunit*tickPos(i),yunit*tickPos(i),'-','color',tc,'linewidth',1);
		if strcmp(labelTicks,'yes')
			if i <= labelCount % Then use the one the use specified
				fprintf('Labeling tick with user-provided label (%s)...\n', tickLabel(i,:));
				text(0,tickPos(i)*1.03,['  ' tickLabel(i,:)],'verticalalignment','bottom' );
			else % Generate one automagically
				fprintf('Generating a tick label...\n');
				text(0,tickPos(i)*1.03,['  ' num2str(tickPos(i))],'verticalalignment','bottom' );
			end
		end
	end
end

% Plot spokes
if spokes > 0
	th = (1:spokes)*2*pi/spokes;
	cst = cos(th);
	snt = sin(th);
	cs = [ zeros(spokes) ; cst];
	sn = [ zeros(spokes) ; snt];
	plot(rhoLimit*cs,rhoLimit*sn,'-','color',tc,'linewidth',1);

	% annotate spokes in degrees
	if strcmp(labelSpokes,'yes')
		rt = 1.1*rhoLimit;
		for i = 1:max(size(th))
			text(rt*cst(i),rt*snt(i),int2str(rem(round(th(i)*180/pi), 360)),'horizontalalignment','center' );
		end
	end
end

% Set 2-D view
if strcmp(angleDir,'ccw') & strcmp(axisPos,'right')
  view(0,90);
  InitTh = 0;
elseif strcmp(angleDir,'ccw') & strcmp(axisPos,'left')
  view(180,90);
  InitTh = 1;
elseif strcmp(angleDir,'ccw') & strcmp(axisPos,'up')
  view(-90,90);
  InitTh = 2;
elseif strcmp(angleDir,'ccw') & strcmp(axisPos,'down')
  view(90,90);
  InitTh = 3;
elseif strcmp(angleDir,'cw') & strcmp(axisPos,'right')
  view(0,-90);
  InitTh = 0;
elseif strcmp(angleDir,'cw') & strcmp(axisPos,'left')
  view(180,-90);
  InitTh = 1;
elseif strcmp(angleDir,'cw') & strcmp(axisPos,'up')
  view(90,-90);
  InitTh = 2;
elseif strcmp(angleDir,'cw') & strcmp(axisPos,'down')
  view(-90,-90);
  InitTh = 3;
else
  error('Invalid angle direction or axis orientation')
end
if strcmp(axisPos,'up') | strcmp(axisPos,'down')
  axis square
end

% Reset defaults.
set(cax, 'DefaultTextFontAngle', fAngle , ...
	'DefaultTextFontName',   fName , ...
	'DefaultTextFontSize',   fSize, ...
	'DefaultTextFontWeight', fWeight );

% Get cartesian data
xx = Rho.*cos(Theta);
yy = Rho.*sin(Theta);

% Scale symSize data for symbol size
minSize = min(symRange);
maxSize = max(symRange);
dMin = min(symSize);
dMax = max(symSize);
if any(dMin == dMax | minSize == maxSize)
	symSize = ones(rows, 1) * ((minSize+maxSize)/2); % set to all the same
else
	symSize = round(((symSize-dMin)/(dMax-dMin)*(maxSize-minSize))+minSize);
end

% Scale symColor data to symbol table indices
cMin = 1;
cMax = numColors;
dMin = min(symColor);
dMax = max(symColor);
if 1 == numColors
	symColor = ones(rows, 1); % Make all color indices the same
else
	symColor = round(((symColor-dMin)/(dMax-dMin)*(cMax - cMin))+cMin);
end

% Plot data
h = plot(xx(1,:), yy(1,:));
c = colorTable(symColor(1),:);
set(h, 'Color', c, 'MarkerSize', symSize(1), 'LineStyle', LineStyle, 'LineWidth', LineWidth);
for i = 2:rows
	h = [ h ; plot(xx(i), yy(i)) ];
	c = colorTable(symColor(i),:);
	set(h(i), 'Color', c, 'MarkerSize', symSize(i), 'LineStyle', LineStyle, 'LineWidth', LineWidth);
end

colormap(colorTable);
ch = colorbar('vert');

%Move the colorbar to the right a bit
cpos = get(ch, 'position');
cpos = cpos .* [ 1.05 1 1.05 1];
set(ch, 'position', cpos);

if nargout > 0
	hpol = h;
end

% reset hold state
set(cax,'NextPlot',next);
hold off;

end;

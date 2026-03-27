% MatDraw GUI Toolbox
% Version 2.0 3/2/95
% Copyright (c) 1995 by Keith Rogers
%
% Main Program:
%   matdraw     - Set up menus for current figure and create
%                 the draw palette if it doesn't exist.
%   mdprog      - Called by matdraw, does most of actual work.
%
% Programs which may be called independently:
%   labels      - Interactively set title and labels
%   viewer      - Interactively control view for 3D graphs
%   pgsetup     - Interactively control page-related figure
%                 properties
%
% Utility functions, may be useful to anyone
%   degrees     - Convert radians to degrees
%   ellipse     - draws an ellipse
%   findfig     - Get figure handle by name (faster than findobj)
%   gcm         - Get Current Menu (from Mathworks)
%   isobj       - True for valid handle
%   kdialog     - Modification of Mathworks dialog function
%                 to add prompter dialog box
%   klayout     - Modification of Mathworks layout function
%                 to add prompter dialog box
%   palette     - Create a palette of tools (user customizable)
%   prmptdlg    - Prompter dialog box for getting user input
%   radians     - Convert degrees to radians
%   rot4x       - 4x4 matrix for X rotations (used by viewer)
%   rot4y       - 4x4 matrix for Y rotations (used by viewer)
%   rot4z       - 4x4 matrix for Z rotations (used by viewer)
%   store       - Store data in invisible text objects
%   streamer    - Centered title for pages with many subplots
%
% Callbacks, shouldn't be used directly
%  axcback      - Callbacks for the Axis menu
%  dmencback    - Callbacks for the Draw menu
%  drwcback     - Callbacks for the Draw Tools palette
%  figcback     - Callbacks for the Figure menu
%  mdpick       - Finds focus for zoom function (3D too!)
%  mdzoom       - Zoom function, must be called from menu
%  zoom3d       - Handles zooms for 3D objects
%  movetext     - Handles movement and rotation of text
%  select       - Selection, movement, resizing of objects
%  txtcback     - Callbacks for fiddling with text objects
%  vwrcback     - Callbacks for viewer
%  wrkcback     - Callback for WorkSpace menu (not on Macs)

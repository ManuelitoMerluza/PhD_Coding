%LAYOUT script to define dialog box layout parameters.
%

%	Author(s): A. Potvin, 5-1-93
%  Modified by Keith Rogers, 11/11/94
%	Copyright (c) 1984-94 by The MathWorks, Inc.
%	$Revision: 1.4 $  $Date: 1994/03/15 16:02:17 $

mDoneButtonString = 'Done';
mOkButtonString = 'OK';
mRevertButtonString = 'Revert';
mCancelButtonString = 'Cancel';

% Following in  pixels
mStdButtonWidth = 90;
mStdButtonHeight = 20;
mOKButtonWidth = 50;
mOKButtonHeight = 20;
if(strcmp(Style,'prompter'))
	mEdObjHeight = 20;
else
	mEdObjHeight = 0;
end

mEdgeToFrame = 1;
mFrameToText = 15;
COMPUTER = computer;
if strcmp(COMPUTER(1:2),'PC')
   mLineHeight = 13;
else
   mLineHeight = 15;
end

% end layout

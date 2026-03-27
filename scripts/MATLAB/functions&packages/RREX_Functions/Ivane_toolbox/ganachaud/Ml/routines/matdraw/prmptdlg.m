function answer = prmptdlg(question,default,dlgname,Replace)
%PRMPTRDLG Creates an error dialog box.
%       ANSWER = PRMPTDLG(QUESTION,DEFAULT,DLGNAME,Replace) 
%       creates a prompter dialog box for user input in a window
%       named DLGNAME.  A pushbutton labeled OK must be pressed 
%       to make the prompter disappear.  If REPLACE='on' and 
%       a prompter with Name DLGMANE already exists, it is
%       simply brought to the front (no new dialog is created).
%       On return, ANSWER will contain the contents of the
%       Prompter's Edit UIObj.
%
%       See also: DIALOG

%	Author(s): K. Rogers, 11-11-94
%	$Revision: 1.01 $  $Date: 1995/1/20  $

ni = nargin;
if ni==0,
   question = 'Input:';
end
if ni<2,
   default = '';
end
if ni<3,
   dlgname = 'Prompter Dialog';
end;
if ni<4,
   Replace = 'off';
end

answer = kdialog('Style','prompter','TextString',question, ...
                'default',default,'Name',dlgname,'Replace',Replace);

% end prompterdlg

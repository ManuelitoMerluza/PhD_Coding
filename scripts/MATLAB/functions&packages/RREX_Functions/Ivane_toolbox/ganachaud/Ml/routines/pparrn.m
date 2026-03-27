%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Script:       pparrn.m                         Date:2/13/96
% Author:       based on parr.m by A. Macdonald
% Purpose:      print out an array (matrix, vector ...) without
%               column headers
%               leave space for pressure column on the left
%               print variable name in that space
%               NO \n AT END OF LINE
% Inputs:       array   - the variable to be printed
%               width   - the minimum # of places to be printed
%                         values are right justified
%               dec     - number of decimal places
%               format  - format specification (d,o,x,u,c,s,e)
%                         see a c manual for further explanation
%               cols    - the number of columns to print
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%

function []=pparrn(array,width,dec,form,cols,name)
   if (issparse(array))
	array=full(array);
   end

   g = 'fprintf(''';
   g = [g,'%s',' '];
   for i=1:cols
      g = [g,'%',int2str(width),'.',int2str(dec),form,' '];
   end
   g = [g,'\n'',name,array);'];
   eval(g)
%   fprintf('\n');



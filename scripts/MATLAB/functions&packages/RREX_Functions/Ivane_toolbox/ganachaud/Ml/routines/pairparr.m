%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Script:       pairparr.m                         Date:12/1/95
% Author:       D. Spiegel (based on parr.m by A. Macdonald)
% Purpose:      print out an array (matrix, vector ...) without
%               column headers
%               include pressure along left
% Inputs:       array   - the variable to be printed
%               pres    - pressure (maybe blank)
%               width   - the minimum # of places to be printed
%                         values are right justified
%               dec     - number of decimal places
%               format  - format specification (d,o,x,u,c,s,e)
%                         see a c manual for further explanation
%               cols    - the number of columns to print
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%

function []=parr(pres,array,width,dec,form,cols)
   if (issparse(array))
	array=full(array);
   end

   g='fprintf('' %5d';
   for i=1:cols
      g = [g,'%',int2str(width),'.',int2str(dec),form,' '];
   end
   g = [g,'\n'',pres,array);'];
   eval(g)
   fprintf('\n');


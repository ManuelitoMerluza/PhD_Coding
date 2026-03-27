%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Script:       pparr.m (parr.m with pressure)       Date:2/13/96
% Author:       D. Spiegel
% Based on:     parr.m
% Author:       A. Macdonald
% Purpose:      print out an array (matrix, vector ...) without
%               column headers
%               print pressure along left side
%               NOTE: we expect array(col,row)
% Inputs:       array   - the variable to be printed
%               width   - the minimum # of places to be printed
%                         values are right justified
%               dec     - number of decimal places
%               format  - format specification (d,o,x,u,c,s,e)
%                         see a c manual for further explanation
%               cols    - the number of columns to print
%               pres    - pressure vector (must have same dim as array)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%

function []=pparr(array,width,dec,form,cols,pres)

   if (issparse(array))
	array=full(array);
   end

for j=1:size(pres)
   g = 'fprintf(''';
   g = [g,'%5.0f',' '', pres(j));'];
   eval(g)
   g = 'fprintf(''';
   for i=1:cols
      g = [g,'%',int2str(width),'.',int2str(dec),form,' '];
   end
   g = [g,'\n'', array(:,j));'];
   eval(g)
%   fprintf('\n');
end



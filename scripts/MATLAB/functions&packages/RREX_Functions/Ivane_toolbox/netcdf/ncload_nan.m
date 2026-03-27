function varargout = ncload_nan(theNetCDFFile, varargin)

% ncload_nan -- Load NetCDF variables.
% compatible with Denham toolbox that is used for matlab versions before
% 2008
%  ncload_nan(theNetCDFFile) loads all the variables of theNetCDFFile in
%    the workspace of the "caller" of this routine.
%    No attributes are loaded.
%  ncload_nan('theNetCDFFile', 'var1', 'var2', ...) loads only the given
%    variables of 'theNetCDFFile' 
%  [A,B,...] =  ncload_nan('theNetCDFFile','var1','var2',...) affects the 
%    data of 'var1' in A, 'var2' in B ...; the number of input and output
%    variables must match.
%  All fillvalues are converted to NaN.

%  same than ncload, except that variable names as seen in the workspace
%  can be specified in the output arguments. The output is no longer a cell
%  array "theResult": it is either empty or contain as many variables as
%  those specified after theNetCDFFile in the input arguments.
%

% modif:
%  Charles R. Denham, ZYDECO, Version of 18-Aug-1997 10:13:57
%  Pascale Lherminier, Version of 12-May-2009
 
if nargin < 1, help(mfilename), return, end
if nargout > 0 && nargout ~= nargin-1,
  error('number of input and output variables don''t match');
end

f = netcdf(theNetCDFFile, 'nowrite');
if isempty(f), return, end

if isempty(varargin), varargin = ncnames(var(f)); end

for i = 1:length(varargin)
   if ~isstr(varargin{i}), varargin{i} = inputname(i+1); end
   data = f{varargin{i}}(:);
   fval = fillval(f{varargin{i}})
   if length(fval)==1,
      data(data==fval) = NaN;
   end
   if nargout == 0,
      assignin('caller', varargin{i}, data);
   else
      varargout(i) = {data};
   end
end

close(f)



function varargout = ncload(filenc,varargin)
% ==================================================
%
%  ncload(theNetCDFFile) loads all the variables of theNetCDFFile in
%    the workspace of the "caller" of this routine.
%    No attributes are loaded.
%    Only 1-D or 2-D variables are correctly loaded.
%  ncload('theNetCDFFile', 'var1', 'var2', ...) loads only the given
%    variables of 'theNetCDFFile' 
%  [A,B,...] =  ncload('theNetCDFFile','var1','var2',...) affects the 
%    data of 'var1' in A, 'var2' in B ...; the number of input and output
%    variables must match.
%
% Fonction permettant de charger les variables de fa�on similaire a la
% fonction de C. Denham dans les anciennes versions de matlab.
% En entree : le nom du fichier NetCDF et �ventuellement le nom de la ou 
%             des variables a charger.
%
% Mai 2009 : P. Lherminier
%
% ================================================= 

if nargin < 1, warning('File name needed'); return; end
if nargout > 0 & nargout ~= nargin-1,
  error('number of input and output variables don''t match');
end

if ~strcmp(filenc(end-2:end),'.nc'),
    filenc = [filenc '.nc'];
end

if ~exist(filenc),
    disp([filenc ' does not exist, or does not have the necessary ".nc" extension.']);
    return
end

nc=netcdf.open(filenc,'NOWRITE');
if isempty(nc), 
  disp([filenc,' does not exist']);
  return
end

[numdims nvars]=netcdf.inq(nc); % Recuperation du nombre de variables du fichier

%if isempty(varargin), varargin = ncnames(var(f)); end

if ~isempty(varargin)
  for i_var = 1:length(varargin)
     % if the ' ' were forgotten in the input arguments, we add them
     if ~ischar(varargin{i_var}), varargin{i_var} = inputname(i_var+1); end;
     % to verify the existence of the variable in the nc file
     res_var = f_test_vars(filenc,varargin{i_var});
     if res_var == 1,
        varid = netcdf.inqVarID(nc,varargin{i_var});
        data = netcdf.getVar(nc,varid);
        if min(size(data))>1, data = data'; end;     %to match with the old toolbox
        if isnumeric(data), data = double(data); end;
     else
         data = [];
         disp([varargin{i_var} ' does not exist in ' filenc]);
     end
     if nargout == 0,
        assignin('caller', varargin{i_var}, data);
     else
        varargout(i_var) = {data};
     end
  end
else
  for i_var = 0:nvars-1,
    [varname, xtype, dimids, numatts] = netcdf.inqVar(nc,i_var);
    data = netcdf.getVar(nc,i_var);
     %if min(size(data))>1 & ndims(data)==2, data = data'; end;     %to match with the old toolbox
     if ndims(data) > 2 || min(size(data))>1, %means vectors are not permuted
        nd = ndims(data);
        data = permute(data,[nd:-1:1]);  %to match with the old toolbox
     end;    
     if isnumeric(data), data = double(data); end;
    assignin('caller', varname, data);
  end
end

result = data;

netcdf.close(nc)




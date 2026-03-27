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
if nargout > 0 && nargout ~= nargin-1,
  error('number of input and output variables don''t match');
end

if ~strcmp(filenc(end-2:end),'.nc'),
    filenc = [filenc '.nc'];
end

if ~exist(filenc,'file'),
    fprintf([filenc ' does not exist\n']);
    return
end

nc=netcdf.open(filenc,'NOWRITE');
if isempty(nc), 
  disp([filenc,' does not exist']);
  return
end

[~,nvars]=netcdf.inq(nc); % Recuperation du nombre de variables du fichier

%if isempty(varargin), varargin = ncnames(var(f)); end

if ~isempty(varargin)
  for i_var = 1:length(varargin)
     % if the ' ' were forgotten in the input arguments, we add them
     if ~ischar(varargin{i_var}), varargin{i_var} = inputname(i_var+1); end;
     % to verify the existence of the variable in the nc file
     res_var = test_vars(filenc,varargin{i_var});
     if res_var == 1,
        varid = netcdf.inqVarID(nc,varargin{i_var});
        varname = netcdf.inqVar(nc,varid);
        %disp(varname);
        data = netcdf.getVar(nc,varid);
        fillval=get_fillvalue(filenc,varargin{i_var});
        if ~isempty(fillval) && isnumeric(data), 
          data(data==fillval) = NaN;
        end
        if ~ismatrix(data) || min(size(data))>1, % vectors are not permuted
           nd = ndims(data);
           data = permute(data,(nd:-1:1));  %to match with the old toolbox
        end;    
        if isnumeric(data), data = double(data); end;
     else
         data = [];
         disp([varargin{i_var} ' does not exist in ' filenc]);
     end
     if nargout == 0,
        assignin('caller', varargin{i_var}, data);
     else
        varargout(i_var) = {data}; %#ok<*AGROW>
     end
  end
else
  for i_var = 0:nvars-1,
     varname = netcdf.inqVar(nc,i_var);
     data = netcdf.getVar(nc,i_var);
     fillval=get_fillvalue(filenc,varname);
     if ~isempty(fillval) && isnumeric(data), 
       data(data==fillval) = NaN;
     end
     if ~ismatrix(data) || min(size(data))>1, % vectors are not permuted
        nd = ndims(data);
        data = permute(data,nd:-1:1);  %to match with the old toolbox
     end;    
     if isnumeric(data), data = double(data); end;
     assignin('caller', varname, data);
  end
end

netcdf.close(nc)


function g_int_fillval = get_fillvalue(filenc,var)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% g_int_fillval = f_get_fillvalue(filenc,var)
%
% Fonction permettant de r�cup�rer la Fillvalue
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%     Le Bot Ph.    Avril 2009
%     P. Lherminier Mai 2009: ok si _FillValue n'existe pas

g_int_fillval = [];   
nc = netcdf.open(filenc,'NOWRITE');
varid = netcdf.inqVarID(nc,var);
[~,~,~,natts] = netcdf.inqVar(nc,varid);
for ii = 1:natts,
  attname = netcdf.inqAttName(nc,varid,ii-1);
  if strcmp(attname,'_FillValue'),
    g_int_fillval = netcdf.getAtt(nc,varid,'_FillValue');
  end
end
netcdf.close(nc);

function res_var = test_vars(filenc,varname_encours)
% ==================================================
%
% Fonction permettant de verifier l'existance
% d'une variable dans un fichier Netcdf.
% En entree : le nom du fichier NetCDF et le nom de la variable a rechercher.
% En sortie : Un indicateur valant 1 si la variable existe dans le fichier, rendant 0 sinon.
%
% Avril 2009 : P. Le Bot.
%
% ================================================= 

nc=netcdf.open(filenc,'NOWRITE');
[~,nvars]=netcdf.inq(nc); % Recuperation du nombre de variables du fichier
i_var = 1;
trouve = 0;
while (i_var<=nvars && trouve==0) % Boucle sur toutes les variables
       varname = netcdf.inqVar(nc,i_var-1);
         if strcmp(varname,varname_encours)==1 % Comparaison entre la variable en cours et celle recherchee.
                 trouve = 1;
         else
                i_var = i_var + 1;
         end
end
if (trouve==0)
           res_var=0;
else
           res_var=1;
end 
netcdf.close(nc);


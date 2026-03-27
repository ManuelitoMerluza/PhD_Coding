function val = ncautonan(filenc, var, varargin)
% val = ncautonan(filenc, var, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% val = ncautonan(filenc, var)
%     Fonction similaire a autonan:
%     charge la variable var du fichier filenc
%     remplace les Fillvalues par NaN
% val = ncautonan(filenc, var, ii, jj, ...)
%     ne charge que la sous-matrice var(ii,jj,...)
%     avec ii,jj ... indices consecutifs de type m:n
%     
%
% En entree : nom du fichier à lire
%             variable à lire
%             index (option)
% En sortie : valeur de la variable 
% utiliser de preference ncload_nan si on ne prend pas de sous-matrice
%
% Mai 2009 : P. Lherminier
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
A = ver;
Mat_version = A(1).Version; 
iv = findstr(Mat_version,'.'); 
Mat_version = str2num(Mat_version(iv+1:end));
if Mat_version < 7
  global nctbx_options;
  nctbx_options.theAutoNaN = 1;
  nc = netcdf([ncrep 'bathy_etopo2.nc'],'read');
  bathy=nc{var}(varargin{:});
else
  i1 = []; l1 = [];
  for ii=1:nargin-2,
    i1(ii)=varargin{ii}(1);
    l1(ii)=varargin{ii}(end)-i1(ii)+1;
  end
  nc = netcdf.open(filenc,'NC_NOWRITE');
  varid = netcdf.inqVarID(nc,var);
  if ~isempty(i1),
    val = netcdf.getVar(nc,varid,i1,l1,'double');
  else
    val = netcdf.getVar(nc,varid,'double');
  end
  fval = f_get_fillvalue(filenc,var);
  if ~isempty(fval)
    val(val==netcdf.getAtt(nc,varid,'_FillValue'))=NaN;
  end
  netcdf.close(nc);
end

    
    
    

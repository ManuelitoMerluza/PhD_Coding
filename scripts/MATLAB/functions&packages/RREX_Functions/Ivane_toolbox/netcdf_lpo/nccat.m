function nccat(filenc1,filenc2,filencres)
% ==================================================
%
%  nccat(theNetCDFFile1,theNetCDFFile2,theNetCDFFileRes)  
%    append all the variables of theNetCDFFile2 to those
%    of theNetCDFFile1 if they have the same name, along the
%    TIME dimension, and put the results in theNetCDFFileRes. 
%    Attributes are also copied.
%    When they are different in both files, a choice is given.
%
% Mai 20010 : P. Lherminier
%
% ================================================= 

if nargin < 3, warning('3 File names needed'); return; end

nc1=netcdf.open(filenc1,'NC_NOWRITE');
if isempty(nc1), return, end
nc2=netcdf.open(filenc2,'NC_NOWRITE');
if isempty(nc2), return, end
%ncr=netcdf.open(filencres,'NC_WRITE');
%netcdf.reDef(ncr);

% info from input files
[ndims1,nvars1,ngatts1,unlimdimid1]=netcdf.inq(nc1); 
[ndims2,nvars2,ngatts2,unlimdimid2]=netcdf.inq(nc2);

% dimensions in res file
for i_dim = 0:ndims1-1,
  [dimname1, dimlen1] = netcdf.inqDim(nc1,i_dim);
  [dimname2, dimlen2] = netcdf.inqDim(nc2,i_dim);
  fprintf(['Dimension %i: ' dimname1 '\n'],i_dim);
  if ~strcmp(dimname1,dimname1),
    error('The files don''t have the same dimension names');
  end
  if ~isempty(findstr(dimname1,'TIME')),
    dimlen = dimlen1 + dimlen2;
  else
    dimlen = dimlen1;
  end
  %dimid = netcdf.defDim(ncr,dimname1,dimlen)
end
  
% global attributes in res file
ngatts = min(ngatts1,ngatts2);
for i_att = 1:ngatts-1,
  gattname1 = netcdf.inqattname(nc1,netcdf.getConstant('NC_GLOBAL'),i_att);
  gattname2 = netcdf.inqattname(nc2,netcdf.getConstant('NC_GLOBAL'),i_att);
  if strcmp(gattname1,gattname2),
    disp(gattname1);
    gattval1 = netcdf.getAtt(nc1,netcdf.getConstant('NC_GLOBAL'),gattname1);
    gattval2 = netcdf.getAtt(nc2,netcdf.getConstant('NC_GLOBAL'),gattname2);
    if strcmp(num2str(gattval1),num2str(gattval2)),
      % netcdf.putAtt(ncr,netcdf.getConstant('NC_GLOBAL'),gattname1,gattval1);
      disp(gattval1);
      disp('ok');
    else
      disp(gattval1);
      disp(gattval2);
      if strcmp(gattname1,'DATE_UPDATE');
        user_entry = datestr(now,1);
      else
        user_entry = input('Attributes have different values. Type the one you choose:');
      end
      disp(user_entry);
      % netcdf.putAtt(ncr,netcdf.getConstant('NC_GLOBAL'),gattname1,user_entry);
    end
  else
    disp('Attribute names are different:');
    disp([gattname1,'    ',gattname2]);
  end
end
disp([ngatts1,ngatts2])
if ngatts1>=ngatts2, xgatts = ngatts1; nc = nc1; ifile = 1;
else                xgatts = ngatts2; nc = nc2; ifile = 2;
end
for i_att = ngatts:xgatts-1,
  gattname = netcdf.inqattname(nc,netcdf.getConstant('NC_GLOBAL'),i_att);
  gattval = netcdf.getAtt(nc,netcdf.getConstant('NC_GLOBAL'),gattname);
  fprintf([gattname ' only exists in file %i with the value ' num2str(gattval) '\n'],ifile);
  user_entry = input('Do you want its value to be copied in the new file? (y/n)','s');
  if strcmp(user_entry,'y') | isempty(user_entry),
    user_entry = input('Type a new value (0 = no attribute, [] means same value):');
    if ~strcmp(num2str(user_entry),'0'),
       if ~isempty(user_entry),
         gattval = user_entry;
       end
      % netcdf.putAtt(ncr,netcdf.getConstant('NC_GLOBAL'),gattname,gattval);
       disp(['Attribute ' gattname ' with the value ' num2str(gattval) ' added.']);
    end
  end
  disp(' ');
end

%   netcdf.copyAtt(nc1,varid_in,attname,ncr,varid_out)

%if isempty(varargin), varargin = ncnames(var(f)); end

%for i_var = 0:nvars-1,
%    [varname, xtype, dimids, numatts] = netcdf.inqVar(nc,i_var);
%    data = netcdf.getVar(nc,i_var);
%     if min(size(data))>1, data = data'; end;     %to match with the old toolbox
%     if isnumeric(data), data = double(data); end;
%    assignin('caller', varname, data);
%end

%result = data;

netcdf.close(nc1)
netcdf.close(nc2)




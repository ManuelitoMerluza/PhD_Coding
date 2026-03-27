function A = ffread(fid, esize, precision)
% read binary data from fortran binary sequecial format
%synopsis : A = ffread(fid, esize, 'precision')
 
 % fid:file identification
 % size: number of elements actually written
 %   if size=inf, one record is read, as a vector
 % 'precision' = datatype(see below)
 % A:array to be read

%description : 
 
 % read the f77 binary sequencial format, verify homogeneity

%uses : killblank.m

% side effects : 
	% signed/unsigned datatype not used;
	% do not read different types on the same line

% author : A.Ganachaud, Mar 95

%see also : ffwrite, ffread_check(.m/.f)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% find the number of bytes required by the table
% X means that the Fortran equivalent is not definite

   tbl_prec=str2mat(... 			% FORTRAN TYPE
	'char','Xschar','Xuchar',...		% character
	'short','Xushort',...			% integer*2
	'int','Xuint',...			% integer (*4)
	'long','Xulong'...			% integer (*4)
	);
   tbl_prec=str2mat(tbl_prec,...
	'float','float32',...			% real (*4)
	'double','float64'...			% real*8, double precision
	);

   i=1;
   while i <= length(tbl_prec)
	if strcmp(precision,killblank(tbl_prec(i,:))) 
	   break
	end
	i=i+1;
   end
   if i == length(tbl_prec)+1
	error('bad precision argument, have a look in ffwrite.m')
   end
   nbyte = [ 1 1 1 2 2 4 4 4 4 4 4 8 8 ]; % to verify for the sun

% read file with fortran format
   nbytes=fread(fid, 1, 'long');
   if any(isinf(esize)) esize=nbytes./nbyte(i); end

   A=fread(fid, esize, precision);
   if fread(fid, 1, 'long')~=nbytes
	error('bad format file input');
   end

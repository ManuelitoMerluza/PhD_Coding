function count = ffwrite(fid, A, precision)
% write binary dat in fortran binary sequecial format
%synopsis : count = ffwrite(fid, A, 'precision')
 
 % fid:file identification
 % A:array to be written
 % 'precision' = datatype(see below)
 % count: number of elements actually written

%description : 
 
 % determines the number of bytes required by the wanted precision
 % write it in a long integer, at the beginning and at the end
 % of the array, as required by the f77 format

%uses : killblank.m

% side effects : signed/unsigned datatype not used

% author : A.Ganachaud, Mar 95

%see also : ffread, ffwrite_check(.m/.f)

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

% writes file with fortran format
   fwrite(fid, prod(size(A))*nbyte(i), 'long');
   count=fwrite(fid, A, precision);
   fwrite(fid, prod(size(A))*nbyte(i), 'long');

   a=['always'];
   b=['looking sky'];
   ii=[ -1 2 3 4 5 6 8 7];
   jj=[ -1 2 -3 4 -5 6 32768 -32769];
   kk=[ -1 2 -3 4 -5 6 -7 2147483647 -2147483648 ];
   x=[ 1 2 3 4 5 6 7 8 9 ];
   y=[ 9 8 7 6 5 4 3 2 1 ];
   clear

   fid=fopen('temp.bin','r');
   disp(setstr(ffread(fid,inf,'char'))')
   disp(setstr(ffread(fid,11,'char'))')
   disp(ffread(fid,inf,'short'))
   disp(ffread(fid,inf,'int'))
   disp(ffread(fid,inf,'long'))
   disp(ffread(fid,inf,'float'))
   disp(ffread(fid,[2,9],'double'))
   fclose(fid);

   a=['always'];
   b=['looking sky'];
   ii=[ -1 2 3 4 5 6 8 7];
   jj=[ -1 2 -3 4 -5 6 32768 -32769];
   kk=[ -1 2 -3 4 -5 6 -7 2147483647 -2147483648 ];
   x=[ 1 2 3 4 5 6 7 8 9 ];
   y=[ 9 8 7 6 5 4 3 2 1;...
	-9 -8 -7 -6 -5 -4 -3 -2 -1 ];
   fid=fopen('temp.bin','w');
    ffwrite(fid,a,'char');
    ffwrite(fid,b,'char');
    ffwrite(fid,ii,'short');
    ffwrite(fid,jj,'int');
    ffwrite(fid,kk,'long');
    ffwrite(fid,x,'float');
    ffwrite(fid,y,'double');
   fclose(fid);

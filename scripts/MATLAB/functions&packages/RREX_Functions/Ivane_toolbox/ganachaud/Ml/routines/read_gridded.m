function [lon,lat,gdata]=read_gridded(fname,nskip)
% KEY: read Detlef's gridded data format
% USAGE : [lon,lat,gdata]=read_gridded(fname,nskip)
% 
%
%
%
% DESCRIPTION : 
%
%
% INPUT: fname: file name / file id if not string
%        nskip: number of skip before reading the data
%
% OUTPUT:
%
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , Jan 98
%
% SIDE EFFECTS :
%
% SEE ALSO :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER:
% CALLEE:

if isstr(fname)
  fid=fopen(fname,'r');
else
  fid=fname;
end
if fid==-1
  disp(fname)
  error('not found')
end

irec=1;
while irec<=(nskip+1)
  irec=irec+1;
  [nd,ct]=fread(fid,1,'int32');
  if ~ct 
    error('end of file reached !')
  end
  nlon=fread(fid,1,'int32');
  nlat=fread(fid,1,'int32');
  latmin=fread(fid,1,'float');
  latmax=fread(fid,1,'float');
  lonmin=fread(fid,1,'float');
  lonmax=fread(fid,1,'float');
  nd1=fread(fid,1,'int32');
  if nd~=nd1
    error('problem reading the header !')
  end
  nd=fread(fid,1,'int32');
  if nd ~= 4*nlon*nlat
    error('problem reading the data ! (beginning)')
  end
  gdata=fread(fid,[nlon,nlat],'float');
  nd1=fread(fid,1,'int32');
  if nd1 ~= 4*nlon*nlat
    error('problem reading the data ! (end)')
  end
end %for irec
gisnogood=find(gdata==-9999 | gdata==-999 );
gdata(gisnogood)=NaN;

if isstr(fname)
  fclose(fid);
end

dlat=(latmax-latmin)/(nlat-1);
dlon=(lonmax-lonmin)/(nlon-1);
lat=(latmin:dlat:latmax)';
lon=(lonmin:dlon:lonmax)';

function [iship,icast,xlat,xlon,botp,kt,xdep,nobs,maxd]=...
  read_stathdr(hdrfile,nstat)
% KEY: read the station header file
% USAGE :
% 
%
%
%
% DESCRIPTION : read the direct access station header file
%  created in mergech.f
%
% INPUT:
%
% OUTPUT:
%   (is) is the station (or cast) number 
%   iship(is): (?) ship ID
%   icast(is): (?) cast ID
%   xlat(is),xlon(is): position
%   botp(is): bottom pressure (db)
%   kt(is): (?) some record number
%   xdep(is): last station depth
%   nobs(is): number of observations
%   maxd(is): last depth indice
%
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , Jul 96
%
% SIDE EFFECTS :
%
% SEE ALSO :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER: general purpose
% CALLEE:

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%READING HEADER FILE
disp(['READING ' hdrfile '...'])

[fid,message]=fopen(hdrfile,'r');
if fid==-1
  error(message)
end
iship=fread(fid,[nstat,1],'long');
icast=fread(fid,[nstat,1],'long');
xlat=fread(fid,[nstat,1],'float32');
xlon=fread(fid,[nstat,1],'float32');
botp=fread(fid,[nstat,1],'float32');
kt=fread(fid,[nstat,1],'long');
xdep=fread(fid,[nstat,1],'float32');
nobs=fread(fid,[nstat,1],'long'); %UNKNOWN
maxd=fread(fid,[nstat,1],'long');

status=fseek(fid,1,'cof');
if status~=-1
  error('SOME MORE DATA ARE TO BE READ')
end
fclose(fid);


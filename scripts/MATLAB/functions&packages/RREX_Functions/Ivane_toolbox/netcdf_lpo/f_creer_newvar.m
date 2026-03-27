function f_creer_newvar(filenc,namevar,type,dimvar,varargin)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Fonction permettant de creer une nouvelle 
%   Variable dans un fichier netcdf
%      C. Kermabon - P Le Bot Avril 2009
%
%   filenc= nom du fichier
%   namevar= nom de la variable
%   type = Type de la variable
%   dimvar= nom des dimensions. ex: strvcat('a','b')
%   varargin= nom et valeur des attributs. ex: 'long_name','Vitessse en ms'
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nc=netcdf.open(filenc,'WRITE');

netcdf.reDef(nc);
for idim=1:size(dimvar,1)
 dimid(idim)= netcdf.inqDimID(nc,deblank(dimvar(idim,:)));
end
id_var=netcdf.defVar(nc,namevar,type,dimid);
for iatt=1:2:size(varargin,2)
 netcdf.putAtt(nc,id_var,varargin{iatt},varargin{iatt+1});
end
netcdf.endDef(nc);
netcdf.close(nc);

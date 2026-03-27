function gesw(fid)
if nargin==0
  fid=gcf;
end

cccc=g(fid,'Toolbar');
if strcmp(fid,'figure')
  set(fid,'Toolbar','none')
else
  set(fid,'Toolbar','figure')
end
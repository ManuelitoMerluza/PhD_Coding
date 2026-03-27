function lay2sum=readlay2sum(lay2sumfile,propnm)
% KEY: read the file lay2sum.dat that gives the layers over which 2 sum
% the residuals
% USAGE :
% 
%
%
%
% DESCRIPTION : 
%
%
% INPUT: 
%
%
% OUTPUT:
%
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , Apr99
%
% SIDE EFFECTS :
%
% SEE ALSO :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER:
% CALLEE:
fid=fopen(lay2sumfile,'r');
ibox=0;

curline=fgetl(fid);
while curline~=-1
  if ~strcmp(curline(1:3),'box')
    error('box name not found')
  elseif length(curline)>4 & ~isempty(sscanf(curline(5:length(curline)),'%s'))
    ibox=ibox+1;
    lay2sum{ibox}.boxname=sscanf(curline(5:length(curline)),'%s');
    curline=fgetl(fid);
    while ~strcmp('-',curline(1)) & curline ~= -1
      for iprop=1:length(propnm)
	if findstr(lower(propnm{iprop}),lower(curline))
	  break;
	elseif iprop==length(propnm)
	  error([curline ' property not found'])
	end
      end %for iprop
      if length(curline)>length(propnm{iprop}) & ~isempty(findstr(curline,'z'))
	gstart=findstr(curline,'z');
	for ig=1:length(gstart)
	  if ig==length(gstart)
	    nmax=length(curline);
	  else
	    nmax=gstart(ig+1)-1;
	  end
	  gill=sscanf(curline(gstart(ig)+1:nmax),'%i',2);
	  lay2sum{ibox}.lay2sum{iprop,ig}=(gill(1):gill(2))';
	end %for ig
      else
	lay2sum{ibox}.lay2sum{iprop}=[];
     end %if length(curline)>
      curline=fgetl(fid);
    end %while ~strcmp('-'
    curline=fgetl(fid);
  else %empty box name: skip
    curline=fgetl(fid);
    while length(curline)<=3 | (~strcmp(curline(1:3),'box') &  curline~=-1)
      curline=fgetl(fid);
    end
  end %if ~strcmp(curline(1:3),'box')
end %while curline ~= -1  
  
fclose(fid);
  

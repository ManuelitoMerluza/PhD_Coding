function cddates=findate(ybeg,mbeg,dbeg,yend,mend,dend,clpath,clconfig,clvar)
% KEY: find files between two dates [ date ]
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
% AUTHOR : A.Ganachaud (ganacho@ifremer.fr) , Sept 00/ from S. Michel's 
% routine.
%
% SIDE EFFECTS :
%
% SEE ALSO :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER:
% CALLEE:
it=0;
disp('')
disp('FOUND FILES :')
for iy=ybeg:yend
  if iy==ybeg
    im1=mbeg;
  else
    im1=1;
  end
  if iy==yend
    im2=mend;
  else
    im2=12;
  end
  for im=im1:im2
    if (im==mbeg) & (iy==ybeg)
      id1=dbeg;
    else
      id1=1;
    end
    if (im==mend) & (iy==yend)
      id2=dend;
    else
      id2=31;
    end   
    for id=id1:id2
      cddate=sprintf('y%02im%02id%02i',iy,im,id);
      fname=[clpath '/' clconfig '_' clvar '_' cddate '.dimg'];
      if exist(fname)==2
	disp(fname)
	it=it+1;
	cddates{it}=cddate;
      end
    end % for id=id1:id2
  end % for im=im1:im2
end % for iy=ybeg:yend

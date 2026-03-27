function [ovwrite]=diarystart(drynm,ovwd)
% KEY: starts a diary, check if already exist
% USAGE : [ovwrite]=diarystart(drynm,ovwd)
%    
%    Erase previous diary if ovwd exists and is 1 
%    ovwrite = if the diary existed
%       0 : diary not created
%       1 : previous diary erased and new diary started
%       2 : diary opened in old diary
%       3 : diary opened, no previous diary
%
% DESCRIPTION : 
%
%
% INPUT: drynm the name of the diary
%
% OUTPUT: <drynm>.dry , starting with the date
%
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , Nov 95
%
% SIDE EFFECTS :
%
% SEE ALSO :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER: general purpose
% CALLEE: menu
if ~exist('ovwd')
  ovwd=0;
end

drynm=[deblank(drynm) '.dry'];
ov=1;
if exist(drynm)==2
  if 1
    reask=1;
    disp(' ')
    disp([drynm ' ALREADY EXISTS'])
    while reask
      reask=0;
      if exist('ovwd')
	rep='o';
      else
	rep=input(...
	  '(o)verwrite (a)ppend (n)o diary : ','s');
      end
      if rep=='o'
	unix(['rm ' drynm ]);
	eval(['diary ' drynm])
	ov=1;
	
      elseif rep=='a'
	eval(['diary ' drynm])
	ov=2;
      elseif rep=='n'
	ov=0;
      else
	reask=1;
      end
    end
  else
    im=menu([drynm ' already exist'],'OVERWRITE','APPEND','NO DIARY');
    if im==1
      unix(['rm ' drynm ]);
      eval(['diary ' drynm])
      ov=1;
      
    elseif im==2
      eval(['diary ' drynm])
      ov=2;
      
    else
      ov=0;
    end
  end
else
  eval(['diary ' drynm])
  ov=3;
  
end

if ov ~=0
  disp(['Diary opened on ' date])
end

if nargout~=0
  ovwrite=ov;
end


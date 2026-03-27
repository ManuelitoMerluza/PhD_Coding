function covsec=cov_section(gsecs)
% KEY: return a sparse matrix with 1 if covariance between sections should
% be kept
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
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , Feb99
%
% SIDE EFFECTS :
%
% SEE ALSO :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER:
% CALLEE:
covsec=sparse(eye(length(gsecs.name)));
for isec=1:length(gsecs.name)
  secname=gsecs.name{isec};
  for isec2=1:length(gsecs.name)
    putcov=0;
    switch gsecs.name{isec}
    case 'A2'
      if strcmp(gsecs.name{isec2},'a36n')
	putcov=1;
      end
      if strcmp(gsecs.name{isec2},'A5')
	putcov=1;
      end
    case 'a36n'
      if strcmp(gsecs.name{isec2},'A5')
	putcov=1;
      end
    case 'A5'
      if strcmp(gsecs.name{isec2},'A6')
	putcov=1;
      end
      if strcmp(gsecs.name{isec2},'A9')
	putcov=1;
      end
    case 'A6'
      if strcmp(gsecs.name{isec2},'A7')
	putcov=1;
      end
    case 'A7'
      if strcmp(gsecs.name{isec2},'A8')
	putcov=1;
      end
    case 'A8'
      if strcmp(gsecs.name{isec2},'A9')
	putcov=1;
      end
    case 'A9'
      if strcmp(gsecs.name{isec2},'A10')
	putcov=1;
      end
    case 'A10'
      if strcmp(gsecs.name{isec2},'A11')
	putcov=1;
      end
    case 'A11'
      if strcmp(gsecs.name{isec2},'A12')
	putcov=1;
      end
      if strcmp(gsecs.name{isec2},'A21')
	putcov=1;
      end
    case 'A12'
      if strcmp(gsecs.name{isec2},'I6')
	putcov=1;
      end
      if strcmp(gsecs.name{isec2},'I5')
	putcov=1;
      end
      if strcmp(gsecs.name{isec2},'I9')
	putcov=1;
      end
      if strcmp(gsecs.name{isec2},'A21')
	putcov=1;
      end
    case 'I6'
      if strcmp(gsecs.name{isec2},'I5')
	putcov=1;
      end
      if strcmp(gsecs.name{isec2},'I9')
	putcov=1;
      end
    case 'I5'
      if strcmp(gsecs.name{isec2},'I3')
	putcov=1;
      end
      if strcmp(gsecs.name{isec2},'I4')
	putcov=1;
      end
      if strcmp(gsecs.name{isec2},'J8992')
	putcov=1;
      end
    case 'I4'
      if strcmp(gsecs.name{isec2},'I3')
	putcov=1;
      end
      if strcmp(gsecs.name{isec2},'I2W')
	putcov=1;
      end
    case 'I3'
      if strcmp(gsecs.name{isec2},'I2')
	putcov=1;
      end
      if strcmp(gsecs.name{isec2},'I10')
	putcov=1;
      end
    case 'I2W'
      if strcmp(gsecs.name{isec2},'I2')
	putcov=1;
      end
      if strcmp(gsecs.name{isec2},'I10')
	putcov=1;
      end
      if strcmp(gsecs.name{isec2},'J8992')
	putcov=1;
      end
    case 'I2'
      if strcmp(gsecs.name{isec2},'I10')
	putcov=1;
      end
      if strcmp(gsecs.name{isec2},'J8992')
	putcov=1;
      end
    case 'I10'
      if strcmp(gsecs.name{isec2},'J8992')
	putcov=1;
      end
    case 'J8992'
      if strcmp(gsecs.name{isec2},'P21W')
	putcov=1;
      end
      if strcmp(gsecs.name{isec2},'P21')
	putcov=1;
      end
      if strcmp(gsecs.name{isec2},'P4')
	putcov=1;
      end
      if strcmp(gsecs.name{isec2},'P3')
	putcov=1;
      end
    case 'I9'
      if strcmp(gsecs.name{isec2},'P12')
	putcov=1;
      end
    case 'P12'
      if strcmp(gsecs.name{isec2},'P14S')
	putcov=1;
      end
      if strcmp(gsecs.name{isec2},'P6')
	putcov=1;
      end
      if strcmp(gsecs.name{isec2},'A21')
	putcov=1;
      end
    case 'P6'
      if strcmp(gsecs.name{isec2},'A21')
	putcov=1;
      end
      if strcmp(gsecs.name{isec2},'P21W')
	putcov=1;
      end
      if strcmp(gsecs.name{isec2},'P21')
	putcov=1;
      end
    case 'P21W'
      if strcmp(gsecs.name{isec2},'P21')
	putcov=1;
      end
      if strcmp(gsecs.name{isec2},'P4')
	putcov=1;
      end
      if strcmp(gsecs.name{isec2},'P3')
	putcov=1;
      end
      if strcmp(gsecs.name{isec2},'J8992')
	putcov=1;
      end
    case 'P21'
      if strcmp(gsecs.name{isec2},'P4')
	putcov=1;
      end
      if strcmp(gsecs.name{isec2},'P3')
	putcov=1;
      end
      if strcmp(gsecs.name{isec2},'J8992')
	putcov=1;
      end
    case 'P4'
      if strcmp(gsecs.name{isec2},'P3')
	putcov=1;
      end
    case 'P3'
      if strcmp(gsecs.name{isec2},'P1')
	putcov=1;
      end
    end
    if putcov
      covsec(isec,isec2)=1;
      covsec(isec2,isec)=1;
    end
  end
end

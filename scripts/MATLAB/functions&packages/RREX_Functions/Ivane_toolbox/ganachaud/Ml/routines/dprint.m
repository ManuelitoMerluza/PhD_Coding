function dprint(figids,opts,twosided)
% KEY: print a series of figures, with double sided paper option
% USAGE : dprint(figids,opts,twosided)
%   figids =  figure handle (1, 2, ...)
%   opts = print options (default= -P$PRINTER)
%   twosided = print double-sided (if available on the printer)
%              (default=0)
%
% EXAMPLES : 
%   dprint(1:gcf,'',1): print all figures from 1 to the current
%                       figure on double sided paper
%   dprint([2,5]): print figures 2 and 5 on hp15, single-sided
%
% INPUT: 
%
%
% OUTPUT:
%
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , Sept98
%
% SIDE EFFECTS : creates temporary files /var2/Dprintspool/tmpfigX.ps and /var/tmp/allfig.ps
%
% SEE ALSO : print
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER:
% CALLEE:
figids=figids(:)';
if nargin<2
  opts=['-P' getenv('PRINTER')];
end
if nargin<3
  twosided=0;;
end
if ~findstr(opts,'-P')
  opts=['lpr -P' getenv('PRINTER') opts ' '];
else
  opts=['lpr ' opts ' '];
end
figstr=[];
for ifig=figids
  if ~isempty([findstr(opts,'cl') findstr(opts,'phaser') findstr(opts,'hp840c')])
    print(ifig,'-depsc',sprintf('/var2/Dprintspool/tmpfig%i.ps',ifig));
  else
    print(ifig,'-deps',sprintf('/var2/Dprintspool/tmpfig%i.ps',ifig));
  end
  figstr=[figstr, sprintf(' /var2/Dprintspool/tmpfig%i.ps',ifig)];
end

if twosided
  unix(sprintf('mv /var2/Dprintspool/tmpfig%i.ps /var2/Dprintspool/allfig.ps',figids(1)));
  if length(figids)>1
    for ifig=figids(2):figids(length(figids))
      [ss,dd]=unix(sprintf(...
	'cat /var2/Dprintspool/tmpfig%i.ps >> /var2/Dprintspool/allfig.ps',ifig));
      if ~ss
	error(dd)
      end
    end
  end
  [ss,dd]=unix([opts ' /var2/Dprintspool/allfig.ps '...
      ' && \rm /var2/Dprintspool/tmpfig*.ps /var2/Dprintspool/allfig.ps']);
  if ~ss
    error(dd)
  end
else
  [ss,dd]=unix([opts figstr ' && \rm /var2/Dprintspool/tmpfig*.ps']);
  if ss
    error(dd)
  end
end  

function [b,p,u] = woce_bots(a1,a2,a3,a4,a5,a6,a7,a8,a9);
%function [bot,props,units] = woce_bots(fname1,fname2,...., fname9)
%
% loads multiple woce *.HY2 and *.SEA files
% merges data using column property titles and units.  If some files have
% extra properties or units don't match then the additional data is appended
% as an additional columns.   Files missing properties have appropriate
% columns padded with nan's
% 
% Currently set to disregard data flagged as 'bad' or 'questionable'
% 
% Paul E Robbins, copywrite 1995

%  needs to call woce_bot.m

[b,p,u] = woce_bot(a1);

b = [ones(size(b,1),1) b];
p = str2mat('CRSNUM',p);
u = str2mat('  ',u);

for n = 2:nargin
  bo = b; po = p; uo = u;  
  eval(['fname = a',num2str(n),';'])
  [bn,pn,un] = woce_bot(fname);
  bn = [n*ones(size(bn,1),1) bn];  
  pn = str2mat('CRSNUM',pn);   un = str2mat('  ',un);
  % 
  % create new block of data sized for both sets but with nan's for new set
  b = [bo; n*ones(size(bn,1),1)  nan*ones(size(bn,1),size(bo,2)-1)];
  %go through all the variables and check to get properties to line up and
  % to  see if units are same
  
  %keyboard
  matched = 0*ones(1,size(pn,1));matched(1) =1;
  for i = 2:size(po,1);

    for j = 1:size(pn,1)
      if strcmp(po(i,:),pn(j,:))
	%if a match is found then add in appropriate column
	if strcmp(uo(i,:),un(j,:))
	  matched(j) = 1; 	  
	  b(b(:,1)==n,i) = bn(:,j);
	  break;
	else
	 disp(['Units mismatch: ',pn(j,:),' has units ',un(j,:),' in file ',...
		 fname,' previous files had units ',uo(i,:)])
        end
      end
    end
  end
  if any(matched==0)
    for j = find(matched == 0)
    %if no match is found append a column to end
      b = [b nan*ones(size(b,1),1)];
      b(b(:,1)==n,size(b,2)) = bn(:,j);
      p = str2mat(p,pn(j,:));
      u = str2mat(u,un(j,:));   
    end
  end
end






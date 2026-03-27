%scrippt get_watermass 
% KEY: get the water mass transport with uncertainty eats/west of a ridge
% and total. See run_global.m. Need to have in memory bhat and Amat
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
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , April 98
%
% SIDE EFFECTS :
%
% SEE ALSO :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER:
% CALLEE:
    disp(['Layer transports section ' gsecs.name{isa}])
    disp([(1:Nlay)' Ta{isa}(:,1)])
    gilnadw=input(['NADW LAYERS ?']);
    gilaabw=input(['AABW LAYERS ?']);
    girow=pm.ibfrow(boxsec(isa))-1+[(iprop-1)*Nlay+1:iprop*Nlay];
    gicol=pm.gifcol(isa):pm.gilcol(isa);
    tekk=gsecs.Ekt(:,gisb(isa),iprop);
    inboxdirr=gsecs.inboxdir(gisb(isa));
    %Separation EAST/WEST
    imid=0;
    switch gsecs.name{isa}
      case 'a36n'
         imid=58
      case {'A5','A5+'}
         imid=52;
      case 'a24n_flst'
         imid=[];
	 break
      case 'A6'
         imid=41;
      case 'A7'
         imid=44;
      case 'A8'
         imid=51;
      case 'A9'
         imid=49;
      case 'A10'
         imid=66;
      case 'A11'
         imid=57;
      case {'P1','P6','I5'}
         imid=NaN;
      otherwise 
        disp('midpoint unknown'); stop
    end
    for iside=1:3
      if iside==1 & ~isnan(imid)
	gicols=gicol(1:imid-1);
      elseif iside==2 & ~isnan(imid)
	gicols=gicol(imid:gsecs.npair(isa));
      else
	gicols=gicol;
      end    
      a=ones(1,length(gilnadw));
      TrNADW{iside}=a*(sum(Gunsgn(girow(gilnadw),gicols),2)+tekk(gilnadw));
      TaNADW{iside}=TrNADW{iside}...
	-a*inboxdirr*Amat(girow(gilnadw),gicols)*bhat(gicols);
      dTaNADW{iside}=full(sqrt(a*Amat(girow(gilnadw),gicols)*...
	P(gicols,gicols)*Amat(girow(gilnadw),gicols)'*a'));
      
      a=ones(1,length(gilaabw));
      TrAABW{iside}=a*(sum(Gunsgn(girow(gilaabw),gicols),2)+tekk(gilaabw));
      TaAABW{iside}=TrAABW{iside}...
	-a*inboxdirr*Amat(girow(gilaabw),gicols)*bhat(gicols);
      dTaAABW{iside}=full(sqrt(a*Amat(girow(gilaabw),gicols)*...
	P(gicols,gicols)*Amat(girow(gilaabw),gicols)'*a'));
      
      
    end %iside
    disp('NADW')
    disp(sprintf(['WEST                          '...
        '\tEAST                          '...
	'\tTOTAL                         ']))
    disp(sprintf(['Ta=%3.1f +/- %3.1f (Tr=%3.1f) ' ...
	'\tTa=%3.1f +/- %3.1f (Tr=%3.1f) '...
	'\tTa=%3.1f +/- %3.1f (Tr=%3.1f)'],TaNADW{1},dTaNADW{1},TrNADW{1},...
      TaNADW{2},dTaNADW{2},TrNADW{2},TaNADW{3},dTaNADW{3},TrNADW{3}))

    disp('AABW')
    disp(sprintf(['WEST                          '...
        '\tEAST                          '...
	'\tTOTAL                         ']))
    disp(sprintf(['Ta=%3.1f +/- %3.1f (Tr=%3.1f) ' ...
	'\tTa=%3.1f +/- %3.1f (Tr=%3.1f) '...
	'\tTa=%3.1f +/- %3.1f (Tr=%3.1f)'],TaAABW{1},dTaAABW{1},TrAABW{1},...
      TaAABW{2},dTaAABW{2},TrAABW{2},TaAABW{3},dTaAABW{3},TrAABW{3}))
    ppause
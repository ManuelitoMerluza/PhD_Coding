%function weldequats
% KEY: assemble different equations with common sections
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
% OUTPUT:
%
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , Aug 97
%
% SIDE EFFECTS :
%
% SEE ALSO : mkequats
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER:
% CALLEE:
if 0
  clear
  Modelid= 'NewNatl';
  IPdir{1}='/data1/ganacho/Boxmod/Natl/';
  boxname{1}='natl_XVII';
  modelid{1}='New';
  %IPdir{2}='/data1/ganacho/Boxmod/Natl/';
  %boxname{2}='natl_XVIII';
  %modelid{2}='New';
end


Nbox=length(boxname);
if ~prealloc
  Amat1=[];
  Gunsgn1=[];
else
  Amat1=zeros(prealloc,1);
  Gunsgn1=zeros(prealloc,1);
end
Mcur=1; %current index of the first equation to add
Ncur=1; %current index of the first column to add
for ibox=1:Nbox
  disp(['LOADING ' IPdir{ibox} boxname{ibox} '_' modelid{ibox} '_equn.mat'])
  eval(['load ' IPdir{ibox} boxname{ibox} '_' modelid{ibox} '_equn.mat'])
  gsecs_orig=gsecs;
  Cwght_orig=Cwght;
  Binit_orig=Binit;
  p_dEk=any(strcmp(fieldnames(gsecs),'dEkstd'));
  
  nsec=length(gsecs.npair);
  gisbnew=1:nsec;
  [mAmat,nAmat]=size(Amat);
  if exist('p_remove_zero_eq')&p_remove_zero_eq
    girowb=find(Rwght);
  else
    girowb=1:mAmat;
  end
  girowa=(Mcur:Mcur+mAmat-1)';
  girowa=girowa(1:length(girowb));
  gicola=(Ncur:Ncur+nAmat-1)';
  if Mcur==1 %First set of equations
    Gsecs=gsecs;
    Gsecs=rmfield(Gsecs,{'inboxdir','perEk','Ekt'});
    %SETS THE REF. LEV. NEUTRAL SURFACE TO ITS ID
    if any(strcmp(fieldnames(gsecs.rl),'ns'))& ~isempty(gsecs.rl.ns)
      gii=find(~isnan(gsecs.rl.ns));
      Gsecs.rl.nsid(gii)=boxi.glevels(gsecs.rl.ns(gii));
      gii=find(isnan(gsecs.rl.ns));
      Gsecs.rl.nsid(gii)=NaN;
    elseif any(strcmp(fieldnames(gsecs.rl),'nsid'))& ~isempty(gsecs.rl.nsid)
      Gsecs.rl.nsid=gsecs.rl.nsid;
    end
    Pm=pm;
    Pm.gifwcol=pm.ifwcol;
    Pm.gilwcol=pm.ilwcol;
    Pm=rmfield(Pm,['ifwcol';'ilwcol']);
    if any(strcmp(fieldnames(pm),'ifw'))
      Pm.gifw={pm.ifw};
      Pm=rmfield(Pm,'ifw');
    else
      Pm.gifw={[]};
    end
    if any(strcmp(fieldnames(pm),'ifKzcol'))
      Pm.gifKzcol={pm.ifKzcol};
      Pm.gilKzcol={pm.ilKzcol};
      Pm=rmfield(Pm,['ifKzcol';'ilKzcol']);
    else
      Pm.gifKzcol={[]};
      Pm.gilKzcol={[]};
    end
    Pm.giffrow=[];
    Pm.gilfrow=[];
    Pm.gifafrow=[];
    Pm.gilafrow=[];
  else %Mcur~=1
    %CHECK FOR ALREADY EXISTING SECTIONS
    isb=0;npairshifted=0;
    while isb<length(gsecs.npair) %isb= box section indice
      nsec=length(gsecs.npair);
      isb=isb+1;
      for isa=1:length(Gsecs.name) %isa= absolute section indice
	if strcmp(gsecs.name{isb},Gsecs.name{isa})
	  disp(['Section ' gsecs.name{isb} ' overlap ...'])
	  gicolbs=pm.gifcol(isb):pm.gilcol(isb);
	  npair=length(gicolbs);
	  %can be gsecs.npair(isb)+1 if Ekman correction term
	  gicolas=Pm.gifcol(isa):Pm.gilcol(isa);
	  
	  %CHECK CONSISTENCY BEFORE COMBINATION
	  if any(Cwght1(gicolas)~=Cwght(gicolbs)')
	    error('Cwght incompatible')
	  elseif any(Binit1(gicolas)~=Binit(gicolbs)')
	    error('Binit incompatible')
	  elseif Gsecs.EkmanT(isa)~=gsecs.EkmanT(isb)
	    %if ( any(strcmp(fieldnames(Gsecs),'gip2select'))&...
	    %	Gsecs.npair(isa)~=length(Gsecs.gip2select{isa}) ) |...
	    %   (any(strcmp(fieldnames(gsecs),'gip2select'))&...
	    %   gsecs.npair(isb)~=length(gsecs.gip2select{isb}))
	    %  disp('Not same Ekman transport... must be checked')
	    %else
	    %COMMENTED 08/31 BECAUSE MUST HAVE SAME EKMAN TRANSPORT
	    %BUT PLAY WITH PERC TO CHANGE CONTRIBUTION
	      error('Ekman Transport incompatible')
	    %end
	  elseif ~strcmp(Gsecs.namesuf{isa},gsecs.namesuf{isb})
	    error('bottom wedge method incompatible')
	  elseif (~isempty(gsecs.rl.ns))
	    if ~isnan(gsecs.rl.ns(isb))
	      if (Gsecs.rl.nsid(isa)~=boxi.glevels(gsecs.rl.ns(isb)))
		error('ns reference levels incompatible')
	      end
	    elseif ~isnan(Gsecs.rl.nsid(isa))
	      error('ns reference levels incompatible')
	    end	      
	  elseif ( any(strcmp(fieldnames(gsecs.rl),'nsid')) &...
	      ~isempty(gsecs.rl.nsid) ) &...
	      (~isnan(gsecs.rl.nsid(isb))&...
	       ( length(Gsecs.rl.nsid)~=(isa-1) ) &...
	       (Gsecs.rl.nsid(isa)~=gsecs.rl.nsid(isb)))
	    error('nsid reference levels incompatible')
	  elseif ((any(strcmp(fieldnames(Gsecs.rl),'pres'))&...
	      ~isempty(Gsecs.rl.pres) & length(Gsecs.rl.pres)==isa)...
	      |...
	      ( any(strcmp(fieldnames(gsecs.rl),'pres'))...
	        & ~isempty(gsecs.rl.pres)... 
	        & ~isempty(gsecs.rl.pres{isb})...
	      ))...
	      &...
	      (...
	        (...
	        iscell(gsecs.rl.pres)...
	        &...
	        any(Gsecs.rl.pres{isa}~=gsecs.rl.pres{isb})...
	        )...
	        |...
	        (...
	          ~iscell(gsecs.rl.pres)...
	          & (Gsecs.rl.pres(isa)~=gsecs.rl.pres(isb))...
	        )...
	      ) 
	    error('pressure reference level incompatible')
	  elseif Gsecs.npair(isa)~=gsecs.npair(isb)
	    error('number of pairs incompatible')
	  elseif ( ( any(strcmp(fieldnames(gsecs),'pair2mask'))&...
	      length(gsecs.pair2mask)>=isb &...
	      ~isempty(gsecs.pair2mask{isb}) )|...
	      (any(strcmp(fieldnames(Gsecs),'pair2mask'))&...
	      length(Gsecs.pair2mask)>=isa &...
	      ~isempty(Gsecs.pair2mask{isa}) ) )&...
	      (length(Gsecs.pair2mask)<isa |...
	      isempty(Gsecs.pair2mask{isa})|...
	      any(gsecs.pair2mask{isb}~=Gsecs.pair2mask{isa}))
	    error('pair2mask incompatible')
	  elseif ( ( any(strcmp(fieldnames(gsecs),'gip2select'))&...
	      length(gsecs.gip2select)>=isb &...
	      ~isempty(gsecs.gip2select{isb}) )|...
	      (any(strcmp(fieldnames(Gsecs),'gip2select'))&...
	      length(Gsecs.gip2select)>=isa &...
	      ~isempty(Gsecs.gip2select{isa}) ) )
	    if (length(Gsecs.gip2select)<isa |...
		isempty(Gsecs.gip2select{isa}))
	      error('gip2select incompatible')
	    end
	    if((any(strcmp(fieldnames(Gsecs),'subsection'))&...
		~isempty(Gsecs.subsection{isa})&Gsecs.subsection{isa}==1)|...
		(any(strcmp(fieldnames(gsecs),'subsection'))&...
		~isempty(gsecs.subsection{isb})&...
		gsecs.subsection{isb}==1))
	      %do nothing
	    elseif any(gsecs.gip2select{isb}~=Gsecs.gip2select{isa})
	      error('gip2select incompatible')
	    end
	  end
	  Cwght(gicolbs)=[];
	  Binit(gicolbs)=[];
	  gsecs.namesuf=rmcell(gsecs.namesuf,isb);
	  if ~isempty(gsecs.rl.ns)
	    gsecs.rl.ns(isb)=[];
	  end
	  if ( any(strcmp(fieldnames(gsecs.rl),'nsid')) &...
	      ~isempty(gsecs.rl.nsid) )
	    gsecs.rl.nsid(isb)=[];
	  end
	  if (any(strcmp(fieldnames(gsecs.rl),'pres')))&~isempty(gsecs.rl.pres)
	    if iscell(gsecs.rl.pres)
	      gsecs.rl.pres{isb}=rmcell(gsecs.rl.pres,isb); 
	    else
	      gsecs.rl.pres(isb)=[];
	    end
	  end
	  if any(strcmp(fieldnames(gsecs),'pair2mask'))&...
	      length(gsecs.pair2mask)>=isb
	    gsecs.pair2mask=rmcell(gsecs.pair2mask,isb);
	  end
	  if any(strcmp(fieldnames(gsecs),'gip2select'))&...
	      length(gsecs.gip2select)>=isb
	    gsecs.gip2select=rmcell(gsecs.gip2select,isb);
	  end
	  if any(strcmp(fieldnames(gsecs),'subsection'))&...
	      length(gsecs.subsection)>=isb
	    gsecs.subsection=rmcell(gsecs.subsection,isb);
	  end
	  %because of what follows

	  %REARRANGE THE COLUMN ASSIGNMENT
	  %SUPRESS THE OVERLAPPING SECTION FROM THE PARAMETERS
	  gicolbshift=npairshifted+max(gicolbs)+1:length(gicola);
	  gicola(gicolbshift)=gicola(gicolbshift)-npair;
	  gicola(npairshifted+gicolbs)=Pm.gifcol(isa):Pm.gilcol(isa);
	  gisshift=isb+1:nsec;
	  pm.gifcol(gisshift)=pm.gifcol(gisshift)-npair;
	  pm.gilcol(gisshift)=pm.gilcol(gisshift)-npair;
	  pm.gifcol(isb)=[];
	  pm.gilcol(isb)=[];
	  if p_dEk
	    pm.giEkcol(gisshift)=pm.giEkcol(gisshift)-npair;
	    pm.giEkcol(isb)=[];
	  end
	  pm.ifwcol=pm.ifwcol-npair;
	  pm.ilwcol=pm.ilwcol-npair;
	  if any(strcmp(fieldnames(pm),'ifw'))
	    pm.ifw=pm.ifw-npair;
	  end
	  if any(strcmp(fieldnames(pm),'ifKzcol'))
	    pm.ifKzcol=pm.ifKzcol-npair;
	    pm.ilKzcol=pm.ilKzcol-npair;
	  end
	  gisbnew(isb)=[];
	  gsecs.EkmanT(isb)=[];
	  gsecs.npair(isb)=[];
	  gsecs.name=rmcell(gsecs.name,isb);
	  if any(strcmp(fieldnames(gsecs.rl),'pres'))&...
	      length(gsecs.rl.pres)>isb
	    if iscell(gsecs.rl.pres)
	      gsecs.rl.pres=rmcell(gsecs.rl.pres,isb);
	    else
	      gsecs.rl.pres(isb)=[];
	    end
	  end
	  isb=isb-1;
	  npairshifted=npairshifted+npair;
	  break %do not compare to other isa
	end % if section exists
      end %for isa
    end %for isb
    Pm.gifcol=[Pm.gifcol,Ncur-1+pm.gifcol];
    Pm.gilcol=[Pm.gilcol,Ncur-1+pm.gilcol];
    if p_dEk
      Pm.giEkcol=[Pm.giEkcol,Ncur-1+pm.giEkcol];
    end
    Pm.gifwcol=[Pm.gifwcol,Ncur-1+pm.ifwcol];
    Pm.gilwcol=[Pm.gilwcol,Ncur-1+pm.ilwcol];
    if any(strcmp(fieldnames(pm),'ifw'))
      Pm.gifw{ibox}=Ncur-1+pm.ifw;
   else
      Pm.gifw{ibox}=[];
    end
    if any(strcmp(fieldnames(pm),'ifKzcol'))
      Pm.gifKzcol{ibox}=Ncur-1+pm.ifKzcol;
      Pm.gilKzcol{ibox}=Ncur-1+pm.ilKzcol;
    else
      Pm.gifKzcol{ibox}=[];
      Pm.gilKzcol{ibox}=[];
    end
    for is=1:length(gisbnew)
      isb=gisbnew(is);
      %In this loop isb is the indice in the original
      %box, not the one from which parameters of the 
      %overlapping sections have been eliminated
      isanew=length(Gsecs.name)+1;
      Gsecs.name{isanew}=gsecs_orig.name{isb};
      Gsecs.namesuf{isanew}=gsecs_orig.namesuf{isb};
      Gsecs.datadir{isanew}=gsecs_orig.datadir{isb};
      Gsecs.binit{isanew}=gsecs_orig.binit{isb};
      Gsecs.bstd{isanew}=gsecs_orig.bstd{isb};
      putpres=1;
      
      if any(strcmp(fieldnames(gsecs_orig.rl),'ns'))& ...
	  ~isempty(gsecs_orig.rl.ns)
	if ~isnan(gsecs_orig.rl.ns(isb))&gsecs_orig.rl.ns(isb)~=-1
	  Gsecs.rl.nsid(isanew)=boxi.glevels(gsecs_orig.rl.ns(isb));
	  putpres=0;
	else
	  Gsecs.rl.nsid(isanew)=NaN;
	  putpres=1;
	end
      elseif any(strcmp(fieldnames(gsecs_orig.rl),'nsid'))& ...
	  ~isempty(gsecs_orig.rl.nsid)
	Gsecs.rl.nsid(isanew)=gsecs_orig.rl.nsid(isb);
	putpres=0;
	if any(isnan(gsecs_orig.rl.nsid(isb))|gsecs_orig.rl.nsid(isb)==-1)
	  putpres=1;
	end
      end
      if(any(strcmp(fieldnames(gsecs_orig.rl),'pres'))&...
	  ~isempty(gsecs_orig.rl.pres)) & length(gsecs_orig.rl.pres)>=isb...
	&putpres
	Gsecs.rl.pres{isanew}=gsecs_orig.rl.pres{isb};
      end
      if any(strcmp(fieldnames(gsecs_orig),'pair2mask'))&...
	  length(gsecs_orig.pair2mask)>=isb
	Gsecs.pair2mask{isanew}=gsecs_orig.pair2mask{isb};
      end
      if any(strcmp(fieldnames(gsecs_orig),'gip2select'))&...
	  length(gsecs_orig.gip2select)>=isb
	Gsecs.gip2select{isanew}=gsecs_orig.gip2select{isb};
      end
      if any(strcmp(fieldnames(gsecs_orig),'subsection'))&...
	  length(gsecs_orig.subsection)>=isb
	Gsecs.subsection{isanew}=gsecs_orig.subsection{isb};
      end
    end %for is=1:length(isbnew)
    Gsecs.EkmanT=[Gsecs.EkmanT,gsecs.EkmanT];
    Gsecs.npair=[Gsecs.npair,gsecs.npair];
  end %if Mcur~=1
  Gsecs.inboxdir{ibox}=gsecs.inboxdir;
  Gsecs.perEk{ibox}=gsecs.perEk;
  Gsecs.Ekt{ibox}=gsecs.Ekt;
  %if(any(strcmp(fieldnames(gsecs.rl),'pres'))&~isempty(gsecs.rl.pres))
  %  Gsecs.rl.pres{ibox}=gsecs.rl.pres;
  %elseif any(strcmp(fieldnames(gsecs.rl),'ns'))& ~isempty(gsecs.rl.ns)
  %  Gsecs.rl.ns{ibox}=gsecs.rl.ns;
  %end
  if ~prealloc
    Amat1=[Amat1;zeros(length(girowa),size(Amat1,2))];
    Gunsgn1=[Gunsgn1;zeros(length(girowa),size(Gunsgn1,2))];
  end
  Amat1(girowa,gicola)=Amat(girowb,:);
  Gunsgn1(girowa,gicola)=Gunsgn(girowb,:);
  G1(girowa)=G(girowb);
  Ekman1(girowa)=Ekman(girowb);
  Norm1(girowa)=Norm(girowb);
  Rhs1(girowa)=Rhs(girowb);
  Rwght1(girowa)=Rwght(girowb);
  Binit1(gicola)=Binit_orig;
  Cwght1(gicola)=Cwght_orig;
  Pm.ibfrow(ibox)=min(girowa);
  Pm.iblrow(ibox)=max(girowa);
  Pm.giffrow=[Pm.giffrow,Mcur-1+pm.giffrow];
  Pm.gilfrow=[Pm.gilfrow,Mcur-1+pm.gilfrow];
  Pm.gifafrow=[Pm.gifafrow,Mcur-1+pm.gifafrow];
  Pm.gilafrow=[Pm.gilafrow,Mcur-1+pm.gilafrow];
  Pm.eqname(girowa)=pm.eqname(girowb);
  
  Mcur=max(girowa)+1;
  Ncur=max(gicola)+1;
end %for ibox

Amat=sparse(Amat1(1:max(girowa),:));
Gunsgn=sparse(Gunsgn1(1:max(girowa),:));
G=G1';
Ekman=Ekman1';
Norm=Norm1';
Rhs=Rhs1';
Rwght=Rwght1';
Binit=Binit1';
Cwght=Cwght1';
pm=Pm;
gsecs=Gsecs;

clear boxi
boxi.modelid=Modelid;
boxi.name=Name;

if ~exist('OPdir')
  OPdir=IPdir{1};
end
if exist('p_remove_zero_eq')&p_remove_zero_eq
  %clear Gunsgn to save memory
  Gunsgn=[];
end

strs=[  'save ' OPdir boxi.name '_' boxi.modelid '_equn.mat '...
    'Amat      Gunsgn    Rhs       grelvel   lunits '...
    'Binit     Rwght     gsecs     modelid   '... 
    'Cwght     Laybs     boxi      pm       '...  
    'Ekman     Lays      boxname   lipres    propnm   '...  
    'G         Norm      flxeq     lscale    rlpres   '];
disp(strs)
eval(strs)

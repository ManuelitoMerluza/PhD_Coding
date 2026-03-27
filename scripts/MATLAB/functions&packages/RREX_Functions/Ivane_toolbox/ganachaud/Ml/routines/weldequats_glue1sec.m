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
Amat1=[];
Gunsgn1=[];
Mcur=1; %current index of the first equation to add
Ncur=1; %current index of the first column to add
for ibox=1:Nbox
  disp(['LOADING ' IPdir{ibox} boxname{ibox} '_' modelid{ibox} '_equn.mat'])
  eval(['load ' IPdir{ibox} boxname{ibox} '_' modelid{ibox} '_equn.mat'])
 
  nsec=length(gsecs.npair);
  gisbnew=1:nsec;
  [mAmat,nAmat]=size(Amat);
  girowa=(Mcur:Mcur+mAmat-1)';
  gicola=(Ncur:Ncur+nAmat-1)';
  if Mcur==1 %First set of equations
    Gsecs=gsecs;
    Gsecs=rmfield(Gsecs,{'inboxdir','perEk','Ekt'});
    %SETS THE REF. LEV. NEUTRAL SURFACE TO ITS ID
    if any(strcmp(fieldnames(gsecs.rl),'ns'))& ~isempty(gsecs.rl.ns)
      Gsecs.rl.nsid=boxi.glevels(gsecs.rl.ns);
    elseif any(strcmp(fieldnames(gsecs.rl),'nsid'))& ~isempty(gsecs.rl.nsid)
      Gsecs.rl.nsid=gsecs.rl.nsid;
    end
    Pm=pm;
    Pm.gifwcol=pm.ifwcol;
    Pm.gilwcol=pm.ilwcol;
    Pm=rmfield(Pm,['ifwcol';'ilwcol']);
    Pm.giffrow=[];
    Pm.gilfrow=[];
    Pm.gifafrow=[];
    Pm.gilafrow=[];
  else %Mcur~=1
    %CHECK FOR ALREADY EXISTING SECTIONS
    for isb=1:nsec %isb= box section indice
      for isa=1:length(Gsecs.name) %isa= absolute section indice
	if strcmp(gsecs.name{isb},Gsecs.name{isa})
	  disp(['Section ' gsecs.name{isb} ' overlap ...'])
	  npair=gsecs.npair(isb);
	  gicolbs=pm.gifcol(isb):pm.gilcol(isb);
	  gicolas=Pm.gifcol(isa):Pm.gilcol(isa);
	  
	  %CHECK CONSISTENCY BEFORE COMBINATION
	  if any(Cwght1(gicolas)~=Cwght(gicolbs)')
	    error('Cwght incompatible')
	  elseif any(Binit1(gicolas)~=Binit(gicolbs)')
	    error('Binit incompatible')
	  elseif Gsecs.EkmanT(isa)~=gsecs.EkmanT(isb)
	    error('Ekman Transport incompatible')
	  elseif ~strcmp(Gsecs.namesuf{isa},gsecs.namesuf{isb})
	    error('bottom wedge method incompatible')
	  elseif (~isempty(gsecs.rl.ns))&...
	      (Gsecs.rl.nsid(isa)~=boxi.glevels(gsecs.rl.ns(isb))) |...
	      ~isempty(gsecs.rl.nsid) & ...
	      (Gsecs.rl.nsid(isa)~=gsecs.rl.nsid(isb))
	    error('ns reference levels incompatible')
	  elseif ( (any(strcmp(fieldnames(Gsecs.rl),'pres'))&...
	      ~isempty(Gsecs.rl.pres))|...
	      (any(strcmp(fieldnames(gsecs.rl),'pres'))&...
	      ~isempty(gsecs.rl.pres)) )&...
	      (Gsecs.rl.pres(isa)~=gsecs.rl.pres(isb))
	    error('pressure reference level incompatible')
	  elseif Gsecs.npair(isa)~=gsecs.npair(isb)
	    error('number of pairs incompatible')
	  end
	    
	  %REARRANGE THE COLUMN ASSIGNMENT
	  gicolshift=max(gicolbs)+1:length(gicola);
	  gicola(gicolshift)=gicola(gicolshift)-npair;
	  gicola(gicolbs)=Pm.gifcol(isa):Pm.gilcol(isa);
	  gisshift=isb+1:nsec;
	  pm.gifcol(gisshift)=pm.gifcol(gisshift)-npair;
	  pm.gilcol(gisshift)=pm.gilcol(gisshift)-npair;
	  pm.gifcol(isb)=[];
	  pm.gilcol(isb)=[];
	  pm.ifwcol=pm.ifwcol-npair;
	  pm.ilwcol=pm.ilwcol-npair;
	  gisbnew(isb)=[];
	  gsecs.EkmanT(isb)=[];
	  gsecs.npair(isb)=[];
	end % if section exists
      end %for isa
    end %for isb
    Pm.gifcol=[Pm.gifcol,Ncur-1+pm.gifcol];
    Pm.gilcol=[Pm.gilcol,Ncur-1+pm.gilcol];
    Pm.gifwcol=[Pm.gifwcol,Ncur-1+pm.ifwcol];
    Pm.gilwcol=[Pm.gilwcol,Ncur-1+pm.ilwcol];
    for is=1:length(gisbnew)
      isb=gisbnew(is);
      isanew=length(Gsecs.name)+is;
      Gsecs.name{isanew}=gsecs.name{isb};
      Gsecs.namesuf{isanew}=gsecs.namesuf{isb};
      Gsecs.datadir{isanew}=gsecs.datadir{isb};
      Gsecs.binit{isanew}=gsecs.binit{isb};
      Gsecs.bstd{isanew}=gsecs.bstd{isb};
      if(any(strcmp(fieldnames(gsecs.rl),'pres'))&~isempty(gsecs.rl.pres))
	Gsecs.rl.pres(isanew)=gsecs.rl.pres(isb);
      elseif any(strcmp(fieldnames(gsecs.rl),'ns'))& ~isempty(gsecs.rl.ns)
	Gsecs.rl.nsid(isanew)=boxi.glevels(gsecs.rl.ns(isb));
      elseif any(strcmp(fieldnames(gsecs.rl),'nsid'))& ~isempty(gsecs.rl.nsid)
	Gsecs.rl.nsid(isanew)=gsecs.rl.nsid(isb);
      end
    end
    Gsecs.EkmanT=[Gsecs.EkmanT;gsecs.EkmanT];
    Gsecs.npair=[Gsecs.npair;gsecs.npair];
  end %if Mcur~=1
  Gsecs.inboxdir{ibox}=gsecs.inboxdir;
  Gsecs.perEk{ibox}=gsecs.perEk;
  Gsecs.Ekt{ibox}=gsecs.Ekt;
  %if(any(strcmp(fieldnames(gsecs.rl),'pres'))&~isempty(gsecs.rl.pres))
  %  Gsecs.rl.pres{ibox}=gsecs.rl.pres;
  %elseif any(strcmp(fieldnames(gsecs.rl),'ns'))& ~isempty(gsecs.rl.ns)
  %  Gsecs.rl.ns{ibox}=gsecs.rl.ns;
  %end
  Amat1=[Amat1;zeros(length(girowa),size(Amat1,2))];
  Amat1(girowa,gicola)=Amat;
  Gunsgn1=[Gunsgn1;zeros(length(girowa),size(Gunsgn1,2))];
  Gunsgn1(girowa,gicola)=Gunsgn;
  G1(girowa)=G;
  Ekman1(girowa)=Ekman;
  Norm1(girowa)=Norm;
  Rhs1(girowa)=Rhs;
  Rwght1(girowa)=Rwght;
  Binit1(gicola)=Binit;
  Cwght1(gicola)=Cwght;
  Pm.ibfrow(ibox)=min(girowa);
  Pm.iblrow(ibox)=max(girowa);
  Pm.giffrow=[Pm.giffrow,Mcur-1+pm.giffrow];
  Pm.gilfrow=[Pm.gilfrow,Mcur-1+pm.gilfrow];
  Pm.gifafrow=[Pm.gifafrow,Mcur-1+pm.gifafrow];
  Pm.gilafrow=[Pm.gilafrow,Mcur-1+pm.gilafrow];
  Pm.eqname(girowa)=pm.eqname;
  
  Mcur=max(girowa)+1;
  Ncur=max(gicola)+1;
  
end %for ibox
Amat=sparse(Amat1);
Gunsgn=sparse(Gunsgn1);
G=G1';
Ekman=Ekman1';
Norm=Norm1';
Rhs=Rhs1';
Rwght=Rwght1';
Binit=Binit1';
Cwght=Cwght1';
pm=Pm;
gsecs=Gsecs;

disp(['SAVING ' IPdir{1} Modelid '_equn.mat '...
    'Amat      Gunsgn    Rhs       grelvel   lunits '...
    'Binit     Rwght     gsecs     modelid   '... 
    'Cwght     Laybs     boxi      pm       '...  
    'Ekman     Lays      boxname   lipres    propnm   '...  
    'G         Norm      flxeq     lscale    rlpres   '])
eval([  'save ' IPdir{1} Modelid '_equn.mat '...
    'Amat      Gunsgn    Rhs       grelvel   lunits '...
    'Binit     Rwght     gsecs     modelid   '... 
    'Cwght     Laybs     boxi      pm       '...  
    'Ekman     Lays      boxname   lipres    propnm   '...  
    'G         Norm      flxeq     lscale    rlpres   '])

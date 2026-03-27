% Save net cross section transports from hydrotrans into a global variable
% Transec

for isb=1:Nsec
  disp(['Section ' gsecs.name{isb}])
  if ~exist('Transec')
    p_update=1;
    isa_global=0;
  else
    p_update=1;
    for isa=1:length(Transec)
      if strcmp(Transec(isa).secname,gsecs.name{isb})
	p_update=0;
	disp('already there')
      end
    end
  end %~exist('Transec')
  if p_update
    isa_global=isa_global+1;
    Transec(isa_global).secname=gsecs.name{isb};
    Transec(isa_global).streamf=p_pltstream;
    Transec(isa_global).box=boxname1{ibox1};
    Transec(isa_global).nlay=boxi.nlay;
    Transec(isa_global).Tr=Tr{isb};
    Transec(isa_global).Ta=Ta{isb};
    Transec(isa_global).dTa=dTa{isb};
    Transec(isa_global).Tbi=Tbi{isb};
    Transec(isa_global).Tanet=Ta{isb}(boxi.nlay,:);
    Transec(isa_global).dTanet=dTa{isb}(boxi.nlay,:);
    Transec(isa_global).Tunits=lunits;
    Transec(isa_global).Tscale=lscale;
    Transec(isa_global).Tscale=lscale;
    Transec(isa_global).Laydep=-[0;cumsum(Lays{isb}.lavgwdth(1:Nlay-1))'];
    if exist('p_save_Amat')&p_save_Amat
      Amatnets_glb{isa_global}=Amatnets{isb};
    end
    disp('recorded')
  end
end
clear Amatnets

% 
disp('mask last layer (19 and 20) of P3')
gil2mask=19:20;

lprop{isb,iprop}(:,gil2mask)=0;
lgvprop{isb,iprop}(:,gil2mask)=0;
lsumpropr(gil2mask,iprop)=lsumpropr(gil2mask,iprop)-...
  Lays{isb,iprop}.lsumprop(gil2mask)';
lsumpropr2(gil2mask,iprop)=lsumpropr2(gil2mask,iprop)-...
  Lays{isb,iprop}.lsumprop2(gil2mask)';
lisumpropr(gil2mask,iprop)=lisumpropr(gil2mask,iprop)-...
  Laybs{isb,iprop}.lisumprop(gil2mask)';
lisumpropr2(gil2mask,iprop)=lisumpropr2(gil2mask,iprop)-...
  Laybs{isb,iprop}.lisumprop2(gil2mask)';
lisumdCrdz(gil2mask-1,iprop)=lisumdCrdz(gil2mask-1,iprop)-...
  Laybs{isb,iprop}.lisumdCdz(gil2mask-1);
Lays{isb,iprop}.lavgwdth(gil2mask)=0;
Lays{isb,iprop}.lverarea(gil2mask)=0;
Lays{isb,iprop}.lsumprop(gil2mask)=0;
Lays{isb,iprop}.lsumprop2(gil2mask)=0;
Lays{isb,iprop}.lavgprop(gil2mask)=0;
Lays{isb,iprop}.lstdprop(gil2mask)=0;

Laybs{isb,iprop}.litotdist(gil2mask)=0;
Laybs{isb,iprop}.lisumprop(gil2mask)=0;
Laybs{isb,iprop}.lisumprop2(gil2mask)=0;
Laybs{isb,iprop}.liavgprop(gil2mask)=0;
Laybs{isb,iprop}.listdprop(gil2mask)=0;
Laybs{isb,iprop}.lisumdCdz(gil2mask-1)=0;
Laybs{isb,iprop}.liavgdCdz(gil2mask-1)=0;

lsumprop(gil2mask,iprop)=lsumprop(gil2mask,iprop)-...
  Layprops{isb,iprop}.lsumprop(gil2mask)';
lsumprop2(gil2mask,iprop)=lsumprop2(gil2mask,iprop)-...
  Layprops{isb,iprop}.lsumprop2(gil2mask)';
lisumprop(gil2mask,iprop)=lisumprop(gil2mask,iprop)-...
  Laypropbs{isb,iprop}.lisumprop(gil2mask)';
lisumprop2(gil2mask,iprop)=lisumprop2(gil2mask,iprop)-...
  Laypropbs{isb,iprop}.lisumprop2(gil2mask)';
lisumdCdz(gil2mask-1,iprop)=lisumdCdz(gil2mask-1,iprop)-...
  Laypropbs{isb,iprop}.lisumdCdz(gil2mask-1);
Layprops{isb,iprop}.lavgwdth(gil2mask)=0;
Layprops{isb,iprop}.lverarea(gil2mask)=0;
Layprops{isb,iprop}.lsumprop(gil2mask)=0;
Layprops{isb,iprop}.lsumprop2(gil2mask)=0;
Layprops{isb,iprop}.lavgprop(gil2mask)=0;
Layprops{isb,iprop}.lstdprop(gil2mask)=0;

Laypropbs{isb,iprop}.litotdist(gil2mask)=0;
Laypropbs{isb,iprop}.lisumprop(gil2mask)=0;
Laypropbs{isb,iprop}.lisumprop2(gil2mask)=0;
Laypropbs{isb,iprop}.liavgprop(gil2mask)=0;
Laypropbs{isb,iprop}.listdprop(gil2mask)=0;
Laypropbs{isb,iprop}.lisumdCdz(gil2mask-1)=0;
Laypropbs{isb,iprop}.liavgdCdz(gil2mask-1)=0;

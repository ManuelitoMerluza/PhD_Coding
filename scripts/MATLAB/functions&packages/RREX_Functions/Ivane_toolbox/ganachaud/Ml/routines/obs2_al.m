%obs2_vert.m: part of obs2std code (vertical interp Aitken-Lagrange)
             if gimiss(1)==1
		id1=max(gimiss)+1;
		id2=max(gimiss)+2;
		while isnan(bprop(id2,is))
		  id2=id2+1;
		  if id2>bmaxd(is)
		    disp('Not enough points for vertical extrapolation')
		    id2=0;
		    break
		  end
		end
	      else
		id1=gimiss(1)-1;
		id2=max(gimiss)+1;
		if id2>bmaxd(is)
		  id2=gimiss(1)-2;
		  if id2<1
		    disp('Not enough points for vertical extrapolation')
		    id2=0;
		  else
		    while isnan(bprop(id2,is))
		      id2=id2-1;
		      if id2<1
			disp('Not enough points for vertical extrapolation')
			id2=0;
			break
		      end
		    end
		  end
		end
	      end
	      id3=id1-1;
	      if id3<1
		if id2+1<=bmaxd(is)
		  id3=id2+1;  
		  while isnan(bprop(id3,is))
		    id3=id3+1;
		    if id3>bmaxd(is)
		      disp('Not enough points for vertical extrapolation')
		      id3=0;
		      break
		    end
		  end
		else
		  id3=0;
		  disp('Try linear interpolation !')
		end
	      end
	
	      if id2 & id3
		di2=stdd(gimiss)-stdd(id2);
		di3=stdd(gimiss)-stdd(id3);
		d12=stdd(id1)-stdd(id2);
		d13=stdd(id1)-stdd(id3);
		di1=stdd(gimiss)-stdd(id1);
		d23=stdd(id2)-stdd(id3);
		bprop(gimiss,is)=...
		  bprop(id1,is)*(di2.*di3)/( d12*d13)+...
		  bprop(id2,is)*(di1.*di3)/(-d12*d23)+...
		  bprop(id3,is)*(di1.*di2)/( d13*d23);
	      else
		disp('No vertical extrapolation possible')
	      end
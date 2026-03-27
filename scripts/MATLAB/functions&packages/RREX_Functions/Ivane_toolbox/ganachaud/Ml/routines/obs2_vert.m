%obs2_vert.m: part of obs2std code (vertical interp/extrap)
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
	      if id2
		bprop(gimiss,is)=bprop(id1,is)+(stdd(gimiss)-stdd(id1))*...
		  (bprop(id2,is)-bprop(id1,is))/(stdd(id2)-stdd(id1));
	      else
		disp('No vertical extrapolation possible')
	      end
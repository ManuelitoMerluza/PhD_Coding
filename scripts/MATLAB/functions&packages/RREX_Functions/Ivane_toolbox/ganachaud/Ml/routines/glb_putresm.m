function glb_putresm(iv,reslat,reslon,resres,resunc,p_resbox,...
p_resfontsize,resboxscale,scaleboxes,resboxwidth,...
cposres,cnulres,cnegres,boxname,gilsup,gilinf,dilsup,dilinf,...
p_putgamma)
% 					KEY: Put the residuals on a plot generated ny glb_transmap
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
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , Apr99
%
% SIDE EFFECTS :
%
% SEE ALSO :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER: glb_transmap
% CALLEE:
for ir=1:length(reslon)
  if isnan(resres(ir)) | resres(ir)==0
    rescolor=cnulres;
    razi=0;
  elseif resres(ir)>0
    rescolor=cposres;
    razi=0;
  elseif resres(ir)<0
    rescolor=cnegres;
    razi=180;
  end
  if ~p_resbox
    fmttrans={'''%1g ''';'''%1.2g ''';'''%3.0g ''';'''%3.0f ''';
    '''%3.0f ''';'''%3.0f ''';'''%3.0f ''';'''%3.0f ''';'''%3.0g ''';
    '''%3.0f '''};
    if ~isnan(resres(ir))
      eval(['slabel=deblank(sprintf(' fmttrans{iv} ...
	  ',resres(ir),resunc(ir)));'])
    else	    
      eval(['slabel=deblank(sprintf(' fmttrans{iv} ...
	  ',resres(ir),resunc(ir)));'])
    end
    if ~isnan(resres(ir))
      htx=m_text(reslon(ir),reslat(ir),slabel,...
	'fontsize',p_resfontsize,'color',rescolor);
    end
  else 
    %PUT RESIDUALS AS BOXES
    if ~isnan(resres(ir))
      [hpr,htr]=m_vec(1,reslon(ir),reslat(ir),...
	abs(resres(ir))/resboxscale(iv)*scaleboxes*cos(razi*pi/180),...
	abs(resres(ir))/resboxscale(iv)*scaleboxes*sin(razi*pi/180),rescolor,...
	'shaftwidth',resboxwidth,'headlength',0);
      Hpr{ir}=hpr;
      Htr{ir}=htr;
    end
    
    %UNCERTAINTY
    [hpru,htru]=m_vec(1,reslon(ir),reslat(ir),...
      resunc(ir)/resboxscale(iv)*scaleboxes*cos(razi*pi/180),...
      resunc(ir)/resboxscale(iv)*scaleboxes*sin(razi*pi/180),'w',...
      'shaftwidth',resboxwidth/3,'headlength',0,'EdgeColor','k');
    
    if p_putgamma %put gamma interfaces
      reslatshift=.9;
      reslonshift=1;
      if resres(ir) > 0
	if gilsup(ir) ~= 0 & gilsup(ir) ~= 22 & ...
	    ((ir>1)&(gilsup(ir)~=gilinf(ir-1)))
	  m_text(reslon(ir)-reslonshift,reslat(ir)+reslatshift,...
	    sprintf('%3.4g(%3im)',gilsup(ir),round(dilsup(ir))),'fontsize',7);
	end
	if gilinf(ir)~=48 & gilinf(ir)~=100  & gilinf(ir)~=99
	  m_text(reslon(ir)-reslonshift,reslat(ir)-reslatshift,...
	    sprintf('%3.4g(%3im)',gilinf(ir),round(dilinf(ir))),'fontsize',7);
	end
      else
	if gilsup(ir) ~= 0 & gilsup(ir) ~= 22 &...
	    ((ir>1)&(gilsup(ir)~=gilinf(ir-1)))
	  m_text(reslon(ir)+reslonshift,reslat(ir)+reslatshift,...
	    sprintf('%3.4g(%3im)',gilsup(ir),round(dilsup(ir))),'fontsize',7);
	end
	if gilinf(ir)~=48 & gilinf(ir)~=100  & gilinf(ir)~=99
	  m_text(reslon(ir)+reslonshift,reslat(ir)-reslatshift,...
	    sprintf('%3.4g(%3im)',gilinf(ir),round(dilinf(ir))),'fontsize',7);
	end
      end %if fdres
    end %if p_putgamma
    %ADD LITTLE AXIS ON RESIDUAL BOXES
    hl=m_line([reslon(ir),reslon(ir)],[reslat(ir)-3,reslat(ir)+3],...
      'linewidth',.2,'color','k');
   end %if ~p_resbox
end %for ir=1:length(reslon)
      
      
      
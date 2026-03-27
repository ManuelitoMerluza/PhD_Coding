function [Hp,Ht,Hpu,Htu,htx]=glb_putseclabel(iv,latlon,arrowbasepositions,section2put,Nsec,...
Iazi,Transec,gist,figname,scale,thinvsthickarrowsratio,...
p_arrowcolor,p_arrowwidth,p_mk_arrows,p_unc,Outdir,...
p_writeflux,p_put_transports,p_bw)
% 					KEY: put the arrows for the total/partial transport across sections
% USAGE :
% DESCRIPTION : 
% INPUT: 
% OUTPUT: handles to transport arrows
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , Apr99
%          June 01: added possibility of net/bt/bi/gyre transports 
% SIDE EFFECTS :
% SEE ALSO : glb_putresm
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER: glb_transmap
% CALLEE:
global Llll p_resfontsize
htx=[];
Hpu=[];
Htu=[];
Hp=[];
Ht=[];
set(gca,'PlotBoxAspectRatioMode','auto')
set(gca,'DataAspectRatioMode','auto')
set(gca,'cameraviewanglemode','auto')
secnames={'A2 (Jul 93)', 'A5 (Jul 92)','A6 (Feb 93)',...
  'A7 (Jan 93)','A8 (Mar 94)','A9 (Feb 91)','A10 (Jan 93)',...
  'A11 (Jan 93)','A21 (Jan 90)','A12 (May 92)','I6 (Feb 96)',...
  'I9S (Jan 95)','P12 (Jan 95)','I5 (Nov 87)','I3+I4 (Jun 95)',...
  'I2+I10 (Nov 95)','JADE (Aug 89)','P6 (May 92)',...
  'P21 (May 94)','P3 (May 85)','P1 (Apr 85)'
  };
fontsize=12;

arrcolor=p_arrowcolor;
p_unc1=p_unc;
for isa_h=1:Nsec
  %latlon=load([latlondir section2put{isa_h} '.latlon']);
  lonsec=scan_longitude(latlon{isa_h}(:,2));
  latsec=latlon{isa_h}(:,1);
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %creates the tranports file
  %1):position of each arrow:
  ipairpos=floor(length(lonsec)/2);
  isa_h
  flat=mean(latsec)
  flon=mean(lonsec)
  %[hp,ht]=m_vec(0.23,flon-30,flat+3,0.2,0,[1 1 1],...
  %  'shaftwidth',0.8*fontsize,'headlength',0,...
  %  'EdgeColor','k');
  htx=m_text(flon,flat,secnames(isa_h),...
    'fontsize',fontsize,'color','b','fontweight','bold',...
    'VerticalAlignment','bottom','HorizontalAlignment','center');
end %on isa_h


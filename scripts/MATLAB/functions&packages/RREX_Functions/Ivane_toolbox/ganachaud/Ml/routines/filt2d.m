function B=filt2d(A,lx,ly,dx,dy)
% KEY: filter 2D field with spec. sampling at row or column
% USAGE : B=filt2d(A,lx,ly,dx,dy)
% DESCRIPTION: filter A with a sinc over the x and y directions
%               lx,ly=cut-off wavelengths
%               dx,dy=sample interval, can be of variable size
%                     independently
% INPUT: dx(jj) ok
%        dy(ji,jj) ok also but slow
%
% OUTPUT:
%
% AUTHOR : A.Ganachaud (ganacho@notos.cst.cnes.fr) Jan 2002
%
% SIDE EFFECTS :
%
% SEE ALSO :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER:
% CALLEE: fsinc
% EXAMPLE:
if 0 % DEMO
  fs=100;
  t=0:1/fs:1;
  A=sin(2*pi*t*3)+0.25*sin(2*pi*t*40);
  A=A(:)*ones(1,50)+0.3*randn(length(A),50);
  A=A';
  dx=1/fs;
  dy(1:size(A,1))=1/fs; %sample interval=0.01;
  dy=dy(:)*ones(1,size(A,2));
  lx=0.1; %wavelenght cut-off
  ly=0.2;
  [xhat,xacvn,xvar,xpsd_,dxpsd_,fm]=spectmat(A',mean(mean(dy)));
  f1;clf;plot(fm,abs(xhat(1:length(fm),:)).^2)
  B=filt2d(A,lx,ly,dx,dy); %Square filter
  % B=filt2d(A',lx,lx,dx(1),dx(:,1))'; %Square filter change dir.
  [xhat,xacvn,xvar,xpsd_,dxpsd_,fm]=spectmat(B',mean(mean(dy)));
  f1;hold on; plot(fm,abs(xhat(1:length(fm),:)).^2,'r')
  f2;clf;plot(t,A');
  f2;hold on; plot(t,B','r');
  
  %2D surface Filter
  A=(sin(2*pi*t*3)+0.25*sin(2*pi*t*40))'*...
    (sin(2*pi*t*3)+0.25*sin(2*pi*t*40));
  clf;surf(A);
  B=filt2d(A,lx,lx,dx,dx); %Square filter.
  hold on; surf(B+2);
  B=filt2d(A,3*lx,3*lx,dx,dx); %Square filter.
  hold on; surf(B+4); shading flat
  
end
   
if ~(any(size(dx)==1))
  error('IRREGULAR dx(i,j) not programmed... do it !')
end
if length(dx)>1
  for jj=1:size(A,2)
    xx=dx(jj):dx(jj):6*lx;
    xx=[-reverse(xx),0,xx];
    Fx=fsinc(xx(:)/lx)/lx;
    B(:,jj)=dx(jj)*conv2(A(:,jj),Fx,'same');
  end %for jj=1:size(A,2)
else %if length(dx>1)
  xx=dx:dx:6*lx;
  xx=[-reverse(xx),0,xx];
  Fx=fsinc(xx(:)/lx)/lx;
  if 0 %FREQUENCY RESPONSE
    n=128;
    [H,W,S]=freqz(dx*Fx,1,256,1/dx);S.yunits='linear';
    clf;freqzplot(H,W,S)
    ppause
  end
  B=dx*conv2(A,Fx,'same');
end

[ni,nj]=size(A);
if ~(any(size(dy)==1))
  disp('SLOW FILTER...')
end

if length(dy)>1
  for ji=1:size(A,1)
    if any(size(dy)==1)
      yy=dy(ji):dy(ji):6*ly;
      yy=[-reverse(yy),0,yy];
      Fy=fsinc(yy(:)/ly)/ly;
      B(ji,:)=dy(ji)*conv2(A(ji,:)',Fy,'same')';
    else
      for jj=1:nj
	%APPROXIMATE DY CENTERED ON POINT
	yy=dy(ji,jj):dy(ji,jj):6*ly;
	nk=length(yy);
	yy=[-reverse(yy),0,yy]; %size is 2nk+1
	Fy=fsinc(yy(:)/ly)/ly;
	gjj=max(1,jj-nk):min(nj,jj+nk);
	gjk=gjj-jj+nk+1;
	B(ji,jj)=trapz(yy(gjk),A(ji,gjj)'.*Fy(gjk));
      end %for jj=1:nj
    end
  end %for ji=1:size(A,1)
else %if length(dy>1)
  yy=dy:dy:6*ly;
  yy=[-reverse(yy),0,yy];
  Fy=fsinc(yy(:)/ly)/ly;  
  B=dy*conv2(A',Fy,'same')';
end
disp('filtering done')

function [yhat,fm]=fftmxtaper(yy,delt);
%fftmxtaper: A. Ganachaud-fft the colums of a matrix 
%after tapering them
%from spectru3.m spectrum using Daniell window and cosine taper.
%by C. Wunsch, 1987.
%%modified May and July 1995
%using fft.
%%same as spectru2.m except plotting and output are suppressed
% M is window width--Daniell. delt must also be specified.
[L,N]=size(yy);
%generate a taper window
  L10=ceil(L/10);
  wind=ones(L,1);
  wind(1:L10,1)=1-cos([1:L10]'*pi/(2*L10));
  wind(L:-1:L-L10+1,1)=wind(1:L10,1);
  for jj=1:N
    yy(:,jj)=yy(:,jj).*wind;
    yy(:,jj)=yy(:,jj)-mean(yy(:,jj));
  end
  yhat=fft(yy);

  %FREQUENCIES
  if nargout==2
    nqt=fix(L/2); %nyquist
    df=1/(L*delt);  
    fm=df*(0:nqt);
  end
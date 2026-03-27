function [spectx,specty,coherxy,coherxyp,freq,period,cohconf,cohpconf]=...
coheremat(xxhat,yyhat,M,dt)
% KEY: compute coherence and spectrum between 2 matrices
% USAGE : [spectx,specty,coherxy,freq,period,...
%    ,cohconf,cohpconf ]=... <Optional>
%   coheremat(xxhat,yyhat,M,dt)
%
%
% DESCRIPTION : 
%    compute psd of 2 variables and coherence column by column of
%    2 matrices
%  Mormally M = integer=number of frequencies over which to avg
%  if M is a vector, contains frequency bands (0.001 0.1 1)
%  over which to estimate spectrum and coherence. Then OP contains
%  length(M)-1 frequencies.
% INPUT: 
%
%
% OUTPUT:
%   spectx,specty: psd over M points, in Sv^2 cycle/day
%   coherxy,coherxyp: coherence (not squared) and phase
%   positive phase means that y is late 
%   freq,period = frequency (and period) scales
%
% AUTHOR : A.Ganachaud (ganacho@ifremer.fr) Oct 2001
%
% SIDE EFFECTS :
%
% SEE ALSO : spectmat
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER:
% CALLEE:
N=size(xxhat,1);

if length(M)==1
  window=ones(M,1);
  %%multiplies by conjugate. mixing + and
  %% minusfrequencies.  use with real data only.
  spectx=conv2(window,1,xxhat.*conj(xxhat),'same');
  specty=conv2(window,1,yyhat.*conj(yyhat),'same');
  coherxy=conv2(window,1,xxhat.*conj(yyhat),'same');
  giznotnull=find(spectx.*specty);
  coherxy(giznotnull)=coherxy(giznotnull)./...
    (sqrt(spectx(giznotnull)).*sqrt(specty(giznotnull)));
  %divide values by width of the averaging interval to get spectral density
  %in units of Sv^2 rms cycle/day
  spectx=spectx/(M*dt);
  specty=specty/(M*dt);
  %now decimate
  s=M:M:N/2;
  s1=length(s);
  spectx=spectx(s,:);
  specty=specty(s,:);
  coherxy=coherxy(s,:);

  %discarding 1/2 the spectrum by symmetry. keeping only first 1/2.
  
  %set up frequency  scale
  freq(1,1)=(M-1)/2*(1/(N*dt));
  freq(2:s1,1)=freq(1)+(M/(N*dt))*[1:s1-1]';
  for ii=2:s1
    period(ii,1)=1/freq(ii,1);
  end
  if M==1
    period(1,1)=inf;
  else
    period(1,1)=1/freq(1,1);
  end
  dfreed=M;
  for irge=1:s1
    if nargout>=7
      dfreed=M;
      cohconf(irge)=cohereconf(dfreed);
      if nargout==8
        cohpconf(irge,:)=180/pi*...
            coherephaseconf(dfreed,coherxy(irge));
      end
    end
  end

else %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %1-Find where indices of frequencies to average over
  nqt=fix(N/2);
  df=1/(N*dt);
  fm=df*(0:nqt-1);
  for irge=1:length(M)-1
    gif=find(fm > M(irge) & fm <=M(irge+1));
    
    %%multiplies by conjugate. mixing + and
    %% minusfrequencies.  use with real data only.
    spectx(irge,:)=sum(xxhat(gif,:).*conj(xxhat(gif,:)));
    specty(irge,:)=sum(yyhat(gif,:).*conj(yyhat(gif,:)));
    coherxy(irge,:)=sum(xxhat(gif,:).*conj(yyhat(gif,:)));
    giznotnull=find(spectx(irge,:).*specty(irge,:));
    coherxy(irge,giznotnull)=coherxy(irge,giznotnull)./...
      (sqrt(spectx(irge,giznotnull)).*sqrt(specty(irge,giznotnull)));
    %divide values by width of the averaging interval 
    %to get spectral density
    %in units of Sv^2 rms cycle/day
    spectx(irge,:)=spectx(irge,:)/(length(gif)*dt);
    specty(irge,:)=specty(irge,:)/(length(gif)*dt);
    
    %set up frequency  scale
    freq(irge,:)=fm([gif(1),max(gif)]);
    period(irge,:)=1./freq(irge,:);
    if nargout>=7
      dfreed=length(gif);
      cohconf(irge)=cohereconf(dfreed);
      if nargout==8
	cohpconf(irge,:)=180/pi*...
	  coherephaseconf(dfreed,coherxy(irge,:)')';
      end
    end
  end %for irge
end %if length(M)==1

coherxyp=atan2(imag(coherxy),real(coherxy));
coherxy=sqrt(abs(coherxy));


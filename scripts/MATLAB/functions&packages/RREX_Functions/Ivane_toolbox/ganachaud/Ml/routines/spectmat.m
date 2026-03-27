function [umhatt,umacvn,umvar,umpsdt,dumpsdt,fm]=spectmat(xx,dt)
% spectrum on rows of matrices
% KEY: 
% USAGE :
% 
% DESCRIPTION : 
%   compute periodogram of each column
%   computes psd based on average of all columns
%
% INPUT: xx(nt x nvar) in Sv
%        dt: time unit
%
% OUTPUT: umhatt: fft in Sv rms
%         so that umacv(1,i).* umvar(i)= sum((xx-mean(xx))^2)/nt
%         Parseval:
%         sum(umhatt x umhatt*)=sum(xx.^2)/N=umacv(1)
%
%         umacvn: normalized autocovariances
%         umvar: variance of each column
%         umpsdt: psd=average of all periodograms
%         dumpsdt: std.deviation between periodograms
%         fm: frequency
%
% AUTHOR : A.Ganachaud (ganacho@ifremer.fr) , Sept2001
%
% SIDE EFFECTS :
%     %not corrected for taper energy loss.
%
% SEE ALSO :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER:
% CALLEE:
  nt=size(xx,1);
  nqt=fix(nt/2);
  df=1/(nt*dt);
  fm=df*(0:nqt-1);
  xx=xx-ones(nt,1)*mean(xx);
  %Generate a taper window
  nt10=fix(nt/10);
  wind=ones(nt,1);
  wind(1:nt10,1)=1-cos([1:nt10]'*pi/(2*nt10));
  wind(nt:-1:nt-nt10+1,1)=wind(1:nt10,1);
  wind=wind*ones(1,size(xx,2));
  xx=xx.*wind;
  xx=xx-ones(nt,1)*mean(xx);

  umhatt=fft(xx)/nt;
  umperiod=umhatt.*conj(umhatt);
  %umperiod in Sv ^2 rms
  umacv=nt*ifft(umperiod);
  %umacv in Sv^2 rms
  umacv=real(umacv(1:nqt,:));
  giznotnull=find(umacv(1,:));
  giznull=find(~umacv(1,:));
  umacvn=NaN*ones(size(umacv));
  umacvn(:,giznotnull)=umacv(:,giznotnull)./...
    (ones(nqt,1)*umacv(1,giznotnull));
  umvar=umacv(1,:);
  %Now, umacv(1)=sum(xx-mean(xx) ^2)/nt
  umperiod=umperiod(1:nqt,:);
  umperiod(:,giznull)=NaN;
  umpsdt=mmean(umperiod');
  dumpsdt=mstd(umperiod')';
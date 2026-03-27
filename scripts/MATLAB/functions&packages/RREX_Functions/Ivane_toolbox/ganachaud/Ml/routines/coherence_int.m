function [cohint,cohphi,cohconf,cohconf60]=coherence_int(x,y,gifrq)
%computes coherence (not squared) and phase between x and y (ffts)
% x is MxN, fft of x_ (M samples/ N geographical points)
% y is Mx1, fft of y_
% cohint,cohphi: coherence and phase (Nx?)
% cohconf,cohconf60: 95 and 60% non-zero confidence
% coherence is computed over interval gifrq (indices of frequencies)
% if gifrq is a cell, loop over the different frequency intervals
% uses cohconf/cohconf60
% A. Ganachaud, 03/2001
%NEGATIVE PHASE : X IS LATE W/RESPECT TO Y
[nt,nu]=size(x);
if iscell(gifrq)
  niint=length(gifrq);
else
  niint=1;
end
for iint=1:niint
  if iscell(gifrq)
    gifrq1=gifrq{iint};
  else
    gifrq1=gifrq;
  end
  if min(size(y))==1
    Y=y(gifrq1)*ones(1,nu);
  else
    Y=y(gifrq1);
  end
  coh=sum(x(gifrq1,:).*conj(Y))...
    ./sqrt(sum(x(gifrq1,:).*conj(x(gifrq1,:)))...
    .*sum(Y.*conj(Y)));
  cohint(:,iint)=abs(coh)';
  cohphi(:,iint)=180/pi*atan2(imag(coh),real(coh))';
  %confidence for coherence
  cohconf(iint)=cohereconf(length(gifrq1));
  cohconf60(iint)=cohereconf60(length(gifrq1));
end %iint
function [pol, delta_pres] = calibration_FP07(pres,Tf,Tacc,fs, nsec)
fprintf('\nThermistor calibration')
if nargin<5
    nsec = 20;
end

maxN = floor(nsec*fs);
R = nan(2*maxN+1,1);
ind = [-maxN:maxN];
j=1;
for i =-maxN:maxN
    if i>=0
        y = Tacc(1+i:end);
        x = Tf(1:end-i);
    else
        y = Tacc(1:end-abs(i));
        x = Tf(1+abs(i):end);
    end
    r = corrcoef(x,y);
    R(j)=r(1,2);
    j=j+1;
end
%maximum correlation
[MR,im] = max(R);
IM = ind(im);
%gets displaced temperatures and pressure correction for slow sensors
if IM>=0
   y = Tacc(1+IM:end);
   x = Tf(1:end-IM);
   delta_pres = -nanmean( pres(1+IM:end) - pres(1:end-IM) );
else
   y = Tacc(1:end-abs(IM));
   x = Tf(1+abs(IM):end);
   delta_pres = -nanmean( pres(1:end-abs(IM)) - pres(1+abs(IM):end) );
end
fprintf('\nTime difference %1.3f secs',IM/fs)

% figure()
% clf
% plot(ind/fs,R)
% hold on
% plot(ind(IM)/fs,R(IM),'ro')
% 
% figure()
% plot(x)
% hold on
% plot(y)
% pause()

delta_T = max(y) - min(y);

%does a quadratic correction when delta_T>5, otherwise linear
if delta_T>5
    fprintf('\nQuadratic')
    pol = polyfit(x,y,2);
else
    fprintf('\nLinear')
    pol = polyfit(x,y,1);
end

%figure()
%plot(x,y,'.')
%pause()


function spvol=v350p(p)
% function spvol=v350p(p)
%
% specific volume (cm**3/G) of sea-water with 
%   T= 0.0 (C),  S= 35.0 (psu), P= p (dB)
%
% check value: spvol = 9.337431e-1 cm**3/g for p = 10000 dbars.
%
% r. schlitzer  (5/18/89)
spvol=eos80(p,0,35);

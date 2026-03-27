%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Script:	fixaxes.m                     Date: 8/26/93
% Author:       A. Macdonald
% Purpose:      Fix a set of axis tick marks to a reasonable number
%
% Inputs:  ticks - vector of postions of tic marks
%	   numtics - approximate number which we would like to have
%
% Outputs: nticks - vector of new postions of tic marks
%
% UPDATE: A.GANACHAUD, Aug 96:
%  scales the ticks into the 0:10 range before finding the new ticks
% to avoid ticks like 1234, but rather have 1200
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
function nticks = fixaxes(ticks,numtics)

	lax=length(ticks);	% how many do we have
	totrange=abs(ticks(lax)-ticks(1));
	expon=fix(log10(totrange));
	scale=fix(totrange*10^(-expon));
	%scale the ticks
    if scale
        ticks=ticks/scale;
    end

	have2want=lax/numtics;
	if(have2want >= 1)             % if we have enough or more than we need
	   step=round(have2want);
	   nticks=ticks(1:step:lax);
	elseif ( have2want <= .6 )
	   step=(ticks(lax) - ticks(1))/numtics;
	%   idx=1;
        %   while(step < 1 )
	%     idx=idx*10;
	%     step=step*10;
	%   end
	%   step=round(step)/idx;
	   
           nticks=ticks(1):step:ticks(lax);
	else			% don't change them if they're too far off
	   nticks=ticks;        % from what we want
	end

        %if(isempty(find(nticks==0)))
	%  nticks = [0 nticks];
	%end
	  
	%unscale the new ticks
	nticks=scale*nticks;


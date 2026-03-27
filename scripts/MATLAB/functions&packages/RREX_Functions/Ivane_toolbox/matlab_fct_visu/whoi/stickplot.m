function stickplot(tt,x,y,tlen,units,labels)
% STICKPLOT This function will produce a stickplot of vector data in 
%           chronological order. By calling STICKPLOT(DATE,VX,VY,TLEN), 
%           vectors with components (VX,VY) at times DATE are arranged in 
%           rows of length TLEN. Everything is scaled "nicely" and a 
%           scale-bar is drawn, with units given by an  (optional 5th 
%           parameter) UNITS string. 
%
%           if TLEN is a 2-element vector, then only that range of 
%           days is plotted.
%
%           If VX,VY are matrices, then column will be plotted above one
%           another (i.e. for time series at different depths). In this
%           case TLEN *must* be a 2-element vector. Finally, a 6th
%           parameter LABELS will be used to label each line.
% 

% This is a really kludgey piece of code - my contribution to
% global confusion! 
%              -RP 

% convert to column vectors
[N,M]=size(x);

if (min(N,M)==1),
   stackseries=0;
   if (nargin<6), M=0; end;
else
   stackseries=1;
   if (nargin<6),
    labels=[];
    if (M>1),
     for i=1:M,
        labels=[labels;int2str(i)];
     end;
    else
     labels=' ';
    end;
   end;
end;

tt=tt(:);
x=x(:);
y=y(:);

if (nargin<4),
  tlen=max(tt)-min(tt);
end;
if (nargin<5),
  units='units';
end;

if (max(size(tlen))==1),
   if (stackseries), error('TLEN must be a 2-element vector'); end;
   autoaxis=1;
   leftx=min(tt);
else
   autoaxis=0;
   leftx=tlen(1);
   tlen=tlen(2)-tlen(1);
end;



maxmag=max(max(sqrt(x.*x+y.*y)));
sc=tlen/maxmag/8;
wx=x*sc;            % scaled versions of the vectors
wy=y*sc;

% make this stuff stackable in rows of length tlen
if (autoaxis), xax=tlen+2*max(wx);
else           xax=tlen; end;

yax=xax;
if (autoaxis),
   yoff=yax/ceil( (tt( length(tt))-tt(1))/tlen);

   t=tt-floor( (tt-tt(1))/tlen)*tlen;
   yy=-yoff/2-floor( (tt-tt(1))/tlen)*yoff;
else
   if (stackseries),
      t=tt*ones(1,M);
      t=t(:);
      yoff=yax/M;
      yy=-yoff/2-ones(size(tt))*[0:M-1]*yoff;
      yy=yy(:);
   else
      yoff=yax;
      t=tt;
      yy=-yoff/2*ones(size(tt));
   end;
end;

xp=[ t  t+wx  NaN*ones(size(t)) ]';xp=xp(:);
yp=[ yy wy+yy NaN*ones(size(t)) ]';yp=yp(:);

% Now plot
%%clf reset;
plot(xp,yp,'-');

maxmag=10^round(log10(maxmag));
line([leftx leftx+maxmag*sc]+tlen/20,maxmag*[1 1]*sc-yoff/2,'linestyle','-');
text(leftx+maxmag*sc+tlen/20,maxmag*sc-yoff/2,[sprintf(' %g ',maxmag) units]);

% labels
for i=1:M
   text(t(1),-yoff/2-(i-1)*yoff,labels(i,:),'horizontal','right');
end;

set(gca,'Ytick',[]);
set(gca,'box','off');
set(gca,'Aspect',[NaN 1]);
%if (autoaxis), axis([min(tt)-max(wx) min(tt)+tlen+max(wx) -yax 0]);
%else axis([leftx leftx+tlen -yax 0]); end;
if (autoaxis), set(gca,'xlim',[min(tt)-max(wx) min(tt)+tlen+max(wx)]);
else set(gca,'xlim',[leftx leftx+tlen]); end;
% scale bar


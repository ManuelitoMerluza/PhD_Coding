%             [NAGWare Gateway Generator]
%
%Copyright (c) 1993-94 by the Numerical Algorithms Group Ltd 2.0 
%
%getsigpres
%
%nd                                    integer
%np                                    integer
%ns                                    integer
%pres (nd)                             real
%botdep (np)                           real
%imaxd (np)                            integer
%sigs (nd,np)                          real
%sigint (ns)                           real
%psig (np,ns)                          real
%
%[psig] = getsigpres(pres,botdep,imaxd,sigs,sigint)
%
%
 function [psig] = getsigpres(pres,botdep,imaxd,sigs,sigint)
%
%
%
%Call the MEX function
%
 iground = find(isnan(sigs));
 sigs(iground)=-ones(size(iground));
 nd=size(sigs,1);
 np=size(sigs,2);
 ns=length(sigint);
 if nd~=length(pres)
   error('nd~=length(pres)')
 end
 if np~=length(botdep) | np~=length(imaxd)
   error('np~=length(botdep) | np~=length(imaxd)')
 end
 
 [psig] = getsigpresg(nd,np,ns,pres,botdep,imaxd,sigs,...
 sigint);
%

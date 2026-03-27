      subroutine getsigprop(nd,np,dep,prop,botdep,nl,sigdep,sigprop)
c
c synopsis :
 
c  depths must be positive
c

c description : 
 
c   interpolates linearily the property prop to values along at
c   certain depths (following an isopycnal typically)
c   given by sigdep
c
c INPUTS
c   dep(nd)     :standard depths for the data
c   prop(nd,np)  :property to interpolate, for each pair
c   botdep(np)  :bottom depth for each pair
c
c   sigdep(np,nl):depth of the isopycnal for each pair, and
c                 for each isopycnal layer
c
c OUTPUTS (I/O)
c   sigprop(np,nl):interpolated property
c

c uses :

c side effects : if we are outside the data range 
c                sigprop is linearily extrapolated
c                if under bottom, sigprop is the one at the bottom.
c author : A.Ganachaud, Nov 96

c see also :

cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

      integer*4 nd,np,nl
      real*8    dep(nd),prop(nd,np),botdep(np)
      real*8    sigdep(np,nl),sigprop(np,nl)

c     indices: id = depth indices
c              ip = pair indices
c              il = sigma-layer indices


c     FOR EACH LAYER
      do il=1,nl
         
c        FOR EACH PAIR
         do ip=1,np
            xd=sigdep(ip,il)
c           FIND SURROUNDING STANDARD DEPTHS
            do id=1,nd
               if (xd.le.dep(id)) then
                  goto 100
               endif
            enddo
 100        continue
            if (id.eq.1) then   
c              sigma at the surface
               if (dep(2).lt.botdep(ip)) then
                  sigprop(ip,il)=prop(1,ip) + (xd-dep(1))*
     &                 (prop(2,ip)-prop(1,ip))/(dep(2)-dep(1))

               else 
c                 THERE IS ONLY ONE POINT
                  sigprop(ip,il)=prop(1,ip)
               endif

            elseif (dep(id).gt.botdep(ip)) then
               if (xd.gt.botdep(ip)) then 
c                 UNDERGROUND CASE
C                 THE SIGPROP TAKES THE EXTRAPOLATED VALUE 
C                 AT THE BOTTOM
                  xd=botdep(ip)
               endif
C              EXTRAPOLATION
               sigprop(ip,il)=prop(id-1,ip) + (xd-dep(id-1))*
     &              (prop(id-1,ip)-prop(id-2,ip))/(dep(id-1)-dep(id-2))

            else                
c              REGULAR INTERPOLATION
               sigprop(ip,il)=(prop(id-1,ip)*(dep(id)-xd) -
     &              prop(id,ip)*(dep(id-1)-xd))/(dep(id)-dep(id-1))
               
            endif

         enddo                  
c        LOOP ON EACH PAIR

      enddo                     
c     LOOP ON EACH LAYER

      return
      end

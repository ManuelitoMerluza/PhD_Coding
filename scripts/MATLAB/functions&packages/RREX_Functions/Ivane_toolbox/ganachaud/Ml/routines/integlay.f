      subroutine integlay(np,nl,nd,lidep,lipropint,Dep,ppropint,
     & sdist,Botdep,lprop)
C KEY:   integrate the property in each layer
C USAGE :
C 
C
C DESCRIPTION : 
C   integrate the property between layer interfaces, last
C   is the top to bottom one
C
C   Trapezoidal integration, takes the bottom triangle into account
C   Zero if less than 1m between layers
C   Zero triangle if less than 1m between the two bottom depths
C
C INPUT:
C   [np,nl]=size(lidep);
C   nd=size(Dep,1);
C
C   ip = pair indice
C   il = layer indice
C   id = std. depth indice
C   is = station indice
C
C   lidep(ip,il)     (m)  depth at layer interface
C   lipropint(ip,il)      property to integrate at layer interface
C   Dep(id,ip)       (m)  std. depth
C   ppropint(id,ip)       property to integrate, at std. depth
C   sdist(ip)        (km) distance between stations
C   Botdep(is)       (m)  bottom depth
C
C OUTPUT:
C
C   lprop(ip,il)     (m^2)*property : integrated property in layer 
C
C
C AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , April 97
C
C SIDE EFFECTS : Do not check if layer depth underneath bottom !
C                This allows elimination of triangles for 
C                model transports computation
C
C SEE ALSO : integ_lay.m
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C CALLER:
C CALLEE: dqtgs.f

      integer*4 MAXLAYER
      parameter (MAXLAYER=15000)

      integer*4 np,nl,nd
      real*8 lidep(np,nl),lipropint(np,nl)
      real*8 Dep(nd,np),ppropint(nd,np),sdist(np),Botdep(np+1)
      real*8 lprop(np,nl),xdz


      integer*4 il,ip,id,ltop,lbot,idep
      real*8    ldist,laydepth,linteg(MAXLAYER),zinteg(MAXLAYER)
 
C LOOP OVER LAYERS
      do il=1,nl
C        DEFINE INDICES FOR TOP/BOTTOM INTERFACE
         if(il.lt.nl) then
            ltop=il
            lbot=il+1
C        last is top to bottom
         else 
            ltop=1
            lbot=nl
         endif
  
C        LOOP OVER PAIRS
         do ip=1,np
            laydepth=lidep(ip,lbot)-lidep(ip,ltop)
            if (laydepth.lt.1.) then
               lprop(ip,il)=0
            else
               deep=max(Botdep(ip),Botdep(ip+1))
               shallow=min(Botdep(ip),Botdep(ip+1))
               if ((deep-shallow).lt.1) then
                  dratio=0.
               else
                  dratio=1e3*sdist(ip)/(deep-shallow)
               endif
      
C              IDEP WILL BE THE NUMBER OF DEPTH OVER WHICH THE INTEGRATION
C              IS MADE = 1 (top interface)+ 1(bot.int.) + number of std.
C              depths between top and bot interfaces 
               idep=1
      
C              SET INTEGRAND AT TOP OF LAYER
               if (lidep(ip,ltop).gt.shallow) then
                  ldist=dratio*(deep-lidep(ip,ltop))
               else
                  ldist=1e3*sdist(ip)
               endif
C              INTEGRAND
               linteg(idep)=ldist*lipropint(ip,ltop) 
               zinteg(idep)=lidep(ip,ltop)
      
C              SET INTEGRAND IN THE INTERMEDIATE STANDART DEPTHS
               do id=1,nd
                  if( (Dep(id,ip).gt.lidep(ip,ltop)).and.
     &                 (Dep(id,ip).lt.lidep(ip,lbot))) then
                     idep=idep+1
                     if (Dep(id,ip).gt.shallow) then
                        ldist=dratio*(deep-Dep(id,ip))
                     else
                        ldist=1e3*sdist(ip)
                     endif
                     linteg(idep)=ldist*ppropint(id,ip)
                     zinteg(idep)=Dep(id,ip)
                  endif
               enddo
      
C              SET INTEGRAND AT BOTTOM OF LAYER
               idep=idep+1
               if (lidep(ip,lbot).gt.shallow) then
                  ldist=dratio*(deep-lidep(ip,lbot))
               else
                  ldist=1e3*sdist(ip)
               endif
               linteg(idep)=ldist*lipropint(ip,lbot)
               zinteg(idep)=lidep(ip,lbot)
      
C              DO THE INTEGRATION FOR THIS LAYER, THIS PAIR
C               call dqtgs(zinteg,linteg,idep,lprop(ip,il),ier)
               lprop(ip,il)=0
               do i1=1,idep-1
                  xdz=zinteg(i1+1)-zinteg(i1)
                  if(xdz.lt.0) then
                     print*,'UNFORTUNATE UNMONOTONIC DEPTH'
                     print*,idep,zinteg(i1+1),zinteg(i1)
                     stop
                  endif
                  lprop(ip,il)=lprop(ip,il)+xdz*0.5*(linteg(i1)+
     &                 linteg(i1+1))
                  if(i1+1.gt.MAXLAYER) then
                     print*,'NOT ENOUGH MEMORY, INCREASE MAXLAYER !'
                     stop
                  endif
               enddo
            endif 
C           if laydepth.lt.1e-6
         enddo 
C        loop on ip
  
      enddo 
C     loop on nl
 
      return
      end

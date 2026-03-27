      subroutine polint1 (xa, ya, nd, x, ni, y, dy )      
      real*8      xa(*),ya(*),x(*), y(*),dy(*)
      integer     nd,ni

      do id=1,ni
         call polint(xa, ya, nd, x(id), y(id), dy(id))
      enddo
      return
      end

      subroutine alinterp1 (x, d, di, n, wind1, wind2, 
     &                            win1rng, win2rng, yi, ni )      
      real*8      d(*)
      real*8      di(*)
      real*8      wind1
      real*8      wind2
      real*8      win1rng
      real*8      win2rng
      real*8      x(*)
      real*8      yi(*)
      integer     n, ni
      
      do id=1,ni
         call alinterp(x, d, di(id), n, wind1, wind2, 
     &        win1rng, win2rng, yi(id))
      enddo
      return
      end

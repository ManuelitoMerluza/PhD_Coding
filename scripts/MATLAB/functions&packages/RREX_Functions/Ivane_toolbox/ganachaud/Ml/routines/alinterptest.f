      Program alinterptest

      real*8      x(10)
      real*8      d(10)
      real*8      wind1
      real*8      wind2
      real*8      win1rng
      real*8      win2rng
      real*8      di
      real*8      yi
      external alinterp
      real*8      alinterp

      do ii=1,10
         d(ii)=ii
         x(ii)=ii
      enddo
      yi=alinterp (x, d, di, 10, wind1, wind2, 
     &                            win1rng, win2rng )

      end

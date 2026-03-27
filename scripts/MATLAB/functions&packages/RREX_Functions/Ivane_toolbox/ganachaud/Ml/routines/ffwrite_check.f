      character a*6,b*11
      integer*2   ii(8)
      integer     jj(8)
      integer     kk(9)
      real        x(9)
      real*8      y(2,9)

      open(10,file='temp.bin',form='unformatted',status='read')
      read(10) a
      read(10) b
      read(10) ii
      read(10) jj
      read(10) kk
      read(10) x
      read(10) y
       print*, a 
      print*, b
      print*, ii
      print*, jj
      print*, kk
      print*, x 
      print*, (y(1,j),j=1,9)
      print*, (y(2,j),j=1,9)
      close(10)
      end

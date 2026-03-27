      character a*6,b*11
      integer*2   ii(8)
      integer     jj(8)
      integer     kk(9)
      real        x(9)
      real*8        y(2,9)
      do i=1,8
         ii(i)=i
         jj(i)=-i
      enddo
      do j = 1,9
         kk(j)=2*j
         x(j)=100.*j
         y(1,j)=j
         y(2,j)=-j
      enddo
      a="always"
      b="looking sky"
      open(10,file='temp.bin',form='unformatted',status='write')
      write(10) a
      write(10) b
      write(10) ii
      write(10) jj
      write(10) kk
      write(10) x
      write(10) y

      print*, a 
      print*, b
      print*, ii
      print*, jj
      print*, kk
      print*, x 
      print*, y
      close(10)
      end

      subroutine cube(x,y,idim)
      dimension x(idim),y(idim)

      do i=1,idim
         y(i)=x(i)**3
      enddo
      return
      end

        subroutine alinterp (x, d, di, n, wind1, wind2, 
     &                            win1rng, win2rng, yi )

C *********************************************************************
C
C Function: alinterp
C Date: 6/18/92
C Author: Alison Macdonald
C Update: This subroutine is the equivalent to the old routine XNODC
C         the only substantial change is the that the range over which
C         the windows are used is now used specified. The old defaults
C         were wind1 0-400, wind2 400-1200.
C
C Description: Performs an Aitken-Lagrange Interpolation of the
C              values in x at the depths in d to the depth di if:
C                the distance between the 2 observed values which
C                bracket the standard depth are:
C                      < wind1 for di < win1rng
C                      < wind2 for win1rngm < di < win2rng
C             Uses a linear interpolation if only two point
C
C *********************************************************************

C Inputs:
C     d       - the depths of the data values
C     di      - the depth to which to interpolate
C     n       - total number of data values
C     wind1   - the allowed distance between the data points used
C               in the interpolation when depth < win1rng
C     wind2   - the allowed distance between the data points used
C               in the interpolation when win1rng< depth < win2rng
C     win1rng - the range over which wind1 is effective
C     win2rng - the range over which wind2 is effective
C     x       - the data values

        integer*4   n

        real*8      d(*)
        real*8      di
        real*8      wind1
        real*8      wind2
        real*8      win1rng
        real*8      win2rng
        real*8      x(*)
        real*8      yi

C Outputs: yi
        
C I/O: none

C CALLEE: al_index

C Include Files: none

C Fortran Parameters:
        real*8      FLAG
        parameter   (FLAG=-999.0)

C Local_Variables:
C     i        - alindex of the last depth < di
C     alindex    - function which returns the first non-flagged value
C                in a vector in the specified specified direction
C     j        - current depth alindex
C     rtname   - name of the current routine

      integer*4   i, j
      integer*4   al_index
      integer*4   i1, i2, i3

      logical*4   in_range
      logical*4   linear

      real*8      dp200
      real*8      dp400
      real*8      di1, di2, di3
      real*8      d12, d13, d23
      real*8      dx

C Specification:
C     Assume the worst to begin
      yi=FLAG
      linear = .true.

C     But assume are values are within the window range
      in_range = .true.

C     Find i=al_index of last depth < di
      i=0
      do j=1,n
         if(di.ge.d(j)) i=i+1
      enddo

      if (i .ne. 0) then
        if(di.eq.d(i)) then
           yi=x(i)
        else
C          Get the nearest good values above and below i
C           -1 search up,  +1 search down the water column
           i1=al_index(i,1,-1,x)
           i2=al_index(i+1,n,1,x)
           if (d(i2) .eq. d(i1)) then
              i2=al_index(i2+1,n,1,x)
           endif

C          If we can find two points, look for a third
           if (i1.ne.0.and.i2.ne.0) then
C             LOOK UP
              i31=al_index(i1-1,1,-1,x)
              if (d(i31) .eq. d(i1)) then
                 i31=al_index(i31-1,1,-1,x)
              endif
C             LOOK DOWN
              i32=al_index(i2+1,n,1,x)
              if (d(i32) .eq. d(i2)) then
                 i32=al_index(i32+1,n,1,x)
              endif
C             CHOOSES THE CLOSEST THIRD POINT
              if((i31.ne.0).and.(i32.ne.0)) then
                 if(abs(d(i32)-di).lt.(abs(si-d(i31)))) then
                    i3=i32
                 else
                    i3=i31
                 endif
              elseif(i31.ne.0) then
                 i3=i31
              else
                 i3=i32
              endif

C             Now check that i1 and i2 are within the desired window
              dp200=d(i1)+wind1
              dp400=d(i1)+wind2

              if(d(i1).le.win1rng .and. d(i2).gt.dp200)then
                 in_range = .false.
              endif
              if(d(i1).gt.win1rng .and. d(i1).le.win2rng .and.
     &           d(i2).gt.dp400)then
                 in_range = .false.
              endif
              
              if ( in_range )then

C                We have three points, try the Al interpolation
                 if ( i3 .ne. 0 )then
                    di2=di-d(i2)
                    di3=di-d(i3)
                    d12=d(i1)-d(i2)
                    d13=d(i1)-d(i3)
                    di1=di-d(i1)
                    d23=d(i2)-d(i3)

                    yi = x(i1) * di2 * di3 / (d12 * d13) +
     &                         x(i2) * di1 * di3 / (-d12 * d23) +
     &                         x(i3) * di1 * di2 / (d13 * d23)

C                   Is the interpolated value between the bracketing
C                   values (+/-dx), if not, do a linear interpol. instead
                    dx=0.
C                   abs(x(i1)-x(i2))/2.

                    if((yi.gt.(x(i1)-dx) .and. yi.lt.(x(i2)+dx)) .or.
     &                 (yi.gt.(x(i2)-dx) .and. yi.lt.(x(i1)+dx)))then
c                        print *,'false ',yi,x(i1),x(i2)
                        linear = .false.
                    else
c                        print *,'true ',yi,x(i1),x(i2)
                    endif
                 endif

                 if (  linear )then
                    yi =  x(i1)+ 
     &                         (x(i2)-x(i1))*(di-d(i1))/(d(i2)-d(i1))
                 endif
              endif
           endif
        endif
      endif

      return
      end

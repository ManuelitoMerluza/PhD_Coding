        subroutine rd_std_hdr_m( hdrname, ncasts_in_file,
     1     icast,xlat,xlong,botd,kt,maxd)

C *********************************************************************
C
C Subroutine: RD_STD_HDR
C Date: 10/3/95
C Author: D. Spiegel (based on A. MacDonald)
C Update: does *not* use common, does *not* use kd
C
C Description: read the data in a standard depth header file 
C
C *********************************************************************

C Inputs:
C     hdrname        - path and name of the header file
C     ncasts_in_file - number of casts described in the file

      character*(*)     hdrname
      integer*4         ncasts_in_file

C I/O:

C Following taken from 'stdhd.cmn'
C Variables:
C       ncasts_in_file - fortran parameter, the size of the arrays
C       ncasts     - number of casts in the file
C       kd         - current kt
C       iship      - the ship number associated with the cast
C       xlat       - latitude of the cast  ( degrees )
C       xlong      - longitude of the cast ( degrees )
C       botd       - bottom depth of the cast ( meters or db )
C       kt         - index to order expected to be used
C       xdep       - distance to lowest observation in the cast
C       nobs       - number of observations in the cast
C       maxd       - maximum possible number of standard depths
C                    for the cast based on xdepth

       integer*4 maxhdcasts
       parameter (maxhdcasts=1800)

       integer*4 kd
       integer*4 ncasts

       integer*4 iship(maxhdcasts)
       integer*4 icast(ncasts_in_file)
       integer*4 kt(ncasts_in_file)
       integer*4 nobs(maxhdcasts)
       integer*4 maxd(ncasts_in_file)

       real*4 botd(ncasts_in_file)
       real*4 xdep(maxhdcasts)
       real*4 xlat(ncasts_in_file)
       real*4 xlong(ncasts_in_file)

C Fortran Parameters:

C Local_Variables:
C     hd_lu      - logical unit to the data file
C     i          - record element index
C     reclen     - logical record length of the header file in bytes
C     rtname     - name of current routine
C     wrbuff     - message buffer

      character*36    rtname
      character*256   wrbuff
      character*100   ibuf      
c                     used if reading as in geovel

      integer*4       hd_lu
      integer*4       i
      integer*4       reclen

      data  rtname /'rd_std_hdr'/

C Specification:
      reclen = ncasts_in_file * 4

      ncasts = ncasts_in_file
      if ( ncasts .gt. ncasts_in_file ) then
         write ( wrbuff, 1000 ) ncasts, ncasts_in_file
         call wrerr ( rtname, 101, wrbuff )
      endif

C  open the header file , die if anything is wrong
C  open as in geovel.f:
c      call getlu(hd_lu)
c      open (unit=hd_lu,form='unformatted',access='direct',
c     &      recl=rec_len,file=ibuf)
C  open as in rd_std_hdr.f:
      call opfile(hdrname, 'r', 'b', reclen, hd_lu)

C     read ( unit=hd_lu, rec=1 ) (iship(i),i=1,ncasts)
      read ( unit=hd_lu, rec=2 ) (icast(i),i=1,ncasts)
      read ( unit=hd_lu, rec=3 ) (xlat(i),i=1,ncasts)
      read ( unit=hd_lu, rec=4 ) (xlong(i),i=1,ncasts)
      read ( unit=hd_lu, rec=5 ) (botd(i),i=1,ncasts)
      read ( unit=hd_lu, rec=6 ) (kt(i),i=1,ncasts)
C     read ( unit=hd_lu, rec=7 ) (xdep(i),i=1,ncasts)
C     read ( unit=hd_lu, rec=8 ) (nobs(i),i=1,ncasts)
      read ( unit=hd_lu, rec=9 ) (maxd(i),i=1,ncasts)

      close (hd_lu)

1000  format( ' Error: array size too small, there are:',i,
     &        ' casts but can only accommodate: ',i)

      return
      end

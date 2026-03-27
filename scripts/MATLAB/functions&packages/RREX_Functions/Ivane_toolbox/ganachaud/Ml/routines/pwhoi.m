%pwhoi : print on whoi printer
print -deps pptempfile.eps;
!lpr -Pwhoi pptempfile.eps;
!rm pptempfile.eps;
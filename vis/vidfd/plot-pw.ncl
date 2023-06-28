load "utils.ncl"
;----------------------------------------------------------------------
 info = readinfo("datainfo.txt")

 plottype = info(0)
 dirname = info(1)
 finame = info(2)
 foname = info(3)
 imgname = info(4)
 title = info(5)

 fi = dirname+finame
 fo = dirname+foname

;print("fi = " + fi)
;print("fo = " + fo)

 f = addfile(fi, "r")

 pw = f->PWAT_P0_L200_GLL0(:,:)

 plot_pw(pw, title, plottype, imgname)


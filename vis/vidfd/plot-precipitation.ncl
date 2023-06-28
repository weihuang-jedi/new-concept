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

 prate = f->PRATE_P0_L1_GLL0(:,:)  ; m/s, (level,lat,lon)
 prate = 10000.0*prate
 prate@units = "0.1g m-2 s-1"

 plot_precipitation(prate, title, plottype, imgname)


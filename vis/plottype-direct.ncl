load "categorical.ncl"

;************************************************
undef("gen_plot")
procedure gen_plot(f:file, plottype:string, imgstr:string, titlestr:string)
begin
  type = f->cate(:, :, :)
  alt = type&alt

;----------------------------------------------------------------------
  do k = 0, dimsizes(alt)-1, 10
    hgt = alt(k)
    imgname = "gfs_" + imgstr + "_at_" + tostring(toint(hgt)) + "meter"
    title = "gfs " + titlestr + " Type at " + tostring(toint(hgt)) + "meter"
    pvar = tofloat(type(k,:,:))
    plot_type(pvar, plottype, imgname, title, hgt)
  end do
end

;************************************************
;plottype = "png"
;plottype = "x11"

;diri = "/work2/noaa/gsienkf/weihuang/gfs/data/dec2021/"
;fili = "type_202112.nc"
;imgstr = "dec_2021_grad_type"
;titlestr = "Dec 2021"

 info = readinfo("controlplot.txt")

 print(info)

 plottype = info(0)
 diri = info(1)
 fili = info(2)
 imgstr = info(3)
 titlestr = info(4)

 f = addfile(diri+fili,"r")

 gen_plot(f, plottype, imgstr, titlestr)


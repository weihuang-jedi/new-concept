load "categorical.ncl"

;************************************************
undef("gen_plot")
procedure gen_plot(f:file, plottype:string, imgstr:string, titlestr:string)
begin
  cate = f->cate(:, :, :)
  alt = cate&alt

;----------------------------------------------------------------------
  do k = 0, dimsizes(alt)-1, 10
    hgt = alt(k)
    imgname = "gfs_" + imgstr + "_at_" + tostring(toint(hgt)) + "meter"
    title = "gfs " + titlestr + " Catalog at " + tostring(toint(hgt)) + "meter"
    pvar = tofloat(cate(k,:,:))
    plot_categorical(pvar, plottype, imgname, title, hgt)
  end do
end

;************************************************
;plottype = "png"
 plottype = "x11"

;diri = "/work2/noaa/gsienkf/weihuang/gfs/data/dec2021/"
;fili = "grad_cate_202112.nc"
;diri = "/work2/noaa/gsienkf/weihuang/gfs/data/jan2022/"
;fili = "grad_cate_20220116_00.nc"
;diri = "/work2/noaa/gsienkf/weihuang/gfs/data/annual/"
;fili = "p_grad_grad_annual_grad_cate.nc"
 diri = "/work2/noaa/gsienkf/weihuang/gfs/data/dec2022/"
 fili = "grad_cate_20221201_00.nc"
 imgstr = "dec_2022_grad_cate"
 titlestr = "Dec 2022"

;info = readinfo("datainfo.txt")

;plottype = info(0)
;diri = info(1)
;fili = info(2)
;imgstr = info(3)
;titlestr = info(4)

 f = addfile(diri+fili,"r")

 gen_plot(f, plottype, imgstr, titlestr)


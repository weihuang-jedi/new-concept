load "categorical.ncl"

;************************************************
undef("gen_plot")
procedure gen_plot(f:file, plottype:string)
begin
  cate = f->cate(:, :, :)
  alt = cate&alt

;----------------------------------------------------------------------
  do k = 0, dimsizes(alt)-1, 10
    hgt = alt(k)
   ;imgname = "gfs_grad_catelog_of_dec_2021_at_" + tostring(toint(hgt)) + "meter"
   ;title = "gfs Atmospheric Catalog of DEC 2021 at " + tostring(toint(hgt)) + "meter"
    imgname = "gfs_grad_catelog_of_16_jan_2022_00Z_at_" + tostring(toint(hgt)) + "meter"
    title = "gfs Atmospheric Catalog of JAN 16, 2022 00Z at " + tostring(toint(hgt)) + "meter"
    pvar = tofloat(cate(k,:,:))
    plot_categorical(pvar, plottype, imgname, title, hgt)
  end do
end

;************************************************
 plottype = "png"
;plottype = "x11"

;diri = "/work2/noaa/gsienkf/weihuang/gfs/data/dec2021/"
;fili = "grad_cate_202112.nc"
 diri = "/work2/noaa/gsienkf/weihuang/gfs/data/jan2022/"
 fili = "grad_cate_20220116_00.nc"
 f = addfile(diri+fili,"r")

 gen_plot(f, plottype)


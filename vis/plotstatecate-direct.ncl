load "categorical.ncl"

;************************************************
undef("gen_plot")
procedure gen_plot(f:file, plottype:string)
begin
  cate = f->cate(:, :, :)
  alt = cate&alt

;----------------------------------------------------------------------
  do k = 0, dimsizes(alt)-1, 40
    hgt = alt(k)
    imgname = "gfs_state_catelog_of_dec_2021_at_" + tostring(toint(hgt)) + "meter"
    title = "gfs Atmospheric Catalog of DEC 2021 at " + tostring(toint(hgt)) + "meter"
    pvar = tofloat(cate(k,:,:))
    plot_categorical(pvar, plottype, imgname, title, hgt)
  end do
end

;************************************************
 plottype = "png"
;plottype = "x11"

 diri = "/work2/noaa/gsienkf/weihuang/gfs/data/dec2021/"
 fili = "state_cate_202112.nc"
 f = addfile(diri+fili,"r")

 gen_plot(f, plottype)


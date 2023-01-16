load "categorical.ncl"

;************************************************
undef("gen_plot")
procedure gen_plot(f:file, plottype:string)
begin
  cate = f->cate(:, :, :)
  alt = cate&alt

;----------------------------------------------------------------------
  do k = 0, dimsizes(alt)-1, 40
    hgt = tofloat(alt(k))
    imgname = "era5_grad_catelog_of_dec_2021_at_" + tostring(toint(hgt)) + "meter"
    title = "era5 Atmospheric Catalog of DEC 2021 at " + tostring(toint(hgt)) + "meter"
    pvar = tofloat(cate(k,:,:))
    plot_categorical(pvar, plottype, imgname, title, hgt)
  end do
end

;************************************************
;plottype = "png"
 plottype = "x11"

;diri = "/work2/noaa/gsienkf/weihuang/era5/data/"
;fili = "grad_cate_202112.nc"
 diri = "/work2/noaa/gsienkf/weihuang/era5/daily-data/"
 fili = "grad_cate_2022121500.nc"
 f = addfile(diri+fili,"r")

 gen_plot(f, plottype)


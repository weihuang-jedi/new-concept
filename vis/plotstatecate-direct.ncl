load "categorical.ncl"

;************************************************
undef("gen_plot")
procedure gen_plot(fon:string, plottype:string)
begin
  f = addfile(fon, "r")
  alt = f->alt(:)
  cate = f->cate

  print("Start plotting")
;----------------------------------------------------------------------
  do k = 0, dimsizes(alt)-1, 40
    hgt = tofloat(alt(k))
    imgname = "era5_state_catelog_of_2021121600_at_" + tostring(toint(hgt)) + "meter"
    title = "era5 Atmospheric Catalog of 00Z DEC 16, 2021 at " + tostring(toint(hgt)) + "meter"
    print("Title: " + title)
    pvar = tofloat(cate(k,:,:))
    plot_categorical(pvar, plottype, imgname, title, hgt)
  end do
end

;************************************************
 plottype = "png"
;plottype = "x11"

 diri = "/work2/noaa/gsienkf/weihuang/era5/data/"
 fon = diri+"state_cate_2021121600.nc"

 gen_plot(fon, plottype)


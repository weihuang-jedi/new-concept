load "categorical.ncl"

;************************************************
undef("gen_plot")
procedure gen_plot(plottype:string, flnm:string)
begin
  f = addfile(flnm, "r")

  pvar = f->cate(:,:,:)
  pvar@long_name = "Catelog"

  dims = dimsizes(pvar)
  nalt = dims(0)
  alt = pvar&alt

  do level = 20, nalt, 20
    print("Plot level: " + tostring(level))
    hgt = toint(alt(level))
    var = pvar(level, :, :)
    title = "State catelog of 00Z Jan 16, 2022 at " + tostring(hgt) + "meter"
    imgname = "state_catelog_2022011600_at_" + tostring(hgt) + "meter"
    plot_categorical(var, plottype, imgname, title, hgt)
  end do
end

;************************************************
;plottype = "png"
 plottype = "x11"

 diri = "/work2/noaa/gsienkf/weihuang/gfs/data/jan2022/"
 fon = diri + "state_cate_20220116_0000.nc"

 gen_plot(plottype, fon)


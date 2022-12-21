load "categorical.ncl"

;************************************************
undef("gen_plot")
procedure gen_plot(f:file, plottype:string)
begin
  cate = f->cate(:, :, :)
  P = f->P(:, :, :)

  imgname = "Zonal Averaged Atmospheric Catalog"
  
;----------------------------------------------------------------------
 dimP = dimsizes(P)
 nalt = dimP(0)
 nlat = dimP(1)
 nlon = dimP(2)
 lev = new((/nalt/), float, -1.0e32)

 do n=0, nalt-1
    pm = avg(P(n,:,:))
    lev(n) = pm
 end do

 lev!0 = "lev" 
 lev&lev = lev
 lev@units = "Pa"
 lev@long_name = "Pressure"

 cate!0 = "lev" 
 cate!1 = "lat" 
 cate!2 = "lon" 
 cate&lev = lev
 cate&lat = P&lat
 cate&lon = P&lon
 cate@long_name = "Atmospheric Catalog"

 plot_cate_section(cate, plottype, imgname)
end

;************************************************
;plottype = "png"
 plottype = "x11"

 dir = "/work2/noaa/gsienkf/weihuang/gfs/vis/"
;fil = "gradCate.nc"
 fil = "stateCate.nc"
 f = addfile(dir+fil,"r")

 gen_plot(f, plottype)


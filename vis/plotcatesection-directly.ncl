load "categorical.ncl"

;************************************************
undef("gen_plot")
procedure gen_plot(f:file, plottype:string)
begin
  cate = f->cate(:, :, :)
  P = f->P(:, :, :)

  imgname = "gfs Zonal Averaged Atmospheric Catalog"
  title = "gfs_Zonal_Averaged_Atmospheric_Catalog"
  
;----------------------------------------------------------------------
 dimP = dimsizes(P)
 nalt = dimP(0)
 nlat = dimP(1)
 nlon = dimP(2)
 lev = new((/nalt/), float, -1.0e32)

 print(dimP)

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

 printVarSummary(cate)

 plot_avg_cate_section(cate, plottype, imgname, title)

;do i = 0, 350, 60
;  lon = i/2
;  imgname = "gfs Zonal Averaged Atmospheric Catalog at Lon " + tostring(lon)
;  title = "gfs_Zonal_Averaged_Atmospheric_Catalog_at_Lon_" + tostring(lon)
;  plot_cate_section(cate, plottype, lon, imgname, title)
;end do

;************************************************
;plottype = "png"
 plottype = "x11"

 diri = "/work2/noaa/gsienkf/weihuang/gfs/data/dec2021/"
 fili = "grad_cate_202112.nc"
 f = addfile(diri+fili, "r")

 gen_plot(f, plottype)


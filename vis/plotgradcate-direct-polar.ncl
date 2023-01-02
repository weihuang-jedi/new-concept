load "categorical.ncl"

;************************************************
undef("gen_plot")
procedure gen_plot(f:file, plottype:string, hemisphere:string)
begin
  cate = (/f->cate(:, :, :)/)
  alt = (/f->alt(:)/)
  lat = (/f->lat(:)/)
  lon = (/f->lon(:)/)

  alt@units = "upward"
  alt!0 = "alt"
  alt&alt = alt
  lat@units = "degrees_north"
  lat!0 = "lat"
  lat&lat = lat
  lon@units = "degrees_east"
  lon!0 = "lon"
  lon&lon = lon

  cate!0 = "alt"
  cate!1 = "lat"
  cate!2 = "lon"
  cate&alt = alt
  cate&lat = lat
  cate&lon = lon
  cate@long_name = "Atmospheric Catalog"
  cate@units = "None"
  cate@coordinates = "alt lat lon"

 ;printVarSummary(alt)
 ;printVarSummary(lat)
 ;printVarSummary(lon)
 ;printVarSummary(cate)

;----------------------------------------------------------------------
  do k = 0, dimsizes(alt)-1, 10
    hgt = alt(k)
   ;imgname = "gfs_grad_catelog_of_dec_2021_at_" + tostring(toint(hgt)) + "meter_" + hemisphere
   ;title = "gfs Atmospheric Catalog of DEC 2021 at " + tostring(toint(hgt)) + "meter, " + hemisphere
    imgname = "gfs_grad_catelog_of_16_jan_2022_00Z_at" + tostring(toint(hgt)) + "meter_" + hemisphere
    title = "gfs Atmospheric Catalog of JAN 16, 2022 00Z at " + tostring(toint(hgt)) + "meter, " + hemisphere
    pvar = tofloat(cate(k,:,:))
    copy_VarCoords(cate(k,:,:), pvar)
    plot_categorical_polar(pvar, plottype, imgname, title, hgt, hemisphere)
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

 gen_plot(f, plottype, "NH")
 gen_plot(f, plottype, "SH")


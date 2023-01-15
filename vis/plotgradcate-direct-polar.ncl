load "categorical.ncl"

;---------------------------------------------------------------------
undef("readinfo")
function readinfo(filename:string)
begin
 ;Read data into a one-dimensional string array of unknown length:
  filename = "datainfo.txt"
  info     = asciiread(filename,-1,"string")
 ;nlines   = dimsizes(info)

 ;print("The info in '" + filename + "' has " + nlines + " lines.")
 ;print("This includes the title and the author.")
 ;print(info)    ; Print the lines

  return info
end

;---------------------------------------------------------------------
undef("gen_plot")
procedure gen_plot(f:file, plottype:string, imgstr:string, \
                   titlestr:string, hemisphere:string)
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
    imgname = "gfs_" + imgstr + "_at_" + tostring(toint(hgt)) + "meter_" + hemisphere
    title = "gfs " + titlestr + " Catalog at " + tostring(toint(hgt)) + "meter, " + hemisphere
    pvar = tofloat(cate(k,:,:))
    copy_VarCoords(cate(k,:,:), pvar)
    plot_categorical_polar(pvar, plottype, imgname, title, hgt, hemisphere)
  end do
end

;---------------------------------------------------------------------
 plottype = "png"
;plottype = "x11"

;diri = "/work2/noaa/gsienkf/weihuang/gfs/data/dec2021/"
;fili = "grad_cate_202112.nc"
 diri = "/work2/noaa/gsienkf/weihuang/gfs/data/jan2022/"
 fili = "grad_cate_20220116_00.nc"

 info = readinfo("datainfo.txt")

 plottype = info(0)
 diri = info(1)
 fili = info(2)
 imgstr = info(3)
 titlestr = info(4)

 f = addfile(diri+fili,"r")

 gen_plot(f, plottype, imgstr, titlestr, "NH")
 gen_plot(f, plottype, imgstr, titlestr, "SH")


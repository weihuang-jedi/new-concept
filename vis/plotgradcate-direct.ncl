load "categorical.ncl"

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
 diri = "/work2/noaa/gsienkf/weihuang/gfs/data/dec2022/"
 fili = "grad_gfs_4_20221216_0000_000.nc"

 info = readinfo("datainfo.txt")

 plottype = info(0)
 diri = info(1)
 fili = info(2)
 imgstr = info(3)
 titlestr = info(4)

 f = addfile(diri+fili,"r")

 gen_plot(f, plottype, imgstr, titlestr)


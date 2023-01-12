load "categorical.ncl"

;************************************************
undef("gen_plot")
procedure gen_plot(f:file, fb:file, plottype:string, flnm:string)
begin
  print("Read data")
  T = f->T(:, :, :)
  P = f->P(:, :, :)
  Rho = P / (287.0*T)
  alt = f->alt(:)

  copy_VarCoords(T, Rho)

  Tb = fb->T(:, :, :)
  Pb = fb->P(:, :, :)
  Rhob = Pb / (287.0*Tb)

  T@long_name = "T"                     ; short name for plot labeling clarity

 ;printVarSummary(T)                    ; (94,192) gaussian [S->N]
 ;printMinMax(T,True)
 ;print("")

;----------------------------------------------------------------------
  print("get delt")
  dt = T - Tb
  dp = P - Pb
  dr = Rho - Rhob

  dtdr = dt*dr
  dtdp = dt*dp

  dimT = dimsizes(T)
  nalt = dimT(0)
  nlat = dimT(1)
  mlon = dimT(2)

  opt  = new(dimT, integer, -9999)
  opt1 = new(dimT, integer, -9999)
  opt2 = new(dimT, integer, -9999)
  opt3 = new(dimT, integer, -9999)
  cate = new(dimT, integer, -9999)

  opt3 = 0
  cate = 0

;----------------------------------------------------------------------
  print("Compute cate 1")
 ;Cate 1:  dtdr >= 0, dp >= 0          Thermal-Dynamic  Warm High Dense
  opt1 = where(dtdr .ge. 0.0, 1, 0)
  opt2 = where(dp .ge. 0.0, 1, 0)
  opt = opt1*opt2
  cate = where(opt .gt. 0, 1, cate)

;----------------------------------------------------------------------
  print("Compute cate 2")
 ;Cate 2:  dtdr >= 0, dp < 0           Thermal-Dynamic  Cold Low Thin
  opt2 = where(dp .lt. 0.0, 1, 0)
  opt = opt1*opt2
  cate = where(opt .gt. 0, 2, cate)

;----------------------------------------------------------------------
  print("Compute cate 3")
 ;Cate 3:  dtdr < 0, dtdp >= 0, dp >= 0   Thermal        Warm High thin
  opt1 = where(dtdr .lt. 0.0, 1, 0)
  opt2 = where(dtdp .ge. 0.0, 1, 0)
  opt3 = where(dp .ge. 0.0, 1, 0)
  opt = opt1*opt2*opt3
  cate = where(opt .gt. 0, 3, cate)

;----------------------------------------------------------------------
  print("Compute cate 4")
 ;Cate 4:  dtdr < 0, dtdp < 0, dp < 0   Thermal        Cold Low Dense
  opt3 = where(dp .lt. 0.0, 1, 0)
  opt = opt1*opt2*opt3
  cate = where(opt .gt. 0, 4, cate)

;----------------------------------------------------------------------
  print("Compute cate 5")
 ;Cate 5:  dtdr < 0, dtdp < 0, dp >= 0     Dynamic     Cold High Dense
  opt2 = where(dtdp .lt. 0.0, 1, 0)
  opt3 = where(dp .ge. 0.0, 1, 0)
  opt = opt1*opt2*opt3
  cate = where(opt .gt. 0, 5, cate)

;----------------------------------------------------------------------
  print("Compute cate 6")
 ;Cate 6:  dtdr < 0, dtdp < 0, dp < 0    Dynamic     Wamr Low  Thin
  opt3 = where(dp .gt. 0.0, 1, 0)
  opt = opt1*opt2*opt3
  cate = where(opt .gt. 0, 6, cate)
;----------------------------------------------------------------------
  pvar = tofloat(cate)

  copy_VarCoords(T, pvar)
  pvar@long_name = "Catelog"

  print("Write cate")
  write2file(T, P, pvar, flnm)
 
  do level = 20, nalt, 20
    print("Plot level: " + tostring(level))
    hgt = toint(alt(level))
    var = pvar(level, :, :)
    title = "State catelog at " + tostring(hgt) + "meter"
    imgname = "state_catelog_at_" + tostring(hgt) + "meter"
    plot_categorical(var, plottype, imgname, title, hgt)
  end do
end

;************************************************
;plottype = "png"
 plottype = "x11"

;dirb = "/work2/noaa/gsienkf/weihuang/gfs/data/annual/"
;filb = "hl_annual_mean_gfs_4_2022.nc"
 dirb = "/work2/noaa/gsienkf/weihuang/gfs/data/jan2022/"
 filb = "hl_monthly_mean_gfs_4_202201.nc"
 fb = addfile(dirb+filb,"r")

 diri = "/work2/noaa/gsienkf/weihuang/gfs/data/jan2022/"
 fili = "hl_gfs_4_20220116_0000_000.nc"
;fili = "hl_monthly_mean_gfs_4_202201.nc"
 f = addfile(diri+fili,"r")

 fon = diri + "state_cate_20220116_0000.nc"

 gen_plot(f, fb, plottype, fon)


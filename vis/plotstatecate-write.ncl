load "categorical.ncl"

;----------------------------------------------------------------------
undef("compute_state_catalog")
function compute_state_catalog(f:file, fb:file, flnm:string)
begin
  print("Read T")
  v := f->t(15, :, :, :)
  T = v(:, ::2, ::2)
  print("Read P")
  v := f->p(15, :, :, :)
  P = v(:, ::2, ::2)
  Rho = P / (287.0*T)

  print("Read Tb")
  v := fb->t(0, :, :, :)
  Tb = v(:, ::2, ::2)
  print("Read Pb")
  v := fb->p(0, :, :, :)
  Pb = v(:, ::2, ::2)
  Rhob = Pb / (287.0*Tb)

  delete(v)

 ;printVarSummary(T)
 ;printVarSummary(P)

  T@long_name = "T"
  copy_VarCoords(T, Rho)
  
;----------------------------------------------------------------------
  alt = T&alt
  lat = T&lat
  lon = T&lon

  dimT = dimsizes(T)
  nalt = dimT(0)
  nlat = dimT(1)
  nlon = dimT(2)

  lev = new((/nalt/), double, -1.0e32)

  print("Calculating delt T, P, Tho")
  dt = T - Tb
  dp = P - Pb
  dr = Rho - Rhob

  do n=0, nalt-1
    pm = avg(P(n,:,:))
    lev(n) = pm
  end do

 ;delete([/T, P, Rho, Tb, Pb, Rhob/])
  delete([/Rho, Tb, Pb, Rhob/])

  print("Calculating Catalog")
  dtdr = dt*dr
  dtdp = dt*dp

  opt  = new(dimT, integer, -9999)
  opt1 = new(dimT, integer, -9999)
  opt2 = new(dimT, integer, -9999)
  opt3 = new(dimT, integer, -9999)
  cate = new(dimT, integer, -9999)

  opt3 = 0
  cate = 0

;----------------------------------------------------------------------
  print("Calculating Catalog 1")
 ;Cate 1:  dtdr >= 0, dp >= 0          Thermal-Dynamic  Warm High Dense
  opt1 = where(dtdr .ge. 0.0, 1, 0)
  opt2 = where(dp .ge. 0.0, 1, 0)
  opt = opt1*opt2
  cate = where(opt .gt. 0, 1, 0)

;----------------------------------------------------------------------
  print("Calculating Catalog 2")
 ;Cate 2:  dtdr >= 0, dp < 0           Thermal-Dynamic  Cold Low Thin
  opt2 = where(dp .lt. 0.0, 1, 0)
  opt = opt1*opt2
  cate = where(opt .gt. 0, 2, cate)

;----------------------------------------------------------------------
  print("Calculating Catalog 3")
 ;Cate 3:  dtdr < 0, dtdp >= 0, dp >= 0   Thermal        Warm High thin
  opt1 = where(dtdr .lt. 0.0, 1, 0)
  opt2 = where(dtdp .ge. 0.0, 1, 0)
  opt3 = where(dp .ge. 0.0, 1, 0)
  opt = opt1*opt2*opt3
  cate = where(opt .gt. 0, 3, cate)

;----------------------------------------------------------------------
  print("Calculating Catalog 4")
 ;Cate 4:  dtdr < 0, dtdp >= 0, dp < 0   Thermal        Cold Low Dense
  opt3 = where(dp .lt. 0.0, 1, 0)
  opt = opt1*opt2*opt3
  cate = where(opt .gt. 0, 4, cate)

;----------------------------------------------------------------------
  print("Calculating Catalog 5")
 ;Cate 5:  dtdr < 0, dtdp < 0, dp >= 0     Dynamic     Cold High Dense
  opt2 = where(dtdp .lt. 0.0, 1, 0)
  opt3 = where(dp .ge. 0.0, 1, 0)
  opt = opt1*opt2*opt3
  cate = where(opt .gt. 0, 5, cate)

;----------------------------------------------------------------------
  print("Calculating Catalog 6")
 ;Cate 6:  dtdr < 0, dtdp < 0, dp < 0    Dynamic     Warm Low  Thin
  opt3 = where(dp .lt. 0.0, 1, 0)
  opt = opt1*opt2*opt3
  cate = where(opt .gt. 0, 6, cate)

;----------------------------------------------------------------------
  copy_VarCoords(T, cate)
  cate@long_name = "Catelog"

  write2file(alt, lat, lon, T, P, cate, flnm)

  return cate
end

;************************************************
undef("gen_plot")
procedure gen_plot(f:file, fb:file, fon:string, plottype:string)
begin
  alt = f->alt(:)
  cate = compute_state_catalog(f, fb, fon)

  print("Start plotting")
;----------------------------------------------------------------------
  do k = 0, dimsizes(alt)-1, 40
    hgt = tofloat(alt(k))
    imgname = "era5_state_catelog_of_dec_2021_at_" + tostring(toint(hgt)) + "meter"
    title = "era5 Atmospheric Catalog of DEC 2021 at " + tostring(toint(hgt)) + "meter"
    print("Title: " + title)
    pvar = tofloat(cate(k,:,:))
    plot_categorical(pvar, plottype, imgname, title, hgt)
  end do
end

;************************************************
;plottype = "png"
 plottype = "x11"

 dirb = "/work2/noaa/gsienkf/weihuang/era5/data/"
 filb = "hl_monthly_mean_uvtp.nc"
 fb = addfile(dirb+filb,"r")

 diri = "/work2/noaa/gsienkf/weihuang/era5/data/"
 fili = "hl_uvtp.nc"
 f = addfile(diri+fili,"r")

 fon = diri+"state_cate_2021121600.nc"

 gen_plot(f, fb, fon, plottype)


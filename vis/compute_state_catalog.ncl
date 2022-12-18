load "categorical.ncl"

;----------------------------------------------------------------------
undef("compute_state_catalog")
procedure compute_state_catalog(fi:string, fo:string)
begin
  f = addfile(fi,"r")
  T = f->T(:, :, :)
  P = f->P(:, :, :)
  Rho = P / (287.0*T)

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
  lev = new((/nalt/), float, -1.0e32)

  dt = new(dimT, float, -1.0e32)
  dp = new(dimT, float, -1.0e32)
  dr = new(dimT, float, -1.0e32)

  do n=0, nalt-1
    tm = avg(T(n,:,:))
    pm = avg(P(n,:,:))
    rm = avg(Rho(n,:,:))

    dt(n,:,:) = T(n,:,:) - tm
    dp(n,:,:) = P(n,:,:) - pm
    dr(n,:,:) = Rho(n,:,:) - rm

    lev(n) = pm
  end do

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
 ;Cate 1:  dtdr >= 0, dp >= 0          Thermal-Dynamic  Warm High Dense
  opt1 = where(dtdr .ge. 0.0, 1, 0)
  opt2 = where(dp .ge. 0.0, 1, 0)
  opt = opt1*opt2
  cate = where(opt .gt. 0, 1, cate)

;----------------------------------------------------------------------
 ;Cate 2:  dtdr >= 0, dp < 0           Thermal-Dynamic  Cold Low Thin
  opt2 = where(dp .lt. 0.0, 1, 0)
  opt = opt1*opt2
  cate = where(opt .gt. 0, 2, cate)

;----------------------------------------------------------------------
 ;Cate 3:  dtdr < 0, dtdp >= 0, dp >= 0   Thermal        Warm High thin
  opt1 = where(dtdr .lt. 0.0, 1, 0)
  opt2 = where(dtdp .ge. 0.0, 1, 0)
  opt3 = where(dp .ge. 0.0, 1, 0)
  opt = opt1*opt2*opt3
  cate = where(opt .gt. 0, 3, cate)

;----------------------------------------------------------------------
 ;Cate 4:  dtdr < 0, dtdp < 0, dp < 0   Thermal        Cold Low Dense
  opt3 = where(dp .lt. 0.0, 1, 0)
  opt = opt1*opt2*opt3
  cate = where(opt .gt. 0, 4, cate)

;----------------------------------------------------------------------
 ;Cate 5:  dtdr < 0, dtdp < 0, dp >= 0     Dynamic     Cold High Dense
  opt2 = where(dtdp .lt. 0.0, 1, 0)
  opt3 = where(dp .ge. 0.0, 1, 0)
  opt = opt1*opt2*opt3
  cate = where(opt .gt. 0, 5, cate)

;----------------------------------------------------------------------
 ;Cate 6:  dtdr < 0, dtdp < 0, dp < 0    Dynamic     Wamr Low  Thin
  opt3 = where(dp .gt. 0.0, 1, 0)
  opt = opt1*opt2*opt3
  cate = where(opt .gt. 0, 6, cate)

;----------------------------------------------------------------------
  pvar = tofloat(cate)
 ;pvar = smth9_Wrap(pvar, 0.50, -0.25, True)
 ;pvar = smth9_Wrap(pvar, 0.50, 0.25, True)
 ;cate = toint(pvar + 0.5)
 ;pvar = tofloat(cate)

  copy_VarCoords(T, pvar)
  pvar@long_name = "Catelog"

  write2file(T, P, pvar, fo)
end

;----------------------------------------------------------------------
;if(isdefined(diri)) then
   dirname = diri
;else
;  dirname = "/work2/noaa/gsienkf/weihuang/gfs/data/annual/"
;end if

;if(isdefined(fili)) then
   finame = fili
;else
;  finame = "hl_annual_mean_gfs_4_2022.nc"
;end if

;if(isdefined(filo)) then
   foname = filo
;else
;  foname = "annual_state_cate.nc"
;end if

 fi = dirname+finame
 fo = dirname+foname

 print("fi = " + fi)
 print("fo = " + fo)

 compute_state_catalog(fi, fo)


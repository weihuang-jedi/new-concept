load "categorical.ncl"

;************************************************
undef("gen_plot")
procedure gen_plot(f:file, plottype:string)
begin
  T1 = f->T(:, :, :)
  P1 = f->P(:, :, :)
  Rho1 = P1 / (287.0*T1)

  imgname = "catelog average section"
  
;----------------------------------------------------------------------
 dt = T1
 dp = P1
 dr = Rho1

 alt = T1&alt
 lat = T1&lat
 lon = T1&lon

 dimT = dimsizes(T1)
 nalt = dimT(0)
 nlat = dimT(1)
 nlon = dimT(2)
 lev = new((/nalt/), float, -1.0e32)

 do n=0, nalt-1
    tm = avg(T1(n,:,:))
    pm = avg(P1(n,:,:))
    rm = avg(Rho1(n,:,:))

    dt(n,:,:) = T1(n,:,:) - tm
    dp(n,:,:) = P1(n,:,:) - pm
    dr(n,:,:) = Rho1(n,:,:) - rm

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

;copy_VarCoords(T1, pvar)
 pvar@long_name = "Catelog"

 write2file(T1, P1, pvar, "stateCate.nc")

 lev!0 = "lev" 
 lev&lev = lev
 lev@units = "Pa"

 pvar!0 = "lev" 
 pvar!1 = "lat" 
 pvar!2 = "lon" 
 pvar&lev = lev
 pvar&lat = lat
 pvar&lon = lon

 plot_cate_section(pvar, plottype, imgname)
end

;************************************************
;plottype = "png"
 plottype = "x11"

 dir = "/work2/noaa/gsienkf/weihuang/gfs/data/jan2022/"
 fil = "hl_monthly_mean_gfs_4_202201.nc"
;fil = "hl_gfs_4_20220116_0000_000.nc"
 f = addfile(dir+fil,"r")

 gen_plot(f, plottype)


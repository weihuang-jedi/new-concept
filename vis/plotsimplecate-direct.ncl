load "categorical.ncl"

;************************************************
undef("gen_plot")
procedure gen_plot(f:file, fb:file, plottype:string, level:integer)
begin
  T = f->T(level, :, :)
  P = f->P(level, :, :)
  Rho = P / (287.0*T)

  copy_VarCoords(T, Rho)

  Tb = fb->T(level, :, :)
  Pb = fb->P(level, :, :)
  Rhob = Pb / (287.0*Tb)

  T@long_name = "T"                     ; short name for plot labeling clarity

 ;printVarSummary(T)                    ; (94,192) gaussian [S->N]
 ;printMinMax(T,True)
 ;print("")

  alt = f->alt
  hgt = toint(alt(level))
  
;----------------------------------------------------------------------
 dt = T - Tb
 dp = P - Pb
 dr = Rho - Rhob

 dtdr = dt*dr
 dtdp = dt*dp

 dimT = dimsizes(T)
 nlat = dimT(0)
 mlon = dimT(1)
 ngrids = nlat * mlon

 opt  = new(dimT, integer, -9999)
 opt1 = new(dimT, integer, -9999)
 opt2 = new(dimT, integer, -9999)
 opt3 = new(dimT, integer, -9999)
 cate = new(dimT, integer, -9999)

 copy_VarCoords(T, cate)
 cate@long_name = "Catelog"

 opt3 = 0
 cate = 0

;----------------------------------------------------------------------
 ngrids = nlat * mlon
 print(ngrids)

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
 title = "State catelog at " + tostring(hgt) + "meter"
 imgname = "state_catelog_at_" + tostring(hgt) + "meter"
 plot_categorical(pvar, plottype, imgname, title, hgt)
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
 f = addfile(diri+fili,"r")

 alt = f->alt(:)
 nalts = dimsizes(alt)

 do level = 20, nalts, 20
    gen_plot(f, fb, plottype, level)
 end do


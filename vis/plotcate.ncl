load "categorical.ncl"
;----------------------------------------------------------------------
undef("plot_gradient")
procedure plot_gradient(TX:float, TY:float)
begin
 ;wks = gsn_open_wks("png","gradient")          ; send graphics to PNG file
  wks = gsn_open_wks("x11","gradient")          ; send graphics to PNG file
  
  res                 = True
  res@gsnMaximize     = True                     
  res@gsnPaperOrientation = "portrait"
 ;res@cnLineLabelsOn  = False
 ;res@cnLevelSpacingF =   1.0                   ; set contour spacing
  res@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
  res@cnFillOn    = True                        ; turn on color fill
  res@cnLinesOn   = False                       ; turn off the contour lines
  res@cnLevels     = (/ -1.6, -0.8, -0.4, -0.2, -0.1, 0.1, 0.2, 0.4, 0.8, 1.6/)   ; set levels
  res@cnFillColors = (/"Navyblue", "Blue", "Royalblue", "Cyan", "Green", "White", \
                       "Yellow", "Orange", "Red", "Magenta", "Brown"/)
                                              
  plt1 = gsn_csm_contour_map(wks,TX,res) 
  plt2 = gsn_csm_contour_map(wks,TY,res) 
 ;plt = gsn_csm_contour_map(wks,T,res)  ; original data array 
end

;----------------------------------------------------------------------
undef("plot_var")
procedure plot_var(T:float)
begin
 ;wks = gsn_open_wks("png","gradient")          ; send graphics to PNG file
  wks = gsn_open_wks("x11","gradient")          ; send graphics to PNG file

  res                 = True
  res@gsnMaximize     = True
  res@gsnPaperOrientation = "portrait"
 ;res@cnLineLabelsOn  = False
 ;res@cnLevelSpacingF =   1.0                   ; set contour spacing
 ;res@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
  res@cnFillOn    = True                        ; turn on color fill
  res@cnLinesOn   = False                       ; turn off the contour lines
  res@cnLevels     = (/ 0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0 /)
  res@cnFillColors = (/"White", "Blue", "Cyan", "Yellow", "Orange", "Red", "Magenta"/)

  plt = gsn_csm_contour_map(wks,T,res)  ; original data array
end

;----------------------------------------------------------------------
undef ("get_gradient")
function get_gradient(T:float)
begin
  dimT = dimsizes(T)
  nlat = dimT(0)
  mlon = dimT(1)

 ;print(nlat)
 ;print(mlon)

  rad   = 4.*atan(1.)/180.
  lat   = T&lat
  lon   = T&lon

  re    = 6.37122e6                      ; spherical earth
  con   = re*rad                         ; one deg lat = 111198.8 meters
  scly  = 1e5                            ; scale => nicer plots
  sclx  = 1e5  
  
;************************************************
; SPHERICAL HARMONICS:
; Use "highly accurate" spherical harmonics procedure (gradsg)
; to compute zonal (X) and meridional (Y) gradients.
;************************************************
; pre-allocate space for return gradients
  TX = new( dimT, typeof(T), getFillValue(T) )  ; lon=>X
  TY = new( dimT, typeof(T), getFillValue(T) )  ; lat=>Y

  gradsg(T, TX, TY)     ; procedure for gaussian grids

  copy_VarCoords(T, TX)         ; add meta data
  copy_VarCoords(T, TY) 
  TX@long_name = "TX"
 ;TX@long_name = "TX: gradsg"
  TX@units     = "K/s"
  TY@long_name = "TY"
 ;TY@long_name = "TY: gradsg"
  TY@units     = "K/s"

 ;print("")
 ;printMinMax(TX,False)
 ;printMinMax(TY,True )          ; unscaled
 ;print("")

;************************************************
; PLOTS:  SCALE gradients  for graphical esthetics
;************************************************

  TX = TX*sclx
  TY = TY*scly

 ;print("")
 ;print("=====> scaled values <=====")
 ;print("")
 ;printMinMax(TX,False)
 ;printMinMax(TY, True)          ; scaled
 ;print("")

  return [/TX, TY/]
end

;************************************************
undef("gen_plot")
procedure gen_plot(f:file, plottype:string, level:integer)
begin
  T = f->T(level, :, :)
  P = f->P(level, :, :)
  Rho = P / (287.0*T)

  T@long_name = "T"                     ; short name for plot labeling clarity

 ;printVarSummary(T)                    ; (94,192) gaussian [S->N]
 ;printMinMax(T,True)
 ;print("")

  alt = f->alt
  hgt = toint(alt(level))

  imgname = "catelog_at_" + tostring(hgt) + "meter"
  
;************************************************
 tlst = get_gradient(T)
 TX = tlst[0]
 TY = tlst[1]
 delete(tlst)

 d2t = uv2dvF_Wrap(TX,TY)

;************************************************
 plst = get_gradient(P)
 PX = plst[0]
 PY = plst[1]
 delete(plst)

 d2p = uv2dvF_Wrap(PX,PY)

 PX = 0.01*PX
 PY = 0.01*PY

;plot_gradient(PX, PY)

;************************************************
 copy_VarCoords(T, Rho)         ; add meta data
 Rho@long_name = "Rho"
 Rho@units     = "kg/m^3"

 rlst = get_gradient(Rho)
 RX = rlst[0]
 RY = rlst[1]
 delete(rlst)

 d2r = uv2dvF_Wrap(RX, RY)

 RX = 500.0*RX
 RY = 500.0*RY

;plot_gradient(RX, RY)

 d2t = 1.0e4*d2t
 d2p = 1.0e2*d2p
 d2r = 1.0e6*d2r

 d2t@long_name = "T-laplase"
 d2p@long_name = "P-laplase"
 d2r@long_name = "Rho-laplase"

;print("")
;printMinMax(d2t,False)
;printMinMax(d2p, True)
;printMinMax(d2r, True)

;plot_gradient(d2p, d2r)
;plot_gradient(d2t, d2r)

;----------------------------------------------------------------------
;WHERE(x < 0) x = x + 256                     ; f90 WHERE statement
;x = where(x.lt.0, x+256, x)                ; NCL

 dtdr = TX*RX + TY*RY
 dtdp = TX*PX + TY*PY

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
 copy_VarCoords(T, opt)
 opt@long_name = "Opt"

 copy_VarCoords(T, dtdr)
 dtdr@long_name = "Dt*Drho"
;plot_var(dtdr)

 copy_VarCoords(T, dtdp)
 dtdp@long_name = "Dt*Dp"
;plot_var(dtdp)

 opt3 = 0
 cate = 0

;----------------------------------------------------------------------
 ngrids = nlat * mlon
 print(ngrids)

;----------------------------------------------------------------------
;Cate 1:  dtdr >= 0, d2p <= 0
 ngrids = nlat * mlon
 opt1 = where(dtdr .ge. 0.0, 1, 0)
 opt2 = where(d2p .le. 0.0, 1, 0)
 opt = opt1*opt2
 cate = where(opt .gt. 0, 1, cate)

;----------------------------------------------------------------------
;Cate 2:  dtdr >= 0, d2p > 0
 opt2 = where(d2p .gt. 0.0, 1, 0)
 opt = opt1*opt2
 cate = where(opt .gt. 0, 2, cate)

;----------------------------------------------------------------------
;Cate 3:  dtdr >= 0, dtdp >= 0, d2p <= 0
 opt1 = where(dtdr .lt. 0.0, 1, 0)
 opt2 = where(dtdp .ge. 0.0, 1, 0)
 opt3 = where(d2p .le. 0.0, 1, 0)
 opt = opt1*opt2*opt3
 cate = where(opt .gt. 0, 3, cate)

;----------------------------------------------------------------------
;Cate 4:  dtdr >= 0, dtdp >= 0, d2p > 0
 opt3 = where(d2p .gt. 0.0, 1, 0)
 opt = opt1*opt2*opt3
 cate = where(opt .gt. 0, 4, cate)

;----------------------------------------------------------------------
;Cate 5:  dtdr >= 0, dtdp < 0, d2p <= 0
 opt2 = where(dtdp .lt. 0.0, 1, 0)
 opt3 = where(d2p .le. 0.0, 1, 0)
 opt = opt1*opt2*opt3
 cate = where(opt .gt. 0, 5, cate)

;----------------------------------------------------------------------
;Cate 6:  dtdr >= 0, dtdp < 0, d2p > 0
 opt3 = where(d2p .gt. 0.0, 1, 0)
 opt = opt1*opt2*opt3
 cate = where(opt .gt. 0, 6, cate)
;----------------------------------------------------------------------
 pvar = tofloat(cate)
;pvar = smth9_Wrap(pvar, 0.50, -0.25, True)
;pvar = smth9_Wrap(pvar, 0.50, 0.25, True)
;cate = toint(pvar + 0.5)
;pvar = tofloat(cate)
 plot_categorical(pvar, plottype, imgname, hgt)
end

;************************************************
;plottype = "png"
 plottype = "x11"

;diri = "/work2/noaa/gsienkf/weihuang/gfs/data/jan2022/"
;fili = "hl_monthly_mean_gfs_4_202201_000.nc"
;diri = "/work2/noaa/gsienkf/weihuang/gfs/data/annual/"
;fili = "hl_annual_mean_gfs_4_2022.nc"
 diri = "/work2/noaa/gsienkf/weihuang/gfs/data/dec2022/"
 fili = "delt2p_20221201_00.nc"

 f = addfile(diri+fili,"r")

 alt = f->alt(:)
 nalts = dimsizes(alt)

 do level = 20, nalts, 20
    gen_plot(f, plottype, level)
 end do


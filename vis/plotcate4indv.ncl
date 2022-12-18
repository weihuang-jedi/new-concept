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

  T = smth9_Wrap(T, 0.50, 0.25, True)
  T = smth9_Wrap(T, 0.50, 0.25, True)

;************************************************
; SPHERICAL HARMONICS:
; Use "highly accurate" spherical harmonics procedure (gradsg)
; to compute zonal (X) and meridional (Y) gradients.
;************************************************
; pre-allocate space for return gradients
  TX = new( dimT, typeof(T), getFillValue(T) )
  TY = new( dimT, typeof(T), getFillValue(T) )

  gradsg(T, TX, TY)     ; procedure for gaussian grids

  TX = smth9_Wrap(TX, 0.50, 0.25, True)
  TX = smth9_Wrap(TX, 0.50, 0.25, True)

  TY = smth9_Wrap(TY, 0.50, 0.25, True)
  TY = smth9_Wrap(TY, 0.50, 0.25, True)

 ;print("")
 ;printMinMax(TX,False)
 ;printMinMax(TY,True )          ; unscaled
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

  copy_VarCoords(T, Rho)

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

;************************************************
 plst = get_gradient(P)
 PX = plst[0]
 PY = plst[1]
 delete(plst)

;plot_gradient(PX, PY)

;************************************************
 copy_VarCoords(T, Rho)         ; add meta data
 Rho@long_name = "Rho"
 Rho@units     = "kg/m^3"

 rlst = get_gradient(Rho)
 RX = rlst[0]
 RY = rlst[1]
 delete(rlst)

;plot_gradient(RX, RY)

;----------------------------------------------------------------------
 dtdr = TX*RX + TY*RY
 dtdp = TX*PX + TY*PY
 d2p = uv2dvF_Wrap(PX,PY)
;d2p = smth9_Wrap(d2p, 0.50, 0.25, True)
;d2p = smth9_Wrap(d2p, 0.50, 0.25, True)

 dimT = dimsizes(T)
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
;Cate 1:  dtdr >= 0, d2p <= 0
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

 dir = "/work2/noaa/gsienkf/weihuang/gfs/data/jan2022/"
;fil = "hl_monthly_mean_gfs_4_202201.nc"
 fil = "hl_gfs_4_20220116_0000_000.nc"
 f = addfile(dir+fil, "r")

 alt = f->alt
 nalts = dimsizes(alt)

 do level = 20, nalts, 20
    gen_plot(f, plottype, level)
 end do


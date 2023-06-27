load "categorical.ncl"
;----------------------------------------------------------------------
undef ("get_gradient")
function get_gradient(T:float)
begin
;************************************************
; SPHERICAL HARMONICS:
; Use "highly accurate" spherical harmonics procedure (gradsg)
; to compute zonal (X) and meridional (Y) gradients.
;************************************************

 ;T = smth9_Wrap(T, 0.50, 0.25, True)
 ;T = smth9_Wrap(T, 0.50, 0.25, True)

 ;pre-allocate space for return gradients
  dimT = dimsizes(T)
  TX = new( dimT, typeof(T), getFillValue(T) )  ; lon=>X
  TY = new( dimT, typeof(T), getFillValue(T) )  ; lat=>Y

  gradsg(T, TX, TY)     ; procedure for gaussian grids

 ;TX = smth9_Wrap(TX, 0.50, 0.25, True)
 ;TX = smth9_Wrap(TX, 0.50, 0.25, True)

 ;TY = smth9_Wrap(TY, 0.50, 0.25, True)
 ;TY = smth9_Wrap(TY, 0.50, 0.25, True)

 ;print("")
 ;printMinMax(TX,False)
 ;printMinMax(TY,True )          ; unscaled
 ;print("")

  return [/TX, TY/]
end

;************************************************
undef("compute_grad_catalog")
procedure compute_grad_catalog(fi:string, fo:string)
begin
  f = addfile(fi,"r")
  T = f->T(:, :, :)
  P = f->P(:, :, :)
  Rho = P / (287.0*T)

  T@long_name = "T"                     ; short name for plot labeling clarity
  copy_VarCoords(T, Rho)

 ;printVarSummary(T)                    ; (94,192) gaussian [S->N]
 ;printMinMax(T,True)
 ;print("")

  alt = f->alt

  imgname = "catelog_section"
  
;************************************************
 tlst = get_gradient(T)
 TX = tlst[0]
 TY = tlst[1]
 delete(tlst)

;************************************************
 Rho = T*log(Rho)
 rlst = get_gradient(Rho)
 RX = rlst[0]
 RY = rlst[1]
 delete(rlst)

;************************************************
 plst = get_gradient(P)
 PX = plst[0]
 PY = plst[1]
 delete(plst)

;************************************************
;d2p = uv2dvF_Wrap(PX,PY)

;d2p = smth9_Wrap(d2p, 0.50, 0.25, True)
;d2p = smth9_Wrap(d2p, 0.50, 0.25, True)

;************************************************
 rlst = get_gradient(PX)
 PXX = rlst[0]
 PXY = rlst[1]
 delete(rlst)

;************************************************
 rlst = get_gradient(PY)
 PYX = rlst[0]
 PYY = rlst[1]
 delete(rlst)

 d2p = PXX + PXY + PYX + PYY

;----------------------------------------------------------------------
 dtdr = TX*RX + TY*RY
 dpdr = PX*RX + PY*RY
 dpdt = PX*TX + PY*TY
;dtsq = TX*TX + TY*TY
;drsq = RX*RX + RY*RY

 dimT = dimsizes(T)
 nalt = dimT(0)
 nlat = dimT(1)
 nlon = dimT(2)
 opt  = new(dimT, integer, -9999)
 opt1 = new(dimT, integer, -9999)
 opt2 = new(dimT, integer, -9999)
 opt3 = new(dimT, integer, -9999)
 cate = new(dimT, integer, -9999)

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
;Cate 3:  dtdr < 0, dpdt >= 0, d2p <= 0
 opt1 = where(dtdr .lt. 0.0, 1, 0)
 opt2 = where(dpdt .ge. 0.0, 1, 0)
 opt3 = where(d2p .le. 0.0, 1, 0)
 opt = opt1*opt2*opt3
 cate = where(opt .gt. 0, 3, cate)

;----------------------------------------------------------------------
;Cate 4:  dtdr < 0, dtdp >= 0, d2p > 0
 opt3 = where(d2p .gt. 0.0, 1, 0)
 opt = opt1*opt2*opt3
 cate = where(opt .gt. 0, 4, cate)

;----------------------------------------------------------------------
;Cate 5:  dtdr < 0, dpdt < 0, d2p <= 0
 opt2 = where(dpdr .ge. 0.0, 1, 0)
 opt3 = where(d2p .le. 0.0, 1, 0)
 opt = opt1*opt2*opt3
 cate = where(opt .gt. 0, 5, cate)

;----------------------------------------------------------------------
;Cate 6:  dtdr < 0, dtdp < 0, d2p > 0
 opt3 = where(d2p .gt. 0.0, 1, 0)
 opt = opt1*opt2*opt3
 cate = where(opt .gt. 0, 6, cate)

;----------------------------------------------------------------------
 pvar = tofloat(cate)
 pvar@long_name = "Catelog"

 write2file(T, P, pvar, fo)

 dirname = "/work2/noaa/gsienkf/weihuang/gfs/data/dec2021/"
 foname = "D2P.nc"
 fo = dirname + foname
 write2file(T, P, d2p, fo)

 foname = "TX.nc"
 fo = dirname + foname
 write2file(T, P, TX, fo)

 foname = "TY.nc"
 fo = dirname + foname
 write2file(T, P, TY, fo)

 foname = "PX.nc"
 fo = dirname + foname
 write2file(T, P, PX, fo)

 foname = "PY.nc"
 fo = dirname + foname
 write2file(T, P, PY, fo)

 foname = "RX.nc"
 fo = dirname + foname
 write2file(T, P, RX, fo)

 foname = "RY.nc"
 fo = dirname + foname
 write2file(T, P, RY, fo)

 foname = "PXY.nc"
 fo = dirname + foname
 write2file(T, P, PXY, fo)

 foname = "PYX.nc"
 fo = dirname + foname
 write2file(T, P, PYX, fo)
end

;************************************************

 dirname = "/work2/noaa/gsienkf/weihuang/gfs/data/annual/"
 finame = "hl_annual_mean_gfs_4_2022.nc"
 foname = "annual_grad_cate.nc"

 info = readinfo("datainfo.txt")

 dirname = info(0)
 finame = info(1)
 foname = info(2)

 fi = dirname+finame
 fo = dirname+foname

 print("fi = " + fi)
 print("fo = " + fo)

 compute_grad_catalog(fi, fo)


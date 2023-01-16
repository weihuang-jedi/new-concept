load "categorical.ncl"
;----------------------------------------------------------------------
undef ("get_gradient")
function get_gradient(T:double)
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
  alt = f->alt(:)
  lat = f->lat(:)
  lon = f->lon(:)
  T = f->t(0, :, :, :)
  P = f->p(0, :, :, :)
  Rho = P / (287.0*T)

  T@long_name = "T"
  T!0 = "alt"
  T!1 = "lat"
  T!2 = "lon"
  T&alt = alt
  T&lat = lat
  T&lon = lon
  copy_VarCoords(T, P)
  copy_VarCoords(T, Rho)

  printVarSummary(T)
  printMinMax(T,True)
  printVarSummary(P)
  printMinMax(P,True)
  print("")

  imgname = "catelog_section"
  
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

;PX = smth9_Wrap(PX, 0.50, 0.25, True)
;PY = smth9_Wrap(PY, 0.50, 0.25, True)

;PX = smth9_Wrap(PX, 0.50, 0.25, True)
;PY = smth9_Wrap(PY, 0.50, 0.25, True)

 d2p = uv2dvF_Wrap(PX,PY)

;************************************************
 rlst = get_gradient(Rho)
 RX = rlst[0]
 RY = rlst[1]
 delete(rlst)

;----------------------------------------------------------------------
 dtdr = TX*RX + TY*RY
 dtdp = TX*PX + TY*PY

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
 copy_VarCoords(T, cate)
 cate@long_name = "Catelog"

 write2file(alt, lat, lon, T, P, cate, fo)
end

;************************************************

;if(.not. isdefined(diri)) then
;  dirname = "/work2/noaa/gsienkf/weihuang/gfs/data/annual/"
;else
   dirname = diri
;end if

;if(.not. isdefined(fili)) then
;  finame = "hl_annual_mean_gfs_4_2022.nc"
;else
   finame = fili
;end if

;if(.not. isdefined(filo)) then
;  foname = "annual_grad_cate.nc"
;else
   foname = filo
;end if

 fi = dirname+finame
 fo = dirname+foname

 print("fi = " + fi)
 print("fo = " + fo)

 compute_grad_catalog(fi, fo)


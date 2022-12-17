load "categorical.ncl"
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
 plst = get_gradient(P)
 PX = plst[0]
 PY = plst[1]
 delete(plst)

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
 pvar = tofloat(cate)
;pvar = smth9_Wrap(pvar, 0.50, -0.25, True)
;pvar = smth9_Wrap(pvar, 0.50, 0.25, True)
;cate = toint(pvar + 0.5)
;pvar = tofloat(cate)

 pvar@long_name = "Catelog"

 write2file(T, P, pvar, fo)
end

;************************************************

 if(isdefined(diri)) then
   dirname = diri
 else
   dirname = "/work2/noaa/gsienkf/weihuang/gfs/data/annual/"
 end if

 if(isdefined(fili)) then
   finame = fili
 else
   finame = "hl_annual_mean_gfs_4_2022.nc"
 end if

 if(isdefined(filo)) then
   foname = filo
 else
   foname = "annaul_grad_cate.nc"
 end if

 fi = dirname+finame
 fo = dirname+foname

 compute_grad_catalog(fi, fo)

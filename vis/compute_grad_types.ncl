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
undef("compute_grad_type")
procedure compute_grad_type(fi:string, fo:string)
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

 ;----------------------------------------------------------------------
  dtdr = TX*RX + TY*RY
  dpdr = PX*RX + PY*RY
  dpdt = PX*TX + PY*TY
 
  dimT = dimsizes(T)
  nalt = dimT(0)
  nlat = dimT(1)
  nlon = dimT(2)
  opt  = new(dimT, integer, -9999)
  opt1 = new(dimT, integer, -9999)
  opt2 = new(dimT, integer, -9999)
  type = new(dimT, integer, -9999)

  type = 0

 ;----------------------------------------------------------------------
 ;Type 1:  dtdr >= 0
  type = where(dtdr .ge. 0.0, 1, 0)
 
 ;----------------------------------------------------------------------
 ;Type 2:  dtdr < 0, dpdt >= 0
  opt1 = where(dtdr .lt. 0.0, 1, 0)
  opt2 = where(dpdt .ge. 0.0, 1, 0)
  opt = opt1*opt2
  type = where(opt .gt. 0, 2, type)
  
 ;----------------------------------------------------------------------
 ;Type 3:  dtdr < 0, dpdr >= 0
  opt2 = where(dpdr .ge. 0.0, 1, 0)
  opt = opt1*opt2
   type = where(opt .gt. 0, 3, type)
 
 ;----------------------------------------------------------------------
  pvar = tofloat(type)
  pvar@long_name = "Type"
 
  write2file(T, P, pvar, fo)
end

;************************************************

 dirname = "/work2/noaa/gsienkf/weihuang/gfs/data/annual/"
 finame = "hl_annual_mean_gfs_4_2022.nc"
 foname = "annual_grad_type.nc"

 info = readinfo("datainfo.txt")

 dirname = info(0)
 finame = info(1)
 foname = info(2)

 fi = dirname+finame
 fo = dirname+foname

 print("fi = " + fi)
 print("fo = " + fo)

 compute_grad_type(fi, fo)


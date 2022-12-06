;----------------------------------------------------------------------
; gradient_1.ncl
;
; Concepts illustrated:
;   - Reading and reordering variables
;   - Using spherical harmonic (SPH)  procedure to calculate the 
;     latitudinal and longitidinal gradients.
;   - Using 'grad_latlon_cfd'  centered finite differences (CFD) to calculate the
;     latitudinal and longitidinal gradients.
;   - Compute global means and differences between the SPH and CFS estimates  
;   - Plotting with symmetric contour bounds
;===========================================================
; Comment: 
;   - Using the 2-meter temperatures will maximize the differences
;     because there are large gradients and 2m-temps can be a bit noisy.
;===========================================================
;                  MAIN: requires NCL 6.4.0 onward
;===========================================================
; Read gaussian array
; ftp://ftp.cdc.noaa.gov/Datasets/ncep.reanalysis/surface_gauss/
;************************************************
  diri = "/work2/noaa/gsienkf/weihuang/gfs/data/"
  fili = "hl_monthly_mean_gfs_4_202201_000.nc"
  f    = addfile(diri+fili,"r")

  T   = f->T(100,:,:)                   ; (time,lat,lon) => (lat,lon); degK        

  T@long_name = "T_2m"                 ; short name for plot labeling clarity
  printVarSummary(T)                    ; (94,192) gaussian [S->N]
  printMinMax(T,True)
  print("")
  
;************************************************
; Miscellaneous
;************************************************

  dimT = dimsizes(T)
  nlat  = dimT(0)
  mlon  = dimT(1)

  print(nlat)
  print(mlon)

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
  TX_gradsg = new( dimT, typeof(T), getFillValue(T) )  ; lon=>X
  TY_gradsg = new( dimT, typeof(T), getFillValue(T) )  ; lat=>Y
  gradsg(T, TX_gradsg, TY_gradsg)     ; procedure for gaussian grids

  copy_VarCoords(T, TX_gradsg)         ; add meta data
  copy_VarCoords(T, TY_gradsg) 
  TX_gradsg@long_name = "TX: gradsg"
  TX_gradsg@units     = "K/s"
  TY_gradsg@long_name = "TY: gradsg"
  TY_gradsg@units     = "K/s"

  print("")
  printMinMax(TY_gradsg,True )          ; unscaled
  printMinMax(TX_gradsg,False)
  print("")

;************************************************
  TY_gradsg_mean = dim_avg(TY_gradsg)

  TX_gradsg_mean = dim_avg(TX_gradsg)

  TX_gradsg_mean = TX_gradsg_mean*sclx
  TY_gradsg_mean = TY_gradsg_mean*scly

  print("-----")
  print("TY_gradsg_mean="+sprintf("%9.3f",TY_gradsg_mean)) ; SCALED values
  print("  ")
  print("TX_gradsg_mean="+sprintf("%9.3e",TX_gradsg_mean))
  print("  ")

;************************************************
; PLOTS:  SCALE gradients  for graphical esthetics
;************************************************

  TY_gradsg = TY_gradsg*scly

  TX_gradsg = TX_gradsg*sclx

  print("")
  print("=====> scaled values <=====")
  print("")
  printMinMax(TY_gradsg, True)          ; scaled
  printMinMax(TX_gradsg,False)
  print("")

;************************************************
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
                                              
  plt1 = gsn_csm_contour_map(wks,TX_gradsg,res) 
  plt2 = gsn_csm_contour_map(wks,TY_gradsg,res) 
 ;plt = gsn_csm_contour_map(wks,T,res)  ; original data array 

;----


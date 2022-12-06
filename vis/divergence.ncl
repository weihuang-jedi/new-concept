;*************************************************
; wind_3.ncl
;
; Concepts illustrated:
;   - Use spherical harmonics on a global grid
;   - Use uv2dvG_Wrap and uv2vr_Wrap to compute divergence and vortivity
;     and maintain meta data
;   - Use ilapsG_Wrap to compute velocity potential and streamfunction
;     and maintain meta data
;   - Plot vector winds and scalr quantities
;*************************************************
; wind_4.ncl
;*************************************************
; open file and read in data: data are on a gaussian grid
;*************************************************
  f    = addfile ("$NCARG_ROOT/lib/ncarg/data/cdf/uv300.nc", "r")
  u    = f->U                      ; (time,lat,lon)
  v    = f->V
;*************************************************
; Calculate divergence and vortivity via spherical harmonics
; Use Wrap version to maintain meta data
;*************************************************
  div = uv2dvG_Wrap(u,v)           ; u,v ==> divergence
  vrt = uv2vrG_Wrap(u,v)           ; u,v ==> vorticity

;*************************************************
; Calculate velocity potential and stream function  
; Use Wrap version to maintain meta data
;*************************************************
  chi = ilapsG_Wrap ( div , 0)
  chi@long_name = "velocity potential"
  chi@units     = "m/s" 

  psi = ilapsG_Wrap ( vrt , 0)
  psi@long_name = "streamfunction"
  psi@units     = "m/s" 

;*************************************************
; Use spherical harmonics to derive divergent and rotational wind components 
; Use Wrap version to maintain meta data
;*************************************************    
  
  uvd = dv2uvG_Wrap(div) ; div  ==> divergent  wind components
  uvr = vr2uvG_Wrap(vrt) ; vrt  ==> divergent  wind components

;*************************************************
; For clarity, explicitly extract the wind components
; Add explicit lomg_name for each variable
;*************************************************    
  ud  = uvd(0,:,:,:)     ; 
  vd  = uvd(1,:,:,:)
  ur  = uvr(0,:,:,:)
  vr  = uvr(1,:,:,:)

  ud@long_name  = "Zonal Divergent Wind"
  vd@long_name  = "Meridional Divergent Wind"
  ur@long_name  = "Zonal Rotational Wind"
  vr@long_name  = "Meridional Rotational Wind"

  delete((/uvd,uvr/))   ; no longer needed
;*************************************************
; plot results
;*************************************************    

  nt = 0                                           ; time index (1st time)
  scale = 1e6                                      ; arbitrary: used for nicer plot values
  psi = psi/scale
  chi = chi/scale

  wks  = gsn_open_wks("png","wind")               ; send graphics to PNG file

  res                      = True

  res@cnFillOn             = True                 ; color on
  res@cnLinesOn            = False                ; turn off contour lines

  res@gsnScalarContour     = True                 ; vectors over contours
 ;res@cnFillPalette        = "BlAqGrYeOrReVi200"
  res@cnFillPalette        = "amwg256"

  res@vcRefMagnitudeF      = 3.                   ; make vectors larger
  res@vcRefLengthF         = 0.050                ; ref vector length
  res@vcGlyphStyle         = "CurlyVector"        ; turn on curly vectors
  res@vcMinDistanceF       = 0.012                ; thin the vectors
  res@vcRefAnnoOrthogonalPosF  = -0.13            ; Move ref anno into plot

  res@mpFillOn             = False              ; turn off map fill

  res@tiMainString         = "Velocity Potential via Spherical Harmonics"
  res@gsnCenterString      = "Chi scaled by 1e6"
  res@gsnLeftString        = "Divergent Wind"

  res@cnLevelSelectionMode = "ManualLevels"       ; set manual contour levels
  res@cnMinLevelValF       = -8.0                 ; set min contour level
  res@cnMaxLevelValF       =  8.0                 ; set max contour level
  res@cnLevelSpacingF      =  1.0                 ; set contour spacing

  plot=gsn_csm_vector_scalar_map(wks,ud(0,:,:),vd(0,:,:),chi(0,:,:),res)

  res@tiMainString         = "Streamfunction via Spherical Harmonics"     ; title
  res@gsnCenterString      = "Psi scaled by 1e6"  ; center string
  res@gsnLeftString        = "Rotational Wind"    ; left string

  res@vcMinDistanceF       = 0.017
  res@vcRefAnnoOrthogonalPosF = -1.0              ; move ref vector up
  res@vcRefMagnitudeF      = 10.0                 ; define vector ref mag
  res@vcRefLengthF         = 0.050                ; define length of vec ref

  res@cnMinLevelValF       = -120.0               ; set min contour level
  res@cnMaxLevelValF       =  120.0               ; set max contour level
  res@cnLevelSpacingF      =   10.0               ; set contour spacing
  plot=gsn_csm_vector_scalar_map(wks,ur(nt,:,:),vr(nt,:,:),psi(nt,:,:),res)


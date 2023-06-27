;----------------------------------------------------------------------
undef("add_coordinate")
procedure add_coordinate(alt:float, lat:float, lon:float, var:float)
begin
  var!0 = "alt"
  var!1 = "lat"
  var!2 = "lon"
  var&alt = alt
  var&lat = lat
  var&lon = lon
  var@coordinate = "alt lat lon"
end

;----------------------------------------------------------------------
 g = 9.80665          ; m/s2
 r = 287.0

 diri = "/work2/noaa/gsienkf/weihuang/era5/data/"
 flnm = "hl_monthly_mean_uvtp.nc"
 ofile = "monthly_mean_df.nc"

 path = diri+flnm      

 f = addfile(path, "r")

 u = f->u(0,:,:,:)  ; m/s, (level,lat,lon)
 v = f->v(0,:,:,:)
 t = f->t(0,:,:,:)
 p = f->p(0,:,:,:)

;Vertical levels
 h = t&alt
 h@units = "M"
 alt = h
 lat = t&lat
 lon = t&lon

 ndh = toint(h(1) - h(0) + 0.5)

 dims = dimsizes(t)
 nalt = dims(0)
 z = conform_dims(dims,h,0)
 rho = p / (287.01*t)

;printVarSummary(z)
;printMinMax(z,0)
;printVarSummary(rho)
;printMinMax(rho,0)

 rho@units = "kg/kg"

 dims(0) = dims(0) - 1
 ua = new(dims, typeof(u))
 va = new(dims, typeof(v))
 dz = new(dims, typeof(h))
 ra = new(dims, typeof(rho))

 ra@units = "kg/kg"

 delete(t)
 delete(p)

 malt = dims(0)

 alta = 0.5*(alt(0:malt-1) + malt(1:malt))
 ua(0:malt-1,:,:) = 0.5*(u(0:malt-1,:,:) + u(1:malt,:,:))
 va(0:malt-1,:,:) = 0.5*(v(0:malt-1,:,:) + v(1:malt,:,:))
 ra(0:malt-1,:,:) = 0.5*(rho(0:malt-1,:,:) + rho(1:malt,:,:))
 dz(0:malt-1,:,:) = z(1:malt,:,:) - z(0:malt-1,:,:)

;ua = smth9_Wrap(ua, 0.50, 0.25, True)
;ua = smth9_Wrap(ua, 0.50, 0.25, True)

;va = smth9_Wrap(va, 0.50, 0.25, True)
;va = smth9_Wrap(va, 0.50, 0.25, True)

;ra = smth9_Wrap(ra, 0.50, 0.25, True)
;ra = smth9_Wrap(ra, 0.50, 0.25, True)

;printVarSummary(ua)
;printVarSummary(va)
;printVarSummary(ra)
;printVarSummary(dz)

;print(dz(::100,1,1))

 add_coordinate(alta, lat, lon, ua)
 add_coordinate(alta, lat, lon, va)
 add_coordinate(alta, lat, lon, ra)
 add_coordinate(alta, lat, lon, dz)

 print("Density flux components at each height level")
;Density flux components at each height level
 ur = ua*ra
 ur@long_name = "Zonal Density Flux [ur]"
 ur@units = "["+u@units+"]["+ra@units+"]"     ; [m/s][kg/m3]     
 copy_VarCoords(u(0:malt,:,:),ur)                        ; (level,lat,lon)

 vr = va*ra
 vr@long_name = "Meridional Density Flux [vr]"
 vr@units = "["+v@units+"]["+ra@units+"]" 
 copy_VarCoords(v(0:malt,:,:),vr)                        ; (level,lat,lon)

 print("-----")
 printVarSummary(ur)                         ; (level,lat,lon); (m/s)(kg/m3)
 printMinMax(ur,0)
 print("-----")
 printVarSummary(vr)
 printMinMax(vr,0)
 print("-----")

 print("Integrated mass weighted density flux components")
;Integrated mass weighted density flux components

 ur_dz = ur*dz                ; mass weighted 'ur'; [m/s][kg/m3][m]=>[m/s][kg/m2]
 iur    = dim_sum_n(ur_dz, 0)
 iur@long_name = "Integrated Zonal URho [ur*dz]" 
 iur@LONG_NAME = "Sum: Mass Weighted Integrated Zonal Density Flux [ur*dz]" 
 iur@units     = "[m2/s][kg/kg]"
 copy_VarCoords(u(0,:,:), iur); (lat,lon)
 delete(ur_dz)

 vr_dz = vr*dz                ; mass weighted 'vr'; [m/s][kg/m3][m]=>[m/s][kg/m2] 
 ivr    = dim_sum_n(vr_dz, 0)
 ivr@long_name = "Integrated Meridional VRho [vr*dz]" 
 ivr@LONG_NAME = "Sum: Mass Weighted Integrated Meridional Density Flux [vr*dz]" 
 ivr@units     = "[m2/s][kg/kg]"
 copy_VarCoords(v(0,:,:), ivr); (lat,lon)
 delete(vr_dz)

 print("Divergence of density flux: uv2dvF => global 'fixed' rectilinear grid")
;Divergence of density flux: uv2dvF => global 'fixed' rectilinear grid

 duvr  = uv2dvF_Wrap(ur, vr)    ; (level,lat,lon)
 add_coordinate(alta, lat, lon, duvr)
 duvr@long_name = "Divergence of Density Flux"
 duvr@units     = "kg/(m2-s)"    ; (1/m)*[(m/s)(kg/m2)] => [kg/(m2-s)]

 print("Mass weighted integration [sum] of the divergence of density flux")
;Mass weighted integration [sum] of the divergence of density flux

 duvr_dz = duvr*dz            ;  [kg/(m2-s)][m] => [kg/(m-s)]
 add_coordinate(alta, lat, lon, duvr_dz)
 iduvr    = dim_sum_n(duvr_dz, 0)
 iduvr@long_name = "Integrated Mass Wgt MFC" 
 iduvr@LONG_NAME = "Integrated Mass Weighted Density Flux Convergence" 
 iduvr@units     = "kg/(m-s)"
 copy_VarCoords(u(0,:,:), iduvr)      ; (lat,lon)
 delete(duvr_dz)

 VIMFC =  iduvr           ; keep meta data                         
 VIMFC = -VIMFC           ; Note the preceding -1 [negative precedes integration] 
 VIMFC@long_name = "VIMFC"

 print("plot results")
;*************************************************
; plot results
;*************************************************   
 scl5  = 1e5                                  ; arbitrary: used for nicer plot values
 sclab5= "(10~S~-5~N~)"                       ; used later   
 SCLAB5= "(10~S~5~N~)"           

 scl6  = 1e6  
 sclab6= "(10~S~-6~N~)"         
 SCLAB6= "(10~S~6~N~)"         

;---------------------------------------------------------------------------------------
 plot := new(2,graphic)

 wks   = gsn_open_wks("png","dfc_div")        ; send graphics to PNG file
;wks   = gsn_open_wks("x11","dfc_div")        ; send graphics to PNG file
 
;Density Transport [ur, vr] at a specified pressure level

 res                   = True             ; plot mods desired
 res@gsnDraw           = False            ; don't draw yet
 res@gsnFrame          = False            ; don't advance frame yet

 res@cnFillOn          = True             ; turn on color
 res@cnLinesOn         = False            ; turn off contour lines
 res@cnLineLabelsOn    = False            ; turn off contour lines
 res@cnFillPalette     = "ViBlGrWhYeOrRe" ; set White-in-Middle color map
 res@lbLabelBarOn      = False            ; turn off individual cb's
 res@mpFillOn          = False            ; turn off map fill
                                          ; Use a common scale
 res@cnLevelSelectionMode = "ManualLevels"; manual set levels so lb consistent
 res@cnMaxLevelValF       =   20.0        ; max level
 res@cnMinLevelValF       = -res@cnMaxLevelValF     ; min level
 res@cnLevelSpacingF      =    1.0        ; contour interval

 LEVP    = 3000
 res@gsnCenterString      = LEVP+"m"
 print("-----")
 printVarSummary(ur(LEVP/ndh,:,:))
 printMinMax(ur(LEVP/ndh,:,:),0)
 print("-----")
 printVarSummary(vr(LEVP/ndh,:,:))
 printMinMax(vr(LEVP/ndh,:,:),0)
 plot(0) = gsn_csm_contour_map(wks,ur(LEVP/ndh,:,:),res)
 plot(1) = gsn_csm_contour_map(wks,vr(LEVP/ndh,:,:),res)

 resP                     = True                ; modify the panel plot
 resP@gsnPanelMainString  = "Unweighted Density Flux Components"
 resP@gsnPanelLabelBar    = True                ; add common colorbar
 gsn_panel(wks,plot,(/2,1/),resP)               ; now draw as one plot

 print("Integrated Density Transport [iur, ivr]")
;Integrated Density Transport [iur, ivr]
;---------------------------------------------------------------------------------------

 delete(res@gsnCenterString)              ; not used for this plot
 res@cnMaxLevelValF       =  5.0          ; max level
 res@cnMinLevelValF       = -res@cnMaxLevelValF     ; min level
 res@cnLevelSpacingF      =  0.1          ; contour interval

 IUQ     = iur(:,:)                    ; local array: keep meta data
 IUQ     = IUQ/scl5                       ; scale for plot
 res@gsnRightString  = SCLAB5+" "+iur@units
 plot(0) = gsn_csm_contour_map(wks,IUQ,res)

 IVQ     = ivr(:,:)                    ; local array: keep meta data
 IVQ     = IVQ/scl5
 res@gsnRightString  = SCLAB5+" "+ivr@units
 plot(1) = gsn_csm_contour_map(wks,IVQ,res)

 print("-----")
 printVarSummary(IUQ)
 printMinMax(IUQ, 0)
 print("-----")
 printVarSummary(IVQ)
 printMinMax(IVQ, 0)

 resP@gsnPanelMainString  = "Mass Wgt. Component Density Flux"
 gsn_panel(wks,plot,(/2,1/),resP)               ; now draw as one plot

 delete( [/IUQ, IVQ/] )                   ; no longer needed

 print("Divergence of Density Flux")
;Divergence of Density Flux
;---------------------------------------------------------------------------------------

 res@cnMaxLevelValF       =  20.0          ; max level
 res@cnMinLevelValF       = -res@cnMaxLevelValF     ; min level
 res@cnLevelSpacingF      =  1.0         ; contour interval

 LEVP    = 1000
 pvar    = duvr(LEVP/ndh,:,:)
 pvar    = pvar*scl6
 res@gsnCenterString = LEVP+"m"
 res@gsnRightString  = sclab6+" "+duvr@units

 print("-----LEVP =" + tostring(LEVP))
 printVarSummary(pvar)
 printMinMax(pvar, 0)
 copy_VarCoords(u(0,:,:), pvar)      ; (lat,lon)
 plot(0) = gsn_csm_contour_map(wks,pvar,res)

 LEVP    = 3000
 pvar    = duvr(LEVP/ndh,:,:)
 pvar    = pvar*scl6                              ; scale for plot
 res@gsnCenterString = LEVP+"m"
 res@gsnRightString  = sclab6+" "+duvr@units

 print("-----LEVP =" + tostring(LEVP))
 printVarSummary(pvar)
 printMinMax(pvar, 0)

 copy_VarCoords(u(0,:,:), pvar)      ; (lat,lon)
 plot(1) = gsn_csm_contour_map(wks,pvar,res)

 resP@gsnPanelMainString  = "Divergence of Density Flux"
 gsn_panel(wks,plot,(/2,1/),resP)                ; now draw as one plot

 delete(pvar)                                        ; no longer needed
 delete([/res@gsnCenterString, res@gsnRightString/]) ; not used in next plot 

 resP@gsnPanelMainString  = "Divergence of Density Flux"
 gsn_panel(wks,plot,(/2,1/),resP)                ; now draw as one plot

 delete(pvar)                                        ; no longer needed
 delete([/res@gsnCenterString, res@gsnRightString/]) ; not used in next plot

 print("Divergence of Density Flux")
;Divergence of Density Flux
;---------------------------------------------------------------------------------------

 res@cnMaxLevelValF       =  40.0          ; max level
 res@cnMinLevelValF       = -res@cnMaxLevelValF     ; min level
 res@cnLevelSpacingF      =  2.0         ; contour interval

 LEVP    = 5000
 pvar    = duvr(LEVP/ndh,:,:)
 pvar    = pvar*scl6
 res@gsnCenterString = LEVP+"m"
 res@gsnRightString  = sclab6+" "+duvr@units

 print("-----LEVP =" + tostring(LEVP))
 printVarSummary(pvar)
 printMinMax(pvar, 0)
 copy_VarCoords(u(0,:,:), pvar)      ; (lat,lon)
 plot(0) = gsn_csm_contour_map(wks,pvar,res)

 LEVP    = 7000
 pvar    = duvr(LEVP/ndh,:,:)
 pvar    = pvar*scl6                              ; scale for plot
 res@gsnCenterString = LEVP+"m"
 res@gsnRightString  = sclab6+" "+duvr@units

 print("-----LEVP =" + tostring(LEVP))
 printVarSummary(pvar)
 printMinMax(pvar, 0)

 copy_VarCoords(u(0,:,:), pvar)      ; (lat,lon)
 plot(1) = gsn_csm_contour_map(wks,pvar,res)

 resP@gsnPanelMainString  = "Divergence of Density Flux"
 gsn_panel(wks,plot,(/2,1/),resP)                ; now draw as one plot

 delete(pvar)                                        ; no longer needed
 delete([/res@gsnCenterString, res@gsnRightString/]) ; not used in next plot 

 resP@gsnPanelMainString  = "Divergence of Density Flux"
 gsn_panel(wks,plot,(/2,1/),resP)                ; now draw as one plot

 delete(pvar)                                        ; no longer needed
 delete([/res@gsnCenterString, res@gsnRightString/]) ; not used in next plot

 print("Divergence of Density Flux")
;Divergence of Density Flux
;---------------------------------------------------------------------------------------

 res@cnMaxLevelValF       =  80.0          ; max level
 res@cnMinLevelValF       = -res@cnMaxLevelValF     ; min level
 res@cnLevelSpacingF      =  4.0         ; contour interval

 LEVP    = 9000
 pvar    = duvr(LEVP/ndh,:,:)
 pvar    = pvar*scl6
 res@gsnCenterString = LEVP+"m"
 res@gsnRightString  = sclab6+" "+duvr@units

 print("-----LEVP =" + tostring(LEVP))
 printVarSummary(pvar)
 printMinMax(pvar, 0)
 copy_VarCoords(u(0,:,:), pvar)      ; (lat,lon)
 plot(0) = gsn_csm_contour_map(wks,pvar,res)

 LEVP    = 11000
 pvar    = duvr(LEVP/ndh,:,:)
 pvar    = pvar*scl6                              ; scale for plot
 res@gsnCenterString = LEVP+"m"
 res@gsnRightString  = sclab6+" "+duvr@units

 print("-----LEVP =" + tostring(LEVP))
 printVarSummary(pvar)
 printMinMax(pvar, 0)

 copy_VarCoords(u(0,:,:), pvar)      ; (lat,lon)
 plot(1) = gsn_csm_contour_map(wks,pvar,res)

 resP@gsnPanelMainString  = "Divergence of Density Flux"
 gsn_panel(wks,plot,(/2,1/),resP)                ; now draw as one plot

 delete(pvar)                                        ; no longer needed
 delete([/res@gsnCenterString, res@gsnRightString/]) ; not used in next plot 

 resP@gsnPanelMainString  = "Divergence of Density Flux"
 gsn_panel(wks,plot,(/2,1/),resP)                ; now draw as one plot

 delete(pvar)                                        ; no longer needed
 delete([/res@gsnCenterString, res@gsnRightString/]) ; not used in next plot

 print("Integrated Divergence of Density Flux Convergence [no scaling]")
;Integrated Divergence of Density Flux Convergence [no scaling]

 print("-----")
 printVarSummary(VIMFC)
 printMinMax(VIMFC, 0)

 res@gsnDraw              = True
 res@gsnFrame             = True
 res@lbLabelBarOn         = True        

;res@cnFillPalette        = "cmp_flux"
 res@cnMaxLevelValF       =  20.0               ; max level
 res@cnMinLevelValF       = -res@cnMaxLevelValF  ; min level
 res@cnLevelSpacingF      =  1.0                ; contour interval
 res@tiMainString         = "VIMFC"

 plt = gsn_csm_contour_map(wks,VIMFC(:,:) ,res)

 write_dfc_div(lat, lon, VIMFC, ofile)


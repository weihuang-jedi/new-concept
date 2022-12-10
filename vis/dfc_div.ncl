;===================================================================
 print("Part 1")
 g = 9.80665          ; m/s2
 r = 287.0

 diri = "/work2/noaa/gsienkf/weihuang/gfs/data/jan2022/"
 flnm = "hl_monthly_mean_gfs_4_202201_000.nc"

 path = diri+flnm      

 f = addfile(path, "r")

 u = f->U(:,:,:)  ; m/s, (level,lat,lon)
 v = f->V(:,:,:)
 t = f->T(:,:,:)
 p = f->P(:,:,:)

 print("Part 2")
;Vertical levels
 h = t&alt
 h@units = "M"

 ndh = toint(h(1) - h(0) + 0.5)

 dims = dimsizes(t)
 z = conform_dims(dims,h,0)
 rho = p / (287.01*t)

 nalt = dims(0)

 print("Part 2.1")
;printVarSummary(z)
;printMinMax(z,0)
;printVarSummary(rho)
;printMinMax(rho,0)

 rho@units = "kg/kg"

 dims(0) = dims(0) - 1
 ua = new(dims, typeof(u))
 va = new(dims, typeof(v))
 ta = new(dims, typeof(t))
 ra = new(dims, typeof(rho))
 dz = new(dims, typeof(h))

 ra@units = "kg/kg"

 malt = dims(0)

 print("Part 2.2")
 ua(0:malt-1,:,:) = 0.5*(u(0:malt-1,:,:) + u(1:malt,:,:))
 va(0:malt-1,:,:) = 0.5*(v(0:malt-1,:,:) + v(1:malt,:,:))
 ta(0:malt-1,:,:) = 0.5*(t(0:malt-1,:,:) + t(1:malt,:,:))
 ra(0:malt-1,:,:) = 0.5*(rho(0:malt-1,:,:) + rho(1:malt,:,:))
 dz(0:malt-1,:,:) = z(1:malt,:,:) - z(0:malt-1,:,:)

 print("Part 2.3")
;printVarSummary(ua)
;printVarSummary(va)
;printVarSummary(ta)
;printVarSummary(ra)
;printVarSummary(dz)

;print(t(::100,1,1))
;print(ta(::100,1,1))
;print(dz(::100,1,1))

 print("Part 3")
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

 print("Part 4")
 print("Integrated mass weighted density flux components")
;Integrated mass weighted density flux components

 ur_dz = ur*dz                ; mass weighted 'ur'; [m/s][kg/m3][m]=>[m/s][kg/m2]
 iur    = dim_sum_n(ur_dz, 0)
 iur@long_name = "Integrated Zonal URho [ur*dz]" 
 iur@LONG_NAME = "Sum: Mass Weighted Integrated Zonal Density Flux [ur*dz]" 
 iur@units     = "[m2/s][kg/kg]"
 copy_VarCoords(u(0,:,:), iur); (lat,lon)
 delete(ur_dz)

 print("Part 4.1")
 vr_dz = vr*dz                ; mass weighted 'vr'; [m/s][kg/m3][m]=>[m/s][kg/m2] 
 ivr    = dim_sum_n(vr_dz, 0)
 ivr@long_name = "Integrated Meridional VRho [vr*dz]" 
 ivr@LONG_NAME = "Sum: Mass Weighted Integrated Meridional Density Flux [vr*dz]" 
 ivr@units     = "[m2/s][kg/kg]"
 copy_VarCoords(v(0,:,:), ivr); (lat,lon)
 delete(vr_dz)

 print("Part 5")
 print("Divergence of density flux: uv2dvF => global 'fixed' rectilinear grid")
;Divergence of density flux: uv2dvF => global 'fixed' rectilinear grid

 duvr  = uv2dvF_Wrap(ur, vr)    ; (level,lat,lon)
 duvr@long_name = "Divergence of Density Flux"
 duvr@units     = "kg/(m2-s)"    ; (1/m)*[(m/s)(kg/m2)] => [kg/(m2-s)]

 print("Part 6")
 print("Mass weighted integration [sum] of the divergence of density flux")
;Mass weighted integration [sum] of the divergence of density flux

 duvr_dz = duvr*dz            ;  [kg/(m2-s)][m] => [kg/(m-s)]
 iduvr    = dim_sum_n(duvr_dz, 0)
 iduvr@long_name = "Integrated Mass Wgt MFC" 
 iduvr@LONG_NAME = "Integrated Mass Weighted Density Flux Convergence" 
 iduvr@units     = "kg/(m-s)"
 copy_VarCoords(u(0,:,:), iduvr)      ; (lat,lon)
 delete(duvr_dz)

 VIMFC =  iduvr           ; keep meta data                         
 VIMFC = -VIMFC           ; Note the preceding -1 [negative precedes integration] 
 VIMFC@long_name = "VIMFC"

 print("Part 7")
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

 print("Part 8")
 print("Integrated Density Transport [iur, ivr]")
;Integrated Density Transport [iur, ivr]
;---------------------------------------------------------------------------------------

 delete(res@gsnCenterString)              ; not used for this plot
 res@cnMaxLevelValF       =  100.0          ; max level
 res@cnMinLevelValF       = -res@cnMaxLevelValF     ; min level
 res@cnLevelSpacingF      =  5.0          ; contour interval

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

 print("Part 9")
 print("Divergence of Density Flux")
;Divergence of Density Flux
;---------------------------------------------------------------------------------------

 res@cnMaxLevelValF       =  8000.0          ; max level
 res@cnMinLevelValF       = -res@cnMaxLevelValF     ; min level
 res@cnLevelSpacingF      =  40.0         ; contour interval

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

 print("Part 9.1")
 print("Divergence of Density Flux")
;Divergence of Density Flux
;---------------------------------------------------------------------------------------

 res@cnMaxLevelValF       =  8000.0          ; max level
 res@cnMinLevelValF       = -res@cnMaxLevelValF     ; min level
 res@cnLevelSpacingF      =  40.0         ; contour interval

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

 print("Part 9.2")
 print("Divergence of Density Flux")
;Divergence of Density Flux
;---------------------------------------------------------------------------------------

 res@cnMaxLevelValF       =  8000.0          ; max level
 res@cnMinLevelValF       = -res@cnMaxLevelValF     ; min level
 res@cnLevelSpacingF      =  40.0         ; contour interval

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

 print("Part 10")
 print("Integrated Divergence of Density Flux Convergence [no scaling]")
;Integrated Divergence of Density Flux Convergence [no scaling]

 print("-----")
 printVarSummary(VIMFC)
 printMinMax(VIMFC, 0)

 res@gsnDraw              = True
 res@gsnFrame             = True
 res@lbLabelBarOn         = True        

;res@cnFillPalette        = "cmp_flux"
 res@cnMaxLevelValF       =  2000.0                 ; min level
 res@cnMinLevelValF       = -res@cnMaxLevelValF  ; min level
 res@cnLevelSpacingF      =  10.0                ; contour interval
 res@tiMainString         = "VIMFC"

 plt = gsn_csm_contour_map(wks,VIMFC(:,:) ,res)


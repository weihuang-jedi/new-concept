;===================================================================

 ptop = 1
 ptop@units = "hPa"
 g    = 9.80665          ; m/s2

 diri = "/work2/noaa/gsienkf/weihuang/gfs/data/jan2022/"
 flnm = "monthly_mean_gfs_4_202201_000.nc"

 path = diri+flnm      

 f = addfile(path, "r")

 u = f->UGRD_P0_L100_GLL0(:,:,:)  ; m/s, (level,lat,lon)
 v = f->VGRD_P0_L100_GLL0(:,:,:)
 q = f->SPFH_P0_L100_GLL0(:,:,:)
 ps = f->PRMSL_P0_L101_GLL0(:,:)

;Vertical levels
 ptop@units = "Pa"

 plev = q&lv_ISBL0                   ; [100000,...,30000] Pa [kg/(m-s2)]
 plev@units = "Pa"

;Change [kg/kg] to [g/kg]; not necessary: but common units for q

 q    = q*1000            
 q@units = "g/kg"

;Divergence function [used later] requires S->N grid order

 u  = u(:,::-1,:)  
 v  = v(:,::-1,:)
 q  = q(:,::-1,:)     
 ps =ps(  ::-1,:)       

;Layer thickness: ; Pa=>[kg/(m-s2)], (level,lat,lon) 
;Mass weighting: (dp/g) => [Pa/(m/s2)] => (Pa-s2)/m => [kg/(m-s2)][s2/m] =>  (kg/m2)
;Reference: http://www.cgd.ucar.edu/cas/catalog/newbudgets/

 dp = dpres_plevel_Wrap(plev, ps, ptop, 0) ; Pa; layar thickness 

 dimdp = dimsizes(dp)

 print(dimdp)

 dpg  = dp/g    
 dpg@long_name = "Layer Mass Weighting"
 dpg@units     = "kg/m2"                     ; dp/g, Pa/(m s-2), reduce to kg m-2

;Moisture flux components at each pressure level

 uq = u*q
 uq@long_name = "Zonal Moisture Flux [uq]"
 uq@units = "["+u@units+"]["+q@units+"]"     ; [m/s][g/kg]     
 copy_VarCoords(u,uq)                        ; (level,lat,lon)

 vq = v*q
 vq@long_name = "Meridional Moisture Flux [vq]"
 vq@units = "["+v@units+"]["+q@units+"]" 
 copy_VarCoords(v,vq)                        ; (level,lat,lon)

 printVarSummary(q)                          ; (level,lat,lon); g/kg
 printMinMax(q,0)
 print("-----")
 printVarSummary(u)                          ; (level,lat,lon); m/s
 printMinMax(u,0)
 print("-----")
 printVarSummary(v)
 printMinMax(v,0)
 print("-----")
 printVarSummary(ps)                         ; (lat,lon); Pa => kg/(m-s2) 
 printMinMax(ps,0)
 print("-----")
 printVarSummary(uq)                         ; (level,lat,lon); (m/s)(g/kg)
 printMinMax(uq,0)
 print("-----")
 printVarSummary(vq)
 printMinMax(vq,0)
 print("-----")
 printVarSummary(dp)                         ; (level,lat,lon); Pa => kg/(m-s2)
 printMinMax(dp,0)
 print("-----")
                            ; examine layer thickness at selected locations
 print(dp(:,{40},{180}))    ; mid-Pacific
 print(dp(:,{40},{255}))    ; Boulder, CO 
 print("-----")

;Integrated mass weighted moisture flux components

 uq_dpg = uq*dpg                ; mass weighted 'uq'; [m/s][g/kg][kg/m2]=>[m/s][g/kg]
 iuq    = dim_sum_n(uq_dpg, 0)
 iuq@long_name = "Integrated Zonal UQ [uq*dpg]" 
 iuq@LONG_NAME = "Sum: Mass Weighted Integrated Zonal Moisture Flux [uq*dpg]" 
 iuq@units     = "[m/s][g/kg]"
 copy_VarCoords(u(0,:,:), iuq); (lat,lon)
 delete(uq_dpg)

 vq_dpg = vq*dpg                ; mass weighted 'vq'; [m/s][g/kg][kg/m2]=>[m/s][g/kg] 
 ivq    = dim_sum_n(vq_dpg, 0)
 ivq@long_name = "Integrated Meridional VQ [vq*dpg]" 
 ivq@LONG_NAME = "Sum: Mass Weighted Integrated Meridional Moisture Flux [vq*dpg]" 
 ivq@units     = "[m/s][g/kg]"
 copy_VarCoords(v(0,:,:), ivq); (lat,lon)
 delete(vq_dpg)

;Divergence of moisture flux: uv2dvF => global 'fixed' rectilinear grid

 duvq  = uv2dvF_Wrap(uq, vq)    ; (level,lat,lon)
 duvq@long_name = "Divergence of Moisture Flux"
 duvq@units     = "g/(kg-s)"    ; (1/m)*[(m/s)(g/kg)] => [g/(kg-s)]

;Mass weighted integration [sum] of the divergence of moisture flux

 duvq_dpg = duvq*dpg            ;  [g/(kg-s)][kg/m2] => [g/(m2-s)]
 iduvq    = dim_sum_n(duvq_dpg, 0)
 iduvq@long_name = "Integrated Mass Wgt MFC" 
 iduvq@LONG_NAME = "Integrated Mass Weighted Moisture Flux Convergence" 
 iduvq@units     = "g/(m2-s)"
 copy_VarCoords(u(:,0,:,:), iduvq)      ; (lat,lon)
 delete(duvq_dpg)

 VIMFC =  iduvq           ; keep meta data                         
 VIMFC = -VIMFC           ; Note the preceding -1 [negative precedes integration] 
 VIMFC@long_name = "VIMFC"

;Another way to compute Integrated divergence of moisture flux [iduvq_1]

;IDUVQ = wgt_vertical_n(duvq, dp, 2, 1) 
;iduvq_0 = IDUVQ[0]
;iduvq_0 = iduvq_0/g                   ; complete mass weighting
;iduvq_0@long_name = "Average Mass Weighted MFC" 
;iduvq_0@LONG_NAME = "Average Mass Weighted Moisture Flux Convergence" 
;iduvq_0@units    = "g/(m2-s)"

;iduvq_1 = IDUVQ[1]                    ; same as iuvq_sum
;iduvq_1 = iduvq_1/g
;iduvq_1@long_name = "Integrated MFC" 
;iduvq_1@LONG_NAME = "Integrated Moisture Flux Convergence" 
;iduvq_1@units    = "g/(m2-s)"

 printVarSummary(iuq)                 ; (lat,lon)
 printMinMax(iuq,0)
 print("-----")
 printVarSummary(ivq)                 ; (lat,lon)
 printMinMax(ivq,0)
 print("-----")
 printVarSummary(duvq)                ; (lev,lat,lon)
 printMinMax(duvq,0)
 print("-----")
 printVarSummary(iduvq)               ; (lat,lon)
 printMinMax(iduvq,0)
 print("-----")
;printVarSummary(iduvq_0)             ; (lat,lon)
;printMinMax(iduvq_0,0)
;print("-----")
;printVarSummary(iduvq_1)             ; (lat,lon)
;printMinMax(iduvq_1,0)
;print("-----")

;*************************************************
; Calculate divergence: Use Wrap to include meta data
; Calculate divergent wind components; used for graphics 
;*************************************************
 div = uv2dvF_Wrap(u,v)                ; u,v ==> divergence; (:,:,:,:)

 ud  = new(dimsizes(u), typeof(u), "No_FillValue")
 vd  = new(dimsizes(v), typeof(v), "No_FillValue")
 dv2uvf(div,ud,vd)                     ; divergence ==> divergent components  

 copy_VarCoords(u, ud ) 
 copy_VarCoords(u, vd ) 
 ud@long_name  = "Zonal Divergent Wind"
 ud@units      = u@units
 vd@long_name  = "Meridional Divergent Wind"
 vd@units      = v@units

 printVarSummary(ud)                 ; (level,lat,lon)
 printMinMax(ud,0)
 print("-----")
 printVarSummary(vd)                 ; (level,lat,lon)
 printMinMax(vd,0)
 print("-----")

;*************************************************
; plot results
;*************************************************   
 scl5  = 1e5                                  ; arbitrary: used for nicer plot values
 sclab5= "(10~S~-5~N~)"                       ; used later   
 SCLAB5= "(10~S~5~N~)"           

 scl6  = 1e6  
 sclab6= "(10~S~-6~N~)"         
 SCLAB6= "(10~S~6~N~)"         

 plot := new(2,graphic)

;wks   = gsn_open_wks("png","mfc_div")        ; send graphics to PNG file
 wks   = gsn_open_wks("x11","mfc_div")        ; send graphics to PNG file
 resd                 = True
 resd@cnFillOn        = True                  ; color
 resd@cnLinesOn       = False                 ; turn off contour lines

 resd@cnLevelSelectionMode = "ManualLevels"   ; set manual contour levels
 resd@cnMinLevelValF  = -15.                  ; set min contour level
 resd@cnMaxLevelValF  =  15.                  ; set max contour level
 resd@cnLevelSpacingF =   1.                  ; set contour spacing
 ;resd@cnFillPalette  = "cmocean_balance"     ; NCL 6.5.0
 resd@cnFillPalette   = "ViBlGrWhYeOrRe"

 resd@mpFillOn        = False                 ; turn off map fill
 resd@vcRefMagnitudeF = 3.                    ; make vectors larger
 resd@vcRefLengthF    = 0.025                 ; reference vector length
 resd@vcGlyphStyle    = "CurlyVector"         ; turn on curly vectors
 resd@vcMinDistanceF  = 0.010                 ; thin the vectors
 resd@vcRefAnnoOrthogonalPosF = -1.0          ; move ref vector up
 resd@gsnLeftString   = "Divergent Wind"
 resd@gsnScalarContour= True                  ; vectors over contours
 
 LEVP = 700
 DIV  = div({LEVP},:,:)                     ; keep meta data
 DIV  = DIV*scl6                               ; nicer numbers                 

 resd@tiMainString    = "Divergence and Divergent Winds" 
 resd@gsnCenterString = LEVP+"hPa "
 resd@gsnRightString  = sclab6+" "+div@units
 dplt = gsn_csm_vector_scalar_map(wks,ud({LEVP},:,:),vd({LEVP},:,:),DIV,resd)

;Moisture Transport [uq, vq] at a specified pressure level

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
 res@cnMaxLevelValF       =  140.0        ; max level
 res@cnMinLevelValF       = -res@cnMaxLevelValF     ; min level
 res@cnLevelSpacingF      =   10.0        ; contour interval

 LEVP    = 700
 res@gsnCenterString      = LEVP+"hPa"
 plot(0) = gsn_csm_contour_map(wks,uq({LEVP},:,:),res)
 plot(1) = gsn_csm_contour_map(wks,vq({LEVP},:,:),res)

 resP                     = True                ; modify the panel plot
 resP@gsnPanelMainString  = "Unweighted Moisture Flux Components"
 resP@gsnPanelLabelBar    = True                ; add common colorbar
 gsn_panel(wks,plot,(/2,1/),resP)               ; now draw as one plot

;Integrated Moisture Transport [iuq, ivq]

 delete(res@gsnCenterString)              ; not used for this plot
 res@cnMaxLevelValF       = 10.0          ; min level
 res@cnMinLevelValF       = -res@cnMaxLevelValF     ; min level
 res@cnLevelSpacingF      =  0.5          ; contour interval

 IUQ     = iuq(:,:)                    ; local array: keep meta data
 IUQ     = IUQ/scl5                       ; scale for plot
 res@gsnRightString  = SCLAB5+" "+iuq@units
 plot(0) = gsn_csm_contour_map(wks,IUQ,res)

 IVQ     = ivq(:,:)                    ; local array: keep meta data
 IVQ     = IVQ/scl5
 res@gsnRightString  = SCLAB5+" "+ivq@units
 plot(1) = gsn_csm_contour_map(wks,IVQ,res)

 resP@gsnPanelMainString  = "Mass Wgt. Component Moisture Flux"
 gsn_panel(wks,plot,(/2,1/),resP)               ; now draw as one plot

 delete( [/IUQ, IVQ/] )                   ; no longer needed

;Divergence of Moisture Flux

 res@cnMaxLevelValF       = 100.0          ; min level
 res@cnMinLevelValF       = -res@cnMaxLevelValF     ; min level
 res@cnLevelSpacingF      =  5.0          ; contour interval

 LEVP    = 700
 DUVQ    = duvq({LEVP},:,:)                    ; keep meta data
 DUVQ    = DUVQ*scl6                              ; scale for plot
 res@gsnCenterString = LEVP+"hPa"
 res@gsnRightString  = sclab6+" "+duvq@units
 plot(0) = gsn_csm_contour_map(wks,DUVQ,res)

 LEVP    = 500
 DUVQ    = duvq({LEVP},:,:)                    ; keep meta data
 DUVQ    = DUVQ*scl6
 res@gsnCenterString = LEVP+"hPa"
 res@gsnRightString  = sclab6+" "+duvq@units
 plot(1) = gsn_csm_contour_map(wks,DUVQ,res)

 resP@gsnPanelMainString  = "Divergence of Moisture Flux"
 gsn_panel(wks,plot,(/2,1/),resP)                ; now draw as one plot

 delete(DUVQ)                                        ; no longer needed
 delete([/res@gsnCenterString, res@gsnRightString/]) ; not used in next plot 

;Integrated Divergence of Moisture Flux Convergence [no scaling]

 res@gsnDraw              = True
 res@gsnFrame             = True
 res@lbLabelBarOn         = True        

 ;res@cnFillPalette       = "cmp_flux"
 res@cnMaxLevelValF       =  0.50                ; min level
 res@cnMinLevelValF       = -res@cnMaxLevelValF  ; min level
 res@cnLevelSpacingF      =  0.050               ; contour interval
 res@tiMainString         = "VIMFC"

 plt = gsn_csm_contour_map(wks,VIMFC(:,:) ,res)

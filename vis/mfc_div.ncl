load "categorical.ncl"

;----------------------------------------------------------------------
 diri = "/work2/noaa/gsienkf/weihuang/gfs/data/jan2022/"
 flnm = "monthly_mean_gfs_4_202201.nc"

 dirname = "/work2/noaa/gsienkf/weihuang/gfs/data/jan2022/"
 finame = "monthly_mean_gfs_4_202201.nc"
 foname = "monthly_mean_mfc_202201.nc"

 info = readinfo("datainfo.txt")

 plottype = info(0)
 dirname = info(1)
 finame = info(2)
 foname = info(3)

 fi = dirname+finame
 fo = dirname+foname

 print("fi = " + fi)
 print("fo = " + fo)

 ptop = 1
 ptop@units = "hPa"
 g    = 9.80665          ; m/s2

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
 copy_VarCoords(u(0,:,:), iduvq)      ; (lat,lon)
 delete(duvq_dpg)

 VIMFC =  iduvq           ; keep meta data                         
 VIMFC = -VIMFC           ; Note the preceding -1 [negative precedes integration] 
 VIMFC@long_name = "VIMFC"

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

;printVarSummary(ud)                 ; (level,lat,lon)
;printMinMax(ud,0)
;print("-----")
;printVarSummary(vd)                 ; (level,lat,lon)
;printMinMax(vd,0)
;print("-----")

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

 wks   = gsn_open_wks("png","mfc_div")        ; send graphics to PNG file
;wks   = gsn_open_wks("x11","mfc_div")        ; send graphics to PNG file
 resd                 = True
 resd@cnFillOn        = True                  ; color
 resd@cnLinesOn       = False                 ; turn off contour lines

 resd@cnLevelSelectionMode = "ManualLevels"   ; set manual contour levels
 resd@cnMinLevelValF  = -5.0                  ; set min contour level
 resd@cnMaxLevelValF  =  5.0                  ; set max contour level
 resd@cnLevelSpacingF =  0.5                  ; set contour spacing
;resd@cnFillPalette  = "cmocean_balance"      ; NCL 6.5.0
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
 DIV  = div({LEVP},::3,::3)                   ; keep meta data
 DIV  = DIV*scl6                              ; nicer numbers                 

 resd@tiMainString    = "Divergence and Divergent Winds" 
 resd@gsnCenterString = LEVP+"hPa "
 resd@gsnRightString  = sclab6+" "+div@units
;dplt = gsn_csm_vector_scalar_map(wks,ud({LEVP},:,:),vd({LEVP},:,:),DIV,resd)

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
 res@cnMaxLevelValF       =    0.1        ; max level
 res@cnMinLevelValF       = -res@cnMaxLevelValF     ; min level
 res@cnLevelSpacingF      =    0.005      ; contour interval

 LEVP    = 700
 res@gsnCenterString      = LEVP+"hPa"
 print("-----")
 printVarSummary(uq({LEVP},:,:))
 printMinMax(uq({LEVP},:,:),0)
 print("-----")
 printVarSummary(vq({LEVP},:,:))
 printMinMax(vq({LEVP},:,:),0)
 plot(0) = gsn_csm_contour_map(wks,uq({LEVP},:,:),res)
 plot(1) = gsn_csm_contour_map(wks,vq({LEVP},:,:),res)

 resP                     = True                ; modify the panel plot
 resP@gsnPanelMainString  = "Unweighted Moisture Flux Components"
 resP@gsnPanelLabelBar    = True                ; add common colorbar
 gsn_panel(wks,plot,(/2,1/),resP)               ; now draw as one plot

;Integrated Moisture Transport [iuq, ivq]

 delete(res@gsnCenterString)              ; not used for this plot
 res@cnMaxLevelValF       =  5.0          ; max level
 res@cnMinLevelValF       = -res@cnMaxLevelValF     ; min level
 res@cnLevelSpacingF      =  0.1          ; contour interval

 IUQ     = iuq(:,:)                    ; local array: keep meta data
 IUQ     = IUQ/scl5                       ; scale for plot
 res@gsnRightString  = SCLAB5+" "+iuq@units
 plot(0) = gsn_csm_contour_map(wks,IUQ,res)

 IVQ     = ivq(:,:)                    ; local array: keep meta data
 IVQ     = IVQ/scl5
 res@gsnRightString  = SCLAB5+" "+ivq@units
 plot(1) = gsn_csm_contour_map(wks,IVQ,res)

 print("-----")
 printVarSummary(IUQ)
 printMinMax(IUQ, 0)
 print("-----")
 printVarSummary(IVQ)
 printMinMax(IVQ, 0)

 resP@gsnPanelMainString  = "Mass Wgt. Component Moisture Flux"
 gsn_panel(wks,plot,(/2,1/),resP)               ; now draw as one plot

 delete( [/IUQ, IVQ/] )                   ; no longer needed

;Divergence of Moisture Flux

 res@cnMaxLevelValF       =  0.2          ; max level
 res@cnMinLevelValF       = -res@cnMaxLevelValF     ; min level
 res@cnLevelSpacingF      =  0.01         ; contour interval

 LEVP    = 500
 DUVQ    = duvq({LEVP},:,:)                    ; keep meta data
 DUVQ    = DUVQ*scl6
 res@gsnCenterString = LEVP+"hPa"
 res@gsnRightString  = sclab6+" "+duvq@units
 plot(0) = gsn_csm_contour_map(wks,DUVQ,res)

 print("-----LEVP =" + tostring(LEVP))
 printVarSummary(DUVQ)
 printMinMax(DUVQ, 0)

 LEVP    = 700
 DUVQ    = duvq({LEVP},:,:)                    ; keep meta data
 DUVQ    = DUVQ*scl6                              ; scale for plot
 res@gsnCenterString = LEVP+"hPa"
 res@gsnRightString  = sclab6+" "+duvq@units
 plot(1) = gsn_csm_contour_map(wks,DUVQ,res)

 resP@gsnPanelMainString  = "Divergence of Moisture Flux"
 gsn_panel(wks,plot,(/2,1/),resP)                ; now draw as one plot

 print("-----LEVP =" + tostring(LEVP))
 printVarSummary(DUVQ)
 printMinMax(DUVQ, 0)

 delete(DUVQ)                                        ; no longer needed
 delete([/res@gsnCenterString, res@gsnRightString/]) ; not used in next plot 

;Divergence of Moisture Flux

 res@cnMaxLevelValF       =  0.2          ; max level
 res@cnMinLevelValF       = -res@cnMaxLevelValF     ; min level
 res@cnLevelSpacingF      =  0.01         ; contour interval

 LEVP    = 250
 DUVQ    = duvq({LEVP},:,:)                    ; keep meta data
 DUVQ    = DUVQ*scl6
 res@gsnCenterString = LEVP+"hPa"
 res@gsnRightString  = sclab6+" "+duvq@units
 plot(0) = gsn_csm_contour_map(wks,DUVQ,res)

 print("-----LEVP =" + tostring(LEVP))
 printVarSummary(DUVQ)
 printMinMax(DUVQ, 0)

 LEVP    = 850
 DUVQ    = duvq({LEVP},:,:)                    ; keep meta data
 DUVQ    = DUVQ*scl6                              ; scale for plot
 res@gsnCenterString = LEVP+"hPa"
 res@gsnRightString  = sclab6+" "+duvq@units
 plot(1) = gsn_csm_contour_map(wks,DUVQ,res)

 print("-----LEVP =" + tostring(LEVP))
 printVarSummary(DUVQ)
 printMinMax(DUVQ, 0)

 resP@gsnPanelMainString  = "Divergence of Moisture Flux"
 gsn_panel(wks,plot,(/2,1/),resP)                ; now draw as one plot

 delete(DUVQ)                                        ; no longer needed
 delete([/res@gsnCenterString, res@gsnRightString/]) ; not used in next plot

;Divergence of Moisture Flux

 res@cnMaxLevelValF       =  0.2          ; max level
 res@cnMinLevelValF       = -res@cnMaxLevelValF     ; min level
 res@cnLevelSpacingF      =  0.01         ; contour interval

 LEVP    = 150
 DUVQ    = duvq({LEVP},:,:)                    ; keep meta data
 DUVQ    = DUVQ*scl6
 res@gsnCenterString = LEVP+"hPa"
 res@gsnRightString  = sclab6+" "+duvq@units
 plot(0) = gsn_csm_contour_map(wks,DUVQ,res)

 print("-----LEVP =" + tostring(LEVP))
 printVarSummary(DUVQ)
 printMinMax(DUVQ, 0)

 LEVP    = 950
 DUVQ    = duvq({LEVP},:,:)                    ; keep meta data
 DUVQ    = DUVQ*scl6                              ; scale for plot
 res@gsnCenterString = LEVP+"hPa"
 res@gsnRightString  = sclab6+" "+duvq@units
 plot(1) = gsn_csm_contour_map(wks,DUVQ,res)

 print("-----LEVP =" + tostring(LEVP))
 printVarSummary(DUVQ)
 printMinMax(DUVQ, 0)

 resP@gsnPanelMainString  = "Divergence of Moisture Flux"
 gsn_panel(wks,plot,(/2,1/),resP)                ; now draw as one plot

 delete(DUVQ)                                        ; no longer needed
 delete([/res@gsnCenterString, res@gsnRightString/]) ; not used in next plot

;Integrated Divergence of Moisture Flux Convergence [no scaling]

 print("-----")
 printVarSummary(VIMFC)
 printMinMax(VIMFC, 0)

 res@gsnDraw              = True
 res@gsnFrame             = True
 res@lbLabelBarOn         = True        

;res@cnFillPalette        = "cmp_flux"
 res@cnMaxLevelValF       =  0.2                 ; min level
 res@cnMinLevelValF       = -res@cnMaxLevelValF  ; min level
 res@cnLevelSpacingF      =  0.01                ; contour interval
 res@tiMainString         = "VIMFC"

 plt = gsn_csm_contour_map(wks,VIMFC(:,:) ,res)


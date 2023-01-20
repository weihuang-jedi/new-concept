;===================================================================
 diri = "/work2/noaa/gsienkf/weihuang/gfs/data/jan2022/"
 flnm = "dfc_20220116_00.nc"
 fi = diri+flnm      

 f = addfile(fi, "r")

 duvr = f->duvr(:,:,:)  ; m/s, (level,lat,lon)
 iduvr = f->iduvr(:,:)

 iduvr = smth9_Wrap_n(iduvr, 0.50, 0.25, True)
 iduvr = smth9_Wrap_n(iduvr, 0.50, 0.25, True)

 print("plot results")
;*************************************************
; plot results
;*************************************************   
 scl6  = 1e6  
 sclab6= "(10~S~-6~N~)"         
 SCLAB6= "(10~S~6~N~)"         

;---------------------------------------------------------------------------------------
;Integrated Divergence of Density Flux Convergence [no scaling]

 print("-----")
 printVarSummary(iduvr)
 printMinMax(iduvr, 0)

;wks   = gsn_open_wks("png","dfc_div")        ; send graphics to PNG file
 wks   = gsn_open_wks("x11","dfc_div")        ; send graphics to PNG file

 res                      = True
 res@gsnDraw              = True
 res@gsnFrame             = True
 res@lbLabelBarOn         = True        

 res@cnFillOn          = True             ; turn on color
 res@cnLinesOn         = False            ; turn off contour lines
;res@cnFillPalette        = "cmp_flux"
;res@cnLevelSelectionMode = "AutomaticLevels"
 res@cnFillPalette     = "ViBlGrWhYeOrRe" ; set White-in-Middle color map
 res@lbLabelBarOn      = False            ; turn off individual cb's
 res@mpFillOn          = False            ; turn off map fill
                                          ; Use a common scale
 res@cnLevelSelectionMode = "ManualLevels"; manual set levels so lb consistent
 res@cnMaxLevelValF       =   2.0e13
 res@cnMinLevelValF       = -res@cnMaxLevelValF     ; min level
 res@cnLevelSpacingF      =    1.0e12

 res@tiMainString         = "VIDFC"

 plt = gsn_csm_contour_map(wks,iduvr,res)


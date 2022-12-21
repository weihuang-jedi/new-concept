;----------------------------------------------------------------------
undef("panel_div_density_flux")
procedure panel_div_density_flux(ddf:float, plottype:string, imgname:string)
begin
;************************************************
; create plot
;************************************************
  plot = new(2,graphic)
  wks = gsn_open_wks(plottype, imgname)

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

  resP                     = True                ; modify the panel plot
  resP@gsnPanelMainString  = "Unweighted Density Flux Components"
  resP@gsnPanelLabelBar    = True                ; add common colorbar
  gsn_panel(wks,plot,(/2,1/),resP)               ; now draw as one plot

  delete(wks)
  delete(res)
  delete(resP)
  delete(plot)
end

;----------------------------------------------------------------------
undef("plot_div_density_flux")
procedure plot_div_density_flux(ddf:float, plottype:string, imgname:string)
begin
;************************************************
; create plot
;************************************************
  wks = gsn_open_wks(plottype, imgname)

  res                   = True             ; plot mods desired
  res@gsnDraw           = True
  res@gsnFrame          = True
  res@lbLabelBarOn      = True

  res@cnFillOn          = True             ; turn on color
  res@cnLinesOn         = False            ; turn off contour lines
  res@cnLineLabelsOn    = False            ; turn off contour lines
  res@cnFillPalette     = "ViBlGrWhYeOrRe" ; set White-in-Middle color map
  res@mpFillOn          = False            ; turn off map fill

  res@cnLevelSelectionMode = "ManualLevels"; manual set levels so lb consistent
  res@cnMaxLevelValF       =  0.02               ; max level
  res@cnMinLevelValF       = -res@cnMaxLevelValF  ; min level
  res@cnLevelSpacingF      =  0.001                ; contour interval
  res@tiMainString         = "VIDDF"

  plt = gsn_csm_contour_map(wks, ddf, res)

  delete(wks)
  delete(res)
  delete(plt)
end


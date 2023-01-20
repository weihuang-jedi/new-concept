undef("readinfo")
function readinfo(filename:string)
begin
 ;Read data into a one-dimensional string array of unknown length:
  filename = "datainfo.txt"
  info     = asciiread(filename,-1,"string")
  nlines   = dimsizes(info)

  print("The <" + filename + "> has " + nlines + " lines.")
  print("<" + info + ">")    ; Print the lines

  return info
end

;----------------------------------------------------------------------
undef("plot_categorical")
procedure plot_categorical(x:float, plottype:string, imgname:string, title:string, hgt:float)
begin
  info  = (/ " 1 ThermDyn High", \
             " 2 ThermDyn Low ", \
             " 3 Warm High   ", \
             " 4 Cold Low    ", \
             " 5 Warm Low    ", \
             " 6 Cold High   " /)
  ninfo = dimsizes(info)

;************************************************
; create plot
;************************************************
 ;wks = gsn_open_wks("png","vegland")        ; send graphics to PNG file
 ;wks = gsn_open_wks("x11","cate")        ; send graphics to PNG file
  wks = gsn_open_wks(plottype, imgname)

  res                  = True                ; plot mods desired
  res@gsnDraw          = False
  res@gsnFrame         = False
  res@gsnMaximize      = True 

  res@cnFillOn         = True               ; color Fill 
  res@cnFillMode       = "RasterFill"       ; Raster Mode
  res@cnLinesOn        = False              ; Turn off contour lines

  res@cnFillPalette     = "default"
  res@cnSpanFillPalette = False

  res@cnLineLabelsOn   = False              ; Turn off contour line labels

  res@cnLevelSelectionMode = "ExplicitLevels"              ; set explict contour levels
 ;res@cnLevels         = integertobyte( ispan(1,ninfo-1,1) ) ; one less than ninfo
  res@cnLevels         = (/2, 3, 4, 5, 6/)
  res@cnFillColors = (/"Magenta", "Navyblue", "Orange", "Cyan", "Red", "Blue"/)
  res@lbLabelPosition  = "Center"           ; label position
  res@lbLabelAlignment = "BoxCenters"       ; label orientation
  res@lbLabelStrings   = ispan(1,ninfo,1)  

  res@tiMainString     = title

  res@pmLabelBarHeightF        =  0.075
 ;res@pmLabelBarWidthF         =  0.60      ; default is 0.6
 ;res@pmLabelBarOrthogonalPosF = -0.0005    ; move up smidge

  res@mpCenterLonF     = 0                  ; set map center
  res@mpFillOn         = False

 ;res@gsnRightString   = fili

  x = lonFlip(x)
  plot = gsn_csm_contour_map_ce(wks, x, res) ; create plot

  rtxt = True
  rtxt@txJust        = "CenterLeft"
  rtxt@txFontHeightF = 0.010 
                            ; 1 rows x 6 columns of text
  n  = -1
  xx = 0.20                 ; arbitrary
  do ncol=0,5
     yy = 0.20 
    do nrow=0,0
       n = n+1
       gsn_text_ndc (wks,info(n),xx,yy,rtxt)
       yy = yy - 3*rtxt@txFontHeightF
    end do
     xx = xx + 0.11 
  end do
  draw(plot)
  frame(wks)
end

;----------------------------------------------------------------------
undef("plot_avg_cate_section")
procedure plot_avg_cate_section(x:float, plottype:string, imgname:string, title:string)
begin
  info  = (/ " 1 ThermDyn High", \
             " 2 ThermDyn Low ", \
             " 3 Warm High   ", \
             " 4 Cold Low    ", \
             " 5 Warm Low    ", \
             " 6 Cold High   " /)
  ninfo = dimsizes(info)

;************************************************
; create plot
;************************************************
  wks = gsn_open_wks(plottype, imgname)

  print("Imagename: " + imgname)

  res                  = True                ; plot mods desired
  res@gsnDraw          = False
  res@gsnFrame         = False
  res@gsnMaximize      = True 

  res@cnFillOn         = True               ; color Fill 
  res@cnFillMode       = "RasterFill"       ; Raster Mode
  res@cnLinesOn        = False              ; Turn off contour lines

  res@cnFillPalette     = "default"
  res@cnSpanFillPalette = False

  res@cnLineLabelsOn   = False              ; Turn off contour line labels

  res@cnLevelSelectionMode = "ExplicitLevels"              ; set explict contour levels
 ;res@cnLevels         = integertobyte( ispan(1,ninfo-1,1) ) ; one less than ninfo
  res@cnLevels         = (/2, 3, 4, 5, 6/)
  res@cnFillColors = (/"Magenta", "Navyblue", "Orange", "Cyan", "Red", "Blue"/)
  res@lbLabelPosition  = "Center"           ; label position
  res@lbLabelAlignment = "BoxCenters"       ; label orientation
  res@lbLabelStrings   = ispan(1,ninfo,1)  

  res@tiMainString     = title

  res@pmLabelBarHeightF        =  0.075
 ;res@pmLabelBarWidthF         =  0.60      ; default is 0.6
 ;res@pmLabelBarOrthogonalPosF = -0.0005    ; move up smidge

  res@mpFillOn         = False
 ;res@gsnRightString   = fili

  printVarSummary(x)

  sect = dim_avg_Wrap(x) 
  plot = gsn_csm_pres_hgt(wks,sect(0:300,:),res) ; create plot

  rtxt = True
  rtxt@txJust        = "CenterLeft"
  rtxt@txFontHeightF = 0.010 
                            ; 1 rows x 6 columns of text
  n  = -1
  xx = 0.18                 ; arbitrary
  do ncol=0,5
     yy = 0.025 
    do nrow=0,0
       n = n+1
       gsn_text_ndc (wks,info(n),xx,yy,rtxt)
       yy = yy - 3*rtxt@txFontHeightF
    end do
     xx = xx + 0.12
  end do
  draw(plot)
  frame(wks)
end

;----------------------------------------------------------------------
undef("plot_cate_section")
procedure plot_cate_section(x:float, plottype:string, lon:integer, \
                            imgname:string, title:string)
begin
  info  = (/ " 1 ThermDyn High", \
             " 2 ThermDyn Low ", \
             " 3 Warm High   ", \
             " 4 Cold Low    ", \
             " 5 Warm Low    ", \
             " 6 Cold High   " /)
  ninfo = dimsizes(info)

;************************************************
; create plot
;************************************************
 ;wks = gsn_open_wks("png","vegland")        ; send graphics to PNG file
 ;wks = gsn_open_wks("x11","cate")        ; send graphics to PNG file
  wks = gsn_open_wks(plottype, imgname)

  res                  = True                ; plot mods desired
  res@gsnDraw          = False
  res@gsnFrame         = False
  res@gsnMaximize      = True 

  res@cnFillOn         = True               ; color Fill 
  res@cnFillMode       = "RasterFill"       ; Raster Mode
  res@cnLinesOn        = False              ; Turn off contour lines

  res@cnFillPalette     = "default"
  res@cnSpanFillPalette = False

  res@cnLineLabelsOn   = False              ; Turn off contour line labels

  res@cnLevelSelectionMode = "ExplicitLevels"              ; set explict contour levels
 ;res@cnLevels         = integertobyte( ispan(1,ninfo-1,1) ) ; one less than ninfo
  res@cnLevels         = (/2, 3, 4, 5, 6/)
  res@cnFillColors = (/"Magenta", "Navyblue", "Orange", "Cyan", "Red", "Blue"/)
  res@lbLabelPosition  = "Center"           ; label position
  res@lbLabelAlignment = "BoxCenters"       ; label orientation
  res@lbLabelStrings   = ispan(1,ninfo,1)  

  res@tiMainString     = title

  res@pmLabelBarHeightF        =  0.075
 ;res@pmLabelBarWidthF         =  0.60      ; default is 0.6
 ;res@pmLabelBarOrthogonalPosF = -0.0005    ; move up smidge

  res@mpFillOn         = False
 ;res@gsnRightString   = fili

  printVarSummary(x)

  sect = x(:, :, lon)
  plot = gsn_csm_pres_hgt(wks,sect(0:300,:),res) ; create plot

  rtxt = True
  rtxt@txJust        = "CenterLeft"
  rtxt@txFontHeightF = 0.010 
                            ; 1 rows x 6 columns of text
  n  = -1
  xx = 0.18                 ; arbitrary
  do ncol=0,5
     yy = 0.025 
    do nrow=0,0
       n = n+1
       gsn_text_ndc (wks,info(n),xx,yy,rtxt)
       yy = yy - 3*rtxt@txFontHeightF
    end do
     xx = xx + 0.12
  end do
  draw(plot)
  frame(wks)
end

;----------------------------------------------------------------------
undef("write2file")
procedure write2file(alt:float, lat:float, lon:float, cate:float, flnm:string)
begin
  system("/bin/rm -f " + flnm)   ; remove any pre-existing file
  ncdf = addfile(flnm, "c")  ; open output netCDF file

 ;===================================================================
 ; create global attributes of the file (optional)
 ;===================================================================
  fAtt               = True            ; assign file attributes
  fAtt@title         = "NCL Write Category file"
  fAtt@source_file   = "Calculated from NCL script"
  fAtt@Conventions   = "None"
  fAtt@creation_date = systemfunc ("date")
  fileattdef( ncdf, fAtt )            ; copy file attributes

 ;===================================================================
 ; output variables directly; NCL will call appropriate functions
 ; to write the meta data associated with each variable
 ;===================================================================
  cate!0 = "alt"
  cate!1 = "lat"
  cate!2 = "lon"
  cate&alt = alt
  cate&lat = lat
  cate&lon = lon

  ncdf->cate = cate

  delete(ncdf)
end

;----------------------------------------------------------------------
undef("write_dfc_div")
procedure write_dfc_div(alt:integer, lat:float, lon:float, idfc:double, dfc:double, flnm:string)
begin
  system("/bin/rm -f " + flnm)   ; remove any pre-existing file
  ncdf = addfile(flnm, "c")  ; open output netCDF file

 ;===================================================================
 ; create global attributes of the file (optional)
 ;===================================================================
  fAtt               = True            ; assign file attributes
  fAtt@title         = "NCL Write Divergence of density flux"
  fAtt@source_file   = "Calculated from NCL script"
  fAtt@Conventions   = "None"
  fAtt@creation_date = systemfunc ("date")
  fileattdef( ncdf, fAtt )            ; copy file attributes

 ;===================================================================
 ; output variables directly; NCL will call appropriate functions
 ; to write the meta data associated with each variable
 ;===================================================================

  idfc!0 = "lat"
  idfc!1 = "lon"
  idfc&lat = lat
  idfc&lon = lon

  printVarSummary(idfc)

  ncdf->idfc = idfc

  dfc!0 = "alt"
  dfc!1 = "lat"
  dfc!2 = "lon"
  dfc&alt = alt
  dfc&lat = lat
  dfc&lon = lon

  printVarSummary(dfc)

  ncdf->dfc = dfc

  delete(ncdf)
end

;----------------------------------------------------------------------
undef("plot_categorical_polar")
procedure plot_categorical_polar(x:float, plottype:string, imgname:string,
                                 title:string, hgt:float, hemisphere:string)
begin
  info  = (/ " 1 ThermDyn High", \
             " 2 ThermDyn Low ", \
             " 3 Warm High   ", \
             " 4 Cold Low    ", \
             " 5 Warm Low    ", \
             " 6 Cold High   " /)
  ninfo = dimsizes(info)

;************************************************
; create plot
;************************************************
 ;wks = gsn_open_wks("png","vegland")        ; send graphics to PNG file
 ;wks = gsn_open_wks("x11","cate")        ; send graphics to PNG file
  wks = gsn_open_wks(plottype, imgname)

  res                  = True                ; plot mods desired
  res@gsnDraw          = False
  res@gsnFrame         = False
  res@gsnMaximize      = True 
  res@gsnPolar         = hemisphere          ; specify the hemisphere

  res@cnFillOn         = True               ; color Fill 
  res@cnFillMode       = "RasterFill"       ; Raster Mode
  res@cnLinesOn        = False              ; Turn off contour lines

  res@cnFillPalette     = "default"
  res@cnSpanFillPalette = False

  res@cnLineLabelsOn   = False              ; Turn off contour line labels

  res@cnLevelSelectionMode = "ExplicitLevels"              ; set explict contour levels
 ;res@cnLevels         = integertobyte( ispan(1,ninfo-1,1) ) ; one less than ninfo
  res@cnLevels         = (/2, 3, 4, 5, 6/)
  res@cnFillColors = (/"Magenta", "Navyblue", "Orange", "Cyan", "Red", "Blue"/)
  res@lbLabelPosition  = "Center"           ; label position
  res@lbLabelAlignment = "BoxCenters"       ; label orientation
  res@lbLabelStrings   = ispan(1,ninfo,1)  

  res@tiMainString     = title

  res@pmLabelBarHeightF        =  0.075
 ;res@pmLabelBarWidthF         =  0.60      ; default is 0.6
 ;res@pmLabelBarOrthogonalPosF = -0.0005    ; move up smidge

  res@mpCenterLonF     = 0                  ; set map center
  res@mpFillOn         = False

 ;res@gsnRightString   = fili

 ;x = lonFlip(x)
  plot = gsn_csm_contour_map_polar(wks, x, res) 

  rtxt = True
  rtxt@txJust        = "CenterLeft"
  rtxt@txFontHeightF = 0.010 
                            ; 1 rows x 6 columns of text
  n  = -1
  xx = 0.16                 ; arbitrary
  do ncol=0,5
     yy = 0.06
    do nrow=0,0
       n = n+1
       gsn_text_ndc (wks,info(n),xx,yy,rtxt)
       yy = yy - 3*rtxt@txFontHeightF
    end do
     xx = xx + 0.115
  end do
  draw(plot)
  frame(wks)
end


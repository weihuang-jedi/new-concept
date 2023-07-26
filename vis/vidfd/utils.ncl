undef("readinfo")
function readinfo(filename:string)
begin
 ;Read data into a one-dimensional string array of unknown length:
 ;filename = "datainfo.txt"
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
undef("plot_type")
procedure plot_type(x:float, plottype:string, imgname:string, title:string, hgt:float)
begin
  info  = (/ " 1 Thermal-Dynamic", \
             " 2 Thermal Systems", \
             " 3 Dynamic Systems" /)
  ninfo = dimsizes(info)

;************************************************
; create plot
;************************************************
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
  res@cnLevels         = (/2, 3/)
  res@cnFillColors = (/"Blue", "Cyan", "Red"/)
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
  do ncol=0,2
     yy = 0.20 
    do nrow=0,0
       n = n+1
       gsn_text_ndc (wks,info(n),xx,yy,rtxt)
       yy = yy - 3*rtxt@txFontHeightF
    end do
     xx = xx + 0.23 
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
procedure write2file(T:float, P:float, cate:float, flnm:string)
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
  ncdf->T = T
  ncdf->P = P

 ;alt!0 = "alt"
 ;alt&alt = alt
 ;alt@units = "meter"

  cate!0 = "alt"
  cate!1 = "lat"
  cate!2 = "lon"
  cate&alt = T&alt
  cate&lat = T&lat
  cate&lon = T&lon

  ncdf->cate = cate

 ;delete(ncdf)
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

;----------------------------------------------------------------------
undef("write_mfc")
procedure write_mfc(duvq:float, iduvq:float, flnm:string)
begin
  system("/bin/rm -f " + flnm)   ; remove any pre-existing file
  ncdf = addfile(flnm, "c")  ; open output netCDF file

 ;===================================================================
 ; create global attributes of the file (optional)
 ;===================================================================
  fAtt               = True            ; assign file attributes
  fAtt@title         = "NCL calculated Moisture Flux Divergence"
  fAtt@source_file   = "Calculated from NCL script: cal-mfc-div"
  fAtt@Conventions   = "None"
  fAtt@creation_date = systemfunc ("date")
  fileattdef( ncdf, fAtt )            ; copy file attributes

 ;===================================================================
 ; output variables directly; NCL will call appropriate functions
 ; to write the meta data associated with each variable
 ;===================================================================
  ncdf->duvq = duvq
  ncdf->iduvq = iduvq

  delete(ncdf)
end

;----------------------------------------------------------------------
undef("write_div")
procedure write_div(vidfd:float, dfd:float, div:float, flnm:string)
begin
  system("/bin/rm -f " + flnm)   ; remove any pre-existing file
  ncdf = addfile(flnm, "c")  ; open output netCDF file

 ;===================================================================
 ; create global attributes of the file (optional)
 ;===================================================================
  fAtt               = True            ; assign file attributes
  fAtt@title         = "NCL calculated Density Flux Divergence"
  fAtt@source_file   = "Calculated from NCL script: plot-vidfd.template"
  fAtt@Conventions   = "None"
  fAtt@creation_date = systemfunc ("date")
  fileattdef( ncdf, fAtt )            ; copy file attributes

 ;===================================================================
 ; output variables directly; NCL will call appropriate functions
 ; to write the meta data associated with each variable
 ;===================================================================
  ncdf->vidfd = vidfd
  ncdf->dfd = dfd
  ncdf->div = div

  delete(ncdf)
end

;----------------------------------------------------------------------
undef("get_res4precipitation")
function get_res4precipitation(title:string)
begin
  res                   = True             ; plot mods desired
  res@gsnDraw           = True
  res@gsnFrame          = True
  res@lbLabelBarOn      = True

  res@cnFillOn          = True             ; turn on color
  res@cnLinesOn         = False            ; turn off contour lines
  res@cnLineLabelsOn    = False            ; turn off contour lines
  res@cnFillPalette     = "ViBlGrWhYeOrRe" ; set White-in-Middle color map
  res@lbLabelBarOn      = True             ; turn off individual cb's
  res@mpFillOn          = False            ; turn off map fill
                                           ; Use a common scale
 ;res@lbOrientation        = "Vertical"     ; vertical label bar
  res@cnLevelSelectionMode = "ExplicitLevels"
  res@cnLevels             = (/0.01, 0.02, 0.05, 0.1, \
                               0.2, 0.5, 1.0, 2.0, 5.0/)
  res@cnFillColors         = (/"white", "cyan", "green", "springgreen", "yellow", \
                               "orange", "orangered", "red", "magenta", "pink"/)
  res@tiMainString         = title

  return res
end

;----------------------------------------------------------------------
undef("plot_precipitation")
procedure plot_precipitation(var:float, name:string, plottype:string, imgname:string)
begin
  wks = gsn_open_wks(plottype, imgname)
  res = get_res4precipitation(name)

 ;--------------------------------------------------------------------------------------
 ;Integrated Divergence of Density Flux Convergence [no scaling]
  printMinMax(var, 0)

  plt = gsn_csm_contour_map(wks,var,res)
end

;----------------------------------------------------------------------
undef("get_res4pw")
function get_res4pw(title:string)
begin
  res                   = True             ; plot mods desired
  res@gsnDraw           = True
  res@gsnFrame          = True
  res@lbLabelBarOn      = True

  res@cnFillOn          = True             ; turn on color
  res@cnLinesOn         = False            ; turn off contour lines
  res@cnLineLabelsOn    = False            ; turn off contour lines
  res@cnFillPalette     = "ViBlGrWhYeOrRe" ; set White-in-Middle color map
  res@lbLabelBarOn      = True             ; turn off individual cb's
  res@mpFillOn          = False            ; turn off map fill
                                           ; Use a common scale
 ;res@lbOrientation        = "Vertical"     ; vertical label bar
  res@cnLevelSelectionMode = "ExplicitLevels"
  res@cnLevels             = (/1.0, 2.0, 4.0, 8.0, \
                               10.0, 20.0, 40.0, 50.0, 60.0/)
  res@cnFillColors         = (/"white", "cyan", "green", "springgreen", "yellow", \
                               "orange", "orangered", "red", "magenta", "pink"/)
  res@tiMainString         = title

  return res
end

;----------------------------------------------------------------------
undef("plot_pw")
procedure plot_pw(var:float, name:string, plottype:string, imgname:string)
begin
  wks = gsn_open_wks(plottype, imgname)
  res = get_res4pw(name)

 ;--------------------------------------------------------------------------------------
  printMinMax(var, 0)

  plt = gsn_csm_contour_map(wks,var,res)
end

;----------------------------------------------------------------------
undef("get_div")
function get_div(u:float, v:float)
begin
 ;----------------------------------------------------------------------
  div = uv2dvF_Wrap(u, v)    ; (level,lat,lon)
  scale = 1.0e6
  div = scale*div
  div@long_name = "Divergence"
  div@units     = "1/s"    ; (1/m)*[(m/s)(g/kg)] => [g/(kg-s)]
  copy_VarCoords(u, div)

  return div
end


;----------------------------------------------------------------------
undef("get_dfd")
function get_dfd(u:float, v:float, t:float)
begin
  plev = t&lv_ISBL0                   ; [100000,...,30000] Pa [kg/(m-s2)]
  plev@units = "Pa"

 ;Vertical levels
  ptop = plev(0)
  ptop@units = "Pa"

  rho = t
  copy_VarCoords(t,rho)
  rho@units = "kg/kg"

  g = 9.806
  R = 287.0
  dims = dimsizes(t)
  do k = 0, dims(0)-1
     rho(k,:,:) = plev(k)/(R*t(k,:,:))
  end do

 ;----------------------------------------------------------------------
 ;Density flux components at each pressure level
  urho = u*rho
  vrho = v*rho

 ;----------------------------------------------------------------------
  scale = 1.0e6

  duvrho = uv2dvF_Wrap(urho, vrho)    ; (level,lat,lon)
  duvrho = scale*duvrho
  copy_VarCoords(u, duvrho)
  duvrho@long_name = "Divergence of Density Flux"
  duvrho@units     = "g/(kg-s)"    ; (1/m)*[(m/s)(g/kg)] => [g/(kg-s)]
  delete(urho)
  delete(vrho)

  return duvrho
end

;----------------------------------------------------------------------
undef("get_vidfd")
function get_vidfd(u:float, v:float, t:float, ps:float)
begin
  plev = t&lv_ISBL0                   ; [100000,...,30000] Pa [kg/(m-s2)]
  plev@units = "Pa"

 ;Vertical levels
  ptop = plev(0)
  ptop@units = "Pa"

  rho = t
  copy_VarCoords(t,rho)
  rho@units = "kg/kg"

  g = 9.806
  R = 287.0
  dims = dimsizes(t)
  do k = 0, dims(0)-1
     rho(k,:,:) = plev(k)/(R*t(k,:,:))
  end do

 ;----------------------------------------------------------------------
 ;Layer thickness: ; Pa=>[kg/(m-s2)], (level,lat,lon) 
 ;Mass weighting: (dp/g) => [Pa/(m/s2)] => (Pa-s2)/m => [kg/(m-s2)][s2/m] =>  (kg/m2)
 ;Reference: http://www.cgd.ucar.edu/cas/catalog/newbudgets/

  dp = dpres_plevel_Wrap(plev, ps, ptop, 0) ; Pa; layar thickness 

  dimdp = dimsizes(dp)

 ;print(dimdp)

  dpg  = dp/g    
  dpg@long_name = "Layer Mass Weighting"
  dpg@units     = "kg/m2"                     ; dp/g, Pa/(m s-2), reduce to kg m-2

 ;----------------------------------------------------------------------
 ;Density flux components at each pressure level

  urho = u*rho
  vrho = v*rho

 ;----------------------------------------------------------------------
  duvrho = uv2dvF_Wrap(urho, vrho)    ; (level,lat,lon)
  copy_VarCoords(u, duvrho)
  duvrho@long_name = "Divergence of Density Flux"
  duvrho@units     = "g/(kg-s)"    ; (1/m)*[(m/s)(g/kg)] => [g/(kg-s)]
  delete(urho)
  delete(vrho)

 ;----------------------------------------------------------------------
 ;Mass weighted integration [sum] of the divergence of density flux

  duvrho_dpg = duvrho*dpg            ;  [g/(kg-s)][kg/m2] => [g/(m2-s)]
  iduvrho    = dim_sum_n(duvrho_dpg, 0)
  iduvrho@long_name = "Integrated Mass Wgt DFC"
  iduvrho@LONG_NAME = "Integrated Mass Weighted Density Flux Convergence"
  iduvrho@units     = "g/(m2-s)"
  delete(duvrho_dpg)

  VIDFD =  iduvrho           ; keep meta data
  VIDFD = -1000.0*VIDFD           ; Note the preceding -1 [negative precedes integration]
  VIDFD@long_name = "VIDFD"
  VIDFD@units     = "g/(m2-s)"
  copy_VarCoords(u(0,:,:), VIDFD)
  delete(iduvrho)

  return VIDFD
end


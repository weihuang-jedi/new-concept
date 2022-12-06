;----------------------------------------------------------------------
undef("plot_categorical")
procedure plot_categorical(x)
begin
  info  = (/ " 1 Thermal High", \
             " 2 Thermal Low ", \
             " 3 Warm High   ", \
             " 4 Cold Low    ", \
             " 5 Warm Low    ", \
             " 6 Cold High   ", \
             " 0 Unknown     ", \
             "-1 Impossbile  " /) ; n=7
  ninfo = dimsizes(info)

;************************************************
; create plot
;************************************************
 ;wks = gsn_open_wks("png","vegland")        ; send graphics to PNG file
  wks = gsn_open_wks("x11","cate")        ; send graphics to PNG file

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
  res@cnLevels         = integertobyte( ispan(1,ninfo-1,1) ) ; one less than ninfo

  res@lbLabelPosition  = "Center"           ; label position
  res@lbLabelAlignment = "BoxCenters"       ; label orientation
  res@lbLabelStrings   = ispan(2,ninfo,1)  

  res@pmLabelBarHeightF        =  0.075
 ;res@pmLabelBarWidthF         =  0.60      ; default is 0.6
 ;res@pmLabelBarOrthogonalPosF = -0.0005    ; move up smidge

  res@mpCenterLonF     = 0                  ; set map center
  res@mpFillOn         = False

 ;res@gsnRightString   = fili
  plot = gsn_csm_contour_map_ce(wks, x, res) ; create plot

  rtxt = True
  rtxt@txJust        = "CenterLeft"
  rtxt@txFontHeightF = 0.010 
                            ; 3 rows x 6 columns of text
  n  = -1
  xx = 0.05                 ; arbitrary
  do ncol=0,3
     yy = 0.22 
    do nrow=0,1
       n = n+1
       gsn_text_ndc (wks,info(n),xx,yy,rtxt)
       yy = yy - 3*rtxt@txFontHeightF
    end do
     xx = xx + 0.155 
  end do
  draw(plot)
  frame(wks)
end


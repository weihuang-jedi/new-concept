load "utils.ncl"

;----------------------------------------------------------------------
 info = readinfo("datainfo_00.txt")

 plottype = info(0)
 dirname = info(1)
 finame = info(2)
 foname = info(3)
 imgname = info(4)
 title = info(5)

 fi = dirname+finame
 fo = dirname+foname

 print("fi = " + fi)
 print("fo = " + fo)

 f = addfile(fi, "r")

 u = f->UGRD_P0_L100_GLL0(:,:,:)  ; m/s, (level,lat,lon)
 v = f->VGRD_P0_L100_GLL0(:,:,:)
 t = f->TMP_P0_L100_GLL0(:,:,:)
 ps = f->PRMSL_P0_L101_GLL0(:,:)

;Divergence function [used later] requires S->N grid order
 u  = u(:,::-1,:)  
 v  = v(:,::-1,:)
 t  = t(:,::-1,:)     
 ps =ps(  ::-1,:)       

 lat_0 = u@lat_0
 lat_0 = lat_0[::-1]
 u@lat_0 = lat_0

;--------------------------------------------------------------------------------------
 div = get_div(u, v)
 dfd = get_dfd(u, v, t)
 vidfd = get_vidfd(u, v, t, ps)

;--------------------------------------------------------------------------------------
 print("-----")
 printVarSummary(vidfd)
 printMinMax(vidfd, 0)

 write_div(vidfd, dfd, div, fo)

;--------------------------------------------------------------------------------------
 wks   = gsn_open_wks(plottype, imgname)        ; send graphics to PNG file

 res                   = True             ; plot mods desired
 res@gsnDraw           = True
 res@gsnFrame          = True
 res@lbLabelBarOn      = True        

 res@cnFillOn          = True             ; turn on color
 res@cnLinesOn         = False            ; turn off contour lines
 res@cnLineLabelsOn    = False            ; turn off contour lines
 res@cnFillPalette     = "ViBlGrWhYeOrRe" ; set White-in-Middle color map
 res@lbLabelBarOn      = False            ; turn off individual cb's
 res@mpFillOn          = False            ; turn off map fill
                                          ; Use a common scale
 res@cnLevelSelectionMode = "ManualLevels"; manual set levels so lb consistent
 res@cnMaxLevelValF       = 10.0                  ; min level
 res@cnMinLevelValF       = -res@cnMaxLevelValF  ; min level
 res@cnLevelSpacingF      =  1.0                  ; contour interval
 res@tiMainString         = title

;--------------------------------------------------------------------------------------
;Integrated Divergence of Density Flux Convergence [no scaling]

 pvar := vidfd
 plt = gsn_csm_contour_map(wks,pvar,res)


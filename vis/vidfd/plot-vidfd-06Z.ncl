load "utils.ncl"

;----------------------------------------------------------------------
 pinfo = readinfo("varinfo_06Z.txt")
 phour = pinfo(0)
 pmonth = pinfo(1)
 pyear = pinfo(2)
;pvarname = pinfo(3)
 pvarname = "msl"

 print("phour=" + phour)
 print("pmonth=" + pmonth)
 print("pyear=" + pyear)
 print("pvarname=" + pvarname)

;----------------------------------------------------------------------
 info = readinfo("datainfo.txt")

 plottype = info(0)
 dirname = info(1)
 sfcfile = info(2)
 prsfile = info(3)

;----------------------------------------------------------------------
 fisfc = dirname+sfcfile

 fsfc = addfile(fisfc, "r")
 sfctime = fsfc->time(:)
 sfctstr = get_tstr(sfctime)

;print(sfctstr(0))

 sfcidx = get_mean_index(sfctime, phour, pmonth, pyear)
;print(sfcidx)
 ps = get_monthly_mean(sfcidx, pvarname, fsfc)
 printVarSummary(ps)

;----------------------------------------------------------------------
 fiprs = dirname+prsfile

 fprs = addfile(fiprs, "r")
 prstime = fprs->time(:)
 prststr = get_tstr(prstime)

;print(prststr(0))

 prsidx = get_mean_index(prstime, phour, pmonth, pyear)
;print(prsidx)

 it = get_valid_index(prsidx)
;print(it)

 u = short2flt(fprs->u(it,:,:,:))
 v = short2flt(fprs->v(it,:,:,:))
 t = short2flt(fprs->t(it,:,:,:))

 u = u(:,::-1,:)
 v = v(:,::-1,:)
 t = t(:,::-1,:)
 ps = ps(::-1,:)

;--------------------------------------------------------------------------------------
 VIDFD = get_vidfd(u, v, t, ps)
;VIDFD = get_vidfd(u(:,::2,::2), v(:,::2,::2), t(:,::2,::2), ps(::2,::2))

 tn = "monthly mean ERA5 VIDFD " + phour + " " + pmonth + " " + pyear
 imgname = "monthly_mean_ERA5_VIDFD_" + phour + "_" + pmonth + "_" + pyear
;plotit(VIDFD, tn, "x11", imgname)

 lat = t&latitude
 lon = t&longitude

;lat = t&latitude(::2,::2)
;lon = t&longitude(::2,::2)

 VIDFD!0 = "latitude"
 VIDFD!1 = "longitude"

 VIDFD@latitude = lat
 VIDFD@longitude = lon

 flnm = imgname+".nc"
 write_vidfd(VIDFD, flnm)

 printMinMax(VIDFD, True)

;--------------------------------------------------------------------------------------
 wks   = gsn_open_wks("png", imgname)
;wks   = gsn_open_wks("png","dfd_div")        ; send graphics to PNG file
;wks   = gsn_open_wks("x11","dfd_div")        ; send graphics to PNG file

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
 res@cnLevelSelectionMode = "ManualLevels"; manual set levels so lb consistent
 res@cnLevelSpacingF      =  1.0                  ; contour interval
 res@cnMaxLevelValF       = 10.0                  ; min level
 res@cnMinLevelValF       = -res@cnMaxLevelValF  ; min level
;res@tiMainString         = "ERA5 VIDFD"
 res@tiMainString         = tn

;--------------------------------------------------------------------------------------
;Integrated Divergence of Density Flux Convergence [no scaling]
 pvar := VIDFD(::4,::4)
 plt = gsn_csm_contour_map(wks,pvar,res)

;--------------------------------------------------------------------------------------
;Integrated Divergence of Density Flux Convergence [no scaling]
 pvar := VIDFD(::2,::2)
 plt = gsn_csm_contour_map(wks,pvar,res)

;--------------------------------------------------------------------------------------
;Integrated Divergence of Density Flux Convergence [no scaling]
 pvar := VIDFD
 plt = gsn_csm_contour_map(wks,pvar,res)

;--------------------------------------------------------------------------------------
;Integrated Divergence of Density Flux Convergence [no scaling]
 pvar := smth9(VIDFD, 0.50, -0.25, False)
 plt = gsn_csm_contour_map(wks,pvar,res)

;--------------------------------------------------------------------------------------
;Integrated Divergence of Density Flux Convergence [no scaling]
 pvar := smth9(VIDFD, 0.50,  0.25, True)
 plt = gsn_csm_contour_map(wks,pvar,res)

;--------------------------------------------------------------------------------------
;Integrated Divergence of Density Flux Convergence [no scaling]
;pvar := smth9(VIDFD, 0.50, -0.25, False)
;pvar = smth9(pvar, 0.50, -0.25, False)
;plt = gsn_csm_contour_map(wks,pvar,res)

;--------------------------------------------------------------------------------------
;Integrated Divergence of Density Flux Convergence [no scaling]
;pvar := smth9(VIDFD, 0.50,  0.25, True)
;pvar = smth9(pvar, 0.50,  0.25, True)
;plt = gsn_csm_contour_map(wks,pvar,res)

;--------------------------------------------------------------------------------------
;Integrated Divergence of Density Flux Convergence [no scaling]
;pvar := smth9(VIDFD, 0.50, -0.25, False)
;pvar = smth9(pvar, 0.50, -0.25, False)
;pvar = smth9(pvar, 0.50, -0.25, False)
;plt = gsn_csm_contour_map(wks,pvar,res)
 
;--------------------------------------------------------------------------------------
;Integrated Divergence of Density Flux Convergence [no scaling]
;pvar := smth9(VIDFD, 0.50,  0.25, True)
;pvar = smth9(pvar, 0.50,  0.25, True)
;pvar = smth9(pvar, 0.50,  0.25, True)
;plt = gsn_csm_contour_map(wks,pvar,res)


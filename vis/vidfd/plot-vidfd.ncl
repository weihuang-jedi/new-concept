load "categorical.ncl"

;----------------------------------------------------------------------
 info = readinfo("datainfo.txt")

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

 ptop = 1
 ptop@units = "hPa"
 g    = 9.80665          ; m/s2

 f = addfile(fi, "r")

 u = f->UGRD_P0_L100_GLL0(:,:,:)  ; m/s, (level,lat,lon)
 v = f->VGRD_P0_L100_GLL0(:,:,:)
 t = f->TMP_P0_L100_GLL0(:,:,:)
 ps = f->PRMSL_P0_L101_GLL0(:,:)

;Vertical levels
 ptop@units = "Pa"

 plev = t&lv_ISBL0                   ; [100000,...,30000] Pa [kg/(m-s2)]
 plev@units = "Pa"

;Divergence function [used later] requires S->N grid order

 u  = u(:,::-1,:)  
 v  = v(:,::-1,:)
 t  = t(:,::-1,:)     
 ps =ps(  ::-1,:)       

 rho = t
 copy_VarCoords(t,rho)
 rho@units = "kg/kg"

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

 print(dimdp)

 dpg  = dp/g    
 dpg@long_name = "Layer Mass Weighting"
 dpg@units     = "kg/m2"                     ; dp/g, Pa/(m s-2), reduce to kg m-2

;----------------------------------------------------------------------
;Density flux components at each pressure level

 urho = u*rho
 urho@long_name = "Zonal Density Flux [urho]"
 urho@units = "["+u@units+"]["+rho@units+"]"     ; [m/s][g/kg]     
 copy_VarCoords(u,urho)                        ; (level,lat,lon)

 vrho = v*rho
 vrho@long_name = "Meridional Density Flux [vrho]"
 vrho@units = "["+v@units+"]["+rho@units+"]" 
 copy_VarCoords(v,vrho)                        ; (level,lat,lon)

;----------------------------------------------------------------------
;Integrated mass weighted moisture flux components

 urho_dpg = urho*dpg                ; mass weighted 'urho'; [m/s][g/kg][kg/m2]=>[m/s][g/kg]
 iurho    = dim_sum_n(urho_dpg, 0)
 iurho@long_name = "Integrated Zonal URho [urho*dpg]" 
 iurho@LONG_NAME = "Sum: Mass Weighted Integrated Zonal Density Flux [urho*dpg]" 
 iurho@units     = "[m/s][g/kg]"
 copy_VarCoords(u(0,:,:), iurho); (lat,lon)
 delete(urho_dpg)

 vrho_dpg = vrho*dpg                ; mass weighted 'vrho'; [m/s][g/kg][kg/m2]=>[m/s][g/kg] 
 ivrho    = dim_sum_n(vrho_dpg, 0)
 ivrho@long_name = "Integrated Meridional VRho [vrho*dpg]" 
 ivrho@LONG_NAME = "Sum: Mass Weighted Integrated Meridional Density Flux [vrho*dpg]" 
 ivrho@units     = "[m/s][g/kg]"
 copy_VarCoords(v(0,:,:), ivrho); (lat,lon)
 delete(vrho_dpg)

;----------------------------------------------------------------------
;Divergence of moisture flux: uv2dvF => global 'fixed' rectilinear grid

 duvrho  = uv2dvF_Wrap(urho, vrho)    ; (level,lat,lon)
 duvrho@long_name = "Divergence of Density Flux"
 duvrho@units     = "g/(kg-s)"    ; (1/m)*[(m/s)(g/kg)] => [g/(kg-s)]

;----------------------------------------------------------------------
;Mass weighted integration [sum] of the divergence of moisture flux

 duvrho_dpg = duvrho*dpg            ;  [g/(kg-s)][kg/m2] => [g/(m2-s)]
 iduvrho    = dim_sum_n(duvrho_dpg, 0)
 iduvrho@long_name = "Integrated Mass Wgt DFD" 
 iduvrho@LONG_NAME = "Integrated Mass Weighted Density Flux Convergence" 
 iduvrho@units     = "g/(m2-s)"
 delete(duvrho_dpg)

 VIDFD = 1000.0*iduvrho           ; keep meta data                         
 VIDFD = -VIDFD           ; Note the preceding -1 [negative precedes integration] 
 copy_VarCoords(u(0,:,:), VIDFD)
 VIDFD@long_name = "VIDFD"
 VIDFD@units     = "g/(m2-s)"

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

 print("-----")
 print("VIDFD")
 printVarSummary(VIDFD)
 printMinMax(VIDFD, 0)

 write_dfc(VIDFD, fo)
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


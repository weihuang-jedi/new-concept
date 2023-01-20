load "categorical.ncl"

;----------------------------------------------------------------------
 dirname = "/work2/noaa/gsienkf/weihuang/gfs/data/jan2022/"
 finame = "monthly_mean_gfs_4_202201.nc"
 foname = "monthly_mean_mfc_202201.nc"

 info = readinfo("datainfo.txt")

 dirname = info(0)
 finame = info(1)
 foname = info(2)

 fi = dirname+finame
 fo = dirname+foname

 print("fi = " + fi)
 print("fo = " + fo)

;Vertical levels
 ptop = 1
 ptop@units = "Pa"
 g    = 9.80665          ; m/s2

 f = addfile(fi, "r")

 t = f->TMP_P0_L100_GLL0(:,:,:)

 plev = t&lv_ISBL0                   ; [100000,...,30000] Pa [kg/(m-s2)]
 plev@units = "Pa"

 p3d = conform_dims(dimsizes(t),plev,0)

;printVarSummary(t)
;printVarSummary(p3d)
;print(p3d(:,181,360))

 u = f->UGRD_P0_L100_GLL0(:,:,:)  ; m/s, (level,lat,lon)
 v = f->VGRD_P0_L100_GLL0(:,:,:)
 ps = f->PRMSL_P0_L101_GLL0(:,:)

;Divergence function [used later] requires S->N grid order

 u  = u(:,::-1,:)  
 v  = v(:,::-1,:)
 t  = t(:,::-1,:)     
 ps =ps(  ::-1,:)       

 r = p3d/(287.0*t)

;Layer thickness: ; Pa=>[kg/(m-s2)], (level,lat,lon) 
;Mass weighting: (dp/g) => [Pa/(m/s2)] => (Pa-s2)/m => [kg/(m-s2)][s2/m] =>  (kg/m2)
;Reference: http://www.cgd.ucar.edu/cas/catalog/newbudgets/

 dp = dpres_plevel_Wrap(plev, ps, ptop, 0) ; Pa; layar thickness 

 dimdp = dimsizes(dp)

;print(dimdp)

 dpg  = dp/g    
 dpg@long_name = "Layer Mass Weighting"
 dpg@units     = "kg/m2"                     ; dp/g, Pa/(m s-2), reduce to kg m-2

;Density flux components at each pressure level
 ur = u*r
 vr = v*r

;Integrated mass weighted moisture flux components
;Divergence of moisture flux: uv2dvF => global 'fixed' rectilinear grid

 duvr  = uv2dvF_Wrap(ur, vr)    ; (level,lat,lon)
 duvr@long_name = "Divergence of Density Flux"
 duvr@units     = "g/(kg-s)"    ; (1/m)*[(m/s)(g/kg)] => [g/(kg-s)]
 copy_VarCoords(u, duvr)        ; (lat,lon)

;Mass weighted integration [sum] of the divergence of moisture flux

 duvr_dpg = duvr*dpg            ;  [g/(kg-s)][kg/m2] => [g/(m2-s)]
 iduvr    = dim_sum_n(duvr_dpg, 0)
 iduvr@long_name = "Integrated DFC" 
 iduvr@LONG_NAME = "Integrated Density Flux Convergence" 
 iduvr@units     = "kg/(m2-s)"
 copy_VarCoords(u(0,:,:), iduvr)      ; (lat,lon)
 delete(duvr_dpg)

 VIDFC =  iduvr           ; keep meta data                         
 VIDFC = -VIDFC           ; Note the preceding -1 [negative precedes integration] 
 VIDFC@long_name = "VIDFC"

;-----------------------------------------------------------------------------------------
 printVarSummary(duvr)
 printVarSummary(VIDFC)
 write_dfc(duvr, VIDFC, fo)

